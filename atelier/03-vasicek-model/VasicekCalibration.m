%% 0. Settings you can change
clear; clc; close all;
projectDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
dataDir = fullfile(projectDir, 'data', 'raw');
outputDir = fullfile(projectDir, 'results', 'generated', 'vasicek');
if ~isfolder(outputDir), mkdir(outputDir); end
startDate = datetime(1982,1,1);
gswFile   = fullfile(dataDir, 'feds200628.csv');   % Fed zero-coupon yields (SVENYxx)
maxMat    = 10;                 % fit the model to 1-year through 10-year yields
shortFile = fullfile(dataDir, 'TB3MS.csv');        % FRED 3M T-bill = proxy of the short rate r_t
dt        = 1/12;               % monthly data (in years)

%% 1. Read the yields and short-term rate
% Use the last available daily yield in each month.
lines = splitlines(fileread(gswFile));
h = find(startsWith(lower(strtrim(lines)), 'date'), 1);
G = readtable(gswFile, 'NumHeaderLines', h-1, 'TreatAsMissing', {'NA',''});
G.Properties.VariableNames{1} = 'Date';
G.Date = datetime(G.Date);
vn  = G.Properties.VariableNames;
tok = regexp(vn, '^SVENY(\d+)$', 'tokens', 'once', 'ignorecase');
isY = ~cellfun(@isempty, tok);
if ~any(isY), error('No SVENYxx columns found. First columns: %s', strjoin(vn(1:min(end,40)), ', ')); end
yrs = cellfun(@(c) str2double(c{1}), tok(isY));  yc = vn(isY);
[yrs, o] = sort(yrs);  yc = yc(o);
sel    = yrs <= maxMat;
ids    = yc(sel);
tau    = yrs(sel);  tau = tau(:)';             % maturities in years (1 x m)
labels = cellstr(compose('%dY', tau));
TTy = retime(sortrows(table2timetable(G(:, [{'Date'}, ids]))), 'monthly', 'lastvalue');

% Use the 3-month bill rate as an estimate of the short-term rate.
if isfile(shortFile)
    S = readtable(shortFile, 'TreatAsMissing', '.');
    S.Properties.VariableNames{1} = 'Date';  S.Date = datetime(S.Date);
    TTs = table2timetable(S(:, [1 2]));
    TTs.Properties.VariableNames = {'r'};
    shortName = '3M T-bill (TB3MS)';
else
    warning('%s not found: using the 1Y zero-coupon yield as short rate.', shortFile);
    TTs = TTy(:, ids(1));
    TTs.Properties.VariableNames = {'r'};
    shortName = '1Y zero-coupon yield';
end

TT = synchronize(TTy, TTs, 'intersection');
TT = TT(TT.Properties.RowTimes >= startDate, :);
TT = rmmissing(TT);
dates = TT.Properties.RowTimes;
Y = TT{:, ids} / 100;                   % convert percent to decimals: 4% becomes 0.04
r = TT.r / 100;                         % one short-term rate per month
nObs = numel(r);
fprintf('Sample: %s -> %s, T=%d, short rate: %s\n', datestr(dates(1),'mmm yyyy'), datestr(dates(end),'mmm yyyy'), nObs, shortName);

%% 2. Set up the Vasicek bond and yield formulas
% Rates tend to return to rbar, at speed kappa, with random changes scaled by sigma.
% For pricing bonds, the long-run rate is theta = rbar - lambda*sigma/kappa.
% lambda is the market price of risk. The bond price is exp(A - B*r).
Bf = @(k,t) (1 - exp(-k*t)) ./ k;
Af = @(k,th,sg,t) (th - sg^2/(2*k^2)) .* (Bf(k,t) - t) - sg^2 * Bf(k,t).^2 / (4*k);
Rf = @(r,k,th,sg,t) (r * Bf(k,t) - Af(k,th,sg,t)) ./ t;   % r: T x 1, t: 1 x m -> T x m

