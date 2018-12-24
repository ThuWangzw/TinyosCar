 #include <Timer.h>
 #include "BlinkToRadio.h"
 #include "message.h"
 module BlinkToRadioC {
   uses interface Packet;
   uses interface AMPacket;
   uses interface AMSend;
   uses interface SplitControl as AMControl;
   uses interface Boot;
   uses interface Leds;
   uses interface Timer<TMilli> as Timer0;
 }
 implementation {
   uint16_t counter = 0;
   uint32_t data = 0;
   bool busy = FALSE;
   message_t pkt;
   uint8_t typearray[] = {2,3,5,4,6,1,1,7,7,8,8,1,7,8};
   uint8_t dataarray[] = {500,500,500,500,500,2000,3000,2000,3000,2000,3000,0,0,0};
   uint16_t len = 14;
typedef nx_struct BlinkToRadioMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
} BlinkToRadioMsg;
   event void Boot.booted() {
    call AMControl.start();
  }
   event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }
 
   event void Timer0.fired() {
     counter = (counter+1)%len;
     
     call Leds.set(typearray[counter]);
     if (!busy) {
    Message* btrpkt = (Message*)(call Packet.getPayload(&pkt, sizeof (Message)));
    btrpkt->nodeid = TOS_NODE_ID;
    btrpkt->type = typearray[counter];
    btrpkt->data = dataarray[counter];
    if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(Message)) == SUCCESS) {
      busy = TRUE;
    }
  }
   }
event void AMSend.sendDone(message_t* msg, error_t error) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }
 }
