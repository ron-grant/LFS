/* UserDraw - optional user draw overlay on top of robot view

   userDraw can be empty or code commented out
   if no robot overlay geometry needed

   Image overlay supported Lib 1.3.1
   See UserInit where icon is defined and loaded.

*/


PImage bigIcon;     // this variable should be defined for use by userDraw method. Moved here (lib 1.4.2)
                   
                   
boolean showUserDraw = true; // set false to eliminate user drawing

void userDraw() 
{
  if (showUserDraw == false) return;    
  
  if (courseTop) lfs.setupUserDraw();      // sets up transforms origin robot center scale inches for Robot view
  else lfs.setupUserDrawSensorViewport();  // ... for SensorView
     
  lfs.drawRobotCoordAxes();  // draw robot coordinate axes 
  
  // sample code that draws robot components using Processing drawing functions 
  // assume, use if robotBigIcon not defined, see UserInit 
  
  if (bigIcon == null)
  {
    strokeWeight(4.0f/lfs.courseDPI);                // line thickness in pixels 
    stroke (color (255,0,255,180));  // r,g,b,alpha (0=transparent ... 255= opaque)
    noFill();
    rectMode(CENTER);
    rect(0,-2.5f,4,0.5f);
    rect(0, 2.5f,4,0.5f);
  
    // draw circles -- newest version of processing supports "circle" method
    ellipseMode(CENTER);
    ellipse(0,0,8,8);
    ellipse(-2,0,2,2);
     
    stroke (color(0,0,255,180));
    line(0,-3,0,3);
  }  
  else // bigIcon defined
  { 
    // Display bigIcon if defined, see User Init
    
    rotate (PI/2);              // robot coordinates place +X up need to right +Y down
    imageMode(CENTER);          // center image at x,y 
    tint (255,40);             // 255,alpha   alpha param 0..255   0=transparent 255=opaque
    image (bigIcon,0,0,10,10);  // x,y,width,height     width=height= 10 inches  
    tint (255,255);             // restore opaque tinting 
    imageMode(CORNER);          // important to restore corner mode for proper image display elsewhere            
  }
  
}
