#include <Timer.h>
#include "TankMain.h"

configuration TankMainAppC {
}
implementation {
  components MainC;
  components LedsC;
  components TankMainC as App;
  components ActiveMessageC;
  components new AMReceiverC(AM_BLINKTORADIO);
  components TankActionC as tank;
  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.AMControl -> ActiveMessageC;
  App.Receive -> AMReceiverC;
  App.tank -> tank;
}
