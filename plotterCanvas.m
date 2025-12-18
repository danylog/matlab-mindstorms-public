function plotterCanvas()

    fig = figure('Name', 'Plotter Canvas', ...
                 'NumberTitle', 'off', ...
                 'Position', [50, 50, 650, 850], ...
                 'Color', 'white', ...
                 'Resize', 'off');  
 
    ax = axes('Parent', fig, ...
              'Units', 'pixels', ...
              'Position', [50, 60, 300, 580], ...
              'XLim', [0 150], ...
              'YLim', [0 290], ...
              'Box', 'on', ...
              'XTick', 0:25:150, ...
              'YTick', 0:50:290, ...
              'GridLineStyle', '-', ...
              'GridAlpha', 0.3);
    axis equal; 
    xlim([0 150]);
    ylim([0 290]);
    grid on;
    hold on;
    xlabel('X (mm)');
    ylabel('Y (mm)');
    
   
    overlayFile = fullfile(fileparts(mfilename('fullpath')), 'overlay.png');
    if exist(overlayFile, 'file')
        try
            img = imread(overlayFile);
           
            imgAx = axes('Parent', fig, ...
                         'Units', 'pixels', ...
                         'Position', [50, 660, 300, 180], ...
                         'Visible', 'off');
            image(imgAx, img);
            axis(imgAx, 'image');  
            set(imgAx, 'XTick', [], 'YTick', []);  
        catch
            warning('Could not load overlay.png');
        end
    end
    
    
    data = struct();
    data.strokes = {};          
    data.currentStroke = [];    
    data.isDrawing = false;     
    data.ax = ax;
    
    data.ev3 = [];              
    data.motorX = [];           
    data.motorY = [];           
    data.motorPen = [];         
    data.touchSensor = [];      
    data.lightSensor = [];      
    data.isConnected = false;
    
    data.xDegreesPerCm = 100.000;
    data.yDegreesPerCm = 83.721;
    
    data.xDirection = 1;       
    data.yDirection = -1;       
    
    data.canvasWidthCm = 15;    
    data.canvasHeightCm = 29;   
    data.canvasMaxX = 150;     
    data.canvasMaxY = 290;     
    
    data.drawSpeed = 50;
    data.moveSpeed = 80;
    data.jogDistance = 10;      
    
   
    data.xSpeedMultiplier = 1.0;
    data.ySpeedMultiplier = 1.0;
    
   
    data.penIsDown = false;
    
   
    data.debugMode = false;
    
    data.overlayImage = [];
    
  
    data.isPaused = false;
    data.isStopped = false;
    data.isPlotting = false;
    
    data.textPlacementMode = false;
    
    fig.UserData = data;
    
    btnX = 380;
    btnW = 120;
    btnH = 30;
    
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Load Paper', ...
              'Position', [btnX, 760, btnW, btnH], ...
              'Callback', @loadPaper);
    
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Unload Paper', ...
              'Position', [btnX+130, 760, btnW, btnH], ...
              'Callback', @unloadPaper);
    
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Clear', ...
              'Position', [btnX, 720, btnW, btnH], ...
              'Callback', @clearCanvas);
    
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Undo Stroke', ...
              'Position', [btnX+btnW+10, 720, btnW, btnH], ...
              'Callback', @undoStroke);
    
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Save', ...
              'Position', [btnX, 685, btnW, btnH], ...
              'Callback', @saveDrawing);
          
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Load', ...
              'Position', [btnX+btnW+10, 685, btnW, btnH], ...
              'Callback', @loadDrawing);
    
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', '--- Plotter ---', ...
              'Position', [btnX, 650, 250, 20], ...
              'BackgroundColor', 'white', ...
              'FontWeight', 'bold');
    
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Connect EV3', ...
              'Position', [btnX, 615, 250, btnH], ...
              'Tag', 'connectBtn', ...
              'Callback', @connectEV3);
    
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Home Position', ...
              'Position', [btnX, 580, 250, btnH], ...
              'Callback', @goHome);
    
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'START DRAWING!', ...
              'Position', [btnX, 535, 250, 40], ...
              'BackgroundColor', [0.5 1 0.5], ...
              'FontWeight', 'bold', ...
              'FontSize', 11, ...
              'Tag', 'startBtn', ...
              'Callback', @startPlotting);
    
    uicontrol('Parent', fig, ...
              'Style', 'togglebutton', ...
              'String', 'Pause', ...
              'Position', [btnX, 500, 120, btnH], ...
              'BackgroundColor', [1 1 0.5], ...
              'Tag', 'pauseBtn', ...
              'Value', 0, ...
              'Callback', @togglePause);
    
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Stop', ...
              'Position', [btnX+130, 500, 120, btnH], ...
              'BackgroundColor', [1 0.5 0.5], ...
              'Tag', 'stopBtn', ...
              'Callback', @stopPlotting);
    
    uicontrol('Parent', fig, ...
              'Style', 'togglebutton', ...
              'String', 'Debug Mode: OFF', ...
              'Position', [btnX, 465, 250, btnH], ...
              'Tag', 'debugToggle', ...
              'Value', 0, ...
              'Callback', @toggleDebug);
    
    % Status labels
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', 'Strokes: 0', ...
              'Position', [btnX, 435, 120, 20], ...
              'Tag', 'strokeCounter', ...
              'BackgroundColor', 'white', ...
              'FontSize', 10);
    
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', 'EV3: Not connected', ...
              'Position', [btnX+125, 435, 125, 20], ...
              'Tag', 'connectionStatus', ...
              'BackgroundColor', 'white', ...
              'ForegroundColor', 'red', ...
              'FontSize', 10);
    
    % Manual motor controls section
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', '--- Manual Control ---', ...
              'Position', [btnX, 405, 250, 20], ...
              'BackgroundColor', 'white', ...
              'FontWeight', 'bold');
    
    % D-pad style jog buttons (centered in 250px wide column)
    padX = btnX + 100;  % Center of 250px column
    padY = 330;
    
    % Y+ button (up)
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Y+', ...
              'Position', [padX, padY+40, 50, 35], ...
              'Callback', {@jogMotor, 'Y', 1});
    
    % X- button (left)
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'X-', ...
              'Position', [padX-55, padY, 50, 35], ...
              'Callback', {@jogMotor, 'X', -1});
    
    % X+ button (right)
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'X+', ...
              'Position', [padX+55, padY, 50, 35], ...
              'Callback', {@jogMotor, 'X', 1});
    
    % Y- button (down)
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Y-', ...
              'Position', [padX, padY-40, 50, 35], ...
              'Callback', {@jogMotor, 'Y', -1});
    
    % Pen controls
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Pen Up', ...
              'Position', [btnX, 250, 80, 35], ...
              'Callback', @manualPenUp);
    
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Pen Down', ...
              'Position', [btnX+90, 250, 80, 35], ...
              'Callback', @manualPenDown);
    
    % Pen state display
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', 'Pen: UP', ...
              'Position', [btnX+175, 250, 75, 35], ...
              'Tag', 'penStatus', ...
              'BackgroundColor', [0.8 1 0.8], ...
              'FontSize', 10, ...
              'FontWeight', 'bold');
    
    % Speed multiplier slider
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', 'Speed:', ...
              'Position', [btnX, 215, 45, 20], ...
              'BackgroundColor', 'white', ...
              'HorizontalAlignment', 'left');
    
    uicontrol('Parent', fig, ...
              'Style', 'slider', ...
              'Position', [btnX+45, 215, 150, 20], ...
              'Tag', 'speedSlider', ...
              'Min', 0.1, ...
              'Max', 2.0, ...
              'Value', 1.0, ...
              'SliderStep', [0.1/1.9, 0.3/1.9], ...
              'Callback', @updateSpeedLabel);
    
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', '100%', ...
              'Position', [btnX+200, 215, 50, 20], ...
              'Tag', 'speedLabel', ...
              'BackgroundColor', 'white', ...
              'FontWeight', 'bold');
    
    % X axis speed multiplier
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', 'X Speed:', ...
              'Position', [btnX, 190, 55, 20], ...
              'BackgroundColor', 'white', ...
              'HorizontalAlignment', 'left');
    
    uicontrol('Parent', fig, ...
              'Style', 'slider', ...
              'Position', [btnX+55, 190, 140, 20], ...
              'Tag', 'xSpeedSlider', ...
              'Min', 0.5, ...
              'Max', 1.5, ...
              'Value', 1.0, ...
              'SliderStep', [0.05/1.0, 0.1/1.0], ...
              'Callback', @updateAxisSpeedLabels);
    
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', '100%', ...
              'Position', [btnX+200, 190, 50, 20], ...
              'Tag', 'xSpeedLabel', ...
              'BackgroundColor', 'white');
    
    % Y axis speed multiplier
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', 'Y Speed:', ...
              'Position', [btnX, 165, 55, 20], ...
              'BackgroundColor', 'white', ...
              'HorizontalAlignment', 'left');
    
    uicontrol('Parent', fig, ...
              'Style', 'slider', ...
              'Position', [btnX+55, 165, 140, 20], ...
              'Tag', 'ySpeedSlider', ...
              'Min', 0.5, ...
              'Max', 1.5, ...
              'Value', 1.0, ...
              'SliderStep', [0.05/1.0, 0.1/1.0], ...
              'Callback', @updateAxisSpeedLabels);
    
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', '100%', ...
              'Position', [btnX+200, 165, 50, 20], ...
              'Tag', 'ySpeedLabel', ...
              'BackgroundColor', 'white');
    
    % === Text Input Section ===
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', '--- Add Text ---', ...
              'Position', [btnX, 140, 250, 20], ...
              'BackgroundColor', 'white', ...
              'FontWeight', 'bold');
    
    % Multiline text input field (on the right side)
    uicontrol('Parent', fig, ...
              'Style', 'edit', ...
              'String', 'HELLO', ...
              'Position', [btnX, 85, 145, 50], ...
              'Tag', 'textInput', ...
              'HorizontalAlignment', 'left', ...
              'Max', 5, ...
              'Min', 0);  % Max > 1 enables multiline
    
    % Font size input
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'String', 'Size:', ...
              'Position', [btnX+150, 115, 35, 20], ...
              'BackgroundColor', 'white');
    
    uicontrol('Parent', fig, ...
              'Style', 'edit', ...
              'String', '15', ...
              'Position', [btnX+185, 112, 40, 25], ...
              'Tag', 'fontSizeInput', ...
              'HorizontalAlignment', 'center');
    
    % Autoposition toggle
    uicontrol('Parent', fig, ...
              'Style', 'togglebutton', ...
              'String', 'Auto', ...
              'Position', [btnX+150, 85, 75, 25], ...
              'Tag', 'autoPositionToggle', ...
              'Value', 1, ...
              'TooltipString', 'Auto-center text on canvas');
    
    % Add Text button
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Add Text', ...
              'Position', [btnX, 50, 250, 30], ...
              'Tag', 'addTextBtn', ...
              'FontWeight', 'bold', ...
              'Callback', @addTextToCanvas);

    % --- Ask AI (Deepseek) button at very bottom ---
    uicontrol('Parent', fig, ...
              'Style', 'pushbutton', ...
              'String', 'Ask AI', ...
              'Position', [btnX, 10, 250, 35], ...
              'Callback', @askDeepseek);
    
    % Set mouse callbacks
    set(fig, 'WindowButtonDownFcn', @startDrawing);
    set(fig, 'WindowButtonMotionFcn', @continueDrawing);
    set(fig, 'WindowButtonUpFcn', @stopDrawing);

