function [ TaskData ] = NBI( DataStruct )

try
    %% Parallel port
    
    Common.PrepareParPort;
    
    
    %% Preparation of movies
    
    % Load location
    movie(1).file = [ pwd filesep 'videos' filesep 'pathS_InOut.mov'          ];
    movie(2).file = [ pwd filesep 'videos' filesep 'pathS_Rot.mov'            ];
    movie(3).file = [ pwd filesep 'videos' filesep 'control2_pathS_InOut.mov' ];
    movie(4).file = [ pwd filesep 'videos' filesep 'control2_pathS_Rot.mov'   ];
    
    %     movie(1).file = [ pwd filesep 'videos' filesep 'test_InOut.mov'          ];
    %     movie(2).file = [ pwd filesep 'videos' filesep 'test_Rot.mov'            ];
    %     movie(3).file = [ pwd filesep 'videos' filesep 'control2_pathS_InOut.mov' ];
    %     movie(4).file = [ pwd filesep 'videos' filesep 'control2_pathS_Rot.mov'   ];
    
    Common.OpenMovies;
    
    
    %% Tunning of the task
    
    NBI.Planning;
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    Common.PrepareRecorders;
    
    
    %% Prepare fixation dot
    
    PixelPerDegree = va2pix( 1 , DataStruct.Parameters.Video.SubjectDistance , DataStruct.Parameters.Video.ScreenWidthM , DataStruct.Parameters.Video.ScreenWidthPx );
    
    DotVisualAngle = 0.1;
    
    
    %% Start recording eye motions
    
    TaskData.EyelinkFile = Eyelink.StartRecording( DataStruct );
    
    
    %% Go
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        switch EP.Data{evt,1}
            
            case 'StartTime'
                
                % Draw fixation point
                NBI.DrawFixation;
                
                Common.StartTimeEvent;
                
                
            case 'Fixation'
                
                % Draw fixation point
                NBI.DrawFixation;
                
                % Flip video
                fixation_onset = Screen( 'Flip' , DataStruct.PTB.Window , StartTime + EP.Data{evt,2} - DataStruct.PTB.slack * 1 );
                %                 fixation_onset = Screen( 'Flip' , DataStruct.PTB.Window );
                
                % Parallel port message
                if strcmp( DataStruct.ParPort , 'On' )
                    WriteParPort( EP.Data{evt,6} );
                    WaitSecs( msg.duration );
                    WriteParPort( 0 );
                end
                
                % Save onset
                ER.AddEvent({ 'Fixation' fixation_onset-StartTime })
                
                % Fixation duration handeling
                % WaitSecs('UntilTime', StartTime + EP.Data{evt+1,2} - DataStruct.PTB.slack * 1 );
                
                
            case 'StopTime'
                
                Common.StopTimeEvent;
                
                
            otherwise % == movie
                
                % Which condition ?
                switch EP.Data{evt,1}
                    
                    case 'pathS_InOut'
                        movie_ref = 1; %#ok<*NASGU>
                        
                    case 'pathS_Rot'
                        movie_ref = 2;
                        
                    case 'control2_pathS_InOut'
                        movie_ref = 3;
                        
                    case 'control2_pathS_Rot'
                        movie_ref = 4;
                        
                end
                
                % Speed ?
                if Speed ~= 1
                    DeadLine = EP.Data{evt,3};
                else
                    DeadLine = Inf;
                end
                
                % Video start onset ?
                when = StartTime + EP.Data{evt,2} - DataStruct.PTB.slack * 2;
                
                % Play
                Common.PlayMovieTrial;
                
                if Exit_flag
                    
                    break
                    
                end
                
                fprintf(' \n Real movie duration = %.3f s \n ' , Last_frame - First_frame )
                
                % Save onset
                ER.AddEvent({ EP.Data{evt,1} First_frame-StartTime })
                
        end % switch
        
    end % for
    
    
    %% End of stimulation
    
    Common.EndOfStimulationScript;
    
    
catch err
    
    Common.Catch;
    
end

end
