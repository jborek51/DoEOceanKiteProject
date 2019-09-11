% %Get the most updated versions of the "origin" branches. This is what has
% %been pushed
% !git fetch
% 
% %Rebuild your unpushed commits as though you had started working with the
% %most updated version.  This is basically in place of a git merge.  You can
% %still end up with conflicts if you changed a file that was changed since
% %the commit you actually build off.
% !git rebase origin/master

%% if you are getting commit issues and want to rebase anyway use
% !git checkout origin/master -f
% !git rebase --continue
tempFilename = 'temp.txt';
!git fetch
% eval(sprintf("!git rev-parse --abbrev-ref HEAD > %s",tempFilename));
% pause(1)
% FID=fopen(tempFilename,'r');
% branch = fscanf(FID,'%s');
% fclose(FID);
% delete(tempFilename)
% eval(sprintf("!git rebase origin/%s",branch))
!FOR /F "tokens=* USEBACKQ" %F IN (`git rev-parse --abbrev-ref HEAD`) DO (git rebase origin/%F)