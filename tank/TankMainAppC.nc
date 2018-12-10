#include <Timer.h>
#include "TankMain.h"

configuration BlinkToRadioAppC {
}
implementation {
  components MainC;
  components LedsC;
  components TankMain as App;
  components ActiveMessageC;
  components new AMReceiverC(AM_BLINKTORADIO);
  components TankAction as tank;
  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.AMControl -> ActiveMessageC;
  App.Receive -> AMReceiverC;
  App.tank -> tank;
}