//Code to simulate keyboard presses
import SimpleOpenNI.*;
import java.util.ArrayList;

import java.awt.Robot;
import java.awt.event.KeyEvent;
import java.io.IOException;

int keyCommand; // one of:
static final int STOPSTART     = 1;
static final int SPEEDUP     = 2;
static final int SLOWDOWN   = 3;
static final int REWIND   = 4;
static final int FASTFORWARD   = 5;
  
void keyTrigger(int inputCommand){
  try {
    Robot robot = new Robot();
    //robot.delay(3000);
    switch(inputCommand){
      case STOPSTART:
        robot.keyPress(KeyEvent.VK_SPACE);
        robot.delay(25);
        robot.keyRelease(KeyEvent.VK_SPACE);
        robot.delay(25);
        break;
      case SPEEDUP:
        robot.keyPress(KeyEvent.VK_SHIFT);
        robot.keyPress(KeyEvent.VK_PERIOD);
        robot.delay(25);
        robot.keyRelease(KeyEvent.VK_PERIOD);
        robot.keyRelease(KeyEvent.VK_SHIFT);
        robot.delay(25);
        break;
      case SLOWDOWN:
        robot.keyPress(KeyEvent.VK_SHIFT);
        robot.keyPress(KeyEvent.VK_COMMA);
        robot.delay(25);
        robot.keyRelease(KeyEvent.VK_COMMA);
        robot.keyRelease(KeyEvent.VK_SHIFT);
        robot.delay(25);
        break;
      case REWIND:
        robot.keyPress(KeyEvent.VK_LEFT);
        robot.delay(25);
        robot.keyRelease(KeyEvent.VK_LEFT);
        robot.delay(25);
        break;
      case FASTFORWARD:
        robot.keyPress(KeyEvent.VK_RIGHT);
        robot.delay(25);
        robot.keyRelease(KeyEvent.VK_RIGHT);
        robot.delay(25);
        break;
      
    }
  }
  catch (Exception e) {
    e.printStackTrace();
    exit();
  }
}
