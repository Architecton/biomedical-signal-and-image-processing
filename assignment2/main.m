
function [] = main(data_folder_path, imgs_idxs, t_high, t_low)
    % function [] = main(data_folder_path, imgs_idxs)
    %
    % Main functionality for the second assignment. The parameter 
    % data_folder_path specifies the path to the image files (sequence). 
    % The parameter imgs_idxs represents the indices of the images in the 
    % dataset folder to use. It is best to specify them using the 
    % colon operator.

    % Determine dimensions of images.
    image_dims = size(imread(strcat(data_folder_path, sprintf('%04d', imgs_idxs(1)), ".png")));
    
    % Allocate array for storing sequence of images in tensor form.
    images_seq = zeros([image_dims, length(imgs_idxs)]);
    
    % Fill array of images.
    idx_image_seq = 1;
    for idx = 1:length(imgs_idxs)
       images_seq(:, :, idx_image_seq) = imread(strcat(data_folder_path, ...
            sprintf('%04d', imgs_idxs(idx)), ".png"));
       idx_image_seq = idx_image_seq + 1;
    end
    
    % Perform Canny edge detection using 24-connectivity.
    [res_linked, res_unlinked] = canny3d(images_seq, 1, t_high, t_low);
    
    % Check if res folder exists in dataset folder. If not, create it.
    if ~exist(strcat(data_folder_path, 'res/'), 'dir')
        mkdir(strcat(data_folder_path, 'res/'));
    end
    
    % Save images to folder
    for idx = 1:size(res_linked, 3)
        imwrite(res_linked(:, :, idx), strcat(data_folder_path, 'res/' , ...
            sprintf('%04d', imgs_idxs(idx)), '.png'));
    end
    
    % Display original sequence of images, sequence of images before
    % linking and seuqence of images after linking using using
    % 24-connectivity.
    figure('NumberTitle', 'off', 'Name', 'Original Sequence of Images');
    imshow3D(images_seq);
    
    figure('NumberTitle', 'off', 'Name', 'Images Processed using Canny Edge Detector - Before Linking');
    imshow3D(res_unlinked)
    
    figure('NumberTitle', 'off', 'Name', 'Images Processed using Canny Edge Detector - After Linking');
    imshow3D(res_linked)
    
end

