# from memory import memcpy
# from collections.vector import InlinedFixedVector
# import time


# fn main():
# 	var bytes = 1024 * 1024 * 256 + 78
# 	var bytes_to_hash: List[UInt8] = kinda_random_bytes(bytes)
# 	var ptr = bytes_to_hash.unsafe_ptr()
# 	var buffer = Buffer[DType.uint8](ptr, bytes_to_hash.size)
# 	var before = time.now()
# 	var hash = sha256(buffer)
# 	var after = time.now()
# 	var keep_vector_alive = bytes_to_hash[4]
# 	var ns = after - before
# 	var seconds = ns / 1_000_000_000
# 	var megabytes = bytes / 1_000_000
# 	for i in range(hash.size):
# 		print(hash[i])
# 	print("megabytes per second")
# 	print(megabytes / seconds)


# fn kinda_random_bytes(length: Int) -> DynamicVector[UInt8]:
# 	var vec = DynamicVector[UInt8](capacity=length)
# 	var n: UInt8 = 245
# 	var cycle: UInt8 = 1
# 	for i in range(length):
# 		var shifted = n >> 3
# 		var shiftalso = n << 4
# 		var more = shifted ^ n ^ shiftalso
# 		var next = n + more
# 		n = next
# 		cycle ^= n
# 		vec.append(n + cycle)

# 	return vec


# @always_inline
# fn big_endian_bytes_to_dword(
# 	first: UInt8, second: UInt8, third: UInt8, fourth: UInt8
# ) -> UInt32:
# 	var a = first.cast[DType.uint32]() << 24
# 	var b = second.cast[DType.uint32]() << 16
# 	var c = third.cast[DType.uint32]() << 8
# 	var d = fourth.cast[DType.uint32]() << 0
# 	return a | b | c | d


# @always_inline
# fn big_endian_dword_to_bytes(word: UInt32) -> InlinedFixedVector[UInt8, 4]:
# 	var v = InlinedFixedVector[UInt8, 4](4)
# 	var a = (word >> 24) & 255
# 	var b = (word >> 16) & 255
# 	var c = (word >> 8) & 255
# 	var d = word & 255
# 	v.append(a.cast[DType.uint8]())
# 	v.append(b.cast[DType.uint8]())
# 	v.append(c.cast[DType.uint8]())
# 	v.append(d.cast[DType.uint8]())
# 	return v


# @always_inline
# fn big_endian_qword_to_bytes(word: UInt64) -> InlinedFixedVector[UInt8, 8]:
# 	var v = InlinedFixedVector[UInt8, 8](8)
# 	var a = (word >> 56) & 255
# 	var b = (word >> 48) & 255
# 	var c = (word >> 40) & 255
# 	var d = (word >> 32) & 255
# 	var e = (word >> 24) & 255
# 	var f = (word >> 16) & 255
# 	var g = (word >> 8) & 255
# 	var h = word & 255
# 	v.append(a.cast[DType.uint8]())
# 	v.append(b.cast[DType.uint8]())
# 	v.append(c.cast[DType.uint8]())
# 	v.append(d.cast[DType.uint8]())
# 	v.append(e.cast[DType.uint8]())
# 	v.append(f.cast[DType.uint8]())
# 	v.append(g.cast[DType.uint8]())
# 	v.append(h.cast[DType.uint8]())
# 	return v


# # bit rotate right
# @always_inline
# fn bitrr(integer: UInt32, rotations: UInt32) -> UInt32:
# 	return (integer >> rotations) | (integer << (32 - rotations))


