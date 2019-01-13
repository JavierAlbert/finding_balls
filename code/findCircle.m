function [centersStrong, radiiStrong] = findCircle(img, radiusRange, maxNumOfCircles, sensitivity)

[centers, radii] = imfindcircles(img, radiusRange, 'Sensitivity', sensitivity);
centersStrong = centers(1:min(maxNumOfCircles,size(centers,1)),:);
radiiStrong = radii(1:min(maxNumOfCircles,size(radii,1)));