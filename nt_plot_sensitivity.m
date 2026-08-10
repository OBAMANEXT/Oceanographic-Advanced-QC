function nt_plot_sensitivity( ...
    RMSD,BIAS,Nmatch, ...
    radiusDeg,timeWindowHours, ...
    R_selected,TW_selected)

% NT_PLOT_SENSITIVITY
%
% Plots Neighbor Test collocation-sensitivity results.
%
% Figure 1:
%   RMSD heatmap with number of matchups in each cell.
%
% Figure 2:
%   Bias heatmap.
%
% The selected collocation configuration is highlighted.
%
% ------------------------------------------------------------


%% ============================================================
% Find selected matrix position
% ============================================================

irSel = find( ...
    abs(radiusDeg-R_selected) < 1e-10, ...
    1);

itSel = find( ...
    abs(timeWindowHours-TW_selected) < 1e-10, ...
    1);


%% ============================================================
% FIGURE 1 - RMSD
% ============================================================

figure( ...
    'Color','w', ...
    'Position',[100 100 900 650])


imagesc( ...
    timeWindowHours, ...
    radiusDeg, ...
    RMSD)


set(gca,'YDir','normal')


xlabel('Temporal half-window (\pm hours)')
ylabel('Spatial radius (degrees)')


cb = colorbar;
ylabel(cb,'RMSD')


title('NT collocation sensitivity: RMSD')


hold on


%% Add matchup number

for ir = 1:numel(radiusDeg)

    for it = 1:numel(timeWindowHours)

        if isfinite(RMSD(ir,it))

            text( ...
                timeWindowHours(it), ...
                radiusDeg(ir), ...
                sprintf('N=%d',Nmatch(ir,it)), ...
                'HorizontalAlignment','center', ...
                'VerticalAlignment','middle', ...
                'FontSize',9, ...
                'FontWeight','bold');

        end

    end

end


%% Highlight selected cell

if ~isempty(irSel) && ~isempty(itSel)

    plot( ...
        TW_selected, ...
        R_selected, ...
        'ks', ...
        'MarkerSize',24, ...
        'LineWidth',2.5)

end


box on


%% ============================================================
% FIGURE 2 - BIAS
% ============================================================

figure( ...
    'Color','w', ...
    'Position',[150 120 900 650])


imagesc( ...
    timeWindowHours, ...
    radiusDeg, ...
    BIAS)


set(gca,'YDir','normal')


xlabel('Temporal half-window (\pm hours)')
ylabel('Spatial radius (degrees)')


cb = colorbar;
ylabel(cb,'Bias (Target - Neighbor)')


title('NT collocation sensitivity: bias')


hold on


%% Add bias values

for ir = 1:numel(radiusDeg)

    for it = 1:numel(timeWindowHours)

        if isfinite(BIAS(ir,it))

            text( ...
                timeWindowHours(it), ...
                radiusDeg(ir), ...
                sprintf('%.3f',BIAS(ir,it)), ...
                'HorizontalAlignment','center', ...
                'VerticalAlignment','middle', ...
                'FontSize',9);

        end

    end

end


%% Highlight selected cell

if ~isempty(irSel) && ~isempty(itSel)

    plot( ...
        TW_selected, ...
        R_selected, ...
        'ks', ...
        'MarkerSize',24, ...
        'LineWidth',2.5)

end


box on

end