# # for reference see https://en.wikipedia.org/wiki/SHA-2#Pseudocode
# # right now it internally copies the byte_view into a dynamic vector and works on that
# # this is slow, but i don't have the mojo mojo to chunk it out for zero-copy
# fn sha256(byte_view: Buffer[_, DType.uint8, 0]) -> InlinedFixedVector[UInt8, 32]:
# 	var k = InlinedFixedVector[UInt32, 64](64)
# 	k.append(0x428A2F98)
# 	k.append(0x71374491)
# 	k.append(0xB5C0FBCF)
# 	k.append(0xE9B5DBA5)
# 	k.append(0x3956C25B)
# 	k.append(0x59F111F1)
# 	k.append(0x923F82A4)
# 	k.append(0xAB1C5ED5)
# 	k.append(0xD807AA98)
# 	k.append(0x12835B01)
# 	k.append(0x243185BE)
# 	k.append(0x550C7DC3)
# 	k.append(0x72BE5D74)
# 	k.append(0x80DEB1FE)
# 	k.append(0x9BDC06A7)
# 	k.append(0xC19BF174)
# 	k.append(0xE49B69C1)
# 	k.append(0xEFBE4786)
# 	k.append(0x0FC19DC6)
# 	k.append(0x240CA1CC)
# 	k.append(0x2DE92C6F)
# 	k.append(0x4A7484AA)
# 	k.append(0x5CB0A9DC)
# 	k.append(0x76F988DA)
# 	k.append(0x983E5152)
# 	k.append(0xA831C66D)
# 	k.append(0xB00327C8)
# 	k.append(0xBF597FC7)
# 	k.append(0xC6E00BF3)
# 	k.append(0xD5A79147)
# 	k.append(0x06CA6351)
# 	k.append(0x14292967)
# 	k.append(0x27B70A85)
# 	k.append(0x2E1B2138)
# 	k.append(0x4D2C6DFC)
# 	k.append(0x53380D13)
# 	k.append(0x650A7354)
# 	k.append(0x766A0ABB)
# 	k.append(0x81C2C92E)
# 	k.append(0x92722C85)
# 	k.append(0xA2BFE8A1)
# 	k.append(0xA81A664B)
# 	k.append(0xC24B8B70)
# 	k.append(0xC76C51A3)
# 	k.append(0xD192E819)
# 	k.append(0xD6990624)
# 	k.append(0xF40E3585)
# 	k.append(0x106AA070)
# 	k.append(0x19A4C116)
# 	k.append(0x1E376C08)
# 	k.append(0x2748774C)
# 	k.append(0x34B0BCB5)
# 	k.append(0x391C0CB3)
# 	k.append(0x4ED8AA4A)
# 	k.append(0x5B9CCA4F)
# 	k.append(0x682E6FF3)
# 	k.append(0x748F82EE)
# 	k.append(0x78A5636F)
# 	k.append(0x84C87814)
# 	k.append(0x8CC70208)
# 	k.append(0x90BEFFFA)
# 	k.append(0xA4506CEB)
# 	k.append(0xBEF9A3F7)
# 	k.append(0xC67178F2)

# 	var h0: UInt32 = 0x6A09E667
# 	var h1: UInt32 = 0xBB67AE85
# 	var h2: UInt32 = 0x3C6EF372
# 	var h3: UInt32 = 0xA54FF53A
# 	var h4: UInt32 = 0x510E527F
# 	var h5: UInt32 = 0x9B05688C
# 	var h6: UInt32 = 0x1F83D9AB
# 	var h7: UInt32 = 0x5BE0CD19

# 	var one_bit: UInt8 = 0b1000_0000

# 	var exact_chunks = byte_view.dynamic_size // 64
# 	var remainder_start = exact_chunks * 64
# 	var remainder_length = byte_view.dynamic_size % 64
# 	var bare_min_extra_bytes = remainder_length + 9
# 	var extra_space = InlinedFixedVector[UInt8,128](128)
# 	for i in range(remainder_length):
# 		extra_space.append(byte_view[remainder_start + i])

# 	extra_space.append(one_bit)
# 	var only_one_chunk_needed = bare_min_extra_bytes <= 64
# 	var tail_bytes = big_endian_qword_to_bytes(byte_view.dynamic_size * 8)
# 	if only_one_chunk_needed:
# 		while 8+extra_space.current_size < 64:
# 			extra_space.append(0)
# 	else:
# 		while 8+extra_space.current_size < 128:
# 			extra_space.append(0)
	
# 	for i in range(8):
# 		extra_space.append(tail_bytes[i])


