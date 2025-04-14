% Plant Growth Visual Dashboard with Mock Data Analysis
function PlantGrowthAnalyzerPro
    % Load sensor data from CSV
    try
        data = readtable('mock_plant_data.csv'); % Corrected filename
    catch ME
        disp(['Error loading data: ', ME.message]);
        return;
    end

    % GUI window
    f = figure('Name', 'Advanced Plant Growth Dashboard', 'Position', [200, 100, 1100, 700]);

    % Top controls
    uicontrol(f, 'Style', 'pushbutton', 'String', 'Reload Data', 'FontWeight', 'bold', 'Position', [40 650 120 30], 'Callback', @(~,~) updatePlots(ax1, ax2, ax3, ax4)); % Pass axes handles

    % Axes definitions
    ax1 = subplot(2,2,1, 'Parent', f);  % Environmental Trends
    ax2 = subplot(2,2,2, 'Parent', f);  % Plant Growth Timeline
    ax3 = subplot(2,2,3, 'Parent', f);  % Histogram
    ax4 = subplot(2,2,4, 'Parent', f);  % Yield Estimation/Mock Analysis

    % Initial Plot
    updatePlots(ax1, ax2, ax3, ax4); % Pass axes handles for initial plot

    function updatePlots(ax1, ax2, ax3, ax4) % Receive axes handles
        try
            % Reload data on update
            try
                data = readtable('mock_plant_data.csv'); % Corrected filename
            catch ME
                disp(['Error reloading data: ', ME.message]);
                return;
            end

            % Convert growth stages to categorical if not already
            if ~iscategorical(data.GrowthStage)
                data.GrowthStage = categorical(data.GrowthStage);
            end

            % Determine the actual name of the date column
            dateColumnName = '';
            if any(strcmp(data.Properties.VariableNames, 'Date'))
                dateColumnName = 'Date';
            elseif any(contains(data.Properties.VariableNames, 'Date', 'IgnoreCase', true))
                % Find the first column name containing 'Date' (case-insensitive)
                dateColumnName = data.Properties.VariableNames{find(contains(data.Properties.VariableNames, 'Date', 'IgnoreCase', true), 1)};
            else
                disp('Error: Could not find a column named "Date" in the data.');
                return;
            end

            % Timeline
            t = datetime(data.(dateColumnName));
            environmental_vars = {'pH','EC','Temperature','Humidity','LightIntensity','CO2','TDS'}; % Define environmental variables

            % Plot 1: Environmental Trends (plotting Temperature, Humidity, CO2)
            cla(ax1);
            plot(ax1, t, data.Temperature, '-o', 'DisplayName','Temperature');
            hold(ax1, 'on');
            plot(ax1, t, data.Humidity, '-x', 'DisplayName','Humidity');
            plot(ax1, t, data.CO2, '-s', 'DisplayName','CO₂');
            hold(ax1, 'off');
            legend(ax1, 'Location', 'northwest');
            title(ax1, 'Environmental Trends (Temp, Humidity, CO₂)');
            xlabel(ax1, 'Date'); ylabel(ax1, 'Value');
            grid(ax1, 'on');

            % Plot 2: Growth Stage & Weight
            cla(ax2);
            yyaxis(ax2, 'left');
            plot(ax2, t, data.Weight, '-*g', 'LineWidth', 2);
            ylabel(ax2, 'Plant Weight (g)');
            yyaxis(ax2, 'right');
            stairs(ax2, t, double(data.GrowthStage), '--r', 'LineWidth', 2);
            yticks(ax2, 0:max(double(data.GrowthStage)));
            ylabel(ax2, 'Growth Stage');
            title(ax2, 'Growth Timeline with Stages');
            xlabel(ax2, 'Date');
            grid(ax2, 'on');

            % Plot 3: Histogram of CO2
            cla(ax3);
            histogram(ax3, data.CO2, 'FaceColor', [0.5 0.5 0.8]); % Added color for better visualization
            title(ax3, 'Distribution of CO₂ Levels');
            xlabel(ax3, 'CO₂ (ppm)'); ylabel(ax3, 'Frequency');
            grid(ax3, 'on');

            % Plot 4: Mock Yield Estimation Over Time
            cla(ax4);
            % Ensure TDS is not zero to avoid division by zero
            nonZeroTDS = data.TDS;
            nonZeroTDS(nonZeroTDS == 0) = eps; % Replace zeros with a small epsilon value
            predictedYield = data.Weight .* (nonZeroTDS ./ max(nonZeroTDS));
            plot(ax4, t, predictedYield, 'm-*', 'LineWidth', 1.5);
            title(ax4, 'Mock Yield Estimation Over Time (Based on Weight & TDS)');
            xlabel(ax4, 'Date'); ylabel(ax4, 'Predicted Yield (Arbitrary Units)');
            grid(ax4, 'on');

        catch err
            disp(['Error updating plots: ', err.message]);
        end
    end
end