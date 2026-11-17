%% 0. OPTIONS (edit here)
clear; clc; close all;
projectDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
dataDir = fullfile(projectDir, 'data', 'raw');
outputDir = fullfile(projectDir, 'results', 'generated', 'pca');
if ~isfolder(outputDir), mkdir(outputDir); end
startDate  = datetime(1982,1,1);
dataSource = 'GSW';      % 'GSW': Fed zero-coupon yields (feds200628.csv); 'FRED': FRED CSV files
maxMat     = 10;         % GSW only: use yields 1Y,2Y,...,maxMat (e.g. 10 or 15)
gswFile    = fullfile(dataDir, 'feds200628.csv');

useChanges = false;      % false: PCA on yield levels; true: on monthly changes
K          = 3;          % number of components used in the reconstruction
nStd       = 1;          % shock size in the plots (std. deviations of the factor)

% FRED settings (used only if dataSource = 'FRED')
ids    = {'TB3MS','GS2','GS5','GS10'};
mats   = [0.25 2 5 10];                 % maturities in years (same order as ids)
labels = {'3M','2Y','5Y','10Y'};

%% 1. Import data
if strcmp(dataSource, 'GSW')
    if ~isfile(gswFile)                                  % try to find the file by name
        d = dir(fullfile(dataDir, '*.csv'));
        d = d(contains(lower({d.name}), {'feds','yield','gsw'}));
        if isempty(d)
            error('File %s not found in %s. Put the Fed CSV in the data folder or set gswFile.', gswFile, dataDir);
        end
        gswFile = fullfile(d(1).folder, d(1).name);  fprintf('Using file: %s\n', gswFile);
    end
    lines = splitlines(fileread(gswFile));
    h = find(startsWith(lower(strtrim(lines)), 'date'), 1);   % header row of the data table
    if isempty(h), error('Header row starting with "Date" not found in %s.', gswFile); end
    G = readtable(gswFile, 'NumHeaderLines', h-1, 'TreatAsMissing', {'NA',''});
    G.Properties.VariableNames{1} = 'Date';
    G.Date = datetime(G.Date);

    vn  = G.Properties.VariableNames;                    % find the SVENYxx columns (zero-coupon yields)
    tok = regexp(vn, '^SVENY(\d+)$', 'tokens', 'once', 'ignorecase');
    isY = ~cellfun(@isempty, tok);
    if ~any(isY)
        error('No SVENYxx columns found. First columns: %s', strjoin(vn(1:min(end,40)), ', '));
    end
    yrs = cellfun(@(c) str2double(c{1}), tok(isY));
    yc  = vn(isY);
    [yrs, o] = sort(yrs);  yc = yc(o);
    sel    = yrs <= maxMat;
    ids    = yc(sel);
    mats   = yrs(sel);
    labels = cellstr(compose('%dY', mats));
    fprintf('Yields used: %s\n', strjoin(labels, ' '));

    TTd = sortrows(table2timetable(G(:, [{'Date'}, ids])));
    TT  = retime(TTd, 'monthly', 'lastvalue');           % end-of-month values
else
    files = dir(fullfile(dataDir, '*.csv'));
    TT = [];
    for k = 1:numel(files)
        inputFile = fullfile(files(k).folder, files(k).name);
        H = readtable(inputFile, 'TreatAsMissing', '.');
        if ~any(ismember(H.Properties.VariableNames(2:end), ids)), continue; end
        X = readFRED(inputFile);
        if isempty(TT), TT = X; else, TT = synchronize(TT, X, 'union'); end
    end
end

%% 2. Select series and period
C = TT(:, ids);
C = C(C.Properties.RowTimes >= startDate, :);
C = rmmissing(C);                       % keep only months with all maturities
Y = C{:,:};  dates = C.Properties.RowTimes;   % yields in %, T x p
Ylev = Y;                               % yield levels (used for the average curve)
if useChanges
    Y = diff(Y);  dates = dates(2:end); % Delta y_t
end
[nObs, p] = size(Y);
fprintf('Sample: %s -> %s, T=%d, p=%d\n', datestr(dates(1),'mmm yyyy'), datestr(dates(end),'mmm yyyy'), nObs, p);

%% 3. PCA: Sigma = A * Lambda * A'
Rbar  = mean(Y,1);
Rd    = Y - Rbar;                       % demeaned
Sigma = cov(Rd);                        % sample covariance matrix
[A, L] = eig(Sigma);
[lam, idx] = sort(diag(L), 'descend');  % lambda_1 > ... > lambda_p
A = A(:, idx);

