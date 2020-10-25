/* UserReset - Trike Bot

   Method userControllerResetAndRun is called when the simulation
   is doing a contest Run
   
   It will have cleared sensor definitions, so best to call userInit()
   Also, anything related to controller state should be reset.
   
   You may want to verify that multiple R)un commands has same behavior 
   as inital run when sketch is started. One possible problem is not zeroing
   variables that are expected to be zero when program starts might result
   in differing behavior.

*/
  
void userControllerResetAndRun() 
{
  userInit();                               // call userInit() to init sensors & accel rates.
 
  lfs.setPositionAndHeading (52,12,0);      // override initial position & heading with start
                                            // at 52,12,0
  
  // lfs.setPositionAndHeading (52-4,12,0);  
  lfs.moveToStartLocationAndHeading();      // initial position, click on marker overrides (lib 1.3)
   
  // lfs.setTargetSpeed(6.0f);   // example start driving robot straight -- Trike uses wheelVelocity to set
  trike.wheelVelocity = 4.0;     // Target Speed - See: trikeDriveUpdate () in UserTracking
 
 
  // might be used if you are only controlling turn rate.
  
  // reset user state variables
  // (not much to do in simple demo controller)
  // If you are creating a challenge course controller you will probably have several state variables.
  // Be sure to reset them were 
  
  trackingUpdateInit();
  
  cOld = 0;       // centroid of path run  
  sensorState = 0;
  toGo = 0.0;     //  = turn angle / robot.wheelBase  wjk 6-27- 2020
  
  
} // end userControllerResetAndRun
