function PlantGrowthAnalyzerPro3 % Changed function name
    % --- Plant Growth Analyzer with Real-time Sensor Input ---

    % --- 1. GUI Setup ---
    f = figure('Name', 'Real-time Plant Growth Analyzer', 'Position', [200, 100, 1200, 800]);

    % --- 2. UI Controls ---
    % (Keep your existing UI controls, but adjust positions if needed)
    loadButton = uicontrol(f, 'Style', 'pushbutton', 'String', 'Connect & Start Logging', 'Position', [40 650 150 30], 'Callback', @startDataAcquisition);
    stopButton = uicontrol(f, 'Style', 'pushbutton', 'String', 'Stop Logging', 'Position', [200 650 150 30], 'Callback', @stopDataAcquisition, 'Enable', 'off'); % Initially disabled

    % --- 3. Display Areas ---
    dataDisplay = uicontrol(f, 'Style', 'edit', 'String', 'Connecting...', 'Position', [40 500 300 100], 'Max', 2, 'Enable', 'inactive'); % Multiline edit box
    % (Keep your existing plot axes: ax1, ax2, ax3, imageAxes, etc.)

    % --- 4. Data Storage ---
    sensorData = table(); % Initialize an empty table
    isLogging = false;
    tcpClient = []; % Handle for the TCP/IP connection

    % --- 5. Nested Functions ---

    function startDataAcquisition(~, ~)
        % --- Connect to Raspberry Pi and start logging data ---
        try
            tcpClient = tcpip('localhost', 65432, 'NetworkRole', 'client'); % Adjust IP if needed
            fopen(tcpClient);
            set(loadButton, 'Enable', 'off');
            set(stopButton, 'Enable', 'on');
            set(dataDisplay, 'String', 'Connected. Logging data...', 'Enable', 'inactive');
            isLogging = true;
            % Start data logging in a separate thread to keep the GUI responsive
            t = timer('TimerFcn', @readAndProcessData, 'Period', 1, 'ExecutionMode', 'fixedRate'); % Adjust period as needed
            start(t);
        catch ME
            set(dataDisplay, 'String', ['Error connecting: ', ME.message], 'Enable', 'inactive');
        end
    end

    function stopDataAcquisition(~, ~)
        % --- Stop data logging and disconnect ---
        try
            fclose(tcpClient);
            delete(tcpClient);
            clear tcpClient;
            isLogging = false;
            set(loadButton, 'Enable', 'on');
            set(stopButton, 'Enable', 'off');
            set(dataDisplay, 'String', 'Connection closed.', 'Enable', 'inactive');
        catch ME
            set(dataDisplay, 'String', ['Error disconnecting: ', ME.message], 'Enable', 'inactive');
        end
    end

    function readAndProcessData(obj, ~)
        % --- Read data from Raspberry Pi and update GUI ---
        if isLogging
            try
                data = fgetl(tcpClient); % Read a line of data
                if ~isempty(data)
                    % --- Parse Data ---
                    data_cells = strsplit(data, ',');
                    timestamp = datetime(data_cells{1}, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSSSSS');
                    ph = str2double(data_cells{2});
                    ec = str2double(data_cells{3});
                    temp = str2double(data_cells{4});
                    humidity = str2double(data_cells{5});
                    light = str2double(data_cells{6});
                    co2 = str2double(data_cells{7});
                    tds = str2double(data_cells{8});
                    weight = str2double(data_cells{9});

                    % --- Store Data ---
                    newData = table(timestamp, ph, ec, temp, humidity, light, co2, tds, weight);
                    sensorData = [sensorData; newData]; % Append to table

                    % --- Update Display ---
                    set(dataDisplay, 'String', data, 'Enable', 'inactive');

                    % --- Update Plots ---
                    updatePlots(ax1, ax2, ax3);
                end
            catch ME
                disp(['Error reading data: ', ME.message]);
                stop(obj); % Stop the timer on error
                stopDataAcquisition();
            end
        end
    end

    function updatePlots(ax1, ax2, ax3, varargin)
        % --- Update the plots with the sensor data ---
        % (Keep your existing plotting logic, but use the 'sensorData' table)
        if ~isempty(sensorData)
            % --- Plotting Code (Example) ---
            cla(ax1);
            plot(ax1, sensorData.timestamp, sensorData.temp);
            title(ax1, 'Temperature Over Time');
            % ... (Plot other sensor data)
        end
    end

    % --- Initial GUI State ---
    % (Any initial setup you need)

end