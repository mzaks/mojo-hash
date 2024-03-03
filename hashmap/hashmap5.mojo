from math.bit import bit_length, ctpop
from memory import memset_zero, memcpy

@always_inline
fn eq(p1: DTypePointer[DType.int8], p2: DTypePointer[DType.int8], l: Int) -> Bool:
    var offset = 0
    alias step = 16
    while l - offset >= step:
        if p1.simd_load[step](offset) != p2.simd_load[step](offset):
            return False
        offset += step
    while l - offset > 0:
        if p1.load(offset) != p2.load(offset):
            return False
        offset += 1
    return True

struct KeysContainer(Sized):
    var keys: DTypePointer[DType.int8]
    var allocated_bytes: Int
    var keys_end: DTypePointer[DType.int32]
    var key_hashes: DTypePointer[DType.uint64]
    var count: Int
    var capacity: Int

    fn __init__(inout self, capacity: Int):
        self.allocated_bytes = capacity << 3
        self.keys = DTypePointer[DType.int8].alloc(self.allocated_bytes)
        self.keys_end = DTypePointer[DType.int32].alloc(capacity)
        self.key_hashes = DTypePointer[DType.uint64].alloc(capacity)
        self.count = 0
        self.capacity = capacity

    @always_inline
    fn add(inout self, key: String, hash_key: UInt64):
        var prev_end = 0 if self.count == 0 else self.keys_end[self.count - 1]
        var key_length = len(key)
        var new_end = prev_end + key_length
        
        var needs_realocation = False
        while new_end > self.allocated_bytes:
            self.allocated_bytes <<= 1
            needs_realocation = True

        if needs_realocation:
            var keys = DTypePointer[DType.int8].alloc(self.allocated_bytes)
            memcpy(keys, self.keys, prev_end.to_int())
            self.keys.free()
            self.keys = keys
        
        memcpy(self.keys.offset(prev_end), key._as_ptr(), key_length)
        self.count += 1
        if self.capacity <= self.count:
            self.capacity <<= 1
            var keys_end = DTypePointer[DType.int32].alloc(self.capacity)
            memcpy(keys_end, self.keys_end, self.count - 1)
            self.keys_end.free()
            self.keys_end = keys_end
            var key_hashes = DTypePointer[DType.uint64].alloc(self.capacity)
            memcpy(key_hashes, self.key_hashes, self.count - 1)
            self.key_hashes.free()
            self.key_hashes = key_hashes
        self.keys_end.store(self.count - 1, new_end)
        self.key_hashes.store(self.count - 1, hash_key)

    @always_inline
    fn get_index(self, key: String, key_hash: UInt64) -> Int:
        var l1 = len(key)
        var p1 = key._as_ptr()
        var start = 0
        var index_offset = 0

        for i in range(index_offset, self.count):
            if key_hash != self.key_hashes[i]:
                continue
            var found = True
            var end = self.keys_end[i].to_int()
            var l2 = end - start
            if l1 != l2:
                start = end
                continue
            if eq(p1, self.keys.offset(start), l1):
                return i
        return -1
        
    @always_inline
    fn __len__(self) -> Int:
        return self.count

struct HashMapDict[V: CollectionElement, hash: fn(String) -> UInt64]:
    var keys: KeysContainer
    var values: DynamicVector[V]
    var deleted_mask: DTypePointer[DType.uint8]

    fn __init__(inout self, capacity: Int = 16):
        var _capacity = 8
        if capacity > 8:
            var icapacity = Int64(capacity)
            _capacity = capacity if ctpop(icapacity) == 1 else
                            1 << (bit_length(icapacity)).to_int()
        self.keys = KeysContainer(capacity)
        self.values = DynamicVector[V](capacity=_capacity)
        self.deleted_mask = DTypePointer[DType.uint8].alloc(_capacity >> 3)
        memset_zero(self.deleted_mask, _capacity >> 3)

    fn put(inout self, key: String, value: V):
        var key_hash = hash(key)
        var index = self.keys.get_index(key, key_hash)
        if index >= 0:
            if self._is_deleted(index):
                self._not_deleted(index)
            self.values[index] = value
        else:
            self.keys.add(key, key_hash)

    @always_inline
    fn _is_deleted(self, index: Int) -> Bool:
        var offset = index // 8
        var bit_index = index & 7
        return self.deleted_mask.offset(offset).load() & (1 << bit_index) != 0

    @always_inline
    fn _deleted(self, index: Int):
        var offset = index // 8
        var bit_index = index & 7
        var p = self.deleted_mask.offset(offset)
        var mask = p.load()
        p.store(mask | (1 << bit_index))
    
    @always_inline
    fn _not_deleted(self, index: Int):
        var offset = index // 8
        var bit_index = index & 7
        var p = self.deleted_mask.offset(offset)
        var mask = p.load()
        p.store(mask & ~(1 << bit_index))

    fn get(self, key: String, default: V) -> V:
        var key_hash = hash(key)
        var index = self.keys.get_index(key, key_hash)
        if index < 0 or self._is_deleted(index):
            return default
        return self.values[index]

    fn delete(inout self, key: String):
        var key_hash = hash(key)
        var index = self.keys.get_index(key, key_hash)
        if index >= 0:
            self._deleted(index)  
