


// steering-drive wheel is behind front two wheels & axle   wjk 6-21-20  
// trike varibles   wjk 6-14-20
 
Trike trike = new Trike(); // single instance of Trike 
 
class Trike {
 
 float wheelBase = -4.0;    // distance main axle to steer pivot in inches
 float steerAngleR;         // steering angle for front wheel -Pi/2 to +Pi/2 radians, CW is +
 float wheelVelocity;       // steering wheel forward velocity in inches/second

 Trike() {}
 
 void reset()
 { steerAngleR = 0.0;
   wheelVelocity = 0.0;
 }  
 
 void decodeKeys (char k, int code)    // wjk 6-14-20
 {
     if (code ==  UP)  trike.wheelVelocity += 0.30;  //1.0
     if (k ==  'S' )   trike.wheelVelocity = 0;
     if (code == DOWN) trike.wheelVelocity -= 0.30;
     if (code == LEFT)  trike.steerAngleR += 0.05;  // steer wheel aft so + steer --> LEFT turn 
     if (code == RIGHT) trike.steerAngleR -= 0.05;  // think of wheel as rudder  wjk 6-21-20
    
     if (trike.steerAngleR > 1.0 ) trike.steerAngleR = 1.0;
     if (trike.steerAngleR < -1.0 ) trike.steerAngleR = -1.0;
 }
 
 
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
