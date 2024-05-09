% Plot supralinearity effect and test marginals

clc
clearvars
close all

addpath(fullfile(pwd, 'myFunctions'))



% Import
data = readtable(fullfile(pwd, 'Data.xlsx'));
varsnames = data.Properties.VariableNames;

% Keep pupil data
data = data(:,contains(varsnames,'Subj')|contains(varsnames, 'Pupil'));
data.Properties.VariableNames = strrep(data.Properties.VariableNames, 'Pupil_', '');

% Average per subj
G = findgroups(data.Subj);
m1 = splitapply(@mean, data.Dynamic_Real, G);
m2 = splitapply(@mean, data.Dynamic_Wood, G);
m3 = splitapply(@mean, data.Static_Real, G);
m4 = splitapply(@mean, data.Static_Wood, G);

new = table();
new.Subj = unique(data.Subj);
new.Dynamic_Real = m1;
new.Dynamic_Wood = m2;
new.Static_Real = m3;
new.Static_Wood = m4;
data = new;


% Plot
dyn_real = data.Dynamic_Real;
somma = data.Dynamic_Wood + data.Static_Real;

figure
scatter(somma, dyn_real, 'k', 'filled')
hold on
x = linspace(-3, 4, 1000);
y = x;
plot(x,y);
xline(0, 'k:')
yline(0, 'k:')
xlabel('Static Real + Dynamic Wood')
ylabel('Dynamic Real')
xlim([-0.5 1.5])
ylim([-0.5 1.5])


% Test marginal
[rej, pVal, ~, stats] = ttest(dyn_real, somma, 'tail', 'right')
