#!/bin/bash

export SOC_HOME="${PWD}"
export SOC_WORK=$SOC_HOME/work
export TEXMFLOCAL="${TEXMFLOCAL}:${SOC_HOME}/extern/texmf"

export SCARV_CPU=$SOC_HOME/extern/scarv-cpu
export SCARV_SOC=$SOC_HOME
export FRV_HOME=$SCARV_CPU
export XCRYPTO_RTL=$SCARV_CPU/external/xcrypto/rtl


if [[ -z "$VERILATOR_ROOT" ]]; then
    echo "Warning: No VERILATOR_ROOT environment variable set."
    export VERILATOR_ROOT=/opt/eda/verilator
fi

if [[ -z "$YOSYS_ROOT" ]]; then
    echo "Warning: No YOSYS_ROOT environment variable set."
    export YOSYS_ROOT=/opt/eda/Yosys
fi

echo "------------------------ SCARV SoC Project Setup ----------------------"
echo "SOC_HOME          = $SOC_HOME"
echo "SOC_WORK          = $SOC_WORK"
echo "VERILATOR_ROOT    = $VERILATOR_ROOT"
echo "YOSYS_ROOT        = $YOSYS_ROOT"
echo "SCARV_CPU         = $SCARV_CPU"
echo "-----------------------------------------------------------------------"

