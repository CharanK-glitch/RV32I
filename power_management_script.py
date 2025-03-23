# program_fpga.py
import subprocess

def program_fpga(bitstream_file):
    """Program FPGA using Vivado"""
    tcl_script = f"""
open_hw
connect_hw_server
open_hw_target
current_hw_device [get_hw_devices xc7a100t_0]
set_property PROGRAM.FILE {{{bitstream_file}}} [current_hw_device]
program_hw_devices [current_hw_device]
"""

    with open("program.tcl", "w") as f:
        f.write(tcl_script)
    
    result = subprocess.run(["vivado", "-mode", "batch", "-source", "program.tcl"])
    return result.returncode == 0

if __name__ == "__main__":
    if program_fpga("riscv_soc.bit"):
        print("FPGA programmed successfully!")
    else:
        print("Programming failed!")
