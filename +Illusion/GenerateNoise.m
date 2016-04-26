try
    %% Set some parameters
    
    nFrames = round(stim.period/scr.fd);
    
    patchesNumber = 16 ;
    
    
    %% Generate patches
    
    % 2D = Stimulus = Illusion
    fprintf('\n Generating 2D noise...')
    noiseArray2D = Illusion.Common.generateNoiseImage(stim,visual, scr.fd);
    for ti = 1:patchesNumber % for each of the patchesNumber noise patches
        noiseArray2D = cat(3, noiseArray2D, Illusion.Common.generateNoiseImage(stim,visual,scr.fd));
    end
    fprintf(' Done \n')
    
    % 3D = Control = Control
    fprintf('\n Generating 3D noise...')
    noiseArray3D = Illusion.Common.generateNoiseVolume(stim,visual, scr.fd);
    for ti = 1:patchesNumber
        noiseArray3D = cat(4, noiseArray3D, Illusion.Common.generateNoiseVolume(stim,visual,scr.fd));
    end
    fprintf(' Done \n')

    
    %% Cut the patches into frames
    
    fprintf('\n Cut the patches into frames...')
    
    m_2D = cell(patchesNumber,1);
    m_3D = cell(patchesNumber,1);
    
    for ti = 1:patchesNumber % for each patch
        
        % 2D
        m2D = Illusion.Common.framesIllusion(stim, visual, noiseArray2D(:,:,ti), scr.fd);
        m_2D{ti} = uint8(m2D);
        
        % 3D
        m = Illusion.Common.framesControl(stim, visual, noiseArray3D(:,:,:,ti), scr.fd);
        m_3D{ti} = uint8(m);
        
    end
    
    fprintf(' Done \n')
    
    
    %% Save the patches
    
    fprintf('\n Save the patches...')
    
    save('m_2D','m_2D','DataStruct','stim','visual','scr');
    save('m_3D','m_3D','DataStruct','stim','visual','scr');
    
    fprintf(' Done \n')
    
    
catch err %#ok<*NASGU>
    
    Common.Catch;
    
end
