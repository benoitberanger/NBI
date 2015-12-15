function [ TriggerTime ] = WaitForTTL( DataStruct )

if strcmp(DataStruct.OperationMode,'Acquisition')
    
    if ~isfield(DataStruct,'StartTime') % It means wait for 1st TTL @ Begining of stimulation
        
        % Fixation cross
        Screen(DataStruct.PTB.Window, 'FillRect', DataStruct.Parameters.ScreenBackgroundColor);
        DrawFormattedText(DataStruct.PTB.Window,'+','center','center',DataStruct.Parameters.CrossColor);
        Screen(DataStruct.PTB.Window, 'Flip');
        
        disp('----------------------------------')
        disp('       Waiting for trigger        ')
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
    
    % Restrict keys to check
    RestrictKeysForKbCheck(...
        [ DataStruct.Parameters.Keybinds.Stop_Escape_ASCII...
        , DataStruct.Parameters.Keybinds.TTL_5_ASCII...
        , DataStruct.Parameters.Keybinds.emulTTL_SpaceBar_ASCII...
        , DataStruct.Parameters.Keybinds.Right_Blue_1_ASCII...
        , DataStruct.Parameters.Keybinds.Right_Yellow_2_ASCII...
        , DataStruct.Parameters.Keybinds.Right_Green_3_ASCII...
        ]);
    
    
    % Waitong for TTL signal
    while 1
        
        [ ~ , TriggerTime, keyCode ] = KbCheck;
        
        if strcmp(DataStruct.Environement,'MRI')
            
            
            if keyCode(DataStruct.Parameters.Keybinds.TTL_5_ASCII) || keyCode(DataStruct.Parameters.Keybinds.emulTTL_SpaceBar_ASCII)
                break
                
            elseif keyCode(DataStruct.Parameters.Keybinds.Stop_Escape_ASCII)
                
                % --- Stop recording Eyelink : START ---
                
                % Eyelink mode 'On' ?
                if strcmp(DataStruct.EyelinkMode,'On')
                    
                    % Eyelink toolbox avalable ?
                    if DataStruct.EyelinkToolboxAvailable
                        
                        % Connection initilized ?
                        if Eyelink('IsConnected')
                            
                            % Recording ?
                            err = Eyelink('CheckRecording');
                            if err == 0 % 0 means recording
                                
                                % Stop recording
                                Eyelink('Stoprecording')
                                
                                % Close file
                                status = Eyelink('CloseFile');
                                if status ~= 0
                                    error('CloseFile error, status : %d ',status);
                                end
                                
                            elseif err == -1 % -1 means not recording
                                
                                disp('Eyelink not recording')
                                
                            else
                                
                                warning('Eyelink:CheckRecording','Eyelink(''CheckRecording'') error : %d',err)
                                
                            end
                            
                        end
                        
                    end
                    
                end
                
                % --- Stop recording Eyelink : END ---
                
                sca
                stack = dbstack;
                error('WaitingForTTL:Abort','\n ESCAPE key : %s aborted \n',stack.file)
                
            end
            
        elseif strcmp(DataStruct.Environement,'MRItraining') || strcmp(DataStruct.Environement,'Training')
            
            if keyCode(DataStruct.Parameters.Keybinds.Right_Blue_1_ASCII) || keyCode(DataStruct.Parameters.Keybinds.Right_Yellow_2_ASCII) ...
                    || keyCode(DataStruct.Parameters.Keybinds.Right_Green_3_ASCII) || keyCode(DataStruct.Parameters.Keybinds.Right_Red_4_ASCII)...
                    || keyCode(DataStruct.Parameters.Keybinds.TTL_5_ASCII) || keyCode(DataStruct.Parameters.Keybinds.emulTTL_SpaceBar_ASCII)
                break
                
            elseif keyCode(DataStruct.Parameters.Keybinds.Stop_Escape_ASCII)
                sca
                stack = dbstack;
                error('WitingForTTL:Abort','\n ESCAPE key : %s aborted \n',stack.file)
                
            end
            
        end
        
    end
    
    RestrictKeysForKbCheck([]);
    
else % in DebugMod
    
    if ~isfield(DataStruct,'StartTime') % It means wait for 1st TTL @ Begining of stimulation
        
        disp('Waiting for 1st TTL : DebugMode')
        
    else % All other cases
        
        disp('Waiting for TTL : DebugMode')
        
    end
    
    TriggerTime = GetSecs;
    
end

end
