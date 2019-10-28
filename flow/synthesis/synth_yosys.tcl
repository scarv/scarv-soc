
yosys -import

tcl  $::env(SOC_HOME)/flow/synthesis/scarv-soc-rtl.tcl

synth -top scarv_soc

write_verilog $::env(SOC_WORK)/synthesis/synthesised.v

