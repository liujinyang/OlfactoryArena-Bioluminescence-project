LEDController1 = LEDController('COM4');
LEDController1.reset();
%LEDController1.setBlueLEDPower(10);

%LEDController1.setRedLEDPower(10);
LEDController1.setRedLEDPower(0,0,'0001');
LEDController1.setRedLEDPower(0,0,'0010');
LEDController1.setRedLEDPower(0,0,'0100');
LEDController1.setRedLEDPower(100,0,'1000');

LEDController1.setBlueLEDPower(0,0,'0001');
LEDController1.setBlueLEDPower(100,0,'0010');
LEDController1.setBlueLEDPower(0,0,'0100');
LEDController1.setBlueLEDPower(0,0,'1000');

LEDController1.setGreenLEDPower(100,0,'0001');
LEDController1.setGreenLEDPower(0,0,'0010');
LEDController1.setGreenLEDPower(0,0,'0100');
LEDController1.setGreenLEDPower(0,0,'1000');


LEDController1.turnOnLED();
pause(10);
LEDController1.turnOffLED();


% param.pulse_width =4000;
% param.pulse_period = 6000;
% param.number_of_pulses = 1;
% param.pulse_train_interval = 0;
% param.LED_delay = 0;
% param.iteration = 1;
% param.color = 'blue';
% LEDController1.setPulseParam(param);

param.pulse_width =5000;
param.pulse_period = 6000;
param.number_of_pulses = 1;
param.pulse_train_interval = 0;
param.LED_delay = 0;
param.iteration = 1;
param.color = 'red';
LEDController1.setPulseParam(param);

pause(0.1);
LEDController1.startPulse();
pause(10);
LEDController1.stopPulse();
LEDController1.delete();

       