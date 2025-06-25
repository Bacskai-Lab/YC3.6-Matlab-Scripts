function [] = MakeProjection(s)
% Steven Hou (shou@mgh.harvard.edu)

for s_idx = 1:length(s)
    
    INPUT_PATH = s(s_idx).INPUT_PATH;
    name_array = s(s_idx).name_array;
    
    for name_idx = 1:length(name_array)
        name = name_array{name_idx};
        
        FILEPATH = sprintf('%s/%s.oif.files', INPUT_PATH, name);
        
        listing = dir([FILEPATH, '/s_C001*.tif']);
        num_sections = length(listing);
        
        temp = imread(sprintf('%s/s_C001Z%03d.tif', FILEPATH, 1));
        [nx ny] = size(temp);
        
        channel1 = zeros(nx, ny, num_sections);
        
        for j = 1:num_sections
            j
            channel1(:, :, j) = imread(sprintf('%s/s_C001Z%03d.tif', FILEPATH, j));
        end
        
    %    intensity = uint16(mean(channel1, 3));
    
        intensity = uint16(max(channel1, [], 3));
        
        OUTPUT_filename = [INPUT_PATH, '/', name, '_proj.tif'];
        
        imwrite(intensity, OUTPUT_filename, 'WriteMode', 'append',  'Compression', 'none');
    end
end
