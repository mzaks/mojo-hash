
from math.bit import bit_length, bswap
from math.math import rotate_bits_right

alias U128 = SIMD[DType.uint64, 2]
alias U256 = SIMD[DType.uint64, 4]
alias default_secret = SIMD[DType.uint64, 4](0x2d358dccaa6c78a5, 0x8bb84b93962eacc9, 0x4b33a62ed433d4a3, 0x4d5a2da51de1aa47)

@always_inline
fn wymum_32(inout a: UInt64, inout b: UInt64):
    var ab = U128(a, b)
    var abl = ab & 0xff_ff_ff_ff
    var abh = ab >> 32
    var hh = abh.reduce_mul()
    var hl = abh[0] * abl[1]
    var ll = abl.reduce_mul()
    var lh = abl[0] * abh[1]
    a, b = rotate_bits_right[32](hl) ^ hh, rotate_bits_right[32](lh) ^ ll

@always_inline
fn wymum(inout a: UInt64, inout b: UInt64):
    var ab = U128(a, b)
    var abl = ab & 0xff_ff_ff_ff
    var abh = ab >> 32
    var hh = abh.reduce_mul()
    var hl = abh[0] * abl[1]
    var ll = abl.reduce_mul()
    var lh = abl[0] * abh[1]
    var t = ll + (hl << 32)
    var lo = t + (lh << 32)
    var c = (t < ll).cast[DType.uint64]()
    c += (lo < t).cast[DType.uint64]()
    var hi = hh + (hl >> 32) + (lh >> 32) + c
    a, b = lo, hi

@always_inline
fn wy_mix(_a: UInt64, _b: UInt64) -> UInt64:
    var a = _a
    var b = _b
    wymum(a, b)
    return a ^ b

@always_inline
fn wyr8(p: DTypePointer[DType.uint8]) -> UInt64:
    return p.bitcast[DType.uint64]().load()

@always_inline
fn wyr4(p: DTypePointer[DType.uint8]) -> UInt64:
    return p.bitcast[DType.uint32]().load().cast[DType.uint64]()

@always_inline
fn wyr3(p: DTypePointer[DType.uint8], k: Int) -> UInt64:
    return (p.load().cast[DType.uint64]() << 16) 
        | (p.offset(k >> 1).load().cast[DType.uint64]() << 8)
        | p.offset(k - 1).load().cast[DType.uint64]()

fn wyhash(key: String, _seed: UInt64, secret: U256 = default_secret) -> UInt64:
    var length = len(key)
    var p = key._as_ptr().bitcast[DType.uint8]()
    var seed = _seed ^wy_mix(_seed ^ secret[0], secret[1])
    var a: UInt64 = 0
    var b: UInt64 = 0
    if length <= 16:
        if length >= 4:
            var last_part_index = (length >> 3) << 2
            a = (wyr4(p) << 32) | wyr4(p.offset(last_part_index))
            b = (wyr4(p.offset(length - 4)) << 32) | wyr4(p.offset(length - 4 - last_part_index))
        elif length > 0:
            a = wyr3(p, length)
    else:
        var see1 = seed
        var see2 = seed

        while length > 48:
            var p64 = p.bitcast[DType.uint64]()
            var data1 = p64.load[width=4]()
            var data2 = p64.load[width=2]()
            var seed_values1 = U256(secret[1], seed, secret[2], see1)
            var seed_values2 = U128(secret[3], see2)
            var seeded_data1 = data1 ^ seed_values1
            var seeded_data2 = data2 ^ seed_values2
            seed = wy_mix(seed_values1[0], seed_values1[1])
            see1 = wy_mix(seed_values1[2], seed_values1[3])
            see2 = wy_mix(seed_values2[0], seed_values2[1])
            p = p.offset(48)
            length -= 48
        
        seed ^= see1 ^ see2

        while length > 16:
            var p64 = p.bitcast[DType.uint64]()
            var data = p64.load[width=2]()
            var seed_values = U128(secret[1], seed)
            var seeded_data = data ^ seed_values
            seed = wy_mix(seeded_data[0], seeded_data[1])
            p = p.offset(16)
            length -= 16
        a = wyr8(p.offset(length-16))
        b = wyr8(p.offset(length-8))

    a ^= secret[1]
    b ^= seed
    wymum(a, b)

    return wy_mix(a ^ secret[0] ^ len(key), b ^ secret[1])
