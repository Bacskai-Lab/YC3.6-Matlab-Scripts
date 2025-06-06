r_min = 0.8;
r_max = 2.0;
brightness_factor = 3; % < 1 (dimmer), > 1 (brighter)
median_filter = 2; % 2 is default
xbitdepth = 12; % 12 is default

s(1).INPUT_PATH = 'C:/Data'; % PATHS SHOULD BE SEPARATED BY '/'. NO '/' AT THE END
s(1).meas_array = {'01', '02'};


YC_Pseudocolor_Single(s, r_min, r_max, brightness_factor, median_filter, xbitdepth);