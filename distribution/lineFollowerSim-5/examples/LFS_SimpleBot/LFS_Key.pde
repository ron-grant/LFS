/* LFS_Key - actions to take when key is pressed   (also mouseClicked actions)
             formerly UserKey

   Code in this tab is not generally modified by user. See UserKey tab which 
   is the preferred location for user keys. 
   
   Single key response commands here to allow manual drive of robot
   turning drive controller on/off, Contest Run control.
  
   Some additions for (lib 1.3) including M)arker command and addition of 
   mouseClicked() method with call to library markerHandleMouseClick method
 
*/

 boolean rotate90 = true;  // course view toggle rotate90 off/on  with ALT key 

 void mouseMoved()
 {
   lfs.setMouseActiveInViews (!parEditor.mouseInView() && (helpPage==0));     // disable mouse in course and robot view
                                                                             // if clicked in param box OR help visible 
 }
 
 void mouseClicked()
    {
      if (parEditor.handleMouseClick()) return;   // handle mouse clicks in param editor window
                                                  // returns true if event consumed.
      if (lfs.markerHandleMouseClick()) return;   // markerHandleMouseClick returns true if clicked
                                                  // in a marker circle, then this mouseClick is considered 
                                                  // consumed, hence return (lib 1.3)
      userHandleMouseClick(); 
      // user / other mouse click handlers here
      // should reactivate if mouse outside box 
  
    }
 

public void keyPressed()  // handle keypress events for manual driving of robot.
{
  // !!! Processing does make note of using NEWT KeyEvent constants with P3D renderer
  // !!! Have not found a problem - yet here.   See Processing keyCode in their Reference.
  
  
  if ((key>='a')&&(key<='z')) key -=32; // shift to uppercase  
 
  if ((key >= '0') && (key <= '9')) 
  { simSpeed = key-'0';
    simFreeze =  (simSpeed == 0);
    key = '0';  // set to be captured in below switch and not to default 
                // which calls userKeypress
  }

  parEditor.processKey(key,keyCode);  
  
  // P Ctrl-A Ctrl-D Ctrl-S Ctrl-L + - PgUp PgDn keys  -- parEditor.processKey
  
  switch (key) {
  
  case '0' :   break;   
    
  case 'P' :     // parameter editor P Ctrl-A Ctrl-D Ctrl-L Ctrl-S   
  case 'A'-64 :  // all key codes here to for duplicate checking 
  case 'D'-64 :  // present for cases   
  case 'L'-64 : 
  case 'S'-64 :  break;  // do nothing here 
 
  case 'C' :    lfs.setEnableController(!lfs.controllerIsEnabled());  // toggle allowing controller to update
                if (!lfs.controllerIsEnabled()) lfs.stop();           // position and heading of robot
                break;                                                // if controller not enabled - stop robot
                      
  
  case 'H' : helpPage++;
             if (helpPage>2) helpPage = 0;
             break;  

  case 'M' : lfs.markerAddRemove();   // interactive marker placement/removal  (lib 1.3)
             break;
  
  case ' ' : if (lfs.contestIsRunning()) 
               lfs.contestStop();
             else
             {
               if (simSpeed == 0) simRequestStep = true;
               if (simSpeed > 0) simFreeze = ! simFreeze;
             }  
             break;  
                                                                  
  case 'E' :  lfs.crumbsEraseAll();
              break;
  case 'F' :  courseTop=true;
              helpPage =0;            // help not visible
              parEditor.hide();       // parameter editor not visible 
              lfs.contestFinish();
              break;
                                                 
  case 'S' :   lfs.stop(); lfs.setEnableController(false); break;
  
  // Sideways Drive Mode - e.g. Mecanum Wheel  using < > keys (shifted or not shifted) 
  // controller would typically use lfs.setTargetSidewaysSpeed() method in addition to 
  // setTargetSpeed() forward/back motion and setTargetTurnRate for heading change
  
  case ',' :
  case '<' : lfs.changeTargetSidewaysSpeed(-1.0);
             break;
             
  case '.' :
  case '>' : lfs.changeTargetSidewaysSpeed(1.0);
             break;
            
  case 'G' : lfs.clearSensors();             // Go  enable controller, clear crumbs, reset stopwatch 
             userControllerResetAndRun();
             lfs.setEnableController(true);
             lfs.crumbsEraseAll();
             simFreeze = false;
             break;
       
  case 'R' : lfs.clearSensors();
             userControllerResetAndRun();
             lfs.contestStart();               // Run  enable controller, clear crumbs, reset stopwatch
             helpPage =0;                      // help not visible
             parEditor.hide();                 // parameter editor not visible 
             simSpeed = 9;
             simFreeze = false;
             break;
  
 case TAB   : courseTop = !courseTop;   //  Ctrl-I
 
   default  : if (key<128) userKeypress(key);   // call user method with key not decoded by LFS    
              break;
             
  } // end switch              
   
  if (keyCode ==  UP)   lfs.changeTargetSpeed(1.0f);
  if (keyCode == DOWN)  lfs.changeTargetSpeed(-1.0f);
  if (keyCode == LEFT)  lfs.changeTargetTurnRate(-11.25f);
  if (keyCode == RIGHT) lfs.changeTargetTurnRate(11.25f);
  if (keyCode == ALT)   { rotate90 = !rotate90; clearScreen(); }
     
  // note also PAGEUP and PAGEDN used by Parameter Editor 
  
                      
}   
   
