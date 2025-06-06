function [ratio_array] = AnalyzeRatio(s, median_filter)
% Steven Hou (shou@mgh.harvard.edu)

for j = 1:length(s)
    INPUT_PATH = s(j).INPUT_PATH;
    meas_array = s(j).meas_array;
        
    OUTPUT_PATH = [INPUT_PATH, '/OUTPUT'];
    mkdir([INPUT_PATH, '/OUTPUT/']);
    
    for k = 1:length(meas_array)
        meas_name = meas_array{k};
        
        filelist = dir(sprintf('%s/%s.oif.files/s_C001Z*.tif', INPUT_PATH, meas_name));
        if length(filelist) > 0
            type = 0; % Z-Stack
            
            num_meas = length(filelist);
        end
                        
        temp1 = double(imread(sprintf('%s/%s.oif.files/s_C001Z%03d.tif', INPUT_PATH, meas_name, 1)));
        [nx ny] = size(temp1);
        
        if exist(sprintf('%s/roi/%s-RoiSet.zip', INPUT_PATH, meas_name), 'file') == 2
            [sROI] = ReadImageJROI(sprintf('%s/roi/%s-RoiSet.zip', INPUT_PATH, meas_name));
        elseif exist(sprintf('%s/roi/%s-RoiSet.roi', INPUT_PATH, meas_name), 'file') == 2
            [sROI] = ReadImageJROI(sprintf('%s/roi/%s-RoiSet.roi', INPUT_PATH, meas_name));
        end
        
        num_ROI = length(sROI);
        
        ratio_array = zeros(1, num_ROI);
        
        for r = 1:num_ROI
            if iscell(sROI) == 1
                ROI_temp = sROI{r};
            else
                ROI_temp = sROI;
            end
            
            temp = ROI_temp.mnCoordinates;
            slice = ROI_temp.nPosition;
            
            if slice == 0
                slice = ROI_temp.vnPosition(2);
            end
                        
            BW = poly2mask(temp(:, 1), temp(:, 2), nx, ny);
            
            temp1 = double(imread(sprintf('%s/%s.oif.files/s_C001Z%03d.tif', INPUT_PATH, meas_name, slice)));
            temp2 = double(imread(sprintf('%s/%s.oif.files/s_C002Z%03d.tif', INPUT_PATH, meas_name, slice)));
            
            backpix = 0.05;
            
            [xpix ypix] = size(temp1);
            temp_back = reshape(temp1, 1, xpix*ypix);
            temp_back = sort(temp_back);
            temp_back = round(mean(temp_back(1:round(xpix*ypix*backpix))));
            
            temp1 = medfilt2(temp1 - temp_back, [median_filter median_filter]);
            
            [xpix ypix] = size(temp2);
            temp_back = reshape(temp2, 1, xpix*ypix);
            temp_back = sort(temp_back);
            temp_back = round(mean(temp_back(1:round(xpix*ypix*backpix))));
            
            temp2 = medfilt2(temp2 - temp_back, [median_filter median_filter]);
            
            ratio_array(r) = sum(sum(double(temp2) .*  double(BW))) / sum(sum(double(temp1) .* double(BW)));
        end
        
        sheet = 1;
        
        xlrange = 'A1';
        A = ratio_array(:);
        xlswrite(sprintf('%s/%s_ratio_analysis.xls', OUTPUT_PATH, meas_name), A, sheet, xlrange);
    end           
end