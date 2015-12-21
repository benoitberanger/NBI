function PixelPerDegree = va2pix( VisualAngle , SubjectDistance , ScreenWidthM , ScreenWidthPx )

PixelPerDegree = SubjectDistance * tan(VisualAngle*pi/180) / (ScreenWidthM/ScreenWidthPx);

end
