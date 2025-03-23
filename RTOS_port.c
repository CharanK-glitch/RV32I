// port.c - RISC-V (RV32I) port
#include "FreeRTOS.h"
#include "task.h"

// Context saving macros
#define portSAVE_CONTEXT() { \
    __asm volatile("sw x1, -4(sp)"); \
    /* Save all registers */ \
    __asm volatile("addi sp, sp, -60"); \
}

#define portRESTORE_CONTEXT() { \
    __asm volatile("lw x1, 56(sp)"); \
    /* Restore all registers */ \
    __asm volatile("addi sp, sp, 60"); \
}

// Timer interrupt setup
void vPortSetupTimerInterrupt(void) {
    // Configure CLINT for 100Hz tick
    *(volatile uint32_t*)0x02000000 = configCPU_CLOCK_HZ / configTICK_RATE_HZ;
    *(volatile uint32_t*)0x02000004 = 0x01;
}

// Start scheduler
void vPortStartFirstTask(void) {
    __asm volatile("mv sp, %0" ::"r"(pxCurrentTCB->pxStack));
    portRESTORE_CONTEXT();
    __asm volatile("mret");
}

// Context switch
void vPortYield(void) {
    __asm volatile("li a7, 0");
    __asm volatile("ecall");
}
