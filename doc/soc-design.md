
# SCARV SoC Design

*This document gives a top level decription of the SCARV SoC and
it's major functional components*.

---

## Overview

- The SCARV SoC is designed to be a self-contained "drop-in" subsystem
  which can be ported to different implementation targets relatively
  easily.

- The core of the SoC is made up of:

  - The SCARV-CPU

  - A boot ROM

  - Tightly coupled SRAM memory

  - A random number source.

  - A basic memory interconnect

  - An AXI-4 interface to a wider bus architecture.

- The AXI-4 interconnect is used to connect to 3rd part IP cores
  which we re-use.

  - As our own IP cores are developed, the idea is to move them into
    the SoC core and connect them to the internal interconnect.

  - Eventually, we want to have only very complex or technology
    specific IP cores provided by 3rd parties.

## SoC Core

This is made up of

- The SCARV-CPU

- A boot ROM and some RAM

- A simple memory interconnect

- A random number source.

The memory interconnect is responsible for routing requests from the
CPU instruction / data interfaces to either the ROM, RAM or the external
AXI port.

### SoC Memory Map

The SoC memory map is split into two levels.

- The first is governed by the simple memory interconnect:

Address      | Range        | Description
-------------|--------------|-------------------------------------------
`0x40000000` | `0x4FFFFFFF` | External AXI Bus (tentative)
`0x20000000` | `0x2000FFFF` | 64K Dual port tightly coupled RAM
`0x10000000` | `0x10003FFF` | 1K Boot ROM
`0x00000000` | `0x00000FFF` | Memory mapped IO devices (CPU Internal)

- The second level is managed by whatever AXI interconnect is on the
  other end of the external AXI bus.

### SCARV CPU

- See the SCARV CPU [project repository](https://github.com/scarv/scarv-cpu).


### Boot ROM

- This contains enough code to download a program and start the CPU
  running.

- The program can be sourced from:

  - An external UART device.

  - Already baked into the RAM (FPGA targets only).

- This is a single port ROM, with accesses multipliexed between
  instructions and data.

  - Data accesses get precedence.


### RAM

- Tightly coupled dual port ram with single cycle access latency.

- 64Kb in size.

  - This will be an externally configurable parameter.


### Memory Interconnect

- See [Memory Interconnect Page](memory-interconnect.md)
