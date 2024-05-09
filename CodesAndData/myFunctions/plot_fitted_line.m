function plot_fitted_line(x,y,degree,color,str)

if nargin > 4
	isna = isnan(x) | isnan(y);
	x(isna) = [];
	y(isna) = [];
end



coefficients = polyfit(x, y, degree);

% Create a new x axis with exactly 1000 points (or whatever you want).
xFit = linspace(min(x), max(x), numel(x)*10);

% Get the estimated yFit value for new x locations.
yFit = polyval(coefficients , xFit);

% Plot
plot(xFit, yFit, color, 'LineWidth', 2); % Plot fitted line.





end

