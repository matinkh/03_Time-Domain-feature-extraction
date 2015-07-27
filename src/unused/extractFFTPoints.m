function FFT_data = extractFFTPoints(active_area)
%EXTRACTFFTPOINTS Find the peaks in a FFT of an active area
%      IDENTIFYACTIVEAREAS(active_area) Given the vector which is assumed to
%      be an active area this will find the FFT of it, and return the top 3
%      peaks. The peaks are found using a heuristic that anything with
%      two lower values on either side is a peak. The max 3 are then selected.

% Define some variables to use
sampling_frequency = 1;
sample_time = 1;
length_of_signal = length(active_area);

% Some the FFT
NFFT = 2^nextpow2(length_of_signal); % Next power of 2 from length of y
Y = fft(active_area,NFFT)/length_of_signal;
f = sampling_frequency/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.
FFT_values = 2*abs(Y(1:NFFT/2+1));

% Find all the peaks
% Could also add when we find a peak i+=2 since they wont be a peak
peaks = [];
for i = (1+2):numel(FFT_values)
    if FFT_values(i-2) < FFT_values(i) &...
       FFT_values(i-1) < FFT_values(i) &...
       FFT_values(i+2) < FFT_values(i) &...
       FFT_values(i+1) < FFT_values(i)
        peaks = [peaks; FFT_values(i)];
    end
end

% Find the max 3 peaks and return them
peaks = sort(peaks, 'descend');

FFT_data = [];
for i = 1:numel(peaks)
    % I only want the top 3
    if i > 3
        break
    end

    FFT_data = [FFT_data; peaks(i)];
end
