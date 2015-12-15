function DrawFixation( winPtr , Color , PositionH , PositionV , VisualAngle , PixelPerDegree )

diameter = round( PixelPerDegree * VisualAngle );
rectOval = [ 0 0 diameter diameter ];
Screen( winPtr , 'FillOval' , Color , CenterRectOnPoint(rectOval,PositionH,PositionV) );

end
