from time import now
from md5 import md5_string
from wyhasher import wyhash
from ahasher import ahash
from fxhash import fxhash64

import benchmark
from benchmark import Unit


fn main() raises:
    let text = Path("/usr/share/dict/words").read_text()
    var tik = now()
    let h0 = md5_string(text)
    var tok = now()
    print("MD5     :", tok - tik, h0, len(text))
    
    tik = now()
    let h1 = wyhash(text, 0)
    tok = now()
    print("Wyhash  :", tok - tik, h1, len(text))

    tik = now()
    let h2 = ahash(text)
    tok = now()
    print("Ahash   :", tok - tik, h2, len(text))

    tik = now()
    let h3 = fxhash64(text)
    tok = now()
    print("Fxhash  :", tok - tik, h3, len(text))

    tik = now()
    let h4 = hash(text._as_ptr(), len(text))
    tok = now()
    print("Std hash:", tok - tik, h4, len(text))

    var hb = SIMD[DType.uint8, 16]()

    @parameter
    fn md5_test():
        hb = md5_string(text)
    print("===MD5===")
    let report0 = benchmark.run[md5_test]()
    report0.print(Unit.ns)
    print(hb)
    
    var hi = 0

    @parameter
    fn hash_test():
        hi = hash(text._as_ptr(), len(text))

    print("===Std hash===")
    let report1 = benchmark.run[hash_test]()
    report1.print(Unit.ns)
    print(hi)

    var hu = UInt64(0)

    @parameter
    fn ahash_test():
        hu = ahash(text)

    print("===Ahash===")
    let report2 = benchmark.run[ahash_test]()
    report2.print(Unit.ns)
    print(hu)

    @parameter
    fn wyhash_test():
        hu = wyhash(text, 0)

    print("===Wyhash===")
    let report3 = benchmark.run[wyhash_test]()
    report3.print(Unit.ns)
    print(hu)
    
    _ = text
