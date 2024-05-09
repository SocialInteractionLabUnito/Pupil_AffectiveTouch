
clc
clearvars
close all

addpath(fullfile(pwd, 'myFunctions'))

% Import
data = readtable(fullfile(pwd, 'Data.xlsx'));
varsnames = data.Properties.VariableNames;

% Keep pupil data
data = data(:,contains(varsnames,'Subj')|contains(varsnames, 'Blinks'));
data.Properties.VariableNames = strrep(data.Properties.VariableNames, 'Blinks_', '');



% zscore
subjs = unique(data.Subj);
for i = 1:numel(subjs)
    a = data{data.Subj==subjs(i), 2:end};
    z = zscore(a, 0, 'all');
    data{data.Subj==subjs(i), 2:end} = z;
end


% test normality
[h, p] = kstest(data.Dynamic_Real);
[h, p] = kstest(data.Dynamic_Wood);
[h, p] = kstest(data.Static_Real);
[h, p] = kstest(data.Static_Wood);


% Run stats
p1 = signrank(data.Dynamic_Real, data.Dynamic_Wood)
p2 = signrank(data.Dynamic_Real, data.Static_Real)
p3 = signrank(data.Dynamic_Wood, data.Static_Wood)
p4 = signrank(data.Static_Real, data.Static_Wood)

[~, ~, ~, pcorr] = fdr_bh([p1,p2,p3,p4])


