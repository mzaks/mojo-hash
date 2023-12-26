from time import now
from math import min, max
from memory.unsafe import bitcast
from fiby_tree import FibyTree
from my_utils import int_cmp64, int_to_str64, cmp_str, stsl, int_cmp, int_to_str, corpus1, corpus2, corpus3, corpus4, corpus5, corpus6, corpus7, corpus8
from ahasher import ahash
from wyhasher import wyhash
from fnv1a import fnv1a64, fnv1a32
from fxhash import fxhash64, fxhash32
from md5 import md5_string

@always_inline
fn std_hash64(s: String) -> UInt64:
    return hash(s._as_ptr(), len(s))

@always_inline
fn md5_hash(s: String) -> UInt64:
    return bitcast[DType.uint64, 2](md5_string(s))[0]

fn benchamark[hashfn: fn(String) -> UInt64](corpus: DynamicVector[String], name: StringLiteral):
    # var f = FibyTree[UInt64, int_cmp64, int_to_str64]()
    # var f1 = FibyTree[UInt64, int_cmp64, int_to_str64]()
    var fs = FibyTree[String, cmp_str, String.__str__]()
    var min_avg: Float64 = 100000.0
    let mod = (1 << 9)
    var hashes = DynamicVector[UInt64]()
    var mod_hashes: DynamicVector[UInt64] = 0
    var total = 0
    for _ in range(20):
        for i in range(len(corpus)):
            let key = corpus[i]
            let tik = now()
            let hash = hashfn(key)
            let tok = now()
            # hash_total += hash
            total += tok - tik
            var found = False
            for i in range(len(hashes)):
                if hash == hashes[i]:
                    found = True
                    break
            if not found:
                hashes.append(hash)
            found = False
            for i in range(len(mod_hashes)):
                if  hash & (mod - 1) == mod_hashes[i]:
                    found = True
                    break
            if not found:
                mod_hashes.append(hash & (mod - 1))# f.add(hash)
            # f1.add(hash & (mod - 1))
            fs.add(key)
    let c_avg = (total / 20) / len(corpus)
    min_avg = min(min_avg, c_avg)
    print(
        name, "avg hash compute", min_avg, "| hash colision", len(fs) / len(hashes),
        "| hash colision mod", mod, len(fs) /  len(mod_hashes)
    )

fn benchamark32[hashfn: fn(String) -> UInt32](corpus: DynamicVector[String], name: StringLiteral):
    # var f = FibyTree[UInt32, int_cmp, int_to_str]()
    # var f1 = FibyTree[UInt32, int_cmp, int_to_str]()
    var fs = FibyTree[String, cmp_str, String.__str__]()
    var min_avg: Float64 = 100000.0
    let mod = (1 << 9)
    var hashes: DynamicVector[UInt32] = 0
    var mod_hashes: DynamicVector[UInt32] = 0
    var total = 0
    for _ in range(20):
        for i in range(len(corpus)):
            let key = corpus[i]
            let tik = now()
            let hash = hashfn(key)
            let tok = now()
            total += tok - tik
            var found = False
            for i in range(len(hashes)):
                if hash == hashes[i]:
                    found = True
                    break
            if not found:
                hashes.append(hash)
            found = False
            for i in range(len(mod_hashes)):
                if  hash & (mod - 1) == mod_hashes[i]:
                    found = True
                    break
            if not found:
                mod_hashes.append(hash & (mod - 1))
            # f.add(hash)
            # f1.add(hash & (mod - 1))
            fs.add(key)
    let c_avg = (total / 20) / len(corpus)
    min_avg = min(min_avg, c_avg)
    print(
        name, "avg hash compute", min_avg, "| hash colision", len(fs) / len(hashes), 
        "| hash colision mod", mod, len(fs) /  len(mod_hashes)
    )


fn corpus_details(corpus: DynamicVector[String]):
    let word_count = len(corpus)
    print(word_count)
    var fs = FibyTree[String, cmp_str, String.__str__]()
    var min_key_size = 10000000
    var max_key_size = 0
    var total_key_size = 0
    for i in range(word_count):
        let key = corpus[i]
        fs.add(key)
        let key_size = len(key)
        total_key_size += key_size
        min_key_size = min(min_key_size, key_size)
        max_key_size = max(max_key_size, key_size)

    print(
        "Word count", word_count, "| unique word count", 
        fs.__len__(), 
        "| min key size", min_key_size, "| avg key size", total_key_size / word_count, "| max key size", max_key_size
    )


fn sample_wyhash(s : String) -> UInt64:
    let default_secret = SIMD[DType.uint64, 4](0xa0761d6478bd642f, 0xe7037ed1a0b428db, 0x8ebc6af09c88c6e3, 0x589965cc75374cc3)
    return wyhash(s, 0, default_secret)

