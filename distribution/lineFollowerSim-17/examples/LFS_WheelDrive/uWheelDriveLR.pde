/* uWheelDriveLR 
  
   This code figures out how fast our robot is moving forward and how fast it is turning, which is the 
   information LFS needs to know, given Left and Right wheel speed and distance between the wheels.
   
   If the wheels are moving the same speed, then it is not turning and the wheel separation does not matter.
   
   If the wheels are turning different speeds then wheel separation distance does matter.
   
   Think about robot 5 feet wide if one wheel was moving 1 inch per second forward and the other 1 inche per second
   backward. How much would the robot turn in 1 second (not much)!
   
   Now imagine a robot 2 inches wide with wheels turning the same speed, how much does that robot turn in one second?
   
       
*/     
 
 void updateRobotSpeedAndTurnRate(float wL, float wR, float wheelSeparation)
 {
 
   float dt = lfs.getTimeStep();  // get value defined in UserInit, should be 0.02
   
   float a = wheelSeparation;     // the distance between the wheels (constant)
 
   float b = (wL-wR)*dt;          // the difference in how far the wheels traveled in one tiny time step (dt)
                                  // wL and wR are speeds in inches per second.  For example if wR-wL =  3 inches/sec 
                                  // distance traveled in inches is speed times time.   So 3 inches/sec * 0.02  = 0.06 inches
                                  // is the length of b and a = 3, a very skinny triangle. the arc tangent of (0.06/3) is 
                                  // about 1.1 degrees which is the amount the robot turned in that period of time.
                                  //
                                  //        y   _                    If the left wheel traveled further than right by   
                                  //      b |          -             distance b  then the robot rotated by the angle 
                                  //        x--------+--------z      by line xz and xy. The Arctangent function computes
                                  //       wheel     a       wheel   this angle.
                                  //         L                 R 
                                

 float turnAngle = atan (b/a);    // b and a are the sides of a right triangle and the arc tangent function tells us 
                                  // the angle in radians - using trigonometry  
 
 float turnAngleDegrees = turnAngle * 180./PI;           // convert angle from radians to degrees
 float turnRateDegreesPerSec  =  turnAngleDegrees/dt;    // convert to rate degrees/sec   our angle was turned in 0.02 seconds 
                                                         // LFS expects angle turned per second  which is 50 times greater 
                                                         // in this case.
                              
                            
 lfs.setTargetTurnRate(turnRateDegreesPerSec);
                                   
 lfs.setTargetSpeed((wL+wR)/2.0);   // the forward speed is just the average of the two wheel speeds.
                                    // note: if wL = 3 and wR = -3  then the average is 0 speed. This is correct. The
                                    // robot is turning in place.
 
 } 
