#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "uart.h"

// GPIO and UART addresses
#define GPIO_BASE 0x40000000
#define UART_BASE 0x40100000

// Task prototypes
void vLEDTask(void *pvParams);
void vUARTTask(void *pvParams);

// Queue handle
QueueHandle_t xUARTQueue;

int main() {
    // Initialize hardware
    uart_init(UART_BASE, 115200);
    
    // Create tasks
    xTaskCreate(vLEDTask, "LED", configMINIMAL_STACK_SIZE, NULL, 1, NULL);
    xTaskCreate(vUARTTask, "UART", configMINIMAL_STACK_SIZE, NULL, 2, NULL);
    
    // Create queue
    xUARTQueue = xQueueCreate(10, sizeof(char[32]));
    
    // Start scheduler
    vTaskStartScheduler();
    
    while(1);
}

// LED Control Task
void vLEDTask(void *pvParams) {
    volatile uint32_t *gpio = (uint32_t*)GPIO_BASE;
    uint8_t count = 0;
    
    while(1) {
        *gpio = count++;
        vTaskDelay(pdMS_TO_TICKS(500));
    }
}

// UART Communication Task
void vUARTTask(void *pvParams) {
    char msg[32];
    
    while(1) {
        uart_puts("Enter command: ");
        uart_gets(msg, 32);
        xQueueSend(xUARTQueue, msg, portMAX_DELAY);
    }
}
