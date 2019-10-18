# Memory Interconnect

*This page describes the simple memory interconnect used to
 route requests/responses in and out of the scarv-cpu*

---

## Overview

- Responsible for routing requests from the CPU to the appropriate
  peripheral.

  - Enforces the first stage of the SoC memory map 
    (see [here](soc-design.md#SoC-Memory-Map)).

- Two input request ports:

  - CPU instruction fetch interface. Reads only.

  - CPU data interface. Reads and Writes.

    - Writes are non-posted.

- Five output request ports:

  - Boot ROM (Instructions)
  
  - Boot ROM (Data)

  - RAM (Instructions)

  - RAM (Data)

  - AXI port.

- The Boot ROM port multiplexes instruction and data accesses, with data
  accesses given priority.

- RAM accesses should have 1 cycle access latency.

- The AXI port does not need to be performance optimised.

  - Instruction + data accesses are multiplexed onto this.

  - All requests block until they are completed. There is no
    tracking of outstanding requests.
