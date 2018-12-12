interface RockerPosition
{
    command error_t getPos();
    command error_t start();
    event void processPos(uint16_t posx,uint16_t posy);
}