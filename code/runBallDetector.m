function runBallDetector(plotFlag)

warning off;

% Define directories
ImagesDir = 'C:\proj\ball';
resultsDir = 'C:\proj\results';
ImagesFiles = dir(ImagesDir);
ImagesFiles = ImagesFiles(3:end);
len = length(ImagesFiles);

if plotFlag
    figureCircles = figure();
end

% Params
firstGaussFilterSigma = 2.8;
secondGaussFilterSigma = 1.8;
reduceTo = 0.25;
radiusRange = [6 70];
maxNumOfCircles = 7;
sensitivity = 0.85;
gradeVisualization = zeros(7, 25);
circleFilteringTh = 0.67;

for i = 1:len
    %disp(i)
    % read image
    image = imread(strcat(ImagesDir,'\',ImagesFiles(i).name));
    % Change to HSV, get imageS
    imageHSV = rgb2hsv(image);
    imageH = imageHSV(:,:,1);
    imageS = imageHSV(:,:,2);
    % Blurr imageS, reduce imageS
    imageSblurr = imgaussfilt(imageS, firstGaussFilterSigma);
    imageSreduce = imresize(imageSblurr, reduceTo);
    % Get nextStepImage with reduced original, mask imageS with it
    nextStepPixels = imresize(maskPixels2(image), reduceTo);
    imageSreduce(nextStepPixels==0)=0;
    % Blurr the resulting image imageSreduce
    imageSreduce = imgaussfilt(imageSreduce, secondGaussFilterSigma);
    % Find circles
    [centersStrong, radiiStrong] = findCircle(imageSreduce, radiusRange, maxNumOfCircles, sensitivity);
    
    if 1  % 1 if we check histograms on NOT reduced. Remember histograms!
        centersStrong = centersStrong.*(1/reduceTo);
        radiiStrong = radiiStrong.*(1/reduceTo);
        factor = 1;
    else
        imageH = imresize(imageH,reduceTo);
        factor = reduceTo;
    end
    
    % For every circle found calculate grade
    roundC = round(centersStrong);
    roundR = round(radiiStrong);
    grade = zeros(1, length(radiiStrong));
    % Check histogram of every circle and give grade
    for cir = 1:length(radiiStrong)
        % Calculate limits of square inside circle
        radToSq = roundR(cir)/1.4142;
        fromX = max(1,roundC(cir,2) - radToSq);
        toX = min(480*factor,roundC(cir,2) + radToSq);
        fromY = max(1,roundC(cir,1) - radToSq);
        toY = min(640*factor,roundC(cir,1) + radToSq);
        % Get image section and calculate normalized histogram
        imageSection = imageH(fromX:toX,fromY:toY);
       
        % Check pixel/pixel
        imfff = maskPixels3(image(fromX:toX,fromY:toY,:));
        grade(1, cir) = sum(sum(imfff))/(size(imageSection,1)*size(imageSection,2));
        
    end
    numOfElements = size(grade,2);
    gradeVisualization(1:numOfElements,i) = grade(1,:)';
    
    % Filter low grade circles
    relevantGrades = grade>circleFilteringTh*max(grade);
    relevantR = roundR(relevantGrades);
    relevantC = roundC(relevantGrades,:);
    
    % Filter circles that are inside other circles
    [relevantRSorted, seder] = sort(relevantR, 'descend');
    relevantCSorted = relevantC(seder,:);
    for b = 1:length(relevantRSorted)-1
        if relevantRSorted(b)~=0
            for y = b+1:length(relevantRSorted) 
                distSmall = sqrt((relevantCSorted(b,1)-relevantCSorted(y,1))^2 + ...
                    (relevantCSorted(b,2)-relevantCSorted(y,2))^2);
                if distSmall < relevantRSorted(b)
                    relevantRSorted(y) = 0;
                    relevantCSorted(y,:) = 0;
                end
            end
        end
    end
    
    % Save image with circles
    imageToSave = insertShape(image,'circle',...
        [relevantCSorted relevantRSorted],'LineWidth',3, 'Color', [128 0 128]);
    imwrite(imageToSave, strcat(resultsDir,'\',ImagesFiles(i).name), 'jpg');
    % Take second max grade after zeroing the first one
    if plotFlag
        ax1 = subplot(5,5,i,'Parent',figureCircles);
        imagesc(ax1, imresize(image,factor));
        h = viscircles(ax1, centersStrong, radiiStrong,'EdgeColor', 'b');
    end
end
a=1;