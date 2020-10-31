/* uTrike - Trike Class 
   Will Kuhnle  Sept 2020

   steering-drive wheel is behind front two wheels & axle   wjk 6-21-20  
   trike varibles   wjk 6-14-20
   
   
   maybe trikeDriveUpdate in uTracking should be brought into Trike class? - Ron 
   maybe Trike class does not need to exist?   - Ron Asking ... 
   
   
   
   
*/   
 
Trike trike = new Trike(); // single instance of Trike 
 
class Trike {
 
 float wheelBase = -4.0;    // distance main axle to steer pivot in inches
 float steerAngleR;         // steering angle for front wheel -Pi/2 to +Pi/2 radians, CW is +
 float wheelVelocity;       // steering wheel forward velocity in inches/second

 Trike() {}
 
 //void reset()              // unused code - should modify current robot state if 
 //{ steerAngleR = 0.0;      // ever used 
 //  wheelVelocity = 0.0;
 //}  
 
 // moved decodeKeys to UKey
 
 
 
}



/*  Will Kuhnle Trike Robot Controller Code 
    Given current sensor data, steering wheel direction and speed is calculated
 
  
 
*/

/******************
to read spot sensors use read() method returns 0.0 to 1.0
 float v =  spotL.read();
to read line sensor
float[] s = lineSensor1.read();  // returns reference to sensor array of floats    which you can do something like
sensorRunDetector(s);
with few changes to your method now (float[] sensor )
*****************/
