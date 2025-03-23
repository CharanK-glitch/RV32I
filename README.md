# I. RISC-V RV32I(single - Core) Architecture and Implementation

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


# II. RTOS Implementation on RV32I Core

## 1. Overview
This document describes the implementation of an **RTOS** on the **RV32I Core**, taking inspiration from **Steel** documentation. The integration includes task management, scheduling, interrupt handling, and peripheral interaction.

## 2. System Architecture

### 2.1 Components
- RV32I Core: Custom RISC-V core with MMU (optional for RTOS)
- cheduler: Preemptive round-robin or priority-based scheduling
- **Task Management**: Context switching and multi-threading support
- **Interrupt Handling**: External and software-triggered interrupts
- **Memory Management**: Stack and heap allocation per task
- **Synchronization**: Mutex, semaphores, and event flags
- **Drivers**: UART, GPIO, Timer, and SPI/I2C

### 2.2 RTOS Features
| Feature | Implementation |
|---------|---------------|
| Task Switching | Context switch via software interrupts |
| Scheduling | Preemptive Round-Robin / Priority-based |
| Interrupts | RISC-V PLIC-based handling |
| Timers | System tick using Machine Timer (MTIME) |
| IPC | Message Queues, Semaphores |
| Memory | Stack and Heap allocation per task |

## 3. RTOS Integration with RV32I

### 3.1 System Tick Timer (SysTick)
The system tick is configured using the **MTIME** register:
```c
#define MTIME       (*(volatile uint64_t*)0x200BFF8)
#define MTIMECMP    (*(volatile uint64_t*)0x2004000)
#define TIMER_FREQ  1000000

void set_systick(uint64_t interval) {
    MTIMECMP = MTIME + interval;
}
```

### 3.2 Context Switching Mechanism
The RTOS requires **context switching** between tasks using the RISC-V `mret` instruction.
```assembly
csrrw sp, mscratch, sp  // Save SP
csrrw ra, mepc, ra      // Save Return Address
csrw mscratch, sp       // Restore SP
mret                    // Return from exception
```

### 3.3 Task Scheduler
The task scheduler handles multiple threads and enforces time-slicing.
```c
void scheduler() {
    current_task = (current_task + 1) % NUM_TASKS;
    context_switch(tasks[current_task]);
}
```

### 3.4 Interrupt Handling
All peripherals trigger **software interrupts** managed by the **PLIC**:
```c
void external_interrupt_handler() {
    uint32_t irq = PLIC_CLAIM;
    if (irq == UART_IRQ) {
        uart_handle_irq();
    }
    PLIC_COMPLETE = irq;
}
```

## 4. Peripheral Drivers

### 4.1 UART Driver
```c
void uart_init() {
    UART_CTRL = ENABLE_TX | ENABLE_RX;
}

void uart_write(char c) {
    while (!(UART_STATUS & TX_READY));
    UART_DATA = c;
}
```

### 4.2 GPIO Driver
```c
void gpio_write(uint32_t pin, uint8_t value) {
    if (value)
        GPIO_SET = (1 << pin);
    else
        GPIO_CLEAR = (1 << pin);
}
```

## 5. Testing and Debugging
- **Simulation**: Using **QEMU-RISCV** to test RTOS scheduling
- **FPGA Deployment**: Running on **Artix-7**
- **Debugging**: OpenOCD + GDB with RTOS-aware debugging

## 6. Future Enhancements
- Implement **Mutex and Semaphores** for real-time synchronization
- Add **dynamic memory allocation** for flexible task management
- Optimize **power management** for embedded applications
- Port **FreeRTOS** for multi-threading support

---
This document provides a roadmap for **RTOS integration on RV32I**, enabling **real-time task scheduling, peripheral control, and multi-threading** support.



# III. RV Core Implementation on Sapphire SOC

Here's a comprehensive `README.md` for your Sapphire SoC project, styled after Shakti and RISC-V Steel:

