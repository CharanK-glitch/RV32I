import subprocess

def run_test():
    result = subprocess.run(
        ["make", "verify"],
        capture_output=True,
        text=True
    )
    return "Test Passed" in result.stdout

if __name__ == "__main__":
    if run_test():
        print("✅ Core verification successful!")
        exit(0)
    else:
        print("❌ Core verification failed!")
        exit(1)
