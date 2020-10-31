/* UserDraw - optional user draw overlay on top of robot view

   userDraw can be empty or code commented out
   if no robot overlay geometry needed

   Image overlay supported Lib 1.3.1
   See UserInit where icon is defined and loaded.


   NOT using image overlay in robot view as is done in LFS_SampleBot

*/


PImage bigIcon;             // this variable should be defined for use by userDraw method     

boolean showUserDraw = true; // set false to eliminate user drawing

void userDraw()
{
  // Draw Trike Features over robot view 
  if (showUserDraw == false) return;    
  
  float sc = 4.0/64;
 
  // sets up transforms origin robot center scale inches with +X up on screen and +y to right on screen
  if (courseTop) lfs.setupUserDraw();      // sets up transforms origin robot center scale inches for Robot view
  else lfs.setupUserDrawSensorViewport();  // ... for SensorView
      
  lfs.drawRobotCoordAxes();  // draw robot coordinate axes 
  
 
  stroke(color(250, 0, 0));  // red 
  strokeWeight(5.0*sc);
  
  line(0,0,-3,0);           // body line from robot origin to 3 inches back (-3 inches robot X)
     
  stroke(color(250, 0, 0));  // red          
  strokeWeight(10.0*sc);
  line( -3,0, -3.0-1.0*cos(trike.steerAngleR),1.0*sin(-trike.steerAngleR) );   // 1" radius  wheel at current steer angle 
                
  // show steerAngle due Only to error, no errorRate  wjk 6-25-2020    
   
  stroke(color(0, 0, 250));  // blue                 
  strokeWeight(5.0*sc);
  line(-3,0, -3.0-1.0*cos(uError) , 1.0*sin(-uError));  // 1" radius wheel 
  
}
