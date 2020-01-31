function [val,varargout] = calObjF(tscSim,tscExp,dataRange)

% load data
timeExp = tscExp.roll_rad.Time;
timeSim = tscSim.eulerAngles.Time;

% find indices in time corresponding to dataRange
startIdxSim = find((timeSim - dataRange(1)).^2 < 1e-6);
endIdxSim = find((timeSim - dataRange(2)).^2 < 1e-6);

startIdxExp = find((timeExp - dataRange(1)).^2 < 1e-6);
endIdxExp = find((timeExp - dataRange(2)).^2 < 1e-6);

if (endIdxSim-startIdxSim) ~= (endIdxExp-startIdxExp)
    error('Start and end index while computing objF dont match')
end

% extract simulation values
xPosSim = tscSim.positionVec.Data(1,startIdxSim:endIdxSim);
yPosSim = tscSim.positionVec.Data(2,startIdxSim:endIdxSim);
zPosSim = tscSim.positionVec.Data(3,startIdxSim:endIdxSim);

xVelSim = tscSim.velocityVec.Data(1,startIdxSim:endIdxSim);
yVelSim = tscSim.velocityVec.Data(2,startIdxSim:endIdxSim);
zVelSim = tscSim.velocityVec.Data(3,startIdxSim:endIdxSim);

rollSim = tscSim.eulerAngles.Data(1,startIdxSim:endIdxSim);
yawSim = tscSim.eulerAngles.Data(3,startIdxSim:endIdxSim);

% extract experiment values
xPosExp = tscExp.CoMPosVec_cm.Data(1,startIdxExp:endIdxExp);
yPosExp = tscExp.CoMPosVec_cm.Data(2,startIdxExp:endIdxExp);
zPosExp = tscExp.CoMPosVec_cm.Data(3,startIdxExp:endIdxExp);

xVelExp = tscExp.CoMVelVec_cm.Data(1,startIdxExp:endIdxExp);
yVelExp = tscExp.CoMVelVec_cm.Data(2,startIdxExp:endIdxExp);
zVelExp = tscExp.CoMVelVec_cm.Data(3,startIdxExp:endIdxExp);

rollExp = tscExp.roll_rad.Data(startIdxExp:endIdxExp);
yawExp = tscExp.yaw_rad.Data(startIdxExp:endIdxExp);

% val = calcRMSE(yPosSim,yPosExp)/max(abs(yPosExp));

% RMSEs
rollRMSE = 1.0*calcRMSE(rollSim,rollExp);
yawRMSE = 1.0*calcRMSE(yawSim,yawExp);
ycmRMSE = 1.0*calcRMSE(yPosSim,yPosExp);
zcmRMSE = 1.0*calcRMSE(zPosSim,zPosExp);
val =  rollRMSE + yawRMSE + ycmRMSE + zcmRMSE;

% varargout outputs
allRMSE.rollRMSE = rollRMSE;
allRMSE.yawRMSE = yawRMSE;
allRMSE.ycmRMSE = ycmRMSE;
allRMSE.zcmRMSE = zcmRMSE;
varargout{1} = allRMSE;

% validation functions
meanDiff.roll = mean(rollSim(:)-rollExp(:));
meanDiff.yaw = mean(yawSim(:)-yawExp(:));

meanDiff.xPos = mean(xPosSim(:)-xPosExp(:));
meanDiff.yPos = mean(yPosSim(:)-yPosExp(:));
meanDiff.zPos = mean(zPosSim(:)-zPosExp(:));

meanDiff.xVel = mean(xVelSim(:)-xVelExp(:));
meanDiff.yVel = mean(yVelSim(:)-yVelExp(:));
meanDiff.zVel = mean(zVelSim(:)-zVelExp(:));

varargout{2} = meanDiff;

end




