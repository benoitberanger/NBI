%% Prepare event record

% Create
ER = EventRecorder( header(1:2) , size(EP.Data,1) );

% Prepare
ER.AddStartTime( 'StartTime' , 0 );


%% Prepare the logger of MRI triggers

KbName('UnifyKeyNames');

% fORP in USB : MRI trigger are converted into keyboard input
if ~IsLinux
    keys = {'5%'};
else
    keys = {'parenleft'};
end
KL = KbLogger(min(KbName(keys)) , keys);

switch DataStruct.OperationMode
    
    case 'Acquisition'
        
        % Start recording events
        KL.Start;
        
    case 'FastDebug'
        
        TR = 0.950; % seconds
        nbVolumes = ceil( EP.Data{end,2} / TR ) + 2 ; % nb of volumes for the estimated time of stimulation + 2 to be safe
        KL.GenerateMRITrigger( TR , nbVolumes );
        
    case 'RealisticDebug'
        
        TR = 0.950; % seconds
        nbVolumes = ceil( EP.Data{end,2} / TR ) + 2 ; % nb of volumes for the estimated time of stimulation + 2 to be safe
        KL.GenerateMRITrigger( TR , nbVolumes );
        
end
