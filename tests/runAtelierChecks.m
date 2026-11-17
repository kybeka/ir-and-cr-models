function runAtelierChecks
% Check the calculations, chart controls, and video export using the included data.
root = fileparts(fileparts(mfilename('fullpath')));
fprintf('MATLAB %s\n', version);
for source = ["GSW", "FRED"]
    for changes = [false, true]
        script = fullfile(root, 'atelier', '02-principal-component-analysis', 'YieldCurvePCA.m');
        code = fileread(script);
        code = strrep(code, "dataSource = 'GSW'", "dataSource = '" + source + "'");
        if changes
            code = strrep(code, 'useChanges = false', 'useChanges = true');
        end
        temporaryScript = [tempname(fileparts(script)), '.m'];
        cleanup = onCleanup(@() delete(temporaryScript));
        fid = fopen(temporaryScript, 'w');
        assert(fid >= 0, 'Could not create the temporary PCA variant.');
        fprintf(fid, '%s', code);
        fclose(fid);
        runInBase(temporaryScript);
        evalin('base', "assert(all(isfinite(Y),'all') && all(isfinite(Rhat),'all'));");
        evalin('base', "assert(norm(A'*A-eye(p),'fro') < 1e-10);");
        evalin('base', "assert(all(lam >= -1e-10) && abs(sum(expl)-1) < 1e-12);");
        evalin('base', "assert(norm(cov(Z)-diag(lam),'fro') < 1e-9);");
        evalin('base', "assert(norm(Z*A'+Rbar-Y,'fro') < 1e-9);");
        evalin('base', "assert(height(MonthlyData)==nObs && all(diff(dates)>0));");
        fprintf('PASS: PCA %s, useChanges=%d\n', source, changes);
        clear cleanup
    end
end

runInBase(fullfile(root, 'atelier', '03-vasicek-model', 'VasicekCalibration.m'));
evalin('base', "assert(all(isfinite(Yhat),'all') && all(isfinite(err),'all'));");
evalin('base', "assert(kappa>0 && sigma>0 && b>0 && b<1);");
evalin('base', "assert(all(diff(12*year(dates)+month(dates))==1));");
evalin('base', "assert(abs(Anum-Af(kappa,theta,sigma,Tchk)) < 1e-10);");
evalin('base', "assert(abs(theta-(rbar-lambda*sigma/kappa)) < 1e-12);");
fig = findall(groot, 'Type', 'figure', 'Name', 'Vasicek yield curves');
assert(isscalar(fig));
popup = findobj(fig, 'Style', 'popupmenu');
popup.Value = 2;
feval(popup.Callback, popup, []);
drawnow;
lines = findobj(fig, 'Type', 'line');
assert(numel(lines)==6);
for line = lines'
    assert(all(isfinite(line.YData)));
end
fprintf('PASS: Vasicek estimation, monthly alignment, bond formula, and estimated UI\n');

runInBase(fullfile(root, 'atelier', '01-yield-curves', 'InteractiveYieldCurve.m'));
fig = findall(groot, 'Type', 'figure', 'Name', 'US yield curve - interactive');
assert(isscalar(fig));
slider = findobj(fig, 'Style', 'slider');
for index = [slider.Min, round((slider.Min+slider.Max)/2), slider.Max]
    slider.Value = index;
    feval(slider.Callback, slider, []);
end
groups = findobj(fig, 'Type', 'uibuttongroup');
for group = groups'
    buttons = findobj(group, 'Style', 'togglebutton');
    for button = buttons'
        group.SelectedObject = button;
        feval(group.SelectionChangedFcn, group, []);
        drawnow;
    end
end
play = findobj(fig, 'String', 'Play');
slider.Value = 1;
stopper = timer('StartDelay', 0.6, 'TimerFcn', @(~,~) set(play, 'Value', 0));
timerCleanup = onCleanup(@() delete(stopper));
play.Value = 1;
start(stopper);
feval(play.Callback, play, []);
assert(slider.Value>1 && play.Value==0);
clear timerCleanup
saveButton = findobj(fig, 'String', 'Save MP4');
feval(saveButton.Callback, saveButton, []);
videoFile = fullfile(root, 'results', 'generated', 'yield-curves', 'yield_curve.mp4');
video = VideoReader(videoFile);
assert(video.Duration>0 && video.Width>0 && video.Height>0);
assert(abs(video.Duration-slider.Max/15)<0.2);
fprintf('PASS: yield curve slider, axis modes, playback, and full MP4 export\n');
close all;
fprintf('ALL ATELIER CHECKS PASSED\n');
end

function runInBase(script)
escaped = strrep(script, '''', '''''');
evalin('base', ['run(''', escaped, ''');']);
end
