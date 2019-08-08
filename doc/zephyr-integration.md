
# Zephyr Integration

*This document describes the Zephyr integration for the SCARV SoC,
and how to build applications targeting it.*

---

## Zephyr Documentation Links

- [Zephyr Project Home](https://zephyrproject.org)
- [Getting Started With Zephyr](https://docs.zephyrproject.org/latest/getting_started/index.html)
- [Application Development With Zephyr](https://docs.zephyrproject.org/latest/application/index.html)

## Integration Overview

- The SCARV SoC Zephyr integration exists as a custom board and SoC definition
  using the standard Zephyr directory structure.

  - The Zephyr documentation describes this structure
    [here](https://docs.zephyrproject.org/latest/application/index.html#custom-board-devicetree-and-soc-definitions)

- This repository contains the nessesary files and directory structure under
  the `zephyr/` directory.

- The aim is to not modify the original Zephyr source tree.

  - This is be possible for just defining the SCARV SoC and Board.

  - A fork may be required to integrate our custom crypto code into the base
    Zephyr OS.

- The integration uses the following naming conventions:

  - The SoC name for the directory structure is `scarv_soc`.

  - The Board name for the directory structure is `scarv_board`.

## Directory structure

All Zephyr related integration code in this repository lives under the
`zephyr` subdirectory.

The directory structures here are based on those detailed in the
[Zephyr documentation](https://docs.zephyrproject.org/latest/application/index.html#custom-board-devicetree-and-soc-definitions)

```
zephyr/
|- boards/
|  |- riscv/
|     |- scarv_board/
|        |- scarv_board_defconfig
|        |- scarv_board.dts
|        |- scarv_board.yaml
|        |- board.cmake
|        |- board.h
|        |- CMakeLists.txt
|        |- doc/
|        |- Kconfig.board
|        |- Kconfig.defconfig
|        |- support/
|- soc/
|  |- riscv/
|     |- scarv_soc/
|        |- soc.h
|        |- CMakeLists.txt
|        |- Kconfig
|        |- Kconfig.defconfig
|        |- Kconfig.soc
|        |- linker.ld
|- src/
|- CMakeLists.txt
|- prj.conf
|- README.md
```
