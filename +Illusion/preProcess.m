% Set stimuli parameters : noise, spatial & temporal, ...
Illusion.Common.setParameters % stim (struct)
Illusion.Common.SetAngles     % angles_*

% Link references
scr.main                   = DataStruct.PTB.Window;
scr.rect                   = DataStruct.PTB.WindowRect;
[scr.xres, scr.yres]       = Screen('WindowSize', scr.main);     % heigth and width of screen [pix]
[scr.centerX, scr.centerY] = WindowCenter(scr.main);             % determine th main window's center
scr.fd                     = Screen('GetFlipInterval',scr.main); % frame duration [s]
PixelPerDegree             = va2pix( 1 , DataStruct.Parameters.Video.SubjectDistance , DataStruct.Parameters.Video.ScreenWidthM , DataStruct.Parameters.Video.ScreenWidthPx );
visual.ppd                 = PixelPerDegree;
visual.black               = BlackIndex(scr.main);
visual.white               = WhiteIndex(scr.main);
visual.bgColor             = round((visual.black + visual.white) / 2);     % background color
visual.fgColor             = visual.black;

% Convert in pixel
Illusion.Common.ConvertInPix  % stim (struct) -> update
