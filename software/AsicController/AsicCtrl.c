#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <io.h>
#include "system.h"

/* MicroC/OS-II definitions */
#include "includes.h"

/* Nichestack definitions */
#include "ipport.h"
#include "tcpport.h"

int WriteCommandReg(INT32U val)
{
	IOWR(TOFPET_AVALON_MM_IF_0_BASE, 0x0B, val);
	return 0;
}

int WriteNbitReg(INT32U val)
{
	IOWR(TOFPET_AVALON_MM_IF_0_BASE, 0x0A, val);
	return 0;
}

int WriteCfgFifo(int ndata, INT32U *val)
{
	int i;
	for(i=0;i<ndata;i++)
		IOWR(TOFPET_AVALON_MM_IF_0_BASE, 0x09, val[i]);
	return 0;
}

int ReadDummyReg(int x, INT32U *val)
{
	*val = IORD(TOFPET_AVALON_MM_IF_0_BASE, x);
	return 0;
}

int ReadCommandReg(INT32U *val)
{
	*val = IORD(TOFPET_AVALON_MM_IF_0_BASE, 0x0B);
	return 0;
}

int ReadNbitReg(INT32U *val)
{
	*val = IORD(TOFPET_AVALON_MM_IF_0_BASE, 0x0A);
	return 0;
}

int ReadCfgFifo(int ndata, INT32U *val)
{
	int i;
	for(i=0;i<ndata;i++)
		*(val+i) = IORD(TOFPET_AVALON_MM_IF_0_BASE, 0x08);
	return 0;
}

int ReadStatusReg(INT32U *val)
{
	*val = IORD(TOFPET_AVALON_MM_IF_0_BASE, 0x0C);
	return 0;
}

int ReadDataFifoStatus(INT32U *val)
{
	*val = IORD(TOFPET_AVALON_MM_IF_0_BASE, 0x06);
	return 0;
}

int ReadDataFifo(int ch, int ndata, INT32U *val)
{
	int i;
	INT32U x;
	for(i=0;i<ndata;i++)
	{
//		*(val+i) = htonl(IORD(TOFPET_AVALON_MM_IF_0_BASE, ch)); // THIS DOESN'T WORK !!!
		x = IORD(TOFPET_AVALON_MM_IF_0_BASE, ch);
		*(val+i) = htonl(x);
	}
	return 0;
}
