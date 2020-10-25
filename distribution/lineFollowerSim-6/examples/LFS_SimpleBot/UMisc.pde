/* UMisc  - Miscellaneous User Methods  (userOutOfBounds so far  lib 1.4)



   userOutOfBounds method called by LFS when robot runs off the edge of a course image.
   If a contest run was in progress it is automatically stopped.
   The method should be defined, but can be empty.
  
   Here, for fun, a simple demo is provided to generate an explosion sound along with rotating, scaling
   and fading out the icon.
   
   More needs to be done here, but humble author is cooked after writing LFS_Par code past few days.
   Look for lib 1.4.1 
   Possibly icon for where robots have crashed into wall during current invocation of LFS...
   Better explosion. Burning robot..  might be good for style points in the future.
   
   
   ---- Explosion Sound (and other future sounds) 
   
   To use the explosion sound below, you will need to have the Processing sound library installed on
   your system and enable code in explosionSound and import processing.sound.*; statement.
   
   To install the sound library,
   on the Processing command menu bar click Sketch > Import Library... > Add Library ... 
   The Contribution Manager Window will appear.
   Click on the Filter Box and enter the word "sound"  
   Then click on Sound | Provides a simple way to work with audio.
   Then click Install at bottom right of window. 
   After the library installs completes, close the Contribution Manager window and
   run your sketch.
   
*/

 
  import processing.sound.*;
  
  boolean stopOnOutOfBounds = true;   // Oct 22, stop contest and robot but leave controller ON  
                                      // might be better way like enable controller if drag robot
                                      // or screen feedback on controller state 
  
  boolean blowUpOutOfBounds = false;  // include animation of robot blowing up
  
  boolean sound = false;
  
  SoundFile lapSound; 
  SoundFile boomSound;
  
  void userMiscSetup()  // called from setup allows init sound... 
  {
    lapSound  = new SoundFile(this,"tadaSound.mp3");
    boomSound = new SoundFile(this,"Explosion+6.mp3");
  }
  
  void userMiscUpdate() {} // called every draw
  
  void userLapDetected() {if (sound) lapSound.play(); }
    
     
  void userFinishLineDetected() {}   // user thinks they crossed finish line -- way to validate? (lib 1.4.1)
  void userStartedRun() {}           // future sound effect? (lib 1.4.1)
          
     
  void explosionSound()
  { if (!sound) return;
    boomSound.rate(0.8);
    boomSound.play();
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
      explosionSound();
       
     if (stopOnOutOfBounds)
     {
       //lfs.setEnableController(false);
       lfs.contestStop();
       lfs.stop();
     }  
     
     if (!blowUpOutOfBounds) return; 
      
      outState = 1;
      iconOriginalScale = lfs.getRobotIconScale();
    }
    else 
    if (outState >0)
    {
      lfs.setRobotIconScale(iconOriginalScale + (0.01*v1*outState));
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
    
