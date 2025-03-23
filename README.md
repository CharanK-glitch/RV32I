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


