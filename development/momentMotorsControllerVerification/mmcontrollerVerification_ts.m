% Test script to test modularized modle
close all;clear;clc
format compact

% Initialize the highest level model
OCTModel_init

% Initialize all of ayaz's parameters
ayazPlant_init

% Create the bus objects in the workspace
createAyazPlantBus
createAyazFlowEnvironmentBus
createaAyazCtrlBus

% Set simulation duration
duration_s = 1000;

% Set active variants
ENVIRONMENT = 'ayazFlow';
CONTROLLER  = 'ayazController';
PLANT       = 'ayazPlant';

% Setup setpoint timeseries
time = 0:0.1:duration_s;
set_pitch = set_pitch*ones(size(time));
set_roll = 20*(pi/180)*sign(sin(2*pi*time./200));
set_roll(time<200) = 0;
set_alt = set_alti*ones(size(time));

set_pitch = timeseries(set_pitch,time);
set_roll  = timeseries(set_roll, time);
set_alt   = timeseries(set_alt,time);
%%
try
    sim('origionalPlant_th')
catch
end
tscAyaz = parseLogsout;

try
    sim('controllerVerification_th')
catch
end
tscMod = parseLogsout;

tsc = parseLogsout;
clearvars logsout

%%
close all
figure
subplot(3,1,1)
plot(tscAyaz.posVec.Time,tscAyaz.posVec.Data(:,1),'LineWidth',2)
hold on
try
    plot(tscMod.posVec.Time,squeeze(tscMod.posVec.Data(1,:,:)),'LineWidth',2,'LineStyle','--')
catch
    plot(tscMod.posVec.Time,tscMod.posVec.Data(:,1),'LineWidth',2,'LineStyle','--')
end
xlabel('Time [s]')
ylabel('x pos [m]')

subplot(3,1,2)
plot(tscAyaz.posVec.Time,tscAyaz.posVec.Data(:,2),'LineWidth',2)
hold on
try
    plot(tscMod.posVec.Time,squeeze(tscMod.posVec.Data(2,:,:)),'LineWidth',2,'LineStyle','--')
catch
    plot(tscMod.posVec.Time,tscMod.posVec.Data(:,2),'LineWidth',2,'LineStyle','--')
end
xlabel('Time [s]')
ylabel('y pos [m]')

subplot(3,1,3)
plot(tscAyaz.posVec.Time,tscAyaz.posVec.Data(:,3),'LineWidth',2)
hold on
try
    plot(tscMod.posVec.Time,squeeze(tscMod.posVec.Data(3,:,:)),'LineWidth',2,'LineStyle','--')
catch
    plot(tscMod.posVec.Time,tscMod.posVec.Data(:,3),'LineWidth',2,'LineStyle','--')
end
xlabel('Time [s]')
ylabel('z pos [m]')

set(findall(gcf,'Type','axes'),'FontSize',24)

figure
subplot(3,1,1)
plot(tscAyaz.velocityVec.Time,tscAyaz.velocityVec.Data(:,1),'LineWidth',2)
hold on
try
    plot(tscMod.velocityVec.Time,squeeze(tscMod.velocityVec.Data(1,:,:)),'LineWidth',2,'LineStyle','--')
catch
    plot(tscMod.velocityVec.Time,tscMod.velocityVec.Data(:,1),'LineWidth',2,'LineStyle','--')
end
xlabel('Time [s]')
ylabel('x vel [m]')

subplot(3,1,2)
plot(tscAyaz.velocityVec.Time,tscAyaz.velocityVec.Data(:,2),'LineWidth',2)
hold on
try
    plot(tscMod.velocityVec.Time,squeeze(tscMod.velocityVec.Data(2,:,:)),'LineWidth',2,'LineStyle','--')
catch
    plot(tscMod.velocityVec.Time,tscMod.velocityVec.Data(:,2),'LineWidth',2,'LineStyle','--')
end
xlabel('Time [s]')
ylabel('y vel [m]')

subplot(3,1,3)
plot(tscAyaz.velocityVec.Time,tscAyaz.velocityVec.Data(:,3),'LineWidth',2)
hold on
try
    plot(tscMod.velocityVec.Time,squeeze(tscMod.velocityVec.Data(3,:,:)),'LineWidth',2,'LineStyle','--')
catch
    plot(tscMod.velocityVec.Time,tscMod.velocityVec.Data(:,3),'LineWidth',2,'LineStyle','--')
end
xlabel('Time [s]')
ylabel('z vel [m]')

set(findall(gcf,'Type','axes'),'FontSize',24)

figure
subplot(3,1,1)
plot(tscAyaz.eulerAngles.Time,tscAyaz.eulerAngles.Data(:,1)*180/pi,'LineWidth',2)
hold on
try
    plot(tscMod.eulerAngles.Time,squeeze(tscMod.eulerAngles.Data(1,:,:))*180/pi,'LineWidth',2,'LineStyle','--')
catch
    plot(tscMod.eulerAngles.Time,tscMod.eulerAngles.Data(:,1)*180/pi,'LineWidth',2,'LineStyle','--')
