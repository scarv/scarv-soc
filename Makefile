
ifndef SOC_HOME
    $(error "Please run 'source ./bin/conf.sh' to setup the project workspace")
endif

export SCARV_CPU_RTL_DIR = $(SOC_HOME)/extern/scarv-cpu/rtl/core

include $(SOC_HOME)/flow/verilator/Makefile.in

