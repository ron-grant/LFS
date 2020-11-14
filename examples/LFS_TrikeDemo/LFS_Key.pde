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
 boolean timeWarp = false;
 int timeWarpCount = 0;
 boolean loopMode = false;           // repeat Go reset on out of bounds

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
 
boolean goRequested = false;  // performed at bottom of simulation loop  
 
boolean commandGo()  // G)o Command - non contest run start  (reset controller, clear crumbs, reset stopwatch
{
   if (lfs.contestIsRunning())
   { 
     playBadKeySound();
     return false; // go not allowed
   }
   setEnableController(false);  // prevent updates 
   trike.reset();               // !!! experiment 
   
   goRequested = true;
   goOnRequest();  // go now or comment out for goOnRequest placed at draw bottom of loop 
   
   return true;
}         

void goOnRequest()  // for LFS_M main loop 
{
  if (!goRequested) return; 
  
  goRequested = false;
  
  lfs.clearSensors();              
  userControllerResetAndRun();
  setEnableController(true);
  lfs.setCrumbsDoubleBuffer (loopMode && timeWarp);
  lfs.crumbsEraseAll();
  lfs.clearDistanceTraveled();    // new (1.4.1) see UserInit - no impact on simulator, report only item
             
  lfs.lapTimer.lapTimerAndCountReset();  // new (1.4.1) 
  simFreeze = false;
  lfs_StartedRun();
  cbController.checked = lfs.controllerIsEnabled(); 
  
  trike.reset(); 
  println ("trike.reset() called in LFS_Key  -- non-standard code, move ");
  
}




void commandTimeWarp (boolean tw, boolean silent)
{ timeWarp = tw;
  cbTimeWarp.checked = tw;  // update GUI control 
  
  if (timeWarp)
  {  timeWarpCount++;
     if (!silent) playTimeWarp();
     bigMessage ("Time Warp Mode",color(255,50,50));
  }  
  else
  {  bigMessage("Time Warp OFF",color(50,50,255));
  }
  tickingSoundUpdate();
     
}  

boolean kbdKey;  // lets decodeKey know source is keyboard vs GUI    

void decodeCtrlKey (char k) { decodeKey ((char) (k-64)) ; }

void decodeKeyFromKeyboard(char k)
{ kbdKey = true;  // true for this keypress 
  decodeKey(k);
}


