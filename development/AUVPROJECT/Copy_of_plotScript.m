%% LAST FIGURE
load('allvarsOCTSIM')
 fig1 = figure(1)
 %for the actual oct sim
 maxpos = max(plotpos);
plotpos(plotpos>(maxpos/2))=maxpos-plotpos(plotpos>(maxpos/2));

 h1 =plot(plottime,plotpos)
title('Time vs. Position of AUV with Tension-Based Kite')
ylabel('Position (Km)')
xlabel('Time (Hrs)')
grid on 
box off 
ax1 = gca;
ax1.FontSize = 12;
h1.LineWidth = 1.5;
h1.Color = [0, 0 ,0];
x0=10;
y0=10;
width=550;
height= 200
set(gcf,'position',[x0,y0,width,height])
savefig(fig1)
saveas(fig1,'OCTSim.png')
clear all;
%% MHK TIME FIGURES

load('allvarsMHK2')
fig2 = figure(2)

maxpos = max(plotpos1);
plotpos1(plotpos1>(maxpos/2))=maxpos-plotpos1(plotpos1>(maxpos/2));

maxpos1 = max(plotpos2);
plotpos2(plotpos2>(maxpos1/2))=maxpos1-plotpos2(plotpos2>(maxpos1/2));

h2 = plot(plottime1,plotpos1, '--')
hold on
h22 = plot(plottime2,plotpos2)
title('Time vs. Position of AUV with Tension-Based Kite')
ylabel('Position (Km)')
xlabel('Time (Hrs)')
legend('Baseline','Dynamic Programming')
ylim([0 260])
grid on 
box off 
ax2 = gca;
ax2.FontSize = 12;
h2.LineWidth = 1.5;
h2.Color = [0, 0 ,0];
h22.LineWidth = 1.5;
h22.Color = [0, 0 ,0];
x0=10;
y0=10;
width=550;
height= 200
set(gcf,'position',[x0,y0,width,height])

savefig(fig2)
saveas(fig2,'mhkPos.png')

%% MHK WINNING PATH PLOT


fig3 = figure(3);
h3 = plot(0:posInt*.001:.001*2*xq(end), winningPathFinal  ) 
title({'Battery Percentage vs. Position' ,'Dynamic Programming Solution'})
ylabel('Battery Percentage')
xlabel('Position Traveled (Km)')
xlim([0,2*.001*xq(end)])
grid on 
box off 
ax3 = gca;
ax3.FontSize = 12;
h3.LineWidth = 1.5
h3.Color = [0, 0 ,0]

y0=10;
width=550;
height= 200
set(gcf,'position',[x0,y0,width,height])
savefig(fig3)
saveas(fig3,'MHKDPBatLife.png')
clear all;

%% OCT TIME FIGURES

load('allvarsOCT')
fig4 = figure(4)

maxpos = max(plotpos1);
plotpos1(plotpos1>(maxpos/2))=maxpos-plotpos1(plotpos1>(maxpos/2));

maxpos1 = max(plotpos2);
plotpos2(plotpos2>(maxpos1/2))=maxpos1-plotpos2(plotpos2>(maxpos1/2));

h4 = plot(plottime1,plotpos1, '--')
hold on
h44 = plot(plottime2,plotpos2)
title('Time vs. Position of AUV with Turbine-Based Energy Gen.')
ylabel('Position (Km)')
xlabel('Time (Hrs)')
legend('Baseline','Dynamic Programming')
ylim([0 260])
grid on 
box off 
ax4 = gca;
ax4.FontSize = 12;
h4.LineWidth = 1.5;
h4.Color = [0, 0 ,0];
h44.LineWidth = 1.5;
h44.Color = [0, 0 ,0];
x0=10;
y0=10;
width=550;
height= 200;
set(gcf,'position',[x0,y0,width,height])

savefig(fig4)
saveas(fig4,'OCTPos.png')

%% OCT WINNING PATH PLOT


fig5 = figure(5);
h5 = plot(0:posInt*.001:.001*2*xq(end), winningPathFinal  ) 
title({'Battery Percentage vs. Position' ,'Dynamic Programming Solution'})
ylabel('Battery Percentage')
xlabel('Position (Km) Traveled')
xlim([0,2*.001*xq(end)])
grid on 
box off 
ax5 = gca;
ax5.FontSize = 12;
h5.LineWidth = 1.5
h5.Color = [0, 0 ,0]
x0=10;
y0=10;
width=550;
height= 200;
set(gcf,'position',[x0,y0,width,height])
savefig(fig5)
saveas(fig5,'OCTDPBatLife.png')

clear all;


