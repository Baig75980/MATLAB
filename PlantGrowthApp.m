function PlantGrowthApp()
    % GUI Window
    f = figure('Name', 'Plant Growth Analyzer', 'Position', [300 100 600 700]);

    labels = {'pH','EC','Temperature','Humidity','Light Intensity','CO2','TDS','Weight'};
    inputs = zeros(1, 8);
    fields = gobjects(1, 8);

    % Create input fields
    for i = 1:8
        uicontrol(f, 'Style', 'text', 'Position', [50 620 - (i*40), 140, 25], ...
                  'String', labels{i}, 'HorizontalAlignment', 'left', 'FontSize', 10, 'FontWeight', 'bold');
        fields(i) = uicontrol(f, 'Style', 'edit', 'Position', [200 620 - (i*40), 150, 25], ...
                  'FontSize', 10, 'BackgroundColor', 'white');
    end

    % Upload Image Button
    uicontrol(f, 'Style', 'pushbutton', 'String', 'Upload Plant Image', ...
              'Position', [50 670 150 30], 'FontSize', 10, ...
              'Callback', @(~,~) uploadImage());

    % Load Data File Button
    uicontrol(f, 'Style', 'pushbutton', 'String', 'Load Sensor Data File', ...
              'Position', [220 670 180 30], 'FontSize', 10, ...
              'Callback', @(~,~) loadSensorData());

    % Predict Button
    uicontrol(f, 'Style', 'pushbutton', 'String', 'Predict and Plot', ...
              'Position', [420 670 130 30], 'FontSize', 10, ...
              'Callback', @(~,~) predictAndPlot());

    % Output Text
    outputText = uicontrol(f, 'Style', 'text', 'String', '', ...
                  'Position', [100 240 400 30], 'FontSize', 12, ...
                  'ForegroundColor', 'blue', 'HorizontalAlignment', 'center');

    % Axes for Plot
    ax = axes(f, 'Position', [0.15 0.05 0.75 0.25]);

    % ---------- Functions ----------

    % Predict from entered or loaded inputs
    function predictAndPlot()
        for i = 1:8
            val = str2double(get(fields(i), 'String'));
            if isnan(val)
                errordlg(['Invalid input for ', labels{i}], 'Input Error');
                return;
            end
            inputs(i) = val;
        end

        % Dummy prediction logic — replace with trained model if needed
        growthIndex = mean(inputs);  % Example: simple average
        set(outputText, 'String', sprintf('Predicted Growth Index: %.2f', growthIndex));

        % Plot
        cla(ax);
        bar(ax, inputs, 'FaceColor', [0.2 0.6 0.4]);
        set(ax, 'XTickLabel', labels, 'XTick', 1:8, 'XTickLabelRotation', 45);
        ylabel(ax, 'Values');
        title(ax, 'Sensor Inputs');
    end

    % Load from CSV or MAT file
    function loadSensorData()
        [file, path] = uigetfile({'*.csv;*.mat'}, 'Select Sensor Data File');
        if isequal(file, 0)
            return;
        end

        try
            fullpath = fullfile(path, file);
            [~,~,ext] = fileparts(fullpath);

            if strcmp(ext, '.csv')
                data = readmatrix(fullpath);
            elseif strcmp(ext, '.mat')
                vars = load(fullpath);
                varName = fieldnames(vars);
                data = vars.(varName{1});
            else
                error('Unsupported file format');
            end

            if size(data, 2) >= 8
                for i = 1:8
                    set(fields(i), 'String', num2str(data(1,i)));
                end
                predictAndPlot();  % Optionally auto-predict
            else
                errordlg('Data file must have at least 8 columns.');
            end
        catch err
            errordlg(['Error loading file: ', err.message], 'File Error');
        end
    end

    % Upload and classify image using trained model
    function uploadImage()
        [file, path] = uigetfile({'*.jpg;*.png;*.jpeg'}, 'Select Plant Image');
        if isequal(file, 0)
            return;
        end

        try
            img = imread(fullfile(path, file));
            imgResized = imresize(img, [224 224]);  % Match input size of CNN
            
            % Normalize image and preprocess
            imgProcessed = double(imgResized) / 255;  % Normalize to [0, 1]

            % Load the pre-trained model
            modelData = load('plantImageNet.mat');  % Must contain net_img
            if isfield(modelData, 'net_img')
                % Debugging: Check if the model is loaded correctly
                disp('Model loaded successfully:');
                disp(modelData.net_img);  % Display the model structure
                
                % Classify the image
                predictedLabel = classify(modelData.net_img, imgProcessed);
                set(outputText, 'String', ['Image Stage: ', char(predictedLabel)]);
            else
                error('Variable "net_img" not found in plantImageNet.mat');
            end
        catch err
            % Display detailed error message in the output text box
            set(outputText, 'String', ['Image model error: ', err.message]);
        end
    end
end
