/* LFS_Panel 
             
   Command Summary and Help Panels Defined in this file.
   Main method is lfsDrawPanel()
   
   User panel data handeled by UPanel notebook tab.
   User help (displayed as a help page) is stored in data folder file "userhelp.txt".
   
   You should not need to dig into this code.
   
   Coordinate transforms and calls out to user panel drawing (UPanel tab) are provided in this notebook tab
   (file).
   
*/

  // using simple VP rectangle exposed in lib 1.3.2
  // like Processing rect in CORNER mode  : upper-left x,y and  width,height
   
  VP helpVP = new VP(850,100,900,750);  // x,y,w,h   screen absolute coords
  VP cmdVP  = new VP(850,720,720,150);  // x,y,w,h
 
  VP userVP1 = new VP(0,0,0,0);   // user vieports (panels) calculated at runtime
  VP userVP2 = new VP(0,0,0,0);
   
   
  color vpBorderColor     = color (240,240,240);
  color vpBackgroundColor = color (0,0,30);
     
  // help display
  int helpPage;          // sequenced by H)elp command  0=not visible 1 system page, 2 user page  
  int helpX;             // line left
  int helpY;             // line offset used by help
  int helpLineSpace;     // line spacing advance for help
 
  void help (String s) { text (s,helpVP.x+helpX,helpVP.y+helpY); helpY += helpLineSpace; }  // display line and advance down page
  void helpGap() { helpY+=8; }  // small vertical tab (gap)
  int  helpPages = 3;           // lib 1.4.1 added page with simulator maximums 
 
  void helpVu(String s, float val, String units)
  { help(String.format ("%50s = %8.2f %s",s,val,units)); }
  
 
  // command summary display - identical to help
  int cmdSumX;
  int cmdSumY;
  int cmdSumLineSpace;
 
  void cmdSum(String s) { text (s,cmdVP.x+cmdSumX,cmdVP.y+cmdSumY); cmdSumY+=cmdSumLineSpace;}
  void cmdSumGap() {cmdSumY+=8;}
   
  void drawEmptyVP(VP v) // draw bordered VP used by Help and  command display
  {
    pushStyle();
    stroke (vpBorderColor);
    fill   (vpBackgroundColor);
    rectMode (CORNER);
    rect (v.x,v.y,v.w,v.h);
    popStyle();
  }  
 
  
