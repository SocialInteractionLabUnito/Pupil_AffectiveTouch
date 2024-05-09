% Plots pupil timecourses and extract average in first 4 seconds

clc
clearvars
close all

% Add paths and load table
addpath(fullfile(pwd, 'myFunctions'))
load(fullfile(pwd,'Pupil_Traces.mat'), 'data');

% Sampling rate
SR = 1000;

% Timing
baseline_start = 1;   % when baseline starts (secs after beginning)
baseline_end = 2;     % when baseline ends (secs after beginning)


% Extract Pupil Means
baseline_start_idx = baseline_start*SR;
baseline_end_idx = baseline_end*SR;

subjs = unique(data.Subj);

allpupils_dynamic_real = [];
allpupils_dynamic_wood = [];
allpupils_static_real = [];
allpupils_static_wood = [];

for s = 1:numel(subjs) % for each subject
    currs = data(data.Subj==subjs(s), :);
    subj_conditions = strcat(currs.Type, "_", currs.Hand);

    % Process pupil and get signals
    %--------------------
    % Get signals
    currpupil = cat(1,currs.Pupil{:});
    currbaseline = currpupil( :,  baseline_start_idx : baseline_end_idx);
    currbaseline_mean = mean(currbaseline,2);
    
    % Subtract baseline
    pupil_corrected = currpupil - currbaseline_mean;

    % Standardize
    pupil_standardized = zscore(pupil_corrected, 1, 'all');

    % Assign
    allpupils_dynamic_real = [allpupils_dynamic_real;  pupil_standardized(contains(subj_conditions, 'dynamic_real'), :) ];
    allpupils_dynamic_wood = [allpupils_dynamic_wood;  pupil_standardized(contains(subj_conditions, 'dynamic_wood'), :) ];
    allpupils_static_real = [allpupils_static_real;  pupil_standardized(contains(subj_conditions, 'static_real'), :) ];
    allpupils_static_wood = [allpupils_static_wood;  pupil_standardized(contains(subj_conditions, 'static_wood'), :) ];

end





%--------------------------------------------------
%               Plot
%--------------------------------------------------

% Get vectors
tx = linspace(-2, 10, size(allpupils_dynamic_real,2));

m_dyn_r = mean(allpupils_dynamic_real);
m_stat_r = mean(allpupils_static_real);
m_dyn_w = mean(allpupils_dynamic_wood);
m_stat_w = mean(allpupils_static_wood);

s_dyn_r = sterr(allpupils_dynamic_real);
s_stat_r = sterr(allpupils_static_real);
s_dyn_w = sterr(allpupils_dynamic_wood);
s_stat_w = sterr(allpupils_static_wood);


% Dynamic: Real vs Wood
%_______________________
% Plot
figure
subplot(211)
plot_shaded_errorbars(tx, m_dyn_r, s_dyn_r, 'b')
hold on
plot_shaded_errorbars(tx, m_dyn_w, s_dyn_w, 'r')
xline(0, '-', 'Touch start')
legend({'Human', '', 'Artificial', ''})
legend AutoUpdate off
title('Dynamic Touch')
hold off
ylim([-1.2 0.9])
xlabel('Time (s)')
ylabel('Pupil size (z)')



% Static: Real vs Wood
%_______________________
% Plot
subplot(212)
plot_shaded_errorbars(tx, m_stat_r, s_stat_r, 'b')
hold on
plot_shaded_errorbars(tx, m_stat_w, s_stat_w, 'r')
xline(0, '-', 'Touch start')
legend({'Human', '', 'Artificial', ''})
legend AutoUpdate off
title('Static Touch')
hold off
xlabel('Time (s)')
ylabel('Pupil size (z)')
linkaxes





















