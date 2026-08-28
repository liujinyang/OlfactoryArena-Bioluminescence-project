classdef MassFlowController < handle
    properties
        serialPort
    end
    
    methods
        function obj = MassFlowController(COMPort)
            obj.serialPort = serial(COMPort,...
                'TimeOut', 2,...
                'BaudRate', 19200,...
                'Terminator','CR');
            try
                fopen(obj.serialPort)
            catch ME
                display(ME.message);
                obj.serialPort = 0;
            end
        end
        
        function result = pollData(obj, ID)
            if ~(obj.serialPort == 0)
                try
                    while obj.serialPort.BytesAvailable> 0
                        fscanf(obj.serialPort);
                    end
                    
                    fprintf(obj.serialPort, ID);
                    pause(0.1);
                    IN=fscanf(obj.serialPort);

                    IN = IN(1:48);
                    [OUT.ID, ...
                        OUT.pressure,...
                        OUT.temp,...
                        OUT.volumetricFlow,...
                        OUT.massFlow,...
                        OUT.setPoint,...
                        OUT.gas...
                        ]= strread(IN,'%s%f%f%f%f%f%s', 'delimiter', ' ');
                    
                catch ME
                    disp(ME.message)
                    OUT=[];
                end
                if OUT.ID{1} == ID
                    result = OUT;
                else
                    result = {};
                end
                
            else
                result = [];
            end
        end
        
        function setPoint(obj, ID, setValue)
            if ~(obj.serialPort == 0)
                try
                    cmd = [ID,'S', num2str(setValue)];
                    fprintf(obj.serialPort,cmd);
                    pause(0.1);
                catch ME
                    disp(ME.message)
                end
            end
        end

        function delete(obj)
            if ~(obj.serialPort == 0)
                fclose(obj.serialPort);
            end
        end
    end
end

