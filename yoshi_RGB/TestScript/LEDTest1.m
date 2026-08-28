LEDController1 = LEDController('COM4');
LEDController1.reset();

%LED protocol settings 
stepDuration = 10; %in seconds

%RGB setting
RIntensity = 16;
RPulseWidth = 1000; %in ms
RPulsePeriod = 2000; %in ms
RPulseNum = 1;
ROffTime = 0;
RDelay = 3.9; %in seconds
RIteration = 3;

GIntensity = 0;
GPulseWidth = 0;  %in ms
GPulsePeriod = 0; %in ms
GPulseNum = 0;
GOffTime = 0;
GDelay = 0;  %in seconds
GIteration = 0;

BIntensity = 0;
BPulseWidth = 0;  %in ms
BPulsePeriod = 0; %in ms
BPulseNum = 0;   
BOffTime = 0;
BDelay = 0;    %in seconds
BIteration = 0;

%start to load 4 LED patterns  
for stepIndex = 1:4
    oneStep(stepIndex).NumStep = stepIndex;
    oneStep(stepIndex).Duration = stepDuration;  %in seconds
    oneStep(stepIndex).DelayTime = RDelay;
    %red light
    oneStep(stepIndex).RedIntensity = RIntensity;
    oneStep(stepIndex).RedPulseWidth = RPulseWidth;
    oneStep(stepIndex).RedPulsePeriod = RPulsePeriod;
    oneStep(stepIndex).RedPulseNum = RPulseNum;
    oneStep(stepIndex).RedOffTime = ROffTime;
    oneStep(stepIndex).RedIteration = RIteration;
    %green light
    oneStep(stepIndex).GrnIntensity = GIntensity;
    oneStep(stepIndex).GrnPulseWidth = GPulseWidth;
    oneStep(stepIndex).GrnPulsePeriod = GPulsePeriod;
    oneStep(stepIndex).GrnPulseNum = GPulseNum;
    oneStep(stepIndex).GrnOffTime = GOffTime;
    oneStep(stepIndex).GrnIteration = GIteration;
    %blue light
    oneStep(stepIndex).BluIntensity = BIntensity;
    oneStep(stepIndex).BluPulseWidth = BPulseWidth;
    oneStep(stepIndex).BluPulsePeriod = BPulsePeriod;
    oneStep(stepIndex).BluPulseNum = BPulseNum;
    oneStep(stepIndex).BluOffTime = BOffTime;
    oneStep(stepIndex).BluIteration = BIteration;     
end

oneStep(1).Pattern = '00000000';
oneStep(2).Pattern = '10011001';
oneStep(3).Pattern = '01100110';
oneStep(4).Pattern = '11111111';

%remove all experiment steps and steporders
LEDController1.removeAllExperimentSteps();
LEDController1.removeAllExperimentStepOrders();

%add new experiment steps
for stepIndex = 1:4
    totalSteps = LEDController1.addOneStep(oneStep(stepIndex));
end

if totalSteps == 4
    expData = LEDController1.getExperimentSteps();
    disp(expData);
end

LEDController1.stepOrder(4);
LEDController1.stepOrder(1);
LEDController1.stepOrder(2);
LEDController1.stepOrder(3);

stepOrders = LEDController1.getExperimentStepOrders();
disp(stepOrders);

LEDController1.runExperiment();

for i = 0:1:40
    status = LEDController1.getExperimentStatus();
    disp(status);
%     temp = textscan(status,'%f,%d,%f,%f,%f');
%     timeInfo = temp{1}/1000;
%     step = temp{2};
%     redIntensity = temp{3};
%     grnIntensity = temp{4};
%     bluIntensity = temp{5};
    pause(1);
end 

LEDController1.delete();
