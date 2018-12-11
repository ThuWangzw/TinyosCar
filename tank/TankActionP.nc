#include "TankMain.h"
#include "../message.h"

#define TYPE_POS 2
#define COM_POS1 3
#define COM_POS2 4
module TankActionP {
  provides {
    interface TankAction;
  }
  uses {
    interface Leds;
    interface Resource;
    interface HplMsp430Usart;
  }
}
implementation {
	nx_uint8_t onecom[8]={0x01,0x02,0x00,0x00,0x00,0xFF,0xFF,0x00};
	bool busy = FALSE;
	nx_uint16_t i;
	msp430_uart_union_config_t uart_config = {{
		ubr:UMCTL_1MHZ_115200,
		umctl:UMCTL_1MHZ_115200,
		mm:0,
		listen:0,
		clen:1,
		spb:0,
		pev:0,
		pena:1,//open paritymode
		urxse:0,
		ssel:2,
		ckpl:0,
		urxwie:0,
		urxeie:0,
		utxe:1,
		urxe:1
	}};/*
	command error_t Steer1(uint16_t value){
	  if(busy) return FAIL;
	  onecom[TYPE_POS] = 0x01;
	  onecom[COM_POS1] = (value>>8)|(0xF);
	  onecom[COM_POS2] = (value)|(0xF);
	  call Resource.request();
    }
	
	command error_t Forward(uint16_t value){
	  if(busy) return FAIL;
	  onecom[TYPE_POS] = 0x02;
	  onecom[COM_POS1] = (value>>8)|(0xF);
	  onecom[COM_POS2] = (value)|(0xF);
	  call Resource.request();
	}*/
	command error_t TankAction.action(nx_uint8_t type, nx_uint16_t data){
	  if(busy) return FAIL;
	  busy = TRUE;
	  onecom[TYPE_POS] = type;
	  onecom[COM_POS1] = (data>>8)|(0xF);
	  onecom[COM_POS2] = (data)|(0xF);
	  call Resource.request();
	  return SUCCESS;
	}
	
	event void Resource.granted(){
	  call HplMsp430Usart.setModeUart(&uart_config);
          call HplMsp430Usart.enableUart();
	  for(i=0; i<8; i++){
	    while(!call HplMsp430Usart.isTxEmpty()){}
		call HplMsp430Usart.tx(onecom[i]);
	  }
	  while(!call HplMsp430Usart.isTxEmpty()){}
	  call Resource.release();
	  busy = FALSE;
	  signal TankAction.ActionDone();
	}
	
        command void TankAction.Start(){

        }
}
