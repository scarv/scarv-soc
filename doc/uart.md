
# UART Peripheral

*Documents the UART peripheral and how to program it.*

---

## Relevant Files

- The Verilog code is kept in `rtl/uart/`.
- The C Driver is kept in `src/bsp/` under `include` and `src`.

## Key Information:

- Four registers:

  Offset | Name   | Description
  -------|--------|---------------------------------------------------------
  0x0    | `rx`   | The head of FIFO for reading recieved data.
  0x4    | `tx`   | Writes to this cause the UART to send the written byte.
  0x8    | `stat` | Current status of the peripheral.
  0xC    | `ctrl` | Interrupt enable and control bits.

- `8` byte deep recieve and transmit FIFOs.

- Configurable interrupt raising for:

  - Any byte valid byte being recieved and ready for reading.

  - The RX FIFO being full.

  - Recieving a `break` message via the RX UART line.

## Registers

### RX

Bits    | Name    | Description
--------|---------|----------------------------------------------------------
`31: 8` | N/A     | Writes ignored, read `0x0`.
` 7: 0` |`rx_data`| Writes ignored, read oldest recieved byte. Undefined if `stat.rx_valid` is `0`.

### TX

Bits    | Name    | Description
--------|---------|----------------------------------------------------------
`31: 8` | N/A     | Writes ignored, read `0x0`.
` 7: 0` |`tx_data`| Reads  ignored. Writes will add this byte to the tx FIFO.

### STAT

Bits    | Name     | Description
--------|----------|---------------------------------------------------------
`31: 7` | N/A      | Writes ignored, read `0x0`.
` 6   ` |`int     `| An interrupt has been raised. To clear, write `ctrl.clear_int=0`
` 5   ` |`tx_busy `| Currently sending bytes via the TX module.
` 4   ` |`tx_full `| TX FIFO is full.
` 3   ` |`rx_break`| We recieved a `break` message. To clear, write `ctrl.clear_break=0`
` 2   ` |`rx_busy `| We are currently recieving bytes.
` 1   ` |`rx_full `| The RX FIFO is full.
` 0   ` |`rx_valid`| There is valid data to be read from the RX FIFO.

### CTRL

Bits    | Name     | Description
--------|----------|---------------------------------------------------------
`31: 7` | N/A      | Writes ignored, read `0x0`.
` 6   ` |`clear_rx`| Read `0`. Write `1` to empty the RX FIFO, discarding any contents.
` 5   ` |`clear_tx`| Read `0`. Write `1` to empty the TX FIFO, discarding any contents.
` 4   ` |`clear_break`| Read `0`. Write `1` to clear `stat.rx_break`.
` 3   ` |`clear_int`| Read `0`. Write `1` to clear `stat.int`.
` 2   ` |`en_int_break  `| Enable interrupt when we recieve a `break` byte.
` 1   ` |`en_int_rx_any `| Enable interrupt when any RX data is available.
` 0   ` |`en_int_rx_full`| Enable interrupt when RX FIFO is full.

