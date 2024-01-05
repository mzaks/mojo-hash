import hashlib
import time

if __name__ == "__main__":
    file = open("/usr/share/dict/words", "r")
    content = file.read()
    tik = time.time_ns()
    result = hashlib.md5(content.encode())
    tok = time.time_ns()
    print(result.hexdigest())
    print(f"In: {tok - tik}")