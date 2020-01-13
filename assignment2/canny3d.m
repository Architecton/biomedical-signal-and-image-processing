
function [res, processed_images] = canny3d(imgs, sigma, t_high, t_low)
    % function [res, processed_images] = canny3d(imgs, sigma, t_high, t_low)
    %
    % Perform Canny edge detection on a sequence of images and link them 
    % using 24-connectivity. The parameter imgs specifies the tensor of 
    % images to use. The parameter sigma specifies the width of the kernel 
    % used for Gaussian smoothing. The parameter t_high specifies the high 
    % threshold for hysteresis thresholding. The parameter t_low specifies 
    % the low threshold for hysteresis thresholding.

    % Allocate array for storing processed images.
    processed_images = zeros(size(imgs));
    
    % Go over each image and perform Canny edge detection.
    % Store results in allocated array.
    for idx = 1:size(imgs, 3)
       processed_images(:, :, idx) = canny(imgs(:, :, idx), sigma, t_high, t_low);
    end
    
    % Allocate array for storing connected images.
    % Set initial image (equal to first image in array of processed
    % images).
    res = zeros(size(processed_images));
    res(:, :, 1) = processed_images(:, :, 1);
    
    % Go over images and connect each to the next in the array of processed
    % images.
    for idx = 1:size(processed_images, 3)-1
        res(:, :, idx+1) = connectivity24(processed_images(:, :, idx), processed_images(:, :, idx+1));
    end
end


function [img] = connect_image(img, neighborhood_center)
    % function [img] = connect_image(img, neighborhood_center)
    %
    % Connect image n+1 with pixel on image n that is located at
    % position specified by parameter neighborhood_center.

    % Get local indices for 1-pixels in neighborhood.
    [idxs1_local, idxs2_local] = ind2sub([5, 5], ...
        find(img(neighborhood_center(1)-2:neighborhood_center(1)+2, ...
        neighborhood_center(2)-2:neighborhood_center(2)+2)));
    
    % Convert to global indices.
    pixel_positions_global = [idxs1_local, idxs2_local] + ...
        repmat(neighborhood_center, length(idxs1_local), 1) - 3;
    
    % Go over pixels in 5x5 neighborhood.
    for idx = 1:size(pixel_positions_global, 1)
        pixel_position_nxt = pixel_positions_global(idx, :);
        
        % Get offset from center.
        delta = pixel_position_nxt - neighborhood_center;
        
        % Get values to be added to perform convergence.
        change_nxt = -sign(delta);
        
        % While not yer converged to 0.
        while ~all(change_nxt == 0)
            
            % Perform step of convergence.
            pixel_position_nxt = pixel_position_nxt + change_nxt;
            
            % Set visited pixel to 1.
            img(pixel_position_nxt(1), pixel_position_nxt(2)) = 1;
            
            % Get next offset after convergence step.
            delta = pixel_position_nxt - neighborhood_center;
            
            % Get next values to be added to perform convergence.
            change_nxt = -sign(delta);
        end
    end
end


function [img2_res] = connectivity24(img1, img2)
    % function [img2_res] = connectivity24(img1, img2)
    %
    % Connect images n and n+1 using 24-connectivity.

    % Padd images with zeros to avoid out of bounds issues.
    img1_padded = padarray(img1, [2, 2], 0);
    img2_padded = padarray(img2, [2, 2], 0);
    
    % Get positions of 1-pixels in the first image.
    [idxs1, idxs2] = ind2sub(size(img1_padded), find(img1_padded));
    pixel_positions = [idxs1, idxs2];
    
    % Go over 1-pixel positions.
    for idx = 1:length(idxs1)
        pixel_position_nxt = pixel_positions(idx, :);
        
        % If no 1-pixel found in 3x3 neighborhood in (n+1)-th image.
        if ~any(any(img2_padded(idxs1-1:idxs1+1, idxs2-1:idxs2+1)))
            % Check 5x5 neighboorhood in (n+1)-th image. If any 1-pixel
            % found, perform connecting.
            if any(any(img2_padded(idxs1-2:idxs1+2, idxs2-2:idxs2+2)))
                img2_padded = connect_image(img2_padded, pixel_position_nxt);
            end
        end
    end
    
    % Remove padding to get connected image.
    img2_res = img2_padded(3:end-2, 3:end-2);
end

