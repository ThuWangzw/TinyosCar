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
    bool stopped = false;
    uint16_t current = 0;
    bool valA, valB, valC, valD, valE, valF;

    command error_t ButtonGroup.start() {

        stopped = false;
        current = 0;
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
        #ifdef SAMPLE_FREQUENCY
            return call Timer.startPeriodic(SAMPLE_FREQUENCY);
        #else
            return call Timer.startPeriodic(100);
    }

    event void Timer.fired(){
        call ButtonGroup.get();
    }

    command error_t ButtonGroup.stop() {
        stopped = true;
        signal ButtonGroup.stopDone(SUCCESS);
    }

    //假设：按键按下，则给出high，松开给出low
    command void ButtonGroup.get() {
        if (stopped) return // if already stopped, ignore
        valA = call PortA.get();
        valB = call PortB.get();
        valC = call PortC.get();
        valD = call PortD.get();
        valE = call PortE.get();
        valF = call PortF.get();

        //no btn is pushed
        if (!valA && !valB && !valC && !valD && !valE && !valF)
            current = 0;
        else {
            // have the ability to replace original one when it is pushed
            if (valA && (current != 1)) current = 1;
            else if (valB && (current != 2)) current = 2;
            else if (valC && (current != 3)) current = 3;
            else if (valD && (current != 4)) current = 4;
            else if (valE && (current != 5)) current = 5;
            else if (valF && (current != 6)) current = 6;
            signal ButtonGroup.btnPushed(current);
        }
    }
}