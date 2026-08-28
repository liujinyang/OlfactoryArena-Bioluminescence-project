volt = 13;
delayTime = 0;
onTime = 1000;
offTime = 1000;
cycles = 30;
PScomport = 'COM6';
LEDcomport = 'COM4';


%Test the shock grid
hPS = shockerPowerSupply(PScomport);
hLEDC = LEDController(LEDcomport);
hLEDC.reset();

%set voltage 
hPS.setVoltage(volt);
hPS.turnOnPS();
%pattern in order of Board4 board3 board2 board1
hLEDC.setShockPattern('1100110011111010');

pause(1);
hLEDC.turnOnShock();

pause(10);
hLEDC.turnOffShock();

shockPulse.onTime = onTime;
shockPulse.offTime = offTime;
shockPulse.cycles = cycles;
shockPulse.delayTime = delayTime;
hLEDC.setShockPulse(shockPulse);

hLEDC.startPulse();
pause(60);

%reset to 0 V
hPS.turnOff();

hPS.delete();
hLEDC.delete();

