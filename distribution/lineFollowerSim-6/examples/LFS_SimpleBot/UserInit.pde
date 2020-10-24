/* UserInit - load course, define acceleration rates.. , define sensors

   Additions at end of userInit for (lib 1.3). Init markers, get sensor names
   
*/

SpotSensor sensorL,sensorM,sensorR;
LineSensor sensor1;  

PImage bigIcon;     // this variable should be defined for use by userDraw method     


void userInit()  // called by lfs to obtain robot information and for sensor definitions
{
  lfs.setFirstNameLastNameRobotName("Ron","Grant","SimpleBot4");   // change to your name and robot
  
  // Define courses (64 DPI .png or .jpg) you might want to use with unique sequence number 1,2,3...  (lib 1.4.1) 
  // Then choose the course you want to use.  Ctrl-C can be used to sequence to next course.
  // Initial x,y,heading can be specified OR you can always use markers that are remembered with each unique file
  // These course files must appear in sketch data sub-folder.
  // For backward compatibility. If your program uses old lfs.setCourse("filename"), treated as single course that is
  // chosen automatically. 
   
  lfs.defineLapCourse(1,"Novice_LF_course-Fall_2018_64DPI.jpg");      // LapCourses use lap timer  
  lfs.defineLapCourse(2,"Advanced_LF_course_Fall-2018_64DPI.jpg");
  lfs.defineCourse   (3,"DPRG_Challenge_2011_64DPI.jpg",71.7,120,0);  // not lap timer course, optional x,y,heading is used here 
  lfs.defineLapCourse(4,"Test2x3.png");
  lfs.defineLapCourse(5,"RG_5x7_Advanced_64DPI_R1.png");
    
  lfs.chooseCourseOneTime(4);          // here you choose a course to use. Because userInit may be called again
                                       // the setting is only used one time. This allows the Ctrl-C Course 
                                       // select command to work, where this method is called when robot 
                                       // runs a contest.
  
  //lfs.setCourse("somecourse.jpg");   // commented out - the old way to select course including need to manually load markers            
  //lfs.markerSetup();                 // load course markers, replaced by above code 
  
   
  lfs.lapTimer.lapCountMax = 3;
    
  lfs.showDistanceTraveled = true;     // informational item (lib 1.4.1) 
  lfs.reportDistanceTraveled =false;   // distance can be added to contest.cdf report (lib 1.4.1), suggest erase old 
                                       // contest pdf, if changing state, for correct header to be written.
 
 
 
  /* Optional support for Robot Icons by popular request of people including DPRG President, Carl Ott  (lib 1.3.1)
     Load icon file(s) from data folder.
  
     Simplebot example provided here. Create your own custom icon with a program such as inkscape.
     PNG preferred format, supports background transparency making for nice overlay of robot, vs image borders 
     being visible.
   
     Small icon recommended for course designed around 100x100 pixels 
     Larger icon recommended for robot view/sensor view  400x400 pixels to 800x800 pixels
     
   
     
  */    
  
      
  lfs.setRobotIcon("SimpleBotIcon.png",255);    // override course pointer, display this icon file, located in data folder
                                                // with alpha transparency 0..255  0=transparent to 255 opaque
                                                // (lib 1.3.1) 
                                           
  lfs.setRobotIconScale(0.5);                   // scale up or down as needed, default scale is 1.0
                                                // (lib 1.3.1)  
 
 
  lfs.showDistanceTraveled = true;              // (lib 1.4.1) default false compatible with previous lfs versions 
  lfs.reportDistanceTraveled= false;            // (lib 1.4.1) default false compatible with previous lfs versions
                                                // setting true, would require erasing contest.cdf file to allow generation of
                                                // correct header which includes "Dist"
                                                // * If these statments are omitted in your application the library defaults 
                                                // to false, keeping lib 1.4.1 compatible with (lib 1.3.1).
                                                
 
  bigIcon = loadImage("SimpleBotBigIcon.png");  // image from data folder  to display in UserDraw tab userDraw method 
                                                // for now using small image 
 
 
  // ------------- end of optional icon support
   
  
       
  lfs.setTimeStep(0.0166);   // 0.01 sec to 0.1 sec    0.166 default ~1/60
  
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
         
  sensorL = lfs.createSpotSensor(1,-2,12,12);         // example spot sensors 
  sensorM = lfs.createSpotSensor(1.5f,0,10,10);
  sensorR = lfs.createSpotSensor(1, 2,12,12);
  sensor1 = lfs.createLineSensor(2.0f, 0, 5,5, 65); // x,y offset from robot center, spot size (5,5) ,
                                                     // number of samples (if even, gets incremented to odd value 
                                                     // to place a spot directly at sensor x,y
                                                     // and make sensor symmetrical about x,y
 
  sensor1.setArcRadius(2);    // optional 1/2 circle with center at xoff,yoff, radius in inches
                              // negative radius reverses circle OR setRotation to 180 
  
  sensor1.setRotation (0);   // optional sensor modifier  0 = aligned with robot Left/Right (Y-axis)
                             // 90 = aligned with robot Front/Back (X-axis)
                              
  //sensor1.setPosition(2.5,0);  // example position modification 
                                 // position,rotation and arcRadius (1/2 circle) can be modified 
                                 // in userController at robot run time. That is, every time step
                                 // provides an opportunity to modify these values for the next time step.

  lfs.setShowSensorsOnSensorView(false);

  nameSensorsUsingVariableNames();   // look up sensor names and assign them to sensor name field (lib 1.3)
 
}
