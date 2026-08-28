%initialize MFC

% serial_port_for_MFC = 'COM12';
serial_port_for_MFC = 'COM7';
fprintf('Opening mass flow controllers...\n');
MFC = MassFlowController(serial_port_for_MFC)

%poll data
results = MFC.pollData('C');
if ~isempty(results)
    fprintf('temp is: %s\n', num2str(results.temp));
    fprintf('volumic flow is: %s\n', num2str(results.massFlow));
end
            
%set data
MFC.setPoint('C',10);
