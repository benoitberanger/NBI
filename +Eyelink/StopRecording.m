function StopRecording( DataStruct )
%STOPRECORDING Check if Eyelink is recording, then stop recording.

% Eyelink mode 'On' ?
if strcmp(DataStruct.EyelinkMode,'On')
    
    % Eyelink toolbox avalable ?
    if EyelinkToolboxAvailable
        
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
                
                % Receive file
                status = Eyelink('ReceiveFile', DataStruct.TaskData.EyelinkFile, DataPath, 1);
                if status > 0
                    disp([ DataStruct.TaskData.EyelinkFile ' size is ' num2str(status) ])
                elseif status == 0
                    disp('File transfer cancelled')
                elseif status < 0
                    error('ReceiveFile error, status : %d ',status);
                end
                
                % Rename Eyelink file
                movefile([DataPath filesep DataStruct.TaskData.EyelinkFile '.edf'], [DataStruct.DataFile '.edf'])
                
                
            elseif err == -1 % -1 means not recording
                
                disp('Eyelink not recording')
                
            else
                
                warning('Eyelink:CheckRecording','Eyelink(''CheckRecording'') error : %d',err)
                
            end
            
        end
        
    end
    
end

end

