# Toolchain setup
CC = riscv64-unknown-elf-gcc
CFLAGS = -march=rv32i -mabi=ilp32 -nostartfiles -T link.ld
VIVADO = vivado
BOARD = genesys2

# Targets
.PHONY: all synth program clean

all: app.elf

app.elf: app/main.c freertos/*.c
    $(CC) $(CFLAGS) -I freertos/include -o $@ $^

synth:
    $(VIVADO) -mode batch -source scripts/synth.tcl

program: 
    $(VIVADO) -mode batch -source scripts/program_$(BOARD).tcl

clean:
    rm -f *.elf *.bit *.bin *.log
