%script for visualizing transect data from shamir
%%

% load transect Data
% load('2014_new')

load('E:\flowData\2014_new')  
timeSel = 7000;
lonRad = deg2rad(lon(1:16));
latRad = deg2rad(lat(1:16));
radiusE  = 6.371e6; 
[X,Y,Z] = sph2cart(lonRad',latRad',radiusE);
botherJames = 0; 




arcLengths  = sqrt((X(2:end) - X(1:end-1)).^2 +   (Y(2:end) - Y(1:end-1)).^2 + (Z(2:end) - Z(1:end-1)).^2 );
xPosAL =[0, cumsum(arcLengths)];
maxV=zeros(1,16);
Ubot = zeros(1,16);
Vbot = zeros(1,16);
V = NaN(size(squeeze(u(timeSel,1:16,:))));
U = NaN(size(V));%East
V = NaN(size(V));%North
for i = 1:16

tempV = sqrt(squeeze(u(timeSel,i,~isnan(u(timeSel,i,:)))).^2 + ...
             squeeze(v(timeSel,i,~isnan(v(timeSel,i,:)))).^2);
         
U(1:length(tempV),i) = squeeze(u(timeSel,i,~isnan(u(timeSel,i,:))));
Ubot(i) = U(find(~isnan(U(:,i)),1,'last'),i);
V(1:length(tempV),i) = squeeze(v(timeSel,i,~isnan(u(timeSel,i,:))));
Vbot(i) = V(find(~isnan(V(:,i)),1,'last'),i);

V(1:length(tempV),i)=tempV;
maxV(i)=max(tempV);
end
xq = linspace(0,xPosAL(end),100); 
vq = interp1(xPosAL,maxV,xq);
Ubot = interp1(1:16,Ubot,linspace(1,16,length(xq)));
Vbot = interp1(1:16,Vbot,linspace(1,16,length(xq)));
%East is x, North is y
moveDirXv = interp1(1:15,diff(lonRad),linspace(1,15,length(xq)));
moveDirYv = interp1(1:15,diff(latRad),linspace(1,15,length(xq)));
moveDirX = moveDirXv ./ sqrt(moveDirXv.^2 + moveDirYv.^2);
moveDirY = moveDirYv ./ sqrt(moveDirXv.^2 + moveDirYv.^2);

% flowDirX = 
%plot(xq,vq)
 
title(' Max flow velocity vs.  Transect Positions')
ylabel('Max Flow Velocity (m/s)')
xlabel('Transect Positions (m)')
 
constVel = 1.25;
Ubot = [Ubot flip(Ubot)];
Vbot = [Vbot flip(Vbot)];
moveDirX = [moveDirX flip(-1*moveDirX)];
moveDirY = [moveDirY flip(-1*moveDirY)];
for i=1:length(Ubot)
    %vapp = sqrt((VwindEast-VEast)^2 + (north)^2)
    vApp(i)=sqrt((Ubot(i) - (constVel*moveDirX(i)))^2 + (Vbot(i) - (constVel*moveDirY(i)))^2);
end
    




% u(time,station,z): u velocity
% v(time,station,z): v velocity

%  if botherJames == 1
% figure;
% contourf(flipud(U)) 
%  end 
