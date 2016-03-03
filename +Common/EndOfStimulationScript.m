%% End of stimulation

% EventRecorder
ER.ClearEmptyEvents;
ER.ComputeDurations;
ER.BuildGraph;
TaskData.ER = ER;

% KbLogger
switch DataStruct.OperationMode
    
    case 'Acquisition'
        
        % Stop recording events
        KL.Stop;
        
    case 'FastDebug'
        
    case 'RealisticDebug'
        
    otherwise
        
end
KL.ScaleTime;
KL.ComputeDurations;
KL.BuildGraph;
TaskData.KL = KL;

% Save some values
TaskData.FixationDuration = FixationDuration;
TaskData.Speed            = Speed;
TaskData.PixelPerDegree   = PixelPerDegree;
TaskData.DotVisualAngle   = DotVisualAngle;
TaskData.StartTime        = StartTime;
TaskData.StopTime         = StopTime;


%% Send infos to base workspace

assignin('base','EP',EP)
assignin('base','ER',ER)
assignin('base','KL',KL)

assignin('base','TaskData',TaskData)


%% Close all movies

for m = 1 : length(movie)
    Screen('CloseMovie', movie(m).Ptr );
end


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