end



%% Mouse Callbacks

function startDrawing(src, ~)
    data = src.UserData;
    
    % Check if we're in text placement mode
    if data.textPlacementMode
        placeTextAtClick(src);
        return;
    end
    
    % Check if click is within axes
    pt = get(data.ax, 'CurrentPoint');
    x = pt(1,1);
    y = pt(1,2);
    
    xlim = get(data.ax, 'XLim');
    ylim = get(data.ax, 'YLim');
    
    if x >= xlim(1) && x <= xlim(2) && y >= ylim(1) && y <= ylim(2)
        data.isDrawing = true;
        data.currentStroke = [x, y];
        src.UserData = data;
    end
end

function continueDrawing(src, ~)
    data = src.UserData;
    
    if data.isDrawing
        pt = get(data.ax, 'CurrentPoint');
        x = pt(1,1);
        y = pt(1,2);
        
        % Clamp to axes limits
        xlim = get(data.ax, 'XLim');
        ylim = get(data.ax, 'YLim');
        x = max(xlim(1), min(xlim(2), x));
        y = max(ylim(1), min(ylim(2), y));
        
        % Add point to current stroke
        data.currentStroke = [data.currentStroke; x, y];
        
        % Draw line segment
        if size(data.currentStroke, 1) >= 2
            plot(data.ax, ...
                 data.currentStroke(end-1:end, 1), ...
                 data.currentStroke(end-1:end, 2), ...
                 'b-', 'LineWidth', 2);
        end
        
        src.UserData = data;
    end
