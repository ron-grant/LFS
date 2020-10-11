
// Define LineSensors and SpotSensors here 
// using LineSensor and SpotSensor classes
//
// then intitalize in userInit() method

SpotSensor spotL0, spotR0;                               
SpotSensor spotL1, spotC1, spotR1;      // spot sensors
SpotSensor spotL2, spotC2, spotR2;   // spot sensors
SpotSensor spotL3, spotR3;
SpotSensor spotL4, spotR4;
SpotSensor spotL5, spotR5;

SpotSensor spotFL, spotFR;
SpotSensor spotAI, spotFR2;
SpotSensor spotFL3, spotFR3;
LineSensor lineSensor1;            // line sensors     




void userInit()  // called by lfs to obtain robot information and for sensor definitions
{
  lfs.setFirstNameLastNameRobotName("Will","Kuhnle","Trike");   // contestant info 
  lfs.setCourse("DPRG_Challenge_2011_64DPI.jpg");   // challenge course     
  lfs.setPositionAndHeading (71.7,120,0);           // initial position over DPRG logo
 
  lfs.setTimeStep(0.05);  //  changed from default 0.01667 - appears to work OK, triples execution speed of simulation
                          //  (but not "speed" of robot)
                          //  As of Sept 22,2020 Trike should make it to first chopped sine wave on DPRG Challenge Course
                          //  This line can be commented out to resume original default time step of 0.01667 
  
  // below acceleration and deceleration rates are subject to LFS maximums
  
  lfs.setAccRate(32);      // acceleration rate (inches/sec^2)  
  lfs.setDecelRate(32);    // deceleration rate (inches/sec^2)  
  lfs.setTurnAcc(720);     // turn acceleration and deceleration rate  (degrees/sec^2) 
  
  // below setMaxSpeed and setMaxTurnRate are for informational purposes only
  // lfs will warn you and limit values which you can access by getMaxSpeed() and getMaxTurnRate()
  // It is up to you to limit your controller to these values, simulation will limit only to its maximums.
   
  // Note if you drive the robot straight at simulator maximum a turn will not be allowed as simulator 
  // turning model turning model applies increased velocity to one wheel and a decrease of the same velocity
  // to the other wheel to affect a turn about the center of the robot. 
    
  lfs.setMaxSpeed(16);      // inform lfs of your max speed *
  lfs.setMaxTurnRate(720);  // inform lfs of your max turn rate (degrees/sec)
 
  // Note For Sensor Instances Below
  // Sensor x,y offsets are in robot coordinates and inch scale
  // robot origin is "between wheels" +X axis extends forward and +Y axis extends to "right of robot"

  // note create method is required now, old constructor is not visible 
  
  spotL1 = lfs.createSpotSensor (1.125, -1.5, 15, 15);   // x,y offset from robot center   spot size    
  spotC1 = lfs.createSpotSensor (1.0, 0, 15, 15);
  spotR1 = lfs.createSpotSensor (1.125, 1.5, 15, 15);    
  spotL2 = lfs.createSpotSensor(1.55, -1.5, 15, 15);   
  spotC2 = lfs.createSpotSensor(2.0, 0.0, 15, 15);
  spotR2 = lfs.createSpotSensor(1.55, 1.5, 15, 15);    
  spotL3 = lfs.createSpotSensor(2.125, -1.5, 15, 15);        
  spotR3 = lfs.createSpotSensor(2.125, 1.5, 15, 15);  
  spotL4 = lfs.createSpotSensor(2.7, -1.65, 15, 15);
  spotR4 = lfs.createSpotSensor(2.7, 1.65, 11, 11);
  spotL5 = lfs.createSpotSensor(3.125, -1.8, 15, 15);
  spotR5 = lfs.createSpotSensor(3.125, 1.8, 11, 11);
  spotL0 = lfs.createSpotSensor(3.4, -1.95, 15, 15); 
  spotR0 = lfs.createSpotSensor(3.4, 1.95, 15, 15); 

  spotFL = lfs.createSpotSensor(0.5, -2.75, 15, 15);        
  spotFR = lfs.createSpotSensor(0.5, 2.5, 15, 15);    

  spotFR2= lfs.createSpotSensor(1.5, 2.5, 15, 15);
  spotAI = lfs.createSpotSensor(1.8, 1.9, 15, 15);

  spotFL3= lfs.createSpotSensor(2.125, -2.75, 15, 15);
  spotFR3= lfs.createSpotSensor(2.125, 2.75, 11, 11);

  lineSensor1 = lfs.createLineSensor(0, 0, 5, 5, 64); // x,y offset from robot center, spot size (5,5) , number of samples
  
  nameSensorsUsingVariableNames();   // look up sensor names and assign them to sensor name field (lib 1.3)
  lfs.markerSetup();                 // load course markers (lib 1.3)               
   
}
