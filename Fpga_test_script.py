import serial
import time

def test_leds():
    with serial.Serial('/dev/ttyUSB1', 115200) as uart:
        uart.write(b"LED TEST\n")
        response = uart.read(10)
        return b"OK" in response

def test_uart():
    with serial.Serial('/dev/ttyUSB1', 115200) as uart:
        uart.write(b"UART TEST\n")
        time.sleep(0.1)
        return uart.in_waiting > 0

if __name__ == "__main__":
    print("LED Test:", "PASS" if test_leds() else "FAIL")
    print("UART Test:", "PASS" if test_uart() else "FAIL")
