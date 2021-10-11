% PSD demo Gnocchi block 529
%% Load in Data just looking at channel 4
load('LFP_F2001_Gnocchi_BlockWE-529.mat')
data = data(4,:);
save('exampleData.mat','bHvData','data','dataInfo','fs')

%% Fourier transform


%% Pwelch
% If the window is a multiple of 2 it makes it easier to compute
for i = 1:64
    figure;

inData = data(4,:);
% Get rid of NaNs 
inData(isnan(inData)) = [];
nfft = 2^(nextpow2(fs*10)); % Use a 10 second window
win  = hanning(nfft);
[pxx,fxx] = pwelch(inData,win,[],nfft,fs);
plot(fxx,pxx); xlim([0 25])
end



% freqs of interest
[~,i]=min(abs(fxx-50));

%% Concatenating trials