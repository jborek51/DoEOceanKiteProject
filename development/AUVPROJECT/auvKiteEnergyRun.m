
%% runs the OCT model
 chargingMap = winningPathFinal;
 costBestPathMat = [];

for i = 1:numStages
    
    %if it is not the terminal stage
    if i < numStages
        
    %if you decided to charge 
         if (chargingMap(i) < chargingMap(i+1))
        
            % i is trailing by one from where you actually are in emulating the
            % best flow path
             flowspeed        = flowSpeeds(i); %flowspeed at the charging location
             percentOfBattery = chargingMap(i+1) - chargingMap(i);
             batteryMaxEnergy = percentOfBattery*.01*totalBatteryEnergy ; % telling you how much to charge 

             james_ts
             costBestPath = vhclPosChangeTimePenalty + startKiteCost+tsc.energy.time(end);
         else
             costBestPath = vhclPosChangeTimePenalty; 
         end
       
    else
        if (chargingMap(i) < chargingMap(i+1))
        
            % i is trailing by one from where you actually are in emulating the
            % best flow path
             flowspeed        = flowSpeeds(i); %flowspeed at the charging location
             percentOfBattery = chargingMap(i+1) - chargingMap(i+1);
             batteryMaxEnergy = percentOfBattery*.01*totalBatteryEnergy ; % telling you how much to charge 

             james_ts
             costBestPath = startKiteCost+tsc.energy.time(end);
         else
             costBestPath =0; 
         end
       
    end
    
    
    costBestPathMat =[costBestPathMat,costBestPath];
       
end 
totalTime = sum(costBestPathMat);
figure(12)

plotpos=0;
plottime=0;
for i=1:length(costBestPathMat)
    plotpos(length(plotpos)+1) = plotpos(end) + (.001*posInt);
    plottime(length(plottime)+1) = plottime(end) + vhclPosChangeTimePenalty;
    if costBestPathMat(i) > (vhclPosChangeTimePenalty)
        plotpos(length(plotpos)+1) = plotpos(end);
        plottime(length(plottime)+1) = plottime(end) + (costBestPathMat(i)-vhclPosChangeTimePenalty);
    end
end
plottime=plottime/3600;
% plot( [0,cumsum(costBestPathMat)./3600],0:.001*posInt:2*.001*xq(end))
plot(plottime,plotpos)
title('Time vs. Position: Dynamic Programming Solution')
ylabel('Position(Km)')
xlabel('Time (Hrs)')
