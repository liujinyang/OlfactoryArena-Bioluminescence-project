function delay_daq_control(token, param)

persistent s s1 s2 fullFileName lh

%This script is used to measure the odor controller delay time, which is
%from the time opening the valve to the time the odor is detected by the
%end of PID sensor

DdigitalOut = 'Dev1';  %USB 6525
DanalogInput = 'Dev2';  %USB 6008

switch token
    
    case 'init'
        %intialize daq
        s = daq.createSession('ni');
        addAnalogInputChannel(s,DanalogInput, 0:1, 'Voltage');
        s.Rate = 10;
        
        s1 = daq.createSession('ni');
        addDigitalChannel(s1,DanalogInput,'port0/line0','OutputOnly');

        s2 = daq.createSession('ni');
        addDigitalChannel(s2,DdigitalOut,'port0/line0:7','OutputOnly');
        
        dataFolder = 'E:\Yoshi PID\';
        fileName = ['log', datestr(now, 30), '.bin'];
        fullFileName = fullfile(dataFolder, fileName);
        fid1 = fopen(fullFileName, 'w');
        lh = addlistener(s,'DataAvailable', @(src,event) logData(src, event, fid1));
        s.NotifyWhenDataAvailableExceeds = 10;
        s.IsContinuous = true;
        
    case 'start'
        
        %start daq
        %pin 6 is connected to the default valve, 0 is open and 1 is close
        outputSingleScan(s2,[0,0,0,0,0,0,0,0]);
        outputSingleScan(s1,0);
        s.startBackground();
        
        
    case 'valveon'
        % open valve, paus
        switch param
            case 'ch1'
                outputSingleScan(s2,[1,0,0,0,0,1,0,0]);
                outputSingleScan(s1,1);
            case 'ch2'
                outputSingleScan(s2,[0,1,0,0,0,1,0,0]);
                outputSingleScan(s1,1);
            case 'ch3'
                outputSingleScan(s2,[0,0,1,0,0,1,0,0]);
                outputSingleScan(s1,1);
            case 'ch4'
                outputSingleScan(s2,[0,0,0,1,0,1,0,0]);
                outputSingleScan(s1,1);
            case 'ch5'
                outputSingleScan(s2,[0,0,0,0,1,1,0,0]);
                outputSingleScan(s1,1);
            case 'ch6'
                outputSingleScan(s2,[0,0,0,0,0,0,0,0]);
                outputSingleScan(s1,0);
            case 'ch7'
                outputSingleScan(s2,[0,0,0,0,0,1,1,0]);
                outputSingleScan(s1,1);
            case 'ch8'
                outputSingleScan(s2,[0,0,0,0,0,1,0,1]);
                outputSingleScan(s1,1);
            otherwise
                warning('Unexpected channel.')
        end
        
    case 'valveoff'
        % close valve, pause
        outputSingleScan(s2,[0,0,0,0,0,1,0,0]);
        outputSingleScan(s1,0);
        
    case 'stop'
        % stop experiment
        outputSingleScan(s2,[0,0,0,0,0,0,0,0]);
        outputSingleScan(s1,0);
        s.stop;
        s1.stop;
        s2.stop;
        delete(lh); 
        %clean up
        clear s;
        clear s1;
        clear s2;
        
        % fprintf('Odor controller delay test is done!\n');
        
    case 'figure'
        %plot figure
        fid2 = fopen(fullFileName,'r');
        [data,count] = fread(fid2,[3,inf],'double');
        fclose(fid2);
        t = data(1,:);
        ch1 = data(2,:);
        ch1_norm_data = (ch1 - min(ch1))/ ( max(ch1) - min(ch1) );
        ch2 = data(3,:);
        ch2_norm_data = (ch2 - min(ch2)) *5/ ( max(ch2) - min(ch2) );
        ch = [ch1; ch2];
        plot(t, ch);
    otherwise
        warning('Unexpected command.')
end
