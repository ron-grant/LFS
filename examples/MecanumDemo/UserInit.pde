/* UserInit - load course, define acceleration rates.. , define sensors

*/

SpotSensor sensorL,sensorM,sensorR,sensorDimensionCheck;
LineSensor sensor1;  

int courseNum = 1;  // allow selection of see also UserReset tab

void userInit()  // called by lfs to obtain robot information and for sensor definitions
{
  lfs.setFirstNameLastNameRobotName("Carl","Ott ","MecanumDemo");   // change to your name and robot
 
  if (courseNum==1)
  {
    lfs.setCourse("RG_5x7_Advanced_64DPI_R1.png");       // example of what I think is advanced  - demo robot will run this
    lfs.setPositionAndHeading (48,6,0);       
  } 

  if (courseNum==2)
  {
    lfs.setCourse("DPRG_Challenge_2011_64DPI.jpg");   // challenge course     
    lfs.setPositionAndHeading (71.7,120,0);           // initial position over DPRG logo
  }
 
 // lfs.setTimeStep(0.0166);   // 0.01 sec to 0.1 sec    0.166 default ~1/60
  
 
  
  // below acceleration and deceleration rates are subject to LFS maximums
  
  lfs.setAccRate(16);      // acceleration rate (inches/sec^2)  
  lfs.setDecelRate(32);    // deceleration rate (inches/sec^2)  
  lfs.setTurnAcc(720);     // turn acceleration and deceleration rate  (degrees/sec^2) 
  
  // below setMaxSpeed and setMaxTurnRate are for informational purposes only
  // lfs will warn you and limit values which you can access by getMaxSpeed() and getMaxTurnRate()
  // It is up to you to limit your controller to these values, simulation will limit only to its maximums.
   
  // Note if you drive the robot straight at simulator maximum a turn will not be allowed as simulator 
  // turning model turning model applies increased velocity to one wheel and a decrease of the same velocity
  // to the other wheel to affect a turn about the center of the robot. 
    
  lfs.setMaxSpeed(16);      // inform lfs of your max speed *
  lfs.setMaxTurnRate(720);  // inform lfs of your max turn rate (degrees/sec)
 
  // Note For Sensor Instance Below
  // Sensor x,y offsets are in robot coordinates and inch scale
  // robot origin is "between wheels" +X axis extends forward and +Y axis extends to "right of robot"

   
  // Sept 16, need to change new SpotSensor to lfs.create..   to save having to include reference to sensors.. 
         
  sensorL = lfs.createSpotSensor(1,-1,64,64);         // example spot sensors 
  sensorM = lfs.createSpotSensor(1.5f,0,32,32);
  sensorR = lfs.createSpotSensor(1, 1,64,64);

  sensorDimensionCheck = lfs.createSpotSensor(1, 0,154,16); // up 1 inch, horizontal centered about 0, 154px/2.4in wide and 25px/0.25in tall)

  // 8 sensor array to model Polulu QTRX-MD-08A https://www.pololu.com/product/4448/pictures
  sensor1 = lfs.createLineSensor(2.0f, 0, 19, 19, 8); // x,y offset from robot center, spot size (5,5) ,
                                                     // number of samples (if even, gets incremented to odd value 
                                                     // to place a spot directly at sensor x,y
                                                     // and make sensor symmetrical about x,y
                                                     // ToDo- investiate potential boundary errors w/ non-square sensors

 
  sensor1.setArcRadius(0);    // optional 1/2 circle with center at xoff,yoff, radius in inches
                              // negative radius reverses circle OR setRotation to 180 
  
  sensor1.setRotation (0);   // optional sensor modifier  0 = aligned with robot Left/Right (Y-axis)
                             // 90 = aligned with robot Front/Back (X-axis)
                              
  //sensor1.setPosition(2.5,0);  // example position modification 
                                 // position,rotation and arcRadius (1/2 circle) can be modified 
                                 // in userController at robot run time. That is, every time step
                                 // provides an oppurtinity to modify these values for the next time step.

}