fn sample_fxhash64(s : String) -> UInt64:
    return fxhash64(s, 0)

fn sample_fxhash32(s : String) -> UInt32:
    return fxhash32(s, 0)

fn main() raises:
    let c1 = corpus1()
    print("\nCorpus 1")
    corpus_details(c1)
    benchamark[ahash](c1, "AHash")
    benchamark[sample_wyhash](c1, "Wyhash")
    benchamark32[fnv1a32](c1, "fnv1a32")
    benchamark[fnv1a64](c1, "fnv1a64")
    benchamark32[sample_fxhash32](c1, "fxHash32")
    benchamark[sample_fxhash64](c1, "fxHash64")
    benchamark[std_hash64](c1, "std_Hash64")
    benchamark[md5_hash](c1, "MD5")

    let c2 = corpus2()
    print("\nCorpus 2")
    corpus_details(c2)
    benchamark[ahash](c2, "AHash")
    benchamark[sample_wyhash](c2, "Wyhash")
    benchamark32[fnv1a32](c2, "fnv1a32")
    benchamark[fnv1a64](c2, "fnv1a64")
    benchamark32[sample_fxhash32](c2, "fxHash32")
    benchamark[sample_fxhash64](c2, "fxHash64")
    benchamark[std_hash64](c2, "std_Hash64")
    benchamark[md5_hash](c2, "MD5")
    
    let c3 = corpus3()
    print("\nCorpus 3")
    corpus_details(c3)
    benchamark[ahash](c3, "AHash")
    benchamark[sample_wyhash](c3, "Wyhash")
    benchamark32[fnv1a32](c3, "fnv1a32")
    benchamark[fnv1a64](c3, "fnv1a64")
    benchamark32[sample_fxhash32](c3, "fxHash32")
    benchamark[sample_fxhash64](c3, "fxHash64")
    benchamark[std_hash64](c3, "std_Hash64")
    benchamark[md5_hash](c3, "MD5")

    let c4 = corpus4()
    print("\nCorpus 4")
    corpus_details(c4)
    benchamark[ahash](c4, "AHash")
    benchamark[sample_wyhash](c4, "Wyhash")
    benchamark32[fnv1a32](c4, "fnv1a32")
    benchamark[fnv1a64](c4, "fnv1a64")
    benchamark32[sample_fxhash32](c4, "fxHash32")
    benchamark[sample_fxhash64](c4, "fxHash64")
    benchamark[std_hash64](c4, "std_Hash64")
    benchamark[md5_hash](c4, "MD5")

    let c5 = corpus5()
    print("\nCorpus 5")
    corpus_details(c5)
    benchamark[ahash](c5, "AHash")
    benchamark[sample_wyhash](c5, "Wyhash")
    benchamark32[fnv1a32](c5, "fnv1a32")
    benchamark[fnv1a64](c5, "fnv1a64")
    benchamark32[sample_fxhash32](c5, "fxHash32")
    benchamark[sample_fxhash64](c5, "fxHash64")
    benchamark[std_hash64](c5, "std_Hash64")
    benchamark[md5_hash](c5, "MD5")

    let c6 = corpus6()
    print("\nCorpus 6")
    corpus_details(c6)
    benchamark[ahash](c6, "AHash")
    benchamark[sample_wyhash](c6, "Wyhash")
    benchamark32[fnv1a32](c6, "fnv1a32")
    benchamark[fnv1a64](c6, "fnv1a64")
    benchamark32[sample_fxhash32](c6, "fxHash32")
    benchamark[sample_fxhash64](c6, "fxHash64")
    benchamark[std_hash64](c6, "std_Hash64")
    benchamark[md5_hash](c6, "MD5")

    let c7 = corpus7()
    print("\nCorpus 7")
    corpus_details(c7)
    benchamark[ahash](c7, "AHash")
    benchamark[sample_wyhash](c7, "Wyhash")
    benchamark32[fnv1a32](c7, "fnv1a32")
    benchamark[fnv1a64](c7, "fnv1a64")
    benchamark32[sample_fxhash32](c7, "fxHash32")
    benchamark[sample_fxhash64](c7, "fxHash64")
    benchamark[std_hash64](c7, "std_Hash64")
    benchamark[md5_hash](c7, "MD5")

    let c8 = corpus8()
    print("\nCorpus 8")
    corpus_details(c8)
    benchamark[ahash](c8, "AHash")
    benchamark[sample_wyhash](c8, "Wyhash")
    benchamark32[fnv1a32](c8, "fnv1a32")
    benchamark[fnv1a64](c8, "fnv1a64")
    benchamark32[sample_fxhash32](c8, "fxHash32")
    benchamark[sample_fxhash64](c8, "fxHash64")
    benchamark[std_hash64](c8, "std_Hash64")
    benchamark[md5_hash](c8, "MD5")
