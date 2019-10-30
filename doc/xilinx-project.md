
# Xilinx SoC Project

*Describes the Xilinx project, how to re-create it and how to use it.*

---

There is a flow for re-creating the Xilinx project used to generate
a bitstream for the complete SoC.

## Project Components

- `flow/xilinx/`

  - `scarv-soc-project.tcl` - The Vivado `tcl` script which creates 
    the project.

  - `tb_top_behave.wcfg` - Simulation wave view configuration.

  - `constraints-xc7k.cxd` - Pin constraints for targeting the
    SASEBO-GIII FPGA board.

  - `scarv-soc-xc7k.bit` - A pre-generated bitfile.

- `bin/create-xilinx-xc7k-project.sh` - A bash script to automate the project
  re-creation steps.

- `rtl/xilinx/*` - Xilinx project specific RTL files.

- `verif/xilinx/*` - Testbench files for running simulations inside Vivado.


## Creating the Project

Run the following commands to re-create the project.

- Make sure that the SOC environment is setup:

  ```sh
  source ./bin/conf.sh
  ```

- Make sure that the `VIVADO_ROOT` variable points to a Vivado installation:

  ```sh
  export VIVADO_ROOT=<path to installation>
  ```

  Note that the project was initially created using Vivado 2019.1.

- Source the Vivado environment setup scripts:

  ```sh
  source $VIVADO_ROOT/settings64.sh
  ```

- Run the project re-creation scripts:

  ```sh
  cd $SOC_HOME
  ./bin/create-xilinx-xc7k-project.sh
  ```

 - You can now open Vivado and the project file in
  `$SOC_WORK/vivado/scarv-soc-xc7k/scarv-soc-xc7k.xpr`
  and start working with the project.

  There is also a pre-generated bitfile in `$SOC_HOME/flow/xilinx/`

