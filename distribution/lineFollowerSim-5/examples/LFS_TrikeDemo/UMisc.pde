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
   
   
*/

  import processing.sound.*;
  SoundFile soundfile;
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
      soundfile = new SoundFile(this, "Explosion+6.mp3");
      soundfile.rate(0.5);
      soundfile.play();
      lfs.setEnableController(false);
      lfs.contestStop();
      lfs.stop();
      trike.reset();  // stop trike   !!!! added for trike 
      outState = 1;
      iconOriginalScale = lfs.getRobotIconScale();
    }
    else 
    if (outState >0)
    {
      lfs.setRobotIconScale(iconOriginalScale + (0.01*outState));
      outState += 6;
      lfs.setRobotIconAlpha (255-outState);                // fade out icon
      lfs.setRobotIconRotationBias(outState *0.005 );      // rotate icon 
      
      if (outState>=255)
      {  outState = 0;
         lfs.setRobotIconRotationBias(0); // reset
         lfs.setRobotIconScale(iconOriginalScale); // need to be able to read  scale to restore    
         lfs.setRobotIconAlpha(100);
         trike.reset();  //  !!! stop trike   added for trike 
      }  
    }
    
    // demo draw a box at robot location 
    
    if (!lfs.contestIsRunning()) // contest should be stopped at this point
    {                            // if not, getRobotX Y return 0
    
    
      // handy method for getting screen coords of robot
      
      PVector loc =  lfs.courseCoordToScreenCoord(lfs.getRobotX(),lfs.getRobotY());
    
      // here you could do some fun stuff beyond boring rectangle 
    
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
    
