configuration RemoteControlC{
}

implementation{
    components MainC;
    components RemoteControlP as App;
    components ActiveMessageC;
    components new AMSenderC(AM_BLINKTORADIO);
    //Rocker and Button
    components RockerC;
    components ButtonGroupC;
    components LedsC;

    //system
    App.Boot -> MainC.Boot;
    App.Leds -> LedsC;

    //radio
    App.Packet -> AMSenderC;
    App.AMPacket -> AMSenderC;
    App.AMSend -> AMSenderC;
    App.AMControl -> ActiveMessageC;

    //rocker & button
    App.RockerPosition -> RockerC.RockerPosition;
    App.ButtonGroup -> ButtonGroupC.ButtonGroup;
}