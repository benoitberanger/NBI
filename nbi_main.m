function nbi_main(hObject, ~)

if nargin == 0
    error('Use %s, it will start a GUI.','nbi_GUI.m');
end

handles = guidata(hObject); % retrive GUI data

clc
sca

% Initialize the main structure
DataStruct           = struct;
DataStruct.TimeStamp = datestr(now, 'yyyy-mm-dd HH:MM');


%% Task selection

switch get(hObject,'Tag')
    
    case 'pushbutton_EyelinkCalibration'
        Task = 'EyelinkCalibration';
        
    case 'pushbutton_NBI'
        Task = 'NBI';
        
    case 'pushbutton_MTMST_Left'
        Task = 'MTMST_Left';
        
    case 'pushbutton_MTMST_Right'
        Task = 'MTMST_Right';
        
    case 'pushbutton_Retinotopy'
        Task = 'Retinotopy';
        
    case 'pushbutton_Illusion'
        Task                   = 'Illusion';
        BlockNumber            = str2double( get(handles.edit_IlluBlock,'String') );
        DataStruct.BlockNumber = BlockNumber;
        
    otherwise
        error('NBI:TaskSelection','Error in Task selection')
end

DataStruct.Task = Task;


%% Environement selection

switch get(get(handles.uipanel_Environement,'SelectedObject'),'Tag')
    case 'radiobutton_MRI'
        Environement = 'MRI';
    case 'radiobutton_Training'
        Environement = 'Training';
    otherwise
        warning('NBI:ModeSelection','Error in Environement selection')
end

DataStruct.Environement = Environement;


%% Save mode selection

switch get(get(handles.uipanel_SaveMode,'SelectedObject'),'Tag')
    case 'radiobutton_SaveData'
        SaveMode = 'SaveData';
    case 'radiobutton_NoSave'
        SaveMode = 'NoSave';
    otherwise
        warning('NBI:SaveSelection','Error in SaveMode selection')
end

DataStruct.SaveMode = SaveMode;


%% Mode selection

switch get(get(handles.uipanel_OperationMode,'SelectedObject'),'Tag')
    case 'radiobutton_Acquisition'
        OperationMode = 'Acquisition';
    case 'radiobutton_FastDebug'
        OperationMode = 'FastDebug';
    case 'radiobutton_RealisticDebug'
        OperationMode = 'RealisticDebug';
    otherwise
        warning('NBI:ModeSelection','Error in Mode selection')
end

DataStruct.OperationMode = OperationMode;


%% Record video ?

switch get(get(handles.uipanel_RecordVideo,'SelectedObject'),'Tag')
    case 'radiobutton_RecordOn'
        RecordVideo          = 'On';
        VideoName            = [ get(handles.edit_RecordName,'String') '.mov'];
        DataStruct.VideoName = VideoName;
    case 'radiobutton_RecordOff'
        RecordVideo          = 'Off';
    otherwise
        warning('NBI:RecordVideo','Error in Record Video')
end

DataStruct.RecordVideo = RecordVideo;


%% Subject ID & Run number

SubjectID = get(handles.edit_SubjectID,'String');

if length(SubjectID) ~= 4
    error('NBI:SubjectIDLength','\n SubjectID must be 4 char \n')
end
if ~strcmp(SubjectID,upper(SubjectID))
    warning('NBI:SubjectIDupper','SuubjectID should be upper case ?')
end

% Prepare path
DataPath = [fileparts(pwd) filesep 'data' filesep SubjectID filesep];
switch Task
    case 'Illusion'
        DataPathNoRun = sprintf('%s_%s_B%d_%s_', SubjectID, Task, BlockNumber, Environement);
    otherwise
        DataPathNoRun = sprintf('%s_%s_%s_', SubjectID, Task, Environement);
end

% Fetch content of the directory
dirContent = dir(DataPath);

% Is there file of the previous run ?
previousRun = nan(length(dirContent),1);
for f = 1 : length(dirContent)
    split = regexp(dirContent(f).name,DataPathNoRun,'split');
    if length(split) == 2 && str2double(split{2}(1)) % yes there is a file
        previousRun(f) = str2double(split{2}(1)); % save the previous run numbers
    else % no file found
        previousRun(f) = 0; % affect zero
    end
end

LastRunNumber = max(previousRun);
% If no previous run, LastRunNumber is 0
if isempty(LastRunNumber)
    LastRunNumber = 0;
end

RunNumber = num2str(LastRunNumber + 1);

switch Task
    case 'Illusion'
        DataFile = sprintf('%s%s_%s_B%d_%s_%s', DataPath, SubjectID, Task, BlockNumber, Environement, RunNumber );
    otherwise
        DataFile = sprintf('%s%s_%s_%s_%s', DataPath, SubjectID, Task, Environement, RunNumber );
end

DataStruct.SubjectID = SubjectID;
DataStruct.RunNumber = RunNumber;
DataStruct.DataPath  = DataPath;
DataStruct.DataFile  = DataFile;


%% Controls for SubjectID depending on the Mode selected

switch OperationMode
    
    case 'Acquisition'
        
        % Empty subject ID
        if isempty(SubjectID)
            error('NBI:MissingSubjectID','\n For acquisition, SubjectID is required \n')
        end
        
        % Acquisition => save data
        if ~get(handles.radiobutton_SaveData,'Value')
            warning('NBI:DataShouldBeSaved','\n\n\n In acquisition mode, data should be saved \n\n\n')
        end
        
end


%% Parallel port ?

switch get( handles.checkbox_ParPort , 'Value' )
    
    case 1
        ParPort = 'On';
        
    case 0
        ParPort = 'Off';
end

