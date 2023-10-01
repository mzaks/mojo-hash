# mojo-hash
A collection of hash functions implemented in Mojo.

## AHash
Original repo: https://github.com/tkaitchuck/aHash 
Note: implements the fallback version (without AES-NI intrinsics use), uses folded multiply function without u128 support

## fnv1a
Original repo: https://github.com/ziglang/zig/blob/master/lib/std/hash/fnv.zig
Note: implements 32 and 64 bit variants

## fxhash
Original repo: https://github.com/cbreeden/fxhash/tree/master
Note: implements 32 and 64 bit variants

## Wyhash
Original repo: https://github.com/wangyi-fudan/wyhash
Note: `wymum` implemented as if `WYHASH_32BIT_MUM` is set and `WYHASH_CONDOM` not set. Little endian only.

## Benachmark
Collecets average hash function runtime in nanoseconds based on 7 different word collections. The average runtime is computed 20 times on each word collection, the fastest is kept as final result. Shows collision on full 32/64 bit space and 1024 mod (10 bit) space

### Results

CPU Specs: 11th Gen Intel(R) Core(TM) i7-1165G7 @ 2.80GHz

```
Corpus 1
Word count 100 | unique word count 82 | min key size 2 | avg key size 5.71 | max key size 12
AHash avg hash compute 17.579999999999998 | hash colision 1.0 | hash colision mod 1024 1.0933333333333333
Wyhash avg hash compute 18.84 | hash colision 1.0 | hash colision mod 1024 1.0512820512820513
fnv1a32 avg hash compute 16.960000000000001 | hash colision 1.0 | hash colision mod 1024 1.0649350649350648
fnv1a64 avg hash compute 18.809999999999999 | hash colision 1.0 | hash colision mod 1024 1.0249999999999999
fxHash32 avg hash compute 14.76 | hash colision 1.0 | hash colision mod 1024 1.1081081081081081
fxHash64 avg hash compute 14.66 | hash colision 1.0 | hash colision mod 1024 1.1081081081081081

Corpus 2
Word count 999 | unique word count 203 | min key size 1 | avg key size 4.8058058058058055 | max key size 14
AHash avg hash compute 18.332332332332332 | hash colision 1.0 | hash colision mod 1024 1.1032608695652173
Wyhash avg hash compute 16.618618618618619 | hash colision 1.0 | hash colision mod 1024 1.1153846153846154
fnv1a32 avg hash compute 14.674674674674675 | hash colision 1.0 | hash colision mod 1024 1.1340782122905029
fnv1a64 avg hash compute 15.634634634634635 | hash colision 1.0 | hash colision mod 1024 1.0972972972972972
fxHash32 avg hash compute 13.125125125125125 | hash colision 1.0 | hash colision mod 1024 1.2011834319526626
fxHash64 avg hash compute 13.001001001001001 | hash colision 1.0 | hash colision mod 1024 1.2378048780487805

Corpus 3
Word count 999 | unique word count 192 | min key size 1 | avg key size 4.293293293293293 | max key size 13
AHash avg hash compute 15.86986986986987 | hash colision 1.0 | hash colision mod 1024 1.0847457627118644
Wyhash avg hash compute 18.938938938938939 | hash colision 1.0 | hash colision mod 1024 1.0971428571428572
fnv1a32 avg hash compute 14.131131131131131 | hash colision 1.0 | hash colision mod 1024 1.0666666666666667
fnv1a64 avg hash compute 15.406406406406406 | hash colision 1.0 | hash colision mod 1024 1.0971428571428572
fxHash32 avg hash compute 12.893893893893894 | hash colision 1.0 | hash colision mod 1024 1.2229299363057324
fxHash64 avg hash compute 12.980980980980981 | hash colision 1.0 | hash colision mod 1024 1.28

Corpus 4
Word count 999 | unique word count 532 | min key size 2 | avg key size 10.646646646646646 | max key size 37
AHash avg hash compute 16.003003003003002 | hash colision 1.0 | hash colision mod 1024 1.2636579572446556
Wyhash avg hash compute 17.547547547547548 | hash colision 1.0 | hash colision mod 1024 1.2666666666666666
fnv1a32 avg hash compute 19.814814814814813 | hash colision 1.0 | hash colision mod 1024 1.3071253071253071
fnv1a64 avg hash compute 22.227227227227228 | hash colision 1.0 | hash colision mod 1024 1.2727272727272727
fxHash32 avg hash compute 15.745745745745745 | hash colision 1.0 | hash colision mod 1024 1.3711340206185567
fxHash64 avg hash compute 17.272272272272271 | hash colision 1.0 | hash colision mod 1024 1.5833333333333333

Corpus 5
Word count 999 | unique word count 208 | min key size 2 | avg key size 5.6496496496496498 | max key size 18
AHash avg hash compute 15.645645645645645 | hash colision 1.0 | hash colision mod 1024 1.0505050505050506
Wyhash avg hash compute 16.611611611611611 | hash colision 1.0 | hash colision mod 1024 1.0833333333333333
fnv1a32 avg hash compute 16.927927927927929 | hash colision 1.0 | hash colision mod 1024 1.1304347826086956
fnv1a64 avg hash compute 18.48948948948949 | hash colision 1.0 | hash colision mod 1024 1.1304347826086956
fxHash32 avg hash compute 12.962962962962964 | hash colision 1.0 | hash colision mod 1024 1.1818181818181819
fxHash64 avg hash compute 14.824824824824825 | hash colision 1.0 | hash colision mod 1024 1.1954022988505748

Corpus 6
Word count 10 | unique word count 10 | min key size 378 | avg key size 499.19999999999999 | max key size 558
AHash avg hash compute 58.799999999999997 | hash colision 1.0 | hash colision mod 1024 1.0
Wyhash avg hash compute 72.400000000000006 | hash colision 1.0 | hash colision mod 1024 1.0
fnv1a32 avg hash compute 498.30000000000001 | hash colision 1.0 | hash colision mod 1024 1.0
fnv1a64 avg hash compute 619.89999999999998 | hash colision 1.0 | hash colision mod 1024 1.0
fxHash32 avg hash compute 163.59999999999999 | hash colision 1.0 | hash colision mod 1024 1.0
fxHash64 avg hash compute 87.900000000000006 | hash colision 1.0 | hash colision mod 1024 1.0

Corpus 7
Word count 161 | unique word count 143 | min key size 8 | avg key size 22.242236024844722 | max key size 43
AHash avg hash compute 18.683229813664596 | hash colision 1.0 | hash colision mod 1024 1.0833333333333333
Wyhash avg hash compute 21.900621118012424 | hash colision 1.0 | hash colision mod 1024 1.0437956204379562
fnv1a32 avg hash compute 33.068322981366457 | hash colision 1.0 | hash colision mod 1024 1.0671641791044777
fnv1a64 avg hash compute 38.596273291925463 | hash colision 1.0 | hash colision mod 1024 1.0514705882352942
fxHash32 avg hash compute 18.993788819875775 | hash colision 1.0 | hash colision mod 1024 1.0751879699248121
fxHash64 avg hash compute 16.236024844720497 | hash colision 1.0 | hash colision mod 1024 1.1000000000000001
```
