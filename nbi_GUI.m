function varargout = nbi_GUI(varargin)
% NBI_GUI MATLAB code for nbi_GUI.fig
%      NBI_GUI, by itself, creates a new NBI_GUI or raises the existing
%      singleton*.
%
%      H = NBI_GUI returns the handle to a new NBI_GUI or the handle to
%      the existing singleton*.
%
%      NBI_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NBI_GUI.M with the given input arguments.
%
%      NBI_GUI('Property','Value',...) creates a new NBI_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nbi_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nbi_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nbi_GUI

% Last Modified by GUIDE v2.5 11-Jul-2016 14:36:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @nbi_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @nbi_GUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before nbi_GUI is made visible.
function nbi_GUI_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nbi_GUI (see VARARGIN)

% Choose default command line output for nbi_GUI
handles.output = hObject;


%% Cross-platform compatibility

% Use default background color of the platform
defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(handles.figure1,'Color',defaultBackground)

% Use a fixed width fontname for the platform
FWFN = get(0,'FixedWidthFontName');
ListHandles = fieldnames(handles);
for h = 1 : length( ListHandles )
    if ~( strcmp( ListHandles{h} , 'figure1' ) || strcmp( ListHandles{h} , 'output' ) ) && isnumeric(handles.(ListHandles{h})) && ishghandle(handles.(ListHandles{h}))
        % set(handles.(ListHandles{h}),'FontName',FWFN)
        set(handles.(ListHandles{h}),'FontName','default')
    end
end


%% IMPORTANT : Set defauls values

set(handles.uipanel_SaveMode,'SelectedObject',handles.radiobutton_SaveData)
set(handles.uipanel_Environement,'SelectedObject',handles.radiobutton_MRI)
set(handles.uipanel_OperationMode,'SelectedObject',handles.radiobutton_Acquisition)
set(handles.edit_RunNumber,'String','1')
set(handles.edit_SubjectID,'String','') % No preseted subject ID : error will be raised in Acquisition
set(handles.uipanel_EyelinkMode,'SelectedObject',handles.radiobutton_EyelinkOn)

% ParPort
set( handles.checkbox_ParPort , 'Value' , 1 )
handles = checkbox_ParPort_Callback( handles.checkbox_ParPort , eventdata , handles );

% Windowed screen
set(handles.checkbox_WindowedScreen,'Value',0)

% Set invisible the unused objects
set(handles.text_RunNumber,'Visible','off')
set(handles.edit_RunNumber,'Visible','off')
set(handles.pushbutton_RunNumber_m1,'Visible','off')
set(handles.pushbutton_RunNumber_p1,'Visible','off')
set(handles.pushbutton_NBI,'Visible','off')

% Invisible objects @ opening
set(handles.text_LastFileNameAnnouncer,'Visible','off')
set(handles.text_LastFileName,'Visible','off')
set(handles.text_RecordName,'Visible','off')
set(handles.edit_RecordName,'Visible','off')

%% Try to pick a random seed for the RNG

% Try one time
try
    rng('shuffle')
catch err
end

% Try a second time
try
    rng('default')
    rng('shuffle')
catch err
end


%% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nbi_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = nbi_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% -------------------------------------------------------------------------
%                            NBI_main_routine
% -------------------------------------------------------------------------
function NBI_main_routine(hObject, eventdata, handles)

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
        TaskData = Eyelink.Calibration( DataStruct );
        
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

Eyelink.StopRecording( DataStruct )


%% Ready for another run

set(handles.text_LastFileNameAnnouncer,'Visible','on')
set(handles.text_LastFileName,'Visible','on')
set(handles.text_LastFileName,'String',DataFile(length(DataPath)+1:end))

WaitSecs(0.100);
fprintf('\n')
fprintf('--------------------- \n')
fprintf('Ready for another run \n')
fprintf('--------------------- \n')


% -------------------------------------------------------------------------
%                                   END
% -------------------------------------------------------------------------


