import SimpleOpenNI.*;
import java.util.ArrayList;
import java.util.Date;
import java.sql.Timestamp;
import websockets.*;

WebsocketServer socket; //declare the socket that we are using for speech recognition
String voice = "Victoria"; 
int voiceSpeed = 200;

// declare the various skeleton poser objects
SkeletonPoser restPose;
SkeletonPoser handRaisePose;
SkeletonPoser hLeftArmPose;
SkeletonPoser hRightArmPose;
SkeletonPoser pushUpPose;
SkeletonPoser pushDownPose;
 
SimpleOpenNI kinect; 
// constantly updated ArrayList of associated frames (true is stored if that pose is detected)
ArrayList<Boolean> previousRestPoseFrames = new ArrayList<Boolean>();
ArrayList<Boolean> previousHandRaiseFrames = new ArrayList<Boolean>();
ArrayList<Boolean> previousLeftArmFrames = new ArrayList<Boolean>();
ArrayList<Boolean> previousRightArmFrames = new ArrayList<Boolean>();
ArrayList<Boolean> previousPushUpFrames = new ArrayList<Boolean>();
ArrayList<Boolean> previousPushDownFrames = new ArrayList<Boolean>();
float speed = 1.0; //The speed of the video
boolean hasBorder = false; //UI: whether red border is shown
final int NUM_FRAMES = 25; 
final int COMMAND_NUM_FRAMES = 50;

//Different states of the state machine
static final int START = 1;
static final int TRACKING = 2;
static final int REFRACTORY = 3;
static final int VOICE_REFRACTORY = 4;
static final int TRACKING_REFRACTORY = 5;
final int REFRACTORY_PERIOD = 5000;
final int TRACKING_REFRACTORY_PERIOD = 1500;
int state;
long backToRestTimer;
long actionTimer;
long currentTimer;
String previousAction = "";
float previousSpeed = speed;
void setup() { 
  // size(640, 480); //the size for the kinect image
  size(displayWidth, 150);
  background(255,255,255);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  kinect.setMirror(true);
  socket = new WebsocketServer(this, 1337, "/p5websocket");

  initializePoses();
  strokeWeight(5);
  state = START;
  Timestamp actionTimestamp = new Timestamp(System.currentTimeMillis());
  actionTimer = actionTimestamp.getTime();
}

