interface ButtonGroup
{
    command error_t start();
    event void startDone(error_t err);

    command error_t stop();
    event void stopDone(error_t err);

    command void get(); //获取被按下的按键
    //按键按下事件,只有按键确定被按下才会触发（根据ButtonGroupP里的假设）
    event void btnPushed(uint16_t value);
}