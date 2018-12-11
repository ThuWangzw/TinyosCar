configuration RockerC
{
  provides{
    interface RockerPosition;
  }
}
implementation
{
  components RockerP;
  components new AdcReadClientC() as AdcX;
  components new AdcReadClientC() as AdcY;
  components new TimerMilliC() as MTimer;  
  RockerPosition = RockerP.RockerPosition;
  RockerP.ReadX -> AdcX.Read;
  RockerP.ReadY -> AdcY.Read;
  RockerP.ConfigX <- AdcX.AdcConfigure;
  RockerP.ConfigY <- AdcY.AdcConfigure;
  RockerP.Timer <- MTimer.Timer;
}