end

function stopDrawing(src, ~)
    data = src.UserData;
    
    if data.isDrawing && size(data.currentStroke, 1) >= 2
        % Save completed stroke
        data.strokes{end+1} = data.currentStroke;
        updateStrokeCounter(src, length(data.strokes));
    end
    
    data.isDrawing = false;
    data.currentStroke = [];
    src.UserData = data;
end

%% Button Callbacks

function clearCanvas(src, ~)
    fig = ancestor(src, 'figure');
    data = fig.UserData;
    
    % Clear axes
    cla(data.ax);
    grid(data.ax, 'on');
    hold(data.ax, 'on');
    
    % Reset data
    data.strokes = {};
    data.currentStroke = [];
    data.isDrawing = false;
    fig.UserData = data;
    
    updateStrokeCounter(fig, 0);
    disp('Canvas cleared');
end

function undoStroke(src, ~)
    fig = ancestor(src, 'figure');
    data = fig.UserData;
    
    if ~isempty(data.strokes)
        % Remove last stroke
        data.strokes(end) = [];
        fig.UserData = data;
        
        % Redraw all strokes
        redrawCanvas(fig);
        updateStrokeCounter(fig, length(data.strokes));
        disp('Last stroke undone');
    end
end

function exportPoints(src, ~)
    fig = ancestor(src, 'figure');
    data = fig.UserData;
    
    if isempty(data.strokes)
        disp('No strokes to export!');
        return;
    end
    
    % Convert strokes to point matrix with pen up/down info
    allPoints = [];
    penDown = [];
    
    for i = 1:length(data.strokes)
        stroke = data.strokes{i};
        
        % Add pen down points for this stroke
        allPoints = [allPoints; stroke];
        penDown = [penDown; ones(size(stroke, 1), 1)];
        
        % If not last stroke, add pen up movement to next stroke start
        if i < length(data.strokes)
            nextStart = data.strokes{i+1}(1, :);
            allPoints = [allPoints; nextStart];
            penDown = [penDown; 0];
        end
    end
    
    % Create export structure
    drawing = struct();
    drawing.points = allPoints;
    drawing.penDown = penDown;
    drawing.strokes = data.strokes;
    drawing.numStrokes = length(data.strokes);
    drawing.numPoints = size(allPoints, 1);
    
    % Save to workspace
    assignin('base', 'drawing', drawing);
    
    disp(['Exported ' num2str(drawing.numPoints) ' points from ' ...
          num2str(drawing.numStrokes) ' strokes to variable "drawing"']);
end

function saveDrawing(src, ~)
    fig = ancestor(src, 'figure');
    data = fig.UserData;
    
    if isempty(data.strokes)
        disp('No strokes to save!');
        return;
    end
    
    [filename, pathname] = uiputfile('*.mat', 'Save Drawing');
    if filename ~= 0
        strokes = data.strokes;
        save(fullfile(pathname, filename), 'strokes');
        disp(['Drawing saved to ' filename]);
    end
end

function loadDrawing(src, ~)
    fig = ancestor(src, 'figure');
    
    [filename, pathname] = uigetfile('*.mat', 'Load Drawing');
    if filename ~= 0
        loaded = load(fullfile(pathname, filename));
        if isfield(loaded, 'strokes')
            data = fig.UserData;
            data.strokes = loaded.strokes;
            fig.UserData = data;
            
            redrawCanvas(fig);
            updateStrokeCounter(fig, length(data.strokes));
            disp(['Drawing loaded from ' filename]);
        else
            disp('Invalid file format');
        end
    end
end

%% Helper Functions

