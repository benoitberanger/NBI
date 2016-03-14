% Fill background
Screen( 'FillRect' , DataStruct.PTB.Window , (DataStruct.PTB.Black + DataStruct.PTB.White)/2 );

diameter = round( PixelPerDegree * DotVisualAngle );
rectOval = [ 0 0 diameter diameter ];

% Draw the fixation dot
Screen( DataStruct.PTB.Window , 'FillOval' , DataStruct.PTB.Black , CenterRectOnPoint(rectOval, DataStruct.PTB.CenterH ,DataStruct.PTB.CenterV) );
