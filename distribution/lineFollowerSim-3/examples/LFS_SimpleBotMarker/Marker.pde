/*  Marker    Add/Remove starting location markers  which appear as magenta circles on course.
              Requires robot is not running contest (ideally stopped).
    
    Ron Grant
    October 8, 2020
    
    Click on contest course outside any existing marker circles and robot jumps to the location.
    Hold Left mouse button down and move to drag location, Hold down right button down and move
    the mouse horizontally to change heading.
    
    Press M to mark location (and heading), a magenta circle appears.
    
    Click on any marked location and robot jumps to that location and adjusts heading to match the 
    heading when marker created. Pressing M at this point erases the marker.
    
    Also, dragging robot to location near the center of a marker then pressing M will erase the marker.
       
    Markers are automatically loaded/saved in data folder in file with same name as course file,
    but with .mrk extension.  
        
    ----------------------------
    SimpleBotMarker has been modified with below instructions to support markers.
    Below are the instructions followed to modify original LFS_SimpleBot, i.e., loaded 
    LFS_SimpleBot, performed below, and saved as LFS_SimpleBotMarker
        
    Likewise, if you have already starting working on your controller and would like to add Marker support
    follow these instructions:
  
       
    Make sure you are running LFS library 1.0.3 or later
    (the release# appears in the console when you run your sketch)
    
    
    Optionally: Create a new Tab, Named Marker and add the comments that appear in this file 
    
    In UserKey tab, add below statement to keyPressed method after code to shift letters
    to uppercase.
     
     if (key == 'M') lfs.markerAddRemove();
     
    Also in UserKey tab, add the following method (if not already present in program) with
    first statement as shown, this will notify marker system when user has clicked mouse
     
    void mouseClicked()
    {
      if (lfs.markerHandleMouseClick()) return;   // markerHandleMouseClick returns true if clicked
                                                  // in a marker circle, then this mouseClick is considered 
                                                  // consumed, hence return
      // user / other mouse click handlers here  
    }
  
     
     
     
    
    In UserDraw userDrawPanel method insert add following line to start of method 
    
      lfs.markerDraw(); 
        
    In UserInit tab, Add the following to end of userInit method
    
     lfs.markerSetup(); 
    
    In UserReset userControllerResetAndRun() of LFS_Simplebot, remove or comment out
    following 2 lines:
    
    //if (courseNum == 2)
    //lfs.setPositionAndHeading (52,12,0); 
    
    add the following line
    
    lfs.setPositionAndHeading(startLocX,startLocY,startLocHeading);
    

    Run the sketch. Move the robot somewhere interesting, rotate it to desired heading,
    press M key and magenta circle should appear.
 
 
 
    End of Marker Tab - comments only, all code included in lineFollowerSim library
  
*/
