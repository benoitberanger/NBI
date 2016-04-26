function [ Parameters ] = GetParameters( DataStruct )
% GETPARAMETERS Prepare common parameters
%
% CONFIG fORRP 932 :
%
%
%


%% Set parameters

%%%%%%%%%%%%%%
%   Screen   %
%%%%%%%%%%%%%%
Parameters.Video.ScreenWidthPx   = 1024;  % Number of horizontal pixel in MRI video system @ CENIR
Parameters.Video.ScreenHeightPx  = 768;   % Number of vertical pixel in MRI video system @ CENIR
Parameters.Video.ScreenFrequency = 60;    % Refresh rate (in Hertz)
Parameters.Video.SubjectDistance = 0.120; % m
Parameters.Video.ScreenWidthM    = 0.040; % m
Parameters.Video.ScreenHeightM   = 0.030; % m

switch DataStruct.Task
    
    case 'NBI'
        Parameters.Video.ScreenBackgroundColor = [128 128 128]; % [R G B] ( from 0 to 255 )
        
    case 'MTMST_Left'
        Parameters.Video.ScreenBackgroundColor = [0 0 0]; % [R G B] ( from 0 to 255 )
        
    case 'MTMST_Right'
        Parameters.Video.ScreenBackgroundColor = [0 0 0]; % [R G B] ( from 0 to 255 )
        
    case 'Retinotopy'
        Parameters.Video.ScreenBackgroundColor = [128 128 128]; % [R G B] ( from 0 to 255 )
        
    case 'Illusion'
        Parameters.Video.ScreenBackgroundColor = [128 128 128]; % [R G B] ( from 0 to 255 )
    case 'GenerateNoise'
        Parameters.Video.ScreenBackgroundColor = [128 128 128]; % [R G B] ( from 0 to 255 )
        
end

Parameters.Toolbox = 'PsychToolbox';


%%%%%%%%%%%%%%
%  Keybinds  %
%%%%%%%%%%%%%%

KbName('UnifyKeyNames');

if ~IsLinux
    
    Parameters.Keybinds.Right_Blue_1_ASCII   = KbName('1!');
    % Parameters.Keybinds.Right_Yellow_2_ASCII = KbName('2@');
    % Parameters.Keybinds.Right_Green_3_ASCII  = KbName('3#');
    % Parameters.Keybinds.Right_Red_4_ASCII    = KbName('4$');
    
    Parameters.Keybinds.TTL_5_ASCII = KbName('5%');
    
    % Parameters.Keybinds.Left_Blue_1_ASCII   = KbName('6^');
    % Parameters.Keybinds.Left_Yellow_2_ASCII = KbName('7&');
    % Parameters.Keybinds.Left_Green_3_ASCII  = KbName('8*');
    % Parameters.Keybinds.Left_Red_4_ASCII    = KbName('9(');
    
    Parameters.Keybinds.emulTTL_SpaceBar_ASCII = KbName('space');
    
    Parameters.Keybinds.Stop_Escape_ASCII = KbName('ESCAPE');
    
else
    
    Parameters.Keybinds.Right_Blue_1_ASCII   = KbName('ampersand');
    
    five = KbName('parenleft');
    Parameters.Keybinds.TTL_5_ASCII = five(1);
    %     Parameters.Keybinds.TTL_5_ASCII = KbName('parenleft');
    
    Parameters.Keybinds.emulTTL_SpaceBar_ASCII = KbName('space');
    
    Parameters.Keybinds.Stop_Escape_ASCII = KbName('ESCAPE');
    
end



%% Echo in command window

disp('--------------------------');
disp(['--- ' mfilename ' done ---']);
disp('--------------------------');
disp(' ');


end