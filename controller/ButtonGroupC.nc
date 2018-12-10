configuration ButtonGroupC{
    provides interface ButtonGroup;
}
implementation {
    components ButtonGroupP;
    components HplMsp430GeneralIOC;

    ButtonGroup = ButtonGroupP;
    ButtonGroup.PortA -> HplMsp430GeneralIOC.Port60;
    ButtonGroup.PortB -> HplMsp430GeneralIOC.Port21;
    ButtonGroup.PortC -> HplMsp430GeneralIOC.Port61;
    ButtonGroup.PortD -> HplMsp430GeneralIOC.Port23;
    ButtonGroup.PortE -> HplMsp430GeneralIOC.Port62;
    ButtonGroup.PortF -> HplMsp430GeneralIOC.Port26;
}