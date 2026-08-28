function clearup_olfactoryArena(hComm)

%clearup LED controller
hComm.LEDController1.delete();

if ~(hComm.THSensor == 0)
    hComm.THSensor.close();
end

hComm.MFC1.delete();
hComm.MFC2.delete();

hComm.odormixer1.delete();
