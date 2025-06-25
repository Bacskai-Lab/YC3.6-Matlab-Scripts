function [] = FindPlaqueArea_CAA_SelectZ(s, fill_holes_in_image)
% Steven Hou (shou@mgh.harvard.edu)

for s_idx = 1:length(s)
    
    INPUT_PATH = s(s_idx).INPUT_PATH;
    OUTPUT_PATH = sprintf('%s/OUTPUT', INPUT_PATH);
    mkdir(OUTPUT_PATH);
    
    name_array = s(s_idx).name_array;
    
    zslices = s(s_idx).zslices;
    chan = s(s_idx).channel;
    
    for name_idx = 1:length(name_array)
        name = name_array{name_idx};
        
        name
        FILEPATH = sprintf('%s/%s.oif.files', INPUT_PATH, name);
        
        listing = dir(sprintf('%s/s_C00%d*.tif', FILEPATH, chan));
        num_sections = length(listing);
        
        temp = imread(sprintf('%s/s_C00%dZ%03d.tif', FILEPATH, chan, 1));
        [nx ny] = size(temp);
        
        channel1 = zeros(nx, ny, num_sections);
        
        for j = 1:num_sections
            j
            channel1(:, :, j) = double(imread(sprintf('%s/s_C00%dZ%03d.tif', FILEPATH, chan, j)));
        end
        
        ROI_filename_zip = sprintf('%s/roi/%s_RoiSet.zip', INPUT_PATH, name);
        ROI_filename_roi = sprintf('%s/roi/%s.roi', INPUT_PATH, name);
        
        if exist(ROI_filename_zip, 'file') == 2
            temp = ReadImageJROI(ROI_filename_zip);
        elseif exist(ROI_filename_roi, 'file') == 2
            temp = ReadImageJROI(ROI_filename_roi);
        end
        
        num_ROI = length(temp);
        
        area_array = zeros(1, num_ROI);
        
        for j = 1:num_ROI
            
            if iscell(temp) == 1
                temp_ROI = temp{j};
            else
                temp_ROI = temp;
            end
            
            z_temp = zslices{j};
            
            intensity = max(channel1(:, :, z_temp(1):z_temp(2)), [], 3);
            intensity_original = intensity;
            
            if strcmp(temp_ROI.strType, 'Freehand') == 1
                
                temp_coord = temp_ROI.mnCoordinates;
                
                BW_free = poly2mask(temp_coord(:, 1), temp_coord(:, 2), nx, ny);
                
                intensity = intensity .* BW_free;
            end
            
            intensity = uint8(255*(intensity/max(max(intensity))));
            
            
            bounds = temp_ROI.vnRectBounds;
            
            x_min = bounds(1);
            x_max = bounds(3);
            
            y_min = bounds(2);
            y_max = bounds(4);
            
            intensity_ROI = intensity(x_min:x_max, y_min:y_max);
            
            level = graythresh(intensity_ROI);
            BW = im2bw(intensity_ROI,level);
            
            if fill_holes_in_image == 1
                BW = imfill(BW, 'holes');
            end
            
            % Find biggest object
            %             [L, num] = bwlabel(BW, 8);
            %             count_pixels_per_obj = sum(bsxfun(@eq,L(:),1:num));
            %             [~,ind] = max(count_pixels_per_obj);
            %             biggest_blob = (L == ind);
            %
            %             BW = biggest_blob;
            %             num
            
            area_array(j) = sum(sum(BW));
            
            whole_image = zeros(nx, ny);
            whole_image(x_min:x_max, y_min:y_max) = BW;
            
            figure(1), imagesc(whole_image);
            axis image;
            colormap('gray');
            
            set(gcf, 'Color', 'white'); % white bckgr
            export_fig( gcf, ...      % figure handle
                sprintf('%s/%s_roi%d.png', OUTPUT_PATH, name, j),... % name of output file without extension
                '-painters', ...      % renderer
                '-png', ...           % file format
                '-r300' );             % resolution in dpi
            
            
            figure(2), imagesc(intensity_original);
            axis image;
            colormap('gray');
            
            set(gcf, 'Color', 'white'); % white bckgr
            export_fig( gcf, ...      % figure handle
                sprintf('%s/%s_roi%d_intensity.png', OUTPUT_PATH, name, j),... % name of output file without extension
                '-painters', ...      % renderer
                '-png', ...           % file format
                '-r300' );             % resolution in dpi
            
            %
            %                         [B, L] = bwboundaries(whole_image, 'noholes');
%             
%                         for k = 1:length(B)
%                             boundary = B{k};
%                             plot(boundary(:, 2), boundary(:, 1), 'y', 'Linewidth', 1);
%                         end
        end
                
        temp = zeros(1, 3);
        temp(1) = num_ROI;
        temp(2) = num_sections;
        temp(3) = sum(area_array)/(nx*ny);
        
        sheet = 1;
        xlrange = 'A1';
        A = temp(:)';
        xlswrite(sprintf('%s/%s_stats.xls', OUTPUT_PATH, name), A, sheet, xlrange);
        
        sheet = 1;
        xlrange = 'D1';
        A = area_array(:);
        xlswrite(sprintf('%s/%s_stats.xls', OUTPUT_PATH, name), A, sheet, xlrange);
        
        close all;
    end
end