% --- Ask Deepseek (AI) callback ---
function askDeepseek(src, ~)
    fig = ancestor(src, 'figure');
    
    % Create custom dialog for prompt and role selection
    dlgFig = figure('Name', 'Ask Deepseek', ...
                    'NumberTitle', 'off', ...
                    'Position', [400, 400, 400, 150], ...
                    'MenuBar', 'none', ...
                    'ToolBar', 'none', ...
                    'Resize', 'off', ...
                    'WindowStyle', 'modal');
    
    % Prompt label and text field
    uicontrol('Parent', dlgFig, 'Style', 'text', ...
              'String', 'Prompt for AI:', ...
              'Position', [10, 110, 380, 20], ...
              'HorizontalAlignment', 'left');
    
    promptEdit = uicontrol('Parent', dlgFig, 'Style', 'edit', ...
              'Position', [10, 85, 380, 25], ...
              'HorizontalAlignment', 'left');
    
    % Role dropdown
    uicontrol('Parent', dlgFig, 'Style', 'text', ...
              'String', 'Role:', ...
              'Position', [10, 55, 50, 20], ...
              'HorizontalAlignment', 'left');
    
    roleOptions = {'Answer ONLY with the final result in PLAIN TEXT. No explanation, no steps, no words - just the answer itself.', ...
                   'Provides complete answers in German in PLAIN TEXT'};
    rolePopup = uicontrol('Parent', dlgFig, 'Style', 'popupmenu', ...
              'String', roleOptions, ...
              'Position', [60, 55, 330, 25], ...
              'Value', 1);
    
    % OK and Cancel buttons
    uicontrol('Parent', dlgFig, 'Style', 'pushbutton', ...
              'String', 'OK', ...
              'Position', [220, 15, 80, 30], ...
              'Callback', @(~,~) uiresume(dlgFig));
    
    uicontrol('Parent', dlgFig, 'Style', 'pushbutton', ...
              'String', 'Cancel', ...
              'Position', [310, 15, 80, 30], ...
              'Callback', @(~,~) delete(dlgFig));
    
    % Wait for user
    uiwait(dlgFig);
    
    % Check if dialog was closed
    if ~isvalid(dlgFig)
        return;
    end
    
    % Get values
    promptText = get(promptEdit, 'String');
    roleIdx = get(rolePopup, 'Value');
    roleText = roleOptions{roleIdx};
    
    % Close dialog
    delete(dlgFig);
    
    if isempty(promptText)
        return;
    end

    % Show loading indicator in text box with animated dots
    textInput = findobj(fig, 'Tag', 'textInput');
    if ~isempty(textInput)
        set(textInput, 'String', 'Loading');
        drawnow;
    end
    
    % Create timer for animated loading dots
    dotCount = 0;
    loadingTimer = timer('ExecutionMode', 'fixedRate', ...
                         'Period', 0.4, ...
                         'TimerFcn', @(~,~) updateLoadingDots());
    start(loadingTimer);
    
    function updateLoadingDots()
        dotCount = mod(dotCount, 3) + 1;
        dots = repmat('.', 1, dotCount);
        if isvalid(textInput)
            set(textInput, 'String', ['Loading' dots]);
            drawnow;
        end
    end

    try
        answer = queryDeepseek(promptText, roleText);
        
        % Stop loading animation
        stop(loadingTimer);
        delete(loadingTimer);

        % Normalize answer to a single char array
        if isstring(answer)
            answerStr = char(answer);
        elseif ischar(answer)
            answerStr = answer;
        else
            answerStr = char(string(answer));
        end

        % Split into lines and remove trailing empty line from splitlines
        lines = splitlines(answerStr);
        if ~isempty(lines) && lines(end) == ""
            lines(end) = [];
        end
        if isempty(lines)
            lines = "";
        end

        % Convert to a 2-D char array (rows = lines), suitable for multiline edit box
        textChar = char(lines);  % pads shorter rows with spaces

        % Set the text into the multiline edit control so user can place it on canvas later
        textInput = findobj(fig, 'Tag', 'textInput');
        if ~isempty(textInput)
            set(textInput, 'String', textChar);
        end

        % Also display in the command window
        disp(answerStr);

    catch err
        % Stop loading animation on error
        stop(loadingTimer);
        delete(loadingTimer);
        if ~isempty(textInput) && isvalid(textInput)
            set(textInput, 'String', 'Error');
        end
        warning('Deepseek call failed: %s', err.message);
    end
end


function answer = queryDeepseek(prompt, role)
    answer = '';
    
    % API Key aus externer Datei laden
    keyFile = fullfile(fileparts(mfilename('fullpath')), 'apikey.txt');
    if ~exist(keyFile, 'file')
        error('apikey.txt nicht gefunden');
    end
    apiKey = strtrim(fileread(keyFile));

    url = "https://openrouter.ai/api/v1/chat/completions"; 
    headers = [ ...
        "Authorization", "Bearer " + apiKey; ...
        "Content-Type",  "application/json"; ...
        "HTTP-Referer",  "http://localhost"; ...
        "X-Title",       "MATLAB-Plotter" ...
    ];

    opts = weboptions( ...
        "HeaderFields", headers, ...
        "MediaType", "application/json", ...
        "Timeout", 60);

    % Build request body - use role as system message, prompt as user message
    messages = [ ...
        struct("role","system","content",string(role)), ...
        struct("role","user","content", string(prompt)) ...
    ];
    body = struct( ...
        "model", "nex-agi/deepseek-v3.1-nex-n1:free", ...
        "messages", messages ...
    );

    try
        resp = webwrite(url, body, opts);
        % Defensive parsing: expect resp.choices(1).message.content
        if isfield(resp, "choices") && ~isempty(resp.choices) ...
                && isfield(resp.choices(1), "message") ...
                && isfield(resp.choices(1).message, "content")
            % Ensure char output
            content = resp.choices(1).message.content;
            if isstring(content) || ischar(content)
                answer = char(content);
            else
                answer = jsonencode(content);
            end
        else
            warning('Unexpected response format from Deepseek.');
        end
    catch err
        warning('Deepseek request failed: %s', err.message);
    end
end

function redrawCanvas(fig)
    data = fig.UserData;
    
    % Clear and redraw
    cla(data.ax);
    grid(data.ax, 'on');
    hold(data.ax, 'on');
    
    % Redraw all strokes
    for i = 1:length(data.strokes)
        stroke = data.strokes{i};
        plot(data.ax, stroke(:,1), stroke(:,2), 'b-', 'LineWidth', 2);
    end
end

function updateStrokeCounter(fig, count)
    counter = findobj(fig, 'Tag', 'strokeCounter');
    if ~isempty(counter)
        counter.String = ['Strokes: ' num2str(count)];
    end
end

function updateSpeedLabel(src, ~)
    fig = ancestor(src, 'figure');
    speedLabel = findobj(fig, 'Tag', 'speedLabel');
    if ~isempty(speedLabel)
        speedLabel.String = [num2str(round(src.Value * 100)) '%'];
    end
end

function updateAxisSpeedLabels(src, ~)
    fig = ancestor(src, 'figure');
    data = fig.UserData;
    
    % Update X speed
    xSlider = findobj(fig, 'Tag', 'xSpeedSlider');
    xLabel = findobj(fig, 'Tag', 'xSpeedLabel');
    if ~isempty(xSlider) && ~isempty(xLabel)
        data.xSpeedMultiplier = get(xSlider, 'Value');
        xLabel.String = [num2str(round(data.xSpeedMultiplier * 100)) '%'];
    end
    
    % Update Y speed
    ySlider = findobj(fig, 'Tag', 'ySpeedSlider');
    yLabel = findobj(fig, 'Tag', 'ySpeedLabel');
    if ~isempty(ySlider) && ~isempty(yLabel)
        data.ySpeedMultiplier = get(ySlider, 'Value');
        yLabel.String = [num2str(round(data.ySpeedMultiplier * 100)) '%'];
    end
    
    fig.UserData = data;
