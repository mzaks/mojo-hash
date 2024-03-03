from collections import Dict, KeyElement

@value
struct StringKey(KeyElement):
    var s: String

    fn __init__(inout self, owned s: String):
        self.s = s^

    fn __init__(inout self, s: StringLiteral):
        self.s = String(s)

    fn __hash__(self) -> Int:
        let ptr = self.s._as_ptr()
        return hash(ptr, len(self.s))

    fn __eq__(self, other: Self) -> Bool:
        return self.s == other.s

fn main() raises:
    # let keys = String('Проснувшись однажды утром после беспокойного сна, Грегор Замза').split(" ")

    let keys = String('Проснувшись однажды утром после беспокойного сна Грегор Замза').split(" ")
    var d = Dict[StringKey, Int]()
    for i in range(len(keys)):
        d[keys[i]] = i
    print(d.size, len(keys))
    for i in range(len(keys)):
        let k = keys[i]
        print(k, hash(k))
        print(k, d[k])
