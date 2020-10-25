/* UPanel   (UserPanel)                        Revised for library 1.4.0 
   
   Now, only user drawing code appears in this tab. LFS "panel" drawing performed in LFS_Panel
   which includes Help and Command Summary panels.
   
   In addition LFS defines a new Parameter panel handled by LFS_Par.
   
   
   This tab is expected to implement two methods.
   The methods can be empty, forefitting the drawing of user panel data.
   
   No code should be placed in the user methods which is expected to run every frame as LFS
   does not call the methods in certain circumstances.
   
   userDrawPanel1  - called when Parameter display is not visible - it uses the same X extents 
                     as the parameter display and the same Y extents as the command summary panel
   
   
   userDrawPanel2  - The big panel - 
                     called when course hidden (via TAB key), when help is not visible and 
                     also when LFS window has focus (Click on Window to give focus message visible).
   
   
   On entry to the userDrawPanelX method, a reference to the vieport position can be accessed with
   selectUserPanelX method. (X= 1 or 2)
   
   All coordinates specified in the userDrawPanelX method are relative to the viewport.
   That is point(0,0) would display point in the upper-left corner of the viewport (panel).
   
   Basic sample code is provided, which can be replaced with your own..  OR
   just set showUserPanelX variables to false to blank the display of the panels.
    
*/



void userHandleMouseClick() {   // generally leave empty unless you want to decode 
                                // mouse clicks related stuff
                                
  println (String.format("userHandleMouseClick called  %d,%d ",mouseX,mouseY));
}

boolean showUserPanel1 = true; // set false to blank display of user Panel 1
boolean showUserPanel2 = true; // set false to blank display of user Panel 2
                               // noting that it is only visible normally when course not displayed 

boolean userPanel1Visible = true;  // toggled by U key  (lib 1.4.2)

void userDrawPanel1()          // Panel located in same location as Parameters, called only when 
                               // parameters not visible
{
  if (showUserPanel1 == false) return; // hide user drawing
  if (!userPanel1Visible) return;
  
  VP panel = selectUserPanel1();
  
  // if drawing commented out panel will not be visible 
        
  stroke (0,200,0);
  fill (0);
  rect (0,0,panel.w-1,panel.h-1);  // sample green box extents of viewport 
  
  fill (240);        // text color (gray level if single value vs RGB)
 
 
  textSize (16);  // suggest 18 to 22 for more readable text 
  int ypos = 30;
  text ("UPanel userDrawPanel1",20,ypos);
  ypos += 26;
  // text ("when parameter editor not displayed.",20,ypos);
  ypos += 30;
  //text ("Set showUserPanel1 to false, if not using.",20,ypos); 

  
  
  
  
}



void userDrawPanel2()  // Panel located where help is displayed, but only visible when 
                       // course hidden via TAB key toggle   
{
  // caller setup coordinate origin 0,0 to upper left corner of this view panel
  
  if (showUserPanel2 == false) return; // blank display of panel if false
    
  VP panel = selectUserPanel2();  // reference to window located where help area is, but 150 pixels shorter
  
  // viewport (panel) is not clipped 
    
  stroke (0,200,0);
  fill (0);
  rect (0,0,panel.w-1,panel.h-1);  // sample green box extents of viewport 
  
  float ypos = 25;  // Initial y position of text 
  float alpha = 1.234;
  int beta = 567;
  
  textSize (22);
  fill (240); // text color 
  text ("userDrawPanel2  drawing performed in this method is only visible when course",20,ypos); 
  ypos += 30;
  text ("turned OFF via TAB",20,ypos);
  ypos += 60;
 
  /*
  lfs.getMaxSpeed();
  lfs.getMaxTurnRate();
  lfs.get
  */
  
  
  text (String.format ("Sample Values  alpha = %1.4f  beta = %d ",alpha,beta),20,ypos);  
  
  
}