end

%% Plotter Control Functions

function connectEV3(src, ~)
    fig = ancestor(src, 'figure');
    data = fig.UserData;
    
    try
        disp('Connecting to EV3...');
        data.ev3 = EV3();
        data.ev3.connect('usb');
        
        % Setup motors
        data.motorX = data.ev3.motorA;
        data.motorY = data.ev3.motorD;
        data.motorPen = data.ev3.motorC;
        
        % Setup sensors
        data.touchSensor = data.ev3.sensor2;
        data.touchSensor.mode = DeviceMode.Touch.Pushed;
        
        data.lightSensor = data.ev3.sensor1;
        data.lightSensor.mode = DeviceMode.Color.Reflect;
        
        % Configure X motor
        data.motorX.limitMode = 'Tacho';
        data.motorX.brakeMode = 'Brake';
        
        % Configure Y motor
        data.motorY.limitMode = 'Tacho';
        data.motorY.brakeMode = 'Brake';
        
        % Configure Pen motor
        data.motorPen.limitMode = 'Tacho';
        data.motorPen.brakeMode = 'Brake';
        
        data.isConnected = true;
        fig.UserData = data;
        
        % Update status
        statusLabel = findobj(fig, 'Tag', 'connectionStatus');
        statusLabel.String = 'EV3: Connected';
        statusLabel.ForegroundColor = [0 0.6 0];
        
        data.ev3.beep();
        disp('EV3 connected successfully!');
        disp('Run "Home Position" to calibrate axes.');
        
    catch err
        disp(['Connection failed: ' err.message]);
        data.isConnected = false;
        fig.UserData = data;
    end
end

function toggleDebug(src, ~)
    fig = ancestor(src, 'figure');
    data = fig.UserData;
    
    data.debugMode = src.Value == 1;
    fig.UserData = data;
    
    if data.debugMode
        src.String = 'Debug Mode: ON';
        src.BackgroundColor = [1 1 0.5];
        disp('Debug mode enabled - no EV3 needed');
    else
        src.String = 'Debug Mode: OFF';
        src.BackgroundColor = [0.94 0.94 0.94];
        disp('Debug mode disabled');
    end
end

function togglePause(src, ~)
    fig = ancestor(src, 'figure');
    data = fig.UserData;
    
    data.isPaused = src.Value == 1;
    fig.UserData = data;
    
    if data.isPaused
        src.String = 'Resume';
        src.BackgroundColor = [0.5 1 0.5];
        disp('Plotting PAUSED - click Resume to continue');
    else
        src.String = 'Pause';
        src.BackgroundColor = [1 1 0.5];
        disp('Plotting RESUMED');
    end
end

function stopPlotting(src, ~)
    fig = ancestor(src, 'figure');
    data = fig.UserData;
    
    data.isStopped = true;
    data.isPaused = false;
    fig.UserData = data;
    
    % Reset pause button
    pauseBtn = findobj(fig, 'Tag', 'pauseBtn');
    if ~isempty(pauseBtn)
        pauseBtn.Value = 0;
        pauseBtn.String = 'Pause';
        pauseBtn.BackgroundColor = [1 1 0.5];
    end
    
    disp('STOP requested - plotting will stop after current movement');
end

function shouldContinue = checkPlotState(fig)
    % Check if we should continue plotting
    data = fig.UserData;
    
    % If stopped, return false
    if data.isStopped
        shouldContinue = false;
        return;
    end
    
    % If paused, wait until resumed or stopped
    while data.isPaused && ~data.isStopped
        pause(0.1);
        drawnow;  % Process UI events
        data = fig.UserData;  % Refresh data
    end
    
    shouldContinue = ~data.isStopped;
end

