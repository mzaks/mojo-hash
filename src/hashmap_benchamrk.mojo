from fxhash import fxhash64
from hashmap import HashMapDict
from my_utils import vec
from wyhash import wyhash
from time import now
from testing import assert_equal
from corpus import corpus7

fn _fxhash64(s: StringLiteral) -> UInt64:
    return fxhash64(s, 0)

fn _wyhash(s : StringLiteral) -> UInt64:
    let default_secret = SIMD[DType.uint64, 4](0xa0761d6478bd642f, 0xe7037ed1a0b428db, 0x8ebc6af09c88c6e3, 0x589965cc75374cc3)
    return wyhash(s, 0, default_secret)

fn main():
    let corpus = corpus7()
    var map = HashMapDict[Int, _wyhash]()
    var total = 0
    for i in range(len(corpus)):
        let key = corpus[i]
        let tik = now()
        map.put(key, i)
        let tok = now()
        total += tok - tik

    print("Avg put time", total / len(corpus))

    total = 0
    var value_sum = 0
    for i in range(len(corpus)):
        let key = corpus[i]
        let tik = now()
        let value = map.get(key, 999)
        let tok = now()
        value_sum += value
        total += tok - tik

    print("Avg get time", total / len(corpus))
    if not assert_equal(value_sum, 14403):
        print("ERROR!!!", value_sum, "is not equal to", 14403)