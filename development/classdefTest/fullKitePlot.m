


%% animations plots
resampleDataRate = 2;
time = 0:resampleDataRate:tsc.(signals{1}).Time(end);

tscResample.positionVec = resample(tsc.positionVec,time);
tscResample.velocityVec = resample(tsc.velocityVec,time);
tscResample.eulerAngles = resample(tsc.eulerAngles,time);
tscResample.angularVel = resample(tsc.angularVel,time);



nNodes = thr.numNodes.Value;
nTethers = thr.numTethers.Value;
n_steps = length(time);

sol_Rcm_o = squeeze(tscResample.positionVec.Data);
sol_Vcmo = squeeze(tscResample.velocityVec.Data);
sol_euler = squeeze(tscResample.eulerAngles.Data);
sol_OwB = squeeze(tscResample.angularVel.Data);


s_R = cell(nTethers,1);
s_Rn_o = cell(nTethers,1);
s_R1_o = cell(nTethers,1);
sol_outline = cell(5,1);

for ii = 1:nTethers
    intVar = resample(tsc.thrNodeBus(ii).nodePositions,time);
    s_R{ii} = intVar.Data;
    s_R1_o{ii} = s_R{ii}(:,1,:);
    s_Rn_o{ii} = s_R{ii}(:,end,:);
    
end

surfNames = fieldnames(vhcl.surfaceOutlines);

rotSeq = NaN(3,3,n_steps);
Ri_cm = NaN(5,3,n_steps);

for ii = 1:n_steps
    rotSeq(:,:,ii) = rotation_sequence(sol_euler(:,ii));
end
for jj = 1:5
    for ii = 1:n_steps
        for kk = 1:5
            Ri_cm(kk,:,ii) = (sol_Rcm_o(:,ii) + rotSeq(:,:,ii)*vhcl.surfaceOutlines.(surfNames{jj}).Value(:,kk) )';
        end
    end
    sol_outline{jj} = Ri_cm;
    
end

bx = zeros(nTethers,2);
by = zeros(nTethers,2);
bz = zeros(nTethers,2);

for ii = 1:nTethers
    [xmin,xmax] = bounds(squeeze(s_R{ii}(1,:,:)),'all');
    [ymin,ymax] = bounds(squeeze(s_R{ii}(2,:,:)),'all');
    [zmin,zmax] = bounds(squeeze(s_R{ii}(3,:,:)),'all');
    
    bx(ii,:) = round([floor(xmin-5),ceil(xmax+5)],-1);
    by(ii,:) = round([floor(ymin-5),ceil(ymax+5)],-1);
    bz(ii,:) = round([floor(zmin-5),ceil(zmax+5)],-1);
end

%% plot
fn = fn+1;
figure(fn)
set(gcf,'Position',[200 100 2*560 2*420])

% % % video setting
video = VideoWriter('vid_Test', 'Motion JPEG AVI');
video.FrameRate = 20*1/resampleDataRate;

mov(1:n_steps)=struct('cdata',[],'colormap',[]);
set(gca,'nextplot','replacechildren');

for ii = 1:n_steps
    
    if ii > 1
        h = findall(gca,'type','line','color',red,'-or','color',black);
        delete(h);
    end
    
    for kk = 1:nTethers
        p3d_1 = plot3(s_R{kk}(1,:,ii),s_R{kk}(2,:,ii),s_R{kk}(3,:,ii),...
            '-+','linewidth',line_wd,'color',black);
        hold on
        pRcm_n = plot3([s_R{kk}(1,end,ii) sol_Rcm_o(1,ii)],...
            [s_R{kk}(2,end,ii) sol_Rcm_o(2,ii)],...
            [s_R{kk}(3,end,ii) sol_Rcm_o(3,ii)],...
            '-','linewidth',line_wd,'color',red);
        for jj = 1:5
            p_kite = plot3(sol_outline{jj}(:,1,ii),...
                sol_outline{jj}(:,2,ii),...
                sol_outline{jj}(:,3,ii),...
                '-','linewidth',line_wd,'color',red);
            p_fuse = plot3([sol_outline{1}(1,1,ii); sol_outline{end}(1,1,ii)],...
                [sol_outline{1}(1,2,ii); sol_outline{end}(1,2,ii)],...
                [sol_outline{1}(1,3,ii); sol_outline{end}(1,3,ii)],...
                '-','linewidth',line_wd,'color',red);
            
        end
    end
    
    if ii == 1
        xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)')
        xlim([-max(abs(bx(:)))-10 max(abs(bx(:)))+10]);
        ylim([-max(abs(by(:))) max(abs(by(:)))]);
        zlim([0 max(bz(:))]);
%         axis equal
        hold on
        grid on
    end
    
    title(['Time = ',sprintf('%0.2f', time(ii)),' s'])
    
    try
%         waitforbuttonpress
    catch
        break
    end
    F(ii) = getframe(gcf);

end


% if make_video == 1
%     open(video)
%     for i = 1:length(F)
%         writeVideo(video, F(i));
%     end
%     close(video)
% end

