/* UserReset - Robot Run 

   Method userControllerResetAndRun is called when the simulation
   is starting or re-starting your robot.
   
   LFS will have cleared sensor definitions, so best to call your userInit()
   Also, anything related to controller state should be reset.
   
   You may want to verify that multiple R)un commands has same behavior 
   as inital run when sketch is started. One possible problem is not zeroing
   variables that are expected to be zero when program starts might result
   in differing behavior.

*/
  
void userControllerResetAndRun() 
{
  userInit();                               // call userInit() to init sensors & accel rates.
  
 //if (courseNum == 2)
  //lfs.setPositionAndHeading (52,12,0);      // override initial position & heading with start
                                            // at 52,12,0
 lfs.setPositionAndHeading(startLocX,startLocY,startLocHeading);
   
  lfs.setTargetSpeed(6.0f);   // example start driving robot straight
  // might be used if you are only controlling turn rate.
  
  // reset user state variables
  // (not much to do in simple demo controller)
  // If you are creating a challenge course controller you will probably have several state variables.
  // Be sure to reset them were 
  
  ePrev = 0;
  
  

} // end userControllerResetAndRun
