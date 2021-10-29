
# Xilinx Flows

There are two Xilinx flows. One for targeting the Sasebo FPGA board
and on for the ChipWhisperer 305 (CW305).

## Sasebo flow:

To re-create the sasebo project, move to the root directory of the project
and run:

```sh
./bin/create-xilinx-xc7k-project.sh
```

This will create a Vivado project under `work/vivado/scarv-soc-masking-ise`.
The project can then be opened and used to generate a bitstream.
Programming of the Sasebo FPGA is done with the Xilinx debugger through
Vivado.

## CW305 flow:

To re-create the sasebo project, move to the root directory of the project
and run:

```sh
./bin/create-xilinx-xc7k-project.sh
```

This will create a Vivado project under `work/vivado/scarv-soc-masking-ise-cw305`.
The project can then be opened and used to generate a bitstream.

To program the CW305 board, use the
`flow/xilinx/cw305_program.py` script:

```sh
./flow/xilinx/cw305_program.py --help

usage: cw305_program.py [-h] [--bitstream BITSTREAM] [--fpga-freq FPGA_FREQ]
                        [--fpga-vcc FPGA_VCC] [--verbose]

optional arguments:
  -h, --help            show this help message and exit
  --bitstream BITSTREAM
                        The bitstream to program the CW305 with.
  --fpga-freq FPGA_FREQ
                        Frequency of the FPGA PLL
  --fpga-vcc FPGA_VCC   Voltage to supply to the FPGA
  --verbose
```

Note that this script requires the `chipwhisperer` Python package to
be installed.

To easily upload the bitstream from the generated project, you can
run:

```sh
# See flow/xilinx/Makefile.in
make xilinx-cw305-upload-bitstream
```

NOTE: This _may_ require sudo priviledges.

### CW305 Design information

- The CW305 PLL used to drive the FPGA is `PLL1`.
  `PLL1` should be set to `100MHz`
  Other PLLs are disabled.

- The internal FPGA design runs a `50MHz`.

- The FPGA supply voltage VCC should be set to `1.0V`.

- All of this is handled in the `cw305_program.py` script.

Pins (also described in `constraints-cw305.xdc`):

- UART TX from the FPGA: FPGA Pin `P16` / CW305 `IO1`
- UART RX to   the FPGA: FPGA Pin `R16` / CW305 `IO2`
- GPIO pins are routed to the CW305 header.
  Any GPIO may be used as the trigger.
  - GPIO `0` - FPGA Pin `A12`
  - GPIO `1` - FPGA Pin `A14`
  - GPIO `2` - FPGA Pin `A15`
  - GPIO `3` - FPGA Pin `C12`
  - GPIO `4` - FPGA Pin `B12`
  - GPIO `5` - FPGA Pin `A13`
  - GPIO `6` - FPGA Pin `B15`
  - GPIO `7` - FPGA Pin `C11`
  - GPIO `8` - FPGA Pin `B14`
  - GPIO `9` - FPGA Pin `C14`

Peripheral Addresses:

- GPIO base address `0x40002000`
 ([Datasheet](https://www.xilinx.com/support/documentation/ip_documentation/axi_gpio/v2_0/pg144-axi-gpio.pdf))
- UART base address `0x40001000`
  ([Datasheet](https://www.xilinx.com/support/documentation/ip_documentation/axi_uartlite/v2_0/pg142-axi-uartlite.pdf))

## Uploading software to a programmed FPGA

Both the Sasebo and CW305 bitstreams use the same bootloader, and expect
to download the software to run over a UART connection.
See the `bin/upload-program.py` script for how to do this.

```sh
./bin/upload-program.py --help

usage: upload-program.py [-h] [--no-waiting] [--baud BAUD] [--goto GOTO]
                         port binary start
```

