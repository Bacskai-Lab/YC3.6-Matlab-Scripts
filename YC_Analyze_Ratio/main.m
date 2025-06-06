
s(1).INPUT_PATH = 'C:/Data'; % PATHS SHOULD BE SEPARATED BY '/'. NO '/' AT THE END
s(1).meas_array = {'01'};

median_filter = 2;

% ROI name should be -RoiSet.zip or -RoiSet.roi and in /roi folder

AnalyzeRatio(s, median_filter);