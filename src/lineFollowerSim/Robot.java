package lineFollowerSim;

/* Robot class  (The Heart of LFS)

   Ron Grant
   Sept 2020
   Aug 26,2020  added support for constant acceleration 


   Robot class, handles update of heading and location on course image world using a 
   target turn rate and target forward speed each governed by a constant acceleration / deceleration 
   rate applied at each simulation time step (0.01 to 0.1 seconds).
   
   The "real-time" for a simulation time step can vary from many seconds (single step mode) down to as little time
   as needed for the computer to perform the calculations which includes sampling sensor data, from the line following
   course bitmap, running the controller code, then finally running this Class' driveUpdate method, which might be on 
   the something on order of 0.001 or even 0.0001 seconds (year 2020).
   
      
   Using units of inches and seconds and angular measure in degrees   
      
   Given initial location X,Y (inches) and heading (degrees) 
         constant values for acceleration and deceleration  (inches/sec^2 or inches/sec/sec)
   
         initial speed  0
         initial turn rate 0
   
         target Turn Rate (degrees/sec)
         target Forward Speed (inches /sec)
         
         dt = delta time = simulation time step (constant value from 0.1 down to 0.01 seconds)
              (dt not to be confused with infinitesimal time, calculus notation) 
         
        
   Drive update (applied every time step, dt)
   
   If speed less than target speed apply constant acceleration rate for dt time resulting in 
   change in speed
   
      speed  = speed +  change in speed (inches/sec) 
             = speed +  acclRate (inches/sec^2) * dt (sec) 
         
   
   If (new speed > target speed) clamp to target speed. In reality, in this case the acceleration 
   is being applied for less than the time step, but it makes the simulation cleaner, where the next time
   step will not apply acceleration if the target speed has not been changed.
   
   A similar process is applied for deceleration using decelRate. 
   Also turning, is similar except governed by a single constant turnAcc turn acceleration rate, used 
   also for turn rate deceleration.
   
   Next after updating speed and turnRate which may or may not be at their targets the current speed and turnRate
   are integrated over dt time interval to calculate distances traveled in the time interval and change in heading.
   
    forward distance (inches) = speed (inches/sec) * dt (sec) 
    change in heading (degrees) = turnRate (deg/sec) * dt (sec)
   
   
   Note that, I opted to apply change in heading after location update. Not my exact preference, as I write this,
   (Nov 10 ,2020) but I don't want to alter the simulations behavior, so leaving it as-is
   
   The robot location is defined in Cartesian (x,y) coordinates where forward speed in the current heading  direction
   determines the offset applied to x and y.
   
   For example if the robot is pointing along the -X axis, as it is with default heading 0 then a movement of some distance
   d would be   
   
          x = x - d
          y = y
          
   With an arbitrary heading h        0 = pointing in -X axis direction  turn 90 to right (heading 90) move in Y-
   
         
   looking at image of course. World coordinate origin is taken as upper-left of image with 
   positive X to right and positive Y down
 
       o----->+X axis
       |                                      ^ 
       |  Course Image    <-O Heading 0       O  Heading 90 (robot pointing "up" toward top of page)
       |                    (robot pointing  
      +Y axis                 to left)
          
   
       x = x - cos(h) * d         (h converted to radians for sine/cosine functions, *PI/180)
       y = y - sin(h) * d
   
   
   heading h (degrees)  = h (degrees) + turRate (degrees/sec) * dt (sec)
   
   Finally heading is restricted 0..360   
   
   e.g. heading -0.1   -> 359.9
        heading 361.0  -> 1.0
   
    
*/   
   
 
//Robot robot = new Robot (0,0,0);  // single instance of robot - predefined 

import processing.core.*;


class Robot {   // Java note: no public/private/protected modifier = package protected 

PApplet parent;  

// basic position and motion variables  
// note that robot object instanced by simulator is private -- so no access to x,y coordinates and heading as they are "exact"
// location on course.

public float x;           // robot position on course in inch coordinates
public float y;
public float heading;     // robot heading, 0 to 360 degrees CW, 0 is world x-

public  float turnRate;    // robot turn rate CW in degrees/second   use setTurnRate *
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
float turnAcc;     // turn acceleration rate in deg/sec^2 (same constnt for deceleration rate)

float wheelSep;    // wheel separation in inches 
                   // will be consideration for turning if using acclRate and dcelRate 
                   // on what effects wheel rotation speed.


float targetSpeed;      // used with setSpeed() where robot velocity will ramp up/down
                        // to a target speed using constant accl/decl rate variables 

float targetTurnRate;

float maxSpeed;         // max wheel speed -- applied to forward motion and turns
                        // Note: turn method speeds up one wheel and slows down other
                        // vs slowing down one, this will result in robot being slowed
                        // down if needed to achieve turn radius
                        
float maxTurnRate;  

// added parameters supporting Mecanum wheels  

float sidewaysSpeed;           // right+ left-  translation  
float targetSidewaysSpeed;

float distanceTraveled;  // new in 1.4.1  meant to be,reported, but not available during contest 

Robot (PApplet p, float x, float y, float heading)
{
	parent = p;
	
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

void setDistanceTraveled (float d) {distanceTraveled = d;}
float getDistanceTraveled() { return distanceTraveled;}


void driveUpdate(float dt) // delta time in seconds typically value from 0.1 to 0.01 (seconds)
                           // not tied to real time e.g. simulation steps can be executed very slowly
                           // for debug, even single step or stop with no impact on result
                      
{

// move robot in direction of heading
// default heading 0 moves in -X, turn 90 to right (heading 90) move in Y-
// see coordinate system definition in header 
                                  
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
    
if (sidewaysSpeed==0.0)  distanceTraveled += dist; 
else 
  distanceTraveled += PApplet.sqrt(PApplet.sq(dist)+PApplet.sq(swDist));  // distance traveled if sideways speed component


 
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

// added addCrumbIfNeeded  


}

} // end class