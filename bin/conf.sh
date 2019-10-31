#!/bin/bash

export SOC_HOME="${PWD}"
export SOC_WORK=$SOC_HOME/work
export TEXMFLOCAL="${TEXMFLOCAL}:${SOC_HOME}/extern/texmf"

if [[ -z "$VERILATOR_ROOT" ]]; then
    export VERILATOR_ROOT=/home/ben/tools/verilator
fi

echo "------------------------ SCARV SoC Project Setup ----------------------"
echo "SOC_HOME       = $SOC_HOME"
echo "SOC_WORK       = $SOC_WORK"
echo "VERILATOR_ROOT = $VERILATOR_ROOT"
echo "-----------------------------------------------------------------------"

