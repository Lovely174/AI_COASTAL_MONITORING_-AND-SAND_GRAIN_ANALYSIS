function SandQualityAnalyzer_ESP32()
    % SAND QUALITY VALIDATION SYSTEM
    % Automatic preprocessing, thermal heat map, and quality analysis
    % GUI automatically adjusts to screen size
    % Automatic PDF report generation with sand type classification
    % Disaster prediction based on sand quality data
    % Supports ESP32-CAM image input via IP address
    
    % Get screen size
    screenSize = get(0, 'ScreenSize');
    screenWidth = screenSize(3);
    screenHeight = screenSize(4);
    
    % Calculate GUI size (70% of screen, maintain aspect ratio)
    guiWidth = round(screenWidth * 0.7);
    guiHeight = round(screenHeight * 0.7);
    
    % Ensure minimum size
    if guiWidth < 800
        guiWidth = 800;
    end
    if guiHeight < 600
        guiHeight = 600;
    end
    
    % Calculate position to center the GUI
    posX = round((screenWidth - guiWidth) / 2);
    posY = round((screenHeight - guiHeight) / 2);
    
    % Create main figure with auto-sized dimensions
    fig = uifigure('Name', 'Sand Quality Analyzer - ESP32-CAM', ...
                   'Position', [posX posY guiWidth guiHeight], ...
                   'Color', [0.94 0.94 0.94], ...
                   'Resize', 'on');
    
    % Calculate scaling factors
    scaleFactor = guiWidth / 1200;
    if scaleFactor < 0.6
        scaleFactor = 0.6;
    end
    if scaleFactor > 1.2
        scaleFactor = 1.2;
    end
    
    % Main grid layout
    headerHeight = round(80 * scaleFactor);
    mainGrid = uigridlayout(fig, [2 1], ...
                           'RowHeight', {headerHeight, '1x'}, ...
                           'ColumnWidth', {'1x'});
    
    % Header panel with buttons
    headerPanel = uipanel(mainGrid, ...
                         'Title', 'Sand Quality Validation & Disaster Prediction System', ...
                         'FontSize', round(16 * scaleFactor), ...
                         'FontWeight', 'bold', ...
                         'BackgroundColor', [0.15 0.3 0.5], ...
                         'ForegroundColor', 'white');
    
    % Header buttons (5 buttons)
    headerGrid = uigridlayout(headerPanel, [1 5], ...
                             'ColumnWidth', {'1x', '1x', '1x', '1x', '1x'}, ...
                             'Padding', [round(5*scaleFactor) round(5*scaleFactor) ...
                                        round(5*scaleFactor) round(5*scaleFactor)]);
    
    % Load from File Button
    fileBtn = uibutton(headerGrid, 'push', ...
                      'Text', 'Load File', ...
                      'FontSize', round(12 * scaleFactor), ...
                      'BackgroundColor', [0.2 0.6 0.2], ...
                      'FontColor', 'white', ...
                      'FontWeight', 'bold', ...
                      'ButtonPushedFcn', @(btn,event) loadImage());
    
    % ESP32-CAM Button
    camBtn = uibutton(headerGrid, 'push', ...
                     'Text', 'ESP32-CAM', ...
                     'FontSize', round(12 * scaleFactor), ...
                     'BackgroundColor', [0.2 0.4 0.8], ...
                     'FontColor', 'white', ...
                     'FontWeight', 'bold', ...
                     'ButtonPushedFcn', @(btn,event) loadESP32CAM());
    
    % Generate PDF Button
    pdfBtn = uibutton(headerGrid, 'push', ...
                     'Text', 'Generate PDF', ...
                     'FontSize', round(12 * scaleFactor), ...
                     'BackgroundColor', [0.6 0.2 0.6], ...
                     'FontColor', 'white', ...
                     'FontWeight', 'bold', ...
                     'ButtonPushedFcn', @(btn,event) generatePDFReport());
    
    % Reset All Button
    resetBtn = uibutton(headerGrid, 'push', ...
                       'Text', 'Reset All', ...
                       'FontSize', round(12 * scaleFactor), ...
                       'BackgroundColor', [0.7 0.4 0.2], ...
                       'FontColor', 'white', ...
                       'FontWeight', 'bold', ...
                       'ButtonPushedFcn', @(btn,event) resetAll());
    
    % Exit Button
    exitBtn = uibutton(headerGrid, 'push', ...
                      'Text', 'Exit', ...
                      'FontSize', round(12 * scaleFactor), ...
                      'BackgroundColor', [0.6 0.2 0.2], ...
                      'FontColor', 'white', ...
                      'FontWeight', 'bold', ...
                      'ButtonPushedFcn', @(btn,event) close(fig));
    
    % Main content panel (bottom)
    contentPanel = uipanel(mainGrid, ...
                          'BackgroundColor', [0.98 0.98 0.98]);
    
    contentGrid = uigridlayout(contentPanel, [1 3], ...
                              'ColumnWidth', {'1x', '1x', '1x'}, ...
                              'Padding', [round(10*scaleFactor) round(10*scaleFactor) ...
                                         round(10*scaleFactor) round(10*scaleFactor)]);
    
    % Left: Original Image
    imagePanel1 = uipanel(contentGrid, ...
                         'Title', 'Original Sand Image', ...
                         'FontSize', round(12 * scaleFactor), ...
                         'FontWeight', 'bold', ...
                         'BackgroundColor', 'white');
    
    imageGrid1 = uigridlayout(imagePanel1, [2 1], ...
                             'RowHeight', {'1x', round(30*scaleFactor)});
    
    imageAxes1 = uiaxes(imageGrid1);
    imageAxes1.XTick = [];
    imageAxes1.YTick = [];
    imageAxes1.Box = 'on';
    imageAxes1.BackgroundColor = [0.95 0.95 0.95];
    axis(imageAxes1, 'image');
    title(imageAxes1, 'No Image Loaded', 'FontSize', round(11*scaleFactor));
    
    statusLabel1 = uilabel(imageGrid1, ...
                          'Text', 'Status: Waiting for input', ...
                          'FontSize', round(11*scaleFactor), ...
                          'FontColor', [0.3 0.3 0.3], ...
                          'HorizontalAlignment', 'center', ...
                          'FontWeight', 'bold');
    
    % Center: Thermal Heat Map
    imagePanel2 = uipanel(contentGrid, ...
                         'Title', 'Thermal Heat Map Analysis', ...
                         'FontSize', round(12 * scaleFactor), ...
                         'FontWeight', 'bold', ...
                         'BackgroundColor', 'white');
    
    imageGrid2 = uigridlayout(imagePanel2, [2 1], ...
                             'RowHeight', {'1x', round(30*scaleFactor)});
    
    imageAxes2 = uiaxes(imageGrid2);
    imageAxes2.XTick = [];
    imageAxes2.YTick = [];
    imageAxes2.Box = 'on';
    imageAxes2.BackgroundColor = [0.95 0.95 0.95];
    axis(imageAxes2, 'image');
    title(imageAxes2, 'No Analysis', 'FontSize', round(11*scaleFactor));
    
    statusLabel2 = uilabel(imageGrid2, ...
                          'Text', 'Status: Waiting for analysis', ...
                          'FontSize', round(11*scaleFactor), ...
                          'FontColor', [0.3 0.3 0.3], ...
                          'HorizontalAlignment', 'center', ...
                          'FontWeight', 'bold');
    
    % Right: Results Panel
    resultsPanel = uipanel(contentGrid, ...
                          'Title', 'Quality Analysis Results', ...
                          'FontSize', round(12 * scaleFactor), ...
                          'FontWeight', 'bold', ...
                          'BackgroundColor', 'white');
    
    resultsGrid = uigridlayout(resultsPanel, [12 1], ...
                              'RowHeight', {round(30*scaleFactor), round(40*scaleFactor), ...
                                           round(70*scaleFactor), round(22*scaleFactor), ...
                                           round(22*scaleFactor), round(28*scaleFactor), ...
                                           round(28*scaleFactor), round(32*scaleFactor), ...
                                           round(30*scaleFactor), round(30*scaleFactor), ...
                                           round(30*scaleFactor), round(200*scaleFactor)}, ...
                              'Padding', [round(10*scaleFactor) round(10*scaleFactor) ...
                                         round(10*scaleFactor) round(10*scaleFactor)]);
    
    % Quality grade display
    qualityLabel = uilabel(resultsGrid, ...
                          'Text', 'Sand Quality Grade:', ...
                          'FontSize', round(14*scaleFactor), ...
                          'FontWeight', 'bold', ...
                          'FontColor', [0.2 0.2 0.2]);
    
    qualityValue = uilabel(resultsGrid, ...
                          'Text', 'Not Analyzed', ...
                          'FontSize', round(22*scaleFactor), ...
                          'FontWeight', 'bold', ...
                          'FontColor', [0.5 0.5 0.5], ...
                          'HorizontalAlignment', 'center', ...
                          'BackgroundColor', [0.95 0.95 0.95]);
    
    % Quality metrics panel
    metricsPanel = uipanel(resultsGrid, ...
                          'Title', 'Quality Metrics', ...
                          'BackgroundColor', [0.98 0.98 0.98]);
    
    metricsGrid = uigridlayout(metricsPanel, [2 4], ...
                              'ColumnWidth', {'1x', '1x', '1x', '1x'}, ...
                              'RowHeight', {round(22*scaleFactor), round(22*scaleFactor)});
    
    % Individual metrics
    metricLabels = {'Grain Size', 'Roundness', 'Color Index', 'Purity'};
    metricLabelHandles = gobjects(1, 4);
    metricValueHandles = gobjects(1, 4);
    
    for i = 1:4
        metricLabelHandles(i) = uilabel(metricsGrid, ...
                           'Text', metricLabels{i}, ...
                           'FontSize', round(11*scaleFactor), ...
                           'FontWeight', 'bold');
        metricLabelHandles(i).Layout.Row = 1;
        metricLabelHandles(i).Layout.Column = i;
        
        metricValueHandles(i) = uilabel(metricsGrid, ...
                           'Text', '---', ...
                           'FontSize', round(11*scaleFactor), ...
                           'FontColor', [0.2 0.4 0.6], ...
                           'FontWeight', 'bold');
        metricValueHandles(i).Layout.Row = 2;
        metricValueHandles(i).Layout.Column = i;
    end
    
    % Sand Type Classification
    sandTypeLabel = uilabel(resultsGrid, ...
                          'Text', 'Sand Type Classification:', ...
                          'FontSize', round(12*scaleFactor), ...
                          'FontWeight', 'bold');
    
    sandTypeValue = uilabel(resultsGrid, ...
                          'Text', 'Not Classified', ...
                          'FontSize', round(14*scaleFactor), ...
                          'FontColor', [0 0.4 0.8], ...
                          'FontWeight', 'bold', ...
                          'BackgroundColor', [0.95 0.95 0.95], ...
                          'HorizontalAlignment', 'center');
    
    % Disaster Prediction
    disasterLabel = uilabel(resultsGrid, ...
                           'Text', 'Disaster Prediction:', ...
                           'FontSize', round(12*scaleFactor), ...
                           'FontWeight', 'bold');
    
    disasterValue = uilabel(resultsGrid, ...
                           'Text', 'Not Predicted', ...
                           'FontSize', round(14*scaleFactor), ...
                           'FontColor', [0.8 0.2 0.2], ...
                           'FontWeight', 'bold', ...
                           'BackgroundColor', [0.95 0.95 0.95], ...
                           'HorizontalAlignment', 'center');
    
    % Thermal metrics
    thermalLabel = uilabel(resultsGrid, ...
                          'Text', 'Thermal Analysis:', ...
                          'FontSize', round(12*scaleFactor), ...
                          'FontWeight', 'bold');
    
    thermalValue = uilabel(resultsGrid, ...
                          'Text', 'Not Analyzed', ...
                          'FontSize', round(12*scaleFactor), ...
                          'FontColor', [0.8 0.4 0], ...
                          'FontWeight', 'bold');
    
    % Preprocessing status
    preprocessLabel = uilabel(resultsGrid, ...
                             'Text', 'Preprocessing Status:', ...
                             'FontSize', round(12*scaleFactor), ...
                             'FontWeight', 'bold');
    
    preprocessValue = uilabel(resultsGrid, ...
                             'Text', 'Waiting...', ...
                             'FontSize', round(12*scaleFactor), ...
                             'FontColor', [0.5 0.5 0.5], ...
                             'FontWeight', 'bold');
    
    % PDF Status
    pdfStatusLabel = uilabel(resultsGrid, ...
                            'Text', 'PDF Report:', ...
                            'FontSize', round(12*scaleFactor), ...
                            'FontWeight', 'bold');
    
    pdfStatusValue = uilabel(resultsGrid, ...
                            'Text', 'Not Generated', ...
                            'FontSize', round(12*scaleFactor), ...
                            'FontColor', [0.5 0.5 0.5], ...
                            'FontWeight', 'bold');
    
    % Detailed analysis
    detailText = uitextarea(resultsGrid, ...
                           'Value', 'Analysis results will appear here...', ...
                           'Editable', 'off', ...
                           'FontSize', round(10*scaleFactor), ...
                           'BackgroundColor', [0.98 0.98 0.98]);
    
    % Store handles and data
    appData = struct();
    appData.fig = fig;
    appData.imageAxes1 = imageAxes1;
    appData.imageAxes2 = imageAxes2;
    appData.statusLabel1 = statusLabel1;
    appData.statusLabel2 = statusLabel2;
    appData.qualityValue = qualityValue;
    appData.metricValueHandles = metricValueHandles;
    appData.sandTypeValue = sandTypeValue;
    appData.disasterValue = disasterValue;
    appData.thermalValue = thermalValue;
    appData.preprocessValue = preprocessValue;
    appData.pdfStatusValue = pdfStatusValue;
    appData.detailText = detailText;
    appData.currentImage = [];
    appData.analysisResults = [];
    appData.imagePath = '';
    appData.imageLoaded = false;
    appData.analyzed = false;
    appData.reportGenerated = false;
    appData.lastReportPath = '';
    appData.imageSource = 'None';
    
    % Store in figure user data
    fig.UserData = appData;
    
    % ------------------- Callback Functions -------------------
    
    function loadImage()
        % Load image from file
        [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp;*.tif;*.tiff', ...
                                         'Image Files (*.jpg,*.png,*.bmp,*.tif)'}, ...
                                         'Select Sand Sample Image');
        
        if isequal(filename, 0) || isequal(pathname, 0)
            return;
        end
        
        appData = fig.UserData;
        appData.imagePath = fullfile(pathname, filename);
        appData.imageSource = 'File';
        
        try
            % Read image
            img = imread(appData.imagePath);
            processImage(img, filename);
            
        catch ME
            appData.imageLoaded = false;
            appData.statusLabel1.Text = 'Status: Error loading image';
            appData.statusLabel1.FontColor = [0.8 0.2 0.2];
            fig.UserData = appData;
            uialert(fig, ['Error: ' ME.message], 'Error', 'Icon', 'error');
        end
    end
    
    function loadESP32CAM()
        % Load image from ESP32-CAM
        appData = fig.UserData;
        
        % ESP32-CAM URL
        url = 'http://192.168.137.19/cam-hi.jpg';
        
        try
            appData.statusLabel1.Text = 'Status: Connecting to ESP32-CAM...';
            appData.statusLabel1.FontColor = [0.8 0.4 0];
            drawnow;
            
            % Download image from ESP32-CAM
            img = imread(url);
            
            % Check if image is valid
            if isempty(img)
                uialert(fig, 'Failed to capture image from ESP32-CAM. Please check connection.', 'Error', 'Icon', 'error');
                return;
            end
            
            appData.imagePath = url;
            appData.imageSource = 'ESP32-CAM';
            
            processImage(img, 'ESP32-CAM_Capture');
            
        catch ME
            appData.imageLoaded = false;
            appData.statusLabel1.Text = 'Status: ESP32-CAM connection failed';
            appData.statusLabel1.FontColor = [0.8 0.2 0.2];
            fig.UserData = appData;
            uialert(fig, ['ESP32-CAM Error: ' ME.message], 'Error', 'Icon', 'error');
        end
    end
    
    function processImage(img, filename)
        % Process the loaded image
        appData = fig.UserData;
        
        try
            % Store image
            appData.currentImage = img;
            appData.imageLoaded = true;
            appData.analyzed = false;
            appData.reportGenerated = false;
            
            % Display original image
            imshow(img, 'Parent', appData.imageAxes1);
            title(appData.imageAxes1, filename, 'FontSize', round(11*scaleFactor), 'FontWeight', 'bold');
            axis(appData.imageAxes1, 'image');
            
            % Update status
            if strcmp(appData.imageSource, 'ESP32-CAM')
                appData.statusLabel1.Text = 'Status: ESP32-CAM image captured - Processing...';
            else
                appData.statusLabel1.Text = 'Status: Image loaded - Processing...';
            end
            appData.statusLabel1.FontColor = [0 0.5 0];
            
            % Update app data
            fig.UserData = appData;
            
            % Perform automatic preprocessing and analysis
            performAnalysis();
            
            % Show success
            uialert(fig, sprintf('Image from %s analyzed successfully!', appData.imageSource), 'Success', 'Icon', 'success');
            
        catch ME
            appData.imageLoaded = false;
            appData.statusLabel1.Text = 'Status: Error processing image';
            appData.statusLabel1.FontColor = [0.8 0.2 0.2];
            fig.UserData = appData;
            uialert(fig, ['Error: ' ME.message], 'Error', 'Icon', 'error');
        end
    end
    
    function performAnalysis()
        % Perform automatic preprocessing, heat map, and quality analysis
        appData = fig.UserData;
        
        if ~appData.imageLoaded || isempty(appData.currentImage)
            return;
        end
        
        try
            img = appData.currentImage;
            
            % ---------- PREPROCESSING ----------
            appData.preprocessValue.Text = 'Preprocessing...';
            appData.preprocessValue.FontColor = [0.8 0.4 0];
            drawnow;
            
            % Convert to grayscale if RGB
            if size(img, 3) == 3
                grayImg = rgb2gray(img);
            else
                grayImg = img;
            end
            
            % Enhance contrast
            enhancedImg = imadjust(grayImg);
            
            % Apply median filter for noise removal
            filteredImg = medfilt2(enhancedImg, [3 3]);
            
            % Edge detection
            edges = edge(filteredImg, 'canny', [0.1 0.3]);
            
            % ---------- THERMAL HEAT MAP ----------
            % Create heat map based on intensity distribution
            heatMap = generateThermalMap(filteredImg);
            
            % Display thermal heat map
            imshow(heatMap, 'Parent', appData.imageAxes2);
            title(appData.imageAxes2, 'Thermal Heat Map', 'FontSize', round(11*scaleFactor), 'FontWeight', 'bold');
            axis(appData.imageAxes2, 'image');
            colormap(appData.imageAxes2, 'hot');
            colorbar(appData.imageAxes2);
            
            % Update thermal status
            appData.statusLabel2.Text = 'Status: Thermal analysis complete';
            appData.statusLabel2.FontColor = [0 0.5 0];
            
            % ---------- QUALITY METRICS ----------
            % Calculate quality metrics
            metrics = calculateSandMetrics(filteredImg, img, edges);
            
            % Determine quality grade
            [grade, gradeColor] = determineQualityGrade(metrics);
            
            % Determine sand type
            sandType = classifySandType(metrics);
            
            % Predict disaster
            [disasterPrediction, riskLevel, riskFactors] = predictDisaster(metrics);
            
            % Update UI - Quality Grade
            appData.qualityValue.Text = grade;
            appData.qualityValue.FontColor = gradeColor;
            
            % Update sand type
            appData.sandTypeValue.Text = sandType;
            
            % Update disaster prediction
            appData.disasterValue.Text = disasterPrediction;
            if strcmp(riskLevel, 'High')
                appData.disasterValue.FontColor = [0.8 0.2 0.2];
            elseif strcmp(riskLevel, 'Medium')
                appData.disasterValue.FontColor = [0.8 0.6 0];
            else
                appData.disasterValue.FontColor = [0 0.6 0];
            end
            
            % Update metrics
            metricValues = {sprintf('%.2f um', metrics.grainSize), ...
                           sprintf('%.2f', metrics.roundness), ...
                           sprintf('%.2f', metrics.colorIndex), ...
                           sprintf('%.2f %%', metrics.purity * 100)};
            
            for i = 1:4
                appData.metricValueHandles(i).Text = metricValues{i};
            end
            
            % Update thermal value
            thermalStats = calculateThermalStats(heatMap);
            appData.thermalValue.Text = sprintf('Mean: %.2f | Peak: %.2f | Density: %.2f%%', ...
                                               thermalStats.mean, thermalStats.peak, thermalStats.density * 100);
            appData.thermalValue.FontColor = [0.8 0.2 0.2];
            
            % Update preprocessing status
            appData.preprocessValue.Text = 'Completed - Enhanced & Filtered';
            appData.preprocessValue.FontColor = [0 0.6 0];
            
            % Format risk factors for display
            factorsDisplay = strjoin(riskFactors, '; ');
            
            % Update detail text
            detailStr = sprintf(['AUTOMATIC ANALYSIS REPORT\n', ...
                               '========================================\n', ...
                               'IMAGE SOURCE    : %s\n', ...
                               'PREPROCESSING:\n', ...
                               '  - Contrast Enhancement: Applied\n', ...
                               '  - Noise Filtering: Applied (Median 3x3)\n', ...
                               '  - Edge Detection: Applied (Canny)\n', ...
                               '  - Thermal Mapping: Generated\n\n', ...
                               'QUALITY METRICS:\n', ...
                               '  Grain Size     : %.2f micrometers\n', ...
                               '  Roundness      : %.2f (0-1 scale)\n', ...
                               '  Color Index    : %.2f (0-1 scale)\n', ...
                               '  Purity         : %.2f percent\n\n', ...
                               'SAND TYPE       : %s\n\n', ...
                               'DISASTER PREDICTION:\n', ...
                               '  Prediction     : %s\n', ...
                               '  Risk Level     : %s\n', ...
                               '  Risk Factors   : %s\n\n', ...
                               'THERMAL STATISTICS:\n', ...
                               '  Mean Temp      : %.2f\n', ...
                               '  Peak Temp      : %.2f\n', ...
                               '  Density        : %.2f%%\n\n', ...
                               'QUALITY GRADE   : %s\n', ...
                               '========================================\n', ...
                               'RECOMMENDATION  : %s'], ...
                               appData.imageSource, ...
                               metrics.grainSize, metrics.roundness, ...
                               metrics.colorIndex, metrics.purity * 100, ...
                               sandType, ...
                               disasterPrediction, riskLevel, factorsDisplay, ...
                               thermalStats.mean, thermalStats.peak, ...
                               thermalStats.density * 100, ...
                               grade, getRecommendation(grade));
            
            appData.detailText.Value = detailStr;
            
            % Store results
            appData.analysisResults = metrics;
            appData.analysisResults.grade = grade;
            appData.analysisResults.sandType = sandType;
            appData.analysisResults.disasterPrediction = disasterPrediction;
            appData.analysisResults.riskLevel = riskLevel;
            appData.analysisResults.riskFactors = riskFactors;
            appData.analysisResults.thermalStats = thermalStats;
            appData.analyzed = true;
            
            fig.UserData = appData;
            
        catch ME
            appData.preprocessValue.Text = 'Error in preprocessing';
            appData.preprocessValue.FontColor = [0.8 0.2 0.2];
            fig.UserData = appData;
            uialert(fig, ['Analysis error: ' ME.message], 'Error', 'Icon', 'error');
        end
    end
    
    function [prediction, riskLevel, riskFactors] = predictDisaster(metrics)
        % Predict disaster based on sand quality metrics
        % Uses multiple parameters to assess disaster risk
        
        % Initialize risk score
        riskScore = 0;
        riskFactors = {};
        
        % 1. Grain Size Analysis
        if metrics.grainSize < 150
            riskScore = riskScore + 25;
            riskFactors{end+1} = 'Fine sand - prone to erosion';
        elseif metrics.grainSize > 400
            riskScore = riskScore + 20;
            riskFactors{end+1} = 'Coarse sand - structural instability';
        end
        
        % 2. Roundness Analysis
        if metrics.roundness < 0.3
            riskScore = riskScore + 20;
            riskFactors{end+1} = 'Angular particles - poor compaction';
        elseif metrics.roundness > 0.8
            riskScore = riskScore + 10;
            riskFactors{end+1} = 'Well-rounded - possible wind erosion';
        end
        
        % 3. Purity Analysis
        if metrics.purity < 0.5
            riskScore = riskScore + 25;
            riskFactors{end+1} = 'Low purity - contamination risk';
        elseif metrics.purity < 0.7
            riskScore = riskScore + 15;
            riskFactors{end+1} = 'Moderate purity - requires assessment';
        end
        
        % 4. Color Index Analysis
        if metrics.colorIndex < 0.3
            riskScore = riskScore + 15;
            riskFactors{end+1} = 'High organic content - instability';
        elseif metrics.colorIndex > 0.9
            riskScore = riskScore + 10;
            riskFactors{end+1} = 'Light colored - potential leaching';
        end
        
        % 5. Density/Cementation Indicator (from thermal stats)
        if isfield(metrics, 'thermalStats')
            density = metrics.thermalStats.density;
            if density > 0.7
                riskScore = riskScore + 15;
                riskFactors{end+1} = 'High density - compaction risk';
            end
        end
        
        % Determine risk level and prediction
        if riskScore >= 60
            riskLevel = 'High';
            prediction = 'DISASTER LIKELY - Immediate action required!';
        elseif riskScore >= 35
            riskLevel = 'Medium';
            prediction = 'Disaster Possible - Monitor closely';
        elseif riskScore >= 15
            riskLevel = 'Low';
            prediction = 'Low Risk - Regular monitoring recommended';
        else
            riskLevel = 'Very Low';
            prediction = 'No Immediate Threat - Safe conditions';
        end
        
        % Add specific disaster type prediction
        if riskScore >= 60
            % Determine specific disaster type
            if metrics.grainSize < 150 && metrics.purity < 0.5
                prediction = [prediction, ' (Sand Erosion/Subsidence)'];
            elseif metrics.roundness < 0.3 && metrics.purity < 0.6
                prediction = [prediction, ' (Structural Collapse)'];
            else
                prediction = [prediction, ' (Multiple Risk Factors)'];
            end
        end
    end
    
    function sandType = classifySandType(metrics)
        % Classify sand type based on grain size
        grainSize = metrics.grainSize;
        
        % Classification based on grain size (in micrometers)
        if grainSize >= 200 && grainSize <= 500
            sandType = 'Berm Sand (Medium to Coarse)';
        elseif grainSize >= 125 && grainSize < 200
            sandType = 'Intertidal Sand (Fine to Medium)';
        elseif grainSize >= 150 && grainSize < 300
            sandType = 'Dune Sand (Fine to Medium, Well Sorted)';
        elseif grainSize >= 500
            sandType = 'Very Coarse Sand (Gravelly)';
        elseif grainSize < 125
            sandType = 'Very Fine Sand (Silty)';
        else
            sandType = 'Mixed Sand Type';
        end
        
        % Add quality indicator based on roundness and purity
        if metrics.roundness > 0.7 && metrics.purity > 0.8
            sandType = [sandType, ' - High Quality'];
        elseif metrics.roundness > 0.5 && metrics.purity > 0.6
            sandType = [sandType, ' - Medium Quality'];
        else
            sandType = [sandType, ' - Low Quality'];
        end
    end
    
    function generatePDFReport()
        % Generate PDF report
        appData = fig.UserData;
        
        if ~appData.analyzed || isempty(appData.analysisResults)
            uialert(fig, 'Please analyze an image first!', 'No Data', 'Icon', 'warning');
            return;
        end
        
        try
            % Update status
            appData.pdfStatusValue.Text = 'Generating PDF...';
            appData.pdfStatusValue.FontColor = [0.8 0.4 0];
            drawnow;
            
            % Get image name
            if strcmp(appData.imageSource, 'ESP32-CAM')
                imageName = sprintf('ESP32-CAM_%s', datestr(now, 'yyyy-mm-dd_HH-MM-SS'));
            else
                [~, imageName, ~] = fileparts(appData.imagePath);
            end
            
            % Create filename with timestamp
            timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
            defaultFilename = sprintf('Sand_Quality_Report_%s_%s.pdf', imageName, timestamp);
            
            % Ask user where to save
            [filename, pathname] = uiputfile({'*.pdf', 'PDF Files (*.pdf)'}, ...
                                             'Save PDF Report', defaultFilename);
            
            if isequal(filename, 0) || isequal(pathname, 0)
                appData.pdfStatusValue.Text = 'PDF Generation Cancelled';
                appData.pdfStatusValue.FontColor = [0.8 0.4 0];
                fig.UserData = appData;
                return;
            end
            
            pdfPath = fullfile(pathname, filename);
            
            % Create a new figure for PDF
            pdfFig = figure('Visible', 'off', 'PaperUnits', 'inches', ...
                           'PaperSize', [8.5, 11], 'PaperPosition', [0.25, 0.25, 8, 10.5]);
            
            % Add title
            annotation('textbox', [0.05, 0.92, 0.9, 0.06], ...
                      'String', 'SAND QUALITY ANALYSIS & DISASTER PREDICTION REPORT', ...
                      'FontSize', 16, 'FontWeight', 'bold', ...
                      'HorizontalAlignment', 'center', 'EdgeColor', 'none');
            
            % Add subtitle with timestamp
            annotation('textbox', [0.05, 0.87, 0.9, 0.04], ...
                      'String', sprintf('Generated: %s', datestr(now)), ...
                      'FontSize', 10, 'HorizontalAlignment', 'center', ...
                      'EdgeColor', 'none');
            
            % Image source and name
            annotation('textbox', [0.05, 0.82, 0.9, 0.04], ...
                      'String', sprintf('Image Source: %s', appData.imageSource), ...
                      'FontSize', 9, 'HorizontalAlignment', 'center', ...
                      'EdgeColor', 'none');
            
            % Display original image in PDF (top left)
            subplot('Position', [0.05, 0.52, 0.4, 0.28]);
            imshow(appData.currentImage);
            title('Original Sand Image', 'FontSize', 11, 'FontWeight', 'bold');
            
            % Display thermal map in PDF (top right)
            subplot('Position', [0.55, 0.52, 0.4, 0.28]);
            thermalFrame = getframe(appData.imageAxes2);
            imshow(thermalFrame.cdata);
            title('Thermal Heat Map', 'FontSize', 11, 'FontWeight', 'bold');
            
            % Display metrics in PDF (bottom)
            subplot('Position', [0.05, 0.05, 0.9, 0.42]);
            axis off;
            metrics = appData.analysisResults;
            
            % Create risk level color indicator
            riskSymbol = ' ';
            if strcmp(metrics.riskLevel, 'High')
                riskSymbol = '!!! HIGH RISK !!!';
            elseif strcmp(metrics.riskLevel, 'Medium')
                riskSymbol = '!! MEDIUM RISK !!';
            elseif strcmp(metrics.riskLevel, 'Low')
                riskSymbol = '! LOW RISK !';
            else
                riskSymbol = 'SAFE';
            end
            
            % Format risk factors - each on a new line with bullet points
            riskFactorsText = '';
            if ~isempty(metrics.riskFactors)
                for i = 1:length(metrics.riskFactors)
                    riskFactorsText = [riskFactorsText, sprintf('     * %s', metrics.riskFactors{i})];
                    if i < length(metrics.riskFactors)
                        riskFactorsText = [riskFactorsText, newline];
                    end
                end
            else
                riskFactorsText = '     * No significant risk factors identified';
            end
            
            % Create metrics text with proper formatting
            metricsText = sprintf([ ...
                '====================================================================\n', ...
                '                         QUALITY METRICS\n', ...
                '====================================================================\n', ...
                '  Grain Size          : %.2f micrometers\n', ...
                '  Roundness           : %.2f (0-1 scale)\n', ...
                '  Color Index         : %.2f (0-1 scale)\n', ...
                '  Purity              : %.2f percent\n', ...
                '--------------------------------------------------------------------\n', ...
                '                     SAND TYPE CLASSIFICATION\n', ...
                '--------------------------------------------------------------------\n', ...
                '  Sand Type           : %s\n', ...
                '--------------------------------------------------------------------\n', ...
                '                     DISASTER PREDICTION\n', ...
                '--------------------------------------------------------------------\n', ...
                '  Risk Level          : %s %s\n', ...
                '  Prediction          : %s\n', ...
                '  Risk Factors        : \n%s\n', ...
                '--------------------------------------------------------------------\n', ...
                '                     THERMAL STATISTICS\n', ...
                '--------------------------------------------------------------------\n', ...
                '  Mean Temperature    : %.2f\n', ...
                '  Peak Temperature    : %.2f\n', ...
                '  Heat Density        : %.2f%%\n', ...
                '--------------------------------------------------------------------\n', ...
                '                     QUALITY GRADE\n', ...
                '--------------------------------------------------------------------\n', ...
                '  Grade               : %s\n', ...
                '--------------------------------------------------------------------\n', ...
                '                     RECOMMENDATION\n', ...
                '--------------------------------------------------------------------\n', ...
                '  %s\n', ...
                '====================================================================\n', ...
                '  Report Generated by Sand Quality Analyzer - Disaster Prediction System\n', ...
                '  Image Source: %s\n', ...
                '===================================================================='], ...
                metrics.grainSize, metrics.roundness, ...
                metrics.colorIndex, metrics.purity * 100, ...
                metrics.sandType, ...
                metrics.riskLevel, riskSymbol, ...
                metrics.disasterPrediction, ...
                riskFactorsText, ...
                metrics.thermalStats.mean, metrics.thermalStats.peak, ...
                metrics.thermalStats.density * 100, ...
                metrics.grade, getRecommendation(metrics.grade), ...
                appData.imageSource);
            
            text(0.05, 0.95, metricsText, 'FontSize', 9, 'VerticalAlignment', 'top', ...
                'FontName', 'Courier New', 'HorizontalAlignment', 'left');
            
            % Save as PDF
            print(pdfFig, pdfPath, '-dpdf', '-bestfit');
            close(pdfFig);
            
            % Update status
            appData.pdfStatusValue.Text = 'PDF Generated Successfully!';
            appData.pdfStatusValue.FontColor = [0 0.6 0];
            appData.reportGenerated = true;
            appData.lastReportPath = pdfPath;
            
            fig.UserData = appData;
            
            % Show success message
            uialert(fig, sprintf('PDF Report saved successfully!\nLocation: %s', pdfPath), ...
                   'PDF Generated', 'Icon', 'success');
            
        catch ME
            appData.pdfStatusValue.Text = 'PDF Generation Failed';
            appData.pdfStatusValue.FontColor = [0.8 0.2 0.2];
            fig.UserData = appData;
            uialert(fig, ['PDF Generation Error: ' ME.message], 'Error', 'Icon', 'error');
        end
    end
    
    function heatMap = generateThermalMap(img)
        % Generate thermal heat map from image
        % Normalize image to 0-1 range
        normImg = double(img) / 255;
        
        % Apply Gaussian smoothing for thermal effect
        h = fspecial('gaussian', [15 15], 3);
        smoothedImg = imfilter(normImg, h, 'replicate');
        
        % Enhance thermal regions
        heatMap = imadjust(smoothedImg, [0.2 0.8], [0 1]);
        
        % Apply colormap transformation
        heatMap = heatMap * 255;
        heatMap = uint8(heatMap);
    end
    
    function stats = calculateThermalStats(heatMap)
        % Calculate thermal statistics
        doubleMap = double(heatMap) / 255;
        stats.mean = mean(doubleMap(:));
        stats.peak = max(doubleMap(:));
        stats.density = sum(doubleMap(:) > 0.7) / numel(doubleMap);
    end
    
    function metrics = calculateSandMetrics(grayImg, rgbImg, edges)
        % Calculate sand quality metrics
        
        % 1. Grain Size Estimation
        stats = regionprops(edges, 'Area');
        if ~isempty(stats)
            areas = [stats.Area];
            areas = areas(areas > 10);
            if ~isempty(areas)
                avgArea = mean(areas);
                grainSize = sqrt(avgArea) * 0.5;
            else
                grainSize = 0.5;
            end
        else
            grainSize = 0.5;
        end
        grainSize = min(max(grainSize, 0.1), 2.0);
        
        % 2. Roundness
        if ~isempty(stats)
            perimeters = regionprops(edges, 'Perimeter');
            if ~isempty(perimeters)
                perim = [perimeters.Perimeter];
                areas = [stats.Area];
                validIdx = perim > 0 & areas > 10;
                if any(validIdx)
                    circularity = 4 * pi * areas(validIdx) ./ (perim(validIdx).^2);
                    % Remove NaN and Inf values
                    circularity = circularity(isfinite(circularity));
                    circularity = circularity(circularity > 0 & circularity <= 1);
                    if ~isempty(circularity)
                        roundness = mean(circularity);
                    else
                        roundness = 0.5;
                    end
                else
                    roundness = 0.5;
                end
            else
                roundness = 0.5;
            end
        else
            roundness = 0.5;
        end
        roundness = min(max(roundness, 0.1), 1.0);
        
        % 3. Color Index
        if size(rgbImg, 3) == 3
            hsv = rgb2hsv(rgbImg);
            hueMean = mean2(hsv(:, :, 1));
            colorIndex = 1 - min(abs(hueMean - 0.12) * 5, 0.9);
        else
            grayMean = mean2(grayImg);
            colorIndex = 1 - min(abs(grayMean - 128) / 128, 0.9);
        end
        colorIndex = min(max(colorIndex, 0.1), 1.0);
        
        % 4. Purity
        stdDev = std(double(grayImg(:)));
        maxStd = 100;
        purity = 1 - min(stdDev / maxStd, 0.9);
        purity = min(max(purity, 0.1), 1.0);
        
        % Package metrics
        metrics = struct();
        metrics.grainSize = grainSize * 100;
        metrics.roundness = roundness;
        metrics.colorIndex = colorIndex;
        metrics.purity = purity;
    end
    
    function [grade, gradeColor] = determineQualityGrade(metrics)
        % Determine quality grade
        score = 0.3 * min(metrics.purity, 1) + ...
                0.3 * min(metrics.roundness, 1) + ...
                0.2 * min(metrics.colorIndex, 1) + ...
                0.2 * (1 - min(metrics.grainSize / 500, 1));
        
        if score >= 0.85
            grade = 'Excellent';
            gradeColor = [0 0.6 0];
        elseif score >= 0.7
            grade = 'Good';
            gradeColor = [0.2 0.6 0.2];
        elseif score >= 0.5
            grade = 'Fair';
            gradeColor = [0.8 0.6 0];
        else
            grade = 'Poor';
            gradeColor = [0.8 0.2 0.2];
        end
    end
    
    function recommendation = getRecommendation(grade)
        switch grade
            case 'Excellent'
                recommendation = 'Ideal for construction and concrete applications.';
            case 'Good'
                recommendation = 'Suitable for most construction applications.';
            case 'Fair'
                recommendation = 'Requires processing or mixing with better quality sand.';
            case 'Poor'
                recommendation = 'Not recommended. Consider washing or sourcing better quality.';
            otherwise
                recommendation = 'Analysis incomplete.';
        end
    end
    
    function resetAll()
        % Reset all data and UI
        appData = fig.UserData;
        
        % Reset original image
        cla(appData.imageAxes1);
        title(appData.imageAxes1, 'No Image Loaded', 'FontSize', round(11*scaleFactor));
        appData.statusLabel1.Text = 'Status: Waiting for input';
        appData.statusLabel1.FontColor = [0.3 0.3 0.3];
        
        % Reset thermal image
        cla(appData.imageAxes2);
        title(appData.imageAxes2, 'No Analysis', 'FontSize', round(11*scaleFactor));
        appData.statusLabel2.Text = 'Status: Waiting for analysis';
        appData.statusLabel2.FontColor = [0.3 0.3 0.3];
        
        % Reset quality grade
        appData.qualityValue.Text = 'Not Analyzed';
        appData.qualityValue.FontColor = [0.5 0.5 0.5];
        
        % Reset sand type
        appData.sandTypeValue.Text = 'Not Classified';
        
        % Reset disaster prediction
        appData.disasterValue.Text = 'Not Predicted';
        appData.disasterValue.FontColor = [0.8 0.2 0.2];
        
        % Reset metrics
        for i = 1:4
            appData.metricValueHandles(i).Text = '---';
        end
        
        % Reset thermal value
        appData.thermalValue.Text = 'Not Analyzed';
        appData.thermalValue.FontColor = [0.8 0.4 0];
        
        % Reset preprocessing
        appData.preprocessValue.Text = 'Waiting...';
        appData.preprocessValue.FontColor = [0.5 0.5 0.5];
        
        % Reset PDF status
        appData.pdfStatusValue.Text = 'Not Generated';
        appData.pdfStatusValue.FontColor = [0.5 0.5 0.5];
        
        % Reset detail text
        appData.detailText.Value = 'Analysis results will appear here...';
        
        % Reset data
        appData.currentImage = [];
        appData.imagePath = '';
        appData.imageLoaded = false;
        appData.analyzed = false;
        appData.reportGenerated = false;
        appData.analysisResults = [];
        appData.imageSource = 'None';
        
        fig.UserData = appData;
        
        uialert(fig, 'All data has been reset successfully!', 'Reset Complete', 'Icon', 'success');
    end
    
end