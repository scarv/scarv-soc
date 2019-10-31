
#include "scarvsoc_gpio.h"

//! Base config for GPIO bank 0.
scarvsoc_gpio_conf SCARVSOC_GPIO0 = (scarvsoc_gpio_conf)0x40002000;

//! Base config for GPIO bank 1.
scarvsoc_gpio_conf SCARVSOC_GPIO1 = (scarvsoc_gpio_conf)0x40002008;

//! Write to a UART bank
void scarvsoc_gpio_wr (
    scarvsoc_gpio_conf  conf,
    uint32_t            data
){
    *conf = data;
}

//! Read from a UART bank
uint32_t scarvsoc_gpio_rd (
    scarvsoc_gpio_conf  conf
){
    return *conf;
}
