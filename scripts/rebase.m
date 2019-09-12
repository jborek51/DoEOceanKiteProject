%Get the most updated versions of the "origin" branches. This is what has
%been pushed by others
!git fetch

%Rebuild your unpushed commits as though you had started working with the
%most updated version.
!FOR /F "tokens=* USEBACKQ" %F IN (`git rev-parse --abbrev-ref HEAD`) DO (git rebase origin/%F)

%IMPORTANT NOTE:  All this does is act as though your local changes were
%built upon the most recent version.  Before pushing, you should check if
%the updates to the global repo broke your code.  Just like you would do if
%you pulled right before you pushed.

%Less important Note: This was designed to only work if you are on a local
%tracking branch and updating to the current state of the global repo.  
%Use merge if you are bringing a branch back into the master.

