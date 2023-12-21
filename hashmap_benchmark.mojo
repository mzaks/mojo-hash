from fxhash import fxhash64
from hashmap import HashMapDict
from my_utils import corpus7
from wyhasher import wyhash
from time import now
from testing import assert_equal
from ahasher import ahash
from math import min

fn _fxhash64(s: String) -> UInt64:
    return fxhash64(s, 0)

fn _wyhash(s : String) -> UInt64:
    let default_secret = SIMD[DType.uint64, 4](0xa0761d6478bd642f, 0xe7037ed1a0b428db, 0x8ebc6af09c88c6e3, 0x589965cc75374cc3)
    return wyhash(s, 0, default_secret)

fn _std_hash(s: String) -> UInt64:
    return hash(s._as_ptr(), len(s))

fn benchamark_hash_map[hash_fn: fn(String) -> UInt64](name: String) raises:
    var min_put = 0
    var min_get = 0
    let corpus = corpus7()
    let rounds = 10
    for _ in range(rounds):
        var map = HashMapDict[Int, hash_fn]()
        var total = 0
        for i in range(len(corpus)):
            let key = corpus[i]
            let tik = now()
            map.put(key, i)
            let tok = now()
            total += tok - tik

        min_put += total
        # print("Avg put time", total / len(corpus))

        total = 0
        var value_sum = 0
        for i in range(len(corpus)):
            let key = corpus[i]
            let tik = now()
            let value = map.get(key, 999)
            let tok = now()
            value_sum += value
            total += tok - tik

        min_get += total
        # print("Avg get time", total / len(corpus))
        assert_equal(value_sum, 14403)
    
    print(name, "Avg put time", min_put / (len(corpus) * rounds))
    print(name, "Avg get time", min_get / (len(corpus) * rounds))

fn main() raises :
    benchamark_hash_map[ahash]("AHash")
    benchamark_hash_map[_wyhash]("WyHash")
    benchamark_hash_map[_fxhash64]("FxHash64")
    benchamark_hash_map[_std_hash]("StdHash")
