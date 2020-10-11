/* UserDraw - optional user draw overlay on top of robot view

   userDraw can be empty or code commented out
   if no robot overlay geometry needed

*/

void userDraw()
{
  if (courseTop) lfs.setupUserDraw();   // sets up transforms origin robot center scale inches for Robot view
  else lfs.setupUserDrawSensorViewport();  // ... for SensorView
  
   
  lfs.drawRobotCoordAxes();  // draw robot coordinate axes 
  
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
