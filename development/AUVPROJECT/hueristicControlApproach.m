
% clear all; 

transectData

%% Constants
%number of stages 
n = 2; %n = the number of times going one way. Back and forth, n = 2 
numStages                = n*length(vq);
flowSpeeds               = round([vq,fliplr(vq)],3); 

%xdistance between each stage
posInt                   = xq(end)/length(vq);

%fluid density
densityOfFluid           = 1000; %kg/m^3

%refarea
aRef                     = 10; %m^2

%maximum battery energy capacity 
totalBatteryEnergy        = 23400000; %joules %100 KHW

%start with full battery

vhclVelocity             = [1.25;0;0]; % m/s %velocity of the vehicle
vhclVelMag               = 1.25;%sqrt(sum(vhclVelocity.^2));

%possible Battery Life
possibleBatteryLife      = 0:100;

 chargeOnePercentPerFlowSpeed = [];
%% charging data
%time cost from charging at  flowspeeds at 100 different flow speeds
%TODO: Run OCTModel with a range of constant flow speeds

% stationary turbine 
 eff=.5;
 Aturb=2*8.5;%m^3
 energyInOnePercent =totalBatteryEnergy/100; %Joules THIS NUMBER IS RANDOM AND SHOULD BE A REAL NUMBER
%  chargeOnePercentPerFlowSpeed = energyInOnePercent./(eff*.5*1000*Aturb*flowSpeeds.^3);

%  chargeOnePercentPerFlowSpeed             = 30./flowSpeeds;%randi(10,1,100);

x1 =  [.1,.5,1,1.5,2];
x2 =  [5,1268,8670,35390,83130];
flowForPower = .1:.001:2;
interpolatedPower = interp1(x1,x2,flowForPower,'cubic');
timeToChargePF =  energyInOnePercent./interpolatedPower;
format long
for q = 1:length(flowSpeeds)
    
    tempFlow = flowSpeeds(q)
   [num,ind]=find(abs(10000000000*(flowForPower-tempFlow))<1)  ;
    
   indOfTTC = timeToChargePF(ind)
   chargeOnePercentPerFlowSpeed = [chargeOnePercentPerFlowSpeed,indOfTTC ];
   
end

%  plot(chargeOnePercentPerFlowSpeed)
%  figure(2)
%  plot(flowSpeeds)
% VEHICLE POSITION TO POSITION STAGE PENALTY (TIME)
vhclPosChangeTimePenalty = posInt/vhclVelMag ; %tau

% COST TO REAL IN AN OUT THE KITE 
startKiteCost = 600; %seconds

