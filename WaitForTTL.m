function [ TriggerTime ] = WaitForTTL( DataStruct )

if strcmp(DataStruct.OperationMode,'Acquisition')
    
    if ~isfield(DataStruct,'StartTime') % It means wait for 1st TTL @ Begining of stimulation
        
        disp('----------------------------------')
        disp('        Waiting for trigger       ')
        disp('                OR                ')
        disp(' Press "Space" to emulate trigger ')
        disp('      Press "Escape" to abort     ')
        disp('----------------------------------')
        disp(' ')
        
    else % All other cases
        
        disp('Waiting for TTL')
        
    end
    
    % Just to be sure the user is not pushing a button before
    WaitSecs(0.2); % secondes
    
    % Waiting for TTL signal
    while 1
        
        [ keyIsDown , TriggerTime, keyCode ] = KbCheck;
        
        if keyIsDown
            
            switch DataStruct.Environement
                
                case 'MRI'
                    
                    if keyCode(DataStruct.Parameters.Keybinds.TTL_5_ASCII) || keyCode(DataStruct.Parameters.Keybinds.emulTTL_SpaceBar_ASCII)
                        break
                        
                    elseif keyCode(DataStruct.Parameters.Keybinds.Stop_Escape_ASCII)
                        
                        % Stop routine for Escape key
                        Eyelink.STOP(DataStruct)
                        
                        sca
                        stack = dbstack;
                        error('WaitingForTTL:Abort','\n ESCAPE key : %s aborted \n',stack.file)
                        
                    end
                    
                case 'Training'
                    
                    if keyCode(DataStruct.Parameters.Keybinds.Right_Blue_1_ASCII) || keyCode(DataStruct.Parameters.Keybinds.TTL_5_ASCII) || keyCode(DataStruct.Parameters.Keybinds.emulTTL_SpaceBar_ASCII)
                        break
                        
                    elseif keyCode(DataStruct.Parameters.Keybinds.Stop_Escape_ASCII)
                        sca
                        stack = dbstack;
                        error('WitingForTTL:Abort','\n ESCAPE key : %s aborted \n',stack.file)
                        
                    end
                    
            end
            
        end
        
    end
    
    
else % in DebugMod
    
    if ~isfield(DataStruct,'StartTime') % It means wait for 1st TTL @ Begining of stimulation
        
        disp('Waiting for 1st TTL : DebugMode')
        
    else % All other cases
        
        disp('Waiting for TTL : DebugMode')
        
    end
    
    TriggerTime = GetSecs;
    
end

end
