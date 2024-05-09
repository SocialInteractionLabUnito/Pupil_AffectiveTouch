% Run stats on pupil data
% Also run control stats for Gender and Age effects

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




%% Main stats

% Run stats
%--------------------------------
Touch = categorical({'Dynamic' 'Dynamic' 'Static' 'Static'}');
Hand = categorical({'Real' 'Wood' 'Real' 'Wood'}');

withintab = table(Touch, Hand,'variablenames',{'Touch','Hand'});


rm = fitrm(data,'Dynamic_Real-Static_Wood ~1','withindesign',withintab);

ANOVA = ranova(rm,'withinmodel','Touch*Hand');

ANOVA.etaSq = zeros(size(ANOVA,1), 1);
for i = 1:size(ANOVA,1)
    p = ANOVA.pValue(i);
    if p < 0.05
        eta = ( ANOVA.SumSq(i) ) / (ANOVA.SumSq(i) + ANOVA.SumSq(i+1));
        ANOVA.etaSq(i) = eta;
    end
end


% Post hocs
[~, pHoc.Dynamic_Real_vs_Static_Real.p, ~, pHoc.Dynamic_Real_vs_Static_Real.stats] = ttest(data.Dynamic_Real, data.Static_Real);
[~, pHoc.Dynamic_Real_vs_Dynamic_Wood.p, ~, pHoc.Dynamic_Real_vs_Dynamic_Wood.stats] = ttest(data.Dynamic_Real, data.Dynamic_Wood);
[~, pHoc.Dynamic_Wood_vs_Static_Wood.p, ~, pHoc.Dynamic_Wood_vs_Static_Wood.stats] = ttest(data.Dynamic_Wood, data.Static_Wood);
[~, pHoc.Static_Real_vs_Static_Wood.p, ~, pHoc.Static_Real_vs_Static_Wood.stats] = ttest(data.Static_Real, data.Static_Wood);

% Correct ps
[~, ~, ~, pcorr] = fdr_bh([pHoc.Dynamic_Real_vs_Static_Real.p, pHoc.Dynamic_Real_vs_Dynamic_Wood.p, ...
                           pHoc.Dynamic_Wood_vs_Static_Wood.p, pHoc.Static_Real_vs_Static_Wood.p]);

pHoc.Dynamic_Real_vs_Static_Real.p = pcorr(1);
pHoc.Dynamic_Real_vs_Dynamic_Wood.p = pcorr(2);
pHoc.Dynamic_Wood_vs_Static_Wood.p = pcorr(3);
pHoc.Static_Real_vs_Static_Wood.p = pcorr(4);


% Plot
%----------------------------------------------------
figure
m1 = mean(data.Dynamic_Real);
m2 = mean(data.Dynamic_Wood);
m3 = mean(data.Static_Real);
m4 = mean(data.Static_Wood);

s1 = sterr(data.Dynamic_Real);
s2 = sterr(data.Dynamic_Wood);
s3 = sterr(data.Static_Real);
s4 = sterr(data.Static_Wood);


y = [m1 m2; m3 m4];
err = [s1 s2; s3 s4];

bar(y)
hold on

ngroups = size(y, 1);
nbars = size(y, 2);
groupwidth = min(0.8, nbars/(nbars + 1.5));
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, y(:,i), err(:,i), 'k', 'linestyle', 'none');
end

xticks(1:2)
xticklabels({'Dynamic' 'Static'})
xlabel('Hand Type')
ylabel('Pupil Size [z-score]')
legend({'Real' 'Wood'})
title('Pupil Size')





%% Control Gender effect

% Read genders
subjinfo = readtable(fullfile(pwd, 'Subj_info.xlsx'));
alldatacontrol = data;

% Get gender and age
for i = 1:height(subjinfo)
    currs = subjinfo.ID(i);
    currgender = subjinfo.Gender(i);
    currage = subjinfo.Age(i);
    idx = find(alldatacontrol.Subj == currs);
    alldatacontrol.Gender(idx) = currgender;
    alldatacontrol.Age(idx) = currage;
end

% Stats
Touch = categorical({'Dynamic' 'Dynamic' 'Static' 'Static'}');
Hand = categorical({'Real' 'Wood' 'Real' 'Wood'}');
withintab = table(Touch, Hand,'variablenames',{'Touch','Hand'});
tbl = alldatacontrol;
tbl.Gender = categorical(alldatacontrol.Gender);
tbl.Age = alldatacontrol.Age;
rm = fitrm(tbl,'Dynamic_Real-Static_Wood ~ Gender','withindesign',withintab);
ANOVA_ControlGender = ranova(rm,'withinmodel','Touch*Hand');



%% Control Age effect

figure

subplot(221)
x = tbl.Age;
y = tbl.Dynamic_Real;
subplot(2,2,1); scatter(x, y, 'k', 'filled')
hold on; plot_fitted_line(x, y, 1, 'r');
[r, p] = corrcoef(x,y); r = r(1,2); p = p(1,2);
xlabel('Age'); ylabel('Pupil Size')
title(['Human Dynamic - ', 'r = ', num2str(r), '. p = ', num2str(p)])

subplot(222)
x = tbl.Age;
y = tbl.Dynamic_Wood;
scatter(x, y, 'k', 'filled')
hold on; plot_fitted_line(x, y, 1, 'r');
[r, p] = corrcoef(x,y); r = r(1,2); p = p(1,2);
xlabel('Age'); ylabel('Pupil Size')
title(['Artificial Dynamic - ', 'r = ', num2str(r), '. p = ', num2str(p)])

subplot(223)
x = tbl.Age;
y = tbl.Static_Real;
scatter(x, y, 'k', 'filled')
hold on; plot_fitted_line(x, y, 1, 'r');
[r, p] = corrcoef(x,y); r = r(1,2); p = p(1,2);
xlabel('Age'); ylabel('Pupil Size')
title(['Human Static - ', 'r = ', num2str(r), '. p = ', num2str(p)])

subplot(224)
x = tbl.Age;
y = tbl.Static_Wood;
scatter(x, y, 'k', 'filled')
hold on; plot_fitted_line(x, y, 1, 'r');
[r, p] = corrcoef(x,y); r = r(1,2); p = p(1,2);
xlabel('Age'); ylabel('Pupil Size')
title(['Artificial Static - ', 'r = ', num2str(r), '. p = ', num2str(p)])

sgtitle('Age effect')



