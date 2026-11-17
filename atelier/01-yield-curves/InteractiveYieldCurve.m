%% 0. OPTIONS (edit here)
clear; clc; close all;
projectDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
dataDir = fullfile(projectDir, 'data', 'raw');
outputDir = fullfile(projectDir, 'results', 'generated', 'yield-curves');
if ~isfolder(outputDir), mkdir(outputDir); end
startDate = datetime(1982,1,1);
ids       = {'TB3MS','GS2','GS5','GS10','GS30'};
mats      = [0.25    2     5     10     30];   % maturities in years (same order as ids)
labels    = {'3M','2Y','5Y','10Y','30Y'};

%% 1. Import the selected FRED series
files = dir(fullfile(dataDir, '*.csv'));
files = files(ismember({files.name}, strcat(ids, '.csv')));
TT = [];
for k = 1:numel(files)
    X = readFRED(fullfile(files(k).folder, files(k).name));
    if isempty(TT), TT = X; else, TT = synchronize(TT, X, 'union'); end
end

%% 2. Select series and period
C = TT(:, ids);
C = C(C.Properties.RowTimes >= startDate, :);
Y = C{:,:};  dates = C.Properties.RowTimes;

%% 3. Interactive animated yield curve
yieldCurveVideo(Y, dates, mats, labels, ids, outputDir);

