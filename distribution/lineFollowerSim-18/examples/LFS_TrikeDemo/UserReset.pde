/* UserReset - The userControllerResetAndRun method defined in this tab. 
               Also, (lib 1.4.3) robot StateInformation can be saved/restored with markers. See Below
  
   TRIKE MODS INCLUDED 
   
   Method userControllerResetAndRun is called when the simulation
   is starting or re-starting your robot, e.g. R)un or G)o command issued.
   
   LFS will have cleared sensor definitions, so best to call your userInit method.
   Also, anything related to your controller state should be reset.
   
   You may want to verify that multiple R)un commands have the same behavior 
   as initial run when sketch is first started. If differing behavior you may want to
   verify all state variables are reset with explicit setting of values to zero that may
   have not been explicitly set when program started.
   
   Java sets all global primative variables to zero, i.e. byte,short,int,float..  all zero
   boolean false.
   
   So best to explicitly set them in your userControllerResetAndRun method.
   
   ----------------------------------------------------------------------------------------------
   ROBOT STATE SAVE/RESTORE   Optional robot diagnostic facility -- new feature   (lib 1.5)
                              See LFS_RS header for more information.
    
*/


RobotState currentRobotState = new RobotState(); // LFS will access this instance of RobotState and so can your controller
                                                 // code. If you want to use this facility, you may find it very handy to
                                                 // create a shorthand alias, e.g. RobotState cs = currentRobotState;
                                                 // then to access and modify values e.g.   cs.sampleCounter++;
                                                 // versus verbose  currentRobotState.sampleCounter++;

class RobotState  {
  
  // DO NOT ALTER BELOW FIELDS  --------------------------------------------------------
  
  float markerX,markerY;       // system defined record of marker location this state is 
                               // associated with.
                    
  float robotSpeed;            // current robot speed and turn rate must also be defined
  float robotSidewaysSpeed;    // and not modified by user  
  float robotTurnRate;        
  float robotHeading;          // Note: this value is not updatated during contest run.

  int   timerTick;             // lap timer stop watch time elapsed (lap state not preserved) 

  int   sampleTempValue = 99;

  

  // DO NOT ALTER ABOVE FIELDS ----------------------------------------------------------

  // USER ROBOT STATE VARIABLES BELOW 
  // Only data types that will be saved/restored  float,int,boolean,String,int[],float[]    
  
  // If adding / removing variables, you might lose ability load saved state. 
  // If difficulties, you can always erase the .srs file associated with your contest course and erase your markers.
  // Then create new saved "run" states as needed.
  
  int cOld = 0;         // centroid of path run  
  int sensorState = 0;
  float toGo = 0.0;     //  = turn angle / robot.wheelBase  wjk 6-27- 2020
  
  float wheelVelocity;  // trike driven wheel speed inches/sec
  float steerAngleR;    // trike driven wheel angle in radians 
  
  float steerAngleDeg;  // trike wheel angle in degrees - rg added for fun - computed for display only 
  
  
  float x1_h;           // uTracking state  
  float x2_h;
  
 
}

boolean firstReset = true;  // used to prevent reset of trike speed 

void userControllerResetAndRun() 
{
  userInit();                               // call userInit() to init sensors & accel rates.

  lfs.moveToStartLocationAndHeading();      // initial position, click on marker overrides (lib 1.3)
   
  //lfs.setTargetSpeed(6.0f);              // example start driving robot straight - commented out
                                           // trike defines wheel speed and steer angle -- then
                                           // values transformed to speed and turn rate of LFS robot
                                
  
 
 
  
  // might be used if you are only controlling turn rate.
  
  // reset user state variables
  // (not much to do in simple demo controller)
  // If you are creating a challenge course controller you will probably have several state variables.
  // Be sure to reset them 
  
  RobotState cs = currentRobotState;  // get shorthand reference to current state
                                      // note this is not a "new" instance. 
    
  
   if (firstReset)
  {
 //  firstReset = false;
   trike.wheelVelocity = 4.0;     // Target Speed - See: trikeDriveUpdate () in UserTracking
   cs.wheelVelocity = 4.0;
   
  // lfs.stop();
   
   
  }
    
                                      
   
  // reset user state variables
  // (not much to do in simple demo controller)
  // If you are creating a challenge course controller you will probably have several state variables.
  // Be sure to reset them were 
  
  // need to move into cs.
  
  trackingUpdateInit();   // init state space tracking, notebook tab uTracking
 
                          // init state variables (now part of currentRobotState instance of RobotState defined above.) 
  cs.cOld = 0;            // centroid of path run  
  cs.sensorState = 0;
  cs. toGo = 0.0;         //  = turn angle / robot.wheelBase  wjk 6-27- 2020

} // end userControllerResetAndRun
