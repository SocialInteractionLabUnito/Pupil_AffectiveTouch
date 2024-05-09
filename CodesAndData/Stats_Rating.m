% Run stats on subjective ratings

clc
clearvars
close all

addpath(fullfile(pwd, 'myFunctions'))



% Import
data = readtable(fullfile(pwd, 'Data.xlsx'));
varsnames = data.Properties.VariableNames;

% Keep rating data
data = data(:,contains(varsnames,'Subj')|contains(varsnames, 'Rating'));
data.Properties.VariableNames = strrep(data.Properties.VariableNames, 'Rating_', '');



% Run stats
% -------------------------------------------------------------------
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
[~, pHoc.Dynamic_Real_vs_Static_Wood.p, ~, pHoc.Dynamic_Real_vs_Static_Wood.stats] = ttest(data.Dynamic_Real, data.Static_Wood);

% Correct ps
[~, ~, ~, pcorr] = fdr_bh([pHoc.Dynamic_Real_vs_Static_Real.p, pHoc.Dynamic_Real_vs_Dynamic_Wood.p, ...
                           pHoc.Dynamic_Wood_vs_Static_Wood.p, pHoc.Dynamic_Real_vs_Static_Wood.p]);

pHoc.Dynamic_Real_vs_Static_Real.p = pcorr(1);
pHoc.Dynamic_Real_vs_Dynamic_Wood.p = pcorr(2);
pHoc.Dynamic_Wood_vs_Static_Wood.p = pcorr(3);
pHoc.Dynamic_Real_vs_Static_Wood.p = pcorr(4);


% Plot
%----------------------------------------------------
figure
violin([data.Dynamic_Real, data.Dynamic_Wood, data.Static_Real, data.Static_Wood])
% Add single datapoints
[G, GID] = findgroups(data.Subj);
sdata_1 = splitapply(@mean, data.Dynamic_Real, G);
sdata_2 = splitapply(@mean, data.Dynamic_Wood, G);
sdata_3 = splitapply(@mean, data.Static_Real, G);
sdata_4 = splitapply(@mean, data.Static_Wood, G);
legend autoupdate off
hold on
plot(1, sdata_1, 'ko', 'markersize', 3, 'MarkerFace', 'k')
plot(2, sdata_2, 'ko', 'markersize', 3, 'MarkerFace', 'k')
plot(3, sdata_3, 'ko', 'markersize', 3, 'MarkerFace', 'k')
plot(4, sdata_4, 'ko', 'markersize', 3, 'MarkerFace', 'k')
xticks(1:4)
xticklabels({'Human Dynamic', 'Artificial Dynamic', 'Human Static', 'Artificial Static'})















