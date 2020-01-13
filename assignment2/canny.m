
function [Ie] = canny(I, sigma, t_high, t_low)
    % function [Ie] = canny(I, sigma, t_high, t_low)
    %
    % Performedge detection using the Canny algorithm. parameter sigma
    % specifies the width of the kernel used for Gaussian smoothing.
    % The parameter t_high specifies the high threshold for hysteresis
    % thresholding. The parameter t_low specifies the low threshold for
    % hysteresis thresholding.

    % Get gradient map.
	[Imag, Idir] = image_gradient(I, sigma);
    
	% Get results of nonmaxima suppresion on gradient map.
	Ie_suppressed = nonmaxima_suppression(Imag, Idir);
    
    % Perform hysteresis thresholding to trace edges.
    Ie = hysteresis_tresh(Ie_suppressed, t_high, t_low);
end


function [Imag, Idir] = image_gradient(I, sigma)
    % function [Imag, Idir] = image_gradient(I, sigma)
    %
    % Compute matrix of gradient magnitudes	and matrix of derivative angles.
    % The gaussian kernel is constructed with a standard deviation of sigma.

    % Compute partial derivatives.
	[Ix, Iy] = image_derivatives(I, sigma);
    
    % Compute matrix of magnitudes.
	Imag = sqrt(Ix.^2 + Iy.^2);
    
    % Compute matrix of derivative angles.
	Idir = atan2(Iy, Ix);
end


function [Ix, Iy] = image_derivatives(I, sigma)
    % function [Ix, Iy] = image_derivatives(I, sigma)
    % 
    % Compute partial derivatives of image I. The gaussian kernel is
    % constructed using a standard deviation of sigma.

    % Compute kernels.
	dg = gaussdx(sigma);
	g = gauss(sigma);
    
     % Prepare kernels for imfilter (has the 'replicate' option)
	h1 = conv2(g', dg);
	h2 = conv2(dg', g);
    
    % Perform image derivations.
	Ix = imfilter(double(I), h1, 'conv', 'same', 'replicate');
	Iy = imfilter(double(I), h2, 'conv', 'same', 'replicate');
    
	% Similar but may treat image borders as edges.
	% Ix = conv2(g, dg, I, 'same'); % Derivative with respect to x.
	% Iy = conv2(dg, g, I, 'same'); % Derivative with respect to y.
end


function k = gaussdx(sigma)
    % function k = gaussdx(sigma)
    %
    % Compute kernel representing the convolution of the gaussian kernel and
    % the derivation kernel. The parameter sigma specifies the standard
    % deviation used in the construction of the gaussian kernel.

    % Get gaussian kernel.
	g = gauss(sigma);  % Get gaussian kernel.
    
    % Define derivation kernel (will be rotated by MATLAB's conv function).
	der_ker = [1 -1];
    
    % der_ker * g
	k = conv(g, der_ker);
    
    % Normalize - sum of absolute values is 1.
	k = k ./ sum(abs(k));
end


function [g, x] = gauss(sigma)
    % function [g, x] = gauss(sigma)
    %
    % Compute gaussian kernel over [-3*sigma, 3*sigma]

    % Compute domain values.
	x = -round(3.0*sigma):round(3.0*sigma);
    
    % Evaluate function.
	g = (1/sqrt(2*pi*sigma)) * exp(-(x.^2/(2*sigma^2)));
    
    % Normalize.
	g = g / sum(g);
end


function Imax = nonmaxima_suppression(Imag, Idir)
    % function Imax = nonmaxima_suppression_line(Imag, Idir)
    %
    % Implementation of thinning by non-maxima suppresion. Create an image that
    % only contains the local maxima of lines present in matrix of gradient
    % magnitudes.
    
    % Get height and width of image.
	[h, w] = size(Imag);
    
    % Allocate matrix for result image.
	Imax = zeros(h,w);
	
	% Circularly shift matrix to compare values in all possible directions.
	T_N = circshift(Imag, [1, 0]);
	T_S = circshift(Imag, [-1, 0]);
	T_W = circshift(Imag, [0, 1]);
	T_E = circshift(Imag, [0, -1]);
	T_NE = circshift(Imag, [1, -1]);
	T_SE = circshift(Imag, [-1, -1]);
	T_SW = circshift(Imag, [-1, 1]);
	T_NW = circshift(Imag, [1, 1]);
	
	% Find maximas in each direction. Test if value is positive if
	% subtracting both adjacent elements in stated direction. (Two numbers are both
	% positive, if their product as well as their sum is positive).
	maxima_NS = (Imag - T_N) .* (Imag - T_S) > 0 & (Imag - T_N) + (Imag - T_S) > 0;
	maxima_WE = (Imag - T_W) .* (Imag - T_E) > 0 & (Imag - T_W) + (Imag - T_E) > 0;
	maxima_NWSE = (Imag - T_NW) .* (Imag - T_SE) > 0 & (Imag - T_NW) + (Imag - T_SE) > 0;
	maxima_NESW = (Imag - T_NE) .* (Imag - T_SW) > 0 & (Imag - T_NE) + (Imag - T_SW) > 0;
	
	idx = round(((Idir + pi) ./ pi) .* 4) + 1;  % Get matrix of gradient directions.
	% Values of idx:
	% 
	% 1 - WE
	% 2 - NESW
	% 3 - NS
	% 4 - NWSE
	% 5 - WE
	% 6 - NESW
	% 7 - NS
	% 8 - NWSE
	% 9 - WE
	
	% Find maxima where the maxima are along a gradient direction.
	% Get the indices of the maxima.
	id1 = find(maxima_NS & (idx == 3 | idx == 7));
	id2 = find(maxima_WE & (idx == 1 | idx == 5 | idx == 9));
	id3 = find(maxima_NWSE & (idx == 2 | idx == 6));
	id4 = find(maxima_NESW & (idx == 4 | idx == 8));
	
	% Add gradient magnitude values at appropriate indices to results
	% matrix.
	Imax(id1) = Imag(id1);
	Imax(id2) = Imag(id2);
	Imax(id3) = Imag(id3);
	Imax(id4) = Imag(id4);
end


function [Ie] = hysteresis_tresh(Imag, t_high, t_low)
    % function [Ie] = hysteresis_tresh(Imag, thigh, tlow)
    %
    % Apply histeresis tresholding to image I and return result.

	% Get regions that are above the high treshold.
	high_mask = Imag>t_high; 
    
	% Label regions that pass the low treshold.
	low_mask = bwlabel(Imag > t_low);
    
	% From low_mask get values that are also in high mask and find
	% corresponding labels. Get regions where the labels are found in the
	% low_mask.
	idx = ismember(low_mask, unique(low_mask(high_mask)));
	
	% Allocate matrix for resut.
	Ie = zeros(size(Imag));
    
    % Set pixels corresponding to detected edges to 1.
	Ie(idx) = 1; 
end

