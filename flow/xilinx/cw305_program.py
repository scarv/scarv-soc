#!/usr/bin/python3

import argparse

import chipwhisperer as cw

PLL0 = 0
PLL1 = 1
PLL2 = 2

FPGA_PLL = PLL1
FPGA_FREQ= 100000000
FPGA_VCC = 1.0

def print_pll_info(target):
    print("PLL Current Frequency / slew:")
    print("0: %12d / %s" % (target.pll.pll_outfreq_get(PLL0), target.pll.pll_outslew_get(PLL0)))
    print("1: %12d / %s" % (target.pll.pll_outfreq_get(PLL1), target.pll.pll_outslew_get(PLL1)))
    print("2: %12d / %s" % (target.pll.pll_outfreq_get(PLL2), target.pll.pll_outslew_get(PLL2)))

def build_arg_parser():
    ap = argparse.ArgumentParser()

    ap.add_argument("--bitstream",type=str, required=False,
        help="The bitstream to program the CW305 with.")
    ap.add_argument("--fpga-freq",type=int,default=FPGA_FREQ,
        help="Frequency of the FPGA PLL")
    ap.add_argument("--fpga-vcc",type=float,default=FPGA_VCC,
        help="Voltage to supply to the FPGA")
    ap.add_argument("--verbose",action="store_true")

    return ap

def main():

    ap      = build_arg_parser()
    args    = ap.parse_args()
    
    # Connect to the target
    scope   = None
    target  = None
    if(args.bitstream):
        print("Programming with Bitfile: %s" % args.bitstream)
        target = cw.target(scope, cw.targets.CW305, bsfile=args.bitstream,
            force=True)
    else:
        target = cw.target(scope, cw.targets.CW305)

    # Set VCC-INT to 1V
    print("Setting FPGA VCC: %f" % args.fpga_vcc)
    target.vccint_set(args.fpga_vcc)

    # optional, but reduces power trace noise
    target.clkusbautooff    = True
    target.clksleeptime     = 1 # 1ms typically good for sleep

    # Configure the PLLs
    target.pll.pll_enable_set(True) #Enable PLL chip
    target.pll.pll_outenable_set(False, PLL0) # Disable unused PLL0
    target.pll.pll_outenable_set(True , PLL1) # Enable PLL1 for the FPGA
    target.pll.pll_outenable_set(False, PLL2) # Disable unused PLL2

    # Set the output frequencies for the FPGA PLL to 100MHz
    print("Setting FPGA Freq: %d" % args.fpga_freq)
    target.pll.pll_outfreq_set(args.fpga_freq, FPGA_PLL)

    if(args.verbose):
        print_pll_info(target)

if(__name__ == "__main__"):
    main()
