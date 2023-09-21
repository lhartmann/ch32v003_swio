/*
 * Example for 24L01+ over SPI, using https://github.com/ebrezadev/nRF24L01-C-Driver
 * 04-26-2023 recallmenot 
 */

#include "ch32v003fun.h"
#include <stdio.h>

#define TIME_GAP 1000
uint8_t ascending_number = 0x00;
char txt[16];

//######### LED fn

// led is PD4 to LED1 on board, which is (-)
inline void led(bool on) {
	if (on)
		GPIOD->BSHR = 1<<(16+4);
	else
		GPIOD->BSHR = 1<<4;
}

int main() {
	SystemInit();
	Delay_Ms(100);

	// GPIO D4 Push-Pull for foreground blink
	RCC->APB2PCENR |= RCC_APB2Periph_GPIOD;
	GPIOD->CFGLR &= ~(0xf<<(4*4));
	GPIOD->CFGLR |= (GPIO_Speed_10MHz | GPIO_CNF_OUT_PP)<<(4*4);

	Delay_Ms(1000);

	printf("looping...\n\r");
	while(1)
	{
		Delay_Ms( TIME_GAP );

		ascending_number++;

		printf("***		next number: %u\n\r", ascending_number);
	}
}
