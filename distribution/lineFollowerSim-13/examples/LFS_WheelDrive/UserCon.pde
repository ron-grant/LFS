/* UserCon - user controller code, read sensors,  update motor speeds 

   Your robot controller code wull appear below in a Java method called userControllerUpdate()
  
   
   START OF LOOP
   
   1. LFS draws an image of robot surroundings based on where robot is and direction it is pointed
   2. LFS looks at your sensor definitions from UserInit notebook tab and makes them available to you
   3. Your code (code provided) copies sensor values into simple floating point variables called sL and sR
   4. Your code needs to decide how fast left and right wheels need to turn to drive the robot toward the line
      and to drive it forward by setting wL and wR (left and right wheel speeds)
      
   5. wL and wR are passed to a special method (or function) which 
      figures out how fast robot is moving forward and turning then gives that information to LFS 
   
   
   
   END OF LOOP (go back to step 1)
  
   
   
   
   userControllerUpdate ()  
  
   you must decide how fast to run left and right wheel motors, given your sensor data
  
  
   read the sensor data provided by LFS
   0.0 = black line 
   1.0 = white background 
   If sensor is part on the line and part off the line you will get a value in between 0.0 and 1.0 
 
   
*/


float speedTurn;     // these variables are adjusted with parameter editor. See UPar tab
float speedClear;    // speed to run motors when in the clear (both sensors white)

String controllerMessageString = "";  // messages that gets displayed on Panel 1
String controllerMessageString2 = ""; // see end of userControllerUpdate
String controllerMessageString3 = "";

float sensorSep;


void userControllerUpdate ()    
{
 
   
  
  
  float sL = sensorL.read();   // read left sensor into variable sL
  float sR = sensorR.read();   // read right sensor into variable sR
     
  // update sensor colors based on value. 
  
  if (sL> 0.5) sensorL.setColor (color(0,0,100));
  else sensorL.setColor(color(255,0,0));
  
  if (sR> 0.5) sensorR.setColor (color(0,0,100));
  else sensorR.setColor(color(255,0,0));  

  // define left and right wheel speeds
  // if both speeds the same and positive  the robot moves straight forward
  // if both speeds the same and negative the robot moves straight backwards 
  // if the speeds are opposite in sign the robot turns in place
  // if one wheel is faster than the other the robot drives with a curved path 

  float wL = 0;
  float wR = 0;

  // make sure controller is enabled by pressing G or toggling on with C key if off.
  // also 1..9 keys control simulation step rate and SPACE bar toggles FREEZE on/off
  
  if ((sL>0.5) && (sR>0.5))  // both Left AND Right sensor see white 
  {
    wL = speedClear;
    wR = speedClear;
  }
  
  if (sL<0.5) { wL = 0; wR = speedTurn; }
  if (sR<0.5) { wL = speedTurn; wR = 0; }
 
  String driveMsg = "Robot driving straight this lap";  
  
 int lapN = lfs.lapTimer.getLapCount(); // number of laps completed   
 if (lapN >= 2)
 {
   wL = wL * 1.1;  // slight error in robot wheel speed -- wont drive straight 
   driveMsg = "Left Wheel runs 10% faster than it should this lap";
 }  
   
 controllerMessageString  = String.format("Left Sensor %1.1f  Right Sensor %1.1f",sL,sR);  // displayed by UPanel code
 controllerMessageString2 = String.format("Wheel Speed  Left %1.1f  Right %1.1f ",wL,wR);
 controllerMessageString3 = String.format("Lap %d %s",lapN,driveMsg);
 
  
 float wheelSeparation = 3.0;  // wheel separation (inches) -- affects how fast the robot will turn
  
   
  updateRobotSpeedAndTurnRate(wL,wR,wheelSeparation);  // Method  (function) located in uWheelDriveLR that computes 
                                                       // what LFS wants to know, how fast is the robot moving
                                                       // and how fast is it turning, given wheel speeds and how far
                                                       // apart the wheels are.


  // dynamic sensor separation -- using Parmeter Editor
  // make sure Left is negative and right is Positive, got them reversed, robot did not do well
  sensorL.setYoff(-sensorSep/2.0);
  sensorR.setYoff( sensorSep/2.0);
  

 
 
 //your userControllerUpdate method is finished the program will now go to step 1 decribed in the top of this file.
 //That is, this method returns to LFS code that called this method.
}
