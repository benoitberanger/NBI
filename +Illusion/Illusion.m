function [ TaskData ] = Illusion( DataStruct )

try
    %% Setup
    
    % Load the patches
    load('m_2D')
    load('m_3D')
    
    % Parameters, references, convertions
    Illusion.preProcess;
    
    
    
    %% Parallel port
    
    Common.PrepareParPort;
    
    
    %% Tunning of the task
    
    EP = Illusion.Planning( DataStruct );
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    Common.PrepareRecorders;
    
    
    %% Start recording eye motions
    
    Eyelink.StartRecording( DataStruct );
    
    
    %% Go
    
    
    flip_onset = 0;
    
    frame = 0;
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        switch EP.Data{evt,1}
            
            case 'StartTime'
                
                Screen('FillRect',DataStruct.PTB.Window,DataStruct.Parameters.Video.ScreenBackgroundColor);
                
                % Draw fixation point
                Illusion.DrawFixation;
                
                Common.StartTimeEvent;
                
            case 'StopTime'
                
                Common.StopTimeEvent;
                
                
            otherwise
                
                frame = 0;
                
                fix_counter = 0;
                
                while flip_onset < StartTime + EP.Data{evt+1,2} - DataStruct.PTB.slack * 1
                    
                    % ESCAPE key pressed ?
                    Common.Interrupt;
                    
                    flip_onset = GetSecs;
                    
                end % while
                
                
        end % switch
        
        if Exit_flag
            break %#ok<*UNRCH>
        end
        
        
    end % for
    
    %% End of stimulation
    
    Common.EndOfStimulationScript;
    
    
catch err %#ok<*NASGU>
    
    Common.Catch;
    
end

end

