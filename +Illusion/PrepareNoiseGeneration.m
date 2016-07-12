function PrepareNoiseGeneration(hObject, ~)
handles = guidata(hObject);

clc
sca

% Initialize the main structure
DataStruct           = struct;
DataStruct.TimeStamp = datestr(now, 'yyyy-mm-dd HH:MM');

% Set task name for general coherence
DataStruct.Task = 'GenerateNoise';

% Get stimulation parameters
DataStruct.Parameters = GetParameters( DataStruct );

% Screen mode selection
AvalableDisplays = get(handles.listbox_Screens,'String');
SelectedDisplay = get(handles.listbox_Screens,'Value');
DataStruct.Parameters.Video.ScreenMode = str2double( AvalableDisplays(SelectedDisplay) );

% Windowed screen ?
switch get(handles.checkbox_WindowedScreen,'Value')
    case 1
        WindowedMode = 'On';
    case 0
        WindowedMode = 'Off';
    otherwise
        warning('NBI:WindowedScreen','Error in WindowedScreen')
end
DataStruct.WindowedMode = WindowedMode;

% Open PTB window
DataStruct.PTB = StartPTB( DataStruct );

% Parameters, references, convertions
Illusion.preProcess;

% Close PTB
% Just to be sure that if there is a problem with PTB, we do not loose all
% the data drue to a crash.
try
    Screen('CloseAll'); % Close PTB window
    Priority( DataStruct.PTB.oldLevel );
catch err
    disp(err)
end

pause(0.2); % cooldown the system

% Main process
Illusion.GenerateNoise

load('m_2D')
load('m_3D')

fprintf('\n GenerateNoise DONE \n')

end
