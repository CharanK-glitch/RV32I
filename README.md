### RISC-V RV32I(single - Core) Architecture and Implementation

1. Overview

The RV32I (RISC-V 32-bit Integer) architecture is a reduced instruction set computing (RISC) design that provides a minimal yet efficient foundation for processor development. It follows a load-store architecture, ensuring simple and predictable execution.

2. Architecture & Pipelining

RV32I follows a five-stage pipeline:
	1.	Instruction Fetch (IF) – Retrieves instruction from memory.
	2.	Instruction Decode (ID) – Decodes the opcode and operands.
	3.	Execute (EX) – Performs ALU operations.
	4.	Memory Access (MEM) – Reads/writes from/to memory.
	5.	Write-back (WB) – Stores results into registers.

This pipelined execution enhances parallelism but introduces hazards, which require handling through stalling, forwarding, and prediction mechanisms.

3. Instruction Set & Extensions

The base RV32I set includes arithmetic, logical, branch, load/store, and control instructions. It can be extended with:
	•	M (Multiplication/Division)
	•	A (Atomic operations)
	•	F/D (Floating-point)
	•	C (Compressed instructions for reduced memory footprint)
	•	Zicsr & Zifencei (Control and memory ordering)

4. Privileged & Unprivileged Modes

	•	Machine Mode (M-mode): Highest privilege level, directly controls system resources.
	•	User Mode (U-mode): Executes application code with restricted access.
	•	Supervisor Mode (S-mode) (optional): Handles OS-level management.

Privilege levels are managed via Control and Status Registers (CSRs).

5. Data Paths & Hazard Handling

The datapath includes register files, ALU, control unit, memory access unit, and pipeline registers. Key challenges include:
	•	Data Hazards: Managed via forwarding or stalls.
	•	Control Hazards: Mitigated through branch prediction and pipeline flushing.
	•	Structural Hazards: Minimized by separating instruction and data memory or using multi-port registers.

6. FreeRTOS Implementation

The architecture can be extended to run FreeRTOS, enabling real-time scheduling, task management, and interrupt handling. This requires integrating timer interrupts, system calls, and context switching in the RISC-V privilege model.

7. Future Enhancements

	•	Advanced Branch Prediction: Implementing perceptron-based dynamic prediction for reduced stalls.
	•	Cache & Memory Hierarchy Optimization: Exploring L1/L2 caching for efficient memory access.
	•	Multicore Support: Extending to RV64GC with multi-core synchronization.

This repository serves as a foundation for understanding and developing RISC-V-based embedded and OS-level implementations.


![risc_architecture](https://github.com/user-attachments/assets/f0b33f83-b1b2-42e5-95cd-d2f98ebea5d6)


# RV32I Core and SoC Integration

## 1. Overview
This document provides guidelines for integrating peripherals with the **RV32I** core in a custom **SoC**, taking inspiration from the **Sapphire SoC** of the RISC-V open platform.

## 2. System-on-Chip (SoC) Architecture

### 2.1 Core Components
- **RV32I Core**: Custom implementation of the RISC-V 32-bit integer core.
- **Memory Subsystem**:
  - Instruction Memory (IMEM)
  - Data Memory (DMEM)
  - External RAM (if required)
- **Bus Interconnect**: AXI/AHB/APB or a custom interconnect for core-peripheral communication.
- **Peripherals**:
  - UART (for serial communication)
  - SPI (for external memory/flash)
  - I2C (for sensor interfaces)
  - GPIO (for basic control and signaling)
  - Timer (for system timekeeping and scheduling)
- **Interrupt Controller**: Handles external and internal interrupts efficiently.
- **Boot ROM**: Contains bootloader and initial setup code.

## 3. Integration Steps

### 3.1 Connecting the Core to the Interconnect
1. Define a **bus interface** (AXI-Lite, AHB, or Wishbone) in Verilog for communication.
2. Connect the RV32I core to the bus:
   - **Instruction Fetch**: IMEM interface
   - **Data Memory Access**: DMEM interface
   - **Peripheral Access**: Mapped to specific address ranges
3. Ensure proper **clocking and reset** mechanisms for synchronization.

### 3.2 Memory Integration
- Define memory-mapped regions for IMEM and DMEM.
- Optionally include external memory with an AXI/AHB interface.
- Implement an MMU (Memory Management Unit) if virtual memory is needed.

### 3.3 Peripheral Address Mapping
Allocate specific address ranges for each peripheral:
| Peripheral | Base Address | Size |
|------------|-------------|------|
| UART       | 0x10000000  | 4KB  |
| SPI        | 0x10001000  | 4KB  |
| I2C        | 0x10002000  | 4KB  |
| GPIO       | 0x10003000  | 4KB  |
| Timer      | 0x10004000  | 4KB  |

### 3.4 Interrupt Controller
1. Implement a simple **PLIC (Platform-Level Interrupt Controller)**.
2. Map peripheral interrupts to the core’s interrupt request lines.
3. Define **Interrupt Service Routines (ISRs)** in the firmware.

### 3.5 Bootloader and Firmware
- Implement a **bootloader in ROM** to initialize the system.
- Load the firmware from SPI Flash or external memory.
- Write a minimal **C-based firmware** to verify core and peripheral functionality.

## 4. Verilog Modules
### 4.1 Core Interface (Example)
```verilog
module rv32i_core (
    input wire clk,
    input wire reset,
    input wire [31:0] instr_in,
    output wire [31:0] pc_out,
    input wire [31:0] data_in,
    output wire [31:0] data_out,
    output wire mem_read,
    output wire mem_write
);
    // Core logic
endmodule
```

### 4.2 UART Example
```verilog
module uart (
    input wire clk,
    input wire reset,
    input wire rx,
    output wire tx,
    input wire [7:0] data_in,
    output wire [7:0] data_out
);
    // UART logic
endmodule
```

## 5. Testing and Debugging
- **Simulation**: Use **Verilator or ModelSim** for core and peripheral testing.
- **FPGA Implementation**: Map the SoC onto an **Artix-7 or Genesys-2** board.
- **Software Debugging**: Use **OpenOCD + GDB** for firmware debugging.
- **Benchmarking**: Run basic **Dhrystone and CoreMark tests**.

## 6. Future Enhancements
- Implement **RV32IM or RV32GC** extensions.
- Optimize **bus arbitration** for better performance.
- Integrate a **custom accelerator (e.g., ML inference, DSP unit)**.
- Port **FreeRTOS** to the SoC for multitasking.

---
This document is a foundation for **RV32I-based SoC** development and can be extended for more advanced RISC-V architectures.


![Screenshot 2025-03-23 213107](https://github.com/user-attachments/assets/dcb62823-83fc-4c10-a7c2-81a6a9b2b6a2)



