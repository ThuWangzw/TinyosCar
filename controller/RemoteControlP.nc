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
        LedsBlink(1);
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

    //rocker needed variables
    uint16_t min_speed = 300,
             delta_speed = 300,
             speed_theshold = 50;
        
    uint16_t min_x = 0,
             max_x = 0x1000,
             min_y = 0,
             max_y = 0x1000;

    uint8_t last_type = 0;
    uint8_t current_type = 0;
    uint16_t last_speed = 0;
    uint16_t current_speed = 0;
    double pi = 3.14159265;

    //Rocker event
    event void RockerPosition.processPos(uint16_t posx,uint16_t posy){

        uint16_t cx = ( min_x + max_x ) / 2,
                 cy = ( min_y + max_y ) / 2,
                 dx = max_x - min_x,
                 dy = max_y - min_y,
                 min_r = dx * 0.3 * 0.5;


        double angle = atan2(posy - cy,posx - cx),
               radius = sqrt(( posy - cy)*(posy - cy) + (posx - cx)*(posx - cx));
        
        current_type = 0;
        current_speed = 0;
        if(radius < min_r){
            LedsBlink(6);
            current_type = 6;
        }
        else{
            if( angle >= pi * 0.25 && angle < pi * 0.75){
                current_type = 2;
                LedsBlink(2);
                current_speed = min_speed + radius / dx * 2 * delta_speed;
            }
            else if (angle >= - pi * 0.25 && angle < pi * 0.25){
                LedsBlink(5);
                current_type = 5;
            }
                
            else if (angle >= - pi * 0.75 && angle < -pi * 0.25){
                LedsBlink(3);
                current_type = 3;
                current_speed = min_speed + radius / dx * 2 * delta_speed;
            }
            else{
                LedsBlink(4);
                current_type = 4;
            }
                
        }   

        if (current_type == last_type && abs(current_speed - last_speed) < speed_theshold)
            return;
        last_type = current_type;
        last_speed = current_speed;
        send_message(current_type,current_speed);
    }

    //Button event
    //event void ButtonGroup.startDone(error_t err){}
    //event void ButtonGroup.stopDone(error_t err){}

    event void ButtonGroup.btnPushed(uint16_t btn) {
        switch (btn) {
            case 1:
                //LedsBlink(1);
                //send_message(1, 500);
                break;
            case 2:
                //LedsBlink(2);
                //send_message(1, -500);
                break;
            case 3:
                //LedsBlink(3);
                //send_message(7, 500);
                break;
            case 4:
                //LedsBlink(4);
                //send_message(7, -500);
                break;
            case 5:
                //LedsBlink(5);
                //send_message(8, 500);
                break;
            case 6:
                //LedsBlink(6 );
                //send_message(8, -500);
                break;
        }
    }

}