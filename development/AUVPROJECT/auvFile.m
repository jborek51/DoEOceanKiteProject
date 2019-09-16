
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
batteryMaxEnergy         = 3.6e+9 ; %joules %100 KHW

%start with full battery

vhclVelocity             = [5;0;0]; % m/s %velocity of the vehicle
vhclVelMag               = 5;%sqrt(sum(vhclVelocity.^2));

%possible Battery Life
possibleBatteryLife      = 0:100;

%time cost from charging at  flowspeeds at 100 different flow speeds
%TODO: Run OCTModel with a range of constant flow speeds
chargeOnePercentPerFlowSpeed             = 30./flowSpeeds;%randi(10,1,100);

% VEHICLE POSITION TO POSITION STAGE PENALTY (TIME)
vhclPosChangeTimePenalty = posInt/vhclVelMag ; %tau

% COST TO REAL IN AN OUT THE KITE 
startKiteCost = 300; %seconds

% Total matrix of indexes for the best previous at each current
totalIndexMat = [];

% Total matrix of smallest cost at each stage of the previous
initialStateCostPerStage = [];
%% final cost computation 

            terminalCost              = [];
            
  for j = 1:length(possibleBatteryLife)
      
            terminalBatteryRemaining  = 100 - possibleBatteryLife(j); 
            if terminalBatteryRemaining > 0
                timeToChargeToFull        = chargeOnePercentPerFlowSpeed(100)*terminalBatteryRemaining + startKiteCost;
            else
                timeToChargeToFull        = 0;
            end
            terminalCost              = [terminalCost,timeToChargeToFull]; 
            
  end 
%% for loop 
%                     current     previous
% 0          0             0        0 
% 0          0             0        0 
% 0          0             0        0 
% 0          0             0        0 
%     new Current  new previous