function startPlotting(src, ~)
    fig = ancestor(src, 'figure');
    data = fig.UserData;
    
    if ~data.isConnected && ~data.debugMode
        disp('Please connect to EV3 first (or enable Debug Mode)!');
        return;
    end
    
    if isempty(data.strokes)
        disp('No strokes to draw!');
        return;
    end
    
    % Reset control flags
    data.isPaused = false;
    data.isStopped = false;
    data.isPlotting = true;
    fig.UserData = data;
    
    % Reset pause button state
    pauseBtn = findobj(fig, 'Tag', 'pauseBtn');
    if ~isempty(pauseBtn)
        pauseBtn.Value = 0;
        pauseBtn.String = 'Pause';
        pauseBtn.BackgroundColor = [1 1 0.5];
    end
    
    disp('Starting to draw...');
    
    % Get speed multiplier from slider
    speedSlider = findobj(fig, 'Tag', 'speedSlider');
    speedMultiplier = get(speedSlider, 'Value');
    actualDrawSpeed = round(data.drawSpeed * speedMultiplier);
    actualMoveSpeed = round(data.moveSpeed * speedMultiplier);
    disp(['Speed multiplier: ' num2str(speedMultiplier*100, '%.0f') '% | Draw: ' num2str(actualDrawSpeed) ' | Move: ' num2str(actualMoveSpeed)]);
    
    % In debug mode, clear and prepare for visualization
    if data.debugMode
        redrawCanvas(fig);
        hold(data.ax, 'on');
    end
    
    % After homing, we are at canvas (0, 0) with tacho (0, 0)
    % For debug visualization tracking
    debugCurrentX = 0;
    debugCurrentY = 0;
    
    % Process each stroke
    for strokeIdx = 1:length(data.strokes)
        % Check pause/stop state
        if ~checkPlotState(fig)
            disp('Plotting stopped by user');
            break;
        end
        
        stroke = data.strokes{strokeIdx};
        
        % Move to start of stroke (pen up)
        startX = stroke(1, 1);
        startY = stroke(1, 2);
        
        disp(['[PEN UP] Move to stroke ' num2str(strokeIdx) ' start: (' ...
              num2str(startX, '%.1f') ', ' num2str(startY, '%.1f') ')']);
        
        if data.debugMode
            % Draw pen-up movement as red dashed line
            plot(data.ax, [debugCurrentX, startX], [debugCurrentY, startY], ...
                 'r--', 'LineWidth', 1);
            plot(data.ax, startX, startY, 'ro', 'MarkerSize', 8);
            drawnow;
            pause(0.1);
            debugCurrentX = startX;
            debugCurrentY = startY;
        else
            penUp(data, fig);
            moveToAbsolutePosition(data, startX, startY, actualMoveSpeed);
        end
        
        disp('[PEN DOWN]');
        if ~data.debugMode
            penDown(data, fig);
        end
        
        % Draw the stroke
        for i = 2:size(stroke, 1)
            % Check pause/stop state
            if ~checkPlotState(fig)
                disp('Plotting stopped by user');
                break;
            end
            
            targetX = stroke(i, 1);
            targetY = stroke(i, 2);
            
            if data.debugMode
                % Draw pen-down movement as green solid line
                plot(data.ax, [debugCurrentX, targetX], [debugCurrentY, targetY], ...
                     'g-', 'LineWidth', 3);
                drawnow;
                pause(0.02);
                debugCurrentX = targetX;
                debugCurrentY = targetY;
            else
                moveToAbsolutePosition(data, targetX, targetY, actualDrawSpeed);
            end
        end
        
        disp(['Stroke ' num2str(strokeIdx) ' complete | ' ...
              num2str(size(stroke,1)) ' points']);
        
        % Check if stopped mid-stroke
        data = fig.UserData;
        if data.isStopped
            break;
        end
    end
    
    % Check final state
    data = fig.UserData;
    
    % Return home (unless stopped)
    % Home is now at (0, 0)
    if ~data.isStopped
        homeX = 0;
        homeY = 0;
        
        disp('[PEN UP] Return home (0, 0)');
        
        if data.debugMode
            plot(data.ax, [debugCurrentX, homeX], [debugCurrentY, homeY], 'r--', 'LineWidth', 1);
            plot(data.ax, homeX, homeY, 'rs', 'MarkerSize', 12, 'LineWidth', 2);
            drawnow;
        else
            penUp(data, fig);
            moveToAbsolutePosition(data, homeX, homeY, actualMoveSpeed);
            data.ev3.beep();
        end
        
        disp('Done!');
    else
        disp('Plotting was stopped - not returning home');
        if ~data.debugMode && data.isConnected
            penUp(data, fig);  % Lift pen if stopped
        end
    end
    
    % Refresh data after penUp calls, then reset plotting flag
    data = fig.UserData;
    data.isPlotting = false;
    fig.UserData = data;
end

function goHome(src, ~)
    fig = ancestor(src, 'figure');
    data = fig.UserData;
    
    if ~data.isConnected
        disp('Please connect to EV3 first!');
        return;
    end
    
    disp('Starting homing routine...');
    homingSpeed = 50;
    
    % Step 1: Move X axis until touch sensor is pressed (stopper reached)
    disp('Homing X axis (moving to stopper)...');
    data.motorX.limitValue = 0;  % 0 = run indefinitely
    data.motorX.power = homingSpeed * data.xDirection;
    data.motorX.start();
    
    while data.touchSensor.value == 0
        pause(0.05);
    end
    
    data.motorX.stop();
    disp('X axis at stopper!');
    
    % Step 2: Move Y axis until light sensor detects no paper (< 30)
    disp('Homing Y axis (moving to paper edge)...');
    data.motorY.limitValue = 0;  % 0 = run indefinitely
    data.motorY.power = -homingSpeed * data.yDirection;
    data.motorY.start();
    
    while data.lightSensor.value >= 30
        pause(0.05);
    end
    
    data.motorY.stop();
    disp('Y axis at paper edge!');
    
    % Step 3: Move Y by -20mm (sensor is 20mm above actual Y=0)
    disp('Adjusting Y by -20mm...');
    yOffsetMm = -30;  % mm offset from sensor to actual origin (negative = move back)
    yOffsetDeg = round(abs(yOffsetMm) * 0.1 * data.yDegreesPerCm);  % 0.1 cm per mm
    % Power sign based on offset direction
    if yOffsetMm >= 0
        data.motorY.power = homingSpeed * data.yDirection;
    else
        data.motorY.power = -homingSpeed * data.yDirection;
    end
    data.motorY.limitValue = yOffsetDeg;
    data.motorY.start();
    data.motorY.waitFor();
    data.motorY.stop();
    
    % Step 4: Move to canvas position (0, 0)
    % From stopper, we need to move to the drawing origin
    disp('Moving to canvas origin (0, 0)...');
    cmPerUnit = data.canvasWidthCm / data.canvasMaxX;
    
    % Move X from stopper (at canvas 150) to canvas 0
    % Distance = 150 units = 15 cm
    xDistDeg = round(data.canvasMaxX * cmPerUnit * data.xDegreesPerCm);
    data.motorX.power = -homingSpeed * data.xDirection;  % Opposite direction
    data.motorX.limitValue = xDistDeg;
    data.motorX.start();
    data.motorX.waitFor();
    data.motorX.stop();
    
    % Y is already at 0 (paper edge = canvas Y=0)
    
    % Step 4: Reset tacho counters at (0, 0)
    data.motorX.resetTachoCount();
    data.motorY.resetTachoCount();
    
    disp('Homing complete! Tacho reset at canvas origin (0, 0).');
    data.ev3.beep();
end

