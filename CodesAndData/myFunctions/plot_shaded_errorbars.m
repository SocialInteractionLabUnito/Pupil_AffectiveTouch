function plot_shaded_errorbars(tx, y, err, color)

lo = y - err;
hi = y + err;


hp = patch([tx'; tx(end:-1:1)'; tx(1)], [lo'; hi(end:-1:1)'; lo(1)], color);
hold on;
hl = line(tx,y);
hold off

set(hp, 'facecolor', color, 'edgecolor', 'none');
set(hp, "FaceAlpha", 0.2)
set(hl, 'color', color);


end
