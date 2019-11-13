

%% Set up environment
env = ENV.env;
env.gravAccel.setValue(9.81,'m/s^2')
env.addFlow({'water'},{'constX_YZvarT_ADCPMUGLIATurb'},'FlowDensities',1000)


env.water.setDepthMin(13,''); %minimum index, not meters
env.water.setDepthMax(60,'');  %maximum index, not meters
env.water = env.water.setStartADCPTime(3600*459,'s');
env.water =   env.water.setEndADCPTime(3600*461,'s');
env.water.yBreakPoints.setValue(-140:2:140,'m');

env.water.setTI(0.1,'');
env.water.setF_min(0.01,'Hz');
env.water.setF_max(1,'Hz');
env.water.setP(.1,'');
env.water.setQ(0.1,'Hz');
env.water.setC(6,'');
env.water.setN_mid_freq(5,'');

% figure(1)
% plot(squeeze(env.water.flowVecTSeries.Value.Data(1,:,:)))
% ylim([-.5 1])
% figure(2)
% plot(squeeze(env.water.flowVecTSeries.Value.Data(2,:,:)))
% ylim([-.5 1])
%    env.water.process
  env.water= env.water.buildTimeseries
environment_bc
FLOWCALCULATION = 'constX_YZvarT_CNAPSTurb';
saveBuildFile('env',mfilename,'variant','FLOWCALCULATION');