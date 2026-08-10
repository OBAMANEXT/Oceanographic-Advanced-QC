%% ============================================================
% Prepare FerryBox - E1-M3A dataset for GitHub NT example
%
% Example variable:
% Salinity
%
% Platform A = FerryBox target observations
% Platform B = E1-M3A neighboring observations
%
% Input files:
%   FB_NT_example.mat
%   M3A_NT_example.mat
%
% Output:
%   example_data/NT_example_data.mat
%
% The output file contains ONLY the generic variables:
%
%   timeA lonA latA varA
%   timeB lonB latB varB
%
% This keeps the subsequent NT analysis platform-independent.
% ============================================================

clear
close all
clc


%% ============================================================
% 1. USER SETTINGS
% ============================================================

% E1-M3A fixed position
M3A_lon = 25.1307;
M3A_lat = 35.7263;

% Broad geographical extraction radius around E1-M3A.
%
% IMPORTANT:
% This is NOT the final NT collocation radius.
% It is only used to make the public example dataset smaller
% while retaining all observations needed for testing radii
% up to 0.5 degrees.
maxExampleRadius = 0.6;


%% ============================================================
% 2. LOAD FERRYBOX DATA
% ============================================================

FB = load('FB_NT_example.mat');

timeA = FB.timeFB_1(:);
lonA  = FB.lonFB_1(:);
latA  = FB.latFB_1(:);
varA  = FB.salFB_1(:);


fprintf('\n=============================================\n')
fprintf('Original FerryBox dataset\n')
fprintf('=============================================\n')
fprintf('Time       : %d\n',numel(timeA))
fprintf('Longitude  : %d\n',numel(lonA))
fprintf('Latitude   : %d\n',numel(latA))
fprintf('Salinity   : %d\n',numel(varA))


%% Check equal lengths

assert(numel(timeA)==numel(lonA) && ...
       numel(timeA)==numel(latA) && ...
       numel(timeA)==numel(varA), ...
       'FerryBox variables must have equal lengths.')


%% ============================================================
% 3. LOAD E1-M3A DATA
% ============================================================

M3A = load('M3A_NT_example.mat');

timeB = M3A.time_M3A_1(:);
lonB  = M3A.lon_M3A_1(:);
latB  = M3A.lat_M3A_1(:);
varB  = M3A.S001_1(:);


fprintf('\n=============================================\n')
fprintf('Original E1-M3A dataset\n')
fprintf('=============================================\n')
fprintf('Time       : %d\n',numel(timeB))
fprintf('Longitude  : %d\n',numel(lonB))
fprintf('Latitude   : %d\n',numel(latB))
fprintf('Salinity   : %d\n',numel(varB))


%% Check equal lengths

assert(numel(timeB)==numel(lonB) && ...
       numel(timeB)==numel(latB) && ...
       numel(timeB)==numel(varB), ...
       'E1-M3A variables must have equal lengths.')


%% ============================================================
% 4. BASIC QUALITY SCREENING
% ============================================================
%% ============================================================
% 4. BASIC QUALITY SCREENING
% ============================================================

% FerryBox
goodA = ...
    isfinite(timeA) & ...
    isfinite(lonA) & ...
    isfinite(latA) & ...
    isfinite(varA);

timeA = timeA(goodA);
lonA  = lonA(goodA);
latA  = latA(goodA);
varA  = varA(goodA);


% E1-M3A
goodB = ...
    isfinite(timeB) & ...
    isfinite(lonB) & ...
    isfinite(latB) & ...
    isfinite(varB);

timeB = timeB(goodB);
lonB  = lonB(goodB);
latB  = latB(goodB);
varB  = varB(goodB);


fprintf('\nAfter removal of invalid observations:\n')
fprintf('FerryBox : %d\n',numel(varA))
fprintf('E1-M3A   : %d\n',numel(varB))


%% ============================================================
% 5. DETERMINE COMMON TEMPORAL PERIOD
% ============================================================

