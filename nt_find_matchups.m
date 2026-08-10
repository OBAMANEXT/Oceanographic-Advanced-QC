function [Acol,Bcol,matchInfo] = nt_find_matchups( ...
    timeA,lonA,latA,varA, ...
    timeB,lonB,latB,varB, ...
    radiusKm,timeWindowFullHours)

% NT_FIND_MATCHUPS
%
% Point-to-point spatial-temporal collocation for the
% Neighbor Test.
%
% This implementation follows the point-to-point collocation
% logic used in the associated study.
%
%
% Platform A
% ----------
% Target/source observations.
%
%
% Platform B
% ----------
% Neighboring/reference observations.
%
%
% MATCHUP PROCEDURE
% -----------------
%
% For each valid Platform-A observation:
%
%   1. Calculate its geographical distance to every valid
%      Platform-B observation using the Haversine formula.
%
%   2. Identify all Platform-B observations located within
%      the prescribed spatial radius.
%
%   3. Among those spatially eligible observations, identify
%      the observation with the smallest absolute temporal
%      separation.
%
%   4. Retain that observation only if its temporal separation
%      is <= half of the specified FULL temporal-window width.
%
% No temporal or spatial averaging is performed.
%
%
% IMPORTANT
% ---------
%
% timeWindowFullHours is the FULL temporal-window width.
%
% For example:
%
%       timeWindowFullHours = 60
%
% means:
%
%       permitted temporal separation = +/-30 h
%
%
% INPUTS
% ------
%
% timeA, timeB
%       MATLAB datetime arrays
%
% lonA, latA
%       Platform-A longitude and latitude in decimal degrees
%
% lonB, latB
%       Platform-B longitude and latitude in decimal degrees
%
% varA, varB
%       Observed variable
%
% radiusKm
%       Spatial collocation radius in km
%
% timeWindowFullHours
%       FULL temporal-window width in hours
%
%
% OUTPUTS
% -------
%
% Acol
%       Collocated Platform-A values
%
% Bcol
%       Collocated Platform-B values
%
% matchInfo
%       Table describing each retained matchup
%
% ============================================================


%% ============================================================
% Input checks
% ============================================================

if ~isscalar(radiusKm) || ...
   ~isfinite(radiusKm) || ...
   radiusKm <= 0

    error('radiusKm must be a positive finite scalar.')

end


if ~isscalar(timeWindowFullHours) || ...
   ~isfinite(timeWindowFullHours) || ...
   timeWindowFullHours <= 0

    error(['timeWindowFullHours must be a ' ...
           'positive finite scalar.'])

end


%% ============================================================
% Ensure column vectors
% ============================================================

timeA = timeA(:);
lonA  = lonA(:);
latA  = latA(:);
varA  = varA(:);

timeB = timeB(:);
lonB  = lonB(:);
latB  = latB(:);
varB  = varB(:);


%% ============================================================
% Require datetime
% ============================================================

if ~isdatetime(timeA) || ~isdatetime(timeB)

    error([ ...
        'timeA and timeB must be MATLAB datetime arrays. ' ...
        'Convert numeric datenums before calling ' ...
        'nt_find_matchups.'])

end


%% ============================================================
% Remove invalid Platform-B observations
% ============================================================

goodB = ...
    ~isnat(timeB) & ...
    isfinite(lonB) & ...
    isfinite(latB) & ...
    isfinite(varB);

timeB = timeB(goodB);
lonB  = lonB(goodB);
latB  = latB(goodB);
varB  = varB(goodB);


%% ============================================================
% Half temporal window
% ============================================================

halfWindowHours = ...
    timeWindowFullHours / 2;


%% ============================================================
% Preallocate
% ============================================================

nA = numel(timeA);

Atemp = NaN(nA,1);
Btemp = NaN(nA,1);

targetTime   = NaT(nA,1);
neighborTime = NaT(nA,1);

targetLon = NaN(nA,1);
targetLat = NaN(nA,1);

neighborLon = NaN(nA,1);
neighborLat = NaN(nA,1);

timeDifference_h = NaN(nA,1);
distance_km      = NaN(nA,1);

nSpatialCandidates = zeros(nA,1);

keep = false(nA,1);


%% ============================================================
% Loop through Platform-A observations
% ============================================================

for i = 1:nA


    %% Skip invalid target observation

    if ...
        isnat(timeA(i)) || ...
        ~isfinite(lonA(i)) || ...
        ~isfinite(latA(i)) || ...
        ~isfinite(varA(i))

        continue

    end


    %% ========================================================
    % 1. SPATIAL DISTANCE TO ALL PLATFORM-B OBSERVATIONS
    % =========================================================

    dkm = haversine_km_local( ...
        latA(i), ...
        lonA(i), ...
        latB, ...
        lonB);


    %% ========================================================
    % 2. FIND OBSERVATIONS INSIDE SPATIAL RADIUS
    % =========================================================

    idxSpatial = ...
        find(dkm <= radiusKm);


    if isempty(idxSpatial)

        continue

    end


    nSpatialCandidates(i) = ...
        numel(idxSpatial);


    %% ========================================================
    % 3. FIND NEAREST-IN-TIME SPATIALLY ELIGIBLE OBSERVATION
    % =========================================================

    dtHours = abs( ...
        hours( ...
        timeB(idxSpatial) - timeA(i)));


    [dmin,j] = ...
        min(dtHours);


    %% ========================================================
    % 4. APPLY TEMPORAL CRITERION
    % =========================================================
    %
    % The supplied TW is a FULL temporal-window width.
    %
    % Thus:
    %
    %       dmin <= TW/2
    %
    % reproduces the original methodology.

    if dmin > halfWindowHours

        continue

    end


    %% Index of selected neighboring observation

    k = idxSpatial(j);


    %% ========================================================
    % Store retained pair
    % =========================================================

    keep(i) = true;


    %% Values

    Atemp(i) = varA(i);
    Btemp(i) = varB(k);


    %% Times

    targetTime(i) = ...
        timeA(i);

    neighborTime(i) = ...
        timeB(k);


    %% Coordinates

    targetLon(i) = ...
        lonA(i);

    targetLat(i) = ...
        latA(i);

    neighborLon(i) = ...
        lonB(k);

    neighborLat(i) = ...
        latB(k);


    %% Actual separations

    timeDifference_h(i) = ...
        dmin;

    distance_km(i) = ...
        dkm(k);

end


%% ============================================================
% Retain successful matchups
% ============================================================

Acol = ...
    Atemp(keep);

Bcol = ...
    Btemp(keep);


targetTime = ...
    targetTime(keep);

neighborTime = ...
    neighborTime(keep);


targetLon = ...
    targetLon(keep);

targetLat = ...
    targetLat(keep);


neighborLon = ...
    neighborLon(keep);

neighborLat = ...
    neighborLat(keep);


timeDifference_h = ...
    timeDifference_h(keep);

distance_km = ...
    distance_km(keep);

nSpatialCandidates = ...
    nSpatialCandidates(keep);


%% ============================================================
% Create matchup-information table
% ============================================================

matchInfo = table( ...
    targetTime, ...
    neighborTime, ...
    targetLon, ...
    targetLat, ...
    neighborLon, ...
    neighborLat, ...
    timeDifference_h, ...
    distance_km, ...
    nSpatialCandidates, ...
    'VariableNames', ...
    {'targetTime', ...
     'neighborTime', ...
     'targetLon', ...
     'targetLat', ...
     'neighborLon', ...
     'neighborLat', ...
     'timeDifference_h', ...
     'distance_km', ...
     'nSpatialCandidates'});

end

