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
    
    rect_idx      = size(EP.Data,2) + 1;
    angles_idx    = rect_idx + 1;
    motiontex_idx = angles_idx + 1;
    
    schedule = cell( size(EP.Data,1), motiontex_idx );
    
    for s = 1:size(schedule,1)
        
        schedule(s,1:length(EP.Header)) = EP.Data(s,:);
        
        randPatches = Shuffle(1:nPatches);
        patchesOrder = randPatches(1:16);
        
        switch EP.Data{s,1}
            
            case 'Control_inOut'
                schedule{s,rect_idx}      = rectAll_InOut;
                schedule{s,angles_idx}    = angles_other;
                schedule{s,motiontex_idx} = motionTex3D(patchesOrder,:);
                
            case 'Control_rotation'
                schedule{s,rect_idx}      = rectAll_Rotation;
                schedule{s,angles_idx}    = angles_other;
                schedule{s,motiontex_idx} = motionTex3D(patchesOrder,:);
                
            case 'Control_global'
                schedule{s,rect_idx}      = rectAll_Illusion;
                schedule{s,angles_idx}    = angles_other;
                schedule{s,motiontex_idx} = motionTex3D(patchesOrder,:);
                
            case 'Illusion_InOut'
                schedule{s,rect_idx}      = rectAll_Illusion;
                schedule{s,angles_idx}    = angles_expanding;
                schedule{s,motiontex_idx} = motionTex2D(patchesOrder,:);
                
            case 'Illusion_rotation'
                schedule{s,rect_idx}      = rectAll_Illusion;
                schedule{s,angles_idx}    = angles_rotating;
                schedule{s,motiontex_idx} = motionTex2D(patchesOrder,:);
                
            case 'Control_local_inOut'
                schedule{s,rect_idx}      = rectAll_NoPath;
                schedule{s,angles_idx}    = angles_rotating;
                schedule{s,motiontex_idx} = motionTex2D(patchesOrder,:);
                
            case 'Control_local_rot'
                schedule{s,rect_idx}      = rectAll_NoPath;
                schedule{s,angles_idx}    = angles_expanding;
                schedule{s,motiontex_idx} = motionTex2D(patchesOrder,:);
                
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
            
        case 'FastDebug'
            seq     = seq    ( 1 : round(length(seq)/Speed) );
            seq_tar = seq_tar( 1 : round(length(seq)/Speed) );
            
        case 'RealisticDebug'
            
    end
    
    flip_onset = 0;
    Exit_flag = 0;
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay;
        
        switch EP.Data{evt,1}
            
            case 'StartTime'
                
                % Fill background
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
                    
                    % ESCAPE key pressed ?
                    Common.Interrupt;
                    
                    frame = frame + 1;
                    pp = msg.Null;
                    
                    % Fixation dot
                    Illusion.drawFixation(visual.fgColor,[scr.centerX, scr.centerY],scr,visual)
                    
                    % Tell PTB that no further drawing commands will follow before Screen('Flip')
                    Screen('DrawingFinished', DataStruct.PTB.Window);
                    
                    % Flip
                    flip_onset = Screen('Flip', scr.main);
                    
                    % Clic
                    if keyCode(DataStruct.Parameters.Keybinds.Right_Blue_1_ASCII)
                        RR.AddEvent( { 'Clic' flip_onset-StartTime DataStruct.PTB.IFI } );
                        pp = pp + msg.clic;
                        Common.CLICKecho;
                    end
                    
                    Common.SendParPortMessage
                    
                    if frame == 1
                        
                        switch EP.Data{evt,5}
                            case 1
                                Common.CATCHecho;
                            case 0
                        end
                        
                        % Save onset
                        ER.AddEvent({ EP.Data{evt,1} flip_onset-StartTime })
                        
                    end
                    
                end
                
                
            otherwise
                
                frame = 0;
                fix_counter = 0;
                
                % Catch trial ?
                switch EP.Data{evt,5}
                    case 0
                        as = seq;
                        rep = 1;
                    case 1
                        as = seq_tar;
                        rep = 3;
                end
                
                % Play stimulus
                for r = 1 : rep
                    
                    % Play frames
                    for i = as
                        
                        % ESCAPE key pressed ?
                        Common.Interrupt;
                        
                        frame = frame + 1;
                        pp = msg.(EP.Data{evt,1});
                        
                        % Mothion textures
                        Screen('DrawTextures', scr.main, schedule{evt,motiontex_idx}(:,i), [], squeeze(schedule{evt,rect_idx}(:,:,i)), schedule{evt,angles_idx});
                        
                        % Fixation dot
                        Illusion.drawFixation(visual.fgColor,[scr.centerX, scr.centerY],scr,visual)
                        
                        % Text
                        if ~IsLinux % on UbuntuStudio 14.04, problem of X11 fonts => DrawText crashs
                            switch DataStruct.OperationMode
                                case 'Acquisition'
                                case 'FastDebug'
                                    DrawFormattedText(scr.main, [ num2str(schedule{evt,5}) , ' ' , schedule{evt,1} , ' ' , num2str(schedule{evt,2}) ] );
                                case 'RealisticDebug'
                                    DrawFormattedText(scr.main, [ num2str(schedule{evt,5}) , ' ' , schedule{evt,1} , ' ' , num2str(schedule{evt,2}) ] );
                            end
                        end
                        
                        % Tell PTB that no further drawing commands will follow before Screen('Flip')
                        Screen('DrawingFinished', DataStruct.PTB.Window);
                        
                        % Flip
                        flip_onset = Screen('Flip', scr.main );
                        
                        % Target
                        if schedule{evt,5}
                            pp = pp + msg.flash;
                        end
                        
                        % Clic
                        if keyCode(DataStruct.Parameters.Keybinds.Right_Blue_1_ASCII)
                            RR.AddEvent( { 'Clic' flip_onset-StartTime DataStruct.PTB.IFI } );
                            pp = pp + msg.clic;
                            Common.CLICKecho;
                        end
                        
                        Common.SendParPortMessage
                        
                        if frame == 1
                            
                            switch EP.Data{evt,5}
                                case 1
                                    Common.CATCHecho;
                                    RR.AddEvent( { 'Target' flip_onset-StartTime EP.Data{evt,3} } );
                                case 0
                            end
                            
                            % Save onset
                            ER.AddEvent({ EP.Data{evt,1} flip_onset-StartTime })
                            
                        end
                        
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
