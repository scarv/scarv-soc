
#
# Interconnect sources
read_verilog $::env(SOC_HOME)/rtl/ic/ic_addr_decode.v
read_verilog $::env(SOC_HOME)/rtl/ic/ic_cpu_bus_bram_bridge.v
read_verilog $::env(SOC_HOME)/rtl/ic/ic_cpu_bus_axi_bridge.v
read_verilog $::env(SOC_HOME)/rtl/ic/ic_rsp_router.v
read_verilog $::env(SOC_HOME)/rtl/ic/ic_rsp_tracker.v
read_verilog $::env(SOC_HOME)/rtl/ic/ic_error_rsp_stub.v
read_verilog $::env(SOC_HOME)/rtl/ic/ic_top.v


#
# Random number generator
read_verilog $::env(SOC_HOME)/rtl/rng/scarv_rng_lfsr.v
read_verilog $::env(SOC_HOME)/rtl/rng/scarv_rng_top.v


#
# XCrypto + SCARV CPU sources.
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/external/xcrypto-rtl/rtl/p_addsub/p_addsub.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/external/xcrypto-rtl/rtl/p_shfrot/p_shfrot.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/external/xcrypto-rtl/rtl/xc_sha3/xc_sha3.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/external/xcrypto-rtl/rtl/xc_sha256/xc_sha256.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/external/xcrypto-rtl/rtl/xc_aessub/xc_aessub.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/external/xcrypto-rtl/rtl/xc_aessub/xc_aessub_sbox.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/external/xcrypto-rtl/rtl/xc_aesmix/xc_aesmix.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/external/xcrypto-rtl/rtl/xc_malu/xc_malu.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/external/xcrypto-rtl/rtl/xc_malu/xc_malu_divrem.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/external/xcrypto-rtl/rtl/xc_malu/xc_malu_long.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/external/xcrypto-rtl/rtl/xc_malu/xc_malu_mul.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/external/xcrypto-rtl/rtl/xc_malu/xc_malu_pmul.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/external/xcrypto-rtl/rtl/xc_malu/xc_malu_muldivrem.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/external/xcrypto-rtl/rtl/b_bop/b_bop.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/external/xcrypto-rtl/rtl/b_lut/b_lut.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/rtl/core/frv_alu.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/rtl/core/frv_asi.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/rtl/core/frv_bitwise.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/rtl/core/frv_core.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/rtl/core/frv_core_fetch_buffer.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/rtl/core/frv_counters.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/rtl/core/frv_csrs.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/rtl/core/frv_gprs.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/rtl/core/frv_interrupts.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/rtl/core/frv_leak.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/rtl/core/frv_lsu.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/rtl/core/frv_pipeline.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/rtl/core/frv_pipeline_decode.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/rtl/core/frv_pipeline_execute.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/rtl/core/frv_pipeline_fetch.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/rtl/core/frv_pipeline_memory.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/rtl/core/frv_pipeline_register.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/rtl/core/frv_pipeline_writeback.v
read_verilog $::env(SOC_HOME)/extern/scarv-cpu/rtl/core/frv_rngif.v


#
# Memories
read_verilog $::env(SOC_HOME)/rtl/mem/scarv_soc_bram_dual_synth_xilinx_xc7k.v

#
# SCARV SoC top level sources.
read_verilog $::env(SOC_HOME)/rtl/soc/scarv_soc.v

