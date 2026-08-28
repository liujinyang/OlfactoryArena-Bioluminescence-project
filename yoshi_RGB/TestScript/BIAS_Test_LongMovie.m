    %Run the camera server program bias
    dos('bias_gui.bat &');
    %initialize the camera
    for camCounter = 1:length(camera)
        flea3(camCounter) = BiasControlV60(camera(camCounter).ip,camera(camCounter).port);
        %flea3.initializeCamera(frameRate, movieFormat, ROI, triggerMode);
        flea3(camCounter).connect();
        flea3(camCounter).loadConfiguration(defaultJsonFile{camCounter});
        flea3(camCounter).disableLogging();
        hComm.flea3(camCounter) = flea3(camCounter);
             
        trialMovieName = ['D:\movie_longTest',num2str(i),'.ufmf'];
        flyBowl_camera_control(handles.hComm.flea3(i),'start', trialMovieName);
    end
    
    pause(36000);
              
    for camCounter = 1:length(camera)      
        flyBowl_camera_control(handles.hComm.flea3(i),'stop');
    end
        
    