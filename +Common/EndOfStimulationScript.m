%% End of stimulation

% EventRecorder
ER.ClearEmptyEvents;
ER.ComputeDurations;
ER.BuildGraph;
TaskData.ER = ER;

% Response Recorder
RR.ClearEmptyEvents;
RR.ComputeDurations;
RR.BuildGraph;
TaskData.RR = RR;

% KbLogger
KL.GetQueue;
KL.Stop;
KL.ScaleTime(StartTime);
switch DataStruct.OperationMode
    case 'Acquisition'
    case 'FastDebug'
        TR = 0.950; % seconds
        nbVolumes = ceil( EP.Data{end,2} / TR ) + 2 ; % nb of volumes for the estimated time of stimulation + 2 to be safe
        KL.GenerateMRITrigger( TR , nbVolumes );
    case 'RealisticDebug'
        TR = 0.950; % seconds
        nbVolumes = ceil( EP.Data{end,2} / TR ) + 2 ; % nb of volumes for the estimated time of stimulation + 2 to be safe
        KL.GenerateMRITrigger( TR , nbVolumes );
    otherwise   
end
KL.ComputeDurations;
KL.BuildGraph;
TaskData.KL = KL;

% Save some values
TaskData.Speed            = Speed;
TaskData.PixelPerDegree   = PixelPerDegree;
TaskData.DotVisualAngle   = DotVisualAngle;
TaskData.StartTime        = StartTime;
TaskData.StopTime         = StopTime;


%% Send infos to base workspace

assignin('base','EP',EP)
assignin('base','ER',ER)
assignin('base','RR',RR)
assignin('base','KL',KL)

assignin('base','TaskData',TaskData)


%% Close all movies / textures

switch DataStruct.Task
    
    case 'NBI'
        
        for m = 1 : length(movie)
            Screen('CloseMovie', movie(m).Ptr );
        end
        
end

% Close all textures
Screen('Close');


%% Close parallel port

switch DataStruct.ParPort
    
    case 'On'
        
        try
            CloseParPort;
        catch err % just try to colse it, but we don't want an error
            disp(err)
        end
        
    case 'Off'
        
end


%% Diagnotic

switch DataStruct.OperationMode
    case 'Acquisition'
        
        
    case 'FastDebug'
        plotDelay
        
    case 'RealisticDebug'
        plotDelay
        
end
