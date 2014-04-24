% a script to train a model from the training data...

cd ~/projects/shape_sharing/2D
clear
define_params
addpath src/predict
addpath src/utils
addpath src/external/
addpath src/external/hist2
addpath src/external/findfirst
addpath src/external/libicp/matlab

%% loading in all depths and shapes from disk...
load(paths.all_images, 'all_images')
load(paths.train_data, 'train_data')
load(paths.test_data, 'test_data')

%% now compute the model
params.scale_invariant = true;
params.sd_angles = 0;
train_data_subset = train_data(randperm(length(train_data), 20000));
model = train_fitting_model(all_images, train_data_subset, params);

%% showing all the shape distributions as an image
all_dists = cell2mat(model.shape_dists);
imagesc(all_dists)

%% save the model
save(paths.structured_predict_si_model_path, 'model');

%% making a single prediction and visualising
profile on
clf
num = 5500;
params.aggregating = 1;
params.num_proposals= 4;
params.plotting.plot_transforms = 1;
params.plotting.plot_matches = 0;
%num = num+500;
params.icp.outlier_distance = 10; 

for ii = 1:3
    
    subplot(1, 4,ii); 
    
    % extracting and transforming the GT image
    this_image_idx = test_data(num).image_idx;
    this_transform = test_data(num).transform;
    this_image = all_images{this_image_idx};
    this_test_image = transform_image(this_image, this_transform);
    
    % combinging with the depth for a nice display image
    combine_mask_and_depth(this_test_image, test_data(num).depth)
    width = length(test_data(num).depth);
    set(gca, 'xlim', round([-width/4, 1.25*width]));
    set(gca, 'ylim',round([-width/4, 1.25*width]));
end

params.aggregating = 1;
height = size(this_test_image, 1);
stacked_image = test_fitting_model(model, test_data(num).depth, height, params);
subplot(1, 4, 4);
imagesc(stacked_image); axis image

for ii = 1:3
    subplot(1, 4,ii); 
    set(gca, 'xlim', round([-width/4, 1.25*width]));
    set(gca, 'ylim',round([-width/4, 1.25*width]));
end
profile off viewer

%% showing the closest matching features to the input image
clf
load(paths.structured_predict_si_model_path, 'model');

params.aggregating = 1;
params.plotting.plot_matches = 1;
params.plotting.num_matches = 25;
params.plotting.plot_transforms = 0;

% finding the nearest neighbours
height = size(test_data(num).image, 1);
S = test_fitting_model(model, test_data(num).raytraced, height, params);

% showing image of the input data and ground truth
subplot(3, 4, 3*4);
combine_mask_and_depth(test_data(num).image, test_data(num).raytraced)
title('Ground truth')


