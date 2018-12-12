configuration RemoteControlC{
}

implementation{
    components MainC;
    components RemoteControlC as App;
    components ActiveMessageC;
    components new AMSenderC(AM_BLINKTORADIO);
    //Rocker and Button
    components RockerP;

    //system
    App.Boot -> MainC.Boot;

    //radio
    App.Packet -> AMSenderC;
    App.AMPacket -> AMSenderC;
    App.AMSend -> AMSenderC;
    App.AMControl -> ActiveMessageC;

    //rocker & button
    App.RockerPosition -> RockerP.RockerPosition;
}