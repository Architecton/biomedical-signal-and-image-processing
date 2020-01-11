load rotation_data.mat

figure(1); hold on; xlim([-1.5, 1.5]); ylim([-1.5, 1.5]);

for idx = 1:size(data, 1)
    pt_nxt = plot(data(idx, 1), data(idx, 2), 'r.', 'MarkerSize', 5);
    drawnow
end
