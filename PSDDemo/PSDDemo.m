% PSD demo Gnocchi block 529
%% Load in Data just looking at channel 4
load('exampleData.mat')
% Get rid of NaN from previous cleaning
data(isnan(data)) = [];

%% Fourier transform. Gives a real and imaginary number per frequency
figure; 
% Real and imag numbers come out of an fft. Only want the real numbers -do
% this using abs() as this gives you the magnitude. The imaginary part
% gives you the phase of each frequency - can get this using imag()
Y = abs(fft(data)); 
% Get the frequency points
x = (0:length(Y)-1)*fs/length(Y);

% Split in half as we don't want the negative frequencies
Y = Y(1:floor(numel(Y)/2));
x = x(1:floor(numel(x)/2));
plot(x,Y); title('FFT'); xlabel('Frequency (Hz)'); ylabel('Magnitude')

% Can see its pretty noisy and hard to make much sense of the data as it is
% a direct tranformation of the signal into frequency space

%% Pwelch (Welches power spectral density estimate)
% can be seen as a sort of smoothing of the spectrum and reduces noise (by
% sacrificing frequency resolution). Noise is caused by imperfect finite
% data.

% It takes a sliding window of X size and each slide it will overlap the
% previous window by 50% (you  can change this but don't really want to)

 % If the window is a multiple of 2 it makes it easier to compute
windowLength = 4;
nfft = 2^(nextpow2(fs*windowLength)); 

% What kind of window shape do you want to use? Here we typically using the
% hanning window
win  = hanning(nfft);

% Run the function
[pxx,fxx] = pwelch(data,win,[],nfft,fs); % [] means default for the overlap window (e.g. 50%)

% pxx is the magnitude and fxx is the frequency
figure;subplot(1,2,1)
plot(fxx,pxx); xlabel('Frequency (Hz)'); ylabel('Magnitude'); title('Pwelch')
xlim([0 100]); ylim([0 50])

% Can also plot magnitude in dB
subplot(1,2,2)
plot(fxx,10*log10(pxx)); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); title('Pwelch')
xlim([0 100]); ylim([0 50])


%% Different sliding windows
% The important parameter to change depending on the frequency resolution
% you need. 
windowLength = [1 4 15 100];
figure
for i = windowLength
    subplot(1,numel(windowLength),find(i==windowLength))
    nfft = 2^(nextpow2(fs*i)); % Use a 10 second window
    win  = hanning(nfft);
    [pxx,fxx] = pwelch(data,win,[],nfft,fs);
    plot(fxx,10*log10(pxx)); xlim([0 50]); title(['Window length: ',num2str(i),'s'])
    xlabel('Frequency (Hz)'); ylabel('Magnitude')
end

%% Finding frequencies of interest
% Good to compare across conditions etc.
nfft = 2^(nextpow2(fs*4)); 
win  = hanning(nfft);
[pxx,fxx] = pwelch(data,win,[],nfft,fs);

% Repeats of PL3
% Look at the harmonics of 6.6666Hz which is the repeat rate for a pattern
% length of 3
freqs = (1000/150)*[1:7];
y = [];
for f = freqs
    % Find index closest to frequency of interest
    [~,i]=min(abs(fxx-f));   
    y(end+1) = 10*log10(pxx(i));
end

figure;plot(fxx,10*log10(pxx)); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); hold on
scatter(freqs,y)
xlim([0 50])

%% Zero padding trials to get frequency resolution
% Can zero padd if you want a window size that is bigger than your sample
% data
tempData = data(1:fs*10);
windowLength = 4;
nfft = 2^(nextpow2(fs*windowLength)); 
win  = hanning(nfft);
[pxx,fxx] = pwelch(tempData,win,[],nfft,fs);
figure;plot(fxx,10*log10(pxx)); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); hold on
[pxx,fxx] = pwelch([tempData zeros(1,numel(tempData))],win,[],nfft,fs);
plot(fxx,10*log10(pxx));
xlim([0 50]); legend({'Original data','Zero padded data'});



%% Concatenating trials
% Want to be careful how you concatenate your trials as it can introduce
% harmonics into your PSD or other noise that would'n't be there otherwise.
% However can't seem to demonstrate it well with the below demo ...
concatLength = 10;
windowLength = 8;
% 4s window
% Get idx's
begIdx = floor([1:80]*(fs*concatLength));
endIdx = begIdx(2:end)-1;

order = randperm(numel(endIdx));
newData = [];
for i = 1:numel(order)
    newData = [newData data(begIdx(order(i)):endIdx(order(i)))+(((rand*2)-1)*200)];
end
figure;plot(newData); hold on
for i = 1:numel(order)
    xline(begIdx(i));
end


nfft = 2^(nextpow2(fs*windowLength)); 
win  = hanning(nfft);
[pxx,fxx] = pwelch(newData,win,[],nfft,fs);
figure;plot(fxx,10*log10(pxx)); hold on
[pxx,fxx] = pwelch(data(1:numel(newData)),win,[],nfft,fs);
plot(fxx,10*log10(pxx));
xlabel('Frequency (Hz)'); ylabel('Magnitude');  xlim([0 50]);
legend({'Concatenated data','Original data'})







