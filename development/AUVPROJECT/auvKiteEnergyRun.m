
%% runs the OCT model
 chargingMap = winningPathFinal;
 costBestPathMat = [];

for i = 1:numStages-1
    
    %if it is not the terminal stage
    if i < numStages-1
        
    %if you decided to charge 
         if (chargingMap(i) < chargingMap(i+1))
        
            % i is trailing by one from where you actually are in emulating the
            % best flow path
             flowspeed        = flowSpeeds(i+1); %flowspeed at the charging location
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
             flowspeed        = flowSpeeds(i+1); %flowspeed at the charging location
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
figure(88)
plot( 0:.001*posInt:2*.001*xq(end)-.001*posInt,[0,cumsum(costBestPathMat)./3600])
title('Time vs. Position')
xlabel('Position(Km)')
ylabel('Time (Hrs)')