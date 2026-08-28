classdef OlfactoryArena_BioLuminescence_App_TCP_RUNTIMEFIX3_20260630 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        figure1             matlab.ui.Figure
        uipanel18           matlab.ui.container.Panel
        text20              matlab.ui.control.Label
        exp_name            matlab.ui.control.EditField
        run_exp             matlab.ui.control.StateButton
        select_exp          matlab.ui.control.StateButton
        text21              matlab.ui.control.Label
        current_step        matlab.ui.control.TextArea
        Environment_Panel   matlab.ui.container.Panel
        text27_2            matlab.ui.control.Label
        text26_2            matlab.ui.control.Label
        humidity_rig        matlab.ui.control.EditField
        temp_rig            matlab.ui.control.EditField
        text30              matlab.ui.control.Label
        psia_val2           matlab.ui.control.EditField
        psia_val1           matlab.ui.control.EditField
        text27              matlab.ui.control.Label
        text26              matlab.ui.control.Label
        text16              matlab.ui.control.Label
        temp_val2           matlab.ui.control.EditField
        mfr_val2            matlab.ui.control.EditField
        temp_val1           matlab.ui.control.EditField
        mfr_val1            matlab.ui.control.EditField
        text15              matlab.ui.control.Label
        Vial_Control_Panel  matlab.ui.container.Panel
        uibuttongroup1      matlab.ui.container.ButtonGroup
        RB11                matlab.ui.control.RadioButton
        RB12                matlab.ui.control.RadioButton
        RB13                matlab.ui.control.RadioButton
        RB14                matlab.ui.control.RadioButton
        RB15                matlab.ui.control.RadioButton
        text31              matlab.ui.control.Label
        valve_on            matlab.ui.control.StateButton
    end

    properties (Access = private)
        C8855_Client
        C8855_ServerHost = '127.0.0.1'
        C8855_ServerPort = 55000
    end

    
    methods (Access = private)
        function buildStamp = getBuildStamp(app)
            buildStamp = 'TCP build 2026-06-30 9:50 AM';
        end

        function LED_Pattern_CellEditCallback(app, hObject, eventdata, handles)
            % --- Executes when entered data in editable cell(s) in LED_Pattern.
            
            % hObject    handle to LED_Pattern (see GCBO)
            % eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
            %	Indices: row and column indices of the cell(s) edited
            %	PreviousData: previous data for the cell(s) edited
            %	EditData: string(s) entered by the user
            %	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
            %	Error: error string when failed to convert EditData to appropriate value for Data
            % handles    structure with handles and user data (see GUIDATA)
        end
        
        function LED_Pattern_CellSelectionCallback(app, hObject, eventdata, handles)
            % --- Executes when selected cell(s) is changed in LED_Pattern.
            
            % hObject    handle to LED_Pattern (see GCBO)
            % eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
            %	Indices: row and column indices of the cell(s) currently selecteds
            % handles    structure with handles and user data (see GUIDATA)
            LED_pattern_raw = get(hObject,'data');
            
            if isempty(find(LED_pattern_raw))
                Pattern = logical(zeros(1,16));
            else
                Temp = LED_pattern_raw;
                Pattern = [Temp(1,:),Temp(2,:),Temp(3,:),Temp(4,:)];
            end
            
            handles.LEDpattern(1:8) = Pattern;
            
            guidata(hObject, handles);
        end
        
        function LedPattern_CellEditCallback(app, hObject, eventdata, handles)
            % --- Executes when entered data in editable cell(s) in LedPattern.
            
            % hObject    handle to LedPattern (see GCBO)
            % eventdata  structure with the following fields (see UITABLE)
            %	Indices: row and column indices of the cell(s) edited
            %	PreviousData: previous data for the cell(s) edited
            %	EditData: string(s) entered by the user
            %	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
            %	Error: error string when failed to convert EditData to appropriate value for Data
            % handles    structure with handles and user data (see GUIDATA)
            
            % The quadrant is arranged in the following way
            %2  1
            %3  4
            %The controller is located at the 4th quadrant
            
            LED_pattern_raw = get(hObject,'data');
            
            Pattern = '0000';
            if ~isempty(find(LED_pattern_raw,1))
                Temp = LED_pattern_raw;
                Temp1 = [Temp(1,2) Temp(1,1) Temp(2,1) Temp(2,2)];
                for i = 1 : 4
                    if Temp1(i)
                        Pattern(i) = '1';
                    end
                end
            end
            
            handles.LEDPattern = Pattern;
            
            guidata(hObject, handles);
        end
        
        function board1Group_SelectionChangedFcn(app, hObject, eventdata, handles)
            % --- Executes when selected object is changed in board1Group.
            
            % hObject    handle to the selected object in board1Group
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
                case 'RB11'
                    handles.board1.currentVialNum = '0';
                case 'RB12'
                    handles.board1.currentVialNum = '1';
                case 'RB13'
                    handles.board1.currentVialNum = '2';
                case 'RB14'
                    handles.board1.currentVialNum = '3';
            end
            guidata(hObject, handles);
        end
        
      
        
        function delay(app, sec)
            
            % function pause the program
            % ms = delay time in seconds
            tic;
            while toc < sec
            end
        end
        
        function displayTempMfr(app, obj, event, Hfig)
            % tic
            handles = guidata(Hfig);
            results = handles.hComm.MFC1.pollData('C');
            if isempty(results)
                stop(handles.tTemp);
                return;
            end
            set(handles.temp_val1, 'String', num2str(results.temp));
            set(handles.mfr_val1, 'String', num2str(results.volumetricFlow));
            set(handles.psia_val1, 'String', num2str(results.pressure));
            
            
            results = handles.hComm.MFC2.pollData('D');
            if ~isempty(results)
                set(handles.temp_val2, 'String', num2str(results.temp));
                set(handles.mfr_val2, 'String', num2str(results.volumetricFlow));
                set(handles.psia_val2, 'String', num2str(results.pressure));
            end
            
            % toc
            if ~(handles.hComm.THSensor == 0)
                [temp,humid,~,~] = handles.hComm.THSensor.read(1);
                app.temp_rig.Value = num2str(temp);
                app.humidity_rig.Value = num2str(humid);
            end

            % handles.TempValue = temp;
            % handles.HumdValue = humd;
            %guidata(obj, handles);
        end
        
        function experiment(app, src, evt, hFig)
            %tic
            handles = guidata(hFig);
            if handles.expRun == 1
            
                status = handles.hComm.LEDController1.getExperimentStatus();
                %disp(status);
                %set(handles.current_step, 'string', status);
                %     state = stat.state;
                %     stepIndex = stat.experiment_step_index+1;
                %     sequenceIndex = stat.sequence_index+1;
                %     stepCount = stat.experiment_step_count;
                %     sequenceCount = stat.sequence_count;
                if ~isempty(status)
                    temp = textscan(status,'%f,%d,%f,%f,%f');

                    time = temp{1}/1000;
                    stepCount = temp{2};
                    rL = temp{3};
                    gL = temp{4};
                    bL = temp{5};

                    statusDisp=sprintf('Time: %.2f\nStep: %d\n', time,stepCount);

                    if stepCount == 0  %Experiment is finished
                        %turn off valves
                        handles.hComm.odormixer1.valveOff();

                        handles.expRun = 0;

                        set(handles.current_step, 'string', 'Done!!');
                    else

                        set(handles.current_step, 'string', statusDisp);
                        %start recording movies or changing MFC settings
                        if stepCount ~= handles.lastStepCount

                            %step 1. turn on/off valves
                            % in case the valves haven't been turned off for last step
                            if stepCount > 1 && handles.protocol.valveOffIsDone(stepCount-1) == 0 && handles.protocol.valveOffInSec(stepCount-1)~= 0
                                handles.hComm.odormixer1.valveOff();
                                handles.protocol.valveOffIsDone(stepCount-1) = 1;
                                statusDisp=sprintf('Time: %.2f\nStep: %d\nAll valves are Off\n', time,stepCount);
                                set(handles.current_step, 'string', statusDisp);
                            end

                            if handles.protocol.valveDelay(stepCount)== 0 && handles.protocol.valveOnTime(stepCount)>0
                                temp1 = num2str(handles.protocol.vialNum(stepCount,1));
                                handles.hComm.odormixer1.valveOn(temp1);
                                handles.protocol.valveOnIsDone(stepCount) = 1;
                                statusDisp=sprintf('Time: %.2f\nStep: %d\nValve %d On\n', time,stepCount, temp1);
                                set(handles.current_step, 'string', statusDisp);
                            end

                            %start recording PMT

                            handles.lastStepCount = stepCount;

                        else  % stepCount == handles.lastStepCount
                            if handles.protocol.valveOnIsDone(stepCount) == 0 && handles.protocol.valveOnInSec(stepCount) ~= 0 && time > handles.protocol.valveOnInSec(stepCount)
                                temp1 = num2str(handles.protocol.vialNum(stepCount,1));
                                handles.hComm.odormixer1.valveOn(temp1);
                                handles.protocol.valveOnIsDone(stepCount)=1;
                                statusDisp=sprintf('Time: %.2f\nStep: %d\nValve %d On\n', time,stepCount, temp1);
                                set(handles.current_step, 'string', statusDisp);
                            end

                            if handles.protocol.valveOffIsDone(stepCount) == 0 && handles.protocol.valveOffInSec(stepCount) ~= 0 && time > handles.protocol.valveOffInSec(stepCount)
                                handles.hComm.odormixer1.valveOff();
                                handles.protocol.valveOffIsDone(stepCount)=1;
                                statusDisp=sprintf('Time: %.2f\nStep: %d\nAll valves are Off\n', time,stepCount);
                                set(handles.current_step, 'string', statusDisp);
                            end
                        end
                    end
                    guidata(hFig, handles);
                end
            else
                %%Experiment end
                handles = saveDataAfterAbortOrFinished(app, handles);
                set(handles.run_exp,'Value',0);
                guidata(hFig, handles);
                set(handles.run_exp,'String','Start');
                beep;
            end
            %toc
        end
        
        
        function handles = saveDataAfterAbortOrFinished(app, handles)
            try
                stop(handles.tExperiment);
                handles.hComm.LEDController1.stopExperiment();
            catch ME
                disp(ME);
            end

            stop_C8855(app);
            
            %turn off LEDs
            handles.hComm.LEDController1.turnOffLED();
            
            %turn off valves
            handles.hComm.odormixer1.valveOff();
            
            handles.expRun = 0;
            
            if isfield(handles,'expTimeFileID')
                fclose(handles.expTimeFileID);
            end
            %toc(stopTime)
            %toc(expStartTime)
            
            %set(handles.current_step, 'string', 'Done!!');
            
            %% input experiment notes after the experiment is done
            defaultNoteFile = handles.defaultExpNotesFile;
            
            % Load defaults XML tree from sample file
            defaultNoteTree = loadXMLDefaultsTree(defaultNoteFile);
            
            % Create figure in which to place JIDE property grid
            fig = figure( ...
                'MenuBar', 'none', ...
                'Name', 'Experiment Note Input GUI', ...
                'NumberTitle', 'off', ...
                'Toolbar', 'none' ...
                );
            
            % Create JIDE PropertyGrid and display defaults data in figure
            pgrid = PropertyGrid(fig,'Position', [0 0 1 1]);
            pgrid.setDefaultsTree(defaultNoteTree, 'advanced');
            
            % Block unit figure is destroyed
            uiwait(fig);
            
            % Create XML meta data file from defaults tree. Note we haven't checked if
            % we have all the required values filled in, but this is suppose to be a
            % simple example - I'll show how to do this in a more ellaborate example.
            noteData = createXMLMetaData(defaultNoteTree);
            
            % Save defaultsTree as xml file. Note, the current values for all the meta
            % data are saved in the tree so that it is possible to have meata data whose
            % default option is to use the last value used.
            defaultNoteTree.write(defaultNoteFile);
            
            
            %% save data files
            for i = 1:1
            
                %save the meta data file
                noteFile = [handles.expDataSubdir{i}, '\expNotes.xml'];
                noteData.write(noteFile);
            
                %copy log file
                if i>1
                    logfile1 = [handles.expDataSubdir{1}, '\expTimeStamp.txt'];
                    logfile2 = [handles.expDataSubdir{i}, '\expTimeStamp.txt'];
                    copyfile(logfile1, logfile2);
                end
            
                %     %hardcode to change the movie file name
            %     movieFileWithVer = [handles.expDataSubdir{i}, '\movie*.', handles.movieFormat];
            %
            %     D = dir(movieFileWithVer);
            %     if ~isempty(D)
            %         for j = 1:length(D)
            %             movieFileWithVer = fullfile(handles.expDataSubdir{i},D(j).name);
            %             defaultMovieFile = fullfile(handles.expDataSubdir{i}, [D(j).name(1:end-10),'.',handles.movieFormat]);
            %             movefile(movieFileWithVer, defaultMovieFile);
            %         end
            %     end
            
            end
            
            %enable those inputs
            set(findall(handles.Vial_Control_Panel, '-property', 'enable'), 'enable', 'on');
            set(findall(handles.Environment_Panel, '-property', 'enable'), 'enable', 'on');
            set(handles.select_exp, 'enable', 'on');
            set(handles.run_exp,'Value',0);
            set(handles.run_exp,'String','Start');
            
            
            %start update temp and humidity value
            try
                if ~(handles.hComm.MFC1.serialPort == 0)
                    %handles.tTemp = timer('StartDelay', 3, 'Period', handles.THUpdateP, 'ExecutionMode', 'fixedRate', 'TimerFcn',{@displayTempHumd, handles.figure1} );
                    start(handles.tTemp);
                end
            catch ME
                disp(ME);
            end
            
            %guidata(hObject, handles);
        end
        
        % Update components that require runtime configuration
        function addRuntimeConfigurations(app)
            
            % Load data for component configuration
            componentData = load('OlfactoryArena_BioLuminescence_App.mat');
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function OlfactoryArena_BioLuminescence_OpeningFcn(app, varargin)
            % --- Executes just before OlfactoryArena_BioLuminescence is made visible.
            
            % Add runtime required configuration - Added by Migration Tool
            addRuntimeConfigurations(app);
            
            % Ensure that the app appears on screen when run
            movegui(app.figure1, 'onscreen');
            app.figure1.Name = ['OlfactoryArena_BioLuminescence - ', getBuildStamp(app)];
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app); %#ok<ASGLU>
            
            % This function has no output args, see OutputFcn.
            % hObject    handle to figure
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            % varargin   command line arguments to OlfactoryArena_BioLuminescence (see VARARGIN)
            
            % Choose default command line output for OlfactoryArena_BioLuminescence
            handles.output = hObject;
            
            olfactoryArena_user_setting;
            
            hComm = initialize_olfactoryArena;
            handles.hComm = hComm;

            try
                ensure_C8855_server(app);
            catch ME
                warning('C8855:ServerStartupFailed', 'Failed to launch the PMT TCP server: %s', ME.message);
            end
            
            % add this per Kristin's request
            if ~exist('PreconSensor','file')
                p = fileparts(mfilename('fullpath'));
                addpath(genpath(p));
            end
            
            handles.THUpdateP = THUpdateP;
            
            handles.tTemp = timer('StartDelay', 3, 'Period', handles.THUpdateP, 'ExecutionMode', 'fixedRate', 'TimerFcn',{@app.displayTempMfr, handles.figure1} );
            %guidata(hObject, handles); Do I need to update the handles before the
            
            if ~(handles.hComm.MFC1.serialPort == 0)
                start(handles.tTemp);
            end
            
            handles.expDefaultDir = expDefaultDir;
            handles.expProtocolDir = expProtocolDir;
            handles.expDataDir = expDataDir;
            handles.defaultMetaXmlFile = defaultMetaXmlFile;
            handles.defaultExpNotesFile = defaultExpNotesFile;
            handles.rig = rigName;
            
            handles.board1.currentVialNum = '4';
            
            handles.Blu_int_val = 0;
            handles.Grn_int_val = 0;
            handles.Chr_int_val = 0;
            
            %handles.defaultProtocol = defaultProtocol;
            
            % Update handles structure
            handles.pulseWidth = 0;
            handles.pulsePeriod = 0;
            handles.expRun = 0;
            handles.LEDPattern = '1111';
            %handles.protocol.duration = stepDuration;
            
            
            %shock pattern in the order of board4 board3 board2 board1
            handles.shockpattern = logical([0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1]);
            
            handles.shockVolt = 10;
            handles.shockOnTime = 1000;
            handles.shockOffTime = 1000;
            handles.shockCycles = 10;
            
            %find default metadata xml file
            %updateLineNames;
            %updateEffectors;
            
            %reset MFC to default value
            %setMFC_Callback(handles.setMFC,eventdata,handles);
            
            guidata(hObject, handles);
            
            % UIWAIT makes OlfactoryArena_BioLuminescence wait for user response (see UIRESUME)
            % uiwait(handles.figure1);
        end

        % Callback function
        function BluInt_Callback(app, event)
            % --- Executes on slider movement.
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to BluInt (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'Value') returns position of slider
            %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
            Blu_int_val = round(get(hObject,'Value')*100);   % this is done so only one dec place
            set(handles.BluIntVal, 'String', [num2str(Blu_int_val) '%']);
            handles.Blu_int_val = Blu_int_val;
            %send command to controller
            handles.hComm.LEDController1.setBlueLEDPower(Blu_int_val, 0, handles.LEDPattern);
            guidata(hObject, handles);
        end

        % Callback function
        function ChrInt_Callback(app, event)
            % --- Executes on slider movement.
            
            % Create GUIDE-style callback args - Added by Migration Tool
        end

        % Callback function
        function GrnInt_Callback(app, event)

        end

        % Callback function
        function IrInt_Callback(app, event)

        end

        % Callback function
        function OnOff_Callback(app, event)

        end

        % Value changed function: current_step
        function current_step_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to current_step (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of current_step as text
            %        str2double(get(hObject,'String')) returns contents of current_step as a double
        end

        % Value changed function: exp_name
        function exp_name_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to exp_name (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of exp_name as text
            %        str2double(get(hObject,'String')) returns contents of exp_name as a double
        end

        % Close request function: figure1
        function figure1_CloseRequestFcn(app, event)
            % --- Executes when user attempts to close figure1.
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to figure1 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            % Hint: delete(hObject) closes the figure
            
            %close the serial port connection
            %turn off IR
            
            %stop update temp and humdity. clear the timer
            try
                stop_C8855(app);
                disconnect_C8855(app);
                if ~(handles.hComm.MFC1.serialPort == 0)
                    stop(handles.tTemp);
                end
                %JL10092025 wait one second to finish timer callback to avoid polldata from MFC
                pause(3);
                handles.hComm.LEDController1.setIRLEDPower(0);
                clearup_olfactoryArena(handles.hComm)
            
            catch ME
                disp(ME);
            end
            delete(hObject);
            %close all;
            clear all;
        end

        % Callback function
        function mfr_val1_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to mfr_val1 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of mfr_val1 as text
            %        str2double(get(hObject,'String')) returns contents of mfr_val1 as a double
        end

        % Callback function
        function mfr_val2_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to mfr_val2 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of mfr_val2 as text
            %        str2double(get(hObject,'String')) returns contents of mfr_val2 as a double
        end

        % Callback function
        function mfr_val3_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to mfr_val3 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of mfr_val3 as text
            %        str2double(get(hObject,'String')) returns contents of mfr_val3 as a double
        end

        % Callback function
        function mfr_val4_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, ~] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to mfr_val4 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of mfr_val4 as text
            %        str2double(get(hObject,'String')) returns contents of mfr_val4 as a double
        end

        % Callback function
        function mfr_val5_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to mfr_val5 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of mfr_val5 as text
            %        str2double(get(hObject,'String')) returns contents of mfr_val5 as a double
        end

        % Callback function
        function mfr_val6_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to mfr_val6 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of mfr_val6 as text
            %        str2double(get(hObject,'String')) returns contents of mfr_val6 as a double
        end

        % Callback function
        function mfr_val7_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to mfr_val7 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of mfr_val7 as text
            %        str2double(get(hObject,'String')) returns contents of mfr_val7 as a double
        end

        % Callback function
        function mfr_val8_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to mfr_val8 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of mfr_val8 as text
            %        str2double(get(hObject,'String')) returns contents of mfr_val8 as a double
        end

        % Callback function
        function psia_val1_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to psia_val1 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of psia_val1 as text
            %        str2double(get(hObject,'String')) returns contents of psia_val1 as a double
        end

        % Callback function
        function psia_val2_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to psia_val2 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of psia_val2 as text
            %        str2double(get(hObject,'String')) returns contents of psia_val2 as a double
        end

        % Callback function
        function psia_val3_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to psia_val3 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of psia_val3 as text
            %        str2double(get(hObject,'String')) returns contents of psia_val3 as a double
        end

        % Callback function
        function psia_val4_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to psia_val4 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of psia_val4 as text
            %        str2double(get(hObject,'String')) returns contents of psia_val4 as a double
        end

        % Callback function
        function psia_val5_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to psia_val5 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of psia_val5 as text
            %        str2double(get(hObject,'String')) returns contents of psia_val5 as a double
        end

        % Callback function
        function psia_val6_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to psia_val6 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of psia_val6 as text
            %        str2double(get(hObject,'String')) returns contents of psia_val6 as a double
        end

        % Callback function
        function psia_val7_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to psia_val7 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of psia_val7 as text
            %        str2double(get(hObject,'String')) returns contents of psia_val7 as a double
        end

        % Callback function
        function psia_val8_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to psia_val8 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of psia_val8 as text
            %        str2double(get(hObject,'String')) returns contents of psia_val8 as a double
        end

        % Value changed function: run_exp
        function run_exp_Callback(app, event)
            % --- Executes on button press in run_exp.
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to run_exp (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hint: get(hObject,'Value') returns toggle state of run_exp
            
            button_state = get(hObject,'Value');
            %button is down, start experiment
            if button_state == get(hObject,'Max')
                handles.flagAborted = 0;
                handles.lastStepCount = -1;
                handles.expRun = 1;
                handles.isRecording = 0;
                guidata(hObject, handles);
                set(hObject,'String','ABORT');
            
                %stop update the temperature and humidity value
                if ~(handles.hComm.MFC1.serialPort == 0)
                    stop(handles.tTemp);
                end
            
                %disable those inputs
                set(findall(handles.Vial_Control_Panel, '-property', 'enable'), 'enable', 'off');
                set(findall(handles.Environment_Panel, '-property', 'enable'), 'enable', 'off');
                set(handles.select_exp, 'enable', 'off');
            
                handles.protocol.valveOffIsDone(1:handles.protocol.totalStepNum) = zeros(1,handles.protocol.totalStepNum);
                handles.protocol.valveOnIsDone(1:handles.protocol.totalStepNum) = zeros(1,handles.protocol.totalStepNum);
            
            
                %% input meta data information
                defaultsFile = handles.defaultMetaXmlFile;
            
                % Load defaults XML tree from sample file
                defaultsTree = loadXMLDefaultsTree(defaultsFile);
            
                [pathstr, protocolName, ext]  = fileparts(handles.expFile);
                %    defaultsTree.setValueByPathString('protocol', protocolName);
                %defaultsTree.setValueByPathString('exp_datetime', datestr(now,30));
                defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'IR_intensity'}, num2str(0));
                %defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'LED_intensity_scale'}, handles.intensityMode);
            
                if ~(handles.hComm.THSensor == 0)
                    [temp,humid,~,~] = handles.hComm.THSensor.read(1);
                    defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'temperature'}, num2str(temp));
                    defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'humidity'}, num2str(humid));
                end
            
                if ~(handles.hComm.MFC1.serialPort == 0)
                    results = handles.hComm.MFC1.pollData('C');
                    if ~isempty(results)
                        defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC1_temp'}, num2str(results.temp))
                        defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC1_massFlow'}, num2str(results.volumetricFlow))
                        defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC1_pressure'}, num2str(results.pressure))
                    end
                end
            
                if ~(handles.hComm.MFC2.serialPort == 0)
                    results = handles.hComm.MFC2.pollData('D');
                    if ~isempty(results)
                        defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC2_temp'}, num2str(results.temp))
                        defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC2_massFlow'}, num2str(results.volumetricFlow))
                        defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC2_pressure'}, num2str(results.pressure))
                    end
                end
            
                % defaultsTree.setValueByUniquePath({'olfactoryArena' 'flies' 'genotype'},...
                %     [defaultsTree.getValueByUniquePath({'olfactoryArena','flies', 'male_parent'}), '_',...
                %     defaultsTree.getValueByUniquePath({'olfactoryArena','flies', 'female_parent'})]);
            
                %defaultsTree.setValueByUniquePath({'OlfactoryArena_BioLuminescence' 'flies' 'genotype' 'content'}, 'abcd');
                handles.protocolName= protocolName;
            
                % Create figure in which to place JIDE property grid
                fig = figure( ...
                    'MenuBar', 'none', ...
                    'Name', 'Metadata Input GUI', ...
                    'NumberTitle', 'off', ...
                    'Toolbar', 'none' ...
                    );
            
                % Create JIDE PropertyGrid and display defaults data in figure
                pgrid = PropertyGrid(fig,'Position', [0 0 1 1]);
                pgrid.setDefaultsTree(defaultsTree, 'advanced');
            
                % Block unit figure is destroyed
                uiwait(fig);
                defaultsTree.setValueByUniquePath({'olfactoryArena' 'flies' 'genotype'},...
                    [defaultsTree.getValueByUniquePath({'olfactoryArena','flies', 'male_parent'}),'_' ...
                    defaultsTree.getValueByUniquePath({'olfactoryArena','flies', 'female_parent'})]);
            
                % Create XML meta data file from defaults tree. Note we haven't checked if
                % we have all the required values filled in, but this is suppose to be a
                % simple example - I'll show how to do this in a more ellaborate example.
                metaData = createXMLMetaData(defaultsTree);
            
                % Save defaultsTree as xml file. Note, the current values for all the meta
                % data are saved in the tree so that it is possible to have meata data whose
                % default option is to use the last value used.
                defaultsTree.write(defaultsFile);
            
                % Save meta tree as xml file
                currentDate = datestr(now, 29);
                tempPath1 = [handles.expDataDir, '\', currentDate];
                if ~exist(tempPath1, 'dir')
                    mkdir(tempPath1);
                end
            
                mParentName = metaData.children(2).attribute.male_parent;
                fParentName = metaData.children(2).attribute.female_parent;
                handles.expStartTime = datestr(now,30);
            
                for i = 1:1
                    dataPath = [tempPath1, '\', handles.expStartTime, '_',handles.rig, '_',...
                        'Cam', num2str(i-1), '_', protocolName,'_',mParentName,'_',fParentName];
            
                    if length(dataPath)>255
                        dataPath = [tempPath1, '\', handles.expStartTime,'_', handles.rig, '_',...
                            'Cam', num2str(i-1),'_', protocolName];
                    end
            
                    if ~exist(dataPath, 'dir')
                        tempPath2 = dataPath;
                        mkdir(tempPath2);
                    end
                    handles.expDataSubdir{i} = tempPath2;
                end

                start_C8855(app, handles.expDataSubdir{1});
            
                %% save data files
                for i = 1:1
                    %save the meta data file
                    metaDataFile = [handles.expDataSubdir{i}, '\metaData.xml'];
                    metaData.write(metaDataFile);
            
                    % save the protocol file
                    protocol = handles.protocol;
                    protocolFile = [handles.expDataSubdir{i}, '\protocol.mat'];
                    save(protocolFile,'protocol');
                    protocolExl = [handles.expDataSubdir{i}, '\protocol.xlsx'];
                    copyfile(handles.expFile, protocolExl);
                    protocolCSV = [handles.expDataSubdir{i}, '\protocol.csv'];
                end
            
                % create an experiment timestamp file
                expTimeFile = [handles.expDataSubdir{1}, '\expTimeStamp.txt'];
                handles.expTimeFileID = fopen(expTimeFile, 'w+');
            
                %stop preview mode
                % for i = 1:length(handles.hComm.flea3)
                %     if ~(handles.hComm.flea3(i) == 0)
                %         flyBowl_camera_control(handles.hComm.flea3(i),'stop');
                %     end
                % end
            
                handles.tExperiment = timer('TimerFcn',{@app.experiment, handles.figure1},'Period',0.1, 'ExecutionMode', 'fixedRate');
                guidata(hObject, handles);
                handles.hComm.LEDController1.runExperiment();
                %JL100925 add a wait time to avoid serial read error in experiment()
                %pause(1.2);
                start(handles.tExperiment);
            
            else
                %abort experiment
                handles.flagAborted = 1;
                guidata(hObject, handles);
                handles = saveDataAfterAbortOrFinished(app, handles);
            end
        end

        function start_C8855(app, dataDir)
            ensure_C8855_server(app);
            client = get_C8855_client(app);
            client.setDataDir(dataDir);
            client.startAcquisition();
            pause(0.5);
        end

        function stop_C8855(app)
            if isempty(app.C8855_Client) || ~isvalid(app.C8855_Client)
                return;
            end

            try
                app.C8855_Client.stopAcquisition();
            catch ME
                disp(ME.message);
            end
        end

        function disconnect_C8855(app)
            if isempty(app.C8855_Client) || ~isvalid(app.C8855_Client)
                return;
            end

            app.C8855_Client.disconnect();
        end

        function client = get_C8855_client(app)
            if isempty(app.C8855_Client) || ~isvalid(app.C8855_Client)
                app.C8855_Client = C8855TcpClient(app.C8855_ServerHost, app.C8855_ServerPort, 5);
            end

            client = app.C8855_Client;
        end

        function ensure_C8855_server(app)
            client = get_C8855_client(app);
            try
                client.ping();
                return;
            catch
                client.disconnect();
            end

            appFile = which(class(app));
            appRoot = fileparts(appFile);
            exePath = fullfile(appRoot, 'C8855Exe', 'c8855_dual_acquire.exe');
            if ~isfile(exePath)
                error('C8855:ServerExeMissing', 'Could not find the PMT server executable at %s.', exePath);
            end

            cmd = sprintf('start "" /B "%s" --tcp-server --tcp-port %d --gate 10ms --points auto --trigger external --setupex --edge rise', ...
                exePath, app.C8855_ServerPort);
            [status, cmdout] = system(cmd);
            if status ~= 0
                error('C8855:ServerLaunchFailed', 'Failed to start the PMT server: %s', strtrim(cmdout));
            end

            for attempt = 1:10
                pause(0.5);
                try
                    client.connect();
                    client.ping();
                    return;
                catch
                    client.disconnect();
                end
            end

            error('C8855:ServerUnavailable', 'Could not connect to the PMT TCP server on %s:%d.', ...
                app.C8855_ServerHost, app.C8855_ServerPort);
        end

        % Value changed function: select_exp
        function select_exp_Callback(app, event)
            % --- Executes on button press in select_exp.
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to select_exp (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hint: get(hObject,'Value') returns toggle state of select_exp
            % oldPath = pwd;
            % cd(handles.expProtocolDir);
            [filename, pathname] = uigetfile([handles.expProtocolDir,'\*.xls; *.xlsx;'], 'Select an experiment file');
            if isequal(filename,0)
                return
            else
                expFile = fullfile(pathname, filename);
                set(handles.exp_name, 'string', expFile);
                handles.expFile = expFile;
                [~,~,protocolExt] = fileparts(expFile);
            end
            
            switch protocolExt
                case {'.csv'}
                    [intext, indata] = csvread_with_headers(expFile);

                case {'.xls', '.xlsx'}
                    [indata,intext,~] = xlsread(expFile);

                otherwise
                    disp('Unknown protocol file type.')
                    return
            end

            handles.protocol.vialNum = zeros(size(indata,1),1);
            handles.ProtocolHeader = intext(1,:);
            handles.ProtocolData = indata;

            %trial control
            handles.protocol.stepNum= indata(:,1);
            handles.protocol.duration = indata(:,2);

            %Vial control
            handles.protocol.vialNum(:,1)= indata(:,3);
            handles.protocol.valveDelay= indata(:,4);
            handles.protocol.valveOnTime = indata(:,5);

            
            handles.protocol.totalStepNum = length(handles.protocol.stepNum);
            handles.totalDuration = sum(handles.protocol.duration(:));
            
            for stepIndex = 1:handles.protocol.totalStepNum
            
                if stepIndex == 1
                    handles.protocol.stepStartTime(stepIndex) = 0;
                else
                    handles.protocol.stepStartTime(stepIndex) = handles.protocol.stepStartTime(stepIndex-1) + handles.protocol.duration(stepIndex-1);
                end
            
                handles.protocol.valveOnInSec(stepIndex) = handles.protocol.stepStartTime(stepIndex) + handles.protocol.valveDelay(stepIndex);
                handles.protocol.valveOffInSec(stepIndex) = handles.protocol.valveOnInSec(stepIndex) + handles.protocol.valveOnTime(stepIndex);
            
            
                %if valve on time is zero,
                if handles.protocol.valveOnTime(stepIndex) == 0
                    handles.protocol.valveOnInSec(stepIndex) = 0;
                    handles.protocol.valveOffInSec(stepIndex) = 0;
                end
            
                %if the valve on time is same as last valve off time then keep the vlave on
                if (stepIndex > 1)
                    %if handles.protocol.vialNum(stepIndex,1)==handles.protocol.vialNum(stepIndex-1,1) && (handles.protocol.valveOnInSec(stepIndex) == handles.protocol.valveOffInSec(stepIndex-1))
                    % fix Consecutive writes to a digital line occurred more frequently than the device can safely allow.
                    if (handles.protocol.valveOnInSec(stepIndex) == handles.protocol.valveOffInSec(stepIndex-1))
                        handles.protocol.valveOffInSec(stepIndex-1) = 0;
                    end
                end
            
                oneStep(stepIndex).RedIntensity = 10;
                oneStep(stepIndex).GrnIntensity = 0;
                oneStep(stepIndex).BluIntensity = 0;
            
                %binary array
                oneStep(stepIndex).Pattern = '00000000';
            
            
                %oneStep(stepIndex).NumStep = handles.protocol.stepNum(stepIndex);
                oneStep(stepIndex).NumStep = stepIndex;
                oneStep(stepIndex).Duration = handles.protocol.duration(stepIndex);  %in seconds
                oneStep(stepIndex).DelayTime = 0;
                %red light
                oneStep(stepIndex).RedPulseWidth = 100;
                oneStep(stepIndex).RedPulsePeriod = 100;
                oneStep(stepIndex).RedPulseNum = 1;
                oneStep(stepIndex).RedOffTime = 0;
                oneStep(stepIndex).RedIteration = 1;
            
                %green light
                oneStep(stepIndex).GrnPulseWidth = 0;
                oneStep(stepIndex).GrnPulsePeriod = 0;
                oneStep(stepIndex).GrnPulseNum = 0;
                oneStep(stepIndex).GrnOffTime = 0;
                oneStep(stepIndex).GrnIteration = 0;
            
                %blue light
                oneStep(stepIndex).BluPulseWidth = 0;
                oneStep(stepIndex).BluPulsePeriod = 0;
                oneStep(stepIndex).BluPulseNum = 0;
                oneStep(stepIndex).BluOffTime = 0;
                oneStep(stepIndex).BluIteration = 0;
            
            end
            
            
            %remove all experiment steporders
            handles.hComm.LEDController1.removeAllExperimentSteps();
            
            %add new experiment steps
            try
                for stepIndex = 1:handles.protocol.totalStepNum
                    totalSteps = handles.hComm.LEDController1.addOneStep(oneStep(stepIndex));
                end
            
                if totalSteps == handles.protocol.totalStepNum
                    expData = handles.hComm.LEDController1.getExperimentSteps();
                    disp(expData);
                    set(handles.run_exp,'enable', 'on');
                else
                    errID = 'LEDController:UploadProtocolError';
                    msgtext = 'The LED protocol upload failed.';
            
                    ME = MException(errID,msgtext);
                    throw(ME);
                end
            
            catch ME
                errorMessage = sprintf('Error in uploading LED protocol.\n %s\n', ...
                    ME.message);
                uiwait(warndlg(errorMessage));
                set(handles.run_exp,'enable', 'off');
            end
            
            
            %get whole Valve pattern
            for i = 1:size(handles.protocol.vialNum, 1)
                handles.protocol.valvePatt{i} = handles.protocol.vialNum(i,:);
            end
            
            guidata(hObject, handles);
        end

        % Callback function
        function setMFC1_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to setMFC1 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of setMFC1 as text
            %        str2double(get(hObject,'String')) returns contents of setMFC1 as a double
        end

        % Callback function
        function setMFC2_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to setMFC2 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of setMFC2 as text
            %        str2double(get(hObject,'String')) returns contents of setMFC2 as a double
        end

        % Callback function
        function setMFC3_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to setMFC3 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of setMFC3 as text
            %        str2double(get(hObject,'String')) returns contents of setMFC3 as a double
        end

        % Callback function
        function setMFC4_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to setMFC4 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of setMFC4 as text
            %        str2double(get(hObject,'String')) returns contents of setMFC4 as a double
        end

        % Callback function
        function setMFC5_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to setMFC5 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of setMFC5 as text
            %        str2double(get(hObject,'String')) returns contents of setMFC5 as a double
        end

        % Callback function
        function setMFC6_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to setMFC6 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of setMFC6 as text
            %        str2double(get(hObject,'String')) returns contents of setMFC6 as a double
        end

        % Callback function
        function setMFC7_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to setMFC7 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of setMFC7 as text
            %        str2double(get(hObject,'String')) returns contents of setMFC7 as a double
        end

        % Callback function
        function setMFC8_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to setMFC8 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of setMFC8 as text
            %        str2double(get(hObject,'String')) returns contents of setMFC8 as a double
        end

        % Callback function
        function shockPattern_CellEditCallback(app, event)
            % --- Executes when entered data in editable cell(s) in shockPattern.
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to shockPattern (see GCBO)
            % eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
            %	Indices: row and column indices of the cell(s) edited
            %	PreviousData: previous data for the cell(s) edited
            %	EditData: string(s) entered by the user
            %	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
            %	Error: error string when failed to convert EditData to appropriate value for Data
            % handles    structure with handles and user data (see GUIDATA)
            
            shock_pattern_raw = get(hObject,'data');
            
            if isempty(find(shock_pattern_raw))
                Pattern = logical(zeros(1,16));
            else
                temp = shock_pattern_raw;
                Pattern = [temp(1,:),temp(2,:),temp(3,:),temp(4,:)];
            end
            
            handles.shockpattern(1:8) = Pattern;
            guidata(hObject, handles);
        end

        % Callback function
        function shock_cycles_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to shock_cycles (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of shock_cycles as text
            %        str2double(get(hObject,'String')) returns contents of shock_cycles as a double
            shockCycles = str2double(get(hObject,'String'));
            
            if isempty(shockCycles)||shockCycles<1
                warndlg('shocker cycles should be a positive integer!','Wrong Input Value');
                return
            end
            
            handles.shockCycles = shockCycles;
            guidata(hObject,handles);
        end

        % Callback function
        function shock_offtime_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to shock_offtime (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of shock_offtime as text
            %        str2double(get(hObject,'String')) returns contents of shock_offtime as a double
            shockOffTime = str2double(get(hObject,'String'));
            
            if isempty(shockOffTime)||shockOffTime<10
                warndlg('shocker offTime should be a integer larger than 10ms!','Wrong Input Value');
                return
            end
            
            handles.shockOffTime = shockOffTime;
            guidata(hObject,handles);
        end

        % Callback function
        function shock_ontime_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to shock_ontime (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of shock_ontime as text
            %        str2double(get(hObject,'String')) returns contents of shock_ontime as a double
            shockOnTime = str2double(get(hObject,'String'));
            
            if isempty(shockOnTime)||shockOnTime<10
                warndlg('shocker onTime should be a integer larger than 10ms!','Wrong Input Value');
                return
            end
            
            handles.shockOnTime = shockOnTime;
            guidata(hObject,handles);
        end

        % Callback function
        function shock_volt_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to shock_volt (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of shock_volt as text
            %        str2double(get(hObject,'String')) returns contents of shock_volt as a double
            
            shockVolt = str2double(get(hObject,'String'));
            if isempty(shockVolt)||shockVolt<0||shockVolt>120
                warndlg('shock voltage should be a integer ranges from 0 to 120V!','Wrong Input Value');
                return
            end
            handles.shockVolt = shockVolt;
            guidata(hObject,handles);
        end

        % Callback function
        function temp_val1_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to temp_val1 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of temp_val1 as text
            %        str2double(get(hObject,'String')) returns contents of temp_val1 as a double
        end

        % Callback function
        function temp_val2_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to temp_val2 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of temp_val2 as text
            %        str2double(get(hObject,'String')) returns contents of temp_val2 as a double
        end

        % Callback function
        function temp_val3_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to temp_val3 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of temp_val3 as text
            %        str2double(get(hObject,'String')) returns contents of temp_val3 as a double
        end

        % Callback function
        function temp_val4_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to temp_val4 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of temp_val4 as text
            %        str2double(get(hObject,'String')) returns contents of temp_val4 as a double
        end

        % Callback function
        function temp_val5_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to temp_val5 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of temp_val5 as text
            %        str2double(get(hObject,'String')) returns contents of temp_val5 as a double
        end

        % Callback function
        function temp_val6_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to temp_val6 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of temp_val6 as text
            %        str2double(get(hObject,'String')) returns contents of temp_val6 as a double
        end

        % Callback function
        function temp_val7_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to temp_val7 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of temp_val7 as text
            %        str2double(get(hObject,'String')) returns contents of temp_val7 as a double
        end

        % Callback function
        function temp_val8_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to temp_val8 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of temp_val8 as text
            %        str2double(get(hObject,'String')) returns contents of temp_val8 as a double
        end

        % Callback function
        function test_shocker_Callback(app, event)
            % --- Executes on button press in test_shocker.
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to test_shocker (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hint: get(hObject,'Value') returns toggle state of test_shocker
            set(hObject,'enable', 'off');
            
            %use the grid shocker
            shockerparam.delayTime = 0;
            shockerparam.onTime = handles.shockOnTime;
            shockerparam.offTime = handles.shockOffTime;
            shockerparam.cycles = handles.shockCycles;
            pauseTime = (shockerparam.onTime + shockerparam.offTime)/1000*shockerparam.cycles;
            
            shockPatt = sprintf('%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d',handles.shockpattern);
            
            handles.hComm.hLEDController1.setShockPatern(shockPatt);
            
            handles.hComm.hLEDController1.setShockPulse(shockerparam);
            
            handles.hComm.shockerPS1.setVoltage(handles.shockVolt);
            
            handles.hComm.hLEDController1.startShockPulse();
            
            tstart = tic;
            
            while toc(tstart)<pauseTime
                volt = handles.hComm.shockerPS1.getVoltage();
                if ~ismepty(volt)
                    set(handles.volt_s, 'String', volt);
                end
            
                curr = handles.hComm.shockerPS1.getCurrent();
                if ~isempty(curr)
                    set(handles.current_s, 'String', Curr);
                end
            end
            
            handles.hComm.hLEDController1.stopShockPulse();
            
            handles.hComm.shockerPS1.setVoltage(0);
            
            set(hObject,'enable', 'on');
        end

        % Selection changed function: uibuttongroup1
        function uibuttongroup1_SelectionChangedFcn(app, event)
            % --- Executes when selected object is changed in uibuttongroup1.
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to the selected object in uibuttongroup1
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            handles.board1.currentVialNum = eventdata.NewValue.String;
            guidata(hObject, handles);
        end

        % Callback function
        function uibuttongroup2_SelectionChangedFcn(app, event)
            % --- Executes when selected object is changed in uibuttongroup2.
            
            % Create GUIDE-style callback args - Added by Migration Tool
        end

        % Callback function
        function uibuttongroup3_SelectionChangedFcn(app, event)
            % --- Executes when selected object is changed in uibuttongroup3.
            
        end

        % Callback function
        function uibuttongroup4_SelectionChangedFcn(app, event)
            % --- Executes when selected object is changed in uibuttongroup4.
            
            % Create GUIDE-style callback args - Added by Migration Tool
        end

        % Value changed function: valve_on
        function valve_on_Callback(app, event)
            % --- Executes on button press in valve_on.
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to valve_on (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hint: get(hObject,'Value') returns toggle state of valve_on
            
            button_state = get(hObject,'Value');
            if button_state == get(hObject,'Max')
                handles.valveON = 1;
                set(hObject,'String','OFF');
            
                handles.hComm.odormixer1.valveOn(handles.board1.currentVialNum);
            
            elseif button_state == get(hObject,'Min')
                handles.valveON = 0;
                set(hObject,'String','ON');
            
                handles.hComm.odormixer1.valveOff();
            
            end
            guidata(hObject, handles);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create figure1 and hide until all components are created
            app.figure1 = uifigure('Visible', 'off');
            colormap(app.figure1, 'parula');
            app.figure1.Position = [520 339 728 557];
            app.figure1.Name = 'OlfactoryArena_BioLuminescence';
            app.figure1.Resize = 'off';
            app.figure1.CloseRequestFcn = createCallbackFcn(app, @figure1_CloseRequestFcn, true);
            app.figure1.HandleVisibility = 'callback';
            app.figure1.Tag = 'figure1';

            % Create Vial_Control_Panel
            app.Vial_Control_Panel = uipanel(app.figure1);
            app.Vial_Control_Panel.Title = 'Vial Control';
            app.Vial_Control_Panel.Tag = 'Vial_Control_Panel';
            app.Vial_Control_Panel.FontSize = 10.6666666666667;
            app.Vial_Control_Panel.Position = [39 408 632 98];

            % Create valve_on
            app.valve_on = uibutton(app.Vial_Control_Panel, 'state');
            app.valve_on.ValueChangedFcn = createCallbackFcn(app, @valve_on_Callback, true);
            app.valve_on.Tag = 'valve_on';
            app.valve_on.Text = 'ON';
            app.valve_on.FontSize = 10.6666666666667;
            app.valve_on.Position = [434 33 30 24];

            % Create text31
            app.text31 = uilabel(app.Vial_Control_Panel);
            app.text31.Tag = 'text31';
            app.text31.HorizontalAlignment = 'center';
            app.text31.VerticalAlignment = 'top';
            app.text31.WordWrap = 'on';
            app.text31.FontSize = 10.6666666666667;
            app.text31.Position = [39 38 52 14];
            app.text31.Text = 'Board 1';

            % Create uibuttongroup1
            app.uibuttongroup1 = uibuttongroup(app.Vial_Control_Panel);
            app.uibuttongroup1.SelectionChangedFcn = createCallbackFcn(app, @uibuttongroup1_SelectionChangedFcn, true);
            app.uibuttongroup1.Tag = 'uibuttongroup1';
            app.uibuttongroup1.FontSize = 10.6666666666667;
            app.uibuttongroup1.Position = [124 30 215 29];

            % Create RB15
            app.RB15 = uiradiobutton(app.uibuttongroup1);
            app.RB15.Tag = 'RB15';
            app.RB15.Text = '4';
            app.RB15.FontSize = 10.6666666666667;
            app.RB15.Position = [172 4 39 23];

            % Create RB14
            app.RB14 = uiradiobutton(app.uibuttongroup1);
            app.RB14.Tag = 'RB14';
            app.RB14.Text = '3';
            app.RB14.FontSize = 10.6666666666667;
            app.RB14.Position = [133 4 33 23];

            % Create RB13
            app.RB13 = uiradiobutton(app.uibuttongroup1);
            app.RB13.Tag = 'RB13';
            app.RB13.Text = '2';
            app.RB13.FontSize = 10.6666666666667;
            app.RB13.Position = [94 4 33 23];

            % Create RB12
            app.RB12 = uiradiobutton(app.uibuttongroup1);
            app.RB12.Tag = 'RB12';
            app.RB12.Text = '1';
            app.RB12.FontSize = 10.6666666666667;
            app.RB12.Position = [55 4 33 23];

            % Create RB11
            app.RB11 = uiradiobutton(app.uibuttongroup1);
            app.RB11.Tag = 'RB11';
            app.RB11.Text = '0';
            app.RB11.FontSize = 10.6666666666667;
            app.RB11.Position = [13 5 32 23];
            app.RB11.Value = true;

            % Create uipanel18
            app.uipanel18 = uipanel(app.figure1);
            app.uipanel18.Title = 'Experiments';
            app.uipanel18.Tag = 'uipanel18';
            app.uipanel18.FontSize = 10.6666666666667;
            app.uipanel18.Position = [39 24 627 355];

            % Create Environment_Panel
            app.Environment_Panel = uipanel(app.uipanel18);
            app.Environment_Panel.Title = 'Environment';
            app.Environment_Panel.Tag = 'Environment_Panel';
            app.Environment_Panel.FontSize = 10.6666666666667;
            app.Environment_Panel.Position = [23 120 574 154];

            % Create text15
            app.text15 = uilabel(app.Environment_Panel);
            app.text15.Tag = 'text15';
            app.text15.VerticalAlignment = 'top';
            app.text15.WordWrap = 'on';
            app.text15.FontSize = 10.6666666666667;
            app.text15.Position = [74 87 50 19.5];
            app.text15.Text = 'Temp (C)';

            % Create mfr_val1
            app.mfr_val1 = uieditfield(app.Environment_Panel, 'text');
            app.mfr_val1.Tag = 'mfr_val1';
            app.mfr_val1.HorizontalAlignment = 'center';
            app.mfr_val1.FontSize = 10.6666666666667;
            app.mfr_val1.Enable = 'off';
            app.mfr_val1.Position = [134 51 49 24];
            app.mfr_val1.Value = '0';

            % Create temp_val1
            app.temp_val1 = uieditfield(app.Environment_Panel, 'text');
            app.temp_val1.Tag = 'temp_val1';
            app.temp_val1.HorizontalAlignment = 'center';
            app.temp_val1.FontSize = 10.6666666666667;
            app.temp_val1.Enable = 'off';
            app.temp_val1.Position = [134 85 48 24];
            app.temp_val1.Value = '0';

            % Create mfr_val2
            app.mfr_val2 = uieditfield(app.Environment_Panel, 'text');
            app.mfr_val2.Tag = 'mfr_val2';
            app.mfr_val2.HorizontalAlignment = 'center';
            app.mfr_val2.FontSize = 10.6666666666667;
            app.mfr_val2.Enable = 'off';
            app.mfr_val2.Position = [209 51 49 24];
            app.mfr_val2.Value = '0';

            % Create temp_val2
            app.temp_val2 = uieditfield(app.Environment_Panel, 'text');
            app.temp_val2.Tag = 'temp_val2';
            app.temp_val2.HorizontalAlignment = 'center';
            app.temp_val2.FontSize = 10.6666666666667;
            app.temp_val2.Enable = 'off';
            app.temp_val2.Position = [209 85 48 24];
            app.temp_val2.Value = '0';

            % Create text16
            app.text16 = uilabel(app.Environment_Panel);
            app.text16.Tag = 'text16';
            app.text16.VerticalAlignment = 'top';
            app.text16.WordWrap = 'on';
            app.text16.FontSize = 10.6666666666667;
            app.text16.Position = [74 47 49 32.5];
            app.text16.Text = 'Flow rate (CCM)';

            % Create text26
            app.text26 = uilabel(app.Environment_Panel);
            app.text26.Tag = 'text26';
            app.text26.HorizontalAlignment = 'center';
            app.text26.VerticalAlignment = 'top';
            app.text26.WordWrap = 'on';
            app.text26.FontSize = 10.6666666666667;
            app.text26.Position = [133 113 52 14];
            app.text26.Text = 'MFC1';

            % Create text27
            app.text27 = uilabel(app.Environment_Panel);
            app.text27.Tag = 'text27';
            app.text27.HorizontalAlignment = 'center';
            app.text27.VerticalAlignment = 'top';
            app.text27.WordWrap = 'on';
            app.text27.FontSize = 10.6666666666667;
            app.text27.Position = [210 113 52 14];
            app.text27.Text = 'MFC2';

            % Create psia_val1
            app.psia_val1 = uieditfield(app.Environment_Panel, 'text');
            app.psia_val1.Tag = 'psia_val1';
            app.psia_val1.HorizontalAlignment = 'center';
            app.psia_val1.FontSize = 10.6666666666667;
            app.psia_val1.Enable = 'off';
            app.psia_val1.Position = [134 17 49 24];
            app.psia_val1.Value = '0';

            % Create psia_val2
            app.psia_val2 = uieditfield(app.Environment_Panel, 'text');
            app.psia_val2.Tag = 'psia_val2';
            app.psia_val2.HorizontalAlignment = 'center';
            app.psia_val2.FontSize = 10.6666666666667;
            app.psia_val2.Enable = 'off';
            app.psia_val2.Position = [209 17 49 24];
            app.psia_val2.Value = '0';

            % Create text30
            app.text30 = uilabel(app.Environment_Panel);
            app.text30.Tag = 'text30';
            app.text30.HorizontalAlignment = 'center';
            app.text30.VerticalAlignment = 'top';
            app.text30.WordWrap = 'on';
            app.text30.FontSize = 10.6666666666667;
            app.text30.Position = [73 21 49 17];
            app.text30.Text = 'PSIA';

            % Create temp_rig
            app.temp_rig = uieditfield(app.Environment_Panel, 'text');
            app.temp_rig.Tag = 'temp_val1';
            app.temp_rig.HorizontalAlignment = 'center';
            app.temp_rig.FontSize = 10.6666666666667;
            app.temp_rig.Enable = 'off';
            app.temp_rig.Position = [432 83 48 24];
            app.temp_rig.Value = '0';

            % Create humidity_rig
            app.humidity_rig = uieditfield(app.Environment_Panel, 'text');
            app.humidity_rig.Tag = 'temp_val2';
            app.humidity_rig.HorizontalAlignment = 'center';
            app.humidity_rig.FontSize = 10.6666666666667;
            app.humidity_rig.Enable = 'off';
            app.humidity_rig.Position = [432 22 48 24];
            app.humidity_rig.Value = '0';

            % Create text26_2
            app.text26_2 = uilabel(app.Environment_Panel);
            app.text26_2.Tag = 'text26';
            app.text26_2.HorizontalAlignment = 'center';
            app.text26_2.VerticalAlignment = 'top';
            app.text26_2.WordWrap = 'on';
            app.text26_2.FontSize = 10.6666666666667;
            app.text26_2.Position = [417 110 78 19];
            app.text26_2.Text = 'Temp of Rig';

            % Create text27_2
            app.text27_2 = uilabel(app.Environment_Panel);
            app.text27_2.Tag = 'text27';
            app.text27_2.HorizontalAlignment = 'center';
            app.text27_2.VerticalAlignment = 'top';
            app.text27_2.WordWrap = 'on';
            app.text27_2.FontSize = 10.6666666666667;
            app.text27_2.Position = [430 46 52 22];
            app.text27_2.Text = 'Humidity';

            % Create current_step
            app.current_step = uitextarea(app.uipanel18);
            app.current_step.ValueChangedFcn = createCallbackFcn(app, @current_step_Callback, true);
            app.current_step.Tag = 'current_step';
            app.current_step.FontSize = 10.6666666666667;
            app.current_step.Position = [112 11 159 96];

            % Create text21
            app.text21 = uilabel(app.uipanel18);
            app.text21.Tag = 'text21';
            app.text21.VerticalAlignment = 'top';
            app.text21.WordWrap = 'on';
            app.text21.FontSize = 10.6666666666667;
            app.text21.Position = [26 80 66 19];
            app.text21.Text = 'Current trail';

            % Create select_exp
            app.select_exp = uibutton(app.uipanel18, 'state');
            app.select_exp.ValueChangedFcn = createCallbackFcn(app, @select_exp_Callback, true);
            app.select_exp.Tag = 'select_exp';
            app.select_exp.Text = 'Select';
            app.select_exp.FontSize = 10.6666666666667;
            app.select_exp.Position = [452 282 51 25.9999999999999];

            % Create run_exp
            app.run_exp = uibutton(app.uipanel18, 'state');
            app.run_exp.ValueChangedFcn = createCallbackFcn(app, @run_exp_Callback, true);
            app.run_exp.Tag = 'run_exp';
            app.run_exp.Text = 'Run';
            app.run_exp.FontSize = 10.6666666666667;
            app.run_exp.Position = [510 283 51 26];

            % Create exp_name
            app.exp_name = uieditfield(app.uipanel18, 'text');
            app.exp_name.ValueChangedFcn = createCallbackFcn(app, @exp_name_Callback, true);
            app.exp_name.Tag = 'exp_name';
            app.exp_name.FontSize = 10.6666666666667;
            app.exp_name.Position = [23 286 421 23];

            % Create text20
            app.text20 = uilabel(app.uipanel18);
            app.text20.Tag = 'text20';
            app.text20.VerticalAlignment = 'top';
            app.text20.WordWrap = 'on';
            app.text20.FontSize = 10.6666666666667;
            app.text20.Position = [23 313 121 19];
            app.text20.Text = 'Exp protocol file';

            % Show the figure after all components are created
            app.figure1.Visible = 'on';
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function OlfactoryArena_BioLuminescence_OpeningFcn(app, varargin)
            % --- Executes just before OlfactoryArena_BioLuminescence is made visible.
            
            % Add runtime required configuration - Added by Migration Tool
            addRuntimeConfigurations(app);
            
            % Ensure that the app appears on screen when run
            movegui(app.figure1, 'onscreen');
            app.figure1.Name = ['OlfactoryArena_BioLuminescence - ', getBuildStamp(app)];
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app); %#ok<ASGLU>
            
            % This function has no output args, see OutputFcn.
            % hObject    handle to figure
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            % varargin   command line arguments to OlfactoryArena_BioLuminescence (see VARARGIN)
            
            % Choose default command line output for OlfactoryArena_BioLuminescence
            handles.output = hObject;
            
            olfactoryArena_user_setting;
            
            hComm = initialize_olfactoryArena;
            handles.hComm = hComm;

            try
                ensure_C8855_server(app);
            catch ME
                warning('C8855:ServerStartupFailed', 'Failed to launch the PMT TCP server: %s', ME.message);
            end
            
            % add this per Kristin's request
            if ~exist('PreconSensor','file')
                p = fileparts(mfilename('fullpath'));
                addpath(genpath(p));
            end
            
            handles.THUpdateP = THUpdateP;
            
            handles.tTemp = timer('StartDelay', 3, 'Period', handles.THUpdateP, 'ExecutionMode', 'fixedRate', 'TimerFcn',{@app.displayTempMfr, handles.figure1} );
            %guidata(hObject, handles); Do I need to update the handles before the
            
            if ~(handles.hComm.MFC1.serialPort == 0)
                start(handles.tTemp);
            end
            
            handles.expDefaultDir = expDefaultDir;
            handles.expProtocolDir = expProtocolDir;
            handles.expDataDir = expDataDir;
            handles.defaultMetaXmlFile = defaultMetaXmlFile;
            handles.defaultExpNotesFile = defaultExpNotesFile;
            handles.rig = rigName;
            
            handles.board1.currentVialNum = '4';
            
            handles.Blu_int_val = 0;
            handles.Grn_int_val = 0;
            handles.Chr_int_val = 0;
            
            %handles.defaultProtocol = defaultProtocol;
            
            % Update handles structure
            handles.pulseWidth = 0;
            handles.pulsePeriod = 0;
            handles.expRun = 0;
            handles.LEDPattern = '1111';
            %handles.protocol.duration = stepDuration;
            
            
            %shock pattern in the order of board4 board3 board2 board1
            handles.shockpattern = logical([0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1]);
            
            handles.shockVolt = 10;
            handles.shockOnTime = 1000;
            handles.shockOffTime = 1000;
            handles.shockCycles = 10;
            
            %find default metadata xml file
            %updateLineNames;
            %updateEffectors;
            
            %reset MFC to default value
            %setMFC_Callback(handles.setMFC,eventdata,handles);
            
            guidata(hObject, handles);
            
            % UIWAIT makes OlfactoryArena_BioLuminescence wait for user response (see UIRESUME)
            % uiwait(handles.figure1);
        end

        % Callback function
        function BluInt_Callback(app, event)
            % --- Executes on slider movement.
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to BluInt (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'Value') returns position of slider
            %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
            Blu_int_val = round(get(hObject,'Value')*100);   % this is done so only one dec place
            set(handles.BluIntVal, 'String', [num2str(Blu_int_val) '%']);
            handles.Blu_int_val = Blu_int_val;
            %send command to controller
            handles.hComm.LEDController1.setBlueLEDPower(Blu_int_val, 0, handles.LEDPattern);
            guidata(hObject, handles);
        end

        % Callback function
        function ChrInt_Callback(app, event)
            % --- Executes on slider movement.
            
            % Create GUIDE-style callback args - Added by Migration Tool
        end

        % Callback function
        function GrnInt_Callback(app, event)

        end

        % Callback function
        function IrInt_Callback(app, event)

        end

        % Callback function
        function OnOff_Callback(app, event)

        end

        % Value changed function: current_step
        function current_step_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to current_step (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of current_step as text
            %        str2double(get(hObject,'String')) returns contents of current_step as a double
        end

        % Value changed function: exp_name
        function exp_name_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to exp_name (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of exp_name as text
            %        str2double(get(hObject,'String')) returns contents of exp_name as a double
        end

        % Close request function: figure1
        function figure1_CloseRequestFcn(app, event)
            % --- Executes when user attempts to close figure1.
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to figure1 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            % Hint: delete(hObject) closes the figure
            
            %close the serial port connection
            %turn off IR
            
            %stop update temp and humdity. clear the timer
            try
                stop_C8855(app);
                disconnect_C8855(app);
                if ~(handles.hComm.MFC1.serialPort == 0)
                    stop(handles.tTemp);
                end
                %JL10092025 wait one second to finish timer callback to avoid polldata from MFC
                pause(3);
                handles.hComm.LEDController1.setIRLEDPower(0);
                clearup_olfactoryArena(handles.hComm)
            
            catch ME
                disp(ME);
            end
            delete(hObject);
            %close all;
            clear all;
        end

        % Callback function
        function mfr_val1_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to mfr_val1 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of mfr_val1 as text
            %        str2double(get(hObject,'String')) returns contents of mfr_val1 as a double
        end

        % Callback function
        function mfr_val2_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to mfr_val2 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of mfr_val2 as text
            %        str2double(get(hObject,'String')) returns contents of mfr_val2 as a double
        end

        % Callback function
        function mfr_val3_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to mfr_val3 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of mfr_val3 as text
            %        str2double(get(hObject,'String')) returns contents of mfr_val3 as a double
        end

        % Callback function
        function mfr_val4_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, ~] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to mfr_val4 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of mfr_val4 as text
            %        str2double(get(hObject,'String')) returns contents of mfr_val4 as a double
        end

        % Callback function
        function mfr_val5_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to mfr_val5 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of mfr_val5 as text
            %        str2double(get(hObject,'String')) returns contents of mfr_val5 as a double
        end

        % Callback function
        function mfr_val6_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to mfr_val6 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of mfr_val6 as text
            %        str2double(get(hObject,'String')) returns contents of mfr_val6 as a double
        end

        % Callback function
        function mfr_val7_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to mfr_val7 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of mfr_val7 as text
            %        str2double(get(hObject,'String')) returns contents of mfr_val7 as a double
        end

        % Callback function
        function mfr_val8_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to mfr_val8 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of mfr_val8 as text
            %        str2double(get(hObject,'String')) returns contents of mfr_val8 as a double
        end

        % Callback function
        function psia_val1_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to psia_val1 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of psia_val1 as text
            %        str2double(get(hObject,'String')) returns contents of psia_val1 as a double
        end

        % Callback function
        function psia_val2_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to psia_val2 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of psia_val2 as text
            %        str2double(get(hObject,'String')) returns contents of psia_val2 as a double
        end

        % Callback function
        function psia_val3_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to psia_val3 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of psia_val3 as text
            %        str2double(get(hObject,'String')) returns contents of psia_val3 as a double
        end

        % Callback function
        function psia_val4_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to psia_val4 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of psia_val4 as text
            %        str2double(get(hObject,'String')) returns contents of psia_val4 as a double
        end

        % Callback function
        function psia_val5_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to psia_val5 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of psia_val5 as text
            %        str2double(get(hObject,'String')) returns contents of psia_val5 as a double
        end

        % Callback function
        function psia_val6_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to psia_val6 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of psia_val6 as text
            %        str2double(get(hObject,'String')) returns contents of psia_val6 as a double
        end

        % Callback function
        function psia_val7_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to psia_val7 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of psia_val7 as text
            %        str2double(get(hObject,'String')) returns contents of psia_val7 as a double
        end

        % Callback function
        function psia_val8_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to psia_val8 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of psia_val8 as text
            %        str2double(get(hObject,'String')) returns contents of psia_val8 as a double
        end

        % Value changed function: run_exp
        function run_exp_Callback(app, event)
            % --- Executes on button press in run_exp.
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to run_exp (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hint: get(hObject,'Value') returns toggle state of run_exp
            
            button_state = get(hObject,'Value');
            %button is down, start experiment
            if button_state == get(hObject,'Max')
                handles.flagAborted = 0;
                handles.lastStepCount = -1;
                handles.expRun = 1;
                handles.isRecording = 0;
                guidata(hObject, handles);
                set(hObject,'String','ABORT');
            
                %stop update the temperature and humidity value
                if ~(handles.hComm.MFC1.serialPort == 0)
                    stop(handles.tTemp);
                end
            
                %disable those inputs
                set(findall(handles.Vial_Control_Panel, '-property', 'enable'), 'enable', 'off');
                set(findall(handles.Environment_Panel, '-property', 'enable'), 'enable', 'off');
                set(handles.select_exp, 'enable', 'off');
            
                handles.protocol.valveOffIsDone(1:handles.protocol.totalStepNum) = zeros(1,handles.protocol.totalStepNum);
                handles.protocol.valveOnIsDone(1:handles.protocol.totalStepNum) = zeros(1,handles.protocol.totalStepNum);
            
            
                %% input meta data information
                defaultsFile = handles.defaultMetaXmlFile;
            
                % Load defaults XML tree from sample file
                defaultsTree = loadXMLDefaultsTree(defaultsFile);
            
                [pathstr, protocolName, ext]  = fileparts(handles.expFile);
                %    defaultsTree.setValueByPathString('protocol', protocolName);
                %defaultsTree.setValueByPathString('exp_datetime', datestr(now,30));
                defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'IR_intensity'}, num2str(0));
                %defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'LED_intensity_scale'}, handles.intensityMode);
            
                if ~(handles.hComm.THSensor == 0)
                    [temp,humid,~,~] = handles.hComm.THSensor.read(1);
                    defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'temperature'}, num2str(temp));
                    defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'humidity'}, num2str(humid));
                end
            
                if ~(handles.hComm.MFC1.serialPort == 0)
                    results = handles.hComm.MFC1.pollData('C');
                    if ~isempty(results)
                        defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC1_temp'}, num2str(results.temp))
                        defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC1_massFlow'}, num2str(results.volumetricFlow))
                        defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC1_pressure'}, num2str(results.pressure))
                    end
                end
            
                if ~(handles.hComm.MFC2.serialPort == 0)
                    results = handles.hComm.MFC2.pollData('D');
                    if ~isempty(results)
                        defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC2_temp'}, num2str(results.temp))
                        defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC2_massFlow'}, num2str(results.volumetricFlow))
                        defaultsTree.setValueByUniquePath({'olfactoryArena' 'environment' 'MFC2_pressure'}, num2str(results.pressure))
                    end
                end
            
                % defaultsTree.setValueByUniquePath({'olfactoryArena' 'flies' 'genotype'},...
                %     [defaultsTree.getValueByUniquePath({'olfactoryArena','flies', 'male_parent'}), '_',...
                %     defaultsTree.getValueByUniquePath({'olfactoryArena','flies', 'female_parent'})]);
            
                %defaultsTree.setValueByUniquePath({'OlfactoryArena_BioLuminescence' 'flies' 'genotype' 'content'}, 'abcd');
                handles.protocolName= protocolName;
            
                % Create figure in which to place JIDE property grid
                fig = figure( ...
                    'MenuBar', 'none', ...
                    'Name', 'Metadata Input GUI', ...
                    'NumberTitle', 'off', ...
                    'Toolbar', 'none' ...
                    );
            
                % Create JIDE PropertyGrid and display defaults data in figure
                pgrid = PropertyGrid(fig,'Position', [0 0 1 1]);
                pgrid.setDefaultsTree(defaultsTree, 'advanced');
            
                % Block unit figure is destroyed
                uiwait(fig);
                defaultsTree.setValueByUniquePath({'olfactoryArena' 'flies' 'genotype'},...
                    [defaultsTree.getValueByUniquePath({'olfactoryArena','flies', 'male_parent'}),'_' ...
                    defaultsTree.getValueByUniquePath({'olfactoryArena','flies', 'female_parent'})]);
            
                % Create XML meta data file from defaults tree. Note we haven't checked if
                % we have all the required values filled in, but this is suppose to be a
                % simple example - I'll show how to do this in a more ellaborate example.
                metaData = createXMLMetaData(defaultsTree);
            
                % Save defaultsTree as xml file. Note, the current values for all the meta
                % data are saved in the tree so that it is possible to have meata data whose
                % default option is to use the last value used.
                defaultsTree.write(defaultsFile);
            
                % Save meta tree as xml file
                currentDate = datestr(now, 29);
                tempPath1 = [handles.expDataDir, '\', currentDate];
                if ~exist(tempPath1, 'dir')
                    mkdir(tempPath1);
                end
            
                mParentName = metaData.children(2).attribute.male_parent;
                fParentName = metaData.children(2).attribute.female_parent;
                handles.expStartTime = datestr(now,30);
            
                for i = 1:1
                    dataPath = [tempPath1, '\', handles.expStartTime, '_',handles.rig, '_',...
                        'Cam', num2str(i-1), '_', protocolName,'_',mParentName,'_',fParentName];
            
                    if length(dataPath)>255
                        dataPath = [tempPath1, '\', handles.expStartTime,'_', handles.rig, '_',...
                            'Cam', num2str(i-1),'_', protocolName];
                    end
            
                    if ~exist(dataPath, 'dir')
                        tempPath2 = dataPath;
                        mkdir(tempPath2);
                    end
                    handles.expDataSubdir{i} = tempPath2;
                end

                start_C8855(app, handles.expDataSubdir{1});
            
                %% save data files
                for i = 1:1
                    %save the meta data file
                    metaDataFile = [handles.expDataSubdir{i}, '\metaData.xml'];
                    metaData.write(metaDataFile);
            
                    % save the protocol file
                    protocol = handles.protocol;
                    protocolFile = [handles.expDataSubdir{i}, '\protocol.mat'];
                    save(protocolFile,'protocol');
                    protocolExl = [handles.expDataSubdir{i}, '\protocol.xlsx'];
                    copyfile(handles.expFile, protocolExl);
                    protocolCSV = [handles.expDataSubdir{i}, '\protocol.csv'];
                end
            
                % create an experiment timestamp file
                expTimeFile = [handles.expDataSubdir{1}, '\expTimeStamp.txt'];
                handles.expTimeFileID = fopen(expTimeFile, 'w+');
            
                %stop preview mode
                % for i = 1:length(handles.hComm.flea3)
                %     if ~(handles.hComm.flea3(i) == 0)
                %         flyBowl_camera_control(handles.hComm.flea3(i),'stop');
                %     end
                % end
            
                handles.tExperiment = timer('TimerFcn',{@app.experiment, handles.figure1},'Period',0.1, 'ExecutionMode', 'fixedRate');
                guidata(hObject, handles);
                handles.hComm.LEDController1.runExperiment();
                %JL100925 add a wait time to avoid serial read error in experiment()
                %pause(1.2);
                start(handles.tExperiment);
            
            else
                %abort experiment
                handles.flagAborted = 1;
                guidata(hObject, handles);
                handles = saveDataAfterAbortOrFinished(app, handles);
            end
        end

        % Value changed function: select_exp
        function select_exp_Callback(app, event)
            % --- Executes on button press in select_exp.
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to select_exp (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hint: get(hObject,'Value') returns toggle state of select_exp
            % oldPath = pwd;
            % cd(handles.expProtocolDir);
            [filename, pathname] = uigetfile([handles.expProtocolDir,'\*.xls; *.xlsx;'], 'Select an experiment file');
            if isequal(filename,0)
                return
            else
                expFile = fullfile(pathname, filename);
                set(handles.exp_name, 'string', expFile);
                handles.expFile = expFile;
                [~,~,protocolExt] = fileparts(expFile);
            end
            
            switch protocolExt
                case {'.csv'}
                    [intext, indata] = csvread_with_headers(expFile);

                case {'.xls', '.xlsx'}
                    [indata,intext,~] = xlsread(expFile);

                otherwise
                    disp('Unknown protocol file type.')
                    return
            end

            handles.protocol.vialNum = zeros(size(indata,1),1);
            handles.ProtocolHeader = intext(1,:);
            handles.ProtocolData = indata;

            %trial control
            handles.protocol.stepNum= indata(:,1);
            handles.protocol.duration = indata(:,2);

            %Vial control
            handles.protocol.vialNum(:,1)= indata(:,3);
            handles.protocol.valveDelay= indata(:,4);
            handles.protocol.valveOnTime = indata(:,5);

            
            handles.protocol.totalStepNum = length(handles.protocol.stepNum);
            handles.totalDuration = sum(handles.protocol.duration(:));
            
            for stepIndex = 1:handles.protocol.totalStepNum
            
                if stepIndex == 1
                    handles.protocol.stepStartTime(stepIndex) = 0;
                else
                    handles.protocol.stepStartTime(stepIndex) = handles.protocol.stepStartTime(stepIndex-1) + handles.protocol.duration(stepIndex-1);
                end
            
                handles.protocol.valveOnInSec(stepIndex) = handles.protocol.stepStartTime(stepIndex) + handles.protocol.valveDelay(stepIndex);
                handles.protocol.valveOffInSec(stepIndex) = handles.protocol.valveOnInSec(stepIndex) + handles.protocol.valveOnTime(stepIndex);
            
            
                %if valve on time is zero,
                if handles.protocol.valveOnTime(stepIndex) == 0
                    handles.protocol.valveOnInSec(stepIndex) = 0;
                    handles.protocol.valveOffInSec(stepIndex) = 0;
                end
            
                %if the valve on time is same as last valve off time then keep the vlave on
                if (stepIndex > 1)
                    %if handles.protocol.vialNum(stepIndex,1)==handles.protocol.vialNum(stepIndex-1,1) && (handles.protocol.valveOnInSec(stepIndex) == handles.protocol.valveOffInSec(stepIndex-1))
                    % fix Consecutive writes to a digital line occurred more frequently than the device can safely allow.
                    if (handles.protocol.valveOnInSec(stepIndex) == handles.protocol.valveOffInSec(stepIndex-1))
                        handles.protocol.valveOffInSec(stepIndex-1) = 0;
                    end
                end
            
                oneStep(stepIndex).RedIntensity = 10;
                oneStep(stepIndex).GrnIntensity = 0;
                oneStep(stepIndex).BluIntensity = 0;
            
                %binary array
                oneStep(stepIndex).Pattern = '00000000';
            
            
                %oneStep(stepIndex).NumStep = handles.protocol.stepNum(stepIndex);
                oneStep(stepIndex).NumStep = stepIndex;
                oneStep(stepIndex).Duration = handles.protocol.duration(stepIndex);  %in seconds
                oneStep(stepIndex).DelayTime = 0;
                %red light
                oneStep(stepIndex).RedPulseWidth = 100;
                oneStep(stepIndex).RedPulsePeriod = 100;
                oneStep(stepIndex).RedPulseNum = 1;
                oneStep(stepIndex).RedOffTime = 0;
                oneStep(stepIndex).RedIteration = 1;
            
                %green light
                oneStep(stepIndex).GrnPulseWidth = 0;
                oneStep(stepIndex).GrnPulsePeriod = 0;
                oneStep(stepIndex).GrnPulseNum = 0;
                oneStep(stepIndex).GrnOffTime = 0;
                oneStep(stepIndex).GrnIteration = 0;
            
                %blue light
                oneStep(stepIndex).BluPulseWidth = 0;
                oneStep(stepIndex).BluPulsePeriod = 0;
                oneStep(stepIndex).BluPulseNum = 0;
                oneStep(stepIndex).BluOffTime = 0;
                oneStep(stepIndex).BluIteration = 0;
            
            end
            
            
            %remove all experiment steporders
            handles.hComm.LEDController1.removeAllExperimentSteps();
            
            %add new experiment steps
            try
                for stepIndex = 1:handles.protocol.totalStepNum
                    totalSteps = handles.hComm.LEDController1.addOneStep(oneStep(stepIndex));
                end
            
                if totalSteps == handles.protocol.totalStepNum
                    expData = handles.hComm.LEDController1.getExperimentSteps();
                    disp(expData);
                    set(handles.run_exp,'enable', 'on');
                else
                    errID = 'LEDController:UploadProtocolError';
                    msgtext = 'The LED protocol upload failed.';
            
                    ME = MException(errID,msgtext);
                    throw(ME);
                end
            
            catch ME
                errorMessage = sprintf('Error in uploading LED protocol.\n %s\n', ...
                    ME.message);
                uiwait(warndlg(errorMessage));
                set(handles.run_exp,'enable', 'off');
            end
            
            
            %get whole Valve pattern
            for i = 1:size(handles.protocol.vialNum, 1)
                handles.protocol.valvePatt{i} = handles.protocol.vialNum(i,:);
            end
            
            guidata(hObject, handles);
        end

        % Callback function
        function setMFC1_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to setMFC1 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of setMFC1 as text
            %        str2double(get(hObject,'String')) returns contents of setMFC1 as a double
        end

        % Callback function
        function setMFC2_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to setMFC2 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of setMFC2 as text
            %        str2double(get(hObject,'String')) returns contents of setMFC2 as a double
        end

        % Callback function
        function setMFC3_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to setMFC3 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of setMFC3 as text
            %        str2double(get(hObject,'String')) returns contents of setMFC3 as a double
        end

        % Callback function
        function setMFC4_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to setMFC4 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of setMFC4 as text
            %        str2double(get(hObject,'String')) returns contents of setMFC4 as a double
        end

        % Callback function
        function setMFC5_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to setMFC5 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of setMFC5 as text
            %        str2double(get(hObject,'String')) returns contents of setMFC5 as a double
        end

        % Callback function
        function setMFC6_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to setMFC6 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of setMFC6 as text
            %        str2double(get(hObject,'String')) returns contents of setMFC6 as a double
        end

        % Callback function
        function setMFC7_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to setMFC7 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of setMFC7 as text
            %        str2double(get(hObject,'String')) returns contents of setMFC7 as a double
        end

        % Callback function
        function setMFC8_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to setMFC8 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of setMFC8 as text
            %        str2double(get(hObject,'String')) returns contents of setMFC8 as a double
        end

        % Callback function
        function shockPattern_CellEditCallback(app, event)
            % --- Executes when entered data in editable cell(s) in shockPattern.
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to shockPattern (see GCBO)
            % eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
            %	Indices: row and column indices of the cell(s) edited
            %	PreviousData: previous data for the cell(s) edited
            %	EditData: string(s) entered by the user
            %	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
            %	Error: error string when failed to convert EditData to appropriate value for Data
            % handles    structure with handles and user data (see GUIDATA)
            
            shock_pattern_raw = get(hObject,'data');
            
            if isempty(find(shock_pattern_raw))
                Pattern = logical(zeros(1,16));
            else
                temp = shock_pattern_raw;
                Pattern = [temp(1,:),temp(2,:),temp(3,:),temp(4,:)];
            end
            
            handles.shockpattern(1:8) = Pattern;
            guidata(hObject, handles);
        end

        % Callback function
        function shock_cycles_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to shock_cycles (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of shock_cycles as text
            %        str2double(get(hObject,'String')) returns contents of shock_cycles as a double
            shockCycles = str2double(get(hObject,'String'));
            
            if isempty(shockCycles)||shockCycles<1
                warndlg('shocker cycles should be a positive integer!','Wrong Input Value');
                return
            end
            
            handles.shockCycles = shockCycles;
            guidata(hObject,handles);
        end

        % Callback function
        function shock_offtime_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to shock_offtime (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of shock_offtime as text
            %        str2double(get(hObject,'String')) returns contents of shock_offtime as a double
            shockOffTime = str2double(get(hObject,'String'));
            
            if isempty(shockOffTime)||shockOffTime<10
                warndlg('shocker offTime should be a integer larger than 10ms!','Wrong Input Value');
                return
            end
            
            handles.shockOffTime = shockOffTime;
            guidata(hObject,handles);
        end

        % Callback function
        function shock_ontime_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to shock_ontime (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of shock_ontime as text
            %        str2double(get(hObject,'String')) returns contents of shock_ontime as a double
            shockOnTime = str2double(get(hObject,'String'));
            
            if isempty(shockOnTime)||shockOnTime<10
                warndlg('shocker onTime should be a integer larger than 10ms!','Wrong Input Value');
                return
            end
            
            handles.shockOnTime = shockOnTime;
            guidata(hObject,handles);
        end

        % Callback function
        function shock_volt_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to shock_volt (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of shock_volt as text
            %        str2double(get(hObject,'String')) returns contents of shock_volt as a double
            
            shockVolt = str2double(get(hObject,'String'));
            if isempty(shockVolt)||shockVolt<0||shockVolt>120
                warndlg('shock voltage should be a integer ranges from 0 to 120V!','Wrong Input Value');
                return
            end
            handles.shockVolt = shockVolt;
            guidata(hObject,handles);
        end

        % Callback function
        function temp_val1_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to temp_val1 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of temp_val1 as text
            %        str2double(get(hObject,'String')) returns contents of temp_val1 as a double
        end

        % Callback function
        function temp_val2_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to temp_val2 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of temp_val2 as text
            %        str2double(get(hObject,'String')) returns contents of temp_val2 as a double
        end

        % Callback function
        function temp_val3_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to temp_val3 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of temp_val3 as text
            %        str2double(get(hObject,'String')) returns contents of temp_val3 as a double
        end

        % Callback function
        function temp_val4_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to temp_val4 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of temp_val4 as text
            %        str2double(get(hObject,'String')) returns contents of temp_val4 as a double
        end

        % Callback function
        function temp_val5_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to temp_val5 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of temp_val5 as text
            %        str2double(get(hObject,'String')) returns contents of temp_val5 as a double
        end

        % Callback function
        function temp_val6_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to temp_val6 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of temp_val6 as text
            %        str2double(get(hObject,'String')) returns contents of temp_val6 as a double
        end

        % Callback function
        function temp_val7_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to temp_val7 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of temp_val7 as text
            %        str2double(get(hObject,'String')) returns contents of temp_val7 as a double
        end

        % Callback function
        function temp_val8_Callback(app, event)
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to temp_val8 (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hints: get(hObject,'String') returns contents of temp_val8 as text
            %        str2double(get(hObject,'String')) returns contents of temp_val8 as a double
        end

        % Callback function
        function test_shocker_Callback(app, event)
            % --- Executes on button press in test_shocker.
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to test_shocker (see GCBO)
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            % Hint: get(hObject,'Value') returns toggle state of test_shocker
            set(hObject,'enable', 'off');
            
            %use the grid shocker
            shockerparam.delayTime = 0;
            shockerparam.onTime = handles.shockOnTime;
            shockerparam.offTime = handles.shockOffTime;
            shockerparam.cycles = handles.shockCycles;
            pauseTime = (shockerparam.onTime + shockerparam.offTime)/1000*shockerparam.cycles;
            
            shockPatt = sprintf('%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d',handles.shockpattern);
            
            handles.hComm.hLEDController1.setShockPatern(shockPatt);
            
            handles.hComm.hLEDController1.setShockPulse(shockerparam);
            
            handles.hComm.shockerPS1.setVoltage(handles.shockVolt);
            
            handles.hComm.hLEDController1.startShockPulse();
            
            tstart = tic;
            
            while toc(tstart)<pauseTime
                volt = handles.hComm.shockerPS1.getVoltage();
                if ~ismepty(volt)
                    set(handles.volt_s, 'String', volt);
                end
            
                curr = handles.hComm.shockerPS1.getCurrent();
                if ~isempty(curr)
                    set(handles.current_s, 'String', Curr);
                end
            end
            
            handles.hComm.hLEDController1.stopShockPulse();
            
            handles.hComm.shockerPS1.setVoltage(0);
            
            set(hObject,'enable', 'on');
        end

        % Selection changed function: uibuttongroup1
        function uibuttongroup1_SelectionChangedFcn(app, event)
            % --- Executes when selected object is changed in uibuttongroup1.
            
            % Create GUIDE-style callback args - Added by Migration Tool
            [hObject, eventdata, handles] = convertToGUIDECallbackArguments(app, event); %#ok<ASGLU>
            
            % hObject    handle to the selected object in uibuttongroup1
            % eventdata  reserved - to be defined in a future version of MATLAB
            % handles    structure with handles and user data (see GUIDATA)
            
            handles.board1.currentVialNum = eventdata.NewValue.String;
            guidata(hObject, handles);
        end

        % Callback function
    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = OlfactoryArena_BioLuminescence_App_TCP_RUNTIMEFIX3_20260630(varargin)

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.figure1)

                % Execute the startup function
                runStartupFcn(app, @(app)OlfactoryArena_BioLuminescence_OpeningFcn(app, varargin{:}))
            else

                % Focus the running singleton app
                figure(runningApp.figure1)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.figure1)
        end
    end
end