handles.ParPort    = ParPort;
DataStruct.ParPort = ParPort;


%% Check if Eyelink toolbox is available

switch get(get(handles.uipanel_EyelinkMode,'SelectedObject'),'Tag')
    
    case 'radiobutton_EyelinkOff'
        
        EyelinkMode = 'Off';
        
    case 'radiobutton_EyelinkOn'
        
        EyelinkMode = 'On';
        
        % 'Eyelink.m' exists ?
        status = which('Eyelink.m');
        if isempty(status)
            error('NBI:EyelinkToolbox','no ''Eyelink.m'' detected in the path')
        end
        
        % Save mode ?
        if strcmp(DataStruct.SaveMode,'NoSave')
            error('NBI:SaveModeForEyelink',' \n ---> Save mode should be turned on when using Eyelink <--- \n ')
        end
        
        % Eyelink connected ?
        Eyelink.IsConnected
        
        % File name for the eyelink : 8 char maximum
        switch Task
            case 'NBI'
                task = 'NB';
            case 'EyelinkCalibration'
                task = 'EC';
            case 'MTMST_Left'
                task = 'ML';
            case 'MTMST_Right'
                task = 'MR';
            case 'Retinotopy'
                task = 'RT';
            case 'Illusion'
                task = ['I' get(handles.edit_IlluBlock,'String')];
            otherwise
                error('NBI:Task','Task ?')
        end
        EyelinkFile = [ SubjectID task sprintf('%.2d',str2double(RunNumber)) ];
        
        DataStruct.EyelinkFile = EyelinkFile;
        
    otherwise
        
        warning('NBI:EyelinkMode','Error in Eyelink mode')
        
end

DataStruct.EyelinkMode = EyelinkMode;


%% Security : NEVER overwrite a file
% If erasing a file is needed, we need to do it manually

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    if exist([DataFile '.mat'], 'file')
        error('MATLAB:FileAlreadyExists',' \n ---> \n The file %s.mat already exists .  <--- \n \n',DataFile);
    end
    
end


%% Get stimulation parameters

DataStruct.Parameters = GetParameters( DataStruct );

% Screen mode selection
AvalableDisplays = get(handles.listbox_Screens,'String');
SelectedDisplay = get(handles.listbox_Screens,'Value');
DataStruct.Parameters.Video.ScreenMode = str2double( AvalableDisplays(SelectedDisplay) );


%% Windowed screen ?

switch get(handles.checkbox_WindowedScreen,'Value')
    
    case 1
        WindowedMode = 'On';
    case 0
        WindowedMode = 'Off';
    otherwise
        warning('STIMPNEE:WindowedScreen','Error in WindowedScreen')
        
end

DataStruct.WindowedMode = WindowedMode;


%% Open PTB window

DataStruct.PTB = StartPTB( DataStruct );


%% Task run

switch Task
    
    case 'NBI'
        TaskData = NBI.NBI( DataStruct );
        
    case 'EyelinkCalibration'
        Eyelink.Calibration( DataStruct.PTB.Window );
        TaskData.ER.Data = {};
        TaskData.IsEyelinkRreadyToRecord = 1;

    case 'MTMST_Left'
        TaskData = MTMST.MTMST( DataStruct );
        
    case 'MTMST_Right'
        TaskData = MTMST.MTMST( DataStruct );
        
    case 'Retinotopy'
        TaskData = Retinotopy.Retinotopy( DataStruct );
        
    case 'Illusion'
        TaskData = Illusion.Illusion( DataStruct );
        
    otherwise
        error('NBI:Task','Task ?')
end

DataStruct.TaskData = TaskData;


%% Save files on the fly : just a security in case of crash of the end the script

save([fileparts(pwd) filesep 'data' filesep 'LastDataStruct'],'DataStruct');


%% Close PTB

% Just to be sure that if there is a problem with PTB, we do not loose all
% the data drue to a crash.
try
    
    Screen('CloseAll'); % Close PTB window
    
    Priority( DataStruct.PTB.oldLevel );
    
catch err
    
end


%% SPM data organization

[ names , onsets , durations ] = SPMnod( DataStruct ); %#ok<*NASGU,*ASGLU>


%% Saving data strucure

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    if ~exist(DataPath, 'dir')
        mkdir(DataPath);
    end
    
    save(DataFile, 'DataStruct', 'names', 'onsets', 'durations');
    save([DataFile '_SPM'], 'names', 'onsets', 'durations');
    
    % BrainVoyager data organization
    spm2bv( names , onsets , durations , DataStruct.DataFile )
    
end


%% Send DataStruct and SPM nod to workspace

assignin('base', 'DataStruct', DataStruct);
assignin('base', 'names', names);
assignin('base', 'onsets', onsets);
assignin('base', 'durations', durations);


%% End recording of Eyelink

% Eyelink mode 'On' ?
if strcmp(DataStruct.EyelinkMode,'On')
    
    % Stop recording and retrieve the file
    Eyelink.StopRecording( DataStruct.EyelinkFile , DataStruct.DataPath )
    
    if ~strcmp(DataStruct.Task,'EyelinkCalibration')
        
        % Rename the file
        movefile([DataStruct.DataPath filesep EyelinkFile '.edf'], [DataStruct.DataFile '.edf'])
        
    end
    
end


%% Ready for another run

set(handles.text_LastFileNameAnnouncer,'Visible','on')
set(handles.text_LastFileName,'Visible','on')
set(handles.text_LastFileName,'String',DataFile(length(DataPath)+1:end))

WaitSecs(0.100);
fprintf('\n')
fprintf('--------------------- \n')
fprintf('Ready for another run \n')
fprintf('--------------------- \n')


end % function
