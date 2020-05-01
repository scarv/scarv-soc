#!/usr/bin/python3

"""
A script for uploading programs to the target FPGA.
"""

import os
import sys
import argparse

import serial
import tqdm

FSBL_PROMPT = "scarv-soc fsbl\n"

def getargs():
    """
    Parse command line arguments to the script
    """

    parser = argparse.ArgumentParser()

    parser.add_argument("--no-waiting", action="store_true",
        help="Don't wait for the FSBL ready string, just send everything.")
    
    parser.add_argument("--baud", type=int, default = 115200, 
        help="UART port baud speed")

    parser.add_argument("--goto", type=str,
        help="For telling the acquisition framework to re-enter the FSBL.")
    
    parser.add_argument("port", type=str,
        help="UART port to program over")

    parser.add_argument("binary", type=str,
        help="The binary program to download")

    parser.add_argument("start", type=str,
        help="Start address of the program as hex i.e. 0x20000000")
    
    return parser.parse_args()


def main():
    """
    Main function for the script
    """
    args = getargs()    

    port = serial.Serial()
    port.baudrate = args.baud
    port.port     = args.port
    port.timeout  = 30
    port.open()

    btosend = None

    with open(args.binary,"rb") as fh:
        btosend = fh.read()

    fsize   = len(btosend)

    if(args.goto):

        target_addr = int(args.goto,0).to_bytes(4, byteorder="little")

        print("Issuing GOTO Command: G %s" % args.goto)

        port.write("G".encode("ascii"))
        port.write(target_addr)
        port.flush()

    if(not args.no_waiting):

        print("Waiting for FSBL, please reset the target...")
        
        # Make sure the FSBL is ready
        line = str(port.readline(),encoding="ascii")

        if(line == FSBL_PROMPT):
            pass
        else:
            print(line)
            print(type(line))
            raise Exception("FSBL not ready to recieve data")

    print("Programming %s, size=%d, start=%s" % (
        args.binary,fsize,args.start))
    
    fsize_b = fsize.to_bytes(4, byteorder="little")
    start_b = int(args.start,0).to_bytes(4, byteorder="little")

    port.write(fsize_b[::-1])
    port.write(start_b[::-1])
    port.write(btosend)

    port.flush()

    print("Programming: Done")

    port.close()


if(__name__=="__main__"):
    main()
