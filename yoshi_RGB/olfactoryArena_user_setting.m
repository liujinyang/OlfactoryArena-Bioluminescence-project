serial_port_for_LED_Controller = 'COM3';
serial_port_for_precon_sensor = 'COM4';

devNum_odorC1 = 'Dev1'; 

% %PID JCS 8/26/2021
% devNum_PID1 = 'dev2';
serial_port_for_MFC1 = 'COM8';
serial_port_for_MFC2 = 'COM6';

rigName = 'olfactoryArena1';

%Temp and Humidity update period (in secs)
THUpdateP = 2;

%MFC default value
defaultMFC1Val = 20;  %marked by 3 'C'
defaultMFC2Val = 200; %marked by 4 'D'

%%settings for the PMTs
%exposure time/ gate time (in ms)
PMTGateTime = 100;

%Directory settings

expDefaultDir = 'C:\Users\labadmin\Documents\MATLAB\BioLuminescenceRIg\yoshi_RGB';
expDataDir = 'C:\Data';
expProtocolDir = [expDefaultDir,'\Protocols'];

%file settings
defaultMetaXmlFile = [expDefaultDir,'\olfactoryArenaMetaTree.xml'];
defaultExpNotesFile = [expDefaultDir,'\olfactoryArenaExpNotes.xml'];
defaultProtocol = [expProtocolDir,'\protocolVer3.xlsx'];
