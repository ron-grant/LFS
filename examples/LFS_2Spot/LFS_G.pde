/* LFS_G  Global Settings (first 100 lines) then  GUI Setup and GUI command decode       new (lib 1.6)
  
   Global Settings and Sound Setup - First ~100 lines 
   
   ----- Remainder of Tab GUI Code 
      
   Using custom light-weight GUI (only buttons and checkboxes in this app)
   Two classes UI and UIButton added to lineFollowerSim library (lib 1.6)
      
   Ron Grant
   Nov 24,2019 original code written for webcam app - not using all features..
   Nov 9,2020  ported GUI code to library (lineFollowerSim)
    
    
   Important Methods In this Notebok Tab
   
   uiSetup()  called from setup, defines buttons and their locations 
                then calls UMisc method userSetupUI() for user buttons/checkboxes definitions
                
   uiUpdate() called from draw (LFS_M  lfsDraw) at frame draw rate, draw buttons, decode and execute commands most
              of which are realized by key command decoder
                then calls UMisc method userDecodeUICommands to decode xxx
               
 
 
*/


/* LFS_G  Global variables with initial values that can be modified.
          Note this file can be overwritten with newer renditions of LFS.
          
          You can make changes here, but note that any variables used with Parameter Editor
          will have their values overriden by Parameter Editor's "default value" for variable.
          
          Another means of overriding these values is to place an assignment in your userInit code.
          
*/
  // These variables could be assigned values in your userInit code ------------------------------------------------

  boolean showSensors = true;    // set false to hide your sensors  :(    now also GUI controls    

  int dimCourseViewIndex = 3;    //  0=OFF to  5=BRIGHT  hover mouse over course or robot/sensor view
  int dimRobotViewIndex  = 2;    //                      press D to cycle, initial values here 
 
  boolean lapBeepEnabled         = true;
  
  boolean stopOnOutOfBounds      = true;    // when true, contest stopped (if running) 
                                            // If robot running via G)o command, it can be dragged back on to 
                                            // course with controller still active.
                                      
  
  boolean blowUpOutOfBounds      =  false;   // include animation of robot blowing up (except when Loop enabled)
                                             // disabled for now problems dragging back in bounds robot size not reset (lib 1.6.4)
  boolean explosionSoundEnabled  =  false;   // include explosion sound (auto disabled when Loop enabled)
 
  float   tickSoundAmp = 0.4;                // 0 to 1.0 (value is attenuated when step rate slowed 1..8) 
  
  // End variables that can be assigned values in your userInit code -----------------------------------------
    
  boolean soundEnabled = true;   // set false to eliminate all application sound - this should not be modified 
                                 // elsewhere.  Mute command (Q Key) can be used toggle sound 
  
  // sound files are defined here and loaded 

  boolean freezeNearMarker = false;  // goMarker states
  float   freezeNearMarkerMinDist;   // set to large value on GoMarker press 


  SoundFile lapBeepSound,boomSound,timeWarpSound,startSound,finishSound,tickingSound,badKeySound,tadaSound,whoopSound,
            snapSound;     
 
  void loadSoundFiles() // init sound objects, all located in sketch's sub-folder sound  
  {
    if (!soundEnabled) return;
                                                    // sound to play for:
    lapBeepSound = soundInit("LapBeep.wav");        // lap detected 
    boomSound = soundInit("explosion.mp3");         // if explode enabled on out of bounds
    timeWarpSound = soundInit ("TimeWarp.wav");     // time warp is enabled
    startSound = soundInit("HitItRonnie.wav");      // contest run started 
    finishSound = soundInit("CrowdCheer.wav");      // robot detects it has finished, or lap count reached
    tickingSound = soundInit("ticking.wav");        // stop watch tick
    badKeySound = soundInit("BadKey.wav");          // illegal key pressed 
    tadaSound = soundInit("tadaSound.mp3");
    snapSound = soundInit("Snap.wav");
    whoopSound = soundInit("Whoop.wav");
    
    userLoadSoundFiles();
    
    
  }  
  
  void playBoom()     { playSound(boomSound,0.4);    }
  void playTimeWarp() { playSound(timeWarpSound,0.4);}   // sound object, volume
  void playStartRun() { playSound(startSound,0.4);   } 
  void playCheers()   { playSound(finishSound,0.5);  }
  void playLapBeep()  { playSound(lapBeepSound,0.5); }
  void playBadKeySound()   { playSound(badKeySound,0.8);  }
  void playTada()          { playSound(tadaSound,0.5); }
  void playMarker()        { playSound(whoopSound,0.1); }
  void playStateMarker()   { playSound(snapSound,0.2); } 
  
     
  void playTickingSound() {  
    if (soundEnabled && (!timeWarp || (timeWarp && timeWarpMult <= 10))) {
      tickingSound.loop();            // endless loop until tickingSound.stop() called 
      playSound(tickingSound,tickSoundAmp); // sound amp gets attenuated when slowed 
      ticking = true;
    }
  }
  
  void mutePlayingSound()         // called on mute -- include all persistant sounds 
  { if (!soundEnabled) return;
    startSound.stop();
    finishSound.stop();
    timeWarpSound.stop(); 
  }
 

  
  