# 	var w = InlinedFixedVector[UInt32, 64](64)
# 		# 	(The initial values in w[0..63] don't matter, so many implementations zero them here)
# 	for i in range(64):
# 		w.append(0)


# 	# loop through the full sets of 64 from the byte view
# 	# later, a little code duplication to repeat on the extra space
# 	for chunk_number in range(exact_chunks):
# 		# 	create a 64-entry message schedule array w[0..63] of 32-bit words
		
# 		# 	copy chunk into first 16 words w[0..15] of the message schedule array
# 		@unroll
# 		for dword_i in range(16):
# 			var start_byte_within_chunk = dword_i * 4
# 			var start_byte_overall = start_byte_within_chunk + (64 * chunk_number)
# 			var i = start_byte_overall
# 			var dword = big_endian_bytes_to_dword(
# 				byte_view[i],
# 				byte_view[i + 1],
# 				byte_view[i + 2],
# 				byte_view[i + 3],
# 			)
# 			w[dword_i] = dword

# 		# Extend the first 16 words into the remaining 48 words w[16..63] of the message schedule array:
# 		@unroll
# 		for i in range(16, 64):
# 			# s0 := (w[i-15] rightrotate  7) xor (w[i-15] rightrotate 18) xor (w[i-15] rightshift  3)
# 			var s0 = bitrr(w[i - 15], 7) ^ bitrr(w[i - 15], 18) ^ (w[i - 15] >> 3)
# 			# s1 := (w[i-2] rightrotate 17) xor (w[i-2] rightrotate 19) xor (w[i-2] rightshift 10)
# 			var s1 = bitrr(w[i - 2], 17) ^ bitrr(w[i - 2], 19) ^ (w[i - 2] >> 10)
# 			# w[i] := w[i-16] + s0 + w[i-7] + s1
# 			w[i] = w[i - 16] + s0 + w[i - 7] + s1

# 		var a = h0
# 		var b = h1
# 		var c = h2
# 		var d = h3
# 		var e = h4
# 		var f = h5
# 		var g = h6
# 		var h = h7

# 		@unroll
# 		for i in range(64):
# 			# S1 := (e rightrotate 6) xor (e rightrotate 11) xor (e rightrotate 25)
# 			var S1 = bitrr(e, 6) ^ bitrr(e, 11) ^ bitrr(e, 25)
# 			# ch := (e and f) xor ((not e) and g)
# 			var ch = (e & f) ^ ((e ^ (0-1)) & g)
# 			# temp1 := h + S1 + ch + k[i] + w[i]
# 			var temp1 = h + S1 + ch + k[i] + w[i]
# 			# S0 := (a rightrotate 2) xor (a rightrotate 13) xor (a rightrotate 22)
# 			var S0 = bitrr(a, 2) ^ bitrr(a, 13) ^ bitrr(a, 22)
# 			# maj := (a and b) xor (a and c) xor (b and c)
# 			var maj = (a & b) ^ (a & c) ^ (b & c)
# 			# temp2 := S0 + maj
# 			var temp2 = S0 + maj

# 			h = g
# 			g = f
# 			f = e
# 			e = d + temp1
# 			d = c
# 			c = b
# 			b = a
# 			a = temp1 + temp2

# 		h0 = h0 + a
# 		h1 = h1 + b
# 		h2 = h2 + c
# 		h3 = h3 + d
# 		h4 = h4 + e
# 		h5 = h5 + f
# 		h6 = h6 + g
# 		h7 = h7 + h

# 	#continue through the extra space
# 	var extra_chunks = extra_space.current_size // 64
# 	for chunk_number in range(extra_chunks):
# 		# 	create a 64-entry message schedule array w[0..63] of 32-bit words
		
# 		# 	copy chunk into first 16 words w[0..15] of the message schedule array
# 		@unroll
# 		for dword_i in range(16):
# 			var start_byte_within_chunk = dword_i * 4
# 			var start_byte_overall = start_byte_within_chunk + (64 * chunk_number)
# 			var i = start_byte_overall
# 			var dword = big_endian_bytes_to_dword(
# 				extra_space[i],
# 				extra_space[i + 1],
# 				extra_space[i + 2],
# 				extra_space[i + 3],
# 			)
# 			w[dword_i] = dword

