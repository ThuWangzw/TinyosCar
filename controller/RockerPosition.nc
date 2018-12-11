interface RockerPosition
{
    command error_t getPos();
    event void processPos(uint16_t posx,uint16_t posy);
}