//sets the necessary PoseRules (joint relations) for each pose.
void initializePoses(){
  // RESTING
  restPose = new SkeletonPoser(kinect); 
  // rules for the right arm
  restPose.addRule(SimpleOpenNI.SKEL_RIGHT_ELBOW, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  restPose.addRule(SimpleOpenNI.SKEL_RIGHT_HAND, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_RIGHT_HIP);
  restPose.addRule(SimpleOpenNI.SKEL_RIGHT_HAND, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_RIGHT_ELBOW);
  // rules for the left arm
  restPose.addRule(SimpleOpenNI.SKEL_LEFT_ELBOW, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_LEFT_SHOULDER);
  restPose.addRule(SimpleOpenNI.SKEL_LEFT_HAND, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_LEFT_HIP);
  restPose.addRule(SimpleOpenNI.SKEL_LEFT_HAND, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_LEFT_ELBOW);
  restPose.addRule(SimpleOpenNI.SKEL_RIGHT_KNEE, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_RIGHT_HIP);  
  restPose.addRule(SimpleOpenNI.SKEL_RIGHT_FOOT, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_RIGHT_KNEE);  
  restPose.addRule(SimpleOpenNI.SKEL_LEFT_KNEE, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_LEFT_HIP); 
  restPose.addRule(SimpleOpenNI.SKEL_LEFT_FOOT, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_LEFT_KNEE);  
    
  // HAND RAISE
  handRaisePose = new SkeletonPoser(kinect); 
  // rules for the right arm
  handRaisePose.addRule(SimpleOpenNI.SKEL_RIGHT_ELBOW, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  handRaisePose.addRule(SimpleOpenNI.SKEL_RIGHT_HAND, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_RIGHT_HIP);
  handRaisePose.addRule(SimpleOpenNI.SKEL_RIGHT_HAND, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_RIGHT_ELBOW);
  // rules for the left arm
  handRaisePose.addRule(SimpleOpenNI.SKEL_LEFT_HAND, 
    PoseRule.ABOVE, 
    SimpleOpenNI.SKEL_HEAD);
  handRaisePose.addRule(SimpleOpenNI.SKEL_LEFT_HAND, 
    PoseRule.LEFT_OF, 
    SimpleOpenNI.SKEL_HEAD);
  handRaisePose.addRule(SimpleOpenNI.SKEL_LEFT_ELBOW, 
    PoseRule.LEFT_OF, 
    SimpleOpenNI.SKEL_LEFT_SHOULDER);
  handRaisePose.addRule(SimpleOpenNI.SKEL_LEFT_HAND, 
    PoseRule.ABOVE, 
    SimpleOpenNI.SKEL_LEFT_ELBOW);
  // rules for the right leg
  handRaisePose.addRule(SimpleOpenNI.SKEL_RIGHT_KNEE, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_RIGHT_HIP);  
  handRaisePose.addRule(SimpleOpenNI.SKEL_RIGHT_FOOT, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_RIGHT_KNEE);  
  handRaisePose.addRule(SimpleOpenNI.SKEL_LEFT_KNEE, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_LEFT_HIP); 
  handRaisePose.addRule(SimpleOpenNI.SKEL_LEFT_FOOT, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_LEFT_KNEE); 
  
  
   
  // H LEFT ARM ("Human Left Arm, for the REWIND action")
  // rules for the right arm
  hLeftArmPose = new SkeletonPoser(kinect); 
  hLeftArmPose.addRule(SimpleOpenNI.SKEL_RIGHT_ELBOW, 
    PoseRule.HORIZONTAL, 
    SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  hLeftArmPose.addRule(SimpleOpenNI.SKEL_RIGHT_ELBOW, 
    PoseRule.RIGHT_OF, 
    SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  hLeftArmPose.addRule(SimpleOpenNI.SKEL_RIGHT_HAND, 
    PoseRule.HORIZONTAL, 
    SimpleOpenNI.SKEL_RIGHT_ELBOW);
  hLeftArmPose.addRule(SimpleOpenNI.SKEL_RIGHT_HAND, 
    PoseRule.RIGHT_OF, 
    SimpleOpenNI.SKEL_RIGHT_ELBOW);
   
  // rules for the left arm
  hLeftArmPose.addRule(SimpleOpenNI.SKEL_LEFT_ELBOW, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_LEFT_SHOULDER);
  hLeftArmPose.addRule(SimpleOpenNI.SKEL_LEFT_HAND, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_LEFT_HIP);
  hLeftArmPose.addRule(SimpleOpenNI.SKEL_LEFT_HAND, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_LEFT_ELBOW);
  // rules for the right leg
  hLeftArmPose.addRule(SimpleOpenNI.SKEL_RIGHT_KNEE, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_RIGHT_HIP);  
  hLeftArmPose.addRule(SimpleOpenNI.SKEL_RIGHT_FOOT, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_RIGHT_KNEE);  
  hLeftArmPose.addRule(SimpleOpenNI.SKEL_LEFT_KNEE, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_LEFT_HIP); 
  hLeftArmPose.addRule(SimpleOpenNI.SKEL_LEFT_FOOT, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_LEFT_KNEE);
    
  //H RIGHT ARM (fast forward gesture)
  hRightArmPose = new SkeletonPoser(kinect); 
  // rules for the right arm
  hRightArmPose.addRule(SimpleOpenNI.SKEL_RIGHT_ELBOW, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  hRightArmPose.addRule(SimpleOpenNI.SKEL_RIGHT_HAND, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_RIGHT_HIP);
  hRightArmPose.addRule(SimpleOpenNI.SKEL_RIGHT_HAND, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_RIGHT_ELBOW);
  // rules for the left arm
  hRightArmPose.addRule(SimpleOpenNI.SKEL_LEFT_ELBOW, 
    PoseRule.HORIZONTAL, 
    SimpleOpenNI.SKEL_LEFT_SHOULDER);
  hRightArmPose.addRule(SimpleOpenNI.SKEL_LEFT_ELBOW, 
    PoseRule.LEFT_OF,
    SimpleOpenNI.SKEL_LEFT_SHOULDER);
  hRightArmPose.addRule(SimpleOpenNI.SKEL_LEFT_HAND, 
    PoseRule.HORIZONTAL, 
    SimpleOpenNI.SKEL_LEFT_ELBOW);
  hRightArmPose.addRule(SimpleOpenNI.SKEL_LEFT_HAND, 
    PoseRule.LEFT_OF, 
    SimpleOpenNI.SKEL_LEFT_ELBOW);
  // rules for the right leg
  hRightArmPose.addRule(SimpleOpenNI.SKEL_RIGHT_KNEE, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_RIGHT_HIP);  
  hRightArmPose.addRule(SimpleOpenNI.SKEL_RIGHT_FOOT, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_RIGHT_KNEE);  
  hRightArmPose.addRule(SimpleOpenNI.SKEL_LEFT_KNEE, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_LEFT_HIP); 
  hRightArmPose.addRule(SimpleOpenNI.SKEL_LEFT_FOOT, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_LEFT_KNEE);
    
  //Pose for the speed up gesture
  pushUpPose = new SkeletonPoser(kinect); 
  // rules for the right arm
  pushUpPose.addRule(SimpleOpenNI.SKEL_RIGHT_ELBOW, 
    PoseRule.ABOVE, 
    SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  pushUpPose.addRule(SimpleOpenNI.SKEL_RIGHT_ELBOW, 
    PoseRule.RIGHT_OF, 
    SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  pushUpPose.addRule(SimpleOpenNI.SKEL_RIGHT_HAND, 
    PoseRule.ABOVE, 
    SimpleOpenNI.SKEL_RIGHT_ELBOW);
  pushUpPose.addRule(SimpleOpenNI.SKEL_RIGHT_HAND, 
    PoseRule.VERTICAL, 
    SimpleOpenNI.SKEL_HEAD);
  // rules for the left arm
  pushUpPose.addRule(SimpleOpenNI.SKEL_LEFT_ELBOW, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_LEFT_SHOULDER);
  pushUpPose.addRule(SimpleOpenNI.SKEL_LEFT_HAND, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_LEFT_HIP);
  pushUpPose.addRule(SimpleOpenNI.SKEL_LEFT_HAND, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_LEFT_ELBOW);

  // rules for the right leg
  pushUpPose.addRule(SimpleOpenNI.SKEL_RIGHT_KNEE, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_RIGHT_HIP);  
  pushUpPose.addRule(SimpleOpenNI.SKEL_RIGHT_FOOT, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_RIGHT_KNEE);  
  pushUpPose.addRule(SimpleOpenNI.SKEL_LEFT_KNEE, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_LEFT_HIP); 
  pushUpPose.addRule(SimpleOpenNI.SKEL_LEFT_FOOT, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_LEFT_KNEE);
    
  //Pose for the slow down gesture
  pushDownPose = new SkeletonPoser(kinect); 
  // rules for the right arm
  pushDownPose.addRule(SimpleOpenNI.SKEL_RIGHT_ELBOW, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  pushDownPose.addRule(SimpleOpenNI.SKEL_RIGHT_ELBOW, 
    PoseRule.RIGHT_OF, 
    SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  pushDownPose.addRule(SimpleOpenNI.SKEL_RIGHT_HAND, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_RIGHT_ELBOW);
  pushDownPose.addRule(SimpleOpenNI.SKEL_RIGHT_HAND, 
    PoseRule.VERTICAL, 
    SimpleOpenNI.SKEL_HEAD);
  // rules for the left arm
  pushDownPose.addRule(SimpleOpenNI.SKEL_LEFT_ELBOW, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_LEFT_SHOULDER);
  pushDownPose.addRule(SimpleOpenNI.SKEL_LEFT_HAND, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_LEFT_HIP);
  pushDownPose.addRule(SimpleOpenNI.SKEL_LEFT_HAND, 
    PoseRule.BELOW, 
    SimpleOpenNI.SKEL_LEFT_ELBOW);
  // rules for the right leg
  pushDownPose.addRule(SimpleOpenNI.SKEL_RIGHT_KNEE, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_RIGHT_HIP);  
  pushDownPose.addRule(SimpleOpenNI.SKEL_RIGHT_FOOT, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_RIGHT_KNEE);  
  pushDownPose.addRule(SimpleOpenNI.SKEL_LEFT_KNEE, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_LEFT_HIP); 
  pushDownPose.addRule(SimpleOpenNI.SKEL_LEFT_FOOT, 
    PoseRule.REST_VERTICAL, 
    SimpleOpenNI.SKEL_LEFT_KNEE);
}

void draw() { 
  //background(0); //used for kinect image feed
  kinect.update(); 
  //image(kinect.depthImage(), 0, 0); //used for kinect image feed

  IntVector userList = new IntVector();
  kinect.getUsers(userList);
  if (userList.size() > 0) { //if user is detected
       Timestamp currentTimestamp = new Timestamp(System.currentTimeMillis());
      currentTimer = currentTimestamp.getTime(); 
    if ((currentTimer-actionTimer)>2000) { //used for UI 
      background(255,255,255);
      drawRedBorder(hasBorder);
      drawSpeed(String.valueOf(speed));
    }
    int userId = userList.get(0);
    if ( kinect.isTrackingSkeleton(userId)) { //if user skeleton is tracked
      switch(state) {
      case START: 
        {
          drawVideoPlaying();
          boolean drawResult = checkRestSkeleton(userId);
          if (drawResult){
            background(255,255,255);
            hasBorder = true;
            keyTrigger(STOPSTART);
            state = TRACKING;
            TextToSpeech.say("stopped video", voice, voiceSpeed);
          }
          break;
        }
      case TRACKING: {
        clearUserLost();
        drawRedBorder(hasBorder);
        drawSpeed(String.valueOf(speed));
        boolean leftArmResult = checkLeftArmSkeleton(userId);
        boolean rightArmResult = checkRightArmSkeleton(userId);
        boolean handRaiseResult = checkHandRaiseSkeleton(userId);
        boolean pushUpResult = checkPushUpSkeleton(userId);
        boolean pushDownResult = checkPushDownSkeleton(userId);
        if (leftArmResult){
           keyTrigger(REWIND);
           TextToSpeech.say("rewineded video", voice, voiceSpeed); //intentional misspelling
          Timestamp timestamp = new Timestamp(System.currentTimeMillis());
          actionTimer = timestamp.getTime(); 
          background(255,255,255);
          drawRedBorder(hasBorder);
          drawAction("REWIND 5 SECONDS");
          previousAction = "REWIND 5 SECONDS";
        } 
        else if (rightArmResult){
          keyTrigger(FASTFORWARD);
          TextToSpeech.say("fast forwarded video", voice, voiceSpeed);
          
          Timestamp timestamp = new Timestamp(System.currentTimeMillis());
          actionTimer = timestamp.getTime(); 
          background(255,255,255);
          drawRedBorder(hasBorder);
          drawAction("FAST FORWARD 5 SECONDS");
          previousAction = "FAST FORWARD 5 SECONDS";
        }
        else if (pushUpResult){
          keyTrigger(SPEEDUP);
          TextToSpeech.say("sped up video", voice, voiceSpeed);
          Timestamp timestamp = new Timestamp(System.currentTimeMillis());
          actionTimer = timestamp.getTime();
          if (speed<2.0){
            speed+=0.25;
          }
          
          background(255,255,255);
          drawRedBorder(hasBorder);
          drawAction("SPED UP TO " + speed+"x");
          previousAction = "SPED UP TO " + speed+"x";
          drawSpeed(String.valueOf(speed));
          previousSpeed = speed;
        } 
        else if (pushDownResult){
          keyTrigger(SLOWDOWN);
          TextToSpeech.say("slowed down video", voice, voiceSpeed);
          Timestamp timestamp = new Timestamp(System.currentTimeMillis());
          actionTimer = timestamp.getTime(); 
          clearSpeed(String.valueOf(previousSpeed));
          if (speed>0.25){
            speed-=0.25;
          }
          background(255,255,255);
          drawRedBorder(hasBorder);
          drawAction("SLOWED DOWN TO " + speed+"x");
          previousAction = "SLOWED DOWN TO " + speed+"x";
          drawSpeed(String.valueOf(speed));
          previousSpeed = speed;
        }
        else if (handRaiseResult){
          keyTrigger(STOPSTART);
          TextToSpeech.say("started video", voice, voiceSpeed);
          Timestamp timestamp = new Timestamp(System.currentTimeMillis());
          backToRestTimer = timestamp.getTime();
          state = REFRACTORY;
          
          drawVideoPlaying();
          
        }
        break;
      }
      case REFRACTORY: {
        Timestamp timestampCurrent = new Timestamp(System.currentTimeMillis());
        stroke(255, 0, 0); 
        drawSkeleton(userId);
        if (timestampCurrent.getTime()-backToRestTimer>=REFRACTORY_PERIOD){
          state = START;
          background(255,255,255);
        }
        
      }
      }
    }
  } else {
    background(255,255,255);
    drawUserLost();
  }
}

boolean checkRestSkeleton(int userId){
    // check to see if the user
    // is in the rest pose
    boolean result = false;
    if (restPose.check(userId)) { 
      //if they are, set the color white
      stroke(255); 
      previousRestPoseFrames.add(true);
      boolean allCorrect = true;
      if (previousRestPoseFrames.size()>=NUM_FRAMES) {
        for (int i = previousRestPoseFrames.size()-1; i>=previousRestPoseFrames.size()-NUM_FRAMES; i--) {
          if (previousRestPoseFrames.get(i)==false) {
            allCorrect = false;
          }
        }
        if (allCorrect) {
          result = true;
        }
      }
    } else {
      // otherwise set the color to red
      stroke(255, 0, 0);
    }
    // draw the skeleton in whatever color we chose
    drawSkeleton(userId);
    return result;
}

boolean checkHandRaiseSkeleton(int userId){
    // check to see if the user
    // is in the hand raise pose
    boolean result = false;
    if (handRaisePose.check(userId)) { 
      //if they are, set the color white
      stroke(0, 255, 0); 
      previousHandRaiseFrames.add(true);
      boolean allCorrect = true;
      if (previousHandRaiseFrames.size()>=NUM_FRAMES) {
        for (int i = previousHandRaiseFrames.size()-1; i>=previousHandRaiseFrames.size()-NUM_FRAMES; i--) {
          if (previousHandRaiseFrames.get(i)==false) {
            allCorrect = false;
          }
        }
        if (allCorrect) {
          result = true;
        }
      }
    } else {
      // otherwise set the color to red
      stroke(255, 0, 0);
    }
    // draw the skeleton in whatever color we chose
    drawSkeleton(userId);
    return result;
}

boolean checkLeftArmSkeleton(int userId){
    // check to see if the user
    // is in the rewind pose
    boolean result = false;
    if (hLeftArmPose.check(userId)) { 
      //if they are, set the color white
      stroke(0, 0, 255); 
      previousLeftArmFrames.add(true);
      boolean allCorrect = true;
      if (previousLeftArmFrames.size()>=COMMAND_NUM_FRAMES) {
        for (int i = previousLeftArmFrames.size()-1; i>=previousLeftArmFrames.size()-COMMAND_NUM_FRAMES; i--) {
          if (previousLeftArmFrames.get(i)==false) {
            allCorrect = false;
          }
        }
        if (allCorrect) {
          result = true;
          previousLeftArmFrames.add(false);
        }
      }
    } else {
      // otherwise set the color to red
      stroke(255, 0, 0);
    }
    // draw the skeleton in whatever color we chose
    drawSkeleton(userId);
    return result;
}

boolean checkRightArmSkeleton(int userId){
    // check to see if the user
    // is in the fast-forward pose
    boolean result = false;
    if (hRightArmPose.check(userId)) { 
      //if they are, set the color white
      stroke(0, 0, 255); 
      previousRightArmFrames.add(true);
      boolean allCorrect = true;
      if (previousRightArmFrames.size()>=COMMAND_NUM_FRAMES) {
        for (int i = previousRightArmFrames.size()-1; i>=previousRightArmFrames.size()-COMMAND_NUM_FRAMES; i--) {
          if (previousRightArmFrames.get(i)==false) {
            allCorrect = false;
          }
        }
        if (allCorrect) {
          result = true;
          previousRightArmFrames.add(false);
        }
      }
    } else {
      // otherwise set the color to red
      stroke(255, 0, 0);
    }
    // draw the skeleton in whatever color we chose
    drawSkeleton(userId);
    return result;
}

boolean checkPushUpSkeleton(int userId){
    // check to see if the user
    // is in the speed up pose
    boolean result = false;
    if (pushUpPose.check(userId)) { 
      //if they are, set the color white
      stroke(0, 0, 255); 
      previousPushUpFrames.add(true);
      boolean allCorrect = true;
      if (previousPushUpFrames.size()>=COMMAND_NUM_FRAMES) {
        for (int i = previousPushUpFrames.size()-1; i>=previousPushUpFrames.size()-COMMAND_NUM_FRAMES; i--) {
          if (previousPushUpFrames.get(i)==false) {
            allCorrect = false;
          }
        }
        if (allCorrect) {
          result = true;
          previousPushUpFrames.add(false);
        }
      }
    } else {
      // otherwise set the color to red
      stroke(255, 0, 0);
    }
    // draw the skeleton in whatever color we chose
    drawSkeleton(userId);
    return result;
}

boolean checkPushDownSkeleton(int userId){
    // check to see if the user
    // is in the slow down pose
    boolean result = false;
    if (pushDownPose.check(userId)) { 
      //if they are, set the color white
      stroke(0, 0, 255); 
      previousPushDownFrames.add(true);
      boolean allCorrect = true;
      if (previousPushDownFrames.size()>=COMMAND_NUM_FRAMES) {
        for (int i = previousPushDownFrames.size()-1; i>=previousPushDownFrames.size()-COMMAND_NUM_FRAMES; i--) {
          if (previousPushDownFrames.get(i)==false) {
            allCorrect = false;
          }
        }
        if (allCorrect) {
          result = true;
          previousPushDownFrames.add(false);
        }
      }
    } else {
      // otherwise set the color to red
      stroke(255, 0, 0);
    }
    // draw the skeleton in whatever color we chose
    drawSkeleton(userId);
    return result;
}

// Recomment to drawSkeleton, if kinect feed image is desired
void drawSkeleton(int userId) {
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, 
  //  SimpleOpenNI.SKEL_NECK);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, 
  //  SimpleOpenNI.SKEL_LEFT_SHOULDER);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, 
  //  SimpleOpenNI.SKEL_LEFT_ELBOW);
  //kinect.drawLimb(userId, 
  //  SimpleOpenNI.SKEL_LEFT_ELBOW, 
  //  SimpleOpenNI.SKEL_LEFT_HAND);
  //kinect.drawLimb(userId, 
  //  SimpleOpenNI.SKEL_NECK, 
  //  SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  //kinect.drawLimb(userId, 
  //  SimpleOpenNI.SKEL_RIGHT_SHOULDER, 
  //  SimpleOpenNI.SKEL_RIGHT_ELBOW);
  //kinect.drawLimb(userId, 
  //  SimpleOpenNI.SKEL_RIGHT_ELBOW, 
  //  SimpleOpenNI.SKEL_RIGHT_HAND);
  //kinect.drawLimb(userId, 
  //  SimpleOpenNI.SKEL_LEFT_SHOULDER, 
  //  SimpleOpenNI.SKEL_TORSO);
  //kinect.drawLimb(userId, 
  //  SimpleOpenNI.SKEL_RIGHT_SHOULDER, 
  //  SimpleOpenNI.SKEL_TORSO);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, 
  //  SimpleOpenNI.SKEL_LEFT_HIP);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, 
  //  SimpleOpenNI.SKEL_LEFT_KNEE);
  //kinect.drawLimb(userId, 
  //  SimpleOpenNI.SKEL_LEFT_KNEE, 
  //  SimpleOpenNI.SKEL_LEFT_FOOT);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, 
  //  SimpleOpenNI.SKEL_RIGHT_HIP);
  //kinect.drawLimb(userId, 
  //  SimpleOpenNI.SKEL_RIGHT_HIP, 
  //  SimpleOpenNI.SKEL_RIGHT_KNEE);
  //kinect.drawLimb(userId, 
  //  SimpleOpenNI.SKEL_RIGHT_KNEE, 
  //  SimpleOpenNI.SKEL_RIGHT_FOOT);
  //kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, 
  //  SimpleOpenNI.SKEL_LEFT_HIP);
}

void drawLimb(int userId, int jointType1, int jointType2)
{
  PVector jointPos1 = new PVector();
  PVector jointPos2 = new PVector();
  float confidence;

  // draw the joint position
  confidence = kinect.getJointPositionSkeleton(userId, jointType1, jointPos1);
  confidence = kinect.getJointPositionSkeleton(userId, jointType2, jointPos2);

  line(jointPos1.x, jointPos1.y, jointPos1.z, 
    jointPos2.x, jointPos2.y, jointPos2.z);
}

// user-tracking callbacks!
void onNewUser(SimpleOpenNI kinect, int userId) {
  kinect.startTrackingSkeleton(userId);
}

//upon losing a user, reset the frames seen so far
void onLostUser(SimpleOpenNI curContext, int userId) {
  previousRestPoseFrames = new ArrayList<Boolean>();
  previousHandRaiseFrames = new ArrayList<Boolean>();
  previousLeftArmFrames = new ArrayList<Boolean>();
  previousRightArmFrames = new ArrayList<Boolean>();
  previousPushUpFrames = new ArrayList<Boolean>();
  previousPushDownFrames = new ArrayList<Boolean>();
}

void onVisibleUser(SimpleOpenNI curContext, int userId) {
}


//Function to receive the speech recognition results from the Codepen.
//See http://florianschulz.info/stt/
void webSocketServerEvent(String msg){
  processVoiceInput(msg);
}

//Processes the speech transcript, and if relevant, performs the correct action with
//necessary state transitions
void processVoiceInput(String msg){
  switch(state){
    case START: {
      if (msg.toLowerCase().contains("stop")){
        keyTrigger(STOPSTART); 
        TextToSpeech.say("video stopped", voice, voiceSpeed);
        state = TRACKING; 
      }
      break;
    }
    case TRACKING: {
      if (msg.toLowerCase().contains("start") && !(msg.toLowerCase().contains("video"))){
        keyTrigger(STOPSTART);
        TextToSpeech.say("video started", voice, voiceSpeed);
        Timestamp timestamp = new Timestamp(System.currentTimeMillis());
        backToRestTimer = timestamp.getTime();
        state = VOICE_REFRACTORY; 
      } else if ((msg.toLowerCase().contains("d up") || msg.toLowerCase().contains("t up")) && !(msg.toLowerCase().contains("video"))){
        keyTrigger(SPEEDUP);
        TextToSpeech.say("video sped up", voice, voiceSpeed);
        Timestamp timestamp = new Timestamp(System.currentTimeMillis());
        backToRestTimer = timestamp.getTime();
        state = TRACKING_REFRACTORY; 
      } else if (msg.toLowerCase().contains("slow down") && !(msg.toLowerCase().contains("video"))){
        keyTrigger(SLOWDOWN);
        TextToSpeech.say("video slowed down", voice, voiceSpeed);
        Timestamp timestamp = new Timestamp(System.currentTimeMillis());
        backToRestTimer = timestamp.getTime();
        state = TRACKING_REFRACTORY; 
      } else if (msg.toLowerCase().contains("fast forward") && !(msg.toLowerCase().contains("video"))){
        String [] splitString = msg.toLowerCase().split(" ");
        int numIndex = -1;
        for (int i = 0; i<splitString.length; i++){
          if (splitString[i].equals("forward")){
            numIndex = i+1;
            break;
          }
        }
        try {
          int numTimesToProcess = round(Integer.parseInt(splitString[numIndex])/5.0);
          int numActualSeconds = 5*numTimesToProcess;
          for (int j = 0; j<numTimesToProcess;j++){
            keyTrigger(FASTFORWARD);
          }
          TextToSpeech.say(String.format("video fast forwarded %d seconds", numActualSeconds), voice, voiceSpeed); //intentional misspelling   
      } catch(Exception e){
          keyTrigger(FASTFORWARD);
          TextToSpeech.say(String.format("video fast forwarded 5 seconds"), voice, voiceSpeed); //intentional misspelling
    
      }
        Timestamp timestamp = new Timestamp(System.currentTimeMillis());
        backToRestTimer = timestamp.getTime();
        state = TRACKING_REFRACTORY; 
      }
      else if (msg.toLowerCase().contains("rewind") && !(msg.toLowerCase().contains("video"))){
        String [] splitString = msg.toLowerCase().split(" ");
        int numIndex = -1;
        for (int i = 0; i<splitString.length; i++){
          if (splitString[i].equals("rewind")){
            numIndex = i+1;
            break;
          }
        }
        try {
          int numTimesToProcess = round(Integer.parseInt(splitString[numIndex])/5.0);
          int numActualSeconds = 5*numTimesToProcess;
          for (int j = 0; j<numTimesToProcess;j++){
            keyTrigger(REWIND);
          }
          TextToSpeech.say(String.format("video rewineded %d seconds", numActualSeconds), voice, voiceSpeed); //intentional misspelling
        } catch(Exception e){
          keyTrigger(REWIND);
          TextToSpeech.say(String.format("video rewineded 5 seconds"), voice, voiceSpeed); //intentional misspelling
        }
        Timestamp timestamp = new Timestamp(System.currentTimeMillis());
        backToRestTimer = timestamp.getTime();
        state = TRACKING_REFRACTORY; 

      }
      break;
    }
    case TRACKING_REFRACTORY: {
      Timestamp timestampCurrent = new Timestamp(System.currentTimeMillis());
      if (timestampCurrent.getTime()-backToRestTimer>=TRACKING_REFRACTORY_PERIOD){
        state = TRACKING;
      }
      break;
    }
    
    case VOICE_REFRACTORY: {
      Timestamp timestampCurrent = new Timestamp(System.currentTimeMillis());
      if (timestampCurrent.getTime()-backToRestTimer>=REFRACTORY_PERIOD){
        state = START;
      }
      break;
    }
    
    
      
  }
}
