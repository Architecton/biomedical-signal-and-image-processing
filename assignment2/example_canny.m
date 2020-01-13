
% Visualize results of Canny edge detector on single image.
I = imread('sample-images-canny/museum.jpg');
Ie = canny(rgb2gray(I), 1, 50, 20);
figure(1);
imagesc(I); title('Original Image');
axis off;
figure(2);
imagesc(Ie); colormap gray; title('Image Processed with Canny Edge Detector');
axis off;
