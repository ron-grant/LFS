/*

Create Local Robot for approximation of local odometry 
mimicing simulation robot except if simulation robot has errors added then this "perfect"
robot will not agree with simulation, but good enough for localized measurements
e.g. record position and heading at time X  then drive a bit inquiry will still be accurate enough
*/

Robot robot = new Robot(0,0,0);

class Robot {   // Java note: no public/private/protected modifier = package protected 


// basic position and motion variables  
// note that robot object instanced by simulator is private -- so no access to x,y coordinates and heading as they are "exact"
// location on course.

public float x;         // robot position on course in inch coordinates
public float y;
public float heading;     // robot heading, 0 to 360 degrees CW, 0 is world x-

private float turnRate;    // robot turn rate CW in degrees/second   use setTurnRate *
public  float speed;       // robot forward speed in inches/second    use setSpeed *
                        // * subject to accRate and decelRate if changed from default 

float xi,yi;     // initial position
float headingi;  // initial heading
float speedi;    // initial speed;   



// more advanced motion variables
// require use of set methods and not directly manipulating speed and turnRate
// Also, accelRate and declRate must be set to non-zero values (their default) 


float acclRate;    // acceleration rate inches/sec^2          
float declRate;    // deceleration rate inches/sec^2
float turnAcc;     // turn acceleration rate in deg/sec^2

float wheelSep;    // wheel separation in inches 
                // will be consideration for turning if using acclRate and dcelRate 
                // on what effects wheel rotation speed.


float targetSpeed;         // used with setSpeed() where robot velocity will ramp up/down
                        // to a target speed using accl/decl rate variables 

float targetTurnRate;

float maxSpeed;         // max wheel speed -- applied to forward motion and turns
                        // Note: turn method speeds up one wheel and slows down other
                        // vs slowing down one, this will result in robot being slowed
                        // down if needed to achieve turn radius
                        
float maxTurnRate;  

// added parameters supporting Mecanum wheels  

float sidewaysSpeed;           // right+ left-  translation  
float targetSidewaysSpeed;



Robot (float x, float y, float heading)
{
   
  this.xi = x;
  this.yi = y;
  this.headingi = heading;
  
    
  init();
  reset();

} 

void init()
{
  acclRate = 0.0f;      // by default, instantly apply speed vs ramp    -- assume both set to non-zero if changed
  declRate = 0.0f;      // use setAccDecelRates() method to set.
  turnAcc = 0.0f;       // turn acceleration in deg/sec^2   
  hardStop();

}

/**
 *  Instant stop of robot - normally decelerate to stop using slowToStop() method.
 */
void hardStop()  // instant stop 
{
  targetSpeed = 0;
  speed = 0;
  targetSidewaysSpeed = 0;
  sidewaysSpeed = 0;       // Mecanum wheel
  targetTurnRate = 0;
  turnRate = 0;
}

void setAccDcelRates(float acc, float decel )  // set acceleration deceleration rates in inches/sec^2
{                                              // default = 0 which applied speed and turn rate instantly
acclRate = acc;
declRate = decel;
}

void setTurnAcc(float acc)
{ turnAcc = acc; 
}


void setTargetSpeed(float s)
{
targetSpeed = s;
} 

void setTargetSidewaysSpeed(float hs)
{
  targetSidewaysSpeed = hs; 
}


void setTargetTurnRate(float tr)
{
  targetTurnRate = tr;                   
}

float getTurnRate () { return turnRate; }
float getSpeed()     { return speed; }
float getSidewaysSpeed() { return sidewaysSpeed; }


void changeTargetSpeed(float delta, float maxSpeed)
{ targetSpeed += delta;
  if (targetSpeed > maxSpeed) targetSpeed = maxSpeed;
  if (targetSpeed <-maxSpeed) targetSpeed = -maxSpeed;
}


void changeTargetSidewaysSpeed(float delta, float maxSpeed)
{ targetSidewaysSpeed += delta;
  if (targetSidewaysSpeed > maxSpeed) targetSidewaysSpeed = maxSpeed;
  if (targetSidewaysSpeed <-maxSpeed) targetSidewaysSpeed = -maxSpeed;
}

void changeTargetTurnRate (float delta,float maxTurnRate)
{
  targetTurnRate += delta;
  if (targetTurnRate > maxTurnRate) targetTurnRate = maxTurnRate;
  if (targetTurnRate <-maxTurnRate) targetTurnRate = -maxTurnRate;  
}


void slowToStop()
{
  targetSpeed = 0;
  targetTurnRate = 0;
  targetSidewaysSpeed = 0;   // e.g. Mecanum wheels
}




void setCurrentAndInitialLocationAndHeading(float x, float y,float h)
// called on mouse click when course view is displayed (Tab toggles on/off)
{
xi = x; yi=y; headingi = h;
this.x = x;
this.y = y;
this.heading = h;
}

void reset() // reset to initial conditions 
{
x = xi;
y= yi;
heading = headingi;

speed    = 0.0f;
sidewaysSpeed = 0.0f;     // Mecanum wheel
turnRate = 0.0f;

} 

float radians (float r ) { return (float) (r*Math.PI/180.0f);   }


void driveUpdate(float dt) // delta time in seconds typically value from 0.1 to 0.01 (seconds)
                         // not tied to real time e.g. simulation steps can be executed very slowly
                         // for debug, even single step or stop with no impact on result
                      
{

// robot (click on image) positioning code in  DrawWorld

// move robot in direction of heading
// default heading 0 moves in -X, turn 90 to right (heading 90) move in Y-

// looking at image of course. World coordinate origin is taken as upper-left of image with 
// positive X to right and positive Y down
//
//      o----->+X axis
//      |
//      |  Course Image 
//      | 
//     +Y axis
//

                                         
                                           // units:   inches = inches/sec * seconds 


if (speed != targetSpeed)                 // accelerate / decelerate if non-zero values 
{                                         // specified for acceleration / deceleration.
  
 if (speed < targetSpeed) {
    speed += acclRate * dt;
    if (speed>targetSpeed) speed = targetSpeed;
 }
 
 if (speed > targetSpeed) {
    speed -= declRate * dt;
    if (speed<targetSpeed) speed = targetSpeed;
 }
     
}

if (sidewaysSpeed != targetSidewaysSpeed)     // accelerate / decelerate if non-zero values 
{                                                 // specified for acceleration / deceleration.
  
 if (sidewaysSpeed < targetSidewaysSpeed) {
    sidewaysSpeed += acclRate * dt;
 if (sidewaysSpeed> targetSidewaysSpeed) sidewaysSpeed = targetSidewaysSpeed;
 }
 
 if (sidewaysSpeed > targetSidewaysSpeed) {
    sidewaysSpeed -= declRate * dt;
    if (sidewaysSpeed<targetSidewaysSpeed) sidewaysSpeed = targetSidewaysSpeed;
 }
     
}
   

if (turnRate != targetTurnRate)
{
 
  if (turnRate < targetTurnRate) {                             
   turnRate += turnAcc * dt;                                  
   if (turnRate>targetTurnRate) turnRate = targetTurnRate;
  }
 
  if (turnRate > targetTurnRate) {
   turnRate -= turnAcc * dt;
   if (turnRate<targetTurnRate) turnRate = targetTurnRate;
  }
}

                                              
float dist = speed * dt;            // total distance traveled in this delta time timestep in inches
float swDist = sidewaysSpeed * dt;  // total sideways (right angle to forward) distance - Mecanum wheels  
    
                                        
 
// resolve into changes in x and y  as a function of heading

float ca = (float) Math.cos(radians(heading));
float sa = (float) Math.sin(radians(heading));

float sca = (float) Math.cos(radians(heading+90f));  
float ssa = (float) Math.sin(radians(heading+90f));

                                   
// resolve forward distance into XY components (based on heading)
// also resolve horizontal distance (Mecanum wheels) into XY components
// normally horzDist = 0 for "regular wheels"
                                       
x -= ca * dist + sca * swDist;       
y -= sa * dist + ssa * swDist;        
                                       

heading += turnRate*dt;                    // update heading based on turnRate
                                           // units:  degrees = degrees +  degrees/sec * degrees 

if (heading>=360.0) heading -= 360;        // keep heading in 0..360 range,  e.g. 362 would become 2
if (heading<0.0) heading += 360;           // -5 would become 355


}

} // end class
