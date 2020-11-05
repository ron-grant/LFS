  /* Line Following Simulator User Application - Processing Environment
   
 
   Care should be made to not modify LFS_XXX.pde files (notebook tabs).
   The main tab should be named to LFS_yourRobotName 
   Subsequent library releases with updated LFS_ code files should require little/no 
   modification to your files.
   
  
   * Lap Timer, Improved Run - Faster 
   * supports interactive Markers 
   * user draw/upate/ID sensors
   * improved view port toggle (Tab select Sensor view / course and robot view)
   * Sensor view variable position now supported
   * Optional User supplied Icons in robot and course views.
  
   * Parameter Editor new (1.4) - for now code resides within user sketch.
   * Improved Help/Command Summary screens with optinal user panel drawing separated from LFS code
   * User key commands separated from LFS 
        Now arrow keys can be overridden.
   * LFS code now in tabs prefixed by LFS_ 
   * out of bounds detection added
   * RobotState save (when robot running) and restore when clicking on state marker  support added (lib 1.5)
        State markers have rotating square nested in them.
        
    - UserDraw UserReset UserCon left alone, minor change to UserInit including 
         Course list
         RobotState class including currentRobotState instance (accessed with cs alias typically)
     
   
   *  genRobotIcon able to create robot icon with user initials on the fly (lib 1.4.2)
   
   
     If you have added key commands or text drawing to your robot controller sketch, consider importing to 
     this new template. You can still use existing sketch built with 1.3 if you don't have need for 
     parameter editor.
    
      
   See Document  LFS-1.3-Changes.pdf
   See Document  LFS-1.5.pdf (not yet available as of Oct 24,2020)
   
   Some changes are highlighted as (lib 1.3) or (lib 1.4) in this program indicating 
   library version 1.3 or 1.4 and on is required.
      
        
   Ron Grant
   Sept 30,2020 
   Oct 20, 2020   - last major modification
   Oct 25, 2020   - lap counter for select courses, parameter dialog mouse making changes outside dialog fixed,
                    defineCourse list support (UserInit). 
                    faster frame rate (fixed sensor screen read problem - thanks Chris N for pointing out)
                    
   Oct 29, 2020   - robot state save/recover  lib 1.5 
   
   
   https://github.com/ron-grant/LFS
   
     
   Refer to LFS User's Guide for a description of tabs and ethods
   Short summary here:
   
   Program Tab  Methods called by LFS           Short Description 
   
   
   
   LFS_XXX        NA                            Sketch main program - high level processing sketch skeleton.
                                                Should not change. 
  
   LFS_M                                        Previously main tab, now contains functions called by
                                                main which is now skeleton that should not change
                                                or change very little in the future.
  
   LFS_Key                                      LFS command key decode, undecoded keys passed to 
                                                userKeypress method in UserKey.
                                                
   LFS_Panel                                    LFS display Command Summary and Help Panels also
                                                calls  userDrawPanel1 and userDrawPanel2 when they 
                                                are visible (optional user panels)
              
   LFS_Par                                      LFS parameter editor interactive edit of user variables  
                                                provided in list defined in UserParEdit tab
                                               
   UserInit    userInit()                       define name, course, sensors, acceleration...                                              
   UserReset   userControllerResetAndRun()      method called by simulator to start robot running    
   UserCon     userControllerUpdate()           your controller called by simulator at each time step
    
   Tabs with optional code - methods expected to be defined, but can be "empty" 
    
   UserDraw    userDraw()                      add features to overlay on robot view (or sensor view)
   
   UPanel   userDrawPanel1() userDrawPanel2    display status on screen in specified regions  
   
   UPar     parEditorUpdate()                  supply list to parameter editor     
       
   UKey     userkeyPress()                     command key decoder, custom keys decoded that 
                                               are not decoded (used) by LFS
                                               
   UMisc   userMiscSetup()                     called from setup at program startup
           userMiscUpdate()                    called every draw
           userLapDetected()                   called when lap detected (crossing close to start location)
           userStartedRun()                    called when user presses G)o or R)un 
           userInBounds()                      called if robot in course bounds, either this or userOutOfBounds called every draw
           userOutOfBounds ()                  called if robot outside course bounds
           
           userFinishLineDetected()            called (by your controller) when your controller believes it
                                               has have crossed the finish line       
   
   Note shorter names for user notebook tabs (file) that have been created or changed significantly
   with library release 1.4.  The library code remains unchanged from 1.3 except a few cases exposing 
   icon variables and outOfBounds query for robot.
   
   
  
   New (lib 1.5)
   
   New method sensorUpdateNotNeeded() can be optionally called by controller if it does not need updated sensors 
   on on the next time step. The effect is to speed up the execution of the simulator which may opt to skip updating 
   the screen. The simulated robot will still advance one time step and the stopwatch will be incremented so there 
   will be no impact on the result.
   
   In other words, but notifying the simulator that your controller does not need a sensor update, it provides an opportunity 
   to speed things up. You can always throttle your robot if it runs too fast (0..9 keys), but it can be handy to iterate
   a test cycle if robot runs at a faster rate.
   
   Making the request does not guarantee LFS will abide by the request, so sensors may in fact get updated.
   
*/  

                               