// GUI Setup Buttons and Checkboxes ------------------------------------------------------------------------------------------



boolean guiMode = true;        // "Graphical User Interface" mode, when true buttons displayed and clicks decoded
                               //  when set false by clicking [KeyMenu] button, key code menu appears where 
                               // Ctrl-G key command re-activates guiMode.

UIButton cbTimeWarp;           // references to checkboxes so can programatically check,uncheck
UIButton cbLoopMode;           // allowing key commands to stay active. An number of key commands manipulate  
UIButton cbPanel1Visible;      // these variables. 
UIButton cbController;
UIButton cbSensorsVisible; 

UIButton btnMute;              // reference to button, to allow modification of label "Mute" "UnMute"
UIButton btnUser;              // reference to button, to allow modification of label "User" "LFS"

UI ui;          // single instance of UI

void uiSetup()  // called once from setup, create button and checkbox definitions 
                // then later in uiUpdate actions are defined 
               
{
   
  ui = new UI(this); // single instance of UI (incorporated into lineFollowerSim lib)
  
  // define button locations, sizes, auto increment on placement
  
  ui.setHintLocation(30,height-4);             // location of hint string that appears when you hover over buttons/checkboxes..
  ui.setValEditRect (100,height-200,400,150);  // value editor pop up - not being used 
  ui.setButtonYMax(height-100);                // max Y value for auto placement of buttons
  
  if (fullScreenDisplay)
  ui.setButtonOrigin(20,height-400);     
  else
  ui.setButtonOrigin(20,500);                  // button origin (screen coords)
 
  ui.setButtonWidth(140);
  ui.setButtonHeight (30);
  ui.setRowHeight(40);        // current auto placement row increment
  ui.setColWidth(160);        // current auto placement col increment 
  ui.setDeltaColRow(0,1);     // button creation auto advance direction. In this case down the page (row increment)
  
  ui.gotoCol(1);              // go to top of col 1
  
  // # before first char highlights key command
  // white space OK in btnc commands
 
  ui.setVisibleGroups(12);
   
  
  ui.group(1);
  ui.btnc("#Help","H -  Help, Repeat click of [Help] to cycle through help pages");  // button label/command , hint text 
  cbSensorsVisible = ui.checkBoxc("Sensors Vis",showSensors,"Sensors Visible");
  cbPanel1Visible = ui.checkBoxc("#User Panel1",userPanel1Visible,"U - User Panel1 toggle visibility");
  cbTimeWarp = ui.checkBoxc("#TimeWarp",timeWarp,"T - Toggle Time Warp - Simulation Step Accelerator");
  ui.group(2);
  cbLoopMode = ui.checkBoxc("#Loop",loopMode,"L - Loop mode toggle for Lap contest or Auto finish detect run");
  ui.gap();
  
  ui.group(2);
  ui.btnc("#Go","G - Go, run in non-contest mode, allowed to save state, move robot... ");
  ui.btnc("#Stop","S - Stop robot, turn off Controller"); 
  ui.gap();
  ui.btnc("#Run Contest","R- Run contest in 'Contest Mode' from default location or last clicked marker.");
 
 
   
  ui.gotoCol(2); // move to top of column based on column width,height.. 
   
  ui.group(1);
  ui.btnc("RotateCourse","ALT - Rotate course 90 degrees, toggle"); 
  ui.btnc("View Select","TAB - View toggle course and robot view, vs sensor and User Panel2");
  ui.btnc("Dim Course","Cycle course dimming");
  ui.btnc("Dim Robot","Cycle robot view (and sensor view) dimming");
  ui.btnc("Freeze","SPACE - Toggle simulation Freeze. Also 1..9 throttle step speed, 0 Single Step");
  ui.gap();
  
  // controls in group 2 which are to be hidden when running contest   
  ui.group (2);
  ui.btnc("#EraseCrumbs","E - Erase cookie crumb trail. Done automatically on Run or Go");
  ui.btnc("Course Select","Ctrl-C  Course Selection. Repetitive press to cycle through courses defined in UserInit");
  boolean c = lfs.controllerIsEnabled();
  cbController = ui.checkBoxc("#Controller",c,"C - Controller ON/OFF, when off repetitive arrow key press and < > to drive.");

 
  ui.group (1);  // these controls visible always (except when user controls are displayed)  
  ui.gotoCol(3);
  ui.setButtonWidth(100);
  ui.setColWidth(110);
  ui.btnc("KeyMenu","Switch to Key Command Menu, Press CTRL-G to turn GUI controls back on");  // GUI Mode
  ui.btnc("#ParamEdit","P - Parameter Editor Dialog display (then click [X] to hide)");
  btnMute = ui.btnc("Mute","Q - Toggle Audio Mute. Button label changes to UnMute while muted");
  
  ui.group(2);
  ui.btnc("User","Hide all buttons and display user buttons ");
  ui.btnc("#Marker","M - Marker place/erase  When stopped, location marker, when running via Go, state save marker.");
  ui.btnc("GoMarker","Go until near marker using timeWarp then clear timeWarp & freeze, then, for example, press 1..9 to proceed, or 0 to single step");
 
 
  ui.group(3);     // control button, displayed while contest running -- end the contest
  ui.gotoCol(3);
  ui.gotoRow(7);
  ui.label("Contest Run In Progress");
  ui.btnc("End","End Contest Run. Stopping Robot, allowing for choice of appending to contest Report, or cancel.");
  
  ui.setColWidth(160); 
  
  ui.group(4);    // controls available after contest run End button pressed 
  ui.gotoCol(2);
  ui.gotoRow(7);
  ui.label("Before continuing, choose");
  ui.gotoCol(3);
  ui.gotoRow(6);
  ui.gap();
  ui.btnc("Report","AKA F- Finish, Append contest run data Report /data/contest.cdf and record screen capture image.");
  ui.gap();
  ui.btnc("Cancel","X - Do not record contest run data");
 
  ui.group(5);
  ui.setButtonWidth(140);
  ui.setButtonHeight (30);
  ui.setRowHeight(40);        // current auto placement row increment
  ui.setColWidth(160);        // current auto placement col increment 
  ui.setDeltaColRow(0,1);     // button creation auto advance direction. In this case down the page (row increment)
  
  ui.gotoCol(1);              // go to top of col 1
  
  userSetupUI();              // group 5 user buttons 
 
  println (String.format("uiSetup : %d controls (buttons & checkboxes) defined",ui.buttons.size()));
 
}  // end uiSetup  

