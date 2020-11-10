/* LFS_Key - actions to take when key is pressed   (also mouseClicked actions)
             formerly UserKey

   Code in this tab is not generally modified by user. See UKey tab which 
   is the preferred location for optional user key command decode.
   
   Single key response commands here to allow manual drive of robot
   turning drive controller on/off, Contest Run control.
  
   Some additions for (lib 1.3) including M)arker command and addition of 
   mouseClicked() method with call to library markerHandleMouseClick method
 
*/

 boolean rotate90 = true;       // course view toggle rotate90 off/on  with ALT key
 int quietDisplay = 0;          // Q - Cycles 0,1,2   >0 hide displays >1 hide sensor overlay

 void mouseMoved()
 {
   lfs.setMouseActiveInViews (!parEditor.mouseInView() && (helpPage==0));     // disable mouse in course and robot view
                                                                             // if clicked in param box OR help visible 
 }
 
 void mouseClicked()
    {
      if (parEditor.handleMouseClick()) return;   // handle mouse clicks in param editor window
                                                  // returns true if event consumed.
                                                  
      if (lfs.markerHandleMouseClick()) {         // markerHandleMouseClick returns true if clicked
         lfsMarkerClicked();                      // see LFS_RS or LFS_M (if LFS_RS tab not present)   (lib 1.4.3)    
         userMarkerClicked();                     // in a marker circle, then this mouseClick is considered 
         return;                                  // consumed, hence return (lib 1.3)
      }                                           // call userMarkerClicked new (lib 1.4.2)
     
      userHandleMouseClick(); 
      // user / other mouse click handlers here
      // should reactivate if mouse outside box 
  
    }
 

public void keyPressed()  // handle keypress events for manual driving of robot.
{
  // !!! Processing does make note of using NEWT KeyEvent constants with P3D renderer
  // !!! Have not found a problem - yet here.   See Processing keyCode in their Reference.
  
  
  if ((key>='a')&&(key<='z')) key -=32; // shift to uppercase  
 
  // override key decode after contest stop
  if (lfs.getContestState() == 'S')
  {
    if (key == 'F') { 
      courseTop=true;
      helpPage =0;            // help not visible
      parEditor.hide();       // parameter editor not visible 
      lfs.contestFinish();
      return;
    }
    
    if (key == 'X') {
      lfs.contestEnd();       // back to idle state  (lib 1.4.2)
      return;
    } 
    
    return;
  }
 
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
  
  case 'C'-64 : lfs.chooseNextCourse();    // get next course in list, see UserInit tab.  (lib 1.4.1)  
                //userInit(); 
                break;
                
  case 'Q'    : quietDisplay++;                            // cycle quietDisplay -- used to hide panels.. sensor draw..
                if (quietDisplay > 4) quietDisplay = 0;    // experimental frame rate speed up
                showCommandSummary = (quietDisplay==0);    // 3 = shows sensor view with overlay
                showTopTextBar = (quietDisplay==0);        // 4 = shows only sensor view -- bare minimum
                if (quietDisplay==3) { 
                  courseTop = false;
                  userPanel1Visible = false;
                  userPanel2Visible = false;
                  helpPage = 0;
                }
                if (quietDisplay==0) 
                { courseTop = true; 
                  userPanel2Visible = true;
                  userPanel1Visible = true;
                }
                                              
                break;
                
 
  case 'C' :    lfs.setEnableController(!lfs.controllerIsEnabled());  // toggle allowing controller to update
                if (!lfs.controllerIsEnabled()) lfs.stop();           // position and heading of robot
                break;                                                // if controller not enabled - stop robot
                      
  
  case 'H' : helpPage++;
             if (helpPage>helpPages) helpPage = 0;
             break;  

  case 'M' : boolean placed = lfs.markerAddRemove();  // interactive marker placement/removal  (lib 1.3)
             lfsNewMarkerPlaced(placed);            // true if placed, false if removed. See LFS_RS OR LFS_M   (lib 1.4.3)
             userNewMarkerPlaced(placed);  
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
 
                                                 
  case 'S' :  lfs.stop(); lfs.setEnableController(false);
              userStop();  // allow user to add custom actions to be taken on S)top (lib 1.4.3)
              break;
  
  case 'U' :  userPanel1Visible = !userPanel1Visible;
              if (userPanel1Visible) parEditor.visible = false;
              break;
  
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
             lfs.clearDistanceTraveled();    // new (1.4.1) see UserInit - no impact on simulator, report only item
             
             lfs.lapTimer.lapTimerAndCountReset();  // new (1.4.1) 
             
             simFreeze = false;
             userStartedRun();
             break;
       
  case 'R' : lfs.clearSensors();
             userControllerResetAndRun();
             lfs.contestStart();               // Run  enable controller, clear crumbs, reset stopwatch, reset Distance Traveled
             lfs.lapTimer.lapTimerAndCountReset();  // new (1.4.1) 
             
             helpPage =0;                      // make help not visible
             parEditor.hide();                 // parameter editor not visible 
             
             simSpeed = 9;
             simFreeze = false;
             userStartedRun();
             break;
  
 case TAB   : courseTop = !courseTop;   //  Ctrl-I
              break;
 
   default  : if (key<128) userKeypress(key);   // call user method with key not decoded by LFS    
              break;
             
  } // end switch              
   
  if ((keyCode == UP) || (keyCode == DOWN) || (keyCode == LEFT) || (keyCode == RIGHT))
  {
    if (!userArrowKeyDecode(keyCode)) // user can decode their own actions and/or allow default actions
    {
        // userArrowKeyDecode returns false, normal decode proceeds   (lib 1.4.3)
      
        switch (keyCode) {
        case UP  :  lfs.changeTargetSpeed(1.0f);       break;    // default behaviors 
        case DOWN:  lfs.changeTargetSpeed(-1.0f);      break;
        case LEFT:  lfs.changeTargetTurnRate(-11.25f); break;
        case RIGHT: lfs.changeTargetTurnRate(11.25f);  break;
        } // end switch
    }
  }    
  
  if (keyCode == ALT)   { rotate90 = !rotate90;}
     
  // note also PAGEUP and PAGEDN used by Parameter Editor 
  
                      
}   
   
