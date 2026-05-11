function [EEG] = interpolatePPP(EEG)

% Finds channels over a certain threshold and interpolates them
foundBadChans = (EEG.chanlocs);
[EEG] = pop_rejchan(EEG, 'elec',[1:128] ,'threshold',5,'norm','on','measure','kurt');
[EEG] = pop_interp(EEG,foundBadChans,'Spherical');
    
end