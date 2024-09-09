fn o1_hash(s: String) -> UInt64:
    var p = s.unsafe_ptr()
    var bytes = s.byte_length()
    if bytes >= 4:
        var first = p.bitcast[DType.uint32]()[0]
        var middle = p.offset((bytes >> 1) - 2).bitcast[DType.uint32]()[0]
        var last = p.offset(bytes - 4).bitcast[DType.uint32]()[0]
        return ((first + last) * middle).cast[DType.uint64]()
    if bytes:
        var tail = (p[0].cast[DType.uint64]() << 16) 
            | (p[bytes >> 1].cast[DType.uint64]() << 8)
            | p[bytes - 1].cast[DType.uint64]()
        return tail * 0xa0761d6478bd642
    return 0
