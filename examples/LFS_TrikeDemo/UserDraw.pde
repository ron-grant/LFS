
void userDraw()
{
  // Draw Trike Features over robot view 
  // 
  
  
  float sc = 4.0/64;
  
  lfs.setupUserDraw();       // sets up transforms origin robot center scale inches
                             // with +X up on screen and +y to right on screen
    
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
