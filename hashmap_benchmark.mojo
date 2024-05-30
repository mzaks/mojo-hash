from fxhash import fxhash64
from hashmap import HashMapDict
from my_utils import corpus1, corpus2, corpus3, corpus4, corpus5, corpus6, corpus7, corpus8
from wyhasher import wyhash
from time import now
from testing import assert_equal
from ahasher import ahash
from collections.dict import Dict, KeyElement

fn _fxhash64(s: String) -> UInt64:
    return fxhash64(s, 0)

fn _wyhash(s : String) -> UInt64:
    var default_secret = SIMD[DType.uint64, 4](0xa0761d6478bd642f, 0xe7037ed1a0b428db, 0x8ebc6af09c88c6e3, 0x589965cc75374cc3)
    return wyhash(s, 0, default_secret)

fn _std_hash(s: String) -> UInt64:
    return hash(s.unsafe_uint8_ptr(), len(s))

fn all_corpus() raises -> List[List[String]]:
    var result = List[List[String]]()
    result.append(corpus1())
    result.append(corpus2())
    result.append(corpus3())
    result.append(corpus4())
    result.append(corpus5())
    result.append(corpus6())
    result.append(corpus7())
    result.append(corpus8())
    return result

fn benchamark_hash_map[hash_fn: fn(String) -> UInt64](name: String) raises:
    var corpus_list = all_corpus()
    for i in range(len(corpus_list)):
        var min_put = 0
        var min_get = 0
        var rounds = 10
    
        print("Corpus", i + 1)
        var corpus = corpus_list[i]
        var value_sum = 0
        for _ in range(rounds):
            # var map = HashMapDict[Int, hash_fn](len(corpus) * 2)
            var map = HashMapDict[Int, hash_fn]()
            var total = 0
            for i in range(len(corpus)):
                var key = corpus[i]
                var tik = now()
                map.put(key, i)
                var tok = now()
                total += tok - tik

            min_put += total
            # print("Avg put time", total / len(corpus))

            total = 0
            value_sum = 0
            for i in range(len(corpus)):
                var key = corpus[i]
                var tik = now()
                var value = map.get(key, -1)
                var tok = now()
                value_sum += value
                total += tok - tik

            min_get += total
        
        print(name, "Avg put time", min_put / (len(corpus) * rounds))
        print(name, "Avg get time", min_get / (len(corpus) * rounds))
        print(value_sum)

fn benchamark_std_hash_map() raises:
    var corpus_list = all_corpus()
    for i in range(len(corpus_list)):
        var min_put = 0
        var min_get = 0
        var rounds = 10
        var value_sum = 0
        print("Corpus", i + 1)
        var corpus = corpus_list[i]
        for _ in range(rounds):
            var map = Dict[String, Int]()
            var total = 0
            for i in range(len(corpus)):
                var key = corpus[i]
                var tik = now()
                map[key] = i
                var tok = now()
                total += tok - tik

            min_put += total
            # print("Avg put time", total / len(corpus))

            total = 0
            value_sum = 0
            for i in range(len(corpus)):
                var key = corpus[i]
                var tik = now()
                var value = map[key]
                var tok = now()
                value_sum += value
                total += tok - tik

            min_get += total
    
        print("Std dict avg put time", min_put / (len(corpus) * rounds))
        print("Std dict avg get time", min_get / (len(corpus) * rounds))
        print(value_sum)

fn main() raises :
    benchamark_hash_map[ahash]("AHash")
    # benchamark_hash_map[_wyhash]("WyHash")
    # benchamark_hash_map[_fxhash64]("FxHash64")
    # benchamark_hash_map[_std_hash]("StdHash")
    benchamark_std_hash_map()