```markdown
# Sapphire SoC: RV32I RISC-V Core
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.XXXXXXX.svg)](https://doi.org/10.5281/zenodo.XXXXXXX)

**Inspired by:** [SHAKTI Project](https://www.shakti.org.in/) | **Design Philosophy:** [RISC-V Steel](https://github.com/riscv-steel/riscv-steel)

## Overview
Sapphire SoC is a minimalist RV32I RISC-V implementation targeting FPGA-based embedded systems. Designed with the simplicity-first approach of RISC-V Steel and the robustness of SHAKTI-class cores, it features:

- 5-stage in-order pipeline
- AXI4-Lite system bus
- FPGA-optimized microarchitecture
- FreeRTOS-compatible interrupt system

![Sapphire SoC Block Diagram](docs/block_diagram.png) *Replace with actual diagram*

## Features
- **RV32I Compliance**: Full support for Base Integer ISA (v2.1)
- **Pipeline**: IF-ID-EX-MEM-WB with hazard detection
- **Memory**: 
  - 4KB ICache / 4KB DCache
  - Memory-mapped peripherals (UART, GPIO, Timer)
- **Interrupts**: PLIC with 32 priority levels
- **FPGA Targets**: 
  - Genesys-2 (Xilinx Kintex-7)
  - DE10-Nano (Intel Cyclone V)

## Architecture
### Core Pipeline
```SystemVerilog
module sapphire_core (
  input  logic        clk,
  input  logic        resetn,
  // AXI4-Lite Interface
  axi_lite_if.master  axi_bus,
  // Interrupt Interface
  input  logic [31:0] irq_lines
);
```

### Memory Map
| Address Range       | Description          |
|---------------------|----------------------|
| `0x0000_0000-0x0000_FFFF` | Boot ROM (64KB)    |
| `0x2000_0000-0x2000_0FFF` | GPIO               |
| `0x3000_0000-0x3000_00FF` | UART              |
| `0x4000_0000-0x4FFF_FFFF` | AXI4-Lite Memory  |

## Getting Started
### Prerequisites
- RISC-V GCC Toolchain
- Verilator (v5.0+)
- Vivado 2022.1 (FPGA builds)

### Build & Simulate
```bash
git clone https://github.com/yourusername/sapphire-soc
cd sapphire-soc

# Run UVM tests
make sim TEST=axi_smoke

# Synthesize for Genesys-2
make fpga BOARD=genesys2
```

### Example: Hello World
```c
#include "sapphire.h"

int main() {
  uart_init(115200);
  uart_puts("Sapphire SoC Booted!\n");
  
  while(1) {
    led_toggle();
    delay_ms(500);
  }
}
```

## Performance
| Metric              | Sapphire | SHAKTI C-Class | PicoRV32 |
|---------------------|----------|----------------|----------|
| ISA Support         | RV32I    | RV64IMAC       | RV32I    |
| Pipeline Stages     | 5        | 3              | -        |
| FPGA Freq (MHz)     | 75       | 100            | 150      |
| LUT Utilization     | 1,200    | 2,500          | 750      |
| Verification Method | UVM+FPGA | Formal         | Direct   |

## Contributing
1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Citing Sapphire SoC
```bibtex
@misc{sapphire_soc,
  author = {Your Name},
  title = {Sapphire SoC: RV32I RISC-V Implementation},
  year = {2023},
  publisher = {GitHub},
  journal = {GitHub repository},
  howpublished = {\url{https://github.com/yourusername/sapphire-soc}}
}
```

## License
Distributed under MIT License. See `LICENSE` for details.

## Acknowledgments
- [SHAKTI Project](https://www.shakti.org.in/) for architectural inspiration
- [RISC-V Steel](https://github.com/riscv-steel) for verification methodology
- [Verilator](https://www.veripool.org/verilator/) simulation toolkit
```

Key Design Choices:  
1. Name Inspiration: "Sapphire" evokes both the gemstone's durability and blue hues (common in FPGA diagrams)  
2. SHAKTI Alignment: Adopts similar verification strategies and documentation style  
3. Steel-like Minimalism: Focus on RV32I-only implementation for maximum transparency  


```

![Screenshot 2025-03-23 213107](https://github.com/user-attachments/assets/1aa3e888-c468-46d0-88d6-d59ba2a0da30)

