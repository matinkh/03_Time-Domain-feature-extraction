function plot5FFTs(active_areas, start_index, axis_data)
%PLOT5FFTS Plot the Fast Fourier Transform of 5 successive active areas
%      PLOTACTIVEAREA(active_area) Plots the FFTs on the same figure for easy
%      comparison. Perhaps results in a graph that is a bit too busy to read.


% Define some variables to use
sampling_frequency = 1;
sample_time = 1;
plot_colors = {'k','b','r','g','m'};

fig = figure('Name', 'Fast Fourier Transform of Active Regions');
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
legend_labels = [];

hold on;

for i = start_index:start_index+4
    active_region = axis_data(active_areas(i,1):active_areas(i,2));
    length_of_signal = length(active_region);

    % Some the FFT
    NFFT = 2^nextpow2(length_of_signal); % Next power of 2 from length of y
    Y = fft(active_region,NFFT)/length_of_signal;
    f = sampling_frequency/2*linspace(0,1,NFFT/2+1);

    % Plot single-sided amplitude spectrum.
    % disp(2*abs(Y(1:NFFT/2+1)));
    plot(f,2*abs(Y(1:NFFT/2+1)), plot_colors{i-start_index+1});
    legend_labels = [legend_labels; strcat('Active Area ', {num2str(i)})];
end

legend(legend_labels);
