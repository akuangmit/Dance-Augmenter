//Defines the relations terminology between different joints (e.g. ABOVE), and performs the relations check
class PoseRule { 
  int fromJoint;
  int toJoint;
  PVector fromJointVector;
  PVector toJointVector;
  SimpleOpenNI context;

  int jointRelation; // one of:
  static final int ABOVE     = 1;
  static final int BELOW     = 2;
  static final int LEFT_OF   = 3;
  static final int RIGHT_OF  = 4;
  static final int HORIZONTAL = 5;
  static final int VERTICAL = 6;
  static final int REST_VERTICAL = 7;
  static final int VERTICAL_THRESHOLD = 100;
  static final int HORIZONTAL_THRESHOLD = 100;
  static final int REST_HORIZONTAL_THRESHOLD = 110;
  PoseRule(SimpleOpenNI tempContext, 
           int tempFromJoint,
           int tempJointRelation,
           int tempToJoint)
  {
    context = tempContext; 
    fromJoint = tempFromJoint;
    toJoint = tempToJoint;
    jointRelation = tempJointRelation;

    fromJointVector = new PVector(); 
    toJointVector = new PVector();
  }

  boolean check(int userID){ 

    // populate the joint vectors for the user we're checking
    context.getJointPositionSkeleton(userID, fromJoint, fromJointVector);
    context.getJointPositionSkeleton(userID, toJoint, toJointVector);

    boolean result= false;

    switch(jointRelation){ 
     case ABOVE:
       result = (fromJointVector.y > toJointVector.y);
     break;
     case BELOW:
       result = (fromJointVector.y < toJointVector.y);
     break;
     case LEFT_OF:
       result = (fromJointVector.x < toJointVector.x);
     break;
     case RIGHT_OF:
       result = (fromJointVector.x > toJointVector.x);
     break;
     case HORIZONTAL:
       result = abs(fromJointVector.y - toJointVector.y)<=VERTICAL_THRESHOLD;
     break;
     
     case VERTICAL:
       result = abs(fromJointVector.x - toJointVector.x)<=HORIZONTAL_THRESHOLD;
     break;
     
     case REST_VERTICAL:
       result = abs(fromJointVector.x - toJointVector.x)<=REST_HORIZONTAL_THRESHOLD;
     break;
    }
    return result; 
  }
}

// A class that has a set of PoseRules, which all together have to be true in order to count as a valid pose (e.g resting position)
class SkeletonPoser { 
  SimpleOpenNI context;
  ArrayList rules;


  SkeletonPoser(SimpleOpenNI context){ 
    this.context = context;
    rules = new ArrayList(); 
  }
  
  void addRule(int fromJoint, int jointRelation, int toJoint){ 
    PoseRule rule = new PoseRule(context, fromJoint, jointRelation, toJoint);
    rules.add(rule);
  }
  
  void addRuleDistance(int fromJoint, int jointRelation, int toJoint){ //fromJointLeft, fromJointRight, toJointLeft, to jointRight
    PoseRule rule = new PoseRule(context, fromJoint, jointRelation, toJoint);
    rules.add(rule);
  }

  boolean check(int userID){ 

    boolean result = true; 
    for(int i = 0; i < rules.size(); i++){ 
      PoseRule rule = (PoseRule)rules.get(i); 
      result = result && rule.check(userID); 
    }
    return result; 
  }

}
