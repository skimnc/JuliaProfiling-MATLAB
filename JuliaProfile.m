%% Author information
%
% Author:      Zachary Clawson
% Email:       zc227@cornell.edu, skimnc@gmail.com
% Affiliation: Cornell University, Center for Applied Mathematics
% Date:        05/01/2014

%% INITIALIZATION PHASE
clear; clc; close all;

% This will only work on Unix systems (only tested on Mac)
[status, result] = system( ['wc -l ', 'data_flat.txt'] );
numlines = str2num( result(6:8) );
mod_amt  = floor(0.10 * numlines);
fprintf('Number of lines to parse: %d\n\n', numlines);

% Create the first line object
lines = Cline;

%% PARSE THE DATA
% Open file:
fid = fopen('data_flat.txt');

% Run fgets twice (the first line is garbage):
tline = fgets(fid);
if ~isempty( strfind(tline,'Count') )
    tline = fgets(fid);
end

% Now go over every line til the file is over:
cntr = 1;
while ischar(tline)
    % Display line (debugging purposes):
    %disp(tline);
    % Parse the current line
    if rem(cntr - 1, mod_amt) == 0 || cntr == numlines
        fprintf('Parsing line %d\n', cntr);
    end
    e = 1;
    I = find(tline == ' ');
    while ~isempty(I)
        if length(I) ~= 1
            if I(1) ~= I(2)-1
                temp = tline( I(1)+1 : I(2)-1 );
                if e == 1
                    lines(cntr).count = str2num(temp);
                elseif e == 2
                    lines(cntr).file  = temp;
                else % e == 3
                    lines(cntr).func  = temp;
                end
                e = e + 1;
            end
        else % we are at the end
            temp = tline( I(1)+1 : end );
            lines(cntr).num = str2num(temp);
        end
        I(1) = [];
    end
    % Get the next line:
    tline = fgets(fid);
    cntr  = cntr + 1;
end

% Close file:
fclose(fid);

clearvars -except lines numlines;

%% CLEANUP
% Now we need to cleanup the information:
current = 1;
for next = 2 : numlines
    if length(lines(current).file) == length(lines(next).file) && length(lines(current).func) == length(lines(next).func)
        if min(lines(current).file == lines(next).file) && min(lines(current).func == lines(next).func)
            lines(current).count = lines(current).count + lines(next).count;
            lines(current).num   = [];
            lines(next).count    = [];
            lines(next).file     = [];
            lines(next).func     = [];
            lines(next).num      = [];
        else
            current = next;
        end
    else
        current = next;
    end
end

% Cleanup the empty entries:
cntr = 2;
while length(lines) > cntr
    if isempty( lines(cntr).count )
        lines(cntr) = [];
    else
        cntr = cntr + 1;
    end
end

%% PRINT RESULTS
% Now print the results to the screen:
print_data = true;
if print_data
    % Sort the object array based on count:
    [~,idx] = sort([lines.count], 'descend');
    lines = lines(idx);
    for_latex  = true; % print in the form of a LaTeX table
    do_percent = true; % instead of backtraces print percentages
    per_thresh = 0.005; % percentage threshold for printing
    % Some parsing for LaTeX:
    % Note: This currently will fix all _'s to \_'s for LaTeX processing.
    %       This also needs to be done for things like carets, percent
    %       symbols, etc..
    %
    %       If anyone uses this file and codes that, please email me.
    if for_latex
        fprintf('\\begin{tabular}{| c | >{\\tt}c | >{\\tt}c |}\n');
        fprintf('\\hline\n');
        fprintf('\\bf Backtraces \t & \\bf Filename \t & \\bf Function name\\\\\n');
        fprintf('\\hline\n');
        % Need to go through file & function names for _'s
        for i = 1 : length(lines)
            I = find(lines(i).file == '_');
            % Fix file names:
            temp = lines(i).file;
            for j = length(I) : -1 : 1
                if I(j) == 1
                    temp = strcat('\', temp(I(j):end));
                else
                    temp = strcat(temp(1:I(j)-1), '\', temp(I(j):end));
                end
            end
            lines(i).file = temp;
            % Fix function names:
            I = find(lines(i).func == '_');
            temp = lines(i).func;
            for j = length(I) : -1 : 1
                if I(j) == 1
                    temp = strcat('\', temp(I(j):end));
                else
                    temp = strcat(temp(1:I(j)-1), '\', temp(I(j):end));
                end
            end
            lines(i).func = temp;
        end
    end
    % Convert to percents?
    if do_percent
        total_back  = sum([lines.count]);
        for i = 1 : length(lines)
            lines(i).count = lines(i).count / total_back;
        end
    end
    % Now print every word
    for i = 1 : length(lines)
        if for_latex
            if do_percent
                if lines(i).count >= per_thresh
                    fprintf('%2.2f & \t', 100 * lines(i).count);
                    fprintf('%s & \t', lines(i).file);
                    fprintf('%s \\\\\t', lines(i).func);
                    fprintf('\\hline\n');
                end
            else
                fprintf('%d & \t', lines(i).count);
                fprintf('%s & \t', lines(i).file);
                fprintf('%s \\\\\t', lines(i).func);
                fprintf('\\hline\n');
            end
        else
            if do_percent
                fprintf('%f\t', 100 * lines(i).count);
            else
                fprintf('%d\t', lines(i).count);
            end
            fprintf('%s\t', lines(i).file);
            fprintf('%s\t\n', lines(i).func);
        end
    end
end
if for_latex
    fprintf('\\end{tabular}\n');
end
fprintf('\n');