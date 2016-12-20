/******************************************************************************
* Copyright (c) 2006 Altera Corporation, San Jose, California, USA.           *
* All rights reserved. All use of this software and documentation is          *
* subject to the License Agreement located at the end of this file below.     *
*******************************************************************************
* Date - October 24, 2006                                                     *
* Module - simple_socket_server.c                                             *
*                                                                             *
******************************************************************************/
 
/******************************************************************************
 * Simple Socket Server (SSS) example. 
 * 
 * This example demonstrates the use of MicroC/OS-II running on NIOS II.       
 * In addition it is to serve as a good starting point for designs using       
 * MicroC/OS-II and Altera NicheStack TCP/IP Stack - NIOS II Edition.                                          
 *                                                                             
 * -Known Issues                                                             
 *     None.   
 *      
 * Please refer to the Altera NicheStack Tutorial documentation for details on this 
 * software example, as well as details on how to configure the NicheStack TCP/IP 
 * networking stack and MicroC/OS-II Real-Time Operating System.  
 */
 
#include <stdio.h>
#include <string.h>
#include <ctype.h> 

/* MicroC/OS-II definitions */
#include "includes.h"

/* Simple Socket Server definitions */
#include "simple_socket_server.h"                                                                    
#include "alt_error_handler.h"

/* Nichestack definitions */
#include "ipport.h"
#include "tcpport.h"
#include "libport.h"
#include "osport.h"

#include "AsicCtrl.h"
/*
 * Global handles (pointers) to our MicroC/OS-II resources. All of resources 
 * beginning with "SSS" are declared and created in this file.
 */

/*
 * This SSSLEDCommandQ MicroC/OS-II message queue will be used to communicate 
 * between the simple socket server task and Nios Development Board LED control 
 * tasks.
 *
 * Handle to our MicroC/OS-II Command Queue and variable definitions related to 
 * the Q for sending commands received on the TCP-IP socket from the 
 * SSSSimpleSocketServerTask to the LEDManagementTask.
 */

#define DATA_FIFO_READOUT_TASK_PRIORITY 11
#define USER_TASK_STACKSIZE 4096
//OS_STK DataFifoReadout_TaskStk[APP_STACK_SIZE];
//int DataFifoReadoutTask(int);
//void sss_udp_process(int, struct sockaddr_in *);
void sss_udp_process(void);
INT8U tx_buf[SSS_TX_BUF_SIZE];
INT8U rx_buf[SSS_RX_BUF_SIZE];
INT32U databuf[DATA_BUF_SIZE];
struct sockaddr_in cliaddr;
int fd_listen;

TK_OBJECT(to_DataFifoReadoutTask);
TK_ENTRY(DataFifoReadoutTask);
struct inet_taskinfo ReadoutTask = {
      &to_DataFifoReadoutTask,
      "Data Readout",
      DataFifoReadoutTask,
      DATA_FIFO_READOUT_TASK_PRIORITY,
      APP_STACK_SIZE,
//      USER_TASK_STACKSIZE,
};


void SSSCreateOSDataStructs(void)	// called from iniche_init.c
{
}

/* This function creates tasks used in this example which do not use sockets.
 * Tasks which use Interniche sockets must be created with TK_NEWTASK.
 */
 
void SSSCreateTasks(void)	// called from iniche_init.c
{
	TK_NEWTASK(&ReadoutTask);
}

/*
 * SSSSimpleSocketServerTask()
 * 
 * This MicroC/OS-II thread spins forever after first establishing a listening
 * socket for our sss connection, binding it, and listening. Once setup,
 * it perpetually waits for incoming data to either the listening socket, or
 * (if a connection is active), the sss data socket. When data arrives, 
 * the approrpriate routine is called to either accept/reject a connection 
 * request, or process incoming data.
 */
