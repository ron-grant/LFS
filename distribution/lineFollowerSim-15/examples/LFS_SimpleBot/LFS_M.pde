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
   *  bigMessage (lib 1.6)
   
   
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
  
   LFS_G                                        Some global variables/ sound control, GUI button definitions + GUI
                                                command decode.
  
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
int timeWarpMult = 50;

  
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
                                             
  loadRobotStates();    // RobotState captured on previous run marker click while robot running (in G)o mode) (lib 1.5)
  loadSoundFiles();     // LFS_G, preload all sounds
  userLoadSoundFiles(); // UMisc optional sound files 
  userMiscSetup();      // UMisc setup - for optional audio init...
  
  uiSetup();            // LFS_G Buttons/Checkboxes using  Lightweight UI -- included in lineFollowerSim library code 
  
}


void lfsDraw ()  // method called from draw() that is called by Processing as fast as possible, unless throttled by
                 // setup call to frameRate(), see sketch main tab
{
    background(0,0,20);                // erases window every draw
    
   lfs.setCrumbsVisible(helpPage==0);  // show crumbs if help not visible - hack to fix bleed through 
     
   int dimSensorRobotView = (int) (255* abs(cos(PI/8.0*dimRobotViewIndex)));  // calculate view dimming. 
   int dimCourseView = (int) (255* abs(cos(PI/8.0*dimCourseViewIndex)));      // As index values incremented dimming 
                                                                              // values repeat "sinusoidally"
                                      
   if (courseTop)  //   selective enable/disable controlled by Tab key 
   {
     lfs.drawCourseView(rotate90,dimCourseView);  // draw course view with dimming value 0..255  0=dimming OFF
     lfs.drawRobotView(dimSensorRobotView);       // dimming value 
   }  
   else                                         
     lfs.drawSensorView(dimSensorRobotView); // draw sensors. dimming value 0..255 
    
   if (quietDisplay==0)  
   userDraw();          // draw optional user graphics/annotation overlay on robot view or sensor view 
    
   resetMatrix();       // reset transforms back to screen coordinates 
   camera();
    
   if (showTopTextBar)
   {
     rectMode (CORNER);            // top of screen text boxes - backgrounds 
     strokeWeight (1.0);           // added explicit  strokeWeight,strokeColor  for lib 1.31
     stroke (240);  
     if (timeWarp) stroke (255,100,100);
     fill (0);
     rect (40,10,400,48);          // top left of screen   time box
     rect (480,10,width-485,48);   // top right of screen  contestant name, robot, location velocity 
     
     fill(240);                             // draw contestant name robot name in top right box
     textSize(28);
     text(lfs.getContestTimeString(),51,46);
     text(lfs.nameFirst+lfs.nameLast+"  "+lfs.nameRobot,500,46);
   }
   
   // --- Contest State, Controller ON/OFF State  FPS  Step Speed (or FREEZE) display upper right box right side ----- 
   
   fill(200,200,250); // light blue 
   textSize (18);
   
   if (frameCount%60 == 0)  // about every second update fps (or sps with TimeWarp)
   {  fr = frameRate;
      if (timeWarp) fr *= timeWarpMult;  // effective frame rate x timeWarp (time warp steps taken per frame)
   
   }
   char sf = 'f';
   if (timeWarp) sf = 's';  // fps (frames per second) or sps (steps per second) if timeWarp 
   
  
   if (quietDisplay == 0)  // quietDisplay possibly obsolete method of hiding display features to speed frame rate
     text(String.format("%2.0f %cps",fr,sf),width-100,30);    // (lib 1.4.1) moved to right side of screen
   else 
     text(String.format("Q)uietDisplay %d   %2.0f %cps",quietDisplay,fr,sf),width-300,30);
     
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
     textSize (20);                       // (lib 1.4.1) shrunk text just a bit (lib 1.6) a bit more 
     lfs.drawRobotLocHeadingVel(974,44);  // draw x,y location and heading using lfs provided bitmap  
                                          // during contest run, these values are not available,
                                          // That is, getRobotX() getRobotY() return zeros.
                                          // If non-contest run with Go command, values are available
   } 
   // Simulation Throttling -- this changes how fast simulation runs, but does not affect simulation 
   // logged time. That is slowing down a simulation slows down simulator stopwatch clock
         
   
     
   // --- end simulation throttling  
     
   // removed sensorUpdateNeeded
   // timeWarp 
 
   int twc = 1;
   if (timeWarp) twc = timeWarpMult;
   for (int timeWarp =0; timeWarp<twc; timeWarp++)
   {   
    
   
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
  
  
     lfs.updateSensorsFast();
      
     if (lfs.controllerIsEnabled() && simRequestStep)    // if turned off, no update.    // !!! change   
       userControllerUpdate();         // user reads sensors changes target speed and turn rate as needed.
     
     lfs_CheckCloseToMarker();
          
     if (lfs.robotOutOfBounds())       // Moved up to just after userController update Oct 22, 2020
       lfs_OutOfBounds();
     else lfs_InBounds();              
         
     lfs.driveUpdate(simRequestStep);  // if step requested update robot speed and turn rate with acceleration rates 
                                       // then position and heading with current speed and turn rates.
                                       // Note: if controller is not enabled this call will insure robot  
                                       // position is updated allowing manual drive.
   
     if (lfs.controllerIsEnabled())
     if (lfs.lapTimer.lapTimerUpdate(simRequestStep))  // update lap timer including stopwatch if not lap mode.                                  
       lfs_LapDetected();                              // returns true if lap detected, calling user method in UMisc tab.                                     
     
     if (!lfs.controllerIsEnabled()) break; // exit timeWarp loop (if enabled)                                          
        
   } // end for timeWarp
                                             
  
   if (lfs.lapTimer.lapTimerModeEnabled && focused)  // only show when window focused (lib 1.6.1)
   {
     if (guiMode) lfs.lapTimer.drawPanel ("Lap Timer ",4,740,height-182,250,158); // nvis,x,y,w,h
     else         lfs.lapTimer.drawPanel ("Lap Timer ",4,60,480,250,160);
   }    
  
   
   simRequestStep = false;           // reset simulation step request, if set during this "draw"
   
   informMarkersAboutSavedRobotState();  // LFS_RS - notify markers if robot saved states is present, appearance 
                                         // will change upon markerDraw()  (lib 1.5)
    
   if ((quietDisplay<4) && showSensors)
     lfs.showSensors((courseTop)?'R':'S');             // show user colorable sensors (lib 1.3)
   
   if (courseTop && (helpPage==0)) lfs.markerDraw();   // only display markers when course visible (lib 1.3)
                                                       // and not displaying help       
   
   
   
     
   parEditorUpdate();                // support for LFS_Par (Parameter Editor Dialog) - new in lib 1.4)
     
       
   lfsDrawPanel();                   // formerly userDrawPanel now lfsDrawPanel handles command summary & help panels. 
                                     // Also user panel methods userDrawPanel1 and userDrawPanel2 are called 
                                     // conditionally depending on screen configuration, e.g. help panel obscures 
                                     // user panel 2. Parameter dialog obscures panel 1.
                                   
  
   
   
   userMiscUpdate();     // uMisc method called every time Processing calls draw method
   
   if (guiMode && !parEditor.visible) uiUpdate();      // draw buttons process clicks
                                                       // hide when parameter dialog invoked
      
   lfs.contestScreenSaveIfRequested();   // generates screen save upon contest "Finish" after delay of few frames  
  
   bigMessageUpdate();   // LFS bigMessage display (after screen save if requested)
   
} // end of draw()
  
  
// name sensors using variable names - moved to library Sensors class. (lib 1.6)  
void nameSensorsUsingVariableNames() { lfs.sensors.nameSensorsUsingVariableNames(); } // provide compatible means of 
                                                                                      // access from old app.



