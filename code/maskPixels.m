function nextStepPixels = maskPixels(image)

%% Define vector of hue values that belong to "ball"
hueValues = [1:8, 13:39, 44:73, 243:255];
blurrSigma = 2;
minArea = 250;
whiteThreshold = 200;
sThreshold = 75;

%% Blur image
blurrImage = imgaussfilt(image, blurrSigma);

%% Detection of white pixels. Filter them.
redChannel = blurrImage(:,:,1);
greenChannel = blurrImage(:,:,2);
blueChannel = blurrImage(:,:,3);
imageGray = rgb2gray(blurrImage);
whitePixels = imageGray > whiteThreshold;
redChannel(whitePixels) = 0;
blueChannel(whitePixels) = 0;
greenChannel(whitePixels) = 0;
imageNoWhite = blurrImage;
imageNoWhite(:,:,1) = redChannel;
imageNoWhite(:,:,2) = greenChannel;
imageNoWhite(:,:,3) = blueChannel;


%% Check pixels that have accepted hue value and saturation above 75
imageHSV = rgb2hsv(imageNoWhite);
imageHue = imageHSV(:,:,1);
imageS = imageHSV(:,:,2);

hueMember = ismember(im2uint8(imageHue), hueValues);
tentativePixels = hueMember.*(im2uint8(imageS)>sThreshold);

tentativePixelsAfterFilter = imfilter(tentativePixels,ones(5));
tentativePixelsAfterFilter = tentativePixelsAfterFilter >= 1;

% Erase regions that are smaller than value
nextStepPixels = bwareaopen(tentativePixelsAfterFilter, minArea, 4);