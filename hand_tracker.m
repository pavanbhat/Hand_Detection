function hand_tracker(vidFrame)
%% Obtaining the input image
% addpath('TEST_IMAGES');
% I = imread('hand8.jpg');
I = vidFrame;
% figure, imshow(I), title('Original Image');
%% Hand Segmentation
% Conversion from RGB to LAb color space
cform = makecform('srgb2lab');
lab = applycform(I,cform);
% Otsu's method for thresholding
% figure, imshow(lab), title('Lab Image');
% level = graythresh(I)
% bw = im2bw(lab, 0.4905);
bw = im2bw(lab, 0.5905);% Adjusted value
bw = 1-bw;
% figure, imshow(bw), title('BW Image');
%% Filtering the frame for noise removal
filt = medfilt2(bw);
% figure, imshow(filt),title('Filtered Image');
%% Noise Removal using Morphology
se = strel('sphere',5);
er = imopen(filt,se);
% figure, imshow(er), title('Eroded Image');
% imcontour(er,10);
% figure, imshow(er), title('Eroded ImAGE');
%% Detecting harris corners to obtain edge points in the image after segmentation
% Extracting corner points using Harris Features
corners = detectHarrisFeatures(er);
[features, valid_corners] = extractFeatures(er, corners);
% imshow(I)

%% Plotting Valid corners on the original image
hold on
plot(valid_corners);
%% Obtaining locations of the valid corners
loc = double(valid_corners.Location);

%% Obtaining the region of interest
coords = mean(loc); % Mean of the Harris corners
imshow(I)
% coords(:,1) = coords(:,1) + 200;
% Plots the centroid of the mean of the Harris corners obtained from the
% segmented hand
hold on 
plot(coords(:,1), coords(:,2),'mo', 'MarkerSize', 24, 'LineWidth', 2 );
plot(coords(:,1), coords(:,2),'m+', 'MarkerSize', 24, 'LineWidth', 2 );

% Adding points in the Harris points
loc = cat(1,loc,coords);
[row col] = size(loc);

for m = 1 : row
    for n = 1 : col
        if(( coords(1) + 250 > loc(m,1)) &&  (coords(1) - 250 < loc(m,1)) && (coords(2) + 250 > loc(m,2)) && (coords(2) - 250 < loc(m,2)))
            border(m,n) = loc(m,n);
        end
    end
end

% Discards the Harris corners that are away from the center located.
finalBorder(:,1) = border((border(:,1) ~= 0),1);
finalBorder(:,2) = border((border(:,2) ~= 0),2);

%% Triangulation and Drawing Convex Hull around the region of interest
% Triangulating points from the obtained harris corners.
DT = delaunayTriangulation(finalBorder(:,1),finalBorder(:,2));
% Building the Convex hull around the contours of the Hand
k = convexHull(DT);
%  imshow(I), title('Harris Image');    
%     figure, plot(DT.Points(:,1),DT.Points(:,2), '.','markersize',10);
%  Plotting the Convex Hull on to the original image.
hold on
plot(DT.Points(k,1),DT.Points(k,2),'b', 'MarkerSize', 24, 'LineWidth', 2);
% hold off
end