/* Button Command Decoder

   Each button generates a command character string  which is decoded here.
   For this application a variant of button coding has been used where the button command string is 
   the same as the button label. This does include # if used  e.g. "#Help" button when clicked will be presented
   as curButton to a series of if statements. 
    
*/



void uiUpdate()   
{
  UIButton curButton = ui.update();   // draw buttons and return button reference if clicked, else null 
  if (curButton == null) return;    
  
  // decode button command, where at least in this program the command and button label are the same.
  // The program will detect if a defined button does not have an associated if ()  decoding it.
  // that is for every button or checkbox, there should be a matching if (ui.cmd("buttonName")) below.
   
  //println (String.format("ui.cmd [%s] ",curButton.cmd));
 
  ui.beginDecode(curButton);  // set up ui.cmd 
 
  if (ui.cmd("KeyMenu")) guiMode = false;
  if (ui.cmd("#ParamEdit"))
  { decodeKey ('P');
    println ("P command ");
  }
   
  if (ui.cmd("#Help")) decodeKey('H'); // help cycle 
  if (ui.cmd("#TimeWarp")) commandTimeWarp(curButton.checked,false);  // set timeWarp to checkbox state, false not silent
  if (ui.cmd("#Loop")) decodeKey('L');                                // handles toggle if possible 
  if (ui.cmd("#User Panel1")) decodeKey('U');                         // U=toggle panel visble check box
  if (ui.cmd("Sensors Vis"))
  { showSensors = curButton.checked;
  
  }
  
  if (ui.cmd("#Run Contest"))
  { if (!lfs.contestIsRunning())
    {
      decodeKey('R');
      if (lfs.contestIsRunning())
      {
       ui.setVisibleGroups(13);
      }
    } else playBadKeySound();
    
   
  }
  if (ui.cmd("#Go"))  decodeKey('G');
  if (ui.cmd("#Stop")) decodeKey('S');
  
  if (ui.cmd("#EraseCrumbs"))  decodeKey('E');
  if (ui.cmd("Course Select")) decodeCtrlKey('C'); // Ctrl-C
  if (ui.cmd("RotateCourse"))  { rotate90 = !rotate90;}
  if (ui.cmd("View Select"))   decodeKey (TAB);
 
  if (ui.cmd("Dim Course")) dimCourseViewIndex++;    // D - Dim  cycles brightness (sineusoid increment...)
  if (ui.cmd("Dim Robot")) dimRobotViewIndex++; 
    
  if (ui.cmd("#Controller")) decodeKey('C');
  if (ui.cmd("Mute")) decodeKey ('Q');
  
  if (ui.cmd("#Marker")) decodeKey ('M');
 
  if (ui.cmd("Freeze")) if (!lfs.contestIsRunning()) decodeKey (' ');
                       else decodeKey('0');
 
 
  if (ui.cmd("End"))
  { decodeKey(' ');              // if key command issued without "End" click, notification is needed  
    uiContestEnded();            // so, code was added to call uiContestEnded()
    // ui.setVisibleGroups(14);  // this done by uiContestEnded
  }
 
  if (ui.cmd("Report")) 
  {  decodeKey ('F');                 // generate report, and calls  uiContestComplete()          
     // ui.setVisibleGroups(12);      // decode F takes care of this 
  }
  
  if (ui.cmd("Cancel")) 
  {  decodeKey ('X');
     // ui.setVisibleGroups(12);      // decode X takes care of this 
  }
  
  if (ui.cmd("User")) ui.setVisibleGroups(5);
 
  if (ui.cmd("GoMarker")) 
  { freezeNearMarker = true;
    freezeNearMarkerMinDist = 99; 
    simSpeed = 9;
    commandTimeWarp(true,true);  // set timeWarp, silent 
    decodeKey('G'); 
  }
 
  userDecodeUICommands(curButton);
   
  if (!ui.endCmdDecode())
    println ("Error: No if (ui.cmd(\"" +curButton.cmd+ "\")) statement found to execute button command,"+
             "check uiUpdate or userDecodeUICommands in UMisc");
   
 
   
  // !!! to do speed and arrow commands or just annotate display  
 
 
  /*
  if (cmd("F")) robot.changeSpeed(1.0);
  if (cmd("R")) robot.changeSpeed(-1.0);
  if (cmd("TL")) robot.heading -= 5.0;
  if (cmd("TR")) robot.heading += 5.0;
  if (cmd("SL")) robot.changeSidewaysSpeed (-1);
  if (cmd("SR")) robot.changeSidewaysSpeed (1);
  
  if (cmd("Stop")) robot.stop();
  if (cmd("SingleStep"))
  { 
    if (simSpeed==0) simRequestStep = true;
  }
  
  if (cmd("0")) simSpeed = 0;
  if (cmd("1")) simSpeed = 1;
  if (cmd("2")) simSpeed = 2;
  if (cmd("4")) simSpeed = 3;
  if (cmd("10")) simSpeed = 6;
  if (cmd("60")) simSpeed = 9;
  */
  
  
}

void uiContestEnded() { ui.setVisibleGroups(14); }     // display prompt for report or cancel 
void uiContestComplete() { ui.setVisibleGroups(12); }  // display default controls
