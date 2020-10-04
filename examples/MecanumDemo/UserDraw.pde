/* UserDraw - optional user draw overlay on top of robot view

   userDraw can be empty or code commented out
   if no robot overlay geometry needed

*/

void userDraw()
{
  lfs.setupUserDraw();       // sets up transforms origin robot center scale inches
  lfs.drawRobotCoordAxes();  // draw robot coordinate axes 
  
  strokeWeight(4.0f/lfs.courseDPI);                // line thickness in pixels 
  stroke (color (255,0,255,180));  // r,g,b,alpha (0=transparent ... 255= opaque)
  noFill();
  rectMode(CENTER);
  rect(2.5f,-2.5f,2.5f,0.5f);
  rect(2.5f, 2.5f,2.5f,0.5f);
  rect(-2.5f,-2.5f,2.5f,0.5f);
  rect(-2.5f, 2.5f,2.5f,0.5f);


  // draw circles -- newest version of processing supports "circle" method
  ellipseMode(CENTER);
  ellipse(0,0,12,8);

}
