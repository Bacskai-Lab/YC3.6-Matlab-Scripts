clear all;

addpath(sprintf('%s/export_fig', pwd)); % Put export_fig toolbox (https://www.mathworks.com/matlabcentral/fileexchange/23629-export_fig) in script folder

s(1).INPUT_PATH = 'C:/Data';
s(1).name_array = {'01'};
s(1).zslices = {[1 10]};
s(1).channel = 1;

fill_holes_in_image = 0;

FindPlaqueArea_CAA_SelectZ(s, fill_holes_in_image);
