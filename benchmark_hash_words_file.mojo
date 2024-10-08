from time import now
from md5 import md5_string
from wyhasher import wyhash
from ahasher import ahash
from fxhash import fxhash64
from sha import sha256_encode

import benchmark
from benchmark import Unit
from pathlib import Path
from collections.vector import InlinedFixedVector

fn to_hex(digest: InlinedFixedVector[UInt8, 32]) -> String:
    var lookup = String("0123456789abcdef")
    var result: String = ""
    for i in range(len(digest)):
        var v = int(digest[i])
        result += lookup[(v >> 4)]
        result += lookup[v & 15]
    return result

fn to_hex(digest: SIMD[DType.uint8, 16]) -> String:
    var lookup = String("0123456789abcdef")
    var result: String = ""
    for i in range(len(digest)):
        var v = int(digest[i])
        result += lookup[(v >> 4)]
        result += lookup[v & 15]
    return result

fn main() raises:
    var text = Path("/usr/share/dict/words").read_text()
    var tik = now()
    var h0 = md5_string(text)
    var tok = now()
    print("MD5     :", tok - tik, to_hex(h0), len(text))
    
    tik = now()
    var h5 = sha256_encode(text.unsafe_ptr(), 0)
    tok = now()
    print("SHA256  :", tok - tik, to_hex(h5), len(text))

    tik = now()
    var h1 = wyhash(text, 0)
    tok = now()
    print("Wyhash  :", tok - tik, h1, len(text))

    tik = now()
    var h2 = ahash(text)
    tok = now()
    print("Ahash   :", tok - tik, h2, len(text))

    tik = now()
    var h3 = fxhash64(text)
    tok = now()
    print("Fxhash  :", tok - tik, h3, len(text))

    tik = now()
    var h4 = hash(text.unsafe_ptr(), len(text))
    tok = now()
    print("Std hash:", tok - tik, h4, len(text))

    var hb = SIMD[DType.uint8, 16]()

    @parameter
    fn md5_test():
        hb = md5_string(text)
    print("===MD5===")
    var report0 = benchmark.run[md5_test]()
    report0.print(Unit.ns)
    print(hb)
    
    var hi = 0

    @parameter
    fn hash_test():
        hi = hash(text.unsafe_ptr(), len(text))

    print("===Std hash===")
    var report1 = benchmark.run[hash_test]()
    report1.print(Unit.ns)
    print(hi)

    var hu = UInt64(0)

    @parameter
    fn ahash_test():
        hu = ahash(text)

    print("===Ahash===")
    var report2 = benchmark.run[ahash_test]()
    report2.print(Unit.ns)
    print(hu)

    @parameter
    fn wyhash_test():
        hu = wyhash(text, 0)

    print("===Wyhash===")
    var report3 = benchmark.run[wyhash_test]()
    report3.print(Unit.ns)
    print(hu)
    
    _ = text
