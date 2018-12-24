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
		utxe : 1,
		urxe : 1,
		ubr : UBR_1MHZ_115200,
		umctl : UMCTL_1MHZ_115200,
		ssel : 0x02,
		pena : 0,
		pev : 0,
		spb : 0,
		clen : 1,
		listen : 0,
		mm : 0,
		ckpl : 0,
		urxse : 0,
		urxeie : 0,
		urxwie : 0
	}};
	nx_uint16_t angle[3]={3000,3000,3000};
        void LedsBlink(nx_uint8_t blinknum){
          nx_uint8_t one;
          nx_uint8_t two;
          nx_uint8_t three;
          one = (blinknum)&(0x01);
          two = (blinknum>>1)&(0x01);
          three = (blinknum>>2)&(0x01);
          if(one==0x01){
            call Leds.led0On();
          }
          else{
            call Leds.led0Off();
          }
          if(two==0x01){
            call Leds.led1On();
          }
          else{
            call Leds.led1Off();
          }
          if(three==0x01){
            call Leds.led2On();
          }
          else{
            call Leds.led2Off();
          }
        }        
	void UpdateSteer(nx_uint8_t type, nx_int16_t delta){
	  if(type==0x01){
		angle[0] = (nx_uint16_t)((nx_int16_t)angle[0]+delta);
		onecom[3] = (angle[0]>>8)&(0xF);
		onecom[4] = (angle[0])&(0xF);
	  }
	  else if(type>0x06){
		angle[type-6] = (nx_uint16_t)((nx_int16_t)angle[type-6]+delta);
		onecom[3] = (nx_uint8_t)(angle[type-6]>>8)&(0xF);
		onecom[4] = (nx_uint8_t)(angle[type-6])&(0xF);
  	  }
        }

        command void TankAction.Start(){

        }
	command error_t TankAction.action(nx_uint8_t type, nx_uint16_t data){
	  if(busy) return FAIL;
	  busy = TRUE;
	  onecom[TYPE_POS] = type;
	  onecom[COM_POS1] = (data>>8)|(0xF);
	  onecom[COM_POS2] = (data)|(0xF);
	  UpdateSteer(type,(nx_int16_t)data);
	  call Resource.request();
	  return SUCCESS;
	}

	void shitfunc(nx_uint16_t j){
	  while(!call HplMsp430Usart.isTxEmpty()){}
		call HplMsp430Usart.tx(onecom[j]);
	}
	
	event void Resource.granted(){
	  call HplMsp430Usart.setModeUart(&uart_config);
          call HplMsp430Usart.enableUart();
	  for(i=0; i<8; i++){
	    shitfunc(i);
	  }
	  while(!call HplMsp430Usart.isTxEmpty()){}
	  call Resource.release();
	  busy = FALSE;
          LedsBlink(onecom[TYPE_POS]);
	  signal TankAction.ActionDone();
	}
	
	
}