end
xlabel('Time [s]')
ylabel('Roll [deg]')

subplot(3,1,2)
plot(tscAyaz.eulerAngles.Time,tscAyaz.eulerAngles.Data(:,2)*180/pi,'LineWidth',2)
hold on
try
    plot(tscMod.eulerAngles.Time,squeeze(tscMod.eulerAngles.Data(2,:,:))*180/pi,'LineWidth',2,'LineStyle','--')
catch
    plot(tscMod.eulerAngles.Time,tscMod.eulerAngles.Data(:,2)*180/pi,'LineWidth',2,'LineStyle','--')
end
xlabel('Time [s]')
ylabel('Pitch [deg]')

subplot(3,1,3)
plot(tscAyaz.eulerAngles.Time,tscAyaz.eulerAngles.Data(:,3)*180/pi,'LineWidth',2)
hold on
try
    plot(tscMod.eulerAngles.Time,squeeze(tscMod.eulerAngles.Data(3,:,:))*180/pi,'LineWidth',2,'LineStyle','--')
catch
    plot(tscMod.eulerAngles.Time,tscMod.eulerAngles.Data(:,3)*180/pi,'LineWidth',2,'LineStyle','--')
end
xlabel('Time [s]')
ylabel('Yaw [deg]')

set(findall(gcf,'Type','axes'),'FontSize',24)

%% Plot tether tensions
figure
plot(tscMod.thr1AirTenVec.Time,squeeze(tscMod.thr1AirTenVec.Data(3,1,:)))
hold on
grid on
plot(tscMod.thr3AirTenVec.Time,squeeze(tscMod.thr3AirTenVec.Data(3,1,:)))


%% Plot body frame moments from tethers
figure
subplot(3,1,1)
plot(tscAyaz.B_Tt1.Time,tscAyaz.B_Tt1.Data(:,1))
grid on
hold on
plot(tscMod.B_Tt1_Mod.Time,tscMod.B_Tt1_Mod.Data(:,1))
xlabel('Time, [s]')
ylabel('X Comp.')
title('Tether 1')

subplot(3,1,2)
plot(tscAyaz.B_Tt1.Time,tscAyaz.B_Tt1.Data(:,2))
grid on
hold on
plot(tscMod.B_Tt1_Mod.Time,tscMod.B_Tt1_Mod.Data(:,2))
xlabel('Time, [s]')
ylabel('Y Comp.')

subplot(3,1,3)
plot(tscAyaz.B_Tt1.Time,tscAyaz.B_Tt1.Data(:,3))
grid on
hold on
plot(tscMod.B_Tt1_Mod.Time,tscMod.B_Tt1_Mod.Data(:,3))
xlabel('Time, [s]')
ylabel('Z Comp.')

set(findall(gcf,'Type','axes'),'FontSize',24)
linkaxes(findall(gcf,'Type','axes'),'x')

figure
subplot(3,1,1)
plot(tscAyaz.B_Tt3.Time,tscAyaz.B_Tt3.Data(:,1))
grid on
hold on
plot(tscMod.B_Tt3_Mod.Time,tscMod.B_Tt3_Mod.Data(:,1))
xlabel('Time, [s]')
ylabel('X Comp.')
title('Tether 3')

subplot(3,1,2)
plot(tscAyaz.B_Tt3.Time,tscAyaz.B_Tt3.Data(:,2))
grid on
hold on
plot(tscMod.B_Tt3_Mod.Time,tscMod.B_Tt3_Mod.Data(:,2))
xlabel('Time, [s]')
ylabel('Y Comp.')

subplot(3,1,3)
plot(tscAyaz.B_Tt3.Time,tscAyaz.B_Tt3.Data(:,3))
grid on
hold on
plot(tscMod.B_Tt3_Mod.Time,tscMod.B_Tt3_Mod.Data(:,3))
xlabel('Time, [s]')
ylabel('Z Comp.')


set(findall(gcf,'Type','axes'),'FontSize',24)
linkaxes(findall(gcf,'Type','axes'),'x')


%
% subplot(3,1,2)
% plot(tscAyaz.B_Tt1.Time,tscAyaz.B_Tt1.Data(:,2))
% grid on
% hold on
% plot(tscAyaz.B_Tt2.Time,tscAyaz.B_Tt2.Data(:,2))
% plot(tscAyaz.B_Tt3.Time,tscAyaz.B_Tt3.Data(:,2))
% xlabel('Time, [s]')
% ylabel('Y Comp.')
%
% subplot(3,1,3)
% plot(tscAyaz.B_Tt1.Time,tscAyaz.B_Tt1.Data(:,3))
% grid on
% hold on
% plot(tscAyaz.B_Tt2.Time,tscAyaz.B_Tt2.Data(:,3))
% plot(tscAyaz.B_Tt3.Time,tscAyaz.B_Tt3.Data(:,3))
% xlabel('Time, [s]')
% ylabel('Z Comp.')




%% Animate the simulation
animateSim