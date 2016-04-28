switch DataStruct.ParPort
    
    case 'On'
        
        % Open parallel port
        OpenParPort;
        
        % Set pp to 0
        WriteParPort(0)
        
    case 'Off'
        
end

% Prepare messages
switch DataStruct.Task
    
    case 'NBI'
        
        msg.pathS_InOut          = bin2dec('0 0 0 0 0 0 0 1');
        msg.pathS_Rot            = bin2dec('0 0 0 0 0 0 1 0');
        msg.control2_pathS_InOut = bin2dec('0 0 0 0 0 1 0 0');
        msg.control2_pathS_Rot   = bin2dec('0 0 0 0 1 0 0 0');
        
        msg.Fixation             = bin2dec('1 0 0 0 0 0 0 0');
        
    case 'MTMST_Left'
        
        msg.out      = bin2dec('0 0 0 0 0 0 0 1');
        msg.in       = bin2dec('0 0 0 0 0 0 1 0');
        msg.fixation = bin2dec('0 0 0 0 0 1 0 0');
        
        msg.flash    = bin2dec('0 1 0 0 0 0 0 0');
        msg.clic     = bin2dec('1 0 0 0 0 0 0 0');
        
    case 'MTMST_Right'
        
        msg.out      = bin2dec('0 0 0 0 0 0 0 1');
        msg.in       = bin2dec('0 0 0 0 0 0 1 0');
        msg.fixation = bin2dec('0 0 0 0 0 1 0 0');
        
        msg.flash    = bin2dec('0 1 0 0 0 0 0 0');
        msg.clic     = bin2dec('1 0 0 0 0 0 0 0');
        
    case 'Retinotopy'
        
        msg.cw    = bin2dec('0 0 0 0 0 0 0 1');
        msg.ccw   = bin2dec('0 0 0 0 0 0 1 0');
        
        msg.flic  = bin2dec('0 0 0 0 0 1 0 0');
        msg.flac  = bin2dec('0 0 0 0 1 0 0 0');
        
        msg.flash = bin2dec('0 1 0 0 0 0 0 0');
        msg.clic  = bin2dec('1 0 0 0 0 0 0 0');
        
    case 'Illusion'
        
        msg.Illusion_InOut      = bin2dec('0 0 0 0 0 0 0 1');
        msg.Illusion_rotation   = bin2dec('0 0 0 0 0 0 1 0');
        msg.Control_inOut       = bin2dec('0 0 0 0 0 0 1 1');
        msg.Control_rotation    = bin2dec('0 0 0 0 0 1 0 0');
        msg.Control_global      = bin2dec('0 0 0 0 0 1 0 1');
        msg.Control_local_inOut = bin2dec('0 0 0 0 0 1 1 0');
        msg.Control_local_rot   = bin2dec('0 0 0 0 0 1 1 1');
        
        msg.Null                = bin2dec('0 0 1 0 0 0 0 0');
        
        msg.flash               = bin2dec('0 1 0 0 0 0 0 0');
        msg.clic                = bin2dec('1 0 0 0 0 0 0 0');
        
    otherwise
        
end

% Pulse duration
msg.duration             = 0.005; % seconds

TaskData.ParPortMessages = msg;
