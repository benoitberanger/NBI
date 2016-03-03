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
        
    otherwise
        
end

% Pulse duration
msg.duration             = 0.005; % seconds

TaskData.ParPortMessages = msg;
