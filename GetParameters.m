function [ Parameters ] = GetParameters
% GETPARAMETERS Prepare common parameters
%
% CONFIG fORRP 932 : USB
%
%     HHSC - 2x4 - C
%     HID NAR 12345
%
% MR CONFON : Stim volume = +10


%% Set parameters

%%%%%%%%%%%
%  Text   %
%%%%%%%%%%%
Parameters.Video.TextSize             = 50;
Parameters.Video.TextFont             = 'Arial';
Parameters.Video.TextColor            = [255 255 255] ; % [R B G] color ( from 0 to 255 )
Parameters.Video.TextSizeInstructions = 18;

%%%%%%%%%%%
%  Cross  %
%%%%%%%%%%%
Parameters.Video.FixationCrossColor = [255 255 255]; % [R B G] color ( from 0 to 255 )

%%%%%%%%%%%%%%
%   Screen   %
%%%%%%%%%%%%%%
Parameters.Video.ScreenWide = 1024;                         % Number of horizontal pixel in MRI video system @ CENIR
Parameters.Video.ScreenHeight = 768;                        % Number of vertical pixel in MRI video system @ CENIR
Parameters.Video.ScreenFrequency = 60;                      % Refresh rate (in Hertz)

Parameters.Video.ScreenBackgroundColor = [0 0 0]; % [R G B] ( from 0 to 255 )
Parameters.Toolbox = 'PsychToolbox';

%%%%%%%%%%%%%%
%  Keybinds  %
%%%%%%%%%%%%%%

KbName('UnifyKeyNames');

Parameters.Keybinds.Right_Blue_1_ASCII   = KbName('1!');
Parameters.Keybinds.Right_Yellow_2_ASCII = KbName('2@');
Parameters.Keybinds.Right_Green_3_ASCII  = KbName('3#');
Parameters.Keybinds.Right_Red_4_ASCII    = KbName('4$');

Parameters.Keybinds.TTL_5_ASCII = KbName('5%');

Parameters.Keybinds.Left_Blue_1_ASCII   = KbName('6^');
Parameters.Keybinds.Left_Yellow_2_ASCII = KbName('7&');
Parameters.Keybinds.Left_Green_3_ASCII  = KbName('8*');
Parameters.Keybinds.Left_Red_4_ASCII    = KbName('9(');

Parameters.Keybinds.emulTTL_SpaceBar_ASCII = KbName('space');

Parameters.Keybinds.Stop_Escape_ASCII = KbName('ESCAPE');


%%%%%%%%%%%
%  Audio  %
%%%%%%%%%%%

Parameters.Audio.SamplingRate            = 44100; % Hz

Parameters.Audio.Playback_Mode           = 1; % 1 = playback, 2 = record
Parameters.Audio.Playback_LowLatencyMode = 1; % {0,1,2,3,4}
Parameters.Audio.Playback_freq           = Parameters.Audio.SamplingRate;
Parameters.Audio.Playback_Channels       = 2; % 1 = mono, 2 = stereo

Parameters.Audio.Record_Mode             = 2; % 1 = playback, 2 = record
Parameters.Audio.Record_LowLatencyMode   = 1; % {0,1,2,3,4}
Parameters.Audio.Record_freq             = Parameters.Audio.SamplingRate;
Parameters.Audio.Record_Channels         = 1; % 1 = mono, 2 = stereo


%% Echo in command window

disp('--------------------------');
disp(['--- ' mfilename ' done ---']);
disp('--------------------------');
disp(' ');


end