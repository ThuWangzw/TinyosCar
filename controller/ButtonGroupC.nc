configuration ButtonGroupC{
    provides interface ButtonGroup;
}
implementation {
    components ButtonGroupP;
    components HplMsp430GeneralIOC;
    components new TimerMilliC() as MTimer;  

    ButtonGroup = ButtonGroupP;
    ButtonGroupP.PortA -> HplMsp430GeneralIOC.Port60;
    ButtonGroupP.PortB -> HplMsp430GeneralIOC.Port21;
    ButtonGroupP.PortC -> HplMsp430GeneralIOC.Port61;
    ButtonGroupP.PortD -> HplMsp430GeneralIOC.Port23;
    ButtonGroupP.PortE -> HplMsp430GeneralIOC.Port62;
    ButtonGroupP.PortF -> HplMsp430GeneralIOC.Port26;
    ButtonGroupP.Timer <- MTimer.Timer;
}