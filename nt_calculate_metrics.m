function stats = nt_calculate_metrics(A,B)

% NT_CALCULATE_METRICS
%
% Calculates statistics for collocated Neighbor Test
% observations.
%
% Difference convention:
%
%       Difference = Target - Neighbor
%
%
% OUTPUT
%
% stats.N
% stats.Bias
% stats.RMSD
% stats.R
% stats.MAE
% stats.SD_difference
% stats.Difference
%
% ------------------------------------------------------------


%% Ensure column vectors

A = A(:);
B = B(:);


%% Keep valid pairs

good = ...
    isfinite(A) & ...
    isfinite(B);

A = A(good);
B = B(good);


%% Difference

D = A-B;


%% Number of matchups

stats.N = numel(D);


%% Handle empty input

if isempty(D)

    stats.Bias          = NaN;
    stats.RMSD          = NaN;
    stats.R             = NaN;
    stats.MAE           = NaN;
    stats.SD_difference = NaN;
    stats.Difference    = [];

    return

end


%% ============================================================
% Statistics
% ============================================================

stats.Bias = ...
    mean(D,'omitnan');


stats.RMSD = ...
    sqrt(mean(D.^2,'omitnan'));


stats.MAE = ...
    mean(abs(D),'omitnan');


stats.SD_difference = ...
    std(D,'omitnan');


%% Correlation

if numel(D) >= 3

    C = corrcoef( ...
        A,B, ...
        'Rows','complete');

    stats.R = C(1,2);

else

    stats.R = NaN;

end


%% Store differences

stats.Difference = D;

end