% 
% %% final cost computation 
% changingInitandFinalCondition = [];
% for pp = 100:-1:3
%     
%     disp(pp)
%             terminalCost              = [];
%             termAndInitCondition      = pp;
%             % Total matrix of indexes for the best previous at each current
%             totalIndexMat = [];
% 
%             % Total matrix of smallest cost at each stage of the previous
%             initialStateCostPerStage = [];
%   for j = 1:length(possibleBatteryLife)
%       
%             terminalBatteryRemaining  = pp - possibleBatteryLife(j); 
%             if terminalBatteryRemaining > 0
%                 timeToChargeToFull        = chargeOnePercentPerFlowSpeed(200)*terminalBatteryRemaining + startKiteCost;
%             else
%                 timeToChargeToFull        = 0;
%             end
%             terminalCost              = [terminalCost,timeToChargeToFull]; 
%             
%   end 
% %% for loop 
% %                     current     previous
% % 0          0             0        0 
% % 0          0             0        0 
% % 0          0             0        0 
% % 0          0             0        0 
% %     new Current  new previous
% 
% 
% 
% 
% 
% %stage before the last backwards to 
% for i = numStages-1:-1:2 %TODO the final virtual stage might be counted as a full stage. %FINISHED: I don't think that it is 
%     
%             smallestCostMat          = []; % initializing the matrix that is updated per stage that holds the smallest costs per state of the CURRENT STAGE
%             indexMat                 = []; % initializing the matrix that is updated per stage that holds the index of the state with the smallest costs in the PREVIOUS per state of the CURRENT STAGE
%     %number of states in current stage
%     for ii = length(possibleBatteryLife):-1:1
%    
%             
%             
%             vWind                    = flowSpeeds(i);  %velocity of wind at current stage
%             stateBatteryLife         = possibleBatteryLife(ii); %possible battery lifes %states of the CURRENT STAGE
%             
%             
% %%%%%%%%%%%%%%%%% DRAG DYNAMICS
%             Cd                       = 1.1*(.05*10 + .42*(.25*pi*1^2))/(10+(.25*pi*1^2)); 
%             
%             
%             dragForce                = .5.*densityOfFluid.*vApp(i).^2 .*aRef.*Cd;
% 
% %%%%%%%%%%%%%%%%%INCREASE IN CHARGE COST 
%             
%             dragEnergy               = dragForce * posInt; 
%             propulsionEnergy         = dragEnergy; %maxPropusionEnergy = propulsionPower * vhclPosChangeTimePenalty ;  
%             energySpentToMovePercent = ceil(100*propulsionEnergy/totalBatteryEnergy);
%             batteryEnergyRemaining   = stateBatteryLife - energySpentToMovePercent;
%             timeChargeOnePercentCur  = chargeOnePercentPerFlowSpeed(i-1); %time to charge one percent at the current flowspeed 
%             
%             %if you cannot make it to next position, you have to stop and
%             %charge until you can make it. Your battery in the next stage
%             %is now zero starting out
%             if batteryEnergyRemaining< 0   
%                  timePenaltyCantMakeIt    = timeChargeOnePercentCur * (energySpentToMovePercent - batteryEnergyRemaining);
%                  batteryEnergyRemaining   = 0;
%                  totalAddedStageCost      = timePenaltyCantMakeIt + startKiteCost+10000000; %This should never be chosen
%             else
%                  totalAddedStageCost      = 0;
%             end
%             
%             
%             costToFinishMat          = [];
%         
%         % possible battery life = states
%         for iii = length(possibleBatteryLife):-1:1  %Note: battery life must be in single digit percents 
% 
%             timeChargeOnePercentPrev = chargeOnePercentPerFlowSpeed(i); %time to charge one percent at the previous flowspeed
%             timePenaltyCharging      = timeChargeOnePercentPrev*(possibleBatteryLife(iii)-batteryEnergyRemaining);
% 
%             %as you change stages, the cost to finish at each state combo is
%             %carried back
%             if ~isempty(initialStateCostPerStage)
%                 initialStateCost          = initialStateCostPerStage((length(possibleBatteryLife)+1)-iii,(numStages-1)-i); % grabbing the first element of the cost per state in the previous stage. This is how the costs travel backwards through each stage.
%             else
%                 initialStateCost          = 0; %If you havent gone through any current to previous stage pairs yet, the initial state cost is the terminal cost     
%             end
%             
%             
%             
%             if timePenaltyCharging   == 0 
%                 costToFinish             = totalAddedStageCost + vhclPosChangeTimePenalty + initialStateCost;  
%             elseif timePenaltyCharging <0 
%                 costToFinish             = NaN;
%             else
%                 costToFinish             = totalAddedStageCost + vhclPosChangeTimePenalty + timePenaltyCharging + startKiteCost + initialStateCost;
%             end
%             
%             
%             % if it is the first time running the loop, the
%             % initialStateCostPerStage matrix ( the matrix which stores the
%             % minimum cost per state of the CURRENT stage
%             if i == numStages-1
% %                   if pp < stateBatteryLife  
% %                      costToFinish = NaN;
% %                   else
%                 
%                 costToFinish = costToFinish + terminalCost(iii);
% %                   end
%             end
%             
%             costToFinishMat          =[costToFinishMat,costToFinish];
%         end
%         
%            [smallestCost,index]      = min(costToFinishMat);
%            
%             %matrix of smallest costs for each state of current stage
%             smallestCostMat          =[smallestCostMat; smallestCost];
%             
%             %matrix of indices of smallest costs for each state of current stage
%             indexMat                 =[indexMat;index]; 
%             
% 
%     end   
%             %matrix of smallest costs for each state for all stages
%             initialStateCostPerStage =[initialStateCostPerStage,smallestCostMat];
%             
%             %matrix of indices of smallest costs for each state of all
%             %stages
%             totalIndexMat            =[totalIndexMat, indexMat];
%         
%     
% end
%                     
% %creating the paths that were taken
% %     columns
% eachPathMatr = {}; %initializing final path per element of last column matrix 
% 
% 
% %rows
% for j = 1:length(possibleBatteryLife)
%     
%      pathMat         = [];
%      costTrackingMat = [];
%      position1       =  totalIndexMat(j,end);
%      position1Cost   = initialStateCostPerStage(j,end);
%     %     columns
%     for p =  numStages-2:-1:2
%     
%         if p == numStages-2 
%              position2     = totalIndexMat(position1,p);
%              position2Cost = initialStateCostPerStage(position1,p);
%         else
%              position2     = totalIndexMat(position2,p); 
%              position2Cost = initialStateCostPerStage(position2,p); 
%         end
%     
%     
%     %path mat is a matrix of indexs each elements of the last column took
%    
%     pathMat                = [pathMat,position2];
%     costTrackingMat        = [costTrackingMat,position2Cost];    
%     end
%     eachPathMatr{j}        = [position1,pathMat];
%     eachCostTrackingMat{j} = [position1Cost, costTrackingMat];
% end
% 
% 
% %the results of each pathMatr show the paths that were taken starting from
% %the the stage ( 1 before end ) to the stage 2. This is kind of confusing
% %to look at because the indices look like they should be battery like but
% %they are really 101-index equals battery life.  
% 
% % So, I am reformating to show the steps in battery life
% %
% for i = 1:length(eachPathMatr)
%    batteryLifeSteps{i} = 101- eachPathMatr{i};
% end
% 
% % figure(1)
% %  plot((batteryLifeSteps{1}))
% %  
% % title('Battery Percentage vs. Transect position Increment ')
% % ylabel('Battery Percentage (s)')
% % xlabel('Transect position Increment')
% % figure(1)
%  
% % for i = 1:length(eachPathMatr)
% % plot(batteryLifeSteps{i})
% % hold on 
% % end 
% % 
% % title('Battery Percentage vs. Transect position Increment ')
% % ylabel('Battery Percentage (s)')
% % xlabel('Transect position Increment')
% % hold off
% % 
% % figure(2);plot(chargeOnePercentPerFlowSpeed)   
% % title('Inversion of Max Flow Profile')
% % ylabel('Example Time To Charge One Battery Increment (s)')
% % xlabel('Transect position Increment')
% 
% 
% %% cost for initial position to finish
% 
%             vWind                    = flowSpeeds(1);
%             stateBatteryLife         = pp; %possibleBatteryLife(end); 
%             
% %%%%%%%%%%%%%%%%% INITIAL DRAG DYNAMICS
%             Cd                       = 1.1*(.05*10 + .42*(.25*pi*1^2))/(10+(.25*pi*1^2)); 
%             dragForce                = .5.*densityOfFluid.*vApp(i).^2 .*aRef.*Cd;      
%             dragEnergy               = dragForce * posInt; 
%             propulsionEnergy         = dragEnergy; %maxPropusionEnergy = propulsionPower * vhclPosChangeTimePenalty ;  
%             energySpentToMovePercent = ceil(100*propulsionEnergy/totalBatteryEnergy);
%             batteryEnergyRemaining   = stateBatteryLife - energySpentToMovePercent;  
%             timeChargeOnePercentInit = chargeOnePercentPerFlowSpeed(2);
%             initCostToFinishMat      = [];
% for iii = length(possibleBatteryLife):-1:1
% 
%             timePenaltyCharging      = timeChargeOnePercentInit*(possibleBatteryLife(iii)-batteryEnergyRemaining);
%             initialStateCost         = initialStateCostPerStage((length(possibleBatteryLife)+1)-iii,end);
%             if timePenaltyCharging   == 0 
%                 initCostToFinish         =  vhclPosChangeTimePenalty + initialStateCost;  
%             elseif timePenaltyCharging <0 
%                 initCostToFinish         = NaN;
%             else
%                 initCostToFinish         = vhclPosChangeTimePenalty + timePenaltyCharging + startKiteCost + initialStateCost ;
%             end
%             
%             initCostToFinishMat       =[initCostToFinishMat,initCostToFinish];
%            
% end
%     [smallestCostInit,indexInit]      = min(initCostToFinishMat);
%     winningPath{pp} = [pp,101-indexInit, batteryLifeSteps{indexInit},pp];
%     
% %     figure(99)
% %     plot(0:1:200,winningPath{pp})
% %     
% %     title('Winning Path')
% %     ylabel('Battery Percentage (s)')
% %     xlabel('Transect position Increment')
% %     xlim([0,200])    
% %     hold on
%     
%     
%     changingInitandFinalCondition     =  [changingInitandFinalCondition,smallestCostInit];
%     
% 
% 
% 
% 
% 
% end
% hold off
% [smallestStartingPoint,indexChng]      = mink(changingInitandFinalCondition,5);
% %%
% 
%   winningPathFinal = winningPath{indexChng(1)};
% % winningPathFinal = winningPath{99};
% % figure(5)
% % plot(0:1:200, winningPathFinal  ) 
% % title('Winning Path')
% % ylabel('Battery Percentage (s)')
% % xlabel('Transect position Increment')
% % xlim([0,200])
% 
% costBestPathMat = [];
% chargingMap = winningPathFinal;
% for i = 1:numStages
%     
%     %if it is not the terminal stage
%     if i < numStages
%         
%     %if you decided to charge 
%          if (chargingMap(i) < chargingMap(i+1))
%         
%             % i is trailing by one from where you actually are in emulating the
%             % best flow path
%              flowspeed        = flowSpeeds(i+1); %flowspeed at the charging location
%              percentOfBattery = chargingMap(i+1) - chargingMap(i);
%              chargeOnePercentPerFlowSpeedFinal = chargeOnePercentPerFlowSpeed(i+1);
%              chargingTime = percentOfBattery*chargeOnePercentPerFlowSpeedFinal; % telling you how much to charge 
%              costBestPath = vhclPosChangeTimePenalty + startKiteCost+chargingTime;
%          else
%              costBestPath = vhclPosChangeTimePenalty; 
%          end
%        
%     else
%         if (chargingMap(i) < chargingMap(i+1))
%         
%             % i is trailing by one from where you actually are in emulating the
%             % best flow path
%              flowspeed        = flowSpeeds(i+1); %flowspeed at the charging location
%              percentOfBattery = chargingMap(i+1) - chargingMap(i);
%              chargeOnePercentPerFlowSpeedFinal = chargeOnePercentPerFlowSpeed(i+1);
%              chargingTime = percentOfBattery*chargeOnePercentPerFlowSpeedFinal; % telling you how much to charge  
% 
%              
%              costBestPath = startKiteCost+chargingTime;
%          else
%              costBestPath =0; 
%          end
%        
%     end
%     
%     
%     costBestPathMat =[costBestPathMat,costBestPath];
%        
% end 
%     
% totalTime = sum(costBestPathMat);
% figure(11)
% 
% plotpos=0;
% plottime=0;
% for i=1:length(oldtimes)
%     plotpos(length(plotpos)+1) = plotpos(end) + (.001*posInt);
%     plottime(length(plottime)+1) = plottime(end) + vhclPosChangeTimePenalty;
%     if costBestPathMat(i) > (vhclPosChangeTimePenalty)
%         plotpos(length(plotpos)+1) = plotpos(end);
%         plottime(length(plottime)+1) = plottime(end) + (costBestPathMat(i)-vhclPosChangeTimePenalty);
%     end
% end
% plottime=plottime/3600;
% % plot( [0,cumsum(costBestPathMat)./3600],0:.001*posInt:2*.001*xq(end))
% plot(plottime,plotpos)
% title('Time vs. Position')
% ylabel('Position(Km)')
% xlabel('Time (Hrs)')
% 
% %auvKiteEnergyRun


%%



batteryPercent = 1000; 
timePenMat = [];
batMat = [];

for i = 1:numStages
            vWind                    = flowSpeeds(i);
            batMat = [batMat,batteryPercent]
%%%%%%%%%%%%%%%%%  DRAG DYNAMICS
            Cd                       = 1.1*(.05*10 + .42*(.25*pi*1^2))/(10+(.25*pi*1^2)); 
            dragForce                = .5.*densityOfFluid.*vApp(i).^2 .*aRef.*Cd;      
            dragEnergy               = dragForce * posInt; 
            propulsionEnergy         = dragEnergy; %maxPropusionEnergy = propulsionPower * vhclPosChangeTimePenalty ;  
            energySpentToMovePercent = ceil(1000*propulsionEnergy/totalBatteryEnergy);
            batteryEnergyRemaining   = batteryPercent - energySpentToMovePercent;  
            disp(batteryEnergyRemaining)
            timeChargeOnePercentHur = chargeOnePercentPerFlowSpeed(i);
    
            if batteryEnergyRemaining <= 0 
                timePenaltyCharging = timeChargeOnePercentHur*100;
                timePen = vhclPosChangeTimePenalty + timePenaltyCharging+startKiteCost;
                 batteryEnergyRemaining = 1000;
            else 
                timePenaltyCharging = 0 ;
                timePen = vhclPosChangeTimePenalty;
            end
            
            batteryPercent = batteryEnergyRemaining;
           timePenMat = [timePenMat,timePen];
           
            
            
        
    
    
end

figure(33) 
plotpos=0;
plottime=0;
for i=1:length(timePenMat)
    plotpos(length(plotpos)+1) = plotpos(end) + (.001*posInt);
    plottime(length(plottime)+1) = plottime(end) + vhclPosChangeTimePenalty;
    if timePenMat(i) > (vhclPosChangeTimePenalty)
        plotpos(length(plotpos)+1) = plotpos(end);
        plottime(length(plottime)+1) = plottime(end) + (timePenMat(i)-vhclPosChangeTimePenalty);
    end
end
plottime=plottime/3600;
% plot( [0,cumsum(costBestPathMat)./3600],0:.001*posInt:2*.001*xq(end))
plot(plottime,plotpos)
title('Time vs. Position')
ylabel('Position(Km)')
xlabel('Time (Hrs)')




figure(7) 
plot(batMat./10) 













