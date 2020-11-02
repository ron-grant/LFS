
/*  Temporary Release Notes - working a set of issues  

    Notes for 1.4.3
    
  + userArrowKeyDecode method added to UKey which must be defined 
    as  boolean userArrowKeyDecode(int k) { return false; }
    if not used. Allows taking over arrow keys (return true)
    or adding to key functionality...
  
  + userStop() called when stop command issued (lib 1.4.3)  
   
  - user console messages ability to capture  
  
  - reduce console messages 
      commented out userHandleMouseClick message 
      

    Notes for 1.4.2  very minor changes for (1.4.3)

  + Lap Count Max & stop for contest
  
  + moved PImage bigIcon;   declaration to UserDraw
 
  + Initial Pos no marker clicks, default 12,12,0 override with 
    value in UserInit defineCourse. Click on marker if defined then overrides that.
   
  + Implemented cleaner contest finish, on SPACE stop or lapcount = max dialog 
    appears  press F to Finish and write report or X to cancel
    
  + Need to not allow moving robot in contest stop state only contest idle
      lfs.contestIsRunning() now true for all states except Idle
      
  - Would be nice to put a delay-timer on Finish state to allow for visual confirmation (Show finish top screen)
    and display of acknowldgement message.
    And possible auto clear cookie crumbs 
   
  - simSpeed = 1 should be tied to millis clock (minor issue - skipping for now)    
    
  + Tab key missing break; thinking undecoded key   
    
  + G) o needs to clear lap times on a "lap" course 
  + G)o does not stop at lap count, could FREEZE  (like pressing space bar)
        could disable controller and stop robot, but might be confusing.. 
        opted for controller OFF and stop robot 
        
  + Feedback on controller status
  +  and step speed      
  
  + lap sound enabled by default   
  
  + Distance traveled available when contest not running.
    Demo in UMisc print statement to console when lap detected, final lap reports distance
    (non-zero) because contest not running.
  
  + Gets stuck out of bounds  if controller OFF 

  + Output lap times to report, total time followed by N lap times  in report  

  + connect these methods 

  void userMiscUpdate()  {}          // called end of every draw
  void userLapDetected() {}          // future sound effect / graphics (lib 1.4.2)
  void userFinishLineDetected() {}   // user thinks they crossed finish line (lib 1.4.3)
  void userStartedRun() {}           // R)un or G)o just issued (lib 1.4.2)
  
  (lib 1.5.1)
  + Param Editor Ctrl-A)ll not working
  + Param Editor allowed drifting off selected parameter when left mouse button held down 
      logic still not totally clean, but better
      
  + Updated Users Manual
  + Implemented Q)uietDisplay used to cycle (1..4) blanking of display panels / text except for essential Sensor view 
    Experiment in program speed up.
    
    
    
  
  

*/
