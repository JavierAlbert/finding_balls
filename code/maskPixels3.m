function nextStepPixels = maskPixels3(image)

%% Define vector of hue values that belong to "ball"
hueValues1 = [13 39];
hueValues2 = [44 73];
hueValues3 = [243 255];
blurrSigma = 2;
minArea1 = 40;
minArea2 = 300;
whiteThreshold = 200;
sThreshold = 75;


%% Detection of white pixels. Filter them.
redChannel = image(:,:,1);
greenChannel = image(:,:,2);
blueChannel = image(:,:,3);
imageGray = rgb2gray(image);
whitePixels = imageGray > whiteThreshold;
redChannel(whitePixels) = 0;
blueChannel(whitePixels) = 0;
greenChannel(whitePixels) = 0;
imageNoWhite = image;
imageNoWhite(:,:,1) = redChannel;
imageNoWhite(:,:,2) = greenChannel;
imageNoWhite(:,:,3) = blueChannel;


%% Check pixels that have accepted hue value and saturation above 75
imageHSV = im2uint8(rgb2hsv(imageNoWhite));
imageHue = imageHSV(:,:,1);
imageS = imageHSV(:,:,2);

imageHue(im2uint8(imageS)<sThreshold) = 0;
sizeY = size(image,2);
hueMember1 = zeros(480,sizeY);
hueMember2 = zeros(480,sizeY);
hueMember3 = zeros(480,sizeY);

hueMember1(imageHue>hueValues1(1) & imageHue<hueValues1(2)) = 1;
hueMember2(imageHue>hueValues2(1) & imageHue<hueValues2(2)) = 1;
hueMember3(imageHue>hueValues3(1) & imageHue<hueValues3(2)) = 1;

% Clean each mask and expand it.
% hueMember1 = bwareaopen(hueMember1, minArea1, 4);
% hueMember2 = bwareaopen(hueMember2, minArea1, 4);
% hueMember3 = bwareaopen(hueMember3, minArea1, 4);

% Run window on each of the hueMembers, the value will give the number of
% pixels that are 1 on that channel. It's like blurr basically.
hueMember1Count = imfilter(double(hueMember1),ones(5))./(5^2);
hueMember2Count = imfilter(double(hueMember2),ones(5))./(5^2);
hueMember3Count = imfilter(double(hueMember3),ones(5))./(5^2);

% Erase everywhere there is a 0 in at least one of the members and
% threshold
nextStepPixels = hueMember1Count.*hueMember2Count + ...
    hueMember1Count.*hueMember3Count + ...
    hueMember2Count.*hueMember3Count;

% caca(caca<(max(max(caca))*0.1)) = 0;
% caca(caca>(max(max(caca))*0.1)) = 1;

% Dilate
% se = strel('square',15);
% nextStepPixels = imdilate(caca,se);