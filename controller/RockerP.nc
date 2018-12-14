#include <Msp430Adc12.h>
#include <Timer.h>
#include <TinyError.h>
#include "../message.h"

module RockerP
{
  provides interface RockerPosition;
  provides interface AdcConfigure<const msp430adc12_channel_config_t*> as ConfigX;
  provides interface AdcConfigure<const msp430adc12_channel_config_t*> as ConfigY;

  uses interface Read<uint16_t> as ReadX;
  uses interface Read<uint16_t> as ReadY;
  uses interface Timer<TMilli> as Timer;  
}
implementation
{
  uint16_t posx = 0,posy = 0;
  bool readx = FALSE,ready = FALSE;

  command error_t RockerPosition.start(){
    #ifdef SAMPLE_FREQUENCY
      call Timer.startPeriodic(SAMPLE_FREQUENCY);
    #else
      call Timer.startPeriodic(100);
    #endif
  }
  
  command error_t RockerPosition.getPos(){
    if ((call ReadX.read() != SUCCESS ) || (call ReadY.read()) != SUCCESS)
      return FAIL;
    return SUCCESS;
  }

  event void Timer.fired(){
    call RockerPosition.getPos();
  }

  event void ReadX.readDone(error_t result,uint16_t val){
      readx = TRUE;
      if (result != SUCCESS){
        if (ready == TRUE){
            readx = FALSE;
            ready = FALSE;
        }
        return;
      }
      posx = val;
      if (ready){
        //signal RockerPosition.processPos(posx,posy);
        readx = FALSE;
        ready = FALSE;
      }
  }

  event void ReadY.readDone(error_t result,uint16_t val){
      ready = TRUE;
      if (result != SUCCESS){
        if(readx == TRUE){
          readx = FALSE;
          ready = FALSE;
        }
        return;
      }
      posy = val;
      if (readx){
        //signal RockerPosition.processPos(posx,posy);
        readx = FALSE;
        ready = FALSE;
      }
  }

  const msp430adc12_channel_config_t config1 = {
    inch: INPUT_CHANNEL_A6,
		sref: REFERENCE_VREFplus_AVss,
		ref2_5v: REFVOLT_LEVEL_2_5,
		adc12ssel: SHT_SOURCE_ACLK,
		adc12div: SHT_CLOCK_DIV_1,
		sht: SAMPLE_HOLD_4_CYCLES,
		sampcon_ssel: SAMPCON_SOURCE_SMCLK,
    sampcon_id: SAMPCON_CLOCK_DIV_1
  };

  const msp430adc12_channel_config_t config2 = {
    inch: INPUT_CHANNEL_A7,
		sref: REFERENCE_VREFplus_AVss,
		ref2_5v: REFVOLT_LEVEL_2_5,
		adc12ssel: SHT_SOURCE_ACLK,
		adc12div: SHT_CLOCK_DIV_1,
		sht: SAMPLE_HOLD_4_CYCLES,
		sampcon_ssel: SAMPCON_SOURCE_SMCLK,
    sampcon_id: SAMPCON_CLOCK_DIV_1
  };

  async command const msp430adc12_channel_config_t* ConfigX.getConfiguration(){
    return &config1;
  }
    
  async command const msp430adc12_channel_config_t* ConfigY.getConfiguration(){
    return &config2;
  }
}