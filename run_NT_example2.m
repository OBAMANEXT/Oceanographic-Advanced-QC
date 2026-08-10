%% ============================================================
% Neighbor Test (NT) - Reproducible MATLAB example
%
% Example application:
% FerryBox salinity vs E1-M3A near-surface salinity
%
% Platform A = FerryBox target observations
% Platform B = E1-M3A neighboring observations
%
% This implementation follows the point-to-point collocation
% methodology used in the associated study.
%
% IMPORTANT:
%
% Spatial radius:
%   specified in degrees for presentation
%   converted to km using:
%
%       radius_km = 111 * radius_deg
%
% Temporal window:
%   TW values represent FULL temporal-window widths.
%
% Therefore:
%
%       TW = 60 h
%
% corresponds to:
%
%       +/- 30 h
%
% Difference convention:
%
%       DeltaS = FerryBox - E1-M3A
%
% No observations are averaged during point-to-point
% collocation.
%
% ============================================================

clear
close all
clc

addpath('functions')


%% ============================================================
% 1. LOAD EXAMPLE DATA
% ============================================================

D = load(fullfile('example_data','NT_example_data.mat'));


%% Platform A: FerryBox

timeA = D.timeA(:);
lonA  = D.lonA(:);
latA  = D.latA(:);
varA  = D.varA(:);


%% Platform B: E1-M3A

timeB = D.timeB(:);
lonB  = D.lonB(:);
latB  = D.latB(:);
varB  = D.varB(:);


%% ============================================================
% 2. CONVERT TIME TO DATETIME IF NECESSARY
% ============================================================

if isnumeric(timeA)

    timeA = datetime( ...
        timeA, ...
        'ConvertFrom','datenum');

elseif ~isdatetime(timeA)

    error('Unsupported time format for Platform A.')

end


if isnumeric(timeB)

    timeB = datetime( ...
        timeB, ...
        'ConvertFrom','datenum');

elseif ~isdatetime(timeB)

    error('Unsupported time format for Platform B.')

end


%% ============================================================
% 3. BASIC DATA CHECKS
% ============================================================

assert( ...
    numel(timeA)==numel(lonA) && ...
    numel(timeA)==numel(latA) && ...
    numel(timeA)==numel(varA), ...
    'Platform A variables must have equal lengths.')


assert( ...
    numel(timeB)==numel(lonB) && ...
    numel(timeB)==numel(latB) && ...
    numel(timeB)==numel(varB), ...
    'Platform B variables must have equal lengths.')


%% Remove invalid Platform-A observations

goodA = ...
    ~isnat(timeA) & ...
    isfinite(lonA) & ...
    isfinite(latA) & ...
    isfinite(varA);

timeA = timeA(goodA);
lonA  = lonA(goodA);
latA  = latA(goodA);
varA  = varA(goodA);


%% Remove invalid Platform-B observations

goodB = ...
    ~isnat(timeB) & ...
    isfinite(lonB) & ...
    isfinite(latB) & ...
    isfinite(varB);

timeB = timeB(goodB);
lonB  = lonB(goodB);
latB  = latB(goodB);
varB  = varB(goodB);


%% Sort chronologically

[timeA,IA] = sort(timeA);

lonA = lonA(IA);
latA = latA(IA);
varA = varA(IA);


[timeB,IB] = sort(timeB);

lonB = lonB(IB);
latB = latB(IB);
varB = varB(IB);


%% ============================================================
% Display dataset information
% ============================================================

fprintf('\n=============================================\n')
fprintf('Neighbor Test example dataset\n')
fprintf('=============================================\n')

fprintf('\nPlatform A: FerryBox\n')
fprintf('Observations : %d\n',numel(varA))
fprintf('Period       : %s to %s\n', ...
    string(min(timeA)), ...
    string(max(timeA)))


fprintf('\nPlatform B: E1-M3A\n')
fprintf('Observations : %d\n',numel(varB))
fprintf('Period       : %s to %s\n', ...
    string(min(timeB)), ...
    string(max(timeB)))


%% ============================================================
% 4. COLLOCATION-SENSITIVITY SETTINGS
% ============================================================
%
% These correspond to the point-observation candidate values
% used in the study.
%
% Spatial radii are shown in degrees but converted to km.
%
% Temporal-window values represent FULL widths.
%
% Example:
%
%       TW = 60 h -> +/-30 h
%
% ============================================================
%% Candidate spatial radii
% Reduced range for the compact GitHub example.
% The selected criterion used in the study (0.2 deg) is retained.

radiusDeg = [0.2 0.3 0.4 0.5 0.6];

radiusKm = 111 .* radiusDeg;

%% Candidate temporal-window widths
% TW represents the FULL temporal width.
% Thus, TW = 60 h corresponds to +/-30 h.

timeWindowHours = [3 6 12 24 36 48 60 72 84];

nR = numel(radiusDeg);
nT = numel(timeWindowHours);


