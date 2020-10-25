
/*  Temporary Release Notes - working a set of issues  

    Notes for 1.4.2

  + Lap Count Max & stop for contest
 
  + Initial Pos no marker clicks, default 12,12,0 override with 
    value in UserInit defineCourse. Click on marker if defined then overrides that.
   
  + Implemented cleaner contest finish, on SPACE stop or lapcount = max dialog 
    appears  press F to Finish and write report or X to cancel
    
  + Need to not allow moving robot in contest stop state only contest idle
      lfs.contestIsRunning() now true for all states except Idle
      
  - Would be nice to put a timer on Finish state for visual confirmation (Show finish top screen)
    and display of acknowldgement message.
    And possible auto clear cookie crumbs 
   
  - simSpeed = 1 should be tied to millis clock     
    
  + Tab key missing break; thinking undecoded key   
    
  + G) o needs to clear lap times on a "lap" course 
  - G)o does not stop at lap count, could FREEZE  (like pressing space bar)
        could disable controller and stop robot, but might be confusing.. 
        
  + Feedback on controller status
  -  and step speed      
  
  - Disable sound ??? UMisc  by default  (at the moment sound=false by default  
  
  + Distance traveled available when contest not running.
    Demo in UMisc print statement to console when lap detected, final lap reports distance
    (non-zero) because contest not running.
  
  + Gets stuck out of bounds  if controller OFF 

  + Output lap times to report, total time followed by N lap times  in report  

  connect these methods 

  +void userMiscUpdate()  {}          // called end of every draw
  +void userLapDetected() {}          // future sound effect / graphics (lib 1.4.1)
  -void userFinishLineDetected() {}   // user thinks they crossed finish line -- way to validate? (lib 1.4.1)
  -void userStartedRun() {}           // future sound effect? (lib 1.4.1)



*/