void decodeKey(char key)
{
  
   // override key decode after contest stop
  if (lfs.getContestState() == 'S')
  {
    if (key == 'F') { 
      courseTop=true;
      helpPage =0;            // help not visible
      parEditor.hide();       // parameter editor not visible 
      lfs.contestFinish();
      bigMessage ("Contest Run Logged",color (200,255,200));
      uiContestComplete();
      return;
    }
    
    if (key == 'X') {
      lfs.contestEnd();       // back to idle state  (lib 1.4.2)
      bigMessage ("Contest Run NOT Logged",color (255,200,200));
      uiContestComplete();
      return;
    } 
    
    playBadKeySound();
    return;
  }
  
  if (! parEditor.processKey(key,keyCode)) 
  switch (key) {
  
  case '0' :      break;    // do nothing, 0..9 handled in keypress
                            // prevents un decoded key message.. 
    
  /*
  case 'P' :   
                break;
  /*
  case 'A'-64 :  // all key codes here to for duplicate checking 
  case 'D'-64 :  // present for cases   
  case 'L'-64 : 
  case 'S'-64 :  // parEditor.processKey(key,keyCode); 
                 break;  // do nothing here 
  */
  
  case 'C'-64 : lfs.chooseNextCourse();       // get next course in list, see UserInit tab.  (lib 1.4.1)  
                lfs.setCrumbsDoubleBuffer(false);
                lfs.crumbsEraseAll();
                break;
 
  case 'G'-64: guiMode = !guiMode;        // draw buttons vs command key menu 
               break;
 
   
  case 'C' :    if (!lfs.contestIsRunning())
                {
                  setEnableController(!lfs.controllerIsEnabled());  // toggle allowing controller to update
                  if (!lfs.controllerIsEnabled()) 
                  {  lfs.stop();           // position and heading of robot
                     bigMessage ("Controller OFF",color(255,0,0));
                  }
                  else
                  bigMessage("Controller ON",color(255,255,50));
                }
                
                cbController.checked = lfs.controllerIsEnabled();
                
                
                break;                                                // if controller not enabled - stop robot
                  
  case 'D' :    if (!courseTop || (! lfs.getCourseViewport().pointInside(mouseX,mouseY)))   // dim (lib 1.6)
                 dimRobotViewIndex++;    // D - Dim  cycles
                else              
                 dimCourseViewIndex++;    // D - Dim  cycles
            
                break;
               
  
  case 'H' : helpPage++;
             if (helpPage>helpPages) helpPage = 0;
             break;  
             
  case 'L' : if (lfs.contestIsRunning())
             {  bigMessage ("Loop Mode Not Available",color(200,200,2000));
                cbLoopMode.checked = false;
             }
             else
             {
               if (kbdKey) loopMode = !loopMode;
               else loopMode = cbLoopMode.checked;
                 
               if (loopMode) bigMessage ("Loop Mode",color (255,40,40));
               if (!loopMode) bigMessage ("Loop Mode OFF",color (40,40,255));
    
               cbLoopMode.checked = loopMode;
             }  
             
             lfs.setCrumbsDoubleBuffer(loopMode && timeWarp); // update crumb double buffering 
             
             break;
        

  case 'M' : boolean placed = lfs.markerAddRemove();  // interactive marker placement/removal  (lib 1.3)
             lfsNewMarkerPlaced(placed);              // true if placed, false if removed. See LFS_RS OR LFS_M   (lib 1.4.3)
             userNewMarkerPlaced(placed);  
             break;
  
  case ' ' : if (lfs.getContestState() == 'S')
             {
               uiContestEnded(); // changes visibility of buttons    
             }
             else
             if (lfs.contestIsRunning()) 
             {  
               lfs.contestStop();  // move to stop state  expect  Report or Cancel F or X 
               bigMessage ("Contest Stop",color(255,0,0));
               uiContestEnded(); // changes visibility of buttons  
             }  
             else
             {
               if (simSpeed == 0) simRequestStep = true;
               if (simSpeed > 0) simFreeze = ! simFreeze;
             }
             
             lfs_StopTickingSound();
             break;  
                                                                  
  case 'E' :  lfs.crumbsEraseAll();
              break;
             
  case 'G' : if (commandGo())    // Go  enable controller, clear crumbs, reset stopwatch 
             bigMessage ("Go - Non-Contest Run",color (50,255,50));
             break;
 
   
  case 'Q'    : mute = !mute;
                lfs_SetMute(mute); 
                if (mute) btnMute.label = "UnMute";
                else btnMute.label = "Mute";
                break;
                
                
  case 'Q'-64 : quietDisplay++;                            // cycle quietDisplay -- used to hide panels.. sensor draw..
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
                
 
                                                 
  case 'S' :  lfs.stop(); 
              setEnableController(false);
              lfs_StopTickingSound();
              userStop();                        // user code 
              break;
              
              
 
      
  case 'R' : lfs.clearSensors();
             userControllerResetAndRun();
             lfs.contestStart();               // Run  enable controller, clear crumbs, reset stopwatch, reset Distance Traveled
             lfs.lapTimer.lapTimerAndCountReset();  // new (1.4.1) 
             
             helpPage =0;                      // make help not visible
             parEditor.hide();                 // parameter editor not visible 
             
             simSpeed = 9;
             simFreeze = false;
             loopMode = false;
             lfs_StartedRun();
             bigMessage ("Starting Contest Run",color (50,255,50));
             cbController.checked = lfs.controllerIsEnabled();
             break;
 
  case 'T' :  commandTimeWarp(!timeWarp,false); // toggle timeWarp state,  not silent
              break;
  
  
  
  case 'U' : if (kbdKey) userPanel1Visible = !userPanel1Visible;
             else userPanel1Visible = cbPanel1Visible.checked; 
                         
             if (userPanel1Visible) parEditor.visible = false;
             
             cbPanel1Visible.checked = userPanel1Visible;
                          
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
    
  
 case TAB   : courseTop = !courseTop;   //  Ctrl-I
              break;
 
   default  : if (key<128)
              if (!userKeypress(key))   // call user method with key not decoded by LFS
                playBadKeySound(); // drum sound 
              break;
             
  } // end switch    
  
  kbdKey = false; // reset every time 
  
}

public void keyPressed()  // handle keypress events for manual driving of robot.
{
  // !!! Processing does make note of using NEWT KeyEvent constants with P3D renderer
  // !!! Have not found a problem - yet here.   See Processing keyCode in their Reference.
  
  
  if ((key>='a')&&(key<='z')) key -=32; // shift to uppercase  
 
 
 
  if ((key >= '0') && (key <= '9')) 
  { 
    if ((simSpeed == 0) && (key=='0')) simRequestStep = true;  // allow 0 to single step if already in single step (lib 1.6.1)
    else
    {
      simSpeed = key-'0';
      simFreeze =  (simSpeed == 0);
      key = '0';  // set to be captured in below switch and not to default 
                  // which calls userKeypress
      tickingSoundUpdate();                 
    }              
  }

   
  decodeKeyFromKeyboard(key);  
  
  // P Ctrl-A Ctrl-D Ctrl-S Ctrl-L + - PgUp PgDn keys  -- parEditor.processKey
          
   
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
   
