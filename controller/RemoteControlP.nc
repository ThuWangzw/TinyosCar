#include <math.h>

module RemoteControlP(){
    uses{
        interface Boot;
        
        //Rocker & Button
        interface RockerPostion as Rocker;

        //mote-mote sending interfaces
        interface Packet;
        interface AMPacket;
        interface AMSend;
        interface SplitControl as AMControl;
    }
}

implementation{
    bool is_transfer = false;
    message_t pkt;
    uint16_t pre_posx = 0,pre_posy = 0;

    void send_message(struct Message tmp){
        if(!is_transfer){
            Message *msgpkt = (Message *)(call Packet.getPayLoad(&pkt,sizeof(Message)));
            msgpkt -> nodeid = tmp.nodeid;
            msgpkt -> type = tmp.type;
            msgpkt -> data = tmp.data;
            if(call AMSend.send(AM_BROADCAST_ADDR,&pkt,sizeof(Message)) == SUCCESS)
                is_transfer = true;
        }
    }

    event void Boot.booted(){
        call AMControl.start();
    }

    event void AMSend.sendDone(message_t * m, error_t error){
        if( &msg == m )
            is_transfer = false;
    }

    event void AMControl.startDone(error_t error){
        if (error == SUCCESS){
            //radio initialization succeed
            //entrance of the Rocker & Button
            call Rocker.start();

        }
        else{
            call AMControl.start();
        }
    }

    //Rocker event
    event void Rocker.processPos(uint16_t posx,uint16_t posy){
        
    }

    //Button event


}