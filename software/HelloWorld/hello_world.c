/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>


int main()
{
	FILE *lcd_dev;
	char *lcd_static;
	int len;

	lcd_dev = fopen( "/dev/lcd", "w" );
	lcd_static = "Hello from Nios II!";
	len = strlen(lcd_static);
	fwrite( lcd_static, 1, len, lcd_dev );
	fclose(lcd_dev);

	printf("Hello from Nios II!\n");

	return 0;
}