void SSSSimpleSocketServerTask()
{
//  int fd_listen, max_socket;
  int max_socket;
  struct sockaddr_in addr;
  static SSSConn conn;
  fd_set readfds;
  
  /*
   * Sockets primer...
   * The socket() call creates an endpoint for TCP of UDP communication. It 
   * returns a descriptor (similar to a file descriptor) that we call fd_listen,
   * or, "the socket we're listening on for connection requests" in our sss
   * server example.
   *
   * Traditionally, in the Sockets API, PF_INET and AF_INET is used for the 
   * protocol and address families respectively. However, there is usually only
   * 1 address per protocol family. Thus PF_INET and AF_INET can be interchanged.
   * In the case of NicheStack, only the use of AF_INET is supported.
   * PF_INET is not supported in NicheStack.
   */ 
  if ((fd_listen = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0)
  {
    alt_NetworkErrorHandler(EXPANDED_DIAGNOSIS_CODE,"[sss_task] Socket creation failed");
  }
  
  /*
   * Sockets primer, continued...
   * Calling bind() associates a socket created with socket() to a particular IP
   * port and incoming address. In this case we're binding to SSS_PORT and to
   * INADDR_ANY address (allowing anyone to connect to us. Bind may fail for 
   * various reasons, but the most common is that some other socket is bound to
   * the port we're requesting. 
   */ 
  bzero(&addr, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_port = htons(SSS_PORT);
  addr.sin_addr.s_addr = htonl(INADDR_ANY);
  if ((bind(fd_listen,(struct sockaddr *)&addr,sizeof(addr))) < 0)
  {
    alt_NetworkErrorHandler(EXPANDED_DIAGNOSIS_CODE,"[sss_task] Bind failed");
  }
  sss_udp_process();
}


void sss_udp_process(void)
{
   int bytes_to_process;
   INT8U *tx_wr_pos;
   INT8U *rx_pos;
   static char ps[32];
   static INT32U p1;
   static INT32U p2[1024];
   static int i, j;
   int cliaddr_len, datalen;

	INT8U error_code;
printf("entering sss_udp_process()\n");

  bzero(&cliaddr, sizeof(cliaddr));
  cliaddr.sin_family = AF_INET;
  cliaddr.sin_port = htons(SSS_PORT);

       /*
	* "SSSCommand" is declared static so that the data will reside
	* in the BSS segment. This is done because a pointer to the data in
	* SSSCommand
	* will be passed via SSSLedCommandQ to the LEDManagementTask.
	* Therefore SSSCommand cannot be placed on the stack of the
	* SSSSimpleSocketServerTask, since the LEDManagementTask does not
	* have access to the stack of the SSSSimpleSocketServerTask.
	*/
	static INT32U SSSCommand;
	while(1)
	{
           tx_wr_pos = tx_buf;
           rx_pos = rx_buf;
	   SSSCommand = CMD_LEDS_BIT_0_TOGGLE;
	   p1 = 0;
	   memset(p2, 0, sizeof(p2));

	   cliaddr_len = sizeof(cliaddr);
	   bytes_to_process = recvfrom(fd_listen, rx_buf, SSS_RX_BUF_SIZE, 0, (struct sockaddr*)&cliaddr, &cliaddr_len);
           rx_buf[bytes_to_process] = 0;
// printf("sss_udp_process(): bytes_to_process = %d\n", bytes_to_process);

	   while(bytes_to_process--)
	   {
		  SSSCommand = toupper(*(rx_pos++));
// printf("sss_udp_process(): rx_buf = '%s'\n", rx_buf);

		  if(SSSCommand >= ' ' && SSSCommand <= '~')
		  {
//			 tx_wr_pos += sprintf(tx_wr_pos, "ACK %c.\n", (char)SSSCommand);
			 if (SSSCommand == CMD_QUIT)
			 {
//				tx_wr_pos += sprintf(tx_wr_pos,"Terminating connection.\n\n\r");
//				return;
			 }
			 else
			 {
	// extract p1 parameter (always present, if unused == '0')
				 rx_pos++;	// skip blank space
				 bytes_to_process--;
				 j = 0;
				 while( *(rx_pos) != ' ' && bytes_to_process > 0 && j < 32 )
				 {
					 ps[j++] = *(rx_pos++);
					 bytes_to_process--;
				 }
				 if( bytes_to_process == 0 )
					 j--;
				 ps[j] = 0;
				 atoul(ps,0,0,&p1);
// printf("j = %d, bytes_to_process = %d, ps = %s, p1 = 0x%08X.\n", j, bytes_to_process, ps, p1);
// printf("cmd = '%c'\n", SSSCommand);
	// extract p2[] parameters if any
				 if( SSSCommand == WRITE_CFG_FIFO )
				 {
					 for(i=0;i<p1;i++)
					 {
						 rx_pos++;
						 bytes_to_process--;
						 j = 0;
						 while( *(rx_pos) != ' ' && bytes_to_process > 0 && j < 32 )
						 {
							 ps[j++] = *(rx_pos++);
							 bytes_to_process--;
						 }
						 if( bytes_to_process == 0 )
							 j--;
						 ps[j] = 0;
						 atoul(ps,0,0,&p2[i]);
// printf("j = %d, bytes_to_process = %d, ps = %s, p2[%d] = 0x%08X.\n", j, bytes_to_process, ps, i, p2[i]);
					 }
				 }

				datalen = 0;

				 switch( SSSCommand ) {
					 case READ_DATA_FIFO_0: ReadDataFifo(0, p1, databuf);
// printf("sss_udp_process(): READ_DATA_FIFO_0\n");
						datalen = p1;
//						 for(i=0;i<p1;i++)
//							databuf[i] = p2[i];
						break;
					 case READ_DATA_FIFO_1: ReadDataFifo(1, p1, databuf);
// printf("sss_udp_process(): READ_DATA_FIFO_1\n");
						datalen = p1;
//						 for(i=0;i<p1;i++)
//							databuf[i] = htonl(p2[i]);
						break;
					 case READ_DATA_FIFO_2: ReadDataFifo(2, p1, databuf);
// printf("sss_udp_process(): READ_DATA_FIFO_2\n");
						datalen = p1;
//						 for(i=0;i<p1;i++)
//							databuf[i] = htonl(p2[i]);
						break;
					 case READ_DATA_FIFO_3: ReadDataFifo(3, p1, databuf);
// printf("sss_udp_process(): READ_DATA_FIFO_3\n");
						datalen = p1;
//						 for(i=0;i<p1;i++)
//							databuf[i] = htonl(p2[i]);
						break;
					 case READ_DATA_FIFO_4: ReadDataFifo(4, p1, databuf);
// printf("sss_udp_process(): READ_DATA_FIFO_4\n");
						datalen = p1;
//						 for(i=0;i<p1;i++)
//							databuf[i] = htonl(p2[i]);
						break;
					 case READ_DATA_FIFO_5: ReadDataFifo(5, p1, databuf);
// printf("sss_udp_process(): READ_DATA_FIFO_5\n");
						datalen = p1;
//						 for(i=0;i<p1;i++)
//							databuf[i] = htonl(p2[i]);
						break;
					 case READ_DATA_FIFO_STATUS: ReadDataFifoStatus(&p1);
						datalen = 1;
// printf("sss_udp_process(): READ_DATA_FIFO_STATUS: val = 0x%08X\n", p1);
						databuf[0] = htonl(p1);
						break;
					 case READ_CFG_FIFO: ReadCfgFifo(p1, p2);
// printf("sss_udp_process(): READ_CFG_FIFO\n");
						datalen = p1;
						 for(i=0;i<p1;i++)
							databuf[i] = htonl(p2[i]);
						break;
					 case WRITE_CFG_FIFO: WriteCfgFifo(p1, p2);
//						tx_wr_pos += sprintf(tx_wr_pos, "ACK %c", (char)SSSCommand);
// printf("sss_udp_process(): WRITE_CFG_FIFO\n");
						break;
					 case WRITE_NBIT_REG: WriteNbitReg(p1);
//						tx_wr_pos += sprintf(tx_wr_pos, "ACK %c", (char)SSSCommand);
// printf("sss_udp_process(): WRITE_NBIT_REG: val = 0x%08X\n", p1);
						break;
					 case WRITE_COMMAND_REG: WriteCommandReg(p1);
//						tx_wr_pos += sprintf(tx_wr_pos, "ACK %c", (char)SSSCommand);
// printf("sss_udp_process(): WRITE_COMMAND_REG: val = 0x%08X\n", p1);
						break;
					 case READ_STATUS_REG: ReadStatusReg(&p1);
// printf("sss_udp_process(): READ_STATUS_REG: val = 0x%08X\n", p1);
//						datalen = 1;	// Original
						datalen = 5;	// New
						databuf[0] = htonl(p1);
						ReadDataFifoStatus(&p1);
						databuf[1] = htonl(p1);
						ReadDummyReg(13, &p2[0]);
						databuf[2] = htonl(p2[0]);
						ReadDummyReg(14, &p2[0]);
						databuf[3] = htonl(p2[0]);
						ReadDummyReg(15, &p2[0]);
						databuf[4] = htonl(p2[0]);
						break;
					 case READ_NBIT_REG: ReadNbitReg(&p1);
// printf("sss_udp_process(): READ_NBIT_REG: val = 0x%08X\n", p1);
						tx_wr_pos += sprintf(tx_wr_pos,"0x%08X", p1);
						break;
					 case READ_COMMAND_REG: ReadCommandReg(&p1);
// printf("sss_udp_process(): READ_COMMAND_REG: val = 0x%08X\n", p1);
						tx_wr_pos += sprintf(tx_wr_pos,"0x%08X", p1);
						break;
					 case READ_DUMMY_REG: ReadDummyReg(p1, &p2[0]);
						datalen = 1;
//printf("sss_udp_process(): READ_RUMMY_REG: x = %d, val = 0x%08X\n", p1, p2[0]);
						databuf[0] = htonl(p2[0]);
						 break;
/*
					 case CLIENT_NET_ADDR: //send_addr.sin_addr.s_addr = inet_addr(ps);
//						tx_wr_pos += sprintf(tx_wr_pos, "ACK %c", (char)SSSCommand);
// printf("sss_udp_process(): WRITE_NBIT_REG: val = 0x%08X\n", p1);
						break;
*/
					 default: tx_wr_pos += sprintf(tx_wr_pos,"'%c' Command not found.\n", SSSCommand); break;
				 }
			 }
		  }
	   }
//printf("sss_udp_process(): tx_buf = '%s'\n", tx_buf);
//	  sendto(fd_listen, tx_buf, strlen(tx_buf), 0, &send_addr, sizeof(struct sockaddr_in));
	if( datalen )
		sendto(fd_listen, databuf, datalen*4, 0, &cliaddr, sizeof(cliaddr));
	if( strlen(tx_buf) )
		sendto(fd_listen, tx_buf, strlen(tx_buf), 0, &cliaddr, sizeof(cliaddr));

//	DataFifoReadoutTask();

	}
  return;
}

INT32U xx = 0;
void DataFifoReadoutTask(void *dummy)
{
	int i, j;
	INT32U ndata, cmd, yy;

	while(1)
	{
		ReadCommandReg(&cmd);
//ReadDummyReg(13, &yy);
//if( (xx++ % 100) == 0 ) printf("DataFifoReadout() started! cmd = 0x%08X, ndata = %d\n",cmd,yy);
		for(i=0; i<6; i++)
		{
			if( cmd & (0x1000000 << i) )	// Readout enabled on chip i
			{
				switch( i )
				{
					case 0: ReadDummyReg(13, &ndata); ndata &= 0xFFFF; break;
					case 1: ReadDummyReg(13, &ndata); ndata >>= 16; break;
					case 2: ReadDummyReg(14, &ndata); ndata &= 0xFFFF; break;
					case 3: ReadDummyReg(14, &ndata); ndata >>= 16; break;
					case 4: ReadDummyReg(15, &ndata); ndata &= 0xFFFF; break;
					case 5: ReadDummyReg(15, &ndata); ndata >>= 16; break;
				}
/*
if( ndata > 0 )
{
printf("  DataFifoReadout(): i = %d, ndata = %d\n", i, ndata);
ReadDummyReg(6, &xx); printf("  DataFifoReadout(): fifo_status = 0x%08x\n", xx);
ReadDummyReg(12, &xx); printf("  DataFifoReadout(): fpga_status = 0x%08x\n", xx);
ReadDummyReg(13, &xx); printf("  DataFifoReadout(): used_words[0] = %d\n", xx&0xFFFF);
}
*/
/*
if( (xx++ % 100) == 0 )
{
ReadDummyReg(10, &ndata); printf("  DataFifoReadout(): i = %d, ndata = %x\n", i, ndata);
ReadDummyReg(13, &ndata); printf("  DataFifoReadout(): i = %d, ndata = %d\n", i, ndata);
ReadDummyReg(14, &ndata); printf("  DataFifoReadout(): i = %d, ndata = %d\n", i, ndata);
ReadDummyReg(15, &ndata); printf("  DataFifoReadout(): i = %d, ndata = %d\n", i, ndata);
printf("DataFifoReadout(): i = %d, ndata = %d\n", i, ndata);
}
*/
				if( ndata > 255 )
				{
					ndata = 256;
					databuf[0] = htonl(0x43485000 + i);	// 'CHPi'
					ReadDataFifo(i, ndata-1, databuf+1);	// to avoid overflow
//					for(j=0; j<ndata; j++)
//						databuf[j] = htonl(databuf[j]);
					sendto(fd_listen, databuf, ndata*4, 0, &cliaddr, sizeof(cliaddr));
//printf("DataFifoReadout(): sending %d data\n", ndata);
				}
			}
		}
		OSTimeDly(1);
	}
}


/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2009 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
* Altera does not recommend, suggest or require that this reference design    *
* file be used in conjunction or combination with any other product.          *
******************************************************************************/
