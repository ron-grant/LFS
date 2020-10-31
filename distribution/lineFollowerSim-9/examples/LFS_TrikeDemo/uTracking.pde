/* uTracking - Trike State Space Controller 
   Will Kuhnle  Sept 2020
  
   These methods defined here:
   
   trackingUpdateInit()
   trackingUpdate( int y, float dt)
  
  
  
   trikeDriveUpdate was here, moved to end of UserCon
    
*/   


//----------------------------------
  //float x1_h = 0;      // estimated distance from path tangent to robot, inches
  //float x2_h= 0;       // estimated angle from path tangent to robot heading, radian
  // see trackingUpdateInit 
  
  
  float errorRate = 0;
  float uErrorRate;
  float uCurvature;
  
  float uError;      //  p component of plant input, robot.steerAngleR
  
  //float theta_pR;  // unused 
  
  float b2 = -0.25;            // 1 / robot.wheelBase; // element of B matrix (2x1), b1 = 0
  float k1=0.36 , k2=0.846;    // estimator gains, elements of K matrix (2x1)
  float c1_h = 12.8;           // estimator C matrix (1x2), c2_h = 0
  //float c1 = 12.8;           //  C matrix (1x2), c2 = 0
  float g1 = 1.2, g2 = 2.0;    // state feedback gains, G matrix (1x2)


void trackingUpdateInit()   // reset low-level controller 
{
  RobotState cs = currentRobotState;  // get shorthand reference to current state
  
                    // set initial values inside RobotState (see: UserReset)
  cs.x1_h = 0;      // estimated distance from path tangent to robot, inches
  cs.x2_h = 0;      // estimated angle from path tangent to robot heading, radian
 
}


void trackingUpdate( int y, float dt)
{
  RobotState cs = currentRobotState;  // get shorthand reference to current state
  
  float x1_h = cs.x1_h;   // copy from currentRobotState 
  float x2_h = cs.x2_h;   // then copy back at end of method, eliminating cs. clutter
  
  
  float dSw = trike.wheelVelocity * dt;
  float dSr = dSw * cos(trike.steerAngleR);
  float y_h = c1_h * x1_h;
  float residual = y - y_h;
  float dx2_h = residual * k2 - b2 * trike.steerAngleR;
  float dx1_h = residual * k1 + x2_h;
  x1_h += dx1_h * dSr;
  x2_h += dx2_h * dSr;
  float u1 = g1 * x1_h;
  float u2 = g2 * x2_h;
  uError = u1;         // used in  DrawWorld
  
  //theta_pR = x2_h;   // used in main? -- unreferenced var removed  rg 10/28/2020
  
  trike.steerAngleR = u1 + u2; // = - u
  if (trike.steerAngleR > 1.0 ) trike.steerAngleR = 1.0;
  if (trike.steerAngleR < -1.0 ) trike.steerAngleR = -1.0;
  
     //println (" steer ", trike.steerAngleR);
     
     
     //println("*** %4.2 %4.2 %4.2", sensorRun[0][0], sensorRun[1][0], sensorRun[2][0]);
    // println(c, error, errorRate, delT,"***", sensorRun[1][0] );
    
   
  cs.x1_h = x1_h;   // update current robot state, which stores these values
  cs.x2_h = x2_h;
    
    
} // tracking Update()
//-------------------------------

// trikeDriveUpdate method  was here, moved to end of UserCon
