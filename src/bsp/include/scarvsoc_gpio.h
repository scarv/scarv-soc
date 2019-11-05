
#include <stdint.h>

#ifndef SCARVSOC_GPIO_H
#define SCARVSOC_GPIO_H

/*!
@defgroup driver_gpio GPIO
@brief API for the GPIO peripheral on the SCARV SoC
@details The GPIO can be used by including "scarvsoc_gpio.h".
*/

//! Config object for a single GPIO instance.
typedef volatile uint32_t * scarvsoc_gpio_conf;

/*!
@brief Base config for GPIO bank 0.
@ingroup driver_gpio
*/
extern scarvsoc_gpio_conf SCARVSOC_GPIO0;

/*!
@brief Base config for GPIO bank 1.
@ingroup driver_gpio
*/
extern scarvsoc_gpio_conf SCARVSOC_GPIO1;

/*!
@brief Write to a UART bank
@param[in] conf - The GPIO config object indicating which GPIO bank to write.
@param[in] data - A 32-bit word indicating the new value to write to the GPIOs.
@ingroup driver_gpio
*/
void scarvsoc_gpio_wr (
    scarvsoc_gpio_conf  conf,
    uint32_t            data
);

/*!
@brief Read from a UART bank
@param[in] conf - The GPIO config object indicating which GPIO bank to read.
@ingroup driver_gpio
*/
uint32_t scarvsoc_gpio_rd (
    scarvsoc_gpio_conf  conf
);

/*!
@brief Set a single bit in the supplied GPIO bank
@param[in] conf - The GPIO bank to alter
@param[in] bit  - Which bit of the bank to set.
@ingroup driver_gpio
*/
void scarvsoc_gpio_setbit(
    scarvsoc_gpio_conf  conf,
    int                 bit
);

/*!
@brief Clean a single bit in the supplied GPIO bank
@param[in] conf - The GPIO bank to alter
@param[in] bit  - Which bit of the bank to clear.
@ingroup driver_gpio
*/
void scarvsoc_gpio_clrbit(
    scarvsoc_gpio_conf  conf,
    int                 bit
);

#endif

