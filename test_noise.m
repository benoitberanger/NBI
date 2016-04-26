close all
clear all
clc


%%

figure('Units','Normalized','OuterPosition',[0.01, 0.01, 0.98, 0.98])


%%

m = zeros(500,500);
w = 100;
octaves = 5;
tic
im = Illusion.Common.fractionalNoise(m, w, octaves);
toc*1000

surf(im,'EdgeColor','none')
axis equal
view(2)
colormap(gray(255))


%%

load m_2D
load m_3D

patch = 1;

figure('Units','Normalized','OuterPosition',[0.01, 0.01, 0.98, 0.98])


%%


for i = 1:size(m_2D{patch},3)
    
    ax(1) = subplot(1,2,1);
    image(m_2D{patch}(:,:,i))
    axis(ax(1),'equal')
    view(ax(1),2)
    colormap(ax(1),gray(255))
    title(ax(1),'m_2D','interp','none')
    
    ax(2) = subplot(1,2,2);
    image(m_3D{patch}(:,:,i))
    axis(ax(2),'equal')
    view(ax(2),2)
    colormap(ax(2),gray(255))
    title(ax(2),'m_3D','interp','none')
    
    drawnow
    

    
end


%%


for i = 1:size(m_2D{patch},3)
    
    ax(1) = subplot(1,2,1);
    image(m_2D{patch}(:,:,i))
    axis(ax(1),'equal')
    view(ax(1),2)
    colormap(ax(1),gray(255))
    title(ax(1),'m_2D','interp','none')
    
    ax(2) = subplot(1,2,2);
    image(m_3D{patch}(:,:,i))
    axis(ax(2),'equal')
    view(ax(2),2)
    colormap(ax(2),gray(255))
    title(ax(2),'m_3D','interp','none')
    
    drawnow
    
    pause(0.050)
    
end