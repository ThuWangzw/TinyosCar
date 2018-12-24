module ButtonGroupP
{
    provides interface ButtonGroup;
    uses {
        interface HplMsp430GeneralIO as PortA;
        interface HplMsp430GeneralIO as PortB;
        interface HplMsp430GeneralIO as PortC;
        interface HplMsp430GeneralIO as PortD;
        interface HplMsp430GeneralIO as PortE;
        interface HplMsp430GeneralIO as PortF;
        interface Timer<TMilli> as Timer;  
    }
}
implementation {
    error_t err;
    uint16_t current = 0;
    uint16_t previous = 0;
    bool valA, valB, valC, valD, valE, valF;
    // bool old_valA, old_valB, old_valC, old_valD, old_valE, old_valF;

    command error_t ButtonGroup.start() {
        current = 0;
        previous = 0;
        call PortA.clr(); //make all to low
        call PortA.makeInput();
        call PortB.clr();
        call PortB.makeInput();
        call PortC.clr();
        call PortC.makeInput();
        call PortD.clr();
        call PortD.makeInput();
        call PortE.clr();
        call PortE.makeInput();
        call PortF.clr();
        call PortF.makeInput();
        valA = FALSE; valB = FALSE; valC = FALSE;
        valD = FALSE; valE = FALSE; valF = FALSE;
        // #ifdef SAMPLE_FREQUENCY
        // call Timer.startPeriodic(SAMPLE_FREQUENCY);
        // #else
        call Timer.startPeriodic(200);
        // #endif
    }

    event void Timer.fired(){
        call ButtonGroup.get();
    }

    //假设：按键按下，则给出high，松开给出low
    command void ButtonGroup.get() {
        valA = call PortA.get();
        valB = call PortB.get();
        valC = call PortC.get();
        valD = call PortD.get();
        valE = call PortE.get();
        valF = call PortF.get();
        
        if (!valA && !valB) current = 4;
        else if (!valA) current = 1;
        else if (!valB) current = 2;
        else if (!valC) current = 3;
        else if (!valE) current = 5;
        else if (!valF) current = 6;
        else current = 0;
        
        // // 只有大于0才给
        if (current > 0 && current < 7)
            signal ButtonGroup.btnPushed(current);
        
        // 保存旧值
        // old_valA = valA; old_valB = valB; old_valC = valC;
        // old_valD = valD; old_valE = valE; old_valF = valF;
    }
}