commonStart = max(min(timeA),min(timeB));
commonEnd   = min(max(timeA),max(timeB));


if commonStart > commonEnd
    error('FerryBox and E1-M3A have no overlapping time period.')
end


fprintf('\nCommon temporal period:\n')
fprintf('%s to %s\n', ...
    string(commonStart),string(commonEnd))


%% Keep only observations within common period

idxA = timeA >= commonStart & ...
       timeA <= commonEnd;

timeA = timeA(idxA);
lonA  = lonA(idxA);
latA  = latA(idxA);
varA  = varA(idxA);


idxB = timeB >= commonStart & ...
       timeB <= commonEnd;

timeB = timeB(idxB);
lonB  = lonB(idxB);
latB  = latB(idxB);
varB  = varB(idxB);


fprintf('\nObservations within common period:\n')
fprintf('FerryBox : %d\n',numel(varA))
fprintf('E1-M3A   : %d\n',numel(varB))


%% ============================================================
% 6. BROAD GEOGRAPHICAL EXTRACTION OF FERRYBOX
% ============================================================
%
% Keep only FerryBox observations within 0.6 degrees of E1-M3A.
%
% This DOES NOT perform the Neighbor Test collocation.
%
% It simply removes FerryBox observations that could never
% contribute to the sensitivity analysis, where the largest
% tested NT radius will be 0.5 degrees.
%
% Longitude distance is corrected for latitude.

dlon = (lonA-M3A_lon).*cosd(M3A_lat);
dlat = latA-M3A_lat;

distanceFromM3A_deg = sqrt(dlon.^2 + dlat.^2);


idxA = distanceFromM3A_deg <= maxExampleRadius;

timeA = timeA(idxA);
lonA  = lonA(idxA);
latA  = latA(idxA);
varA  = varA(idxA);


fprintf('\nAfter broad %.1f-degree spatial extraction:\n', ...
    maxExampleRadius)

fprintf('FerryBox observations : %d\n',numel(varA))


%% ============================================================
% 7. SORT DATA CHRONOLOGICALLY
% ============================================================

[timeA,IA] = sort(timeA);

lonA = lonA(IA);
latA = latA(IA);
varA = varA(IA);


[timeB,IB] = sort(timeB);

lonB = lonB(IB);
latB = latB(IB);
varB = varB(IB);


%% ============================================================
% 8. FINAL DATASET INFORMATION
% ============================================================

fprintf('\n=============================================\n')
fprintf('Final NT GitHub example dataset\n')
fprintf('=============================================\n')

fprintf('\nPlatform A: FerryBox\n')
fprintf('Observations : %d\n',numel(varA))

if ~isempty(timeA)
    fprintf('Period       : %s to %s\n', ...
        string(min(timeA)),string(max(timeA)))
end


fprintf('\nPlatform B: E1-M3A\n')
fprintf('Observations : %d\n',numel(varB))

if ~isempty(timeB)
    fprintf('Period       : %s to %s\n', ...
        string(min(timeB)),string(max(timeB)))
end


%% ============================================================
% 9. FINAL SAFETY CHECK
% ============================================================

assert(~isempty(varA), ...
    'No FerryBox observations remain after filtering.')

assert(~isempty(varB), ...
    'No E1-M3A observations remain after filtering.')

%% Convert MATLAB serial datenums to datetime

if isnumeric(timeA)
    timeA = datetime(timeA,'ConvertFrom','datenum');
end

if isnumeric(timeB)
    timeB = datetime(timeB,'ConvertFrom','datenum');
end
%% ============================================================
% 10. SAVE GENERIC PUBLIC DATASET
% ============================================================

if ~exist('example_data','dir')
    mkdir('example_data')
end


save(fullfile('example_data','NT_example_data.mat'), ...
    'timeA','lonA','latA','varA', ...
    'timeB','lonB','latB','varB')


fprintf('\n=============================================\n')
fprintf('Dataset saved successfully:\n')
fprintf('example_data/NT_example_data.mat\n')
fprintf('=============================================\n')