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

    # @parameter
    # fn md5_test():
    #     _ = md5_string(text)

    # let report0 = benchmark.run[md5_test]()
    # report0.print(Unit.ms)

    @parameter
    fn hash_test():
        _ = hash(text._as_ptr(), len(text))

    let report1 = benchmark.run[hash_test]()
    report1.print(Unit.ns)
    
    _ = text
