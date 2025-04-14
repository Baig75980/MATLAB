function PlantGrowthAnalyzerPro2 % Changed function name to avoid conflicts
    % --- Main Plant Growth Analyzer Function ---

    % --- 1. Data Loading ---
    try
        sensorData = readtable('mock_plant_data.csv'); % Or your actual file
    catch ME
        disp(['Error loading sensor data: ', ME.message]);
        sensorData = []; % Ensure sensorData is empty if loading fails
    end

    % --- 2. GUI Setup ---
    f = figure('Name', 'Advanced Plant Growth Analyzer with Image Analysis', 'Position', [200, 100, 1200, 800]);

    % --- 3. UI Controls ---
    % Sensor Data
    uicontrol(f, 'Style', 'pushbutton', 'String', 'Load Sensor Data', 'Position', [40 650 150 30], 'Callback', @loadSensorData);

    % Image Analysis
    captureImageButton = uicontrol(f, 'Style', 'pushbutton', 'String', 'Capture Image', 'Position', [40 580 150 30], 'Callback', @capturePlantImage);
    analyzeImageButton = uicontrol(f, 'Style', 'pushbutton', 'String', 'Analyze Image', 'Position', [200 580 150 30], 'Callback', @analyzeImage); % Corrected Callback

    % --- 4. Image Display Area ---
    imageAxes = axes('Parent', f, 'Position', [0.05 0.3 0.4 0.25]);

    % --- 5. Image Analysis Output Display ---
    uicontrol(f, 'Style', 'text', 'String', 'Estimated Height:', 'Position', [0.05 0.2 100 20], 'HorizontalAlignment', 'left');
    heightDisplay = uicontrol(f, 'Style', 'edit', 'String', '', 'Position', [110 0.2 80 20], 'Enable', 'inactive');

    % --- 6. Plot Axes ---
    ax1 = subplot(2, 2, 2, 'Parent', f);
    ax2 = subplot(2, 2, 3, 'Parent', f);
    ax3 = subplot(2, 2, 4, 'Parent', f);

    % --- 7. Data Storage ---
    plantImage = [];
    imageAnalysisResults = struct();

    % --- 8. Initial Plot (if data is loaded) ---
    if ~isempty(sensorData)
        updatePlots(ax1, ax2, ax3);
    end

    % --- 9. Nested Functions (Callbacks) ---

    function loadSensorData(~, ~)
        % --- Callback for Load Sensor Data Button ---
        try
            sensorData = readtable('mock_plant_data.csv'); % Or your actual file
            updatePlots(ax1, ax2, ax3);
        catch ME
            disp(['Error loading sensor data: ', ME.message]);
        end
    end

    function capturePlantImage(~, ~)
        % --- Callback for Capture Image Button ---
        % Simulate capturing an image (replace with actual camera interface)
        plantImage = imread('peppers.png'); % Example - replace with your image capture code

        % --- Debugging (Important) ---
        if isempty(plantImage)
            disp('Error: plantImage is empty after imread.');
            return;
        end

        if ~ishandle(imageAxes) || ~strcmp(get(imageAxes, 'Type'), 'axes')
            disp('Error: imageAxes is not a valid axes handle.');
            return;
        end

        imshow(plantImage, 'Parent', imageAxes);
        analyzeImage(); % Optionally analyze immediately
    end

    function analyzeImage(~, ~)
        % --- Callback for Analyze Image Button ---
        if ~isempty(plantImage)
            % --- Placeholder for Image Analysis ---
            % Replace this with your actual image processing code
            % Example: (Mock analysis)
            estimatedHeight = rand() * 30; % Replace with real height estimation
            imageAnalysisResults.Height = estimatedHeight;
            set(heightDisplay, 'String', sprintf('%.2f cm', estimatedHeight));

            % --- Example of updating plots with image data ---
            % updatePlots(ax1, ax2, ax3, imageAnalysisResults); % If you want to show image data in plots
        else
            disp('No plant image captured yet.');
        end
    end

    function updatePlots(ax1, ax2, ax3, varargin)
        % --- Function to Update Plots ---
        cla(ax1); cla(ax2); cla(ax3); % Clear previous plots

        if ~isempty(sensorData)
            % --- Date handling ---
            dateColumnName = '';
            if any(strcmp(sensorData.Properties.VariableNames, 'Date'))
                dateColumnName = 'Date';
            elseif any(contains(sensorData.Properties.VariableNames, 'Date', 'IgnoreCase', true))
                dateColumnName = sensorData.Properties.VariableNames{find(contains(sensorData.Properties.VariableNames, 'Date', 'IgnoreCase', true), 1)};
            else
                disp('Error: Could not find a column named "Date" in the data.');
                return; % Stop plotting if no Date column
            end
            t = datetime(sensorData.(dateColumnName));

            % --- Plot Sensor Data ---
            plot(ax1, t, sensorData.Temperature, '-o', 'DisplayName', 'Temperature');
            hold(ax1, 'on');
            plot(ax1, t, sensorData.Humidity, '-x', 'DisplayName', 'Humidity');
            plot(ax1, t, sensorData.CO2, '-s', 'DisplayName', 'CO2');
            hold(ax1, 'off');
            legend(ax1, 'Location', 'northwest');
            title(ax1, 'Environmental Trends');
            xlabel('Date'); ylabel('Value');
            grid(ax1, 'on');

            yyaxis(ax2, 'left');
            plot(ax2, t, sensorData.Weight, '-*g', 'LineWidth', 2);
            ylabel(ax2, 'Plant Weight (g)');
            yyaxis(ax2, 'right');
            stairs(ax2, t, double(sensorData.GrowthStage), '--r', 'LineWidth', 2);
            yticks(ax2, 0:max(double(sensorData.GrowthStage)));
            ylabel(ax2, 'Growth Stage');
            title(ax2, 'Growth Timeline with Stages');
            xlabel('Date');
            grid(ax2, 'on');

            histogram(ax3, sensorData.CO2, 'FaceColor', [0.5 0.5 0.8]);
            title(ax3, 'CO2 Distribution');
            xlabel('CO2 (ppm)'); ylabel('Frequency');
            grid(ax3, 'on');
        end

        % --- Plot Image Analysis Data (Example) ---
        if ~isempty(varargin)
            imageResults = varargin{1};
            if isfield(imageResults, 'Height') && ~isempty(sensorData) && ismember('Date', sensorData.Properties.VariableNames)
                axes(ax3); % Or a new axes if needed
                plot(t, imageResults.Height, '-m', 'LineWidth', 2);
                title('Estimated Plant Height Over Time');
                xlabel('Date'); ylabel('Height (cm)');
                grid('on');
            end
        end
    end

end