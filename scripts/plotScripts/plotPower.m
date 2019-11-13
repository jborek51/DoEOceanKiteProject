figure; 
plot(tsc.vhclFlowVecs.time, tsc.winchPower.data)
title('Power vs. Time ' ) 
xlabel('Time (s) ' ) 
ylabel('Power (Watts)')
timevec=tsc.winchPower.Time;
xlim([0,timevec(end)])

 [~,i1]=min(abs(timevec - 200));
 [~,i2]=min(abs(timevec -400)); %(timevec(end)/2)));
 [~,poweri1]=min(tsc.winchPower.Data(i1:i2));
 poweri1 = poweri1 + i1;
[~,i3]=min(abs(timevec - 600));
[~,i4]=min(abs(timevec - timevec(end)));
i4=i4-1;
[~,poweri2]=min(tsc.winchPower.Data(i3:i4));
poweri2 = poweri2 + i3;
% Manual Override. Rerun with this to choose times
%           t1 = input("time for first measurement");
%             [~,poweri1]=min(abs(timevec - t1));
%             t2 = input("time for second measurement");
%             [~,poweri2]=min(abs(timevec - t2));
hold on
ylims=ylim;
plot([timevec(poweri1) timevec(poweri1)], [-1e6 1e6],'r--')
plot([timevec(poweri2) timevec(poweri2)], [-1e6 1e6],'r--')
ylim(ylims);

avgPowerMag =[ mean( diff(tsc.winchPower.time)); diff(tsc.winchPower.time(poweri1:poweri2))] .* tsc.winchPower.data(poweri1:poweri2);

rPAvg = sum(avgPowerMag)/(tsc.winchPower.time(poweri2)- tsc.vhclFlowVecs.time(poweri1))

title(sprintf('Power vs Time; Average Power between lines = %4.2f Watts',rPAvg ));