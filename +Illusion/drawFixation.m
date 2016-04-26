function drawFixation(col,loc,scr,visual)

if length(loc)==2
    loc=[loc loc];
end
pu = round(visual.ppd*0.1);
Screen(scr.main,'FillOval',col,loc+[-pu -pu pu pu]);
% Screen('DrawDots', scr.main, [scr.centerX+pu*2 scr.centerY] ,pu*2 ,col ,[] ,1);
% Screen('DrawDots', scr.main, [scr.centerX+pu*4 scr.centerY] ,pu*2 ,col ,[] ,2);
