from math.math import rotate_bits_left

alias ROTATE = 5
alias SEED64 = 0x51_7c_c1_b7_27_22_0a_95
alias SEED32 = 0x9e_37_79_b9

@always_inline
fn fxhash32(s: StringLiteral, seed: UInt32 = 0) -> UInt32:
    var bytes = DTypePointer[DType.int8](s.data())
    var count = len(s)
    var hash = seed
    while count >= 4:
        hash = _hash_word32(hash, bytes.bitcast[DType.uint32]().load())
        bytes = bytes.offset(4)
        count -= 4
    if count >= 2:
        hash = _hash_word32(hash, bytes.bitcast[DType.uint16]().load().cast[DType.uint32]())
        bytes = bytes.offset(2)
        count -= 2
    if count > 0:
        hash = _hash_word32(hash, bytes.load().cast[DType.uint32]())
    return hash

@always_inline
fn fxhash64(s: StringLiteral, seed: UInt64 = 0) -> UInt64:
    var bytes = DTypePointer[DType.int8](s.data())
    var count = len(s)
    var hash = seed
    while count >= 8:
        hash = _hash_word64(hash, bytes.bitcast[DType.uint64]().load())
        bytes = bytes.offset(8)
        count -= 8
    if count >= 4:
        hash = _hash_word64(hash, bytes.bitcast[DType.uint32]().load().cast[DType.uint64]())
        bytes = bytes.offset(4)
        count -= 4
    if count >= 2:
        hash = _hash_word64(hash, bytes.bitcast[DType.uint16]().load().cast[DType.uint64]())
        bytes = bytes.offset(2)
        count -= 2
    if count > 0:
        hash = _hash_word64(hash, bytes.load().cast[DType.uint64]())
    return hash


@always_inline
fn _hash_word32(value: UInt32, word: UInt32) -> UInt32:
    return (rotate_bits_left[ROTATE](value) ^ word) * SEED32

@always_inline
fn _hash_word64(value: UInt64, word: UInt64) -> UInt64:
    return (rotate_bits_left[ROTATE](value) ^ word) * SEED64
