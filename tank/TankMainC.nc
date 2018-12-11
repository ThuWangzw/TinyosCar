#include "TankMain.h"
#include "../message.h"
module TankMainC {
  uses interface Boot;
  uses interface Leds;
  uses interface Receive;
  uses interface SplitControl as AMControl;
  uses interface TankAction as tank;
}
implementation {
  Message Msg[BUFFER_LEN];
  Message *now;
  nx_uint8_t begin;
  nx_uint8_t end;
  bool busy = FALSE;
  event void Boot.booted() {
    begin = 0;
    end = 0;
    call AMControl.start();
  }
  void cpMessage(Message* msg){
    Msg[end].nodeid = msg->nodeid;
	Msg[end].type = msg->type;
	Msg[end].data = msg->data;
	end = (end + 1)%BUFFER_LEN;
  }
  
  event void AMControl.startDone(error_t err) {
    if (err != SUCCESS) {
		call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  void runcommand(){
    if((begin==end)||(busy)) return;//buffer is empty or is sending command
    //run
	busy = TRUE;
	now = Msg+begin;/*
	if(now->type == 0x01){
	  call tank.Steer1(now->value);
	}
	else if(now->type == 0x02){
	  call tank.Forward(now->value);
	}
	else if(now->type == 0x03){
	  call tank.Back(now->value);
	}
	else if(now->type == 0x04){
	  call tank.Left(now->value);
	}
	else if(now->type == 0x05){
	  call tank.Right(now->value);
	}
	else if(now->type == 0x06){
	  call tank.Pause();
	}
	else if(now->type == 0x07){
	  call tank.Steer2(now->value);
	}
	else if(now->type == 0x08){
	  call tank.Steer3(now->value);
	}*/
	call tank.action(now->type, now->data);
	begin = (begin + 1)%BUFFER_LEN;
  }
  
  event void tank.ActionDone(){
    busy = FALSE;
    runcommand();
  }
  
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    if ((len == sizeof(Message))&&((end+1)%BUFFER_LEN!=begin)) {
      Message* btrpkt = (Message*)payload;
      cpMessage(btrpkt);//add to waiting list
      runcommand();
    }
    return msg;
  }
}