void lfsDrawPanel()  // called from draw() at frame rate
{
  // show sensors,markers and parEditorUpdate  moved into LFS_ main tab before this call - for clarity 
  
  stroke (240);
  fill (240);
     
  //String cs = lfs.controllerIsEnabled() ? "ON" : "off";
  //String fs = simFreeze ? "ON" : "off";
 
      
  // draw help if toggled on via H)elp
    
  if (focused)
 
  if (helpPage>0) // draw Help if page 1 or 2 or 3h controlld by keypress H, else command summary
  {
    drawEmptyVP(helpVP);
    helpX = 20;
    helpY = 20;
    helpLineSpace = 22;
    textSize (18);
    
    if (helpPage==2)
    {
      help ("PARAMETER DIALOG   Dialog that displays program variables included in list within UPar tab.");
      helpGap();
      help ("P)arameter dialog on/off (also click on [X] to hide parameter dialog.");
      help ("ctrl-D)efault - Set selected parameter to default value. (ctrl-A Default ALL)");
      help ("ctrl-S)ave    - Save Parameters to sketch's data sub-folder param.cdf");
      help ("ctrl-L)oad    - Load Parameters from sketch's data sub-folder param.cdf (manual Load only 1.4)");
      help("");
      help("");
      help ("LFS Simulator Imposed Maximum (& Minimum) Values ");   // new in lib 1.4.1
      help ("");
      helpVu("MaxSpeed",lfs.getSimMaxSpeed(),"inches/sec");
      helpVu("MaxTurnRate ",lfs.getSimMaxTurnRate(),"degrees/sec");
      helpVu("MaxAccRate",lfs.getSimMaxAcc( ),"deg/sec^2");
      helpVu("Maximum Deceleration Rate ",lfs.getSimMaxDecel(),"inches/sec^2");
      helpVu("Max Turn Acceleration Rate",lfs.getSimMaxTurnAcc(),"degrees/sec^2");
      help("");
      helpVu("Min Time Step",lfs.getMinTimeStep(),"seconds");
      helpVu("Max Time Step",lfs.getMaxTimeStep(),"seconds"); 
    }  
      
    if (helpPage ==3)
    {
      help ("User Help ");
      helpGap();
      String fname = "userhelp.txt";
      String [] h = loadStrings(fname);
      if (h == null)
      { help ("help file "+fname+" not found in data sub-folder.");
        help ("Note: file name is case senitive.");
      }
      else
      for (String s: h) help (s);
    }
    else if (helpPage == 1)
    {
      help ("LFS Help");
      helpGap();             // small vertical space  
      help ("H)elp   - cycle help pages with repetitive H press.   LFS Help > Help Pg 2 > User Help > OFF");
      helpGap();
      help ("CONTEST RUN");
      help ("R)un    - Start robot in contest mode. The most recent marker click is used for the start location.");
      help ("             If no markers have been clicked (defined and clicked) then the programmed start location");
      help ("             is used. Parameter dialog not available when running contest, use G)o command instead. ");
      help ("SPACE  - Stop the contest run.   A modal dialog appears in the location of the Command");
      help ("              Summary panel offering two choices: F)inish and append run data to data folder contest.cdf,");
      help ("              or X) Cancel report. No other input will be acceptd until choice is made.");
      helpGap();
      help ("Non-Contest Run");
      helpGap();
      help ("G)o     - Start robot in non-contest mode (user code has access to simulator position and heading)");
      help ("SPACE   - Toggle freeze (on/off) of simulator, when frozen no time steps/ controller updates.");
      help ("0..9    - Rate of time steps, 0=stop (like freeze) 1=slow ... 9=max speed");
      help ("M)arker - Place marker circle at current robot location (recording position and heading).");
      help ("              Left click in a marker circle to move robot to marker and set recorded heading.");  
      help ("              When robot is located in a marker press M to erase it.");
      
      help(""); //helpGap();
      help ("ROBOT POSITION CONTROL");
      help ("Position mouse in course view or (small) robot view, then:");
      help ("  hold left mouse button down and drag to change position");
      help ("  hold right mouse button down and drag horizontally to change heading");
      helpGap();
      help ("MANUAL ROBOT DRIVE (repetitive press of keys) ");
      help (" Vert Arrows        - speed increase/decrease (signed value  +forward -reverse)");
      help (" Horz Arrows        - turn rate increase/decrease (signed value +right -left)");
      help (" < > (comma period) - sideways motion increase/decrease (signed value +right -left)");
      help ("");
      help ("More Commands ");
      helpGap();
      help ("TAB     Toggle visiblity of course vs User Panel 2");
      help ("ALT     Toggle 90 degree rotation of course ");
      help ("Ctrl-C  Course select (next course) from list defined in UserInit.");
      help ("U)ser   Toggle user panel visibility");
     
    } // end if help page 1   
    
  } // end if helpVisible
    else
    {
      
      drawEmptyVP(cmdVP);
      cmdSumX = 20;             // text offset
      cmdSumY = 20;
      cmdSumLineSpace = 22;     // vert offset for each cmdSum() call
      textSize (18);
      
      if (lfs.getContestState() == 'S')
      {
        cmdSum("LFS CONTEST Stopped or Completed.");
        cmdSumGap();
        cmdSum("Press F to Finish, appending run data to data folder contest.cdf and creating");
        cmdSum("screen shot in sketch folder.");
        cmdSum("");
        cmdSum("OR Press X to cancel");
      }
      else
      {
        cmdSum ("LFS Command Key Summary        H)elp       P)arameter dialog   U)ser panel");
        cmdSumGap();
        cmdSum ("CONTEST R)un SPACE-Stop  0..9 step speed             ESC)Exit Program");
        cmdSumGap();
        cmdSum ("C)ontroller (on/off) G)o S)top  E)raseCrumbs M)arker SPACE-toggle freeze");
        cmdSum ("Tab course view    ALT Rotate Course  h Ctrl-C Course select");    // Ctrl-C new (lib 1.4.1)
        
        
        cmdSum(userKeyCommands1); // draw user key commands 1
        
        if (userKeyCommands2.length() >0)  // replace bottom line with 2nd line of user commands 
          cmdSum(userKeyCommands2);
        else
          cmdSum ("* If markers defined, G)o or R)un start at last clicked marker.");
      }  
        
    }
    
        
    if (!focused)  // if window does not have focus, indicate that fact to user
    {
      pushStyle();
      fill (0);
      float fpy = height-150;
      float fpx = 800;
      stroke (255,50,50);
      rect (fpx,fpy,900,50);
      fill (255, 70, 70);   // pale red
      textSize(24);
      text ("Click in application window to give focus for key command response",fpx+30, fpy+35);
      popStyle();
    }
    
    
    if (focused && (helpPage==0) && !courseTop)
    {
      pushMatrix();
      
      resetMatrix();
      camera();
      
      pushStyle();
          
      selectUserPanel2(); // make sure VP  
      translate (userVP2.x,userVP2.y);
     
      userDrawPanel2();  // user provided method (if not empty) for drawing   
                         // large panel only if course and help not visible
      popStyle();
      popMatrix();
     
    }
    
   
     if (focused && !parEditor.visible)
    {
      pushMatrix();
      
      resetMatrix();
      camera();
      
      pushStyle();
      
      selectUserPanel1();   // makes sure VP location has been calculted
     
      translate (userVP1.x,userVP1.y);
    
      userDrawPanel1();  // user provided method for drawing information in panel
                         // about same size as parameter dialog when it is not visible.
      popStyle();
      popMatrix();
     
    }
   
     
  } // end userPanelDraw   
 

 
  VP selectUserPanel2()  // defines user Panel2 based on help panel
  {
   userVP2.x = helpVP.x;
   userVP2.y = helpVP.y;
   userVP2.w = helpVP.w;
   userVP2.h = helpVP.h-150;
   return userVP2;
  }
 
 
  VP selectUserPanel1()  // defines user Panel1 based on parameter editor panel & command summary
  {
       
   userVP1.x = parEditor.parVP.x;
   userVP1.y = cmdVP.y;  
   
   if (!courseTop) userVP1.y -= 50;   // hack to make sensor data visible bottom of Sensor view (lib 1.4.1)
   userVP1.w = parEditor.parVP.w;
   userVP1.h = cmdVP.h;
    
   return userVP1;
  }  
 
  