% sign normalization (same convention as the slides)
if sum(A(:,1)) < 0, A(:,1) = -A(:,1); end   % level > 0
if A(1,2)   < 0,    A(:,2) = -A(:,2); end   % slope: positive on the short end
if A(end,3) < 0,    A(:,3) = -A(:,3); end   % curvature: positive on the long end

% explained variance: R2_PCA(k) = sum_{i<=k} lambda_i / sum_i lambda_i
expl = lam / sum(lam);
cumv = cumsum(expl);
disp(table((1:p)', lam, 100*expl, 100*cumv, ...
    'VariableNames', {'PC','Eigenvalue','Explained_pct','Cumulative_pct'}));

%% 4. PCA factors: Z_t = A'(R_t - Rbar)
Z = Rd * A;                             % T x p, columns = principal components
fprintf('Var(Z_i):  %s\n', mat2str(var(Z), 4));
fprintf('lambda_i:  %s\n', mat2str(lam', 4));
fprintf('max |Corr(Z) - I| = %.2e\n', max(abs(corrcoef(Z) - eye(p)), [], 'all'));

%% 5. Reconstruction with K components: R - Rbar ~ A_(K) Z_(K)
Rhat = Z(:,1:K) * A(:,1:K)' + Rbar;
rmse = sqrt(mean((Y - Rhat).^2, 1));
disp(table(labels', rmse', 'VariableNames', {'Maturity','RMSE_pp'}));

%% 6. Monthly table: yields + PC1 (level), PC2 (slope), PC3 (curvature)
Yal = Ylev(end-nObs+1:end, :);          % yield levels aligned with the dates of Z
MonthlyData = array2timetable([Yal, Z(:,1:3)], 'RowTimes', dates, ...
    'VariableNames', [strcat('y_', labels), {'PC1_Level','PC2_Slope','PC3_Curvature'}]);
disp(head(MonthlyData, 10));
writetimetable(MonthlyData, fullfile(outputDir, 'pca_monthly_matlab.csv'));

names = {'Level','Slope','Curvature'};
Load = array2table(A(:,1:3), 'VariableNames', names, 'RowNames', labels);
disp(Load);
writetable(Load, fullfile(outputDir, 'pca_loadings_matlab.csv'), 'WriteRowNames', true);

%% 7. Figure 1: factor loadings (level, slope, curvature) vs maturity
xmax = max(mats) * 1.05;

figure(1); clf; set(gcf, 'Position', [100 100 900 450]);
hold on;
plot(mats, A(:,1), 'b-o', 'LineWidth', 2);
plot(mats, A(:,2), 'r-o', 'LineWidth', 2);
plot(mats, A(:,3), '-o', 'Color', [0.93 0.69 0.13], 'LineWidth', 2);   % yellow
grid on; xlabel('Maturity (years)'); xlim([0 xmax]);
title('Factor loadings (PCA) for the U.S. yield curve');
legend({'level','slope','curvature'}, 'Location', 'best');

%% 8. Figure 2: bar chart of PC loadings, one group per yield maturity
cols = [0 0.2 0.8; 0.9 0.1 0.1; 0.93 0.69 0.13];   % PC1 blue, PC2 red, PC3 yellow
figure(2); clf; set(gcf, 'Position', [100 100 1100 450]);
b = bar(A(:,1:3), 'grouped');
for i = 1:3, b(i).FaceColor = cols(i,:); end
set(gca, 'XTick', 1:p, 'XTickLabel', labels);
grid on; xlabel('Yield maturity'); ylabel('Loadings'); title('PC loadings');
leg = cell(1,3);
for i = 1:3, leg{i} = sprintf('PC%d (%.1f%%)', i, 100*expl(i)); end
legend(leg, 'Location', 'best');

%% 9. Figure 3: monthly PCA factors over time
figure(3); clf; set(gcf, 'Position', [100 100 1000 700]);
for i = 1:3
    subplot(3,1,i);
    plot(dates, Z(:,i), 'Color', cols(i,:), 'LineWidth', 1.2); grid on;
    title(sprintf('PC%d (%.1f%%)', i, 100*expl(i)));
    ylabel(sprintf('PC%d (%%)', i));
end

%% Helper functions (must be at the end of the file)
function TT = readFRED(f)
    T = readtable(f, 'TreatAsMissing', '.');
    T.Properties.VariableNames{1} = 'Date';
    T.Date = datetime(T.Date);
    TT = table2timetable(T);
end
