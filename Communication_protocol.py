# soc_interface.py
import serial
import time

class SOCInterface:
    def __init__(self, port='/dev/ttyUSB0', baudrate=115200):
        self.uart = serial.Serial(
            port=port,
            baudrate=baudrate,
            bytesize=8,
            parity='N',
            stopbits=1,
            timeout=1
        )
        
    def read_memory(self, address, size=4):
        cmd = f"READ {address:08x}\n".encode()
        self.uart.write(cmd)
        return self.uart.read(size)
    
    def write_memory(self, address, data):
        cmd = f"WRITE {address:08x} {data:08x}\n".encode()
        self.uart.write(cmd)
        return self.uart.read(1) == b'1'
    
    def run_test_program(self):
        self.uart.write(b"RUN\n")
        result = self.uart.read(4)
        return int.from_bytes(result, 'little') == 0xDEADBEEF
    
    def set_gpio(self, value):
        self.write_memory(0x20000004, value)
    
    def get_gpio(self):
        return self.read_memory(0x20000004)

if __name__ == "__main__":
    soc = SOCInterface()
    
    # Test GPIO
    soc.set_gpio(0xAA)
    print("GPIO Output:", soc.get_gpio().hex())
    
    # Run self-test
    if soc.run_test_program():
        print("Self-test passed!")
    else:
        print("Self-test failed!")
