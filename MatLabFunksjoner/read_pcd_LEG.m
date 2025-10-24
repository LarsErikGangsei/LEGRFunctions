%%                                                                       %%
%% Function to read pcd- files in the RoButcher project                  %%
%%                                                                       %%
%% This is some code just to look at PigAtlas Data
%%
%% Author: Lars Erik Gangsei
%% Date: 20th of February 2020
function [PC,Header] = read_pcd_LEG(file_path)
    fileID = fopen(file_path,'r');
    Points = fscanf(fileID,'%c');
    Stoppkt  = strfind(Points,'ascii')+5;
    Header = Points(1:Stoppkt);
    Points(1:Stoppkt)=[];
    Points = {strsplit(Points,Points(end))};
    Points = {Points{1}{1:(end-1)}}';
    Points = {cellfun(@(x) strsplit(x,' '),Points,'UniformOutput',false)};
    Points = Points{1};
    ind = cellfun(@(x) length(x)==3,Points);
    Points = {Points{ind}}';
    PC = NaN*ones(length(Points),3);
    for ii = 1:length(Points);
        PC(ii,:) = cellfun(@(x) str2double(x),Points{ii});
    end
    fclose(fileID);
end