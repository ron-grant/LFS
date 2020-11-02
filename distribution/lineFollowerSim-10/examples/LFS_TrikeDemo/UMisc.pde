/* UMisc  - Optional Miscellaneous User Methods  

   userMiscSetup()                     called from setup at program startup
   userMiscUpdate()                    called every draw
   userLapDetected()                   called when lap detected (crossing close to start location)
   userStartedRun()                    called when user presses G)o or R)un
   userStop()                          called when S pressed  (lib 1.4.3)  
   userInBounds()                      called if robot in course bounds, either this or userOutOfBounds called every draw
   userOutOfBounds()                   called if robot outside course bounds
   userFinishLineDetected()            called when your controller believes it has have crossed the finish line (Challenge Course)
                                          for now stops contest run, could add sound effects... 
                
   userMarkerPlaced(placed);           called when a new marker placed or removed  
                                       
   userMarkerClicked();                called when robot jumps to old marker
                                      
                            
                                      

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

  boolean sound = true;                  // set true if you want to hear sounds 
                                         // also sound lib required, see above.
 
 
  boolean lapBeepEnabled        = true;
  
  boolean stopOnOutOfBounds     = true;   // when true, contest stopped (if running) 
                                          // If robot running via G)o command, it can be dragged back on to 
                                          // course with controller still active.
                                            
  
  boolean blowUpOutOfBounds = false;      // include animation of robot blowing up
  boolean explosionSoundEnabled =  false;  // include explosion sound 
 
  

  SoundFile boomSound;    // sound file (.mp3 or .wav) 
  SinOsc beep;            // sound library sine wave oscillator 
  int beepTime;           // time when a beep is started  
  
  void userMiscSetup()   // called from setup at program startup
  {
    beep = new SinOsc(this);                            
    beep.freq(500);             // beep frequency in Hz                                     
    beep.amp(0.15);             // beep volume 0 to 1.0  when "played" 
    
    boomSound = new SoundFile(this,"/sound/explosion.mp3");
    
    // other initialization code here 
    
  }
  
  void lapBeep() { beep.play(); beepTime = millis(); }   // initiate a beep sound, logging time of start 
                                                         // millis() returns milliseconds that program has been running
  
  void userMiscUpdate() {   // this method called every draw 
  
    if ((beepTime>0) && (millis()-beepTime>100))         // if beep initiated, stop it after 100 msec (0.1 sec)
    { beep.stop(); beepTime = 0; } 
 
    // other user misc functions called every draw (frequently)
 
  } 
  
  void userLapDetected() {
    if (sound & lapBeepEnabled) lapBeep();
    // just for fun print distance traveled at lap crossing, not available if contest running 
    println ("Lap Detected  getDistanceTraveled (zero if contest running) ",lfs.getDistanceTraveled()); 

    if (!lfs.contestIsRunning()) 
    if (lfs.lapTimer.lapList.size() == lfs.lapTimer.lapCountMax)
      lfs.setEnableController(false);

 }
 
 void userStartedRun() {}           // called when R)un or G)o command issued (lib 1.4.2)
 
 // additional actions to take when S)top command issued.
 // on Trike - stop drive wheel
 
 void userStop() {
  trike.wheelVelocity = 0.0;             // additional actions to take when S)top command issued        (lib 1.4.3)
  currentRobotState.wheelVelocity = 0;   // at present controller disabled and robot commanded to stop
 }                                   
    
 void userFinishLineDetected() {    // user thinks they crossed finish line (lib 1.4.2)
   lfs.contestStop();               // stops stopwatch and LFS will prompt for F)inish and log run to contest.cdf report
                                    // or X cancel -- this must be called by your controller 
 }                                    
 
  int outState = 0;
  boolean outResponseTriggered;
  float iconOriginalScale;
 
  
void userInBounds() // complimentary call to userOutOfBounds
{
  outResponseTriggered = false;
}
 
void userOutOfBounds ()
{     
  PImage ci =  lfs.getCourse();
  float ymax= ci.height/64;
  float xmax= ci.width/64;   //
    
  if (!outResponseTriggered)
  {
     outResponseTriggered = true;
     if (sound && explosionSoundEnabled)
     { if (boomSound != null)
       { boomSound.rate(0.8);
         boomSound.play();
       }  
     }
     outState = 1;
     iconOriginalScale = lfs.getRobotIconScale();
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
    
    
}  

              
void userNewMarkerPlaced(boolean placed)    // called when a new marker placed
{}                                          // LFS now saves state information when new markers are placed  
                                            // see UserReset tab header.


void userMarkerClicked()   {}  // optional user method. Note LFS is taking care of state save/restore 
                               // see UserReset tab header. Also see LFS_RS.
