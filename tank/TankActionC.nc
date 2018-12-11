#include "TankMain.h"

configuration TankActionC {
  provides interface TankAction;
}
implementation {
  components HplMsp430Usart0C as HplUsart;
  components new Msp430Uart0C() as Uart;
  components LedsC;
  components TankActionP;
  TankAction = TankActionP;

  TankActionP.HplMsp430Usart -> HplUsart;
  TankActionP.Resource -> Uart;
  TankActionP.Leds -> LedsC;
}
