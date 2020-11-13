/* UserReset - The userControllerResetAndRun method defined in this tab. 
               Also, (lib 1.4.3) robot StateInformation can be saved/restored with markers. See Below
   
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
  float robotHeading;          // Note: this value is not updated during contest run.
  int   timerTick;             // lap timer stop watch time elapsed (lap state not preserved) 

  int   sampleTempValue = 99;
  
  // may need to add target speed and target turnRate values 
  // but controller will typically update every simulation step.
  
  

  // DO NOT ALTER ABOVE FIELDS ----------------------------------------------------------

  // USER ROBOT STATE VARIABLES BELOW 
  // Only data types that will be saved/restored  float,int,boolean,String,int[],float[]    
  
  // At present, adding a new field will result in program crash.
  // delete the .srs file associated with contest course file, and re-create saved state 
  // markers. 
    
  int sampleCounter; // example state variable 
 
}



void userControllerResetAndRun() 
{
  userInit();                               // call userInit() to init sensors & accel rates.

  lfs.moveToStartLocationAndHeading();      // initial position, click on marker overrides (lib 1.3)
   
  lfs.setTargetSpeed(6.0f);   // example start driving robot straight
  
  // might be used if you are only controlling turn rate.
  
  // reset user state variables
  // (not much to do in simple demo controller)
  // If you are creating a challenge course controller you will probably have several state variables.
  // Be sure to reset them 
  
                                      // If using saved robot state option,
  RobotState cs = currentRobotState;  // get shorthand reference to current state
                                      // note this is not a "new" instance. 
  cs.sampleCounter = 1;               // example access to current RobotState. This shorthand alias is 
                                      // also implemented in UserCon
                                      
 
  

} // end userControllerResetAndRun