# 		# Extend the first 16 words into the remaining 48 words w[16..63] of the message schedule array:
# 		@unroll
# 		for i in range(16, 64):
# 			# s0 := (w[i-15] rightrotate  7) xor (w[i-15] rightrotate 18) xor (w[i-15] rightshift  3)
# 			var s0 = bitrr(w[i - 15], 7) ^ bitrr(w[i - 15], 18) ^ (w[i - 15] >> 3)
# 			# s1 := (w[i-2] rightrotate 17) xor (w[i-2] rightrotate 19) xor (w[i-2] rightshift 10)
# 			var s1 = bitrr(w[i - 2], 17) ^ bitrr(w[i - 2], 19) ^ (w[i - 2] >> 10)
# 			# w[i] := w[i-16] + s0 + w[i-7] + s1
# 			w[i] = w[i - 16] + s0 + w[i - 7] + s1

# 		var a = h0
# 		var b = h1
# 		var c = h2
# 		var d = h3
# 		var e = h4
# 		var f = h5
# 		var g = h6
# 		var h = h7

# 		@unroll
# 		for i in range(64):
# 			# S1 := (e rightrotate 6) xor (e rightrotate 11) xor (e rightrotate 25)
# 			var S1 = bitrr(e, 6) ^ bitrr(e, 11) ^ bitrr(e, 25)
# 			# ch := (e and f) xor ((not e) and g)
# 			var ch = (e & f) ^ ((e ^ (0-1)) & g)
# 			# temp1 := h + S1 + ch + k[i] + w[i]
# 			var temp1 = h + S1 + ch + k[i] + w[i]
# 			# S0 := (a rightrotate 2) xor (a rightrotate 13) xor (a rightrotate 22)
# 			var S0 = bitrr(a, 2) ^ bitrr(a, 13) ^ bitrr(a, 22)
# 			# maj := (a and b) xor (a and c) xor (b and c)
# 			var maj = (a & b) ^ (a & c) ^ (b & c)
# 			# temp2 := S0 + maj
# 			var temp2 = S0 + maj

# 			h = g
# 			g = f
# 			f = e
# 			e = d + temp1
# 			d = c
# 			c = b
# 			b = a
# 			a = temp1 + temp2

# 		h0 = h0 + a
# 		h1 = h1 + b
# 		h2 = h2 + c
# 		h3 = h3 + d
# 		h4 = h4 + e
# 		h5 = h5 + f
# 		h6 = h6 + g
# 		h7 = h7 + h



# 	var output = InlinedFixedVector[UInt8, 32](32)

# 	var digest_part_h0 = big_endian_dword_to_bytes(h0)
# 	for i in range(4):
# 		output.append(digest_part_h0[i])
# 	var digest_part_h1 = big_endian_dword_to_bytes(h1)
# 	for i in range(4):
# 		output.append(digest_part_h1[i])
# 	var digest_part_h2 = big_endian_dword_to_bytes(h2)
# 	for i in range(4):
# 		output.append(digest_part_h2[i])
# 	var digest_part_h3 = big_endian_dword_to_bytes(h3)
# 	for i in range(4):
# 		output.append(digest_part_h3[i])
# 	var digest_part_h4 = big_endian_dword_to_bytes(h4)
# 	for i in range(4):
# 		output.append(digest_part_h4[i])
# 	var digest_part_h5 = big_endian_dword_to_bytes(h5)
# 	for i in range(4):
# 		output.append(digest_part_h5[i])
# 	var digest_part_h6 = big_endian_dword_to_bytes(h6)
# 	for i in range(4):
# 		output.append(digest_part_h6[i])
# 	var digest_part_h7 = big_endian_dword_to_bytes(h7)
# 	for i in range(4):
# 		output.append(digest_part_h7[i])

# 	return output
