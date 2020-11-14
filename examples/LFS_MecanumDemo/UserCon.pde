/* UserCon - user controller code, read sensors, possibly decode features, update speed and turn rate

   A challenge course controller will most likely need a much better line detector than
   presented here. Consider scrapping this one and writing one that includes ability to detect
   multiple line intersections. Also, changes in course polarity (white lines on black...)
   could be detected OR you could go with edge detection approach...
    
   The PD controller implemented here is good enough for the advanced course, but
   you will probably want to think about how to handle all the special patterns present in challenge
   course. (If you are trying to solve the DPRG Challenge Course)
   
   
*/

float ePrev;      // global previous error 

float Kp;         // PD Controller parameters  see UserParEdit 
float Kd;

float maxSpeed;

String controllerMessageString = ""; // message that gets displayed on Panel 1
                                     // see code below that populates this string 


void userControllerUpdate ()    
{
    
  // A new, optional feature of LFS (lib 1.4.4), is to provide means of saving robot 
  // state variables when robot is running in non-contest mode and a marker is created.
  // See LFS_RS tab header for more information.
  
  
  //RobotState cs = currentRobotState;  // get shorthand reference to current state
                                        // note this is not a "new" instance. 
  //cs.sampleCounter = 1;               // example access to current RobotState with short name.  
                                        // This is also done in userReset.
                                        
                                        
  
  // your robot controller code here - this method called every time step
  // crude attempt to control velocity as function of current centroid error 
  
  float[] sensor =  sensor1.readArray();   // readArray() returns reference to sensor array of floats 
  
  float e = calcSignedCentroidSingleDarkSpan(sensor) ;   //error in pixels of line intersection with sensor
  
  
  // Added example code of accessing line sensor color table and modifying it for display ---------
  // This code is for display only, no impact on robot run
    
  int[] colorTable = sensor1.getColorArray();  // get reference to sensor color table
  int n = sensor1.getSensorCellCount();
  for (int i=0; i<n; i++) 
  {
    color c =  color (0,0,50); // dark blue
    if ((i > n/2-e-3) && (i < n/2-e+3)) c = color (255,0,0); // red 
    colorTable[i] = c;
  }
  
  // // update sensor colors on spot sensors even though not used in this demo
  
  // if (sensorL.read() > 0.5) sensorL.setColor (color(0,0,100));
  // else sensorL.setColor(color(255,0,0));
 
  // if (sensorM.read() > 0.5) sensorM.setColor (color(0,0,100));
  // else sensorM.setColor(color(255,0,0));
 
  // if (sensorR.read() > 0.5) sensorR.setColor (color(0,0,100));
  // else sensorR.setColor(color(255,0,0));  

  // // -------------------------------------------------------------------------------------------

  controllerMessageString = String.format("sensed line position error %3.1f",e);  // displayed by UPanel code

 

// note you can dynamically change sensor positions if you wish
// in this example sensor radius is varied - just to show it can be done
// now, commented out here
// sensor1.setRotation(10);  // now theta
//sensor1.setArcRadius(1.0+ (frameCount%100)/100.0);
//sensor1.setRotation (90*mouseX/width);

// generally your robot will up updating TargetTurnRate and possibly TargetSpeed

// lfs.setTargetTurnRate(-e * Kp + (e - ePrev) * Kd);   // turn rate in degrees per second

// this works good for offsets
// might need tp turn too???

lfs.setTargetSidewaysSpeed( 0.1*(-e * Kp + (e - ePrev) * Kd) );   
ePrev = e;  

// handy to disable set target speed and manually change 
// note: in this case start in non-contest mode.

//lfs.setTargetSpeed(1.0 + abs(12.0f/(abs(e/2.0f)+1.0)));   

lfs.setTargetSpeed (maxSpeed);


}

//very simple line detector, given sensor array from line (or 1/2 circle) sensor
//you will probably want to enhance the line detector if you are creating a challenge course robot

float calcSignedCentroidSingleDarkSpan(float[] sensor)  // 0=line centered under sensor array  + to right , - to left
{

int n = sensor.length; // total number of sensor samples

// calculate centroid of single black line 

float sum = 0;
int count = 0;
float centroid = 0;
for (int i=0; i<n; i++)
if (sensor[i]<0.5) { sum+= i;  count++; }
if (count>0)
centroid = (0.5*n)-(sum/count);  // make centroid signed value  0 at center

return centroid; 
}