LFS lfs;  // line following simulator - single instance created in setup()

// some global variables

int simSpeed = 9;                     // simulation speed 0=single step 1 slow to 9 normal  -- controlled by Keypress           
boolean simFreeze = false;            // toggled by space bar (when simSpeed>0) else single step -- controlled by Keypress
boolean simRequestStep = false;       // program has decided it needs to take a simulation step
boolean courseTop = true;             // couse view top, now when false course view (and small robot view) are hidden                     
float fr;                             // throttled frame rate update/change to make display more reabable
boolean sensorUpdateNeeded;  // See header, method for speeding up simulator execution  
 
boolean showTopTextBar = true;       // set false to see impact on fps
  
  
void sensorUpdateNotNeeded()    // called by controller if next update, it does not need sensors to be updated
{ sensorUpdateNeeded=false;     // the end result is that LFS execution will be faster, see header above.
}   
    
public void setupLFS()
{
     
  lfs = new LFS(this);   // single instance of LFS  ref to this applet, robotView width,height e.g. typical 800,600
  
  parEditor = new ParEditor();  // single instance of parameter editor
  
  lfs.defineRobotViewport(40,70,400,400);           // small robot viewport  upper-left x,y,width,height
  lfs.defineCourseViewport(480,70,1280,640);        // course viewport (allowable region for course image)
  lfs.defineSensorViewport(40,80,800,800);          // raw sensor view. should be 800x800  (lib 1.3)
                                                
   
  userInit();    // called here - and also on robot start (contest start)
  simSpeed =9;   // step speed, default full speed 9, set by 0..9 keys 
  
  // lfs.setShowSensorsOnSensorView(true);  // slight frame rate gain if false (removed 1.4.1)
                                            // 1 pixel overlap caused problems, feature removed
                                            
  loadRobotStates();  // RobotState captured on previous run marker click while robot running (in G)o mode) (lib 1.5)
  userMiscSetup();    // UMisc setup - for optional audio init... 
}


  void lfsDraw ()  // method called from draw() that is called by Processing as fast as possible, unless throttled by
                   // setup call to frameRate(), see sketch main tab
  {
    background(0,0,20);  // erases window every draw
   
   // Robot view and Course view overwrite viewport areas - but not every frame unless view rate dividers set to 1 (see below)
   // Other screen areas should be overwritten with solid rect before writing text.
   
   int alpha = 0;                      // default alpha=0 fully transparent cover (cover disabled)
   if (courseTop) alpha = 220;         // when course and smaller robot view displayed, dim out larger sensor view 
                                       // 255 is an option to fully obscure from view.
                                      
  
   if (courseTop)
   lfs.updateSensors(0,0,0,alpha);     // draws 64 DPI bitmap of current robot location on screen (can be covered)
                                       // sensor updates, making sensor data available for user controller
                                       // r,g,b cover with alpha written over sensor view after it has been sampled
                                       // if alpha=0 cover rectangle not drawn.
    
   lfs.setCrumbsVisible(helpPage==0);  // show crumbs if help not visible - hack to fix bleed through 
                                       // Drawing order or Z-depth.. ??  
   
   if (courseTop)  // selective enable/disable controlled by Tab key 
     lfs.drawRobotAndCourseViews(1,1,rotate90);  // draw robot and course, using frame divider
   
   // Frame divider (1,1,.. ) used for display every frame. Normal case.
   // To attempt to improve performance read on:
   // robot view rate divider, course view rate divider
   // 0=disable 1=every frame 2=every other frame, 3= every 3..
   // when mouse pressed and not disabled, LFS will temporarily insure every frame
   // Using GPU may eliminate this feature... 
    
   if (!courseTop) lfs.updateSensors(0,0,0,alpha); // complimentary to call above
    
   if (quietDisplay==0)  
   userDraw();          // draw optional user graphics/annotation overlay on robot view or sensor view 
    
   resetMatrix();       // reset transforms back to screen coordinates 
   camera();
    
   if (showTopTextBar)
   {
     rectMode (CORNER);            // top of screen text boxes - backgrounds 
     strokeWeight (1.0);           // added explicit  strokeWeight,strokeColor  for lib 1.31
     stroke (240);      
     fill (0);
     rect (40,10,400,48);          // top left of screen   time box
     rect (480,10,width-500,48);   // top right of screen  contestant name, robot, location velocity 
     
     fill(240);                             // draw contestant name robot name in top right box
     textSize(28);
     text(lfs.getContestTimeString(),51,46);
     text(lfs.nameFirst+lfs.nameLast+"  "+lfs.nameRobot,500,46);
   }
   
   // --- Contest State, Controller ON/OFF State  FPS  Step Speed (or FREEZE) display upper right box right side ----- 
   
   fill(200,200,250); // light blue 
   textSize (18);
   if (frameCount%60 == 0) fr = frameRate;
   if (quietDisplay == 0)
     text(String.format("%2.0f fps",fr),width-100,30);    // (lib 1.4.1) moved to right side of screen
   else 
     text(String.format("Q)uietDisplay %d   %2.0f fps",quietDisplay,fr),width-300,30);
     
   if (showTopTextBar)
   {
     if (simFreeze) text ("FREEZE",width-220,30);
     else           text(String.format("step speed %d",simSpeed),width-240,30);
   
     textSize (22);
     text(lfs.getContestStateName(),width-338,34); 
     textSize(18);
     text ("contest state",width-352,53);
     if (lfs.controllerIsEnabled()) text ("controller ON",width-160,53);
     else                           text ("controller off",width-160,53);
   
     // ---- end of Contest State info (light blue) 
   
     fill (240);
     textSize (22);                       // (lib 1.4.1) shrunk text just a bit 
     lfs.drawRobotLocHeadingVel(974,44);  // draw x,y location and heading using lfs provided bitmap  
                                          // during contest run, these values are not available,
                                          // That is, getRobotX() getRobotY() return zeros.
                                          // If non-contest run with Go command, values are available
   } 
   // Simulation Throttling -- this changes how fast simulation runs, but does not affect simulation 
   // logged time. That is slowing down a simulation slows down simulator stopwatch clock
         
   if (!simFreeze)                             // if simulation not frozen with speed=0 (key='0' freezes)
   {                                           // SPACE bar toggles freeze in G)o mode 
     if (simSpeed == 0)
     { }
     else
     if (simSpeed == 1)
     { if ((frameCount % 60) == 0)             // 1 is really slow   e.g. about frame per second typical
       simRequestStep = true;                  // Oct 25, 2020 consider using millis() clock for 1 step / second !!!
     }  
     else 
     if (simSpeed==9) simRequestStep = true;
     else
     if ((frameCount % (60-simSpeed*60/9) == 0))   // allow keys 1..9 to control speed  
       simRequestStep = true;                      // simSpeed of 9 requests frame every time
   }
     
   // --- end simulation throttling  
     

   int skipSensorUpdateCount = 0;  
   do {  // new (lib 1.5)   
   
     sensorUpdateNeeded = true; // new variable - if controller sets false 
                                // simulation can take multiple steps without time consuming
                                // sensor image redraw -- no impact on simulation -- just speeds 
                                // execution time (same number of stopwatch ticks... 
   
     if (lfs.controllerIsEnabled())    // if turned off, no update.
       userControllerUpdate();         // user reads sensors changes target speed and turn rate as needed.
     
     if (lfs.robotOutOfBounds())       // Moved up to just after userController update Oct 22, 2020
     {
       push();                         // push Matrix and Style  
       userOutOfBounds();
       pop();
     }
     else userInBounds();    
      
      
      
     lfs.driveUpdate(simRequestStep);  // if step requested update robot speed and turn rate with acceleration rates 
                                       // then position and heading with current speed and turn rates.
                                       // Note: if controller is not enabled this call will insure robot  
                                       // position is updated allowing manual drive.
                                       
     if (lfs.lapTimer.lapTimerUpdate(simRequestStep))  // update lap timer including stopwatch if not lap mode.                                  
       userLapDetected();                              // returns true if lap detected, calling user method in UMisc tab.                                     
                                             
        
     } while (!sensorUpdateNeeded &&(skipSensorUpdateCount<3));  // limit number of times controller can
                                                                 // reqest no update 
                                             
   
   
   simRequestStep = false;           // reset simulation step request, if set during this "draw"
   
   informMarkersAboutSavedRobotState();  // LFS_RS - notify markers if robot saved states is present, appearance 
                                         // will change upon markerDraw()  (lib 1.5)
    
   if (quietDisplay<4)
     lfs.showSensors((courseTop)?'R':'S');             // show user colorable sensors (lib 1.3)
   
   if (courseTop && (helpPage==0)) lfs.markerDraw();   // only display markers when course visible (lib 1.3)
                                                       // and not displaying help       
   
   
   
     
   parEditorUpdate();                // support for LFS_Par (Parameter Editor Dialog) - new in lib 1.4)
     
       
   lfsDrawPanel();                   // formerly userDrawPanel now lfsDrawPanel handles command summary & help panels. 
                                     // Also user panel methods userDrawPanel1 and userDrawPanel2 are called 
                                     // conditionally depending on screen configuration, e.g. help panel obscures 
                                     // user panel 2. Parameter dialog obscures panel 1.
                                   
      
   lfs.contestScreenSaveIfRequested();   // generates screen save upon contest "Finish" after delay of few frames  
   
   
   userMiscUpdate(); // uMisc method called every time Processing calls draw method 
 
   
  } // end of draw()
  
   
  