function moveToAbsolutePosition(data, targetX, targetY, speed)
    % Move to absolute canvas position using tacho counters
    % After homing, tacho (0, 0) = canvas (0, 0)
    % Start both motors together for diagonal movement
    
    cmPerUnit = data.canvasWidthCm / data.canvasMaxX;
    
    % Calculate target tacho positions
    targetXtacho = round(targetX * cmPerUnit * data.xDegreesPerCm * data.xDirection);
    targetYtacho = round(targetY * cmPerUnit * data.yDegreesPerCm * data.yDirection);
    
    % Read current tacho positions
    currentXtacho = data.motorX.tachoCount;
    currentYtacho = data.motorY.tachoCount;
    
    % Calculate deltas (in tacho degrees)
    deltaXtacho = targetXtacho - currentXtacho;
    deltaYtacho = targetYtacho - currentYtacho;
    
    absXtacho = abs(deltaXtacho);
    absYtacho = abs(deltaYtacho);
    
    if absXtacho == 0 && absYtacho == 0
        return;  % No movement needed
    end
    
    xSpeedMult = data.xSpeedMultiplier;
    ySpeedMult = data.ySpeedMultiplier;
    
    if absXtacho == 0
        speedX = 0;
        speedY = speed * ySpeedMult;
    elseif absYtacho == 0
        speedX = speed * xSpeedMult;
        speedY = 0;
    elseif absXtacho >= absYtacho
        speedX = speed * xSpeedMult;
        speedY = round(speed * ySpeedMult * absYtacho / absXtacho);
        speedY = max(speedY, 10);
    else
        speedY = speed * ySpeedMult;
        speedX = round(speed * xSpeedMult * absXtacho / absYtacho);
        speedX = max(speedX, 10);
    end
    
    speedX = min(max(round(speedX), 0), 100);
    speedY = min(max(round(speedY), 0), 100);
    
    if deltaXtacho >= 0
        data.motorX.power = speedX;
    else
        data.motorX.power = -speedX;
    end
    
    if deltaYtacho >= 0
        data.motorY.power = speedY;
    else
        data.motorY.power = -speedY;
    end
    
    data.motorX.limitValue = absXtacho;
    data.motorY.limitValue = absYtacho;
    
    if absXtacho > 0
        data.motorX.start();
    end
    if absYtacho > 0
        data.motorY.start();
    end
    
    if absXtacho > 0
        data.motorX.waitFor();
    end
    if absYtacho > 0
        data.motorY.waitFor();
    end
    
    data.motorX.stop();
    data.motorY.stop();
end

function penUp(data, fig)
    % Get fresh state from figure
    if nargin >= 2 && ~isempty(fig)
        data = fig.UserData;
    end
    
    % Check if already up
    if ~data.penIsDown
        return;  % Already up, do nothing
    end
    
    data.motorPen.power = 20;
    data.motorPen.limitValue = 180;
    data.motorPen.start();
    data.motorPen.waitFor();
    data.motorPen.stop();
    
    % Update state
    data.penIsDown = false;
    if nargin >= 2 && ~isempty(fig)
        fig.UserData = data;
        updatePenStatus(fig, false);
    end
end

function penDown(data, fig)
    % Get fresh state from figure
    if nargin >= 2 && ~isempty(fig)
        data = fig.UserData;
    end
    
    % Check if already down
    if data.penIsDown
        return;  
    end
    
    data.motorPen.power = -20;
    data.motorPen.limitValue = 180;
    data.motorPen.start();
    data.motorPen.waitFor();
    data.motorPen.stop();
    
    % Update state
    data.penIsDown = true;
    if nargin >= 2 && ~isempty(fig)
        fig.UserData = data;
        updatePenStatus(fig, true);
    end
end

function updatePenStatus(fig, isDown)
    penStatus = findobj(fig, 'Tag', 'penStatus');
    if ~isempty(penStatus)
        if isDown
            penStatus.String = 'Pen: DOWN';
            penStatus.BackgroundColor = [1 0.8 0.8];
        else
            penStatus.String = 'Pen: UP';
            penStatus.BackgroundColor = [0.8 1 0.8];
        end
    end
end

%% Manual Control Functions

function jogMotor(src, ~, axis, direction)
    fig = ancestor(src, 'figure');
    data = fig.UserData;
    
    if ~data.isConnected
        disp('Please connect to EV3 first!');
        return;
    end
    
    % Calculate distance in degrees (round to prevent drift)
    cmPerUnit = data.canvasWidthCm / data.canvasMaxX;
    distCm = data.jogDistance * cmPerUnit;
    
    if axis == 'X'
        distDeg = round(distCm * data.xDegreesPerCm);
        data.motorX.power = direction * data.moveSpeed * data.xDirection;
        data.motorX.limitValue = distDeg;
        data.motorX.start();
        data.motorX.waitFor();
        data.motorX.stop();
        disp(['Jogged X ' num2str(direction * data.jogDistance) ' units | Tacho: ' num2str(data.motorX.tachoCount)]);
    else
        distDeg = round(distCm * data.yDegreesPerCm);
        data.motorY.power = direction * data.moveSpeed * data.yDirection;
        data.motorY.limitValue = distDeg;
        data.motorY.start();
        data.motorY.waitFor();
        data.motorY.stop();
        disp(['Jogged Y ' num2str(direction * data.jogDistance) ' units']);
    end
end

function manualPenUp(src, ~)
    fig = ancestor(src, 'figure');
    data = fig.UserData;
    
    if ~data.isConnected
        disp('Please connect to EV3 first!');
        return;
    end
    
    penUp(data, fig);
    disp('Pen UP');
end

function manualPenDown(src, ~)
    fig = ancestor(src, 'figure');
    data = fig.UserData;
    
    if ~data.isConnected
        disp('Please connect to EV3 first!');
        return;
    end
    
    penDown(data, fig);
    disp('Pen DOWN');
end

%% Text Functions

function enableTextPlacement(src, ~)
    fig = ancestor(src, 'figure');
    data = fig.UserData;
    
    data.textPlacementMode = ~data.textPlacementMode;
    fig.UserData = data;
    
    addTextBtn = findobj(fig, 'Tag', 'addTextBtn');
    if data.textPlacementMode
        addTextBtn.BackgroundColor = [1 1 0.5];
        addTextBtn.String = 'Click canvas...';
        disp('Text placement mode ON - click on canvas to place text');
    else
        addTextBtn.BackgroundColor = [0.94 0.94 0.94];
        addTextBtn.String = 'Add Text';
        disp('Text placement mode OFF');
    end
