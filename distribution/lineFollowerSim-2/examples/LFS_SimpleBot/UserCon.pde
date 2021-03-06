/* UserCon - user controller code, read sensors, possibly decode features, update speed and turn rate
*/

float ePrev;      // global previous error 


void userControllerUpdate ()    
{
  
// your robot controller code here - this method called every time step
// crude attempt to control velocity as function of current centroid error 

float[] sensor =  sensor1.readArray();   // readArray() returns reference to sensor array of floats 

float e = calcSignedCentroidSingleDarkSpan(sensor) ;          //error in pixels of line intersection with sensor

//println(String.format("line positioning error %3.1f",e)); 


ePrev = e;   

// note you can dynamically change sensor positions if you wish
// in this example sensor radius is varied - just to show it can be done
// now, commented out here
// sensor1.setRotation(10);  // now theta
//sensor1.setArcRadius(1.0+ (frameCount%100)/100.0);
//sensor1.setRotation (90*mouseX/width);

// generally your robot will up updating TargetTurnRate and possibly TargetSpeed

lfs.setTargetTurnRate(-e * 10 + (e - ePrev) * 10.0);   // turn rate in degrees per second
lfs.setTargetSpeed(1.0 + abs(12.0f/(abs(e/2.0f)+1.0)));   

//lfs.setTargetSpeed (4.0);


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
