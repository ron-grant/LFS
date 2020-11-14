/* UserInit - The userInit method. Load course, define acceleration rates.. , define sensors
   
   Contains userInit method, called at program start up and from UserReset tab method
   userControllerResetAndRun when R)un contest or G)o commands are issued.
   
   Define the following
   
   * contestant name, roobot name
   * single course file or list of course files you want to use
   * time step if you want to override simulator default of 0.01667
   * acceleration rate
   * Spot and Line Sensors with optional 1/2 circle and rotation for line sensors.
   * define optional icon file to be used for your robot OR use auto generated icon with your initials 
  
   If you are new to Processing:
   
   One very helpful Processing feature. Right click on any variable or method then select
   ShowUsage (a usage box pops up, and you can click on items) or Jump To Declaration to locate variables 
   or methods defined in the processing app. Unfortunately if the variable name or method name is mentioned in
   a comment,it is not recognized by the right click.
   
        
   Processing methods and datatypes, when right clicked, have a Find in Reference which is also helpful. This
   feature is grayed out for non-processing items.
  
   this header reworded (lib 1.4.3)      
        
*/

SpotSensor sensorL,sensorM,sensorR;     // declarations for sensors being used 
LineSensor sensor1;  


void userInit()  // called at startup and typically by UserReset tab's userControllerResetAndRun method
{
 
  lfs.setFirstNameLastNameRobotName("Ron","Grant","SimpleBot5");   // change to your name and robot
  
  // ---- NEW TO LIB 1.4.1 -----------------------------------------------------------------------------------------
  
  // Define courses (64 DPI .png or .jpg) you might want to use with unique sequence number 1,2,3...  (lib 1.4.1) 
  // Then choose the course you want to use.  Ctrl-C can be used to sequence to next course.
  // Initial x,y,heading can be specified OR you can always use markers that are remembered with each unique file
  // These course files must appear in sketch data sub-folder.
  // For backward compatibility. If your program uses old lfs.setCourse("filename"), treated as single course that is
  // chosen automatically. 
  
 
  lfs.defineLapCourse(1,"Novice_LF_course-Fall_2018_64DPI.jpg");      // LapCourses use lap timer  
  lfs.defineLapCourse(2,"Advanced_LF_course_Fall-2018_64DPI.jpg");
  lfs.defineCourse   (3,"DPRG_Challenge_2011_64DPI.jpg",71.7,120,0);  // not lap timer course, optional x,y,heading is used here 
  lfs.defineLapCourse(4,"Test2x3.png",24,12,20);
  lfs.defineLapCourse(5,"RG_5x7_Advanced_64DPI_R1.png");
    
  lfs.chooseCourseOneTime(5);          // Here you choose an initial course to use. 
                                       // If Ctrl-C command is issued it advances the selection to the next course, 
                                       // wrapping around to the start of list when advancing past the end. To preserve 
                                       // the Ctrl-C selection, this setting is ignored on subsequent userInit calls
                                       // typically when Go or Run commands issued.
  
 
  // below 3 lines are old method commented out of loading a course,setting position, and loading markers replaced
  // by above code.
  
  //lfs.setCourse("DPRG_Challenge_2011_64DPI.jpg");   // old  select course including need to manually load markers
  //lfs.setPositionAndHeading(71.7,120,0);            // old  initial setting      
  //lfs.markerSetup();                                // old  load course markers, replaced by above code 
                                                      
     
  lfs.lapTimer.lapCountMax = 3;        // Maximum number of laps before stop for lap courses defined with defineLapCourse method.
    
  lfs.reportDistanceTraveled= true;    // Include Dist, field in contest.cdf, erase old contest.cdf, and new
                                       // file will correctly include Dist header.
                                     
 
  // End of New to LIB 1.4.1 -----------------------------------------------------------------------------------------------------------
  
       
  lfs.setTimeStep(0.0166);   // 0.01 sec to 0.1 sec    actual default 0.1667 default ~1/60
                             // the value here has been left at 0.0166 so as not to tamper with simulator 
                             // behavior of earlier editions of this demo program.
                             // That is, if this statement is removed, LFS will and has used 0.01667 sec per step
  
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
  sensorM = lfs.createSpotSensor(1.5f,0,15,15);
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

  // setShowSensorsOnSensorView - removed (lib 1.4.2) - LFS draws sensor data over sensor or robot views after all 
  
  
  nameSensorsUsingVariableNames();   // look up sensor names and assign them to sensor name field (lib 1.3)
   
   
  /* Optional support for Robot Icons by popular request of people including DPRG President, Carl Ott. (lib 1.3.1)
     Load icon file(s) from data folder OR generate icon on the fly (lib 1.4.2)
  
     For loaded icon (genIcon=false)
     Simplebot example provided here. Create your own custom icon with a program such as inkscape.
     PNG preferred format, supports background transparency making for nice overlay of robot, vs image borders 
     being visible.
   
     Also, new option, using genRobotIcon method,  add your initials, select colors and LFS generates
     a bitmap for use by LFS (robot/sensor view and course view) 
   
     Previously recommended 100x100 for course icon, 400x400 pixels for robot view/sensor view.
     Now, recommend 400x400 and scale down as needed for course view.
       
  */    
  
  boolean genIcon = true; // if true generate Icon on the fly to skip using a drawing program  new (lib 1.4.2)
                           //  false load Icon(s) from file(s)
    
  if (genIcon)
  {
    String genInitials = "SB";               // replace with your initials (2 or 3 char) and colors below... 
    color genColor = color (250,230,0);      // robot color  Aztec Yellow
    color genTextColor = color (0,0,100);    // text color   Dark Blue   
    
    // create generic robot icon 
    // In the example presented here, a single file is generated 400x400 which is auto scaled for robot view
    // then scaled for course view via setRobotIconScale.
   
    int d = 400; // icon width,height  400 chosen so icon looks good in large views
                 // smaller values like 100 could be tried, but don't think will affect performance
                 
    bigIcon = genRobotIcon (genInitials,d,genColor,genTextColor);  // size,initials,robot color,text color
    lfs.setRobotIconImage(bigIcon,255);      //  image, alpha range 0..255   0=transparent 255=opaque
    lfs.setRobotIconScale(55.0/d);         //  auto scale down to about 55 units seems to be what looks reasonable
  }
  else
  {
    lfs.setRobotIcon("SimpleBotIcon.png",255);    // override course pointer, display this icon file, located in data folder
                                                  // filename,alpha   alpha range 0..255   0=transparent 255=opaque
    lfs.setRobotIconScale(0.5);                   // scale up or down as needed, e.g. 1.0 same size, 2.0 double size, 0.5 half...
    bigIcon = loadImage("SimpleBotBigIcon.png");
  }   
                                   

  // ------------- end of optional icon support
  
  
  lfs.setCrumbThresholdDist(0.5);  // Distance between cookie crumbs (inches). Increase from default 0.5 to reduce frame
                                   // rate reduction near end of long run.
  
                                   

}
