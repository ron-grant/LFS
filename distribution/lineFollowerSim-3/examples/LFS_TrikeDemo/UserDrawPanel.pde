  
  void userDrawPanel()  // called from draw() at frame rate
  {
    lfs.showSensors((courseTop)?'R':'S');    // show user colorable sensors (lib 1.3)
    if (courseTop) lfs.markerDraw();         // only display markers when course visible (lib 1.3)
    
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

    text(keySummary1,30,60);    
    if (lfs.controllerIsEnabled()) text(keySummaryConOn,30,80);    // see KeyInput tab  
    else text(keySummaryConOff,30,80);
    
    
    text ("right mouse button down, drag horz. to change heading",30,100);
    text ("left mouse button down, drag to change position",30,120);

    if (!focused)  // if window does not have focus, indicate that fact to user
    {
      pushStyle();
      fill (255, 70, 70);   // pale red
      text ("Click in application window to give focus for key command response", 30, 140);
      popStyle();
    } else text ("Tab - toggle couse/robot view, Alt-Rotate  P)anel visibility", 30, 140);
  }    
  