// Generate a Robot Icon - eliminating need to use bitmap editor / or drawing program to create an icon.
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


// Big Message on Screen Facility (lib 1.6)   -----------------------------------------------------------------------
// message fades out and vanishes. Only 1 at a time to keep simple  
// mainly select key command responses for on-screen feedback 
                                                   
  String bigMessage = "";
  int bigMessageTotal;
  int bigMessageFrame;
  color bigMessageColor;
   
  void bigMessage(String s, color c)
  { bigMessage = s;
    bigMessageTotal = (int) (frameRate*2)  ; // make dependent on frame rate?
    bigMessageFrame = bigMessageTotal;
    bigMessageColor = c;
  }
  
  void bigMessageUpdate()  // called every frame draw
  {
    if (bigMessageFrame>0)
    {
      bigMessageFrame--;
      pushStyle();
      
      textSize (60); // -bigMessageFrame/2);
      
      fill (bigMessageColor,(int) 255*exp(-sq(1.5 - 1.5*bigMessageFrame/bigMessageTotal)  ));  // start alpha 255 then fade out
      stroke (0,0,255);
      textAlign(CENTER);
      text(bigMessage,width/2,height/2);
      popStyle();
    }  
  }
 
 // ----------------------------------------------------------------------------------------------------------
                          
 /*                                     

   userOutOfBounds method called by LFS when robot runs off the edge of a course image.
   If a contest run was in progress it is automatically stopped.
   The method should be defined, but can be empty.
  
   Here, for fun, a simple demo is provided to generate an explosion sound along with rotating, scaling
   and fading out icon.
   
   More can be done here, always the future... 
  
     
   ---- Beeps and Sound File Sounds  
   
   To use the lap beeps and/or explosion sounds included in this program tab, the optional 
   Processing Sound library must be installed, see main tab for information. (LFS_XXX  XXX=robotName) 
  
*/

  boolean mute = false;     // mute audio - toggled by Q
  boolean ticking = false;  // state of "audible ticking" persistant if mute toggled to true

  SoundFile soundInit (String fname)     // load sound file from /sound subfolder  
  {  return new SoundFile(this,"/sound/"+fname); }
  
   
    
  void playSound(SoundFile s, float volume) { if (soundEnabled && !mute) {s.amp (volume); s.play();} }
   
          
  void tickingSoundUpdate()
  {
     if (soundEnabled)
     {
       if (simFreeze || !lfs.controllerIsEnabled()) 
       { tickingSound.stop();
         //ticking = false;
       }
       else
       { 
         if (lfs.contestIsRunning())
         {
           if (!simFreeze && !tickingSound.isPlaying()) playTickingSound();
           tickingSound.rate(simSpeed/9.0);
           tickingSound.amp(tickSoundAmp*(simSpeed+5)/14.0); // quieter slower
         }  
       }
     }  
  }
  
  void lfs_SetMute(boolean muteAudio)
  {
    mute = muteAudio;
    if (soundEnabled && ticking)
    {
      if (mute) tickingSound.stop();
      else
      { playTickingSound();
        tickingSoundUpdate();
      }  
    }
    
    if (mute) mutePlayingSound();
    
  }
  
  void lfs_StopTickingSound()
  {  if (soundEnabled) { ticking=false;  tickingSound.stop(); }
  }
  
   
  void lfs_LapDetected() {
    userLapDetected();
    
    if (lapBeepEnabled & !timeWarp) playLapBeep();
    // just for fun print distance traveled at lap crossing, not available if contest running 
    if (!loopMode) println ("Lap Detected  getDistanceTraveled (zero if contest running) ",lfs.getDistanceTraveled()); 

   
    if (!loopMode && (lfs.lapTimer.lapList.size() >= lfs.lapTimer.lapCountMax))
    {
      if (lfs.contestIsRunning())
      {
        lfs.contestStop();
        userStop();
        decodeKey(' ');     // stop contest
        uiContestEnded();   // set button visible groups for finish end
      }   
      else // not contest running
      {
         lfs.stop();
         userStop();
         setEnableController(false);  
       
      }
        
      lfs_StopTickingSound();
    }
           
       
    if (!timeWarp && !loopMode) { playCheers(); } // every lap

    if (loopMode)
    {  lfs.setCrumbsDoubleBuffer(loopMode && timeWarp);  // make sure double buffer if loop and timeWarp
       lfs.crumbsEraseAll();
    }
 }
 
 void lfs_StartedRun() {           // called when R)un or G)o command issued (lib 1.4.2)
   
   userStartedRun();
   if (lfs.contestIsRunning())
   {
     playTickingSound();
     tickingSoundUpdate();
     playStartRun();
   }  
  
     
 }
                             
    
 void lfs_FinishLineDetected() {    // user thinks they crossed finish line (lib 1.4.2)
   userFinishLineDetected();
   if (soundEnabled) tickingSound.stop();
 
   if (lfs.contestIsRunning())
   {
   lfs.contestStop();               // stops stopwatch and LFS will prompt for F)inish and log run to contest.cdf report
   userStop();
   }
   else                             // or X cancel -- this must be called by your controller
   {
     setEnableController(false);
     lfs.stop();
     userStop();
   }
   
   if (loopMode)
   {  commandGo();
      lfs.crumbsEraseAll();
      lfs.setCrumbsDoubleBuffer(loopMode && timeWarp);
   }
   else
     playCheers();
   
   
 }                                    
 
  // out of bounds blow-up states
  int outState = 0;
  boolean outResponseTriggered;
  float iconOriginalScale;
 


