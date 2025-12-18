function strokes = textEngine(text, startX, startY, fontSize, spacing, lineSpacing)
% TEXTENGINE - Convert text string to plotter strokes
% Uses vectorFont.m for character stroke definitions
% Supports multiline text (use newline character or cell array of strings)
%
% Inputs:
%   text        - String or cell array of strings (each cell = one line)
%   startX      - X position of text start (mm)
%   startY      - Y position of text TOP (mm) - text grows downward
%   fontSize    - Height of characters in mm (default: 10)
%   spacing     - Character spacing multiplier (default: 1.2)
%   lineSpacing - Line spacing multiplier (default: 1.5)
%
% Output:
%   strokes  - Cell array of stroke paths, each Nx2 matrix of [x, y] points
%
% Dependencies:
%   vectorFont.m - Character stroke definitions

    if nargin < 4 || isempty(fontSize)
        fontSize = 10;
    end
    if nargin < 5 || isempty(spacing)
        spacing = 1.2;
    end
    if nargin < 6 || isempty(lineSpacing)
        lineSpacing = 1.5;
    end
    
    % Convert input to cell array of lines
    if iscell(text)
        % Already a cell array
        lines = text;
    elseif ischar(text)
        % Char array - check if 2D (multiline from edit box)
        numRows = size(text, 1);
        if numRows > 1
            % 2D char array: each row is a line, padded with spaces
            lines = cell(numRows, 1);
            for r = 1:numRows
                lines{r} = strtrim(text(r, :));  % Trim trailing spaces
            end
        else
            % Single line - check for embedded newlines
            if contains(text, newline)
                lines = strsplit(text, newline);
            else
                lines = {text};
            end
        end
    elseif isstring(text)
        lines = cellstr(text);
    else
        lines = {char(text)};
    end
    
    % Remove empty trailing lines
    while ~isempty(lines) && isempty(strtrim(lines{end}))
        lines(end) = [];
    end
    
    strokes = {};
    charWidth = fontSize * 0.6;  % Standard character width
    lineHeight = fontSize * lineSpacing;  % Total height per line (includes spacing)
    
    % Process each line (top to bottom)
    for lineIdx = 1:length(lines)
        line = lines{lineIdx};
        currentX = startX;
        % Baseline is at top minus (line number * line height)
        % First line baseline = startY - fontSize (so top of char is at startY)
        currentY = startY - (lineIdx * lineHeight) + (lineSpacing - 1) * fontSize;
        
        % Process each character in the line
        for i = 1:length(line)
            ch = line(i);
            
            % Get strokes for this character from vectorFont
            charStrokes = vectorFont(ch);
            
            % Scale and position each stroke
            for j = 1:length(charStrokes)
                stroke = charStrokes{j};
                
                % Scale: x by charWidth, y by fontSize
                % Position: offset by currentX, currentY
                scaledStroke = zeros(size(stroke));
                scaledStroke(:, 1) = stroke(:, 1) * charWidth + currentX;
                scaledStroke(:, 2) = stroke(:, 2) * fontSize + currentY;
                
                strokes{end+1} = scaledStroke;
            end
            
            % Move to next character position
            currentX = currentX + charWidth * spacing;
        end
    end
end

