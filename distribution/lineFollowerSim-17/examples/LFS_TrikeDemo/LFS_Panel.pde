/* LFS_Panel 
             
   Command Summary and Help Panels Defined in this file.
   Main method is lfsDrawPanel()
   
   User panel data handeled by UPanel notebook tab.
   User help (displayed as a help page) is stored in data folder file "userhelp.txt".
   
   You should not need to dig into this code.
   
   Coordinate transforms and calls out to user panel drawing (UPanel tab) are provided in this notebook tab
   (file).
   
*/
  
  boolean showCommandSummary = true;   // set false for possible slight fps increase  See Ctrl-Q

  // using simple VP rectangle exposed in lib 1.3.2
  // like Processing rect in CORNER mode  : upper-left x,y and  width,height
   
  VP helpVP = new VP(850,100,900,750);  // x,y,w,h   screen absolute coords
  VP cmdVP  = new VP(850,720,740,150);  // x,y,w,h
 
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
 
  boolean userPanel1Visible = true;  // toggled by U key  (lib 1.4.2)
  boolean userPanel2Visible = true;
 
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
      help ("ctrl-D)efault - Set selected parameter to default value.");
      help ("ctrl-A)ll        - Set ALL parameters to default value."); 
      help ("ctrl-S)ave     - Save Parameters to sketch's data sub-folder param.cdf");
      help ("ctrl-L)oad     - Load Parameters from sketch's data sub-folder param.cdf (manual Load only 1.4)");
      help("");
      help ("MARKERS ");
      helpGap();
      help ("When robot stopped, pressing M creates a location marker (magenta circle) which records robot");
      help ("location and heading for later click that positions robot for run start (Go or Run command).");
      help ("When robot is running in non-contest mode (G key run), pressing M creates a robot state save");
      help ("marker (magenta circle with rotating square) which records robot location, heading, speed, turn-");
      help ("rate and user controller state variables defined in RobotState class. See UserReset tab and");
      help ("LFS User's Guide.  Later click on state-save marker, restores robot run state, but freezes robot,");
      help ("press SPACE or 1..9 to resume run. ");
      help ("");
      help ("Pressing M while robot is located on a marker, erases the marker.");
      help ("Markers are persistant between LFS invocations. (course name.mrk file)");
      help ("");
      help("");
      help ("LFS SIMULATOR IMPOSED MAXIMUM & MINIMUM VALUES");   // new in lib 1.4.1
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
      help ("USER HELP  (/data/userhelp.txt)");
      helpGap();
      String fname = "userhelp.txt";
      
      File f = new File (dataPath(fname));
      if (!f.exists())
      { help ("User commands and comments can be placed here via creation of help file "+fname);
        help ("placed in sketch data sub-folder. Note: file name is case senitive.");
        help ("Also, file should be plain ASCII text with hard carriage returns.");
      }
      else
      {  String [] h = loadStrings(fname);
        for (String s: h) help (s);
      }
          
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
      help ("             is used. Parameter dialog is not available when running contest, use G)o command instead. ");
      help ("SPACE  - Stop the contest run.   A modal dialog appears in the location of the Command");
      help ("              Summary panel offering two choices: F)inish and append run data to data folder");
      help ("              contest.cdf, or X) Cancel report. No other input will be accepted until choice is made.");
      helpGap();
      help ("NON-CONTEST RUN");
      helpGap();
      help ("G)o     - Start robot in non-contest mode (user code has access to simulator position and heading)");
      help ("SPACE  - Toggle freeze (on/off) of simulator, when frozen no time steps/ controller updates.");
      help ("0..9     - Time step rate 1..9, 0=Stop, repetitively press 0 or SPACE to single step.");
      help ("M)arker - Place/Erase Start/State Save Marker - see next help page. ");
      help ("T)imeWarp- Toggle time warp mode, simulator takes multiple steps per frame draw, with huge");
      help ("                 simulator speed-up potential. Time Warp Multipler is controlled by Parameter Editor");
      help ("                 while not running contest.");
      help ("");
      helpGap();
      help ("ROBOT POSITION CONTROL (contest not running) - Position mouse in course or robot view, then:");
      help ("  hold left mouse button down and drag to change position ");
      help ("  hold right mouse button down and drag horizontally to change heading");
      helpGap();
      help ("MANUAL ROBOT DRIVE (repetitive press of keys) - with Controller OFF");
      help (" Vert Arrows        - speed increase/decrease (signed value  +forward -reverse)");
      help (" Horz Arrows        - turn rate increase/decrease (signed value +right -left)");
      help (" < > (comma period) - sideways motion increase/decrease (signed value +right -left)");
      //help ("More Commands ");
      helpGap();
      help ("D)im    repetitive press while mouse over course or robot view to change brightness");  
      help ("TAB     Toggle visiblity of course vs User Panel 2");
      help ("ALT     Toggle 90 degree rotation of course ");
      help ("Ctrl-C  Course select (next course) from list defined in UserInit.");
      help ("U)ser   Toggle user panel visibility");
      help ("Q)uiet  Toggle mute");
     
    } // end if help page 1   
    
  } // end if helpVisible
    else
    {
      if (showCommandSummary & !guiMode)
      {
        drawEmptyVP(cmdVP);
        cmdSumX = 20;             // text offset
        cmdSumY = 20;
        cmdSumLineSpace = 22;     // vert offset for each cmdSum() call
        textSize (18);
      }  
      
      if (lfs.getContestState() == 'S')
      {
        cmdSum("LFS CONTEST Stopped or Completed.");
        cmdSumGap();
        cmdSum("Press F to Finish, appending run data to data folder contest.cdf and creating");
        cmdSum("screen shot in sketch folder.");
        cmdSum("");
        cmdSum("OR Press X to cancel");
      }
      else if (showCommandSummary && !guiMode) 
      {
        if (lfs.contestIsRunning())
        {
          cmdSum ("LFS Command Keys  Contest Running - SPACE BAR Stop        ESC Exit");
          cmdSumGap();
          cmdSum ("U)ser panel  D)im");
          cmdSum ("1..9 step speed 0)single step  T)imeWarp   ");
          //cmdSumGap();
          cmdSum ("Tab course view    ALT Rotate Course  Q)uiet");   
        }
        else
        {
          cmdSum ("LFS Command Key Summary   H)elp   P)aramEdit  U)ser panel  Ctrl-G GUI  ESC Exit");
          cmdSumGap();
          
          cmdSum ("R)unContest  1..9 step speed  0)single step  T)imeWarp L)oop ");
          
          cmdSumGap();
          cmdSum ("C)ontroller (on/off) G)o S)top  E)raseCrumbs M)arker SPACE-toggle freeze");
          cmdSum ("Tab course view    ALT Rotate Course  D)imViews   Ctrl-C Course select  Q)uiet");    // Ctrl-C new (lib 1.4.1)
        }
        
        cmdSum(userKeyCommands1); // draw user key commands 1
        
        if (userKeyCommands2.length() >0)  // replace bottom line with 2nd line of user commands 
          cmdSum(userKeyCommands2);
        else
        {
         if (lfs.controllerIsEnabled())
         {
           if (simSpeed==0) cmdSum ("(step speed = 0)   SPACE BAR  single step");
           else
           cmdSum ("(step speed > 0)   SPACE BAR  toggles FREEZE");
         }
         else
          cmdSum ("* If markers defined, G)o or R)un start at last clicked marker.");
        }  
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
    
    
    if (focused && (helpPage==0) && !courseTop && userPanel2Visible)
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
    
    // Determine if Panel1 is to be shown
    if (focused && userPanel1Visible) 
    if ((parEditor.visible && !guiMode) || (guiMode && helpPage==0) || !guiMode )
    {
      pushMatrix();
        
      resetMatrix();
      camera();
      
      pushStyle();
      
      selectUserPanel1();   // makes sure VP location has been calculted
     
      translate (userVP1.x,userVP1.y);
      if (guiMode) translate (1000,0);
    
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
   
   if (!guiMode && !courseTop) userVP1.y -= 50;   // hack to make sensor data visible bottom of Sensor view (lib 1.4.1)
   
   userVP1.w = parEditor.parVP.w-100;
   userVP1.h = cmdVP.h;
    
   return userVP1;
  }  
 
  
