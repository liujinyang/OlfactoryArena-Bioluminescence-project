function live_plot_c8855_dual_csv(csvPath, refreshSec)
if nargin < 2
    refreshSec = 0.5;
end
f = figure('Name', 'C8855 Dual Live Plot');
while ishandle(f)
    if exist(csvPath, 'file')
        T = readtable(csvPath);
        clf(f);
        plot(T.time_s, T.ch0_count, '-', 'DisplayName', 'ID 0');
        hold on;
        plot(T.time_s, T.ch1_count, '-', 'DisplayName', 'ID 1');
        hold off;
        xlabel('Time (s)'); ylabel('Count');
        grid on; legend('Location', 'best');
        title(sprintf('Rows: %d', height(T)));
        drawnow;
    end
    pause(refreshSec);
end
end
