function DrawFixation( winPtr , Color , PositionH , PositionV , VisualAngle , PixelPerDegree )

Screen( 'FillRect' , winPtr , [255 255 255] );

diameter = round( PixelPerDegree * VisualAngle );
rectOval = [ 0 0 diameter diameter ];
Screen( winPtr , 'FillOval' , Color , CenterRectOnPoint(rectOval,PositionH,PositionV) );

end
