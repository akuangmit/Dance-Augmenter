//Helper functions used to draw our User Interface
PImage img;

void drawVideoPlaying(){ 
  background(255,255,255);
  textSize(40);
  fill(0, 0, 0);
  
  textAlign(CENTER, CENTER);
  text("VIDEO PLAYING...", displayWidth/2, height/2);
}

void drawRedBorder(boolean hasBorder){
  if (hasBorder){
    int borderStroke = 10;
    fill(255,0,0);
    stroke(255,0,0);
    rect(0, 0, width, borderStroke); // Top
    rect(width-borderStroke, 0, borderStroke, height); // Right
    rect(0, height-borderStroke, width, borderStroke); // Bottom
    rect(0, 0, borderStroke, height); // Left
  } else {
    int borderStroke = 10;
    fill(255,255,255);
    stroke(255,255,255);
    rect(0, 0, width, borderStroke); // Top
    rect(width-borderStroke, 0, borderStroke, height); // Right
    rect(0, height-borderStroke, width, borderStroke); // Bottom
    rect(0, 0, borderStroke, height); // Left
  }
}

void undrawRedBorder(){
  int borderStroke = 20;
  fill(255,255, 255);
  stroke(255,255,255);
  rect(0, 0, width, borderStroke); // Top
  rect(width-borderStroke, 0, borderStroke, height); // Right
  rect(0, height-borderStroke, width, borderStroke); // Bottom
  rect(0, 0, borderStroke, height); // Left
}

void drawAction(String action){
  textSize(40);
  fill(0, 0, 0);
  textAlign(CENTER, CENTER);
  text(action, displayWidth/2, 0.75*height);
}

void clearAction(String previousAction){
  textSize(40);
  fill(255, 255, 255);
  textAlign(CENTER, CENTER);
  text(previousAction, displayWidth/2, 0.75*height);
}



void drawSpeed(String speed){
  textSize(30);
  fill(0,0,0);
  textAlign(TOP, RIGHT);
  text(speed+"x", 0.90*displayWidth, height/3);
}

void clearSpeed(String previousSpeed){
  textSize(30);
  fill(255,255,255);
  textAlign(TOP, RIGHT);
  text(previousSpeed+"x", 0.90*displayWidth, height/3);
}
void drawUserLost(){
  //background(0,0,0);
  textSize(40);
  fill(0, 0, 0);
  textAlign(CENTER, CENTER);
  text("USER LOST", displayWidth/2, height/2);
 
}

void clearUserLost(){
  textSize(40);
  fill(255, 255, 255);
  textAlign(CENTER, CENTER);
  text("USER LOST", displayWidth/2, height/2);
}
