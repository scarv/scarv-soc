#!/usr/bin/python3

"""
A script for correcting the alignment of memory addresses / indexes in the
output of objcopy.
- Normally objcopy generates output addresses which are word aligned when
  using -O verilog
- This breaks when we then load the hex file into an N deep but 32-wide
  memory, since the indexes are 4-times too big.
- This script searches the hex files for memory addresses, and divides
  each address by some supplied amount.
"""

import sys
import os
import argparse

def parse_args():
    """
    Parse command line argumnets to the program
    """

    parser = argparse.ArgumentParser()

    parser.add_argument("--scale",type=int,default=4,
        help="Amount to divide each address by. Default = 4")

    parser.add_argument("hexfile",type=str,
        help="The file to modify. Works in place.")

    return parser.parse_args()


def main():
    """
    Main function. Reads the file, does the scaling. Puts it back.
    """

    args    = parse_args()

    towrite = ""
    
    with open(args.hexfile,"r") as fh:

        lines = fh.readlines()

        for l_i in range(0,len(lines)):
            
            tokens = lines[l_i].split()

            for t_i in range(0,len(tokens)):

                if(tokens[t_i][0] == "@"):

                    address = int(tokens[t_i][1:], 16)

                    new_addr= int(address / args.scale)

                    tokens[t_i] = "@" + hex(new_addr)[2:]

                else:
                    newline = "".join(tokens)
                    newtokens= []
                    while(newline):
                        newtokens.append(newline[:8])
                        newline = newline[8:]
                    tokens = newtokens
                    break

            lines[l_i] = " ".join(tokens)

        towrite = "\n".join(lines)
    

    with open(args.hexfile,"w") as fh:

        fh.write(towrite)

    return 0


if(__name__=="__main__"):
    sys.exit(main())

