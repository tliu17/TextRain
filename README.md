# TextRain
*Threshold needs to be adjusted between the prerecorded video and the camera image.

Display:

The video image is displayed in Grayscale, and the screen is unmirrored (video image is flipped horizontally). Color of each letter object is randomized.

Animation:

The letter objects falls based on random velocity assigned based on wall clock, rather than how many time draw() gets called.
Character Picking Algorithm
A random ‘x’ coordinate is assigned to each letter object.

Structure:

The code takes a String for input.
The input string is then split into individual chars and passed to an Object class called Letter.
All letter objects are stored in an arraylist called textRain.
The program goes through each letter objects in textRain and assigns a random velocity coefficient that varies the speed of letter objects falling.
Letter object falls until it collides with a pixel that is less (darker) than the brightness threshold.
After the collision, the letter object is lifted up by 15 pixels.
When the letter object reaches the bottom of the screen, it is put back to the top and repeats the falling process.

KeyPressed Inputs:

Up arrow: increase brightness threshold by 2 

Down arrow: decrease brightness threshold by 2

Space bar: debugMode
