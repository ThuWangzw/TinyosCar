#include <math.h>
#include "../message.h"

module RemoteControlP{
    uses interface Boot;   

    uses interface RockerPosition;

    uses interface Packet;
    uses interface AMPacket;
    uses interface AMSend;
    uses interface SplitControl as AMControl;
}

implementation{
    bool is_transfer = FALSE;
    message_t pkt;
    uint16_t pre_posx = 0,pre_posy = 0;

    void send_message(uint8_t m_type, uint16_t m_data){
        if(!is_transfer){
            Message *msgpkt = (Message *)(call Packet.getPayload(&pkt,sizeof(Message)));
            msgpkt -> nodeid = RECEIVER_NODE_ID;
            msgpkt -> type = m_type;
            msgpkt -> data = m_data;
            if(call AMSend.send(AM_BROADCAST_ADDR,&pkt,sizeof(Message)) == SUCCESS)
                is_transfer = TRUE;
        }
    }

    event void Boot.booted(){
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

        }
        else{
            call AMControl.start();
        }
    }

    event void AMControl.stopDone(error_t error){

    }

    //Rocker event
    event void RockerPosition.processPos(uint16_t posx,uint16_t posy){
        
    }

    //Button event


}