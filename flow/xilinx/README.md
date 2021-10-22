
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

To easily upload the bitstream from the generated project, you can
run:

```sh
make xilinx-cw305-upload-bitstream
```

NOTE: This _may_ require sudo priviledges.

## Uploading software to a programmed FPGA

Both the Sasebo and CW305 bitstreams use the same bootloader, and expect
to download the software to run over a UART connection.
See the `bin/upload-program.py` script for how to do this.

```sh
./bin/upload-program.py --help

usage: upload-program.py [-h] [--no-waiting] [--baud BAUD] [--goto GOTO]
                         port binary start
```

