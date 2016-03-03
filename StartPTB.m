function [ PTB ] = StartPTB( DataStruct )

% Shortcut
Video = DataStruct.Parameters.Video;

% Use GStreamer
Screen('Preference', 'OverrideMultimediaEngine', 1);

% PTB opening screen will be empty = black screen
Screen('Preference', 'VisualDebugLevel', 1);

% Open PTB display window
switch DataStruct.WindowedMode
    case 'Off'
        WindowRect = [];
    case 'On'
        factor = 0.5;
        [ScreenWidth, ScreenHeight]=Screen('WindowSize', Video.ScreenMode);
        SmallWindow = ScaleRect( [0 0 ScreenWidth ScreenHeight] , factor , factor );
        WindowRect = CenterRectOnPoint( SmallWindow , ScreenWidth/2 , ScreenHeight/2 );
    otherwise
end

try
    [PTB.Window,PTB.WindowRect] = Screen('OpenWindow',Video.ScreenMode,Video.ScreenBackgroundColor,WindowRect);
catch err
    disp(err)
    Screen('Preference', 'SkipSyncTests', 1)
    [PTB.Window,PTB.WindowRect] = Screen('OpenWindow',Video.ScreenMode,Video.ScreenBackgroundColor,WindowRect);
end

% Set max priority
PTB.oldLevel         = Priority();
PTB.maxPriorityLevel = MaxPriority( PTB.Window );
PTB.newLevel         = Priority( PTB.maxPriorityLevel );

% Refresh time of the monitor
PTB.slack = Screen('GetFlipInterval', PTB.Window)/2;
PTB.IFI   = Screen('GetFlipInterval', PTB.Window);

% Set up alpha-blending for smooth (anti-aliased) lines and alpha-blending
% (transparent background textures)
Screen('BlendFunction', PTB.Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Set text police
Screen('TextSize', PTB.Window, Video.TextSize);
Screen('TextFont', PTB.Window, Video.TextFont);

% Center
[ PTB.CenterH , PTB.CenterV ] = RectCenter( PTB.WindowRect );

% B&W colors
PTB.Black = BlackIndex( PTB.Window );
PTB.White = WhiteIndex( PTB.Window );


%% Echo in command window

disp('---------------------');
disp(['--- ' mfilename ' done ---']);
disp('---------------------');
disp(' ');


end
