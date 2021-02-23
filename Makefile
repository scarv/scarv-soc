
ifndef SOC_HOME
    $(error "Please run 'source ./bin/conf.sh' to setup the project workspace")
endif

CC              = $(RISCV)/bin/riscv64-unknown-elf-gcc
AS              = $(RISCV)/bin/riscv64-unknown-elf-as
AR              = $(RISCV)/bin/riscv64-unknown-elf-ar
OBJDUMP         = $(RISCV)/bin/riscv64-unknown-elf-objdump
OBJCOPY         = $(RISCV)/bin/riscv64-unknown-elf-objcopy

OBJCOPY_HEX_ARGS= --gap-fill 0 

export SME_SMAX ?= 3

texdocs-%:
	$(MAKE) -C $(SOC_HOME)/doc $%

all: texdocs-all

include $(SOC_HOME)/src/fsbl/Makefile.in

include $(SOC_HOME)/flow/verilator/Makefile.in
include $(SOC_HOME)/flow/formal/Makefile.in
include $(SOC_HOME)/flow/selfcheck/Makefile.in
include $(SOC_HOME)/flow/synthesis/Makefile.in

include $(SOC_HOME)/src/bsp/Makefile.in
include $(SOC_HOME)/src/examples/Makefile.in

include $(SOC_HOME)/flow/xilinx/Makefile.in

