%%% run_example
% This file runs the matching process for all pairs in the given file.
% Input: A file with the list of pairs, input shapes folder, output folder.
% Output: The shape correspondence files will be written to the output
% folder along with an image which displays the results.
%
%%% If you use this code, please cite the following paper:
%  
%  Robust Structure-based Shape Correspondence
%  Yanir Kleiman and Maks Ovsjanikov
%  Computer Graphics Forum, 2018
%
%%% Copyright (c) 2017 Yanir Kleiman <yanirk@gmail.com>

% clear all;
close all;

% Range of intervals - a shape graph will be generated for each interval
% and the best matching shape graphs will be selected:
ints_range = [8 7];

% Update this to appropriate shapes folder:
% shapesdir = '../data/MPI/tr_reg_';
shapesdir = 'tr_reg_'; % (includes the prefix of the shape name)

% Update this to appropriate results folder:
resultsdir = 'results/';

% Reading list of pairs:
fid = fopen('pairs_list.txt');
x = textscan(fid, '%s');
x = x{1};
fclose(fid);

n = length(x);

% Parsing list to find shape names:
names_all = cell(n, 2);
for i=1:n
    s = strsplit(x{i}, '_');

    names_all{i, 1} = s{1};
    names_all{i, 2} = s{2};
end

%%% Leave only this to run correspondence between two triangular meshes:
S1_opts.pcd = 0;
S2_opts.pcd = 0;
%%% Uncomment to create and match a point cloud from shape number 1:
% S1_opts.pcd = 1;
% S1_opts.np = 6000;
%%% Uncomment to create and match a point cloud from shape number 2:
% S2_opts.pcd = 1;
% S2_opts.np = 6000;

TF = [];

%% Run process:
for i=1:n
    name1 = names_all{i, 1};
    name2 = names_all{i, 2};
    
    display(['Matching shapes ' name1 ' and ' name2]);

    filename1 = [shapesdir name1 '.off'];
    filename2 = [shapesdir name2 '.off'];

    save_name = [resultsdir name1 '_' name2];

    dowork = 0;
    if (exist([save_name '.mat'], 'file'))
        display([save_name ' - file exists.']);
    else
        dowork = 1;
    end
    
    if (dowork)

        t1 = tic;
        
        % Load shapes and generate shape graphs:
        [M1, M2] = ShapePairMapper(filename1, filename2, ints_range, [], [], S1_opts, S2_opts);

        % Compute the segment cor   respondences of the two shape graphs:
        % use_val = 0 so the interval band id is not used for the matching of segments.
        R = MatchShapes(M1, M2, 0); 

        R.time = toc(t1);

        R.filename1 = filename1;
        R.filename2 = filename2;

        % Keep record of the computation time:
        TF(end + 1) = R.time;

        display([save_name ' time = ' num2str(R.time) ' seconds.']);

        R.save_name = save_name;

        %%% To save without visualization, uncomment this:
        % save(save_name, 'R');
        %%% To save with visualization, uncomment this:
        VisualizeMatching(R, save_name);

        %%% Uncomment this to compare different matching parameters -
        %%% use the original cluster id for region matching:
%         R = MatchShapes(M1, M2, 1); 
%         
%         R.save_name = [save_name '_cluster'];
%         VisualizeMatching(R, [save_name '_cluster']);
        
        close all;

    end
end

