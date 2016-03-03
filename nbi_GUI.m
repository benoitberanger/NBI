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

% Last Modified by GUIDE v2.5 03-Mar-2016 15:52:28

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
    if ~( strcmp( ListHandles{h} , 'figure1' ) || strcmp( ListHandles{h} , 'output' ) )
        % set(handles.(ListHandles{h}),'FontName',FWFN)
        set(handles.(ListHandles{h}),'FontName','default')
    end
end


%% IMPORTANT : Set defauls values

set(handles.uipanel_SaveMode,'SelectedObject',handles.radiobutton_SaveData)
set(handles.uipanel_Environement,'SelectedObject',handles.radiobutton_MRI)
set(handles.uipanel_OperationMode,'SelectedObject',handles.radiobutton_Acquisition)
set(handles.edit_RunNumber,'String','1')
set(handles.edit_SubjectID,'String','xxxx')
set(handles.uipanel_EyelinkMode,'SelectedObject',handles.radiobutton_EyelinkOn)

% ParPort
set( handles.checkbox_ParPort , 'Value' , 1 )
handles = checkbox_ParPort_Callback( handles.checkbox_ParPort , eventdata , handles );

set(handles.checkbox_WindowedScreen,'Value',0)

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


%% Subject ID & Run number

SubjectID = get(handles.edit_SubjectID,'String');
RunNumber = get(handles.edit_RunNumber,'String');

% Eyelink file name can only contain 8 characters, so we limit the number
% of characters for SubjectID and RunNumber.
if length(SubjectID) ~= 4
    error('NBI:SubjectIDLength','\n SubjectID must contain 4 characters \n')
end
if length(RunNumber) ~= 1
    error('NBI:RunNumberLength','\n RunNumber must contain 1 characters \n')
end

handles.SubjectID       = SubjectID;
handles.RunNumber       = RunNumber;
DataStruct.SubjectID    = SubjectID;
DataStruct.RunNumber    = RunNumber;


%% Environement selection

switch get(get(handles.uipanel_Environement,'SelectedObject'),'Tag')
    case 'radiobutton_MRI'
        Environement = 'MRI';
    case 'radiobutton_Training'
        Environement = 'Training';
    otherwise
        warning('NBI:ModeSelection','Error in Environement selection')
end

handles.Environement    = Environement;
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

handles.SaveMode    = SaveMode;
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

handles.OperationMode    = OperationMode;
DataStruct.OperationMode = OperationMode;


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


%% Task selection

switch get(hObject,'Tag')
    
    case 'pushbutton_EyelinkCalibration'
        Task = 'EyelinkCalibration';
        
    case 'pushbutton_NBI'
        Task = 'NBI';
        
    otherwise
        error('NBI:TaskSelection','Error in Task selection')
end

handles.Task    = Task;
DataStruct.Task = Task;


%% Check if Eyelink toolbox is available

switch get(get(handles.uipanel_EyelinkMode,'SelectedObject'),'Tag')
    
    case 'radiobutton_EyelinkOff'
        
        EyelinkMode = 'Off';
        
    case 'radiobutton_EyelinkOn'
        
        EyelinkMode = 'On';
        
        % 'Eyelink.m' exists ?
        status = which('Eyelink.m');
        if isempty(status)
            EyelinkToolboxAvailable = 0;
        else
            EyelinkToolboxAvailable = 1;
        end
        
        % Save mode ?
        if strcmp(DataStruct.SaveMode,'NoSave')
            error('NBI:EyelinkMode',' \n ---> Save mode should be turned on when using Eyelink <--- \n ')
        end
        
        handles.EyelinkToolboxAvailable = EyelinkToolboxAvailable;
        DataStruct.EyelinkToolboxAvailable = EyelinkToolboxAvailable;
        
    otherwise
        
        warning('NBI:EyelinkMode','Error in Eyelink mode')
        
end

handles.EyelinkMode    = EyelinkMode;
DataStruct.EyelinkMode = EyelinkMode;


%% Path management

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    DataPath = [fileparts(pwd) filesep 'data' filesep SubjectID filesep];
    DataFile = sprintf('%s%s_%s_%s_%s', DataPath, SubjectID, Task, Environement, RunNumber);
    
    if exist([DataFile '.mat'], 'file')
        error('MATLAB:FileAlreadyExists',' \n ---> \n The file %s.mat already exists .  <--- \n \n',DataFile);
    end
    
    DataStruct.DataPath = DataPath;
    DataStruct.DataFile = DataFile;
    
