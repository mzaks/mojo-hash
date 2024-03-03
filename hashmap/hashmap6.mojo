from math.bit import bit_length, ctpop
from memory import memset_zero, memcpy
from sys.intrinsics import masked_load

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
    var count: Int
    var capacity: Int

    fn __init__(inout self, capacity: Int):
        self.allocated_bytes = capacity << 3
        self.keys = DTypePointer[DType.int8].alloc(self.allocated_bytes)
        self.keys_end = DTypePointer[DType.int32].alloc(capacity)
        self.count = 0
        self.capacity = capacity

    @always_inline
    fn add(inout self, key: String):
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
        self.keys_end.store(self.count - 1, new_end)

    @always_inline
    fn get(self, index: Int) -> StringRef:
        if index < 0 or index >= self.count:
            return ""
        var start = 0 if index == 0 else self.keys_end[index - 1]
        var length = self.keys_end[index] - start
        return StringRef(self.keys.offset(start), length.to_int())
    
    @always_inline
    fn get_index(self, key: String) -> Int:
        var l1 = len(key)
        var p1 = key._as_ptr()
        var start = 0
        var index_offset = 0
        alias lanes = 4
        while self.count - index_offset >= lanes:
            var ends = self.keys_end.simd_load[lanes](index_offset)
            var starts = ends.shift_right[1]()
            starts[0] = start
            var lengths = ends - starts
            var skip_mask = lengths != l1
            
            if skip_mask:
                start = ends[lanes-1].to_int()
                index_offset += lanes
                continue

            for i in range(lanes):
                start = ends[i].to_int()
                if skip_mask[i]:
                    continue
                if eq(p1, self.keys.offset(start), l1):
                    return index_offset + i
            
            index_offset += lanes

        for i in range(index_offset, self.count):
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
    fn __getitem__(self, index: Int) -> StringRef:
        return self.get(index)

    @always_inline
    fn __len__(self) -> Int:
        return self.count


struct HashMapDict[V: CollectionElement, hash: fn(String) -> UInt64]:
    var keys: KeysContainer
    var values: DynamicVector[V]
    var count: Int

    fn __init__(inout self, capacity: Int = 16):
        self.keys = KeysContainer(capacity)
        self.values = DynamicVector[V](capacity=capacity)
        self.count = 0

    fn put(inout self, key: String, value: V):
        var index = self.keys.get_index(key)
        if index < 0:
            self.keys.add(key)
            self.values.push_back(value)
        else:
            self.values[index] = value
        self.count += 1

    fn get(self, key: String, default: V) -> V:
        var index = self.keys.get_index(key)
        if index < 0:
            return default
        else:
            return self.values[index]
