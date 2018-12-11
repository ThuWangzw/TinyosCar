interface TankAction{
  	command void Start();
	command error_t action(nx_uint8_t type, nx_uint16_t data);
	
	event void ActionDone();
}