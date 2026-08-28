PScomport = 'COM6';
volt = 90;

hPS = shockerPowerSupply(PScomport);

hPS.setVoltage(volt);
hPS.turnOnPS();

pause(2);

Vcurrent = hPS.getVoltage();
Icurrent = hPS.getCurrent();

hPS.turnOff();
hPS.delete();