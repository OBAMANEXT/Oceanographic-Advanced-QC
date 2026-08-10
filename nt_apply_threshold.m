function NT = nt_apply_threshold(A,B,threshold)

% NT_APPLY_THRESHOLD
%
% Applies a fixed Neighbor Test threshold to collocated
% observations.
%
% Difference convention:
%
%       Difference = Target - Neighbor
%
% A matchup is considered within the NT criterion when:
%
%       abs(Target - Neighbor) <= threshold
%
%
% FLAG CONVENTION
%
%   1 = within NT threshold
%   3 = outside NT threshold / suspect
%
%
% OUTPUT
%
% NT.Difference
% NT.Valid
% NT.Good
% NT.Suspect
% NT.Flag
% NT.N
% NT.Ngood
% NT.Nsuspect
% NT.PercentGood
% NT.PercentSuspect
% NT.Threshold
%
% ------------------------------------------------------------


%% Check threshold

if ...
    ~isscalar(threshold) || ...
    ~isfinite(threshold) || ...
    threshold <= 0

    error('NT threshold must be a positive finite scalar.')

end


%% Ensure column vectors

A = A(:);
B = B(:);


%% Difference

D = A-B;


%% Valid observations

valid = ...
    isfinite(A) & ...
    isfinite(B);


%% ============================================================
% Apply NT criterion
% ============================================================

good = ...
    valid & ...
    abs(D) <= threshold;


suspect = ...
    valid & ...
    abs(D) > threshold;


%% ============================================================
% QC flags
% ============================================================

flag = NaN(size(D));

flag(good)    = 1;
flag(suspect) = 3;


%% ============================================================
% Counts
% ============================================================

N = sum(valid);

Ngood = sum(good);

Nsuspect = sum(suspect);


%% Percentages

if N > 0

    percentGood = ...
        100*Ngood/N;

    percentSuspect = ...
        100*Nsuspect/N;

else

    percentGood = NaN;
    percentSuspect = NaN;

end


%% ============================================================
% Output
% ============================================================

NT.Difference = D;

NT.Valid   = valid;
NT.Good    = good;
NT.Suspect = suspect;

NT.Flag = flag;

NT.N        = N;
NT.Ngood    = Ngood;
NT.Nsuspect = Nsuspect;

NT.PercentGood    = percentGood;
NT.PercentSuspect = percentSuspect;

NT.Threshold = threshold;

end