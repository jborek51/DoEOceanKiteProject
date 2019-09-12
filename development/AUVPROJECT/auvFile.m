clc; 
clear all; 

transectData

%% Constants
%number of stages 
numStages                = length(vq);
flowSpeeds               = vq; 

%xdistance between each stage
posInt                   = xq(end)/length(vq);

%fluid density
densityOfFluid           = 1000; %kg/m^3

%refarea
aRef                     = 10; %m^2

%maximum battery energy capacity 
batteryMaxEnergy         = 3.6e+8 ; %joules %100 KHW

%propulsion Power of a 10 hp motor
propulsionPower          = 7.457; %kw

% %vCurrent
% vWind                    = [-1;0;0];

%start with full battery

vhclVelocity             = [5;0;0]; % m/s %velocity of the vehicle
vhclVelMag               = 5;%sqrt(sum(vhclVelocity.^2));

%possible Battery Life
possibleBatteryLife      = 0:100;

%time cost from charging at  flowspeeds at 100 different flow speeds
%TODO: Run OCTModel with a range of constant flow speeds
flowTimeCost             = randi(10,1,100);

% VEHICLE POSITION TO POSITION STAGE PENALTY (TIME)
vhclPosChangeTimePenalty = posInt/vhclVelMag ; %tau

% COST TO REAL IN AN OUT THE KITE 
startKiteCost = 1000; %seconds

% Total matrix of indexes for the best previous at each current
totalIndexMat = [];

% Total matrix of smallest cost at each stage of the previous
initialStateCostPerStage = [];
%% final cost computation 

            terminalCost              = [];
            
  for j = 1:length(possibleBatteryLife)
      
            terminalBatteryRemaining  = 100 - possibleBatteryLife(j); 
            if terminalBatteryRemaining > 0
                timeToChargeToFull        = flowTimeCost(100)*terminalBatteryRemaining + startKiteCost;
            else
                timeToChargeToFull        = 0;
            end
            terminalCost              = [terminalCost,timeToChargeToFull]; 
            
  end 
%% for loop 

%stage before the last backwards to 
for i = numStages-1:-1:2 %TODO the final virtual stage might be counted as a full stage
    
            smallestCostMat          = [];
            indexMat                 = [];
    %number of states in current stage
    for ii = length(possibleBatteryLife):-1:1
   
            
            %velocity of wind at current stage
            %possible battery lifes 
            vWind                    = flowSpeeds(i);
            stateBatteryLife         = possibleBatteryLife(ii); 
            
            
%%%%%%%%%%%%%%%%% DRAG DYNAMICS
            Cd                       = 1; 
            vApp                     = vWind - vhclVelocity;
            vAppMag                  = sqrt(sum(vApp.^2));
            dragForce                = .5.*densityOfFluid.*vAppMag.^2 .*aRef.*Cd;