import java.lang.reflect.*;  // java reflection used to lookup sensor variable names 

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


// Generate A Robot Icons - eliminating need to use bitmap editor / or drawing program to create an icon.
// If you want to customize this code, suggest renaming and moving a copy of this method into your UserDraw
// and calling it from your userInit. This code tab is subject to change in later library 
// releases. See: UserInit tab.
// This code is called at userInit time.  

PImage genRobotIcon (String initials,int size, color c,color textColor)  // create robot icon on the fly (1.4.2)
{
  float d = size;
  PGraphics mg = createGraphics(size,size);  // create dedicated drawing context for production of icon
  mg.beginDraw();
  mg.background(0,0);
  mg.fill(c);              // color of robot can include alpha 
  mg.translate(d/2,d/2);   // put origin at center of icon flip y-axis
  mg.pushMatrix();         // save for text drawing which is fussy due to textHeight being integer
  mg.scale(d/2,-d/2);      // coordinates now normalized scale +1 to -1 in x and y within sizexsize pixel bitmap
  mg.strokeWeight(0.01);
  mg.circle(0,0,1.8);      // robot main disc
  mg.fill(0,0,0,255);      // black opaque
  mg.rectMode(CENTER);
  mg.rect(-0.8,0,0.1,0.5);    // wheels 
  mg.rect( 0.8,0,0.1,0.5);
  mg.circle (0,-0.80,0.25);   // caster 
  mg.triangle(0,1.0,0.20,0.60,-0.20,0.60); // triangle pointer front of robot  
  mg.popMatrix();
  mg.textAlign(CENTER);
  mg.fill(textColor);
  if (initials.length() == 2) mg.textSize(44*size/100);
  else mg.textSize(38*size/100);
  mg.text(initials,0,20*size/100);  // initials
  mg.endDraw();
  // mg.save("myIcon.png");  // could save to bitmap, but  opting for direct use of PImage 
  
  return mg;                 // return PImage reference 
}




 
