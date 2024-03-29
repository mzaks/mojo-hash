import hashlib
import time

if __name__ == "__main__":
    file = open("/usr/share/dict/words", "r")
    content = file.read().encode()
    tik = time.time_ns()
    result = hashlib.md5(content)
    tok = time.time_ns()
    print(result.hexdigest())
    print(f"In: {tok - tik}")

    tik = time.time_ns()
    result = hashlib.sha256(content)
    tok = time.time_ns()
    print(result.hexdigest())
    print(f"In: {tok - tik}")

