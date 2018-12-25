#include <math.h>
#include "../message.h"

module RemoteControlP{
    uses interface Boot;   

    uses interface RockerPosition;
    uses interface ButtonGroup;

    uses interface Packet;
    uses interface AMPacket;
    uses interface AMSend;
    uses interface SplitControl as AMControl;
    uses interface Leds;
}

implementation{
    bool is_transfer = FALSE;
    message_t pkt;
    void send_message(uint8_t m_type, uint16_t m_data){
        if(!is_transfer){
            Message *msgpkt = (Message *)(call Packet.getPayload(&pkt,sizeof(Message)));
            msgpkt -> nodeid = TOS_NODE_ID;
            msgpkt -> type = m_type;
            msgpkt -> data = m_data;
            if(call AMSend.send(AM_BROADCAST_ADDR,&pkt,sizeof(Message)) == SUCCESS)
                is_transfer = TRUE;
        }
    }

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

    event void Boot.booted(){
        LedsBlink(7);
        call AMControl.start();
    }

    event void AMSend.sendDone(message_t * m, error_t error){
        if( &pkt == m )
            is_transfer = FALSE;
    }

    event void AMControl.startDone(error_t error){
        if (error == SUCCESS){
            //radio initialization succeed
            //entrance of the Rocker & Button
            call RockerPosition.start();
            call ButtonGroup.start();
            //send_message(6, 500);
        }
        else{
            call AMControl.start();
        }
    }

    event void AMControl.stopDone(error_t error){

    }
        
    uint16_t min_x = 1200,
             max_x = 2400,
             min_y = 1000,
             max_y = 4000;

    uint8_t last_type = 0;
    uint8_t current_type = 0;
    uint16_t current_speed = 500;

    //Rocker event
    event void RockerPosition.processPos(uint16_t posx,uint16_t posy){
        
        current_type = 0;
        if( posy > max_y){
            current_type = 3;
            LedsBlink(3);
        }
        else if( posy < min_y){
            current_type = 2;
            LedsBlink(2);
        }
        else if (posx < min_x){
            current_type = 4;
            LedsBlink(4);
        }
        else if (posx > max_x){
            current_type = 5;
            LedsBlink(5);
        }
        else{
            current_type = 6;
            LedsBlink(6);
        }   

        if (current_type == last_type)
            return;
        last_type = current_type;
        send_message(current_type,current_speed);
    }

    //Button event
    //event void ButtonGroup.startDone(error_t err){}
    //event void ButtonGroup.stopDone(error_t err){}

    event void ButtonGroup.btnPushed(uint16_t btn) {
        switch (btn) {
            case 1:
                LedsBlink(1);
                send_message(1, 500);
                break;
            case 2:
                LedsBlink(1);
                send_message(1, -500);
                break;
            case 3:
                LedsBlink(7);
                send_message(7, 500);
                break;
            case 4:
                LedsBlink(7);
                send_message(7, -500);
                break;
            case 5:
                LedsBlink(8);
                send_message(8, 500);
                break;
            case 6:
                LedsBlink(8);
                send_message(8, -500);
                break;
            default:
                break;
        }
    }

}