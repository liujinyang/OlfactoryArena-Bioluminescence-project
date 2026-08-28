function hComm = initialize_olfactoryArena()

olfactoryArena_user_setting;

%initialize LED controller
fprintf('Opening LED controller...\n');
LEDController1 = LEDController(serial_port_for_LED_Controller);
hComm.LEDController1 = LEDController1;

%initalize odor controller1
fprintf('Opening odormixer1...\n');
odormixer1 = Odormixer(devNum_odorC1);
odormixer1.valveOff();
hComm.odormixer1 = odormixer1;
% if isempty(hComm.odormixer1.NIdaq)
%     hComm.odormixer1 = 0;
% end

% % %initialize precon sensor
THSensor = PreconSensor(serial_port_for_precon_sensor);
[success, errMsg] = THSensor.open();
if success
    hComm.THSensor = THSensor;
else
    hComm.THSensor = 0;    
    display(errMsg);
end

%initialize MFC
fprintf('Opening mass flow controllers...\n');
MFC1 = MassFlowController(serial_port_for_MFC1);
hComm.MFC1 = MFC1;
hComm.MFC1.setPoint('C',defaultMFC1Val);

MFC2 = MassFlowController(serial_port_for_MFC2);
hComm.MFC2 = MFC2;
hComm.MFC2.setPoint('D',defaultMFC2Val);
