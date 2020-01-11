function [] = visualize_neighborhood(image)
    
    % Plot image.
    imagesc(image);
    
    % Create pixel-grid.
    pixelgrid();
    
    % Draw bounds for 5x5 neighborhood.
    line([2, 2], [4, 10], 'LineWidth', 10, 'Color', 'green');
    line([2, 8], [4, 4], 'LineWidth', 10, 'color', 'green');
    line([2, 8], [10, 10], 'LineWidth', 10, 'color', 'green');
    line([8, 8], [4, 10], 'LineWidth', 10, 'color', 'green');
    axis square;
    colormap gray;
    
end