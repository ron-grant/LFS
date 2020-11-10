/* UMisc  - Optional Miscellaneous User Methods  



   userMiscSetup()                     called from setup at program startup
   userMiscUpdate()                    called every draw (e.g. 30 to 60 times per second)
   
   userLapDetected()                   called when lap detected (crossing close to start location)
   userStartedRun()                    called when user presses G)o or R)un
   userStop()                          called when S pressed  
   userInBounds()                      called if robot in course bounds, either this or userOutOfBounds called every draw
   userOutOfBounds()                   called if robot outside course bounds
   userFinishLineDetected()            called when your controller believes it has have crossed the finish line (Challenge Course)
                                          for now stops contest run, could add sound effects... 
                
   userMarkerPlaced(placed);           called when a new marker placed or removed  
                                       
   userMarkerClicked();                called when robot jumps to old marker
                                      
                            
   userSetupUI()                                 new GUI button / checkbox support               (lib 1.6)         
   userDecodeUICommands(UIButton curButton)      user demo methods that can be modified.. 


   userOutOfBounds method called by LFS when robot runs off the edge of a course image.
   If a contest run was in progress it is automatically stopped.
   The method should be defined, but can be empty.
  
   In code movedto LFS_M, a simple demo was created that generates an explosion sound along with rotating
   scaling and fading out icon.
    
*/

  SoundFile sampleSound;            // example user sound file 

  void userLoadSoundFiles() {
     sampleSound = soundInit("tadaSound.mp3");   // example sound file loaded here 
                                                 // playSound(sampleSound,0.5);  example method call soundName,volume 0.0 to 1.0
                                                 
  }  
  
    
  void userMiscSetup() {}   // called from setup at program startup
   
  void userMiscUpdate() {}   // this method called every draw 

  void userLapDetected() {}
 
  void userStartedRun() {   }       // called when R)un or G)o command issued (lib 1.4.2)

  void userStop() {
   // additional actions to take when stop command issued.
   // no code here (trike demo uses to zero its drive wheel speed which is fed to LFS)
   //trike.wheelVelocity = 0.0;              // additional actions to take when S)top command issued        (lib 1.4.3)
   // currentRobotState.wheelVelocity = 0;   // at present controller disabled and robot commanded to stop
  }                                   
    
  void userFinishLineDetected() {  }   // user thinks they crossed finish line, LFS handles stop, cheers...
                                     // controller should call lfs_FinishLineDetected method
 
  void userInBounds() {}          // complimentary call to userOutOfBounds

  void userOutOfBounds ()  {}    // LFS_M code handles stopping ..  

  void userNewMarkerPlaced(boolean placed)  {}   // called when a new marker placed, LFS handles save state...
  void userMarkerClicked() {}  // optional user method. Note LFS is taking care of state save/restore 
                             // see UserReset tab header. Also see LFS_RS.
                             
                             
// --------------------- EXAMPLE USER BUTTON / CHECKBOX DEFINITIONS ---------------------------------------------------

UIButton cbUser1;
UIButton cbUser2;

void  userSetupUI()
{
   ui.group(5);    // controls defined here are group 5,  the LFS button "User" sets this group for display
   ui.gotoCol(1);   
   ui.setButtonWidth(140);
   ui.setColWidth(160); 
  
   ui.label ("User Controls");
   
   // some user buttons, if you change label, change also in userDecodeUICommands method below
   // Also, labels for ALL buttons must be unique. See LFS_G Tab for LFS Buttons/Command definitions 
   
   ui.btnc("UserB1","Sample User button 1, see userSetupUI in UMISC tab"); 
   ui.btnc("UserB2","Sample User button 2, see userSetupUI in UMISC tab");  
   ui.btnc("UserB3","Sample User button 3, see userSetupUI in UMISC tab");
   ui.gap();
   
   cbUser1 = ui.checkBoxc("UserCheck1",false,"Sample User Check Box 1, see userSetupUI in UMISC tab");
   cbUser2 = ui.checkBoxc("UserCheck2",true,"Sample User Check Box 2, see userSetupUI in UMISC tab");
   
  
   ui.label("LFS Control View");
   ui.btnc ("Show LFS","Make LFS buttons/checkboxes visible & hide user buttons/checkboxes");
   
   
}

// --------------------- EXAMPLE USER BUTTON / CHECKBOX COMMAND DECODE ----------------------------------------

void userDecodeUICommands(UIButton curButton)
{
   if (ui.cmd("Show LFS")) ui.setVisibleGroups(12);  // button must be handled, returns control to LFS
                                                     // showing groups 1 and 2
   
   
   color c = color(0,255,0); // GREEN rgb color used for bigMessage calls below 
   
   if (ui.cmd("UserB1")){
     bigMessage ("User Button 1 Pressed",c);
     playTada();
   }
   if (ui.cmd("UserB2")){ bigMessage ("User Button 2 Pressed",c); playTada(); }
   if (ui.cmd("UserB3")){ bigMessage ("User Button 3 Pressed",c); playTada(); }
  
   if (ui.cmd("UserCheck1"))
   { if (curButton.checked) bigMessage ("User Checkbox 1 checked ",c);
     else bigMessage ("User Checkbox 1 unchecked",c);
     // note cbUser1 is a reference to this checkbox defined when the checkbox was defined
     // this reference can accessed elsewere  cbUser1.checked  or you could assign 
     // to your own variable here 
     
   }
    
   if (ui.cmd("UserCheck2"))
   { if (curButton.checked) bigMessage ("User Checkbox 2 checked ",c);
     else bigMessage ("User Checkbox 2 unchecked",c);
   }
 
  
}
