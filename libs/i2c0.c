#include <bcm2835.h> 

#define BCM2835_GPIO_FSEL_INPT 0 
#define BCM2835_GPIO_FSEL_ALT0 4 

main() {
    bcm2835_init(); 
    bcm2835_gpio_fsel(0, BCM2835_GPIO_FSEL_INPT); 
    bcm2835_gpio_fsel(1, BCM2835_GPIO_FSEL_INPT); 
    bcm2835_gpio_fsel(28, BCM2835_GPIO_FSEL_INPT); 
    bcm2835_gpio_fsel(29, BCM2835_GPIO_FSEL_INPT); 

    bcm2835_gpio_fsel(28, BCM2835_GPIO_FSEL_ALT0); 
    bcm2835_gpio_set_pud(28, BCM2835_GPIO_PUD_UP); 
    bcm2835_gpio_fsel(29, BCM2835_GPIO_FSEL_ALT0); 
    bcm2835_gpio_set_pud(29, BCM2835_GPIO_PUD_UP); 
}