%% Preallocate sensitivity matrices

RMSD   = NaN(nR,nT);
BIAS   = NaN(nR,nT);
CORR   = NaN(nR,nT);
Nmatch = zeros(nR,nT);


%% ============================================================
% 5. COLLOCATION-SENSITIVITY ANALYSIS
% ============================================================

fprintf('\n=============================================\n')
fprintf('Running collocation-sensitivity analysis\n')
fprintf('=============================================\n')


for ir = 1:nR

    for it = 1:nT

        radiusNow_km = ...
            radiusKm(ir);

        timeNow_hr = ...
            timeWindowHours(it);


        [Acol,Bcol] = nt_find_matchups( ...
            timeA,lonA,latA,varA, ...
            timeB,lonB,latB,varB, ...
            radiusNow_km,timeNow_hr);


        if numel(Acol) >= 2

            stats = ...
                nt_calculate_metrics(Acol,Bcol);

            RMSD(ir,it)   = stats.RMSD;
            BIAS(ir,it)   = stats.Bias;
            CORR(ir,it)   = stats.R;
            Nmatch(ir,it) = stats.N;

        end


        fprintf( ...
            ['R = %.1f deg (%.1f km), ' ...
             'TW = %3d h full width (+/-%.1f h): N = %d\n'], ...
            radiusDeg(ir), ...
            radiusNow_km, ...
            timeNow_hr, ...
            timeNow_hr/2, ...
            Nmatch(ir,it))

    end

end


%% ============================================================
% 6. SELECT FINAL COLLOCATION CRITERIA
% ============================================================
%
% Final FerryBox-E1-M3A salinity criteria used in the study:
%
% Spatial radius:
%       0.20 degrees
%
% Temporal window:
%       60 h FULL width
%
% Therefore actual permitted temporal separation:
%
%       +/-30 h
%
% ============================================================

R_selected_deg = 0.20;

R_selected_km = ...
    111 * R_selected_deg;


TW_selected = 60;      % FULL temporal-window width, hours

TW_half = ...
    TW_selected / 2;


fprintf('\n=============================================\n')
fprintf('Selected collocation criteria\n')
fprintf('=============================================\n')

fprintf('Spatial radius       : %.2f degrees\n', ...
    R_selected_deg)

fprintf('Spatial radius       : %.2f km\n', ...
    R_selected_km)

fprintf('Full temporal window : %.0f hours\n', ...
    TW_selected)

fprintf('Temporal half-window : +/- %.0f hours\n', ...
    TW_half)


%% ============================================================
% 7. PLOT COLLOCATION SENSITIVITY
% ============================================================
%
% The plotting function can still display radius in degrees,
% which is easier to compare with the study.

nt_plot_sensitivity( ...
    RMSD, ...
    BIAS, ...
    Nmatch, ...
    radiusDeg, ...
    timeWindowHours, ...
    R_selected_deg, ...
    TW_selected)


%% ============================================================
% 8. GENERATE FINAL MATCHUPS
% ============================================================

[Acol,Bcol,matchInfo] = nt_find_matchups( ...
    timeA,lonA,latA,varA, ...
    timeB,lonB,latB,varB, ...
    R_selected_km,TW_selected);


%% ============================================================
% 9. CALCULATE FINAL MATCHUP STATISTICS
% ============================================================

statsSelected = ...
    nt_calculate_metrics(Acol,Bcol);


fprintf('\n=============================================\n')
fprintf('Final matchup statistics\n')
fprintf('=============================================\n')

fprintf('N matchups  : %d\n', ...
    statsSelected.N)

fprintf('RMSD        : %.4f\n', ...
    statsSelected.RMSD)

fprintf('Bias        : %.4f\n', ...
    statsSelected.Bias)

fprintf('Correlation : %.4f\n', ...
    statsSelected.R)

fprintf('MAE         : %.4f\n', ...
    statsSelected.MAE)


%% ============================================================
% 10. ACTUAL TEMPORAL SEPARATION
% ============================================================

fprintf('\nActual temporal separation of selected matchups:\n')

fprintf('Minimum : %.2f h\n', ...
    min(matchInfo.timeDifference_h))

fprintf('Mean    : %.2f h\n', ...
    mean(matchInfo.timeDifference_h,'omitnan'))

fprintf('Median  : %.2f h\n', ...
    median(matchInfo.timeDifference_h,'omitnan'))

fprintf('Maximum : %.2f h\n', ...
    max(matchInfo.timeDifference_h))


%% ============================================================
% 11. ACTUAL SPATIAL SEPARATION
% ============================================================

fprintf('\nActual spatial separation of selected matchups:\n')

fprintf('Minimum : %.2f km\n', ...
    min(matchInfo.distance_km))

fprintf('Mean    : %.2f km\n', ...
    mean(matchInfo.distance_km,'omitnan'))

fprintf('Median  : %.2f km\n', ...
    median(matchInfo.distance_km,'omitnan'))

