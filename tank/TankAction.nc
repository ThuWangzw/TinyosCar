interface TankAction{
  	command void Start();
	command error_t Steer1(uint16_t value);
	command error_t Steer2(uint16_t value);
	command error_t Steer3(uint16_t value);
	command error_t Forward(uint16_t value);
	command error_t Back(uint16_t value);
	command error_t Left(uint16_t value);
	command error_t Right(uint16_t value);
	command error_t Pause();
	
	event void ActionDone();
}