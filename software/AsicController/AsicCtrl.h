
// Commands to be implemented
#define READ_DATA_FIFO_0		'0'
#define READ_DATA_FIFO_1		'1'
#define READ_DATA_FIFO_2		'2'
#define READ_DATA_FIFO_3		'3'
#define READ_DATA_FIFO_4		'4'
#define READ_DATA_FIFO_5		'5'
#define READ_DATA_FIFO_STATUS	'6'
#define READ_CFG_FIFO			'8'
#define WRITE_CFG_FIFO			'9'
#define WRITE_NBIT_REG			'A'
#define WRITE_COMMAND_REG		'B'
#define READ_STATUS_REG			'C'
#define READ_NBIT_REG			'D'
#define READ_COMMAND_REG		'E'
#define READ_DUMMY_REG			'F'
#define COMMAND_QUIT			'Q'
#define CLIENT_NET_ADDR			'Z'

#define DATA_BUF_SIZE  2048

// function prototypes
int WriteCommandReg(INT32U val);
int WriteNbitReg(INT32U val);
int WriteCfgFifo(int ndata, INT32U *val);
int ReadDummyReg(int x, INT32U *val);
int ReadCommandReg(INT32U *val);
int ReadNbitReg(INT32U *val);
int ReadCfgFifo(int ndata, INT32U *val);
int ReadStatusReg(INT32U *val);
int ReadDataFifoStatus(INT32U *val);
int ReadDataFifo(int ch, int ndata, INT32U *val);

