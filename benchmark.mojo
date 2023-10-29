from time import now
from math import min, max
from fiby_tree import FibyTree
from my_utils import vec, int_cmp64, int_to_str64, cmp_strl, stsl, int_cmp, int_to_str, corpus1, corpus2, corpus3, corpus4, corpus5, corpus6, corpus7
from ahasher import ahash
from wyhasher import wyhash
from fnv1a import fnv1a64, fnv1a32
from fxhash import fxhash64, fxhash32


fn benchamark[hashfn: fn(StringLiteral) -> UInt64](corpus: UnsafeFixedVector[StringLiteral], name: StringLiteral):
    var f = FibyTree[UInt64, int_cmp64, int_to_str64]()
    var f1 = FibyTree[UInt64, int_cmp64, int_to_str64]()
    var fs = FibyTree[StringLiteral, cmp_strl, stsl]()
    var min_avg: Float64 = 100000.0
    let mod = (1 << 10)
    for _ in range(20):
        var total = 0
        for i in range(len(corpus)):
            let key = corpus[i]
            let tik = now()
            let hash = hashfn(key)
            let tok = now()
            total += tok - tik
            f.add(hash)
            f1.add(hash & (mod - 1))
            fs.add(key)
        let c_avg = total / len(corpus)
        min_avg = min(min_avg, c_avg)
    print(name, "avg hash compute", min_avg, "| hash colision", (fs.__len__() / f.__len__()), "| hash colision mod", mod, (fs.__len__() / f1.__len__()))

fn benchamark32[hashfn: fn(StringLiteral) -> UInt32](corpus: UnsafeFixedVector[StringLiteral], name: StringLiteral):
    var f = FibyTree[UInt32, int_cmp, int_to_str]()
    var f1 = FibyTree[UInt32, int_cmp, int_to_str]()
    var fs = FibyTree[StringLiteral, cmp_strl, stsl]()
    var min_avg: Float64 = 100000.0
    let mod = (1 << 10)
    for _ in range(20):
        var total = 0
        for i in range(len(corpus)):
            let key = corpus[i]
            let tik = now()
            let hash = hashfn(key)
            let tok = now()
            total += tok - tik
            f.add(hash)
            f1.add(hash & (mod - 1))
            fs.add(key)
        let c_avg = total / len(corpus)
        min_avg = min(min_avg, c_avg)
    print(name, "avg hash compute", min_avg, "| hash colision", (fs.__len__() / f.__len__()), "| hash colision mod", mod, (fs.__len__() / f1.__len__()))


fn corpus_details(corpus: UnsafeFixedVector[StringLiteral]):
    let word_count = len(corpus)
    var fs = FibyTree[StringLiteral, cmp_strl, stsl]()
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
        "Word count", word_count, "| unique word count", fs.__len__(), 
        "| min key size", min_key_size, "| avg key size", total_key_size / word_count, "| max key size", max_key_size
    )


fn sample_wyhash(s : StringLiteral) -> UInt64:
    let default_secret = SIMD[DType.uint64, 4](0xa0761d6478bd642f, 0xe7037ed1a0b428db, 0x8ebc6af09c88c6e3, 0x589965cc75374cc3)
    return wyhash(s, 0, default_secret)

fn sample_fxhash64(s : StringLiteral) -> UInt64:
    return fxhash64(s, 0)

fn sample_fxhash32(s : StringLiteral) -> UInt32:
    return fxhash32(s, 0)

fn main():
    let c1 = corpus1()
    print("\nCorpus 1")
    corpus_details(c1)
    benchamark[ahash](c1, "AHash")
    benchamark[sample_wyhash](c1, "Wyhash")
    benchamark32[fnv1a32](c1, "fnv1a32")
    benchamark[fnv1a64](c1, "fnv1a64")
    benchamark32[sample_fxhash32](c1, "fxHash32")
    benchamark[sample_fxhash64](c1, "fxHash64")

    let c2 = corpus2()
    print("\nCorpus 2")
    corpus_details(c2)
    benchamark[ahash](c2, "AHash")
    benchamark[sample_wyhash](c2, "Wyhash")
    benchamark32[fnv1a32](c2, "fnv1a32")
    benchamark[fnv1a64](c2, "fnv1a64")
    benchamark32[sample_fxhash32](c2, "fxHash32")
    benchamark[sample_fxhash64](c2, "fxHash64")

    let c3 = corpus3()
    print("\nCorpus 3")
    corpus_details(c3)
    benchamark[ahash](c3, "AHash")
    benchamark[sample_wyhash](c3, "Wyhash")
    benchamark32[fnv1a32](c3, "fnv1a32")
    benchamark[fnv1a64](c3, "fnv1a64")
    benchamark32[sample_fxhash32](c3, "fxHash32")
    benchamark[sample_fxhash64](c3, "fxHash64")

    let c4 = corpus4()
    print("\nCorpus 4")
    corpus_details(c4)
    benchamark[ahash](c4, "AHash")
    benchamark[sample_wyhash](c4, "Wyhash")
    benchamark32[fnv1a32](c4, "fnv1a32")
    benchamark[fnv1a64](c4, "fnv1a64")
    benchamark32[sample_fxhash32](c4, "fxHash32")
    benchamark[sample_fxhash64](c4, "fxHash64")

    let c5 = corpus5()
    print("\nCorpus 5")
    corpus_details(c5)
    benchamark[ahash](c5, "AHash")
    benchamark[sample_wyhash](c5, "Wyhash")
    benchamark32[fnv1a32](c5, "fnv1a32")
    benchamark[fnv1a64](c5, "fnv1a64")
    benchamark32[sample_fxhash32](c5, "fxHash32")
    benchamark[sample_fxhash64](c5, "fxHash64")

    let c6 = corpus6()
    print("\nCorpus 6")
    corpus_details(c6)
    benchamark[ahash](c6, "AHash")
    benchamark[sample_wyhash](c6, "Wyhash")
    benchamark32[fnv1a32](c6, "fnv1a32")
    benchamark[fnv1a64](c6, "fnv1a64")
    benchamark32[sample_fxhash32](c6, "fxHash32")
    benchamark[sample_fxhash64](c6, "fxHash64")

    let c7 = corpus7()
    print("\nCorpus 7")
    corpus_details(c7)
    benchamark[ahash](c7, "AHash")
    benchamark[sample_wyhash](c7, "Wyhash")
    benchamark32[fnv1a32](c7, "fnv1a32")
    benchamark[fnv1a64](c7, "fnv1a64")
    benchamark32[sample_fxhash32](c7, "fxHash32")
    benchamark[sample_fxhash64](c7, "fxHash64")