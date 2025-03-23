# core_checker.py
import random
from soc_interface import SOCInterface

def test_arithmetic(soc):
    test_cases = [
        (0x1234, 0x5678),
        (0xFFFF, 0x0001),
        (0xDEAD, 0xBEEF)
    ]
    
    for a, b in test_cases:
        soc.write_memory(0x1000, a)
        soc.write_memory(0x1004, b)
        add_result = soc.read_memory(0x1000, 4)
        expected = (a + b) & 0xFFFFFFFF
        if int.from_bytes(add_result, 'little') != expected:
            return False
    return True

def run_full_test():
    soc = SOCInterface()
    
    tests = [
        ("Arithmetic Test", test_arithmetic),
        # Add more test functions
    ]
    
    for name, test in tests:
        print(f"Running {name}...", end="")
        if test(soc):
            print("PASSED")
        else:
            print("FAILED")
            return
    
    print("All core tests passed successfully!")

if __name__ == "__main__":
    run_full_test()
