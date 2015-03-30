/**
 Comp 394 Spring '15 Assignment #1 Text Rain
 Tianyi Liu
**/


import processing.video.*;

// Global variables for handling video data and the input selection screen
String[] cameras;
Capture cam;
Movie mov;
PImage inputImage;
boolean inputMethodSelected = false;

PFont font;
ArrayList<Letter> textRain = new ArrayList<Letter>();
String text = "It is a capital mistake to theorize before one has data. Insensibly one begins to twist facts to suit theories, instead of theories to fit facts. — Sherlock Holmes";
char[] letters = new char[text.length()]; 
int fontSize = 20;
float threshold = 145.0; //brightness threshold
boolean debugMode = false;
double initialTime = System.nanoTime();
double totalElapsed = 0;

void setup() {
  size(1280, 720);
  inputImage = createImage(width, height, RGB);
  font = createFont("AmericanTypewriter", fontSize, true);
  textFont(font, fontSize);
  splitString();
  createLetter();
}


void draw() {

  double timeElapsed = ((double)System.nanoTime()) - initialTime-totalElapsed;
  totalElapsed = totalElapsed + timeElapsed;

  if (timeElapsed > 100000) {
    timeElapsed = 1000;
  }
  
  if (totalElapsed > 500000) {
    initialTime = 0;
    totalElapsed = 0;
  }

  totalElapsed = totalElapsed + timeElapsed;

  // When the program first starts, draw a menu of different options for which camera to use for input
  // The input method is selected by pressing a key 0-9 on the keyboard
  if (!inputMethodSelected) {
    cameras = Capture.list();
    int y=40;
    text("O: Offline mode, test with TextRainInput.mov movie file instead of live camera feed.", 20, y);
    y += 40;
    
    for (int i = 0; i < min (9, cameras.length); i++) {
      text(i+1 + ": " + cameras[i], 20, y);
      y += 40;
    }
    return;
  }
  // This part of the draw loop gets called after the input selection screen, during normal execution of the program.

  // STEP 1. Load an image, either from a movie file or from a live camera feed. Store the result in the inputImage variable

  if ((cam != null) && (cam.available())) {
    cam.read();
    //inputImage.copy(cam, 0,0,cam.width,cam.height, 0,0,inputImage.width,inputImage.height);

    //change to grayscale
    cam.filter(GRAY);

    cam.loadPixels();
    for (int x = 0; x < cam.width; x++) {
      for (int y = 0; y < cam.height; y++) {
        int pos = x + (y * cam.width);

        //flip x axis so the image is unmirrored
        inputImage.pixels[pos] = cam.pixels[((cam.width - 1) - x) + (y * cam.width)]; //cam is 2D array, inputImage is 1D array

        //binary screen (black and white) for debugging
        if (debugMode == true) {
          debugScreen(pos);
        }
      }
    }
    
    inputImage.updatePixels();
    image(inputImage, 0, 0);
    
  } else if ((mov != null) && (mov.available())) {
    mov.read();
    inputImage.copy(mov, 0, 0, mov.width, mov.height, 0, 0, inputImage.width, inputImage.height);
  }
  
  // Fill in your code to implement the rest of TextRain here..

  // Tip: This code draws the current input image to the screen

  set(0, 0, inputImage);

  for (Letter letter : textRain) {
    letter.display();
    if (letter.ypos <= height) {
      if (letter.getBrightness() < threshold) {
        
        if (letter.ypos > 0) {
          letter.up();
        }
        
      } else { 
        letter.down(timeElapsed);
      }
      
    //Put the letter back to the top after it reaches bottom screen
    } else if (letter.ypos > height) {
      letter.ypos = 0;
    }
  }
}

//change pixels color to black and white, based on the threshold
void debugScreen(int pos) {
  float light = brightness(inputImage.pixels[pos]);
  if (light > threshold) {
    inputImage.pixels[pos] = color(255);
  } else {
    inputImage.pixels[pos] = color(0);
  }
}

//splits the input string into chars
void splitString() {
  for (int i = 0; i < text.length (); i++) {
    letters[i] = text.charAt(i);
  }
}

//initializes individual letters
void createLetter() {
  for (char c : letters) {
    Letter letter = new Letter(c);
    textRain.add(letter);
  }
}


//Object class
class Letter {
  //*****Variables*****//
  char c;
  double xpos;
  double ypos;
  
  //*****Constructor*****//
  Letter(char inputLetter) {
    c = inputLetter;
    xpos = int(random(0, width));
    ypos = 1;
  }

  //*****Functions*****//
  //diplays a letter
  void display() {
    textSize(20);
    fill(random(0, 255), random(0, 255), random(0, 255));
    text(c, (int)xpos, (int)ypos);
  }
  
  //moves the letter downward
  void down(double timeElapsed) {
    
    timeElapsed = timeElapsed/1000;
    
    //Assigns random velocity coefficient
    float velocityCoefficient = random(0, 20);
    double velocity = timeElapsed * (double)velocityCoefficient;

    if (ypos < height) {
      ypos = ypos +velocity;
    }
  }

  //moves the letter upward, 15 pixels at time
  void up() {
    if ((ypos - 15) > 0) {
      ypos = ypos - 15;
    }
  }
  
  //get the brightness of letter pixel
  float getBrightness() {
    loadPixels();
    int pos = (int)xpos + ((int)ypos * width); //pixel location = x + y * width
    float light = brightness(pixels[pos]);
    return light;
  }
}


void keyPressed() {
  if (!inputMethodSelected) {
    // If we haven't yet selected the input method, then check for 0 to 9 keypresses to select from the input menu
    if ((key >= '0') && (key <= '9')) {
      int input = key - '0';
      if (input == 0) {
        println("Offline mode selected.");
        mov = new Movie(this, "TextRainInput.mov");
        mov.loop();
        inputMethodSelected = true;
      } else if ((input >= 1) && (input <= 9)) {
        println("Camera " + input + " selected.");
        // The camera can be initialized directly using an element from the array returned by list():
        cam = new Capture(this, cameras[input-1]);
        cam.start();
        inputMethodSelected = true;
      }
    }
    return;
  }

  // This part of the keyPressed routine gets called after the input selection screen during normal execution of the program
  // Fill in your code to handle keypresses here..
  
  if (key == CODED) {
    if (keyCode == UP) {
      //up arrow key pressed, increase threshold
      threshold = threshold + 2;
    } else if (keyCode == DOWN) {
      //down arrow key pressed, decrese threshold
      threshold = threshold - 2;
    }
  } else if (key == ' ') {
    //space bar pressed, change the screen to debugMode
    if (debugMode == false) {
      debugMode = true;
    } else {
      debugMode = false;
    }
  }
}

