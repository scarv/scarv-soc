
yosys -import

tcl  $::env(SOC_HOME)/flow/lattice/scarv-soc-rtl.tcl

synth_ice40 -top scarv_soc

write_json $::env(SOC_WORK)/lattice/scarv_soc.json


