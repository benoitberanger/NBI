function [ TaskData ] = Illusion( DataStruct )

try
    %% Parallel port
    
    Common.PrepareParPort;
    
    
    %% Tunning of the task
    
    [ EP , Speed ] = Illusion.Planning( DataStruct );
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    Common.PrepareRecorders;
    
    
    %% Setup
    
    % Load the patches
    load('m_2D')
    load('m_3D')
    
    % Parameters, references, convertions
    Illusion.preProcess;
    
    % Prepare motion textures
    nPatches = length(m_2D); %#ok<*USENS>
    nFrames = round(stim.period/scr.fd); %#ok<*NODEF>
    motionTex2D = zeros(nPatches, nFrames);
    motionTex3D = motionTex2D;
    
    % Create the textures
    for ti = 1:nPatches % for each patch
        for i=1:nFrames % for each frame
            motionTex2D(ti,i)=Screen('MakeTexture', scr.main, m_2D{ti}(:,:,i));
            motionTex3D(ti,i)=Screen('MakeTexture', scr.main, m_3D{ti}(:,:,i));
        end
    end
    
    % Compute path coordinates
    rectAll_Illusion = Illusion.Common.coordIllusion(stim, visual, scr);
    rectAll_InOut    = Illusion.Common.coordInOut(stim, visual, scr);
    rectAll_Rotation = Illusion.Common.coordRotation(stim, visual, scr);
    stim.pathLength  = 0;
    rectAll_NoPath   = Illusion.Common.coordIllusion(stim, visual, scr);
    
    % Set sequence index (motion start at trajectory midpoint)
    Illusion.Common.SetSequenceIndex;
    
    DotVisualAngle = 2*round(visual.ppd*0.1);
    
    %% Parse the planning
    
    conditions_with_patches = 7;
    
    % shuffleAll = Shuffle(repmat((1:nPatches)',[1 conditions_with_patches]));
    shuffleAll = repmat((1:nPatches)',[1 conditions_with_patches]);
    
    rect_idx      = size(EP.Data,2) + 1;
    angles_idx    = rect_idx + 1;
    motiontex_idx = angles_idx + 1;
    
    schedule = cell( size(EP.Data,1), motiontex_idx );
    
    for s = 1:size(schedule,1)
        
        schedule(s,1:length(EP.Header)) = EP.Data(s,:);
        
        switch EP.Data{s,1}
            
            case 'Control_inOut'
                schedule{s,rect_idx}      = rectAll_InOut;
                schedule{s,angles_idx}    = angles_other;
                schedule{s,motiontex_idx} = motionTex3D(shuffleAll(:,1),:);
                
            case 'Control_rotation'
                schedule{s,rect_idx}      = rectAll_Rotation;
                schedule{s,angles_idx}    = angles_other;
                schedule{s,motiontex_idx} = motionTex3D(shuffleAll(:,2),:);
                
            case 'Control_global'
                schedule{s,rect_idx}      = rectAll_Illusion;
                schedule{s,angles_idx}    = angles_other;
                schedule{s,motiontex_idx} = motionTex3D(shuffleAll(:,3),:);
                
            case 'Illusion_InOut'
                schedule{s,rect_idx}      = rectAll_Illusion;
                schedule{s,angles_idx}    = angles_expanding;
                schedule{s,motiontex_idx} = motionTex2D(shuffleAll(:,4),:);
                
            case 'Illusion_rotation'
                schedule{s,rect_idx}      = rectAll_Illusion;
                schedule{s,angles_idx}    = angles_rotating;
                schedule{s,motiontex_idx} = motionTex2D(shuffleAll(:,5),:);
                
            case 'Control_local_inOut'
                schedule{s,rect_idx}      = rectAll_NoPath;
                schedule{s,angles_idx}    = angles_rotating;
                schedule{s,motiontex_idx} = motionTex2D(shuffleAll(:,5),:);
                
            case 'Control_local_rot'
                schedule{s,rect_idx}      = rectAll_NoPath;
                schedule{s,angles_idx}    = angles_expanding;
                schedule{s,motiontex_idx} = motionTex2D(shuffleAll(:,5),:);
                
            case 'Null'
                schedule{s,rect_idx}      = [];
                schedule{s,angles_idx}    = [];
                schedule{s,motiontex_idx} = [];
                
            case 'StartTime'
                
            case 'StopTime'
                
            otherwise
                error( 'stim unrecognised : %s' , schedule{s} )
                
        end
        
    end
    
    
    %% Start recording eye motions
    
    Eyelink.StartRecording( DataStruct );
    
    
    %% Go
    
    switch DataStruct.OperationMode
        
        case 'Acquisition'
            as = seq;
            
        case 'FastDebug'
            as = seq( 1 : round(length(seq)/10) );
            
        case 'RealisticDebug'
            as = seq;
            
    end
    
    flip_onset = 0;
    Exit_flag = 0;
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        switch EP.Data{evt,1}
            
            case 'StartTime'
                
                Screen('FillRect',DataStruct.PTB.Window,DataStruct.Parameters.Video.ScreenBackgroundColor);
                
                % Draw fixation point
                Illusion.drawFixation(visual.fgColor,[scr.centerX, scr.centerY],scr,visual)
                
                Common.StartTimeEvent
                
            case 'StopTime'
                
                Common.StopTimeEvent
                
                
            case 'Null'
                
                frame = 0;
                fix_counter = 0;
                
                while flip_onset < StartTime + EP.Data{evt+1,2} - DataStruct.PTB.slack * 2
                    
                    frame = frame + 1;
                    
                    % ESCAPE key pressed ?
                    Common.Interrupt;
                    
                    % Fixation dot
                    Illusion.drawFixation(visual.fgColor,[scr.centerX, scr.centerY],scr,visual)
                    
                    % Text
                    DrawFormattedText(scr.main, [ schedule{evt,1} , ' ' , num2str(schedule{evt,2}) ] );
                    
                    % Flip
                    flip_onset = Screen('Flip', scr.main);
                    
                    if frame == 1
                        
                        % Save onset
                        ER.AddEvent({ EP.Data{evt,1} flip_onset-StartTime })
                        
                    end
                    
                end
                    
                
            otherwise
                
                frame = 0;
                fix_counter = 0;
                
                for i = as
                    
                    frame = frame + 1;
                    
                    % ESCAPE key pressed ?
                    Common.Interrupt;
                    
                    % Mothion textures
                    if ~strcmp(schedule{evt,1},'Null')
                        Screen('DrawTextures', scr.main, schedule{evt,motiontex_idx}(:,i), [], squeeze(schedule{evt,rect_idx}(:,:,i)), schedule{evt,angles_idx});
                    end
                    
                    % Fixation dot
                    Illusion.drawFixation(visual.fgColor,[scr.centerX, scr.centerY],scr,visual)
                    
                    % Text
                    DrawFormattedText(scr.main, [ schedule{evt,1} , ' ' , num2str(schedule{evt,2}) ] );
                    
                    % Flip
                    flip_onset = Screen('Flip', scr.main );
                    
                    if frame == 1
                        
                        % Save onset
                        ER.AddEvent({ EP.Data{evt,1} flip_onset-StartTime })
                        
                    end
                    
                end

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

