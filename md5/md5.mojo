# Based on https://github.com/Zunawe/md5-c

from algorithm.functional import unroll
from memory.unsafe import bitcast
from memory import memset_zero
from math import rotate_bits_left

alias S = SIMD[DType.uint32, 64](
    7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
    5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20,
    4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
    6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21
)

alias K = SIMD[DType.uint32, 64](
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
    0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
    0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
    0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
    0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
    0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
    0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
    0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
    0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
    0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
    0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
    0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
)

alias PADDING = create_padding()

fn create_padding() -> DTypePointer[DType.uint8]:
    let result = DTypePointer[DType.uint8].alloc(64)
    result.store(0, 0x80)
    for i in range(1, 64):
        result.store(i, 0)
    return result

struct Md5Context:
    var buffer: SIMD[DType.uint32, 4]
    var input: SIMD[DType.uint8, 64]
    var digest: SIMD[DType.uint8, 16]
    var size: UInt64

    fn __init__(inout self):
        self.size = 0
        self.buffer = SIMD[DType.uint32, 4](0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476)
        self.input = SIMD[DType.uint8, 64]()
        self.digest = SIMD[DType.uint8, 16]()

    @always_inline
    fn update(inout self, input_buffer: DTypePointer[DType.uint8], length: Int):
        var offset = (self.size & 63).to_int()
        var input = SIMD[DType.uint32, 16]()
        self.size += length

        for i in range(length):
            self.input[offset] = input_buffer.offset(i).load()
            offset += 1
            if offset & 63 == 0:
                # TODO: check if it works on BigEndian arch (or needs bswap?)
                input = bitcast[DType.uint32, 16](self.input)
                self.step(input)
                offset = 0
    
    @always_inline
    fn finalize(owned self) -> SIMD[DType.uint8, 16]:
        var input = SIMD[DType.uint32, 16]()
        let offset = (self.size & 63).to_int()
        let padding_length = 56 - offset if offset < 56 else 56 + 64 - offset

        self.update(PADDING, padding_length)
        self.size -= padding_length
        input = bitcast[DType.uint32, 16](self.input)
        input[14] = (self.size * 8).cast[DType.uint32]()
        input[15] = ((self.size * 8) >> 32).cast[DType.uint32]()
        self.step(input)
        return bitcast[DType.uint8, 16](self.buffer)

    @always_inline
    fn step(inout self, input: SIMD[DType.uint32, 16]):
        var aa = self.buffer[0]
        var bb = self.buffer[1]
        var cc = self.buffer[2]
        var dd = self.buffer[3]

        var e: UInt32 = 0
        var j = 0

        @parameter
        fn shuffle[i: Int]():
            alias step = i >> 4
            @parameter
            if step == 0:
                e = (bb & cc) | (~bb & dd)
                j = i
            elif step == 1:
                e = (bb & dd) | (cc & ~dd)
                j = (i * 5 + 1) & 15
            elif step == 2:
                e = bb ^ cc ^ dd
                j = (i * 3 + 5) & 15
            else:
                e = cc ^ (bb | ~dd)
                j = (i * 7) & 15
            aa, bb, cc, dd = dd, bb + rotate_bits_left[S[i].to_int()](aa + e + K[i] + input[j]), bb, cc
        
        unroll[64, shuffle]()

        self.buffer += SIMD[DType.uint32, 4](aa, bb, cc, dd)

@always_inline
fn md5_string(value: String) -> SIMD[DType.uint8, 16]:
    var ctx = Md5Context()
    ctx.update(value._as_ptr().bitcast[DType.uint8](), len(value))
    return ctx^.finalize()
