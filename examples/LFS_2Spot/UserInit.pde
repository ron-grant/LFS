// UserInit - The userInit method. Load course, define acceleration rates.. , define sensors
//   This demo was made from LFS_Simplebot, with a number of comments removed from User tabs to reduce clutter
 
SpotSensor sensorL,sensorR;     // declarations for sensors being used, no LineSensor instances in this demo

void userInit()  // called at startup and typically by userControllerResetAndRun 
{
  lfs.setFirstNameLastNameRobotName("Ron","Grant","2Spot");           // change to your name and robot
 
  lfs.defineLapCourse(1,"Novice_LF_course-Fall_2018_64DPI.jpg");      // LapCourses use lap timer    courses should be all 64 DPI
  lfs.defineLapCourse(2,"Advanced_LF_course_Fall-2018_64DPI.jpg");
  lfs.defineCourse   (3,"DPRG_Challenge_2011_64DPI.jpg",71.7,120,0);  // not lap timer course, optional x,y,heading is used here 
  lfs.defineLapCourse(4,"Test2x3.png",24,12,20);
  lfs.defineLapCourse(5,"RG_5x7_Advanced_64DPI_R1.png");
    
  lfs.chooseCourseOneTime(1);          // Here you choose an initial course to use.  Ctrl-C sequences through courses 
  lfs.lapTimer.lapCountMax = 3;        // Maximum number of laps before stop for lap courses defined with defineLapCourse method.

  lfs.reportDistanceTraveled= true;    // Include Dist, field in contest.cdf
  lfs.setTimeStep(0.0166);             // 0.01 sec to 0.1 sec    actual default 0.1667 default ~1/60
   
  lfs.setAccRate(64);      // acceleration rate (inches/sec^2)   64 sim max
  lfs.setDecelRate(64);    // deceleration rate (inches/sec^2)   64 sim max 
  lfs.setTurnAcc(720);     // turn acceleration and deceleration rate  (degrees/sec^2) 
  
  // below setMaxSpeed and setMaxTurnRate are for informational purposes only
  // lfs will warn you and limit values which you can access by getMaxSpeed() and getMaxTurnRate()
  // It is up to you to limit your controller to these values, simulation will limit only to its maximums.
   
  // Note if you drive the robot straight at simulator maximum a turn will not be allowed as simulator 
  // turning model turning model applies increased velocity to one wheel and a decrease of the same velocity
  // to the other wheel to affect a turn about the center of the robot. 
    
  lfs.setMaxSpeed(16);      // inform lfs of your max speed *
  lfs.setMaxTurnRate(720);  // inform lfs of your max turn rate (degrees/sec)
   
  // Sensor x,y offsets are in robot coordinates and inch scale
  // robot origin is "between wheels" +X axis extends forward and +Y axis extends to "right of robot"
         
  sensorL = lfs.createSpotSensor(1,-2,32,32);    // define Left Sensor xoff,yoff (inches),  spotWidth,spotHeight (pixels)  
  sensorR = lfs.createSpotSensor(1, 2,32,32);    // define Right Sensor
  
  nameSensorsUsingVariableNames();   // name sensors using variable name, for mouse hover over robot view identification
  lfs.setCrumbThresholdDist(0.5);    // Distance between cookie crumbs (inches). 0.5 default, larger dist may help performance    
     
  // robot icon                    
                      
  bigIcon = genRobotIcon ("SP2",400,color(0,255,255),color(0,0,0));  // your initials,size (pixels) robot color,text color
  lfs.setRobotIconImage(bigIcon,255);                               //  image, alpha range 0..255   0=transparent 255=opaque
  lfs.setRobotIconScale(55.0/400);                                  //  auto scale down to about 55 units
  
  // alternate code for loading custom icon file, 
  // lfs.setRobotIcon("SimpleBotIcon.png",255);  // override course pointer, display this icon file, located in data folder
                                                 // filename,alpha   alpha range 0..255   0=transparent 255=opaque
  // lfs.setRobotIconScale(0.5);                   // scale up or down as needed, e.g. 1.0 same size, 2.0 double size, 0.5 half...
  // bigIcon = loadImage("SimpleBotBigIcon.png");  // icon to display in UserDraw
     
}                              
