from fnv1a import fnv1a64
from memory import memset_zero

struct HashMapDict[V: AnyType, hash: fn(StringLiteral) -> UInt64]:
    var keys: DynamicVector[StringLiteral]
    var values: DynamicVector[V]
    var key_map: DTypePointer[DType.uint32]
    var count: Int
    var capacity: Int

    fn __init__(inout self):
        self.count = 0
        self.capacity = 16
        self.keys = DynamicVector[StringLiteral](self.capacity)
        self.values = DynamicVector[V](self.capacity)
        self.key_map = DTypePointer[DType.uint32].alloc(self.capacity)
        memset_zero(self.key_map, self.capacity)

    fn put(inout self, key: StringLiteral, value: V):
        if self.count / self.capacity >= 0.8:
            self._rehash()
        
        self._put(key, value, -1)
    
    fn _rehash(inout self):
        self.key_map.free()
        self.capacity <<= 1
        self.key_map = DTypePointer[DType.uint32].alloc(self.capacity)
        memset_zero(self.key_map, self.capacity)
        for i in range(len(self.keys)):
            self._put(self.keys[i], self.values[i], i + 1)

    fn _put(inout self, key: StringLiteral, value: V, rehash_index: Int):
        let key_hash = hash(key)
        let modulo_mask = self.capacity - 1
        var key_map_index = (key_hash & modulo_mask).to_int()
        while True:
            let key_index = self.key_map.offset(key_map_index).load().to_int()
            if key_index == 0:
                let new_key_index: Int
                if rehash_index == -1:
                    self.keys.push_back(key)
                    self.values.push_back(value)
                    self.count += 1
                    new_key_index = len(self.keys)
                else:
                    new_key_index = rehash_index
                self.key_map.offset(key_map_index).store(UInt32(new_key_index))
                return

            let other_key = self.keys[key_index - 1]
            if other_key == key:
                self.values[key_index - 1] = value
                return
            
            key_map_index = (key_map_index + 1) & modulo_mask

    fn get(self, key: StringLiteral, default: V) -> V:
        let key_hash = hash(key)
        let modulo_mask = self.capacity - 1
        var key_map_index = (key_hash & modulo_mask).to_int()
        while True:
            let key_index = self.key_map.offset(key_map_index).load().to_int()
            if key_index == 0:
                return default
            let other_key = self.keys[key_index - 1]
            if other_key == key:
                return self.values[key_index - 1]
            key_map_index = (key_map_index + 1) & modulo_mask

    fn debug(self):
        print("HashMapDict", "count:", self.count, "capacity:", self.capacity)
        print_no_newline("Keys:")
        for i in range(len(self.keys)):
            print_no_newline(self.keys[i])
            print_no_newline(", ")
        print_no_newline("\n")
        print_no_newline("Key map:")
        for i in range(self.capacity):
            print_no_newline(self.key_map.offset(i).load())
            print_no_newline(", ")
        print_no_newline("\n")

fn main():
    var m = HashMapDict[Int, fnv1a64]()
    m.put("a", 123)
    m.debug()
    print(m.get("a", 0))

    m.put("b", 12)
    m.put("c", 345)
    m.put("a", 111)
    m.debug()
    print(m.get("a", 0))

    m._rehash()
    m.debug()
    print(m.get("a", 0))
    print(m.get("b", 0))
    print(m.get("c", 0))