void lfs_CheckCloseToMarker()
{
  // contest not running, freezeMarker true and distance > 10 (to eliminate false detect of start marker)
  // then proceed 
  
  if (lfs.contestIsRunning() || !freezeNearMarker ||  (lfs.getDistanceTraveled() < 10)) return;
    
  float x = lfs.getRobotX();  // non-contest mode, we have access to x,y coordinates 
  float y = lfs.getRobotY();
  float dm = lfs.distToClosestMarker(x,y);
  
  if (dm<4.0)
  {
    if (timeWarp)
    {   // important eliminate time warp 
        commandTimeWarp(false,true); // turn off time warp
        bigMessage ("Time Warp OFF, Freeze",color(100,255,100)); // override time warp OFF with this variant
    }
    
    { if  (dm<freezeNearMarkerMinDist) freezeNearMarkerMinDist = dm;
      else 
      {
        simFreeze = true;
        freezeNearMarker = false;
        tickingSoundUpdate();         
        println("lfs_CheckCloseToMarker - Freeze close to marker ");
      } 
    }  
  }
  
}

 
  
void lfs_InBounds() // complimentary call to userOutOfBounds
{
  userInBounds();
  outResponseTriggered = false;
}
 
void lfs_OutOfBounds ()
{ 
  push();                         // push Matrix and Style  
  userOutOfBounds();
  
  if (loopMode)  // new (lib 1.6) -- restart robot 
  {
    commandGo();
    pop();
    return;
  }
  
  //PImage ci =  lfs.getCourse();
  //float ymax= ci.height/64;
  //float xmax= ci.width/64;   //
    
  if (!outResponseTriggered)
  {
     outResponseTriggered = true;
     if (soundEnabled && explosionSoundEnabled) playBoom();
     outState = 1;
     iconOriginalScale = lfs.getRobotIconScale();
     lfs_StopTickingSound();
  }
  
  if (stopOnOutOfBounds)
  {
    if (lfs.contestIsRunning()) lfs.contestStop();
    else if (!mousePressed) lfs.stop();
  }   
     
  if (blowUpOutOfBounds) 
  {
    if (outState >0)
    {
        lfs.stop();
        //println ("stop");
        
        lfs.setRobotIconScale(iconOriginalScale + (0.01*outState));
        outState += 6;
        lfs.setRobotIconAlpha (255-outState);                // fade out icon
        lfs.setRobotIconRotationBias(outState *0.005 );      // rotate icon 
        
        if (outState>=255)
        {  outState = 0;
           lfs.setRobotIconRotationBias(0); // reset
           lfs.setRobotIconScale(iconOriginalScale); // need to be able to read  scale to restore    
           lfs.setRobotIconAlpha(100);
        }  
      }
     }
    
    // demo draw a box at robot location 
    
    if (!lfs.contestIsRunning()) // contest should be stopped at this point
    {                            // if not, getRobotX Y return 0
    
    
      // handy method for getting screen coords of robot
      
      PVector loc =  lfs.courseCoordToScreenCoord(lfs.getRobotX(),lfs.getRobotY());
    
      // here you could do some fun stuff beyond boring rectangle 
    
      if (courseTop)  // Added condition Oct 22
      {
        rectMode (CENTER);
        noFill();
        stroke (255,0,0);
        strokeWeight(2.0);
        rect (loc.x,loc.y,40,40,4);
        
        // ..maybe something beyond even boring spinning rectangle, presented here
            
        pushMatrix();                  // save current transform which is screen default 0,0 upper left
                                       // transforms are composed in reverse order 
                                       
        translate (loc.x,loc.y);       // 2. translate to robot location on screen  
        rotate (millis()/1000.9);      // 1. rotate about 0,0
        rect (0,0,30,30,4);            // draw 30 by 30 rectangle (with radiused corners 4) centered at 0,0
        popMatrix();                   // recover current transform
      }
    }  
    
    pop();
}  // end lfs out of bounds  


void setEnableController (boolean e )
{
  lfs.setEnableController(e);
  cbController.checked = e;        // update check box
  
}
