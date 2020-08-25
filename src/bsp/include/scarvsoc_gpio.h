
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

#define GPIO_INPUTS    0
#define GPIO_OUTPUTS   1
#define GPIO_DIRECTION 2
#define GPIO_CTRL      3

/*!
@brief Base config for GPIO bank 0.
@ingroup driver_gpio
*/
extern scarvsoc_gpio_conf SCARVSOC_GPIO0;

/*
@brief Get the word controlling which GPIOs are inputs or outputs.
@details 1 = output, 0 = input.
*/
inline uint32_t scarvsoc_gpio_get_iomask(
    scarvsoc_gpio_conf conf
){
    return conf[GPIO_DIRECTION];
}

/*
@brief Set the word controlling which GPIOs are inputs or outputs.
@details 1 = output, 0 = input.
*/
inline void scarvsoc_gpio_set_iomask(
    scarvsoc_gpio_conf conf,
    uint32_t           mask //!< The IO mask.
){
    conf[GPIO_DIRECTION] = mask;
}


//! Set the output pin values.
inline void scarvsoc_gpio_set_outputs(
    scarvsoc_gpio_conf conf,
    uint32_t           vals
){
    conf[GPIO_OUTPUTS] = vals;
}


//! Get the output pin values.
inline uint32_t scarvsoc_gpio_get_outputs(
    scarvsoc_gpio_conf conf
){
    return conf[GPIO_OUTPUTS];
}


//! Get the input pin values.
inline uint32_t scarvsoc_gpio_get_inputs (
    scarvsoc_gpio_conf conf
){
    return conf[GPIO_INPUTS];
}

#undef GPIO_INPUTS
#undef GPIO_OUTPUTS
#undef GPIO_DIRECTION
#undef GPIO_CTRL

#endif

