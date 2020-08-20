
#include "scarvsoc_gpio.h"


scarvsoc_gpio_conf SCARVSOC_GPIO0 = (scarvsoc_gpio_conf)0x10001000;


scarvsoc_gpio_conf SCARVSOC_GPIO1 = (scarvsoc_gpio_conf)0x10001008;


void scarvsoc_gpio_wr (
    scarvsoc_gpio_conf  conf,
    uint32_t            data
){
    *conf = data;
}


uint32_t scarvsoc_gpio_rd (
    scarvsoc_gpio_conf  conf
){
    return *conf;
}


void scarvsoc_gpio_setbit(
    scarvsoc_gpio_conf  conf,
    int                 bit
){
    uint32_t current  = scarvsoc_gpio_rd(conf);
    
    uint32_t new      = current | (0x1 << bit);
    
    scarvsoc_gpio_wr(conf, new);
}


void scarvsoc_gpio_clrbit(
    scarvsoc_gpio_conf  conf,
    int                 bit
){
    uint32_t current  = scarvsoc_gpio_rd(conf);
    
    uint32_t new      = current | ~(0x1 << bit);
    
    scarvsoc_gpio_wr(conf, new);
}
