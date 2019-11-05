
yosys -import

tcl  $::env(SOC_HOME)/flow/lattice/scarv-soc-rtl.tcl

# Lattice specific top level
read_verilog  $::env(SOC_HOME)/rtl/lattice/lattice_top.v

synth_ice40 -top lattice_top -dsp

write_json $::env(SOC_WORK)/lattice/lattice_top.json


