# import time
# from sha import sha256_encode
# from testing import assert_equal
# from collections.vector import InlinedFixedVector

# fn print_hex(digest: InlinedFixedVector[UInt8, 32]):
#     var lookup = String("0123456789abcdef")
#     var result: String = ""
#     for i in range(len(digest)):
#         var v = digest[i].to_int()
#         result += lookup[(v >> 4)]
#         result += lookup[v & 15]
    
#     print(result)
#     print(len(digest))
#     print(len("b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"))
#     print(len("985752100505598575751521005110148569753501015350100551009755100979810297995256521011021015155975351564810110157485656102559799101501011029910010157"))

# fn main():
#     var bytes = 1024 * 1024 * 256 + 78
#     var bytes_to_hash: DynamicVector[UInt8] = kinda_random_bytes(bytes)
#     var ptr = DTypePointer[DType.uint8](bytes_to_hash.data.value)
#     var buffer = Buffer[DType.uint8](ptr, bytes_to_hash.size)
#     var before = time.now()
#     var hash = sha256_encode(ptr, bytes)
#     var after = time.now()
#     var keep_vector_alive = bytes_to_hash[4]
#     var ns = after - before
#     var seconds = ns / 1_000_000_000
#     var megabytes = bytes / 1_000_000
#     for i in range(hash.size):
#         print(hash[i])
#     print("megabytes per second")
#     print(megabytes / seconds)
#     var text = "hello world"
#     print(text)
#     print_hex(sha256_encode(text.data().bitcast[DType.uint8](), len(text)))


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