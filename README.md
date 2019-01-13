# Finding Balls

The project goal is to find multi-colored balls with very high accuracy and recall. 25 images are given, and on each image we can see 1 or more than 1 ball on totally different backgrounds.

## Offline

First we create a simple Matlab widget that let's the user define a polygon with the mouse. Then the program converts the RGB values of the selected region into HSV values and plots the histogram of the Hue value. If we do this for all the images we can get a good approximation of the expected hue values of the balls.


## Preprocessing

Now on live mode we first check for saturated pixels on RGB channels and we discard this pixels. Then we change to HSV channel and filter all the pixels that are below certain S level. Then we work with the Hue channel and split the remaining pixels into regions that are compatible with the colors that we see on the magic balls (we have this information from the histograms). Later we blurr each component and look for regions where the components intersect (inner edges of the magic balls on H space). Finally we dilate each pixel above certain threshold and build a mask that will filter the image for the next processing step.

## Circles detection

We pass each image through a Hough based circle finder function. For computational speed purposes, we reduce the image to ¼ of its original size using imresize(). We then enlarge the circles by the opposite factor to get them on the original image coordinates. We allow for a maximum of 7 circles on each image that will go under evaluation on the next step. 


## Circles validation

The goal here is to evaluate if the circle indeed represent a magic ball or not. For computational speed purposes we don’t subject all the pixels of the circle to evaluation but rather the largest square inscribed in the circle. Since Matlab is matrix based it will speed up calculations, also we will get less effect from the edge of the ball that can introduce noise. We assume the information we get from the pixels inside the inscribed square are representative of the pixels inside the circle since they account for about 65% of all the pixels.

Each circle gets a score based on how many of its pixels have a large change of being a magic ball based on its Hue component similar to Step 2. The score is normalized so big circles don’t have advantage over small circles for now. We dismiss circles with low score. 

Then we check for circles that intersect with each other. We don’t want circles inside other circles or pairs with much common area. Using simple geometry and calculating the relative area of each circle that is being covered by another circles we can dismiss the “small” ones. This operation is performed very quickly using a sorting algorithm.

Finally we keep the circles that passed both tests, plot the purple perimeters on the image and save the new images to results folder.



