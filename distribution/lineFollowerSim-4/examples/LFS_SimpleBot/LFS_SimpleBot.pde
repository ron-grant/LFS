/* Line Following Simulator User Application - Processing Environment
  
   LFS_SimpleBot3   Required LineFollowerSim Library 1.3.0 or later
   * supports interactive Markers 
   * user draw/upate/ID sensors
   * improved view port toggle (Tab select Sensor view / course and robot view)
   * Sensor view variable position now supported
   
   See Document  LFS-1.3-Changes.pdf
   Some changes are highlighted as (lib 1.3) in this program indicating 
   library version 1.3 and on is required.
      
   
     
   Ron Grant
   Sept 30,2020 
   https://github.com/ron-grant/LFS
   
     
   Refer to LFS User's Guide for a description of tabs and methods
   Short summary here:
   
   Program Tab  Methods called by LFS           Short Description 
   
   LFS_XXX        NA                            Sketch main program - high level code usually not  
                                                user modified - may be library version dependent! 
                                                
   UserCon     userControllerUpdate()           your controller called by simulator at each time step
   UserDraw    userDraw()                       add features to overlay on robot view
   UserPanel   userDrawPanel()                  display status on screen
   UserInit    userInit()                       define name, course, sensors, acceleration...
   UserKey     keyPressed()                     command key decoder 
   UserReset   userControllerResetAndRun()      method called by simulator to start robot running                                         
   
*/  

import lineFollowerSim.*;  // Simulator API - accepts turn rate and speed commands 
                           // tracks virtual robot position and heading
                           // renders robot and course views, reads sensor data

LFS lfs;  // line following simulator - single instance created in setup()

// some global variables

int simSpeed = 9;                     // simulation speed 0=single step 1 slow to 9 normal  -- controlled by Keypress           
boolean simFreeze = false;            // toggled by space bar (when simSpeed>0) else single step -- controlled by Keypress
boolean simRequestStep = false;       // program has decided it needs to take a simulation step
int panelDisplayMode = 2;

boolean showFPS = true;    // show frames per second being drawn - does not affect robot 
                           // stopwatch time, or simulation behavior, just real time
                           // ideally 60 fps will run robot actual speed with default time step
                           // equal to 1/60th sec, 30fps robot appears to run 1/2 speed - slow
                           // motion - as would be noted by slow stop watch.
   
boolean courseTop = true;  // couse view top, now when false course view (and small robot view) are hidden                     
                     
float fr;
    
void clearScreen() { background(0,0,20); } // called initially and  when changing course orientation     
    
