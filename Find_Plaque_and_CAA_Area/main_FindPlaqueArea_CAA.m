clear all;

addpath(sprintf('%s/export_fig', pwd)); % Put export_fig toolbox (https://www.mathworks.com/matlabcentral/fileexchange/23629-export_fig) in script folder

s(1).INPUT_PATH = 'C:/Data';
s(1).name_array = {'01'};

FindPlaqueArea_CAA(s);
