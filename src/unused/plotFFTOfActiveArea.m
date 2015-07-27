function plotFFTOfActiveArea(active_area, varargin)
%PLOTFFTOFACTIVEAREA Plot the Fast Fourier Transform of an active area
%      PLOTFFTOFACTIVEAREA(active_area) Plots the FFT of an active area which is
%      represented by a single column vector of activity readings. The variable
%      argument is the color to plot on the graph

% Default to using blue for the graph
line_color = 'b';
if nargin > 1
    line_color = varargin{1};
end

% Define some variables to use
sampling_frequency = 1;
sample_time = 1;
length_of_signal = length(active_area);

% Some the FFT
NFFT = 2^nextpow2(length_of_signal); % Next power of 2 from length of y
Y = fft(active_area,NFFT)/length_of_signal;
f = sampling_frequency/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.
plot(f,2*abs(Y(1:NFFT/2+1)), line_color);
title('Single-Sided Amplitude Spectrum of y(t)');
xlabel('Frequency (Hz)');
ylabel('|Y(f)|');