%% 3. Estimate the model from one month's rate and the next
%    r_{t+dt} = a + b r_t + eps,  b = exp(-kappa dt),  a = rbar (1-b),
%    eps ~ N(0, sigma^2 (1-b^2)/(2 kappa))
x = r(1:end-1);  y = r(2:end);
X = [ones(size(x)) x];
coef = X \ y;                            % OLS: [a; b]
a = coef(1);  b = coef(2);
res = y - X*coef;
s2  = sum(res.^2) / (numel(y) - 2);      % Var(eps)
se  = sqrt(diag(s2 * inv(X'*X)));        % standard errors of [a; b]
if ~(b > 0 && b < 1)
    error('b = %.4f is outside (0,1): no mean reversion can be estimated.', b);
end
kappa = -log(b) / dt;
rbar  = a / (1 - b);
sigma = sqrt(s2 * 2*kappa / (1 - b^2));
fprintf('\nDiscrete-time AR(1): a=%.5f  b=%.4f (s.e. %.4f)  Var(eps)=%.3e\n', a, b, se(2), s2);
fprintf('Continuous-time parameters (P): kappa=%.4f  rbar=%.3f%%  sigma=%.1f bp/sqrt(yr)\n', kappa, 100*rbar, 1e4*sigma);
fprintf('  half-life = %.2f years,  stationary std = %.0f bp\n', log(2)/kappa, 1e4*sigma/sqrt(2*kappa));

%% 4. Fit the pricing parameter to the observed yields
% Predicted yields are linear in theta, so least squares gives a direct solution.
R0    = Rf(r, kappa, 0, sigma, tau);
slope = -(Bf(kappa,tau) - tau) ./ tau;                  % dR/dtheta, 1 x m
theta = sum(sum((Y - R0) .* slope)) / (nObs * sum(slope.^2));
lambda = (rbar - theta) * kappa / sigma;
fprintf('Q-measure: theta=%.3f%%  lambda=%.4f\n', 100*theta, lambda);

% Check A(tau) another way: integrate A'(s) = sigma^2 B(s)^2/2 - kappa theta B(s).
Tchk = tau(end);
Anum = integral(@(s) 0.5*sigma^2*Bf(kappa,s).^2 - kappa*theta*Bf(kappa,s), 0, Tchk);
fprintf('Check A(%gY): closed form = %.8f, numeric = %.8f\n', Tchk, Af(kappa,theta,sigma,Tchk), Anum);

%% 5. Compare predicted yields with the data and save the parameters
Yhat = Rf(r, kappa, theta, sigma, tau);
err  = (Y - Yhat) * 1e4;                                % basis points
disp(table(labels', sqrt(mean(err.^2,1))', mean(err,1)', ...
    'VariableNames', {'Maturity','RMSE_bp','Bias_bp'}));

Params = table(kappa, rbar, sigma, theta, lambda, log(2)/kappa, ...
    'VariableNames', {'kappa','rbar','sigma','theta_Q','lambda','half_life_years'});
disp(Params);
writetable(Params, fullfile(outputDir, 'vasicek_params_matlab.csv'));

%% 6. Plot observed and predicted yields
figure(1); clf; set(gcf, 'Position', [100 100 900 450]);
plot(tau, 100*mean(Y,1),    'b-o', 'LineWidth', 2); hold on;
plot(tau, 100*mean(Yhat,1), 'r--o', 'LineWidth', 2); grid on;
xlabel('Maturity (years)'); ylabel('Yield (%)');
title('Average yield curve: data vs Vasicek');
legend({'data','Vasicek'}, 'Location', 'best');

figure(2); clf; set(gcf, 'Position', [100 100 1000 700]);
targets = [2 5 10];  nplot = 0;
for m = targets
    [d, j] = min(abs(tau - m));
    if d > 0, continue; end                             % only exact maturities
    nplot = nplot + 1;
    subplot(numel(targets), 1, nplot);
    plot(dates, 100*Y(:,j), 'b', dates, 100*Yhat(:,j), 'r--', 'LineWidth', 1.2); grid on;
    title(sprintf('%dY yield: data vs Vasicek', m)); ylabel('%');
    if nplot == 1, legend({'data','Vasicek'}, 'Location', 'best'); end
end

%% 7. Open the chart where you can change the model parameters
vasicekYieldUI(kappa, rbar, sigma, lambda, r);

%% Local functions (must be at the end of the file)
function vasicekYieldUI(kEst, rbEst, sgEst, lmEst, rObs)
    % Start with the slide values. The menu also offers the estimated values.
    slide = struct('kappa', 0.2, 'rbar', 0.06, 'sigma', 0.03, 'lambda', -0.015, ...
                   'r0', '0.03 0.04 0.05 0.06 0.07', 'tauMax', 30);
    rs = sort(rObs);  q = [0.05 0.25 0.50 0.75 0.95];
    rq = rs(max(1, round(q*numel(rs))));                 % quantiles of the observed short rate
    est = struct('kappa', kEst, 'rbar', rbEst, 'sigma', sgEst, 'lambda', lmEst, ...
                 'r0', sprintf('%.4f ', rq), 'tauMax', 30);

    names  = {'kappa','rbar','sigma','lambda','r0','tauMax'};
    titles = {'kappa','rbar','sigma','lambda','r_0 list (space-separated)','Max maturity (years)'};
    xpos   = [0.16 0.25 0.34 0.43 0.52 0.75];
    wid    = [0.08 0.08 0.08 0.08 0.22 0.10];
    cols   = [0 0.447 0.741; 0.85 0.325 0.098; 0.929 0.694 0.125; 0.494 0.184 0.556; 0.466 0.674 0.188];

    fig = figure('Position', [100 100 1000 700], 'Name', 'Vasicek yield curves');
    bg  = get(fig, 'Color');

    uicontrol(fig, 'Style', 'text', 'String', 'Parameter set', 'Units', 'normalized', ...
        'Position', [0.01 0.945 0.14 0.03], 'BackgroundColor', bg);
    pop = uicontrol(fig, 'Style', 'popupmenu', 'String', {'Slides','Estimated from data'}, ...
        'Units', 'normalized', 'Position', [0.01 0.90 0.14 0.045], 'Callback', @(~,~) setValues());

    ed = struct();
    for i = 1:numel(names)
        uicontrol(fig, 'Style', 'text', 'String', titles{i}, 'Units', 'normalized', ...
            'Position', [xpos(i) 0.945 wid(i) 0.03], 'BackgroundColor', bg);
        ed.(names{i}) = uicontrol(fig, 'Style', 'edit', 'Units', 'normalized', ...
            'Position', [xpos(i) 0.90 wid(i) 0.045], 'Callback', @(~,~) draw());
    end
    uicontrol(fig, 'Style', 'pushbutton', 'String', 'Reset', 'Units', 'normalized', ...
        'Position', [0.87 0.90 0.11 0.045], 'Callback', @(~,~) setValues());

    ax = axes(fig, 'Position', [0.08 0.08 0.88 0.72]);
    setValues();

    function setValues()
        if pop.Value == 1, P = slide; else, P = est; end
        for j = 1:numel(names)
            v = P.(names{j});
            if ischar(v), ed.(names{j}).String = strtrim(v); else, ed.(names{j}).String = num2str(v, 6); end
        end
        draw();
    end

    function draw()
        kp = str2double(ed.kappa.String);   rb = str2double(ed.rbar.String);
        sg = str2double(ed.sigma.String);   lm = str2double(ed.lambda.String);
        tM = str2double(ed.tauMax.String);  r0 = str2num(ed.r0.String); %#ok<ST2NM>
        if any(isnan([kp rb sg lm tM])) || isempty(r0) || kp <= 0 || sg < 0 || tM <= 0
            title(ax, 'Invalid input');  return;
        end
        th   = rb - lm*sg/kp;                        % Q-measure long-run mean
        rInf = th - sg^2/(2*kp^2);                   % asymptotic spot rate
        tg   = linspace(0.01, tM, 300);
        B = (1 - exp(-kp*tg)) / kp;
        A = (th - sg^2/(2*kp^2)) * (B - tg) - sg^2 * B.^2 / (4*kp);

        cla(ax); hold(ax, 'on'); grid(ax, 'on');
        for j = 1:numel(r0)
            R = (r0(j)*B - A) ./ tg;                 % yield curve for initial short rate r0(j)
            plot(ax, tg, R, 'Color', cols(mod(j-1,5)+1,:), 'LineWidth', 2);
        end
        plot(ax, [0 tM], [rInf rInf], 'k--', 'LineWidth', 1.2);
        xlim(ax, [0 tM]);
        xlabel(ax, 'Time to maturity (years)');
        ylabel(ax, 'Yield curve predicted by Vasicek model');
        leg = arrayfun(@(v) sprintf('r_0 = %.4g', v), r0, 'UniformOutput', false);
        legend(ax, [leg, {sprintf('r_\\infty = %.2f%%', 100*rInf)}], 'Location', 'best');
        title(ax, sprintf('theta = %.3f%%,   r_\\infty = %.2f%%', 100*th, 100*rInf));
    end
end
