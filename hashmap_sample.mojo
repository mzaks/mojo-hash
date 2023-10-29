from hashmap import HashMapDict
from fnv1a import fnv1a64

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
    print(m.get("b", 0))
    m.delete("b")
    print(m.get("b", 0))
    m.debug()

    m._rehash()
    m.debug()
    print(m.get("a", 0))
    print(m.get("b", 0))
    print(m.get("c", 0))

    m.put("b", 45)
    m.debug()

    print(m.get("a", 0))
    print(m.get("b", 0))
    print(m.get("c", 0))
