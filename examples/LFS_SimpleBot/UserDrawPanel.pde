/* UserDrawPanel - draw info onto screen 
*/
  void userDrawPanel()  // called from draw() at frame rate
  {
    
    //------------------------
    // display status info at top of screen

    int alpha = panelDisplayMode*127;  // display panel opacity 0% 50% 100%  controlled by pressing P
    stroke (240);
   
    int panelPosY = 700;

    translate (850,panelPosY);  // position panel, default is 0, ron places near bottom of screen
                              // by setting panelPosY in ronInit() method.
    
    fill (0, 0, 50, alpha);   // dark gray, alpha transparency  
    rectMode (CORNER);
    
    rect(20, 20, 720, 130);
    
    
    fill (240, alpha);      // color,alpha transparency 50%
    textSize (20);
    String cs = lfs.controllerIsEnabled() ? "ON" : "off";
    String fs = simFreeze ? "ON" : "off";
    
   
    

    //controller %s simSpeed %d freeze %s", 
    //  robot.x, robot.y, robot.heading, robot.speed, cs,simSpeed,fs), 30, 40);
      
    //String ts = 
    //text (ts+"con "+cs,30,190);

    
      if (lfs.controllerIsEnabled()) text(keySummaryConOn,30,80);    // see KeyInput tab  
      else text(keySummaryConOff,30,80);
    
    
    text ("hold right mouse button down and drag horz. to change heading",30,100);
    text ("hold left mouse button down and drag to change position",30,120);

    if (!focused)  // if window does not have focus, indicate that fact to user
    {
      pushStyle();
      fill (255, 70, 70);   // pale red
      text ("Click in application window to give focus for key command response", 30, 140);
      popStyle();
    } else text ("Tab - toggle couse/robot view  ALT-rotate90  P)anel visibility", 30, 140);
  }    
  
