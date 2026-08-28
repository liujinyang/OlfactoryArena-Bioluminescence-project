classdef Odormixer < handle
    
    properties
        NIdaq
    end
    
    methods
        function obj = Odormixer(deviceID)
            try
                %intialize daq
                obj.NIdaq = daq.createSession('ni');
                addDigitalChannel(obj.NIdaq,deviceID,'port0/line0:7','OutputOnly');
            catch ME
                disp(ME.message);
                obj.NIdaq = '';
            end
        end
        
        
        function valveOn(obj, vial)
            if ~isempty(obj.NIdaq)
                %outputSingleScan(obj.NIdaq,chans);
                %open valve, paus
                switch vial
                    case '0'
                        outputSingleScan(obj.NIdaq,[0,0,0,0,0,0,0,0]);
                    case '1'
                        outputSingleScan(obj.NIdaq,[0,0,0,1,1,0,0,0]);
                    case '2'
                        outputSingleScan(obj.NIdaq,[0,0,1,0,1,0,0,0]);
                    case '3'
                        outputSingleScan(obj.NIdaq,[0,1,0,0,1,0,0,0]);
                    case '4'
                        outputSingleScan(obj.NIdaq,[1,0,0,0,1,0,0,0]);
                    otherwise
                        warning('Unexpected channel.')
                end
             end
        end
        
        function valveOff(obj)
            if ~isempty(obj.NIdaq)
                % close valve, pause
                outputSingleScan(obj.NIdaq,[0,0,0,0,0,0,0,0]);
            end
        end
        
%         function valveOnTime(obj,chan,delay,ontime)
%             if ~isempty(obj.NIdaq)
%                 pause(delay);
%                 valveon(obj,chan);
%                 pause(ontime);
%                 valveoff(obj);
%             end
%         end
        
        function delete(obj)
            clear obj.NIdaq;
        end
        
    end
end