%% Helper functions (must be at the end of the file)
function yieldCurveVideo(Y, dates, mats, labels, ids, outputDir)
    iLast  = find(all(~isnan(Y),2), 1, 'last');    % latest month with all maturities available
    speeds = [0.5 1 2 4];                          % playback speed multipliers
    fps    = 15;                                   % frame rate of the saved MP4
    yl = [min(Y(:)) max(Y(:))];  pad = 0.05*diff(yl);  yl = yl + [-pad pad];   % fixed y-axis limits

    fig = figure('Position',[100 100 1000 720], 'Name', 'US yield curve - interactive');

    btnPlay = uicontrol(fig, 'Style', 'togglebutton', 'String', 'Play', 'Units', 'normalized', ...
        'Position', [0.04 0.915 0.08 0.06], 'Callback', @onPlay);
    sld = uicontrol(fig, 'Style', 'slider', 'Min', 1, 'Max', iLast, 'Value', iLast, ...
        'SliderStep', [1/(iLast-1) 12/(iLast-1)], 'Units', 'normalized', ...
        'Position', [0.13 0.93 0.50 0.03], 'Callback', @(~,~) draw());
    lblDate = uicontrol(fig, 'Style', 'text', 'FontSize', 14, 'FontWeight', 'bold', ...
        'Units', 'normalized', 'Position', [0.64 0.915 0.10 0.05]);
    pop = uicontrol(fig, 'Style', 'popupmenu', 'String', {'0.5x','1x','2x','4x'}, 'Value', 2, ...
        'Units', 'normalized', 'Position', [0.75 0.92 0.08 0.05]);
    uicontrol(fig, 'Style', 'pushbutton', 'String', 'Save MP4', 'Units', 'normalized', ...
        'Position', [0.85 0.915 0.11 0.06], 'Callback', @onSave);

    bgS = uibuttongroup(fig, 'Title', 'Maturity axis (x)', 'Units', 'normalized', ...
        'Position', [0.04 0.82 0.22 0.08], 'SelectionChangedFcn', @(~,~) draw());
    uicontrol(bgS, 'Style', 'togglebutton', 'String', 'Linear', 'UserData', 'linear', ...
        'Units', 'normalized', 'Position', [0 0 0.5 1]);
    uicontrol(bgS, 'Style', 'togglebutton', 'String', 'Log', 'UserData', 'log', ...
        'Units', 'normalized', 'Position', [0.5 0 0.5 1]);

    bgY = uibuttongroup(fig, 'Title', 'Yield axis (y)', 'Units', 'normalized', ...
        'Position', [0.30 0.82 0.30 0.08], 'SelectionChangedFcn', @(~,~) draw());
    uicontrol(bgY, 'Style', 'togglebutton', 'String', 'Fixed', 'UserData', 'fixed', ...
        'Units', 'normalized', 'Position', [0 0 1/3 1]);
    uicontrol(bgY, 'Style', 'togglebutton', 'String', 'Auto', 'UserData', 'auto', ...
        'Units', 'normalized', 'Position', [1/3 0 1/3 1]);
    uicontrol(bgY, 'Style', 'togglebutton', 'String', 'Log', 'UserData', 'log', ...
        'Units', 'normalized', 'Position', [2/3 0 1/3 1]);

    tb = uitable(fig, 'ColumnName', labels, ...
        'RowName', {'Shown (%)','12 months earlier (%)','Change (pp)','Change (%)'}, ...
        'Units', 'normalized', 'Position', [0.04 0.64 0.92 0.16]);
    ax = axes(fig, 'Position', [0.08 0.08 0.87 0.50]);
    draw();

    function draw()
        i  = round(sld.Value);
        y0 = Y(i,:);
        if i > 12, yp = Y(i-12,:); else, yp = nan(size(y0)); end
        chg = y0 - yp;
        tb.Data = round([y0; yp; chg; chg ./ yp * 100], 2);

        g10 = strcmp(ids,'GS10'); g2 = strcmp(ids,'GS2'); g3 = strcmp(ids,'TB3MS');
        cla(ax); hold(ax, 'on'); grid(ax, 'on');
        plot(ax, mats, y0, 'o-', 'LineWidth', 2.5, 'Color', [0.2 0.45 0.85], 'MarkerFaceColor', [0.2 0.45 0.85]);
        set(ax, 'XScale', bgS.SelectedObject.UserData);
        xticks(ax, mats); xticklabels(ax, labels); xlim(ax, [min(mats)*0.9 max(mats)*1.05]);

        switch bgY.SelectedObject.UserData
            case 'fixed'                           % same limits for the whole period
                set(ax, 'YScale', 'linear');  ylim(ax, yl);
            case 'auto'                            % zoom on the curve shown
                set(ax, 'YScale', 'linear');
                p = max(0.15*(max(y0)-min(y0)), 0.1);
                ylim(ax, [min(y0)-p, max(y0)+p]);
            case 'log'                             % logarithmic yields (positive values only)
                set(ax, 'YScale', 'log');  ylim(ax, [max(yl(1), 0.05) yl(2)]);
        end

        xlabel(ax, 'Maturity'); ylabel(ax, 'Yield (%)');
        title(ax, sprintf('US Treasury yield curve - %s\n10Y-3M: %.2f pp   |   10Y-2Y: %.2f pp', ...
              datestr(dates(i), 'mmm yyyy'), y0(g10)-y0(g3), y0(g10)-y0(g2)));
        lblDate.String = datestr(dates(i), 'mmm yyyy');
    end

    function onPlay(src, ~)
        if src.Value == 1
            src.String = 'Pause';
            if round(sld.Value) >= iLast, sld.Value = 1; end      % restart from the beginning
            while isvalid(src) && src.Value == 1
                i = round(sld.Value);
                if i >= iLast, break; end
                sld.Value = i + 1;
                draw(); drawnow;
                pause(0.12 / speeds(pop.Value));
            end
            if isvalid(src), src.Value = 0; src.String = 'Play'; end
        else
            src.String = 'Play';
        end
    end

    function onSave(src, ~)
        old = sld.Value;  src.String = 'Saving...';  drawnow;
        videoFile = fullfile(outputDir, 'yield_curve.mp4');
        vw = VideoWriter(videoFile, 'MPEG-4');  vw.FrameRate = fps;  open(vw);
        for i = 1:iLast
            sld.Value = i;  draw();  drawnow;
            writeVideo(vw, getframe(fig));
        end
        close(vw);
        sld.Value = old;  draw();  src.String = 'Save MP4';
        fprintf('Video saved: %s\n', videoFile);
    end
end

function TT = readFRED(f)
    T = readtable(f, 'TreatAsMissing', '.');
    T.Properties.VariableNames{1} = 'Date';
    T.Date = datetime(T.Date);
    TT = table2timetable(T);
end
