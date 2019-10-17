
ifndef SOC_HOME
    $(error "Please run 'source ./bin/conf.sh' to setup the project workspace")
endif

export SCARV_CPU_RTL_DIR = $(SOC_HOME)/extern/scarv-cpu/rtl/core

CC              = $(RISCV)/bin/riscv32-unknown-elf-gcc
AS              = $(RISCV)/bin/riscv32-unknown-elf-as
AR              = $(RISCV)/bin/riscv32-unknown-elf-ar
OBJDUMP         = $(RISCV)/bin/riscv32-unknown-elf-objdump
OBJCOPY         = $(RISCV)/bin/riscv32-unknown-elf-objcopy

include $(SOC_HOME)/src/fsbl/Makefile.in
include $(SOC_HOME)/flow/verilator/Makefile.in

