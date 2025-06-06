function YC_Pseudocolor_Single(s, r_min, r_max, brightness_factor, median_filter, xbitdepth)
% Modified Kishore YC pseudocoloring scripts
% Steven Hou (shou@mgh.harvard.edu)

for j = 1:length(s)
    INPUT_PATH = s(j).INPUT_PATH;
    meas_array = s(j).meas_array;
    
    mkdir([INPUT_PATH, '/OUTPUT/']);
    
    for k = 1:length(meas_array)
        meas_name = meas_array{k};
        OUTPUT_FILE = sprintf('%s/OUTPUT/%s.tif', INPUT_PATH, meas_name);
        
        if exist(OUTPUT_FILE, 'file') == 2
            delete(OUTPUT_FILE);
        end
        
        temp1 = double(imread(sprintf('%s/%s.oif.files/s_C001.tif', INPUT_PATH, meas_name)));
        temp2 = double(imread(sprintf('%s/%s.oif.files/s_C002.tif', INPUT_PATH, meas_name)));
        
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
        
        % Alternate method to subtract background
        
        %             [xpix ypix] = size(temp1);
        %             temp_back = reshape(temp1, 1, xpix*ypix);
        %             temp_back = mode(temp_back);
        %
        %             temp1 = medfilt2(temp1 - temp_back, [median_filter median_filter]);
        %
        %             [xpix ypix] = size(temp2);
        %             temp_back = reshape(temp2, 1, xpix*ypix);
        %             temp_back = mode(temp_back);
        %
        %             temp2 = medfilt2(temp2 - temp_back, [median_filter median_filter]);
        
        intensity = (double(temp2) + double(temp1))/2;
        ratio = double(temp2) ./ double(temp1);
        
        % convert ratio into an 8-bit image
        ratiouint8 = uint8(((ratio-r_min)/(r_max-r_min))*255);
        cmap = jet(256);
        
        ratiorgb = ind2rgb(ratiouint8, cmap); %convert the indexed image to RGB
        ratiohsv = rgb2hsv(ratiorgb); %convert the RGB image to HSV
        
        intensity_single = intensity/(2^xbitdepth-1); %normalize intensity to maximum possible of yellow + blue channels
        intensity_single = intensity_single * brightness_factor; % change brightness
        ratiohsv(:, :, 3) = intensity_single; %map the intensity image to the "value" of HSV
        newratio = hsv2rgb(ratiohsv); % new image keeps the color from the RGB image and the intensity from the intensity image
        
        imwrite(newratio, OUTPUT_FILE, 'WriteMode', 'append', 'Compression', 'none');
    end
end