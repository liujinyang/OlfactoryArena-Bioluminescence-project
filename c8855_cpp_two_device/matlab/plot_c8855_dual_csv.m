function T = plot_c8855_dual_csv(csvPath)
T = readtable(csvPath);
figure('Name', 'C8855 Dual Channels');
plot(T.time_s, T.ch0_count, '-', 'DisplayName', 'ID 0');
hold on;
plot(T.time_s, T.ch1_count, '-', 'DisplayName', 'ID 1');
hold off;
xlabel('Time (s)');
ylabel('Count');
grid on;
legend('Location', 'best');
title('C8855-01 dual-channel acquisition');
end
