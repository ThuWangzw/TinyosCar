#ifndef MESSAGE_H
#define MESSAGE_H

typedef nx_struct Message{
	nx_uint16_t nodeid;
	nx_uint8_t type;
	nx_uint16_t data;
}Message;

enum{
	AM_BLINKTORADIO = 6
}
#endif