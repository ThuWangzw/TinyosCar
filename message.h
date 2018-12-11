#ifndef MESSAGE_H
#define MESSAGE_H

typedef nx_struct Message{
	nx_uint16_t nodeid;
	nx_uint8_t type;
	nx_uint16_t data;
}Message;

enum{
	AM_BLINKTORADIO = 6
};

#define SAMPLE_FREQUENCY 200
#define SENDER_NODE_ID 1
#define RECEIVER_NODE_ID 2

#endif