%stage before the last backwards to 
for i = numStages-1:-1:2 %TODO the final virtual stage might be counted as a full stage. %FINISHED: I don't think that it is 
    
            smallestCostMat          = []; % initializing the matrix that is updated per stage that holds the smallest costs per state of the CURRENT STAGE
            indexMat                 = []; % initializing the matrix that is updated per stage that holds the index of the state with the smallest costs in the PREVIOUS per state of the CURRENT STAGE
    %number of states in current stage
    for ii = length(possibleBatteryLife):-1:1
   
            
            
            vWind                    = flowSpeeds(i);  %velocity of wind at current stage
            stateBatteryLife         = possibleBatteryLife(ii); %possible battery lifes %states of the CURRENT STAGE
            
            
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
            timeChargeOnePercentCur  = chargeOnePercentPerFlowSpeed(i-1); %time to charge one percent at the current flowspeed 
            
            %if you cannot make it to next position, you have to stop and
            %charge until you can make it. Your battery in the next stage
            %is now zero starting out
            if batteryEnergyRemaining< 0   
                 timePenaltyCantMakeIt    = timeChargeOnePercentCur * (energySpentToMovePercent - batteryEnergyRemaining);
                 batteryEnergyRemaining   = 0;
                 totalAddedStageCost      = timePenaltyCantMakeIt + startKiteCost+10000000; %This should never be chosen
            else
                 totalAddedStageCost      = 0;
            end
            
            
            costToFinishMat          = [];
        
        % possible battery life = states
        for iii = length(possibleBatteryLife):-1:1  %Note: battery life must be in single digit percents 

            timeChargeOnePercentPrev = chargeOnePercentPerFlowSpeed(i); %time to charge one percent at the previous flowspeed
            timePenaltyCharging      = timeChargeOnePercentPrev*(possibleBatteryLife(iii)-batteryEnergyRemaining);

            %as you change stages, the cost to finish at each state combo is
            %carried back
            if ~isempty(initialStateCostPerStage)
                initialStateCost          = initialStateCostPerStage((length(possibleBatteryLife)+1)-iii,(numStages-1)-i); % grabbing the first element of the cost per state in the previous stage. This is how the costs travel backwards through each stage.
            else
                initialStateCost          = 0; %If you havent gone through any current to previous stage pairs yet, the initial state cost is the terminal cost     
            end
            
            
            
            if timePenaltyCharging   == 0 
                costToFinish             = totalAddedStageCost + vhclPosChangeTimePenalty + initialStateCost;  
            elseif timePenaltyCharging <0 
                costToFinish             = NaN;
            else
                costToFinish             = totalAddedStageCost + vhclPosChangeTimePenalty + timePenaltyCharging + startKiteCost + initialStateCost;
            end
            
            
            % if it is the first time running the loop, the
            % initialStateCostPerStage matrix ( the matrix which stores the
            % minimum cost per state of the CURRENT stage
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


%total index matrix to be flipped left right for index
%sorting

         flipMat =   fliplr(totalIndexMat);
               
         
%creating the paths that were taken
%     columns
eachPathMatr = {}; %initializing final path per element of last column matrix 

% for j = 1:length(possibleBatteryLife)
%     
%     pathMat   = [];
%     position1 = flipMat(j,1);
%     
%     %     rows
%     for p = 2: numStages-2
%     
%         if p ==2 
%     position2 = flipMat(position1,p);
%         else
%     position2 = flipMat(position2,p);        
%         end
%     
%     
%     %path mat is a matrix of indexs each elements of the last column took
%     %I flipped totalIndexMat LR so it is easier to think about.
%     pathMat   = [pathMat,position2];
%         
%     end
%     eachPathMatr{j} = [position1,pathMat];
% end

for j = 1:length(possibleBatteryLife)
    
    pathMat   = [];
    position1 =  totalIndexMat(j,1);
    
    %     rows
    for p = 2: numStages-2
    
        if p ==2 
    position2 = flipMat(position1,p);
        else
    position2 = flipMat(position2,p);        
        end
    
    
    %path mat is a matrix of indexs each elements of the last column took
    %I flipped totalIndexMat LR so it is easier to think about.
    pathMat   = [pathMat,position2];
        
    end
    eachPathMatr{j} = [position1,pathMat];
end


%the results of each pathMatr show the paths that were taken starting from
%the the stage ( 1 before end ) to the stage 2. This is kind of confusing
%to look at because the indices look like they should be battery like but
%they are really 101-index equals battery life.  

% So, I am reformating to show the steps in battery life
%
for i = 1:length(eachPathMatr)
   batteryLifeSteps{i} = 101- eachPathMatr{i};
end

figure(1)
for i = 1:length(eachPathMatr)
plot(batteryLifeSteps{i})
hold on 
end
hold off
figure(2);plot(chargeOnePercentPerFlowSpeed)   
title('Inversion of Max Flow Profile')
ylabel('Example Time To Charge One Battery Increment (s)')
xlabel('Transect position Increment')


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
            timeChargeOnePercentInit = chargeOnePercentPerFlowSpeed(2);
            initCostToFinishMat      = [];
for iii = length(possibleBatteryLife):-1:1

            timePenaltyCharging      = timeChargeOnePercentInit*(possibleBatteryLife(iii)-batteryEnergyRemaining);
            initialStateCost         = initialStateCostPerStage((length(possibleBatteryLife)+1)-iii,end);
            if timePenaltyCharging   == 0 
                initCostToFinish         =  vhclPosChangeTimePenalty + initialStateCost;  
            elseif timePenaltyCharging <0 
                initCostToFinish         = NaN;
            else
                initCostToFinish         = vhclPosChangeTimePenalty + timePenaltyCharging + startKiteCost + initialStateCost ;
            end
            
            initCostToFinishMat       =[initCostToFinishMat,initCostToFinish];
           [smallestCostInit,indexInit]      = min(initCostToFinishMat);
end
    [smallestCostInit,indexInit]      = min(initCostToFinishMat);
    
    
%% tracing back out the paths from the indices

% winning path plot =



            
            
            






