public void setup()
{
  size (1800,900,P3D);       // window width,height in pixels
  frameRate(1000);           // request high frame rate to run simulator potentially faster 
                             // than realtime   
  
  lfs = new LFS(this);   // single instance of LFS  ref to this applet, robotView width,height e.g. typical 800,600
  
  lfs.defineRobotViewport(40,70,400,400);
  lfs.defineCourseViewport(480,70,1280,640);
  lfs.defineSensorViewport(40,80,800,800);          // define and position raw sensor view (lib 1.3)
                                                    // was fixed at 0,0 upper-left getting in the way
                                                    // of header text.
 
    
  userInit(); // called here - and also on robot start (contest start)
  
  simSpeed =9;
  
  clearScreen();
  
  lfs.setShowSensorsOnSensorView(true);  // slight frame rate gain if false 
}



  public void draw ()  // method called by Processing at 30 to 60 times per second (1 frame time)
  {
   // Screen now erased upon entry to draw, e.g. with background() method call.
   background(0,0,20);  // erases window 
   
   // Robot view and Course view overwrite viewport areas - but not every frame unless view rate dividers set to 1 (see below)
   // Other screen areas should be overwritten with solid rect before writing text.
   
   int alpha = 90;
   if (courseTop) alpha = 219;
   
   if (courseTop)
   lfs.updateSensors(0,0,0,alpha);     // draws 64 DPI bitmap of current robot location on screen (can be covered)
                                       // sensor updates, making sensor data available for user controller
    
   
   if (courseTop)  // selective enable/disable controlled by Tab key 
     lfs.drawRobotAndCourseViews(1,1,rotate90);  // draw robot and course, using frame divider
   
   // Frame divider (1,1,.. ) used for display every frame. Normal case.
   // To attempt to improve performance read on:
   // robot view rate divider, course view rate divider
   // 0=disable 1=every frame 2=every other frame, 3= every 3..
   // when mouse pressed and not disabled, LFS will temporarily insure every frame
   // Using GPU may eliminate this feature... 
    
   if (!courseTop) lfs.updateSensors(0,0,0,alpha); // complimentary to call above
     
   userDraw();
    
   resetMatrix();
   camera();
    
       
   rectMode (CORNER);   // text boxes - backgrounds 
   strokeWeight (1.0);  // added explicit  strokeWeight,strokeColor  for lib 1.31
   stroke (240);      
   fill (0);
   rect (40,10,400,48);
   rect (480,10,1200,48);
       
   if (showFPS)   // draw() frames per sec (fps)  - performance monitor 
   { textSize (18);
     fill(150);
     if (frameCount%60 == 0) fr = frameRate;
     text(String.format("%2.0f fps",fr),340,55);
   }
    
   fill(240);
   textSize(28);
   text(lfs.getContestTimeString(),51,46);
    
   text(lfs.getContestStateName(),width-248,47);
      
   text(lfs.nameFirst+lfs.nameLast+"  "+lfs.nameRobot,500,46);  
    
    
   lfs.drawRobotLocHeadingVel(974,47);        // draw x,y location and heading bitmap (values not available during contest run) 
                                              // That is, getRobotX() getRobotY()..  are not available during contest run time. 
    
    
   if (!simFreeze)                             // if simulation not frozen with speed=0, key='0' freezes
   {
     if (simSpeed == 0)
     { }
     else
     if (simSpeed == 1)
     { if ((frameCount % 60) == 0)             // 1 is really slow   e.g. about frame per second typical
       simRequestStep = true;
     }  
     else 
     if (simSpeed==9) simRequestStep = true;
     else
     if ((frameCount % (60-simSpeed*60/9) == 0))   // allow keys 1..9 to control speed  
       simRequestStep = true;                      // simSpeed of 9 requests frame every time
   }
     
   if (lfs.controllerIsEnabled())    // if turned off, no update.
     userControllerUpdate();         // user reads sensors changes target speed and turn rate as needed.
    
   lfs.driveUpdate(simRequestStep);  // if step requested update robot position with current speed and turn rate
                                     // also stopwatch tick is counted. Note: if controller is not enabled 
                                     // this call will insure robot position is updated allowing manual drive.   
                                             
   simRequestStep = false;           // ramping speed and/or turn rate toward targetSpeed and targetTurnRate
                                     // using defined acceleration/deceleration rates.
       
   userDrawPanel();
    
   lfs.contestScreenSaveIfRequested();   // generates screen save upon contest "Finish"   
   
  } // end of draw()
  
   
  
import java.lang.reflect.*;  // java reflection used to lookup sensor names 

public void nameSensorsUsingVariableNames()  // (lib 1.3)
  {
  PApplet p = this; // p is current instance of PApplet
  
  println ("SpotSensors");
  for(Field f : p.getClass().getDeclaredFields())   
  {
     if(f.getType() == SpotSensor.class)
     {
       String name = f.getName(); 
       try {
    
       SpotSensor ss = (SpotSensor) (f.get(p));  // access class instance
       if (ss.getName() == null) ss.setName(name);
       println (name, ss.getXoff(), ss.getYoff()); 
       } catch (IllegalAccessException e)
       {}
     }
   
  } 

  println ("LineSensors");
  for(Field f : p.getClass().getDeclaredFields())
  {
     if(f.getType() == LineSensor.class)
     {
       String name = f.getName();
           
       try {
         LineSensor ls = (LineSensor) (f.get(p));  // access class instance
        
         if (ls.getName() == null) 
          ls.setName(name);             // set sensor default name using variable name 
         println (name, ls.getXoff(), ls.getYoff()); 
       }
       catch (IllegalAccessException e)
       {
       }
  
     } 
  }

} // end method   

  

 