%%%%%%%%%%%%%%%%%INCREASE IN CHARGE COST 
            
            dragEnergy               = dragForce * posInt; 
            propulsionEnergy         = dragEnergy; %maxPropusionEnergy = propulsionPower * vhclPosChangeTimePenalty ;  
            energySpentToMovePercent = ceil(100*propulsionEnergy/batteryMaxEnergy);
            batteryEnergyRemaining   = stateBatteryLife - energySpentToMovePercent;
            timeChargeOnePercentCur  = flowTimeCost(i-1);
            
            %if you cannot make it to next position, you have to stop and
            %charge until you can make it. Your battery in the next stage
            %is now zero starting out
            if batteryEnergyRemaining< 0   
                 timePenaltyCantMakeIt    = timeChargeOnePercentCur * (energySpentToMovePercent - batteryEnergyRemaining);
                 batteryEnergyRemaining   = 0;
                 totalAddedStageCost      = timePenaltyCantMakeIt + startKiteCost; %This should never be chosen
            else
                 totalAddedStageCost      = 0;
            end
            
            
            costToFinishMat          = [];
        
        % possible battery life = states
        for iii = length(possibleBatteryLife):-1:1  %Note: battery life must be in single digit percents 

            timeChargeOnePercentPrev = flowTimeCost(i); 
            timePenaltyCharging      = timeChargeOnePercentPrev*(possibleBatteryLife(iii)-batteryEnergyRemaining);

            %as you change stages, the cost to finish at each state combo is
            %carried back
            if ~isempty(initialStateCostPerStage)
                initialStateCost          = initialStateCostPerStage((length(possibleBatteryLife)+1)-iii,(numStages-1)-i);
            else
                initialStateCost          = 0;     
            end
            
            
            
            if timePenaltyCharging   == 0 
                costToFinish             = totalAddedStageCost + vhclPosChangeTimePenalty + initialStateCost;  
            elseif timePenaltyCharging <0 
                costToFinish             = NaN;
            else
                costToFinish             = totalAddedStageCost + vhclPosChangeTimePenalty + timePenaltyCharging + startKiteCost + initialStateCost;
            end
            
            
            
            if i == numStages-1
                costToFinish = costToFinish + terminalCost(length(possibleBatteryLife)-possibleBatteryLife(iii));
            end
            
            costToFinishMat          =[costToFinishMat,costToFinish];
        end
        
           [smallestCost,index]      = min(costToFinishMat);
           
            %matrix of smallest costs for each state of current stage
            smallestCostMat          =[smallestCostMat; smallestCost];
            
            %matrix of indices of smallest costs for each state of current stage
            indexMat                 =[indexMat;index]; 
            

    end   
            %matrix of smallest costs for each state for all stages
            initialStateCostPerStage =[initialStateCostPerStage,smallestCostMat];
            %matrix of indices of smallest costs for each state of all
            %stages
            totalIndexMat            =[totalIndexMat, indexMat];
        
    
end


%total index matrix has to be flipped up down and left right for index
%sorting

         flip1 =   fliplr(totalIndexMat);
         flip2 =   flipud(totalIndexMat);
         
         
%     columns
for j = 1:numStates-2 length(possibleBatteryLife)
    
%     rows
    for p = 1: length(possibleBatteryLife)
    position1 = flip2(j,p)
    position2 = flip2(position2,
    end
end

%% cost for initial position to finish

            vWind                    = flowSpeeds(1);
            stateBatteryLife         = possibleBatteryLife(end); 
            
%%%%%%%%%%%%%%%%% INITIAL DRAG DYNAMICS
            Cd                       = 1; 
            vApp                     = vWind - vhclVelocity;
            vAppMag                  = sqrt(sum(vApp.^2));
            dragForce                = .5.*densityOfFluid.*vAppMag.^2 .*aRef.*Cd;       
            dragEnergy               = dragForce * posInt; 
            propulsionEnergy         = dragEnergy; %maxPropusionEnergy = propulsionPower * vhclPosChangeTimePenalty ;  
            energySpentToMovePercent = ceil(100*propulsionEnergy/batteryMaxEnergy);
            batteryEnergyRemaining   = stateBatteryLife - energySpentToMovePercent;  
            timeChargeOnePercentInit = flowTimeCost(2);
            initCostToFinishMat      = [];
for iii = length(possibleBatteryLife):-1:1

            timePenaltyCharging      = timeChargeOnePercentInit*(possibleBatteryLife(iii)-batteryEnergyRemaining);
            initialStateCost         = initialStateCostPerStage((length(possibleBatteryLife)+1)-iii,end);
            if timePenaltyCharging   == 0 
                initCostToFinish         =  vhclPosChangeTimePenalty;  
            elseif timePenaltyCharging <0 
                initCostToFinish         = NaN;
            else
                initCostToFinish         = vhclPosChangeTimePenalty + timePenaltyCharging + startKiteCost ;
            end
            
            initCostToFinishMat       =[initCostToFinishMat,costToFinish];
           [smallestCostInit,indexInit]      = min(initCostToFinishMat);
end
    [smallestCostInit,indexInit]      = min(initCostToFinishMat);
    
    
%% tracing back out the paths from the indices



            
            
            






