% --- Executes on button press in pushbutton_EyelinkCalibration.
function pushbutton_EyelinkCalibration_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% hObject    handle to pushbutton_EyelinkCalibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NBI_main_routine(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_NBI.
function pushbutton_NBI_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_NBI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NBI_main_routine(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_MTMST_Left.
function pushbutton_MTMST_Left_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_MTMST_Left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NBI_main_routine(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_MTMST_Right.
function pushbutton_MTMST_Right_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_MTMST_Right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NBI_main_routine(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_Retinotopy.
function pushbutton_Retinotopy_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Retinotopy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NBI_main_routine(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_Illusion.
function pushbutton_Illusion_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Illusion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NBI_main_routine(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_GenerateNoise.
function pushbutton_GenerateNoise_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_GenerateNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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
        warning('STIMPNEE:WindowedScreen','Error in WindowedScreen')
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
end

pause(0.2); % cooldown the system

% Main process
Illusion.GenerateNoise

load('m_2D')
load('m_3D')

fprintf('\n GenerateNoise DONE \n')


% --- Executes when selected object is changed in uipanel_OperationMode.
function uipanel_OperationMode_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_OperationMode
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function edit_SubjectID_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
% hObject    handle to edit_SubjectID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_RunNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_RunNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_SubjectID_Callback(hObject, eventdata, handles)
% hObject    handle to edit_SubjectID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_SubjectID as text
%        str2double(get(hObject,'String')) returns contents of edit_SubjectID as a double


function edit_RunNumber_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RunNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_RunNumber as text
%        str2double(get(hObject,'String')) returns contents of edit_RunNumber as a double


% --- Executes on button press in radiobutton_EyelinkOn.
function radiobutton_EyelinkOn_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_EyelinkOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_EyelinkOn


% --- Executes on button press in radiobutton_EyelinkOff.
function radiobutton_EyelinkOff_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_EyelinkOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_EyelinkOff


% --- Executes when selected object is changed in uipanel_EyelinkMode.
function uipanel_EyelinkMode_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_EyelinkMode
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'radiobutton_EyelinkOff'
        set(handles.pushbutton_EyelinkCalibration,'Visible','off')
        set(handles.pushbutton_IsConnected,'Visible','off')
        set(handles.pushbutton_ForceShutDown,'Visible','off')
        set(handles.pushbutton_Initialize,'Visible','off')
    case 'radiobutton_EyelinkOn'
        set(handles.pushbutton_EyelinkCalibration,'Visible','on')
        set(handles.pushbutton_IsConnected,'Visible','on')
        set(handles.pushbutton_ForceShutDown,'Visible','on')
        set(handles.pushbutton_Initialize,'Visible','on')
end


% --- Executes on selection change in listbox_Screens.
function listbox_Screens_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_Screens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_Screens contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_Screens



% --- Executes during object creation, after setting all properties.
function listbox_Screens_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_Screens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

GUI.Listbox_Screens_CreateFcn;



% --- Executes during object creation, after setting all properties.
function text_ScreenMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_ScreenMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

set(hObject,'TooltipString',sprintf('Output of Screen(''Screens'') \n Use ''Screen Screens?'' in Command window for help'))



% --- Executes on button press in pushbutton_RunNumber_p1.
function pushbutton_RunNumber_p1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_RunNumber_p1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

GUI.Pushbutton_RunNumber_p1_Callback;



% --- Executes on button press in pushbutton_RunNumber_m1.
function pushbutton_RunNumber_m1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_RunNumber_m1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

GUI.Pushbutton_RunNumber_m1_Callback;


% --- Executes on button press in pushbutton_Check_SubjectID_data.
function pushbutton_Check_SubjectID_data_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Check_SubjectID_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

GUI.Pushbutton_Check_SubjectID_data_Callback;


% --- Executes on button press in checkbox_ParPort.
function handles = checkbox_ParPort_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_ParPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ParPort

GUI.Checkbox_ParPort_Callback;


% --- Executes on button press in checkbox_WindowedScreen.
function checkbox_WindowedScreen_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_WindowedScreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_WindowedScreen


function edit_IlluBlock_Callback(hObject, eventdata, handles)
% hObject    handle to edit_IlluBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_IlluBlock as text
%        str2double(get(hObject,'String')) returns contents of edit_IlluBlock as a double

block = str2double(get(hObject,'String'));

if block ~= round(block) || block < 0 || block > 8
    set(hObject,'String','1');
    error('block number must be from 0 to 8')
end


% --- Executes during object creation, after setting all properties.
function edit_IlluBlock_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_IlluBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'TooltipString','Block number of Illusion : from 0 to 8')



% --- Executes on button press in pushbutton_IsConnected.
function pushbutton_IsConnected_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_IsConnected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Eyelink.IsConnected;



% --- Executes on button press in pushbutton_Initialize.
function pushbutton_Initialize_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Initialize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Eyelink.Initialize;


% --- Executes on button press in pushbutton_ForceShutDown.
function pushbutton_ForceShutDown_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ForceShutDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Eyelink.ForceShutDown;




function edit_RecordName_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RecordName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_RecordName as text
%        str2double(get(hObject,'String')) returns contents of edit_RecordName as a double


% --- Executes during object creation, after setting all properties.
function edit_RecordName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_RecordName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in uipanel_RecordVideo.
function uipanel_RecordVideo_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_RecordVideo 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'radiobutton_RecordOn'
        set(handles.text_RecordName,'Visible','On')
        set(handles.edit_RecordName,'Visible','On')
    case 'radiobutton_RecordOff'
        set(handles.text_RecordName,'Visible','off')
        set(handles.edit_RecordName,'Visible','off')
end

