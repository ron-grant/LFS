 /*
  Few changes made to Will's Trike code  for 1.3
  
  For 1.4
  Very minor change to UserInit - see bottom of file to support course icon.
  Robot view,Sensor view image NOT USED as is done in LFS_SampleBot
  
    Important change to LFS_Key
    
    decodeKeysTrike  (key,keyCode);  // method moved to  UKey  
    
    if (keyCode ==  UP)   lfs.changeTargetSpeed(1.0f);
    if (keyCode == DOWN)  lfs.changeTargetSpeed(-1.0f);
    if (keyCode == LEFT)  lfs.changeTargetTurnRate(-11.25f);
    if (keyCode == RIGHT) lfs.changeTargetTurnRate(11.25f);
  
    IMPORTANT ADDITION TO LFS_TrikeBot  Main Tab -- added else clause below 
    
    if (lfs.controllerIsEnabled())    // if turned off, no update.
       userControllerUpdate();         // user reads sensors changes target speed and turn rate as needed.
    else                     // !!!
       trikeDriveUpdate ();  // !!! ADDED FOR TRIKE  allow for manual drive 
  
  
      
    Added some Tabs (broke out controller into UserSensor and UserTracking
    
    UserCon       -- existing Controller tab including  
    UserDraw      -- draw over top robot view with trike schematic 
    
    uSensor    -- low level sensor code
    uTracking  -- state estimator
    uTrike     -- trike class - low level code 
    

    lfs.setTargetSpeed     replaces old robot.setSpeed
    lfs.setTargetTurnRate  replaced old robot.setTurnRate

    now line sensor uses different read method name   lineSensor1.readArray()  
    versus old read() 
    
    new method of creating spot and line sensors for example:
        spotL = lfs.createSpotSensor (1.125, -1.5, 15, 15);
        line1 = lfs.createLineSensor (1,1,15,15,64);
        
        
    void userControllerUpdate()  - dropped reference to Robot
        
    void userControllerResetAndRun()  -- required to implement this method 
                                         executed at start of code
                                         
     
    in userInit() method - new additions   see UserInit tab for more comments  
    
    lfs.setFirstNameLastNameRobotName("Will","Kuhnle","Trike");   
    lfs.setCourse("DPRG_Challenge_2011_64DPI.jpg"); 
    lfs.setPositionAndHeading (71.7,120,0);    // initial position over DPRG logo
 
    lfs.setAccRate(0.5);     // acceleration rate (inches/sec^2)  
    lfs.setDecelRate(32);    // deceleration rate (inches/sec^2)  
    lfs.setTurnAcc(720);     // turn acceleration and deceleration rate  (degrees/sec^2) 
    lfs.setMaxSpeed(16);     // inform lfs of your max speed *
    lfs.setMaxTurnRate(720); // inform lfs of your max turn rate (degrees/sec)
 
 
 */
