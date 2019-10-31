
#include <stdint.h>

#ifndef SCARVSOC_GPIO_H
#define SCARVSOC_GPIO_H

//! Config object for a single GPIO instance.
typedef volatile uint32_t * scarvsoc_gpio_conf;

//! Base config for GPIO bank 0.
extern scarvsoc_gpio_conf SCARVSOC_GPIO0;

//! Base config for GPIO bank 1.
extern scarvsoc_gpio_conf SCARVSOC_GPIO1;

//! Write to a UART bank
void scarvsoc_gpio_wr (
    scarvsoc_gpio_conf  conf,
    uint32_t            data
);

//! Read from a UART bank
uint32_t scarvsoc_gpio_rd (
    scarvsoc_gpio_conf  conf
);

#endif

