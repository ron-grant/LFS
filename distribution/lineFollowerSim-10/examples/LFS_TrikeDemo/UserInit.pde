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



SpotSensor spotL0, spotR0;                               
SpotSensor spotL1, spotC1, spotR1;      // spot sensors
SpotSensor spotL2, spotC2, spotR2;   // spot sensors
SpotSensor spotL3, spotR3;
SpotSensor spotL4, spotR4;
SpotSensor spotL5, spotR5;

SpotSensor spotFL, spotFR;
SpotSensor spotAI, spotFR2;
SpotSensor spotFL3, spotFR3;
LineSensor lineSensor1;            // line sensors     

boolean  maximizedWindow = false;  // full screen (designed for 1920x1080 display) (lib 1.4.2)  

void userInit()  // called by lfs to obtain robot information and for sensor definitions
{
 
  lfs.setFirstNameLastNameRobotName("Will","Kuhnle","Trike2");     
  
  // contestant info   // ---- NEW TO LIB 1.4.1 -----------------------------------------------------------------------------------------
  
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
    
  lfs.chooseCourseOneTime(3);          // Here you choose an initial course to use. 
                                       // If Ctrl-C command is issued it advances the selection to the next course, 
                                       // wrapping around to the start of list when advancing past the end. To preserve 
                                       // the Ctrl-C selection, this setting is ignored on subsequent userInit calls
                                       // typically when Go or Run commands issued.
     
  lfs.lapTimer.lapCountMax = 3;        // Maximum number of laps before stop for lap courses defined with defineLapCourse method.
    
  lfs.reportDistanceTraveled= true;    // (lib 1.4.1) false compatible with previous lfs versions
                                       // setting true, would require erasing contest.cdf file to allow generation of
                                       // correct header which includes "Dist"
                                       // * If this statment is omitted in your application the library defaults 
                                       //   to false. I would prefer to eliminate this assignment.. 
 
 
  // End of New to LIB 1.4.1 -----------------------------------------------------------------------------------------------------------
  
  
  lfs.setTimeStep(0.05);  //  changed from default 0.01667 - appears to work OK, triples execution speed of simulation
                          //  (but not "speed" of robot)
                          //  As of Sept 22,2020 Trike should make it to first chopped sine wave on DPRG Challenge Course
                          //  This line can be commented out to resume original default time step of 0.01667 
  
  // below acceleration and deceleration rates are subject to LFS maximums
  
  lfs.setAccRate(32);      // acceleration rate (inches/sec^2)  
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
 
  // Note For Sensor Instances Below
  // Sensor x,y offsets are in robot coordinates and inch scale
  // robot origin is "between wheels" +X axis extends forward and +Y axis extends to "right of robot"

  // note create method is required now, old constructor is not visible 
  
  spotL1 = lfs.createSpotSensor (1.125, -1.5, 15, 15);   // x,y offset from robot center   spot size    
  spotC1 = lfs.createSpotSensor (1.0, 0, 15, 15);
  spotR1 = lfs.createSpotSensor (1.125, 1.5, 15, 15);    
  spotL2 = lfs.createSpotSensor(1.55, -1.5, 15, 15);   
  spotC2 = lfs.createSpotSensor(2.0, 0.0, 15, 15);
  spotR2 = lfs.createSpotSensor(1.55, 1.5, 15, 15);    
  spotL3 = lfs.createSpotSensor(2.125, -1.5, 15, 15);        
  spotR3 = lfs.createSpotSensor(2.125, 1.5, 15, 15);  
  spotL4 = lfs.createSpotSensor(2.7, -1.65, 15, 15);
  spotR4 = lfs.createSpotSensor(2.7, 1.65, 11, 11);
  spotL5 = lfs.createSpotSensor(3.125, -1.8, 15, 15);
  spotR5 = lfs.createSpotSensor(3.125, 1.8, 11, 11);
  spotL0 = lfs.createSpotSensor(3.4, -1.95, 15, 15); 
  spotR0 = lfs.createSpotSensor(3.4, 1.95, 15, 15); 

  spotFL = lfs.createSpotSensor(0.5, -2.75, 15, 15);        
  spotFR = lfs.createSpotSensor(0.5, 2.5, 15, 15);    

  spotFR2= lfs.createSpotSensor(1.5, 2.5, 15, 15);
  spotAI = lfs.createSpotSensor(1.8, 1.9, 15, 15);

  spotFL3= lfs.createSpotSensor(2.125, -2.75, 15, 15);
  spotFR3= lfs.createSpotSensor(2.125, 2.75, 11, 11);

  lineSensor1 = lfs.createLineSensor(0, 0, 5, 5, 64); // x,y offset from robot center, spot size (5,5) , number of samples
  
    
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
  
  boolean genIcon = false; // if true generate Icon on the fly to skip using a drawing program  new (lib 1.4.2)
                           //  false load Icon(s) from file(s)
    
  if (genIcon)
  {
    String genInitials = "WK";               // replace with your initials (2 or 3 char) and colors below... 
    color genColor = color (250,230,0);      // robot color  Aztec Yellow
    color genTextColor = color (0,0,100);    // text color   Dark Blue   
    
    // create generic robot icon 
    // In the example presented here, a single file is generated 400x400 which is auto scaled for robot view
    // then scaled for course view via setRobotIconScale.
   
    int d = 400; // icon width,height  400 chosen so icon looks good in large views
                 // smaller values like 100 could be tried, but don't think will affect performance
                 
    bigIcon = genRobotIcon (genInitials,d,genColor,genTextColor);  // size,initials,robot color,text color
    lfs.setRobotIconImage(bigIcon,255);      //  image, alpha range 0..255   0=transparent 255=opaque
    lfs.setRobotIconScale(55.0/d);           //  auto scale down to about 55 units seems to be what looks reasonable
  }
  else
  {
    lfs.setRobotIcon("TrikeIcon.png",255);    // override course pointer, display this icon file, located in data folder
                                              // filename,alpha   alpha range 0..255   0=transparent 255=opaque
    lfs.setRobotIconScale(0.5);               // scale up or down as needed, e.g. 1.0 same size, 2.0 double size, 0.5 half...
    //bigIcon = loadImage("");                // Big Icon not used, Trike has custom userDraw to show steered wheel.
  }   
                                   

  // ------------- end of optional icon support
                                   

}
