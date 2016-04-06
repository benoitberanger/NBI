%% Prepare event record

% Create
ER = EventRecorder( { 'event_name' , 'onset(s)' } , size(EP.Data,1) );

% Prepare
ER.AddStartTime( 'StartTime' , 0 );


%% Response recorder

% Create
RR = EventRecorder( { 'event_name' , 'onset(s)' } , 50000 ); % high arbitrary value : preallocation of memory

% Prepare
RR.AddStartTime( 'StartTime' , 0 );


%% Prepare the logger of MRI triggers

KbName('UnifyKeyNames');

allKeys = [ ...
    DataStruct.Parameters.Keybinds.TTL_5_ASCII ...
    DataStruct.Parameters.Keybinds.Right_Blue_1_ASCII ...
    DataStruct.Parameters.Keybinds.emulTTL_SpaceBar_ASCII ...
    DataStruct.Parameters.Keybinds.Stop_Escape_ASCII ];

KL = KbLogger( allKeys , KbName(allKeys) );

% Start recording events
KL.Start;
