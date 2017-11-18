#include <stdio.h>

int shiftreg(void);
int global_state;

int main(void)
{
	global_state = 10;
	int i = 0;
	while (i++ < 10)
	{
		printf("%d \n", shiftreg());
	}
	putchar(10);
	i = 0;
	global_state = 213;
	while (i++ < 10)
	{
		printf("%d \n", shiftreg());
	}
	return 0;
}