fprintf('Maximum : %.2f km\n', ...
    max(matchInfo.distance_km))


%% ============================================================
% 12. APPLY NEIGHBOR TEST THRESHOLD
% ============================================================
%
% Salinity NT threshold:
%
%       |DeltaS| <= 0.20
%
% Difference:
%
%       DeltaS = FerryBox - E1-M3A
%
% ============================================================

salinity_SD = 0.20;                 % psu
NT_threshold = 2 * salinity_SD;     % psu

NT = nt_apply_threshold( ...
    Acol,Bcol,NT_threshold);


fprintf('\n=============================================\n')
fprintf('Neighbor Test results\n')
fprintf('=============================================\n')

fprintf('Threshold          : +/- %.2f\n', ...
    NT_threshold)

fprintf('Within threshold   : %d (%.2f %%)\n', ...
    NT.Ngood, ...
    NT.PercentGood)

fprintf('Outside threshold  : %d (%.2f %%)\n', ...
    NT.Nsuspect, ...
    NT.PercentSuspect)


%% ============================================================
% 13. DELTA-S TIME SERIES
% ============================================================

figure( ...
    'Color','w', ...
    'Position',[100 100 1100 600])

hold on


%% Within threshold

h1 = plot( ...
    matchInfo.targetTime(NT.Good), ...
    NT.Difference(NT.Good), ...
    'ko', ...
    'MarkerFaceColor','k', ...
    'MarkerSize',4);


%% Outside threshold

h2 = plot( ...
    matchInfo.targetTime(NT.Suspect), ...
    NT.Difference(NT.Suspect), ...
    'ro', ...
    'MarkerFaceColor','r', ...
    'MarkerSize',6);


%% Reference lines

h3 = yline( ...
    0,'k-', ...
    'LineWidth',1);


h4 = yline( ...
    NT_threshold,'r--', ...
    'LineWidth',1.5);


yline( ...
    -NT_threshold,'r--', ...
    'LineWidth',1.5);


xlabel('Time')

ylabel('\DeltaS = FerryBox - E1-M3A')


title(sprintf( ...
    ['Neighbor Test: R = %.2f^\\circ, ' ...
     'TW = %.0f h full width (\\pm%.0f h)'], ...
    R_selected_deg, ...
    TW_selected, ...
    TW_half))


grid on
box on


legend( ...
    [h1 h2 h3 h4], ...
    {'Within threshold', ...
     'Outside threshold', ...
     'Zero difference', ...
     'NT threshold'}, ...
    'Location','best')


text( ...
    0.02,0.96, ...
    sprintf( ...
    ['Within threshold: %.1f%%\n' ...
     'Outside threshold: %.1f%%'], ...
    NT.PercentGood, ...
    NT.PercentSuspect), ...
    'Units','normalized', ...
    'VerticalAlignment','top', ...
    'BackgroundColor','w')


%% ============================================================
% 14. FERRYBOX VS E1-M3A SCATTERPLOT
% ============================================================

figure( ...
    'Color','w', ...
    'Position',[150 100 700 650])


scatter( ...
    Acol,Bcol, ...
    25,'k','filled')

hold on


lims = [ ...
    min([Acol(:);Bcol(:)]), ...
    max([Acol(:);Bcol(:)])];


plot( ...
    lims,lims, ...
    'k--', ...
    'LineWidth',1.2)


xlim(lims)
ylim(lims)

xlabel('FerryBox salinity')
ylabel('E1-M3A salinity')

title(sprintf( ...
    'Final NT matchups, N = %d', ...
    statsSelected.N))

grid on
box on
axis square


%% ============================================================
% 15. CREATE FINAL MATCHUP TABLE
% ============================================================

NTtable = matchInfo;

NTtable.FerryBoxSalinity = Acol;
NTtable.M3ASalinity      = Bcol;
NTtable.DeltaS           = NT.Difference;
NTtable.NTflag           = NT.Flag;


fprintf('\nFirst 10 matchups:\n')

disp( ...
    NTtable( ...
    1:min(10,height(NTtable)),:))


%% ============================================================
% 16. SAVE RESULTS
% ============================================================

if ~exist('output','dir')

    mkdir('output')

end


save( ...
    fullfile('output','NT_example_results.mat'), ...
    'RMSD', ...
    'BIAS', ...
    'CORR', ...
    'Nmatch', ...
    'radiusDeg', ...
    'radiusKm', ...
    'timeWindowHours', ...
    'R_selected_deg', ...
    'R_selected_km', ...
    'TW_selected', ...
    'TW_half', ...
    'NT_threshold', ...
    'statsSelected', ...
    'NT', ...
    'NTtable')


fprintf('\n=============================================\n')
fprintf('NT example completed successfully.\n')
fprintf('Results saved in:\n')
fprintf('output/NT_example_results.mat\n')
fprintf('=============================================\n')