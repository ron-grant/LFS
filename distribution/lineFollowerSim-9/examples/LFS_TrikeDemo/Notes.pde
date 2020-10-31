 /*
 
 
  Few changes made to Will's Trike code  for 1.3
  
  Note: Now acheived ability to update user program by overwriting with updated LFS_ files.
  
  For example copying the following files from LFS_SampleBot sketch to your sketch
  and then deleting your LFS_TrikeDemo.pde and renaming LFS_SampleBot.pde to LFS_TrikeDemo.pde
  should update your sketch. All your code is preserved.
  
  LFS_SampleBot.pde       (now skeleton of sketch - goal is this file typically won't change after 1.5 )
  LFS_Key.pde     
  LFS_M.pde               (was the old "main tab" with the core of the app that runs user code)
  LFS_Panel.pde
  LFS_Par.pde   
  LFS_RS.pde
  
  In the future, if no changes to skeleton code. An update would require copying just the last 5 files with no need 
  to overwrite skeleton (now main tab of sketch). Remember that the main tab is the one with a file that defines the 
  name of the sketch and must match the name of the folder that contains it.
    
     
  For 1.4
  
  Very minor change to UserInit - see bottom of file to support course icon.
  Robot view,Sensor view image NOT USED as is done in LFS_SampleBot
  
  LFS_Key now does call to  userArrowKeyDecode before decoding arrow keys itself
  This new method (in UKey tab) allows Trike drive commands affecting speed and wheel angle to be used
  
        
    Added some Tabs (broke out controller into UserSensor and UserTracking
    
    UserCon       -- existing Controller tab including  
    UserDraw      -- draw over top robot view with trike schematic 
    
    uSensor    -- low level sensor code
    uTracking  -- state estimator
    uTrike     -- trike class - low level code 
    


    lfs.setTargetSpeed     replaces old robot.setSpeed
    lfs.setTargetTurnRate  replaced old robot.setTurnRate

   
    line sensor uses different read method name   lineSensor1.readArray()  
    versus old read() 
    
    new method of creating spot and line sensors for example:
        spotL = lfs.createSpotSensor (1.125, -1.5, 15, 15);
        line1 = lfs.createLineSensor (1,1,15,15,64);
        
        
    void userControllerUpdate()  - dropped reference to Robot
        
    void userControllerResetAndRun()  -- required to implement this method 
                                         executed at start of code
                                         
     
    In UserInit tab - new additions   (see the tab header for more info)
       
       * new code to specify list of courses available and which one to choose
       * code that specifies acceleration rates and max speed 
       * code that specifies an icon to load OR to generate with user initials
       
       
   Look for Trike arrow key decoder at end of UKey
  
   Lib 1.5 introduces ability of program to save robot state on a G)o initiated run.
   See userReset tab comments.
 
 
 
 */