end


%% Get stimulation parameters

DataStruct.Parameters = GetParameters();

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
        
    otherwise
        error('NBI:Task','Task ?')
end

DataStruct.TaskData = TaskData;


%% Save files

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    save([fileparts(pwd) filesep 'data' filesep 'LastDataStruct'],'DataStruct');
end


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
    
end


%% Send DataStruct and SPM nod to workspace

assignin('base', 'DataStruct', DataStruct);
assignin('base', 'names', names);
assignin('base', 'onsets', onsets);
assignin('base', 'durations', durations);


%% End recording of Eyelink

Eyelink.StopRecording( DataStruct )



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


% --- Executes on button press in pushbutton_Morphology_nonce.
function pushbutton_Morphology_nonce_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Morphology_nonce (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NBI_main_routine(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_Morphology_words.
function pushbutton_Morphology_words_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Morphology_words (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NBI_main_routine(hObject, eventdata, handles)


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
    case 'radiobutton_EyelinkOn'
        set(handles.pushbutton_EyelinkCalibration,'Visible','on')
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

set(hObject,'TooltipString',sprintf('Select the display mode \n PTB : 0 for extended display (over all screens) , 1 for screen 1 , 2 for screen 2 , etc.'))

AvailableDisplays = Screen('Screens');

% Put screen 1 on the top : CENIR human MRI configuration
if length(AvailableDisplays) > 1
    AvailableDisplays = circshift(AvailableDisplays',length(AvailableDisplays)-1);
    ListOfScreens = num2str(AvailableDisplays);
else
    ListOfScreens = num2str(AvailableDisplays');
end

set(hObject,'String',ListOfScreens)



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

CurrentRunNumber_str = get(handles.edit_RunNumber,'String');
CurrentRunNumber = str2double(CurrentRunNumber_str) + 1;

set(handles.edit_RunNumber,'String', num2str( CurrentRunNumber ) )



% --- Executes on button press in pushbutton_RunNumber_m1.
function pushbutton_RunNumber_m1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_RunNumber_m1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CurrentRunNumber_str = get(handles.edit_RunNumber,'String');
CurrentRunNumber = str2double(CurrentRunNumber_str) - 1;

set(handles.edit_RunNumber,'String', num2str( CurrentRunNumber ) )



% --- Executes on button press in pushbutton_Check_SubjectID_data.
function pushbutton_Check_SubjectID_data_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Check_SubjectID_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ../
upperDir = fullfile( fileparts( pwd ) );

% ../data/
dataDir = fullfile( upperDir , 'data' );

% ../data/ exists ?
if ~isdir( dataDir )
    error( 'MATLAB:DataDirExists' , ' \n ---> data directory not found in the upper dir : %s <--- \n ' , upperDir )
end

SubjectID = get(handles.edit_SubjectID,'String');

% ../data/(SubjectID)
SubjectIDDir = fullfile( dataDir , SubjectID );

% ../data/(SubjectID) exists ?
if ~isdir( SubjectIDDir )
    error( 'MATLAB:SubjectIDDirExists' ,  ' \n ---> SubjectID directory not found in the : %s <--- \n ' , dataDir )
end

% Display dir
disp(SubjectIDDir)

% Display content
dir(SubjectIDDir)



% --- Executes on button press in checkbox_ParPort.
function handles = checkbox_ParPort_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_ParPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ParPort

opp_path = which('OpenParPort.m');

if isempty(opp_path)
    
    disp('Parallel port library NOT DETECTED')
    handles.ParPort = 'Off';
    set(hObject,'Value',0);
    
else
    
    switch get(hObject,'Value');
        
        case 0
            disp('Parallel port library OFF')
            handles.ParPort = 'Off';
            set(hObject,'Value',0);
            
        case 1
            disp('Parallel port library ON')
            handles.ParPort = 'On';
            set(hObject,'Value',1);
    end
    
end

guidata(hObject, handles);



% --- Executes on button press in checkbox_WindowedScreen.
function checkbox_WindowedScreen_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_WindowedScreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_WindowedScreen
