function Instructions( DataStruct )
%INSTRUCTIONSNPI Instructions for NPI


%% Localizer

Instructions.Localizer.Training = [
    
'Dans cette expérience,\n'...
'nous vous demandons de regarder attentivement ... \n'...
'\n'...
'Parfois vous verrez une croix blanche à l''écran,\n'...
'nous vous demandons de regarder la croix sans rien faire.\n'...

];


Instructions.Localizer.MRI_training = [
    
'Dans cette expérience,\n'...
'nous vous demandons de regarder attentivement ... \n'...
'\n'...
'Parfois vous verrez une croix blanche à l''écran,\n'...
'nous vous demandons de regarder la croix sans rien faire.\n'...

];


Instructions.Localizer.MRI = [
    
'Dans cette expérience,\n'...
'nous vous demandons de regarder attentivement ... \n'...
'\n'...
'Parfois vous verrez une croix blanche à l''écran,\n'...
'nous vous demandons de regarder la croix sans rien faire.\n'...

];


%% EyelinkCalibrationNPI

Instructions.EyelinkCalibrationNPI  = [
    
'Calibration du suivi des mouvements oculaires.\n'...
'Lorsqu''un point apparait à l''écran, suivez-le du regard.'

];


%% Display of instructions

if strcmp(DataStruct.OperationMode,'Acquisition')
    
    switch DataStruct.Task
        
        case 'Task1'
            switch DataStruct.Environement
                case 'MRI'
                    TextData = Instructions.Localizer.MRI;
                case 'Training'
                    TextData = Instructions.Localizer.Training;
                case 'MRItraining'
                    TextData = Instructions.Localizer.MRI_training;
            end
            
        case 'EyelinkCalibrationNPI'
            TextData = Instructions.EyelinkCalibrationNPI;
    end
    
    
    %% Display
    
    TextData = [TextData '\n = Appuyez sur n''importe quel bouton pour passer les instructions. = '];
    
    switch DataStruct.Environement
        case 'Training'
            TextData = [TextData '\n ==  Puis une seconde fois pour démarrer l''entrainement  == '];
        case 'MRItraining'
            TextData = [TextData '\n ==  Puis une seconde fois pour démarrer l''entrainement  == '];
    end
    
    Screen('TextSize', DataStruct.PTB.Window , DataStruct.Parameters.TextSizeInstructions);
    
    Screen('FillRect', DataStruct.PTB.Window, DataStruct.Parameters.ScreenBackgroundColor )
    
    DrawFormattedText(DataStruct.PTB.Window,TextData,'center','center',DataStruct.Parameters.CrossColor ,0,0,0,2);
    
    Screen('Flip',DataStruct.PTB.Window);
    
    Screen('TextSize', DataStruct.PTB.Window ,  DataStruct.Parameters.TextSize);
    
    
    %% Wait of a key press to end the instuctions function
    
    disp('Waiting for user to advance.')
    
    while 1
        
        [ ~ , ~ , keyCode ] = KbCheck;
        
        
        if ...
                keyCode(DataStruct.Parameters.Keybinds.Right_Blue_1_ASCII) || keyCode(DataStruct.Parameters.Keybinds.Right_Yellow_2_ASCII) ...
                || keyCode(DataStruct.Parameters.Keybinds.Right_Green_3_ASCII) || keyCode(DataStruct.Parameters.Keybinds.Right_Red_4_ASCII) ...
                || keyCode(DataStruct.Parameters.Keybinds.TTL_5_ASCII) || keyCode(DataStruct.Parameters.Keybinds.emulTTL_SpaceBar_ASCII)
            break
            
        elseif keyCode(DataStruct.Parameters.Keybinds.Stop_Escape_ASCII)
            
            sca
            error('InstructionsNPI:Abort','\n ESCAPE key : %s aborted \n', mfilename )
            
        end
        
    end
    
    
end

end