end

function addTextToCanvas(src, ~)
    fig = ancestor(src, 'figure');
    data = fig.UserData;
    
    autoToggle = findobj(fig, 'Tag', 'autoPositionToggle');
    autoPosition = get(autoToggle, 'Value') == 1;
    
    if autoPosition
        placeTextAuto(fig);
    else
        enableTextPlacement(src, []);
    end
end

function placeTextAuto(fig)
    data = fig.UserData;
    
    % Get text and font size from inputs
    textInput = findobj(fig, 'Tag', 'textInput');
    fontSizeInput = findobj(fig, 'Tag', 'fontSizeInput');
    
    textContent = get(textInput, 'String');
    fontSize = str2double(get(fontSizeInput, 'String'));
    
    if isempty(textContent) || (ischar(textContent) && isempty(strtrim(textContent)))
        disp('No text entered!');
        return;
    end
    
    if isnan(fontSize) || fontSize <= 0
        fontSize = 15;
        disp('Invalid font size, using default 15');
    end
    
    
    charWidth = fontSize * 0.6;
    spacing = 1.2;
    lineSpacing = 1.5;
    
    
    if ischar(textContent)
        numLines = size(textContent, 1);
        maxChars = 0;
        for r = 1:numLines
            lineLen = length(strtrim(textContent(r, :)));
            maxChars = max(maxChars, lineLen);
        end
    else
        numLines = 1;
        maxChars = length(char(textContent));
    end
    
    textWidth = maxChars * charWidth * spacing;
    textHeight = numLines * fontSize * lineSpacing;
    
    % Center on canvas
    xlims = get(data.ax, 'XLim');
    ylims = get(data.ax, 'YLim');
    canvasWidth = xlims(2) - xlims(1);
    canvasHeight = ylims(2) - ylims(1);
    
    x = (canvasWidth - textWidth) / 2 + xlims(1);
    y = (canvasHeight + textHeight) / 2 + ylims(1); 
    
    try
        textStrokes = textEngine(textContent, x, y, fontSize, spacing, lineSpacing);
    catch err
        disp(['Text engine error: ' err.message]);
        return;
    end
    
    addTextStrokesToCanvas(fig, textStrokes, x, y);
end

function placeTextAtClick(fig)
    data = fig.UserData;
    
    % Get click position
    pt = get(data.ax, 'CurrentPoint');
    x = pt(1,1);
    y = pt(1,2);
    
    % Check if within canvas bounds
    xlims = get(data.ax, 'XLim');
    ylims = get(data.ax, 'YLim');
    
    if x < xlims(1) || x > xlims(2) || y < ylims(1) || y > ylims(2)
        disp('Click was outside canvas - try again');
        return;
    end
    
    textInput = findobj(fig, 'Tag', 'textInput');
    fontSizeInput = findobj(fig, 'Tag', 'fontSizeInput');
    
    textContent = get(textInput, 'String');
    fontSize = str2double(get(fontSizeInput, 'String'));
    
    if isempty(textContent) || (ischar(textContent) && isempty(strtrim(textContent)))
        disp('No text entered!');
        return;
    end
    
    if isnan(fontSize) || fontSize <= 0
        fontSize = 15;
        disp('Invalid font size, using default 15');
    end
    
    try
        textStrokes = textEngine(textContent, x, y, fontSize);
    catch err
        disp(['Text engine error: ' err.message]);
        return;
    end
    
    addTextStrokesToCanvas(fig, textStrokes, x, y);
    
    data = fig.UserData;
    data.textPlacementMode = false;
    fig.UserData = data;
    
    addTextBtn = findobj(fig, 'Tag', 'addTextBtn');
    addTextBtn.BackgroundColor = [0.94 0.94 0.94];
    addTextBtn.String = 'Add Text';
end

function addTextStrokesToCanvas(fig, textStrokes, x, y)
    data = fig.UserData;
    
    if isempty(textStrokes)
        disp('No strokes generated for text');
        return;
    end
    
    xlims = get(data.ax, 'XLim');
    ylims = get(data.ax, 'YLim');
    
    addedCount = 0;
    for i = 1:length(textStrokes)
        stroke = textStrokes{i};
        
        stroke(:, 1) = max(xlims(1), min(xlims(2), stroke(:, 1)));
        stroke(:, 2) = max(ylims(1), min(ylims(2), stroke(:, 2)));
        
        if size(stroke, 1) >= 2
            data.strokes{end+1} = stroke;
            addedCount = addedCount + 1;
        end
    end
    
    fig.UserData = data;
    
    redrawCanvas(fig);
    updateStrokeCounter(fig, length(data.strokes));
    
    disp(['Added text at (' num2str(x, '%.1f') ', ' num2str(y, '%.1f') ') with ' num2str(addedCount) ' strokes']);
end
function loadPaper(src, ~)
    fig = ancestor(src, 'figure');
    data = fig.UserData;
    
    if ~data.isConnected
        disp('Please connect to EV3 first!');
        return;
    end
    
    disp('Loading paper (moving Y until sensor stops detecting - like homing)...');
    loadSpeed = 40;
    
    data.motorY.limitValue = 0; 
    data.motorY.power = -loadSpeed * data.yDirection;  
    data.motorY.start();
    
    while data.lightSensor.value >= 30
        pause(0.05);
    end
    
    data.motorY.stop();
    disp('Paper edge found!');
    data.ev3.beep();
end

function unloadPaper(src, ~)
    fig = ancestor(src, 'figure');
    data = fig.UserData;
    
    if ~data.isConnected
        disp('Please connect to EV3 first!');
        return;
    end
    
    disp('Unloading paper (moving Y until sensor detects paper)...');
    unloadSpeed = 40;
    
    data.motorY.limitValue = 360*7;  % Run indefinitely
    data.motorY.power = unloadSpeed * data.yDirection;  
    data.motorY.start();
    data.motorY.waitFor();
    data.motorY.stop();
    data.ev3.beep();
end
