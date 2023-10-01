from math.bit import bit_length, bswap
from math.math import rotate_bits_right
from my_utils import vec

alias U128 = SIMD[DType.uint64, 2]
alias U256 = SIMD[DType.uint64, 4]
# alias default_secret = SIMD[DType.uint64, 4](0xa0761d6478bd642f, 0xe7037ed1a0b428db, 0x8ebc6af09c88c6e3, 0x589965cc75374cc3)

@always_inline
fn wymum(inout a: UInt64, inout b: UInt64):
    let ab = U128(a, b)
    let abl = ab & 0xff_ff_ff_ff
    let abh = ab >> 32
    let hh = abh.reduce_mul()
    let hl = abh[0] * abl[1]
    let ll = abl.reduce_mul()
    let lh = abl[0] * abh[1]
    a = rotate_bits_right[32](hl) ^ hh
    b = rotate_bits_right[32](lh) ^ ll

@always_inline
fn wy_mix(_a: UInt64, _b: UInt64) -> UInt64:
    var a = _a
    var b = _b
    wymum(a, b)
    return a ^ b

@always_inline
fn folded_multiply(s: UInt64, by: UInt64) -> UInt64:
    let b1 = s * bswap(by)
    let b2 = bswap(s) * (~by)
    return b1 ^ bswap(b2)

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

fn wyhash(key: StringLiteral, _seed: UInt64, secret: U256) -> UInt64:
    var length = len(key)
    var p = DTypePointer[DType.int8](key.data()).bitcast[DType.uint8]()
    var seed = _seed ^wy_mix(_seed ^ secret[0], secret[1])
    var a: UInt64 = 0
    var b: UInt64 = 0
    if length <= 16:
        if length >= 4:
            let last_part_index = (length >> 3) << 2
            a = (wyr4(p) << 32) | wyr4(p.offset(last_part_index))
            b = (wyr4(p.offset(length - 4)) << 32) | wyr4(p.offset(length - 4 - last_part_index))
        elif length > 0:
            a = wyr3(p, length)
    else:
        var see1 = seed
        var see2 = seed

        while length > 48:
            let p64 = p.bitcast[DType.uint64]()
            let data1 = p64.simd_load[4]()
            let data2 = p64.simd_load[2]()
            let seed_values1 = U256(secret[1], seed, secret[2], see1)
            let seed_values2 = U128(secret[3], see2)
            let seeded_data1 = data1 ^ seed_values1
            let seeded_data2 = data2 ^ seed_values2
            seed = wy_mix(seed_values1[0], seed_values1[1])
            see1 = wy_mix(seed_values1[2], seed_values1[3])
            see2 = wy_mix(seed_values2[0], seed_values2[1])
            p = p.offset(48)
            length -= 48
        
        seed ^= see1 ^ see2

        while length > 16:
            let p64 = p.bitcast[DType.uint64]()
            let data = p64.simd_load[2]()
            let seed_values = U128(secret[1], seed)
            let seeded_data = data ^ seed_values
            seed = wy_mix(seeded_data[0], seeded_data[1])
            p = p.offset(16)
            length -= 16
        a = wyr8(p.offset(length-16))
        b = wyr8(p.offset(length-8))

    a ^= secret[1]
    b ^= seed
    wymum(a, b)

    return wy_mix(a ^ secret[0] ^ len(key), b ^ secret[1])

fn main():
    print(wy_mix(0xff_ff_ff_ff_ff_ff_ff_ff, 10))
    print(folded_multiply(0xff_ff_ff_ff_ff_ff_ff_ff, 10))
    let default_secret = SIMD[DType.uint64, 4](0xa0761d6478bd642f, 0xe7037ed1a0b428db, 0x8ebc6af09c88c6e3, 0x589965cc75374cc3)
    print("hello", wyhash("hello", 42, default_secret))
    print("hello world", wyhash("hello world", 42, default_secret))
    print("hello2", wyhash("hello2", 42, default_secret))

    let msgs_v = vec(
        "",
        "a",
        "abc",
        "message digest",
        "abcdefghijklmnopqrstuvwxyz",
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
        "1234567890123456789012345678901234567890123456789012345678901234567890"
        "1234567890"
    )

    let etalons_v = vec[UInt64](
        0x42bc986dc5eec4d3,
        0x84508dc903c31551,
        0x0bc54887cfc9ecb1,
        0x6e2ff3298208a67c,
        0x9a64e42e897195b9,
        0x9199383239c32554,
        0x7c1ccf6bba30f5a5
    )

    for i in range(len(msgs_v)):
        let hash = wyhash(msgs_v[i], i, default_secret)
        print(etalons_v[i], hash, hash == etalons_v[i])
