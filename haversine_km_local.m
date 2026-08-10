function dkm = haversine_km_local( ...
    lat1,lon1,lat2,lon2)

% HAVERSINE_KM_LOCAL
%
% Great-circle distance between one point (lat1,lon1)
% and one or more points (lat2,lon2).
%
% Inputs are in decimal degrees.
% Output is in kilometres.


%% Earth mean radius

R = 6371.0088;


%% Convert degrees to radians

lat1r = deg2rad(lat1);
lon1r = deg2rad(lon1);

lat2r = deg2rad(lat2);
lon2r = deg2rad(lon2);


%% Coordinate differences

dlat = ...
    lat2r-lat1r;

dlon = ...
    lon2r-lon1r;


%% Haversine formula

a = ...
    sin(dlat./2).^2 + ...
    cos(lat1r).*cos(lat2r).* ...
    sin(dlon./2).^2;


% Protect against tiny numerical values > 1
a = min(1,max(0,a));


c = ...
    2 .* atan2( ...
    sqrt(a), ...
    sqrt(1-a));


%% Distance in km

dkm = ...
    R .* c;

end

