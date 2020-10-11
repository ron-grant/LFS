
//  Below is untouched code from Will Aug 22,2020
//  

int cOld = 0;       // centroid of path run  
int sensorState = 0;
float toGo = 0.0;  //  = turn angle / robot.wheelBase  wjk 6-27- 2020



void userControllerUpdate()
{
  int y = 0;   // output of linear sensor array  
  int c = 0;   // tracking error
  
  float dt = lfs.getTimeStep();  
  
 
  float[] lsa = lineSensor1.readArray();  // returns reference to sensor array of floats 
                                          // which you can do something like:
                                          // sensorRunDetector(lsa);

  if (lsa.length == 0)
  {
    println ("userControllerUpdate - no sensor data exit");
    return;
  }  
  else
   // println ("userControllerUpdate");

  sensorRunDetector(lsa);   // sensorRun[][1]
  
  // which runs are a path width long?
  pathWidthRuns(sensorRun);  // the index of path_length_run fort
  
  //----------------Compute pattern number
  int patL = 0, patR = 0, patC = 0; // pattern
  int patFL = 0, patFR =0;
  if(spotL0.read()>0.5) { patL += 1; } 
  if(spotL1.read()>0.5) { patL += 2; } 
  if(spotL2.read()>0.5) { patL += 4; }
  if(spotL3.read()>0.5) { patL += 8; }                 
  if(spotL4.read()>0.5) { patL += 16;} 
  if(spotL5.read()>0.5) { patL += 32;}
  if(spotR1.read()>0.5) { patR += 2; }
  if(spotR2.read()>0.5) { patR += 4; }
  if(spotR3.read()>0.5) { patR += 8; }
  if(spotR4.read()>0.5) { patR += 16;}
  if(spotR5.read()>0.5) { patR += 32;}
  if(spotR0.read()>0.5) { patR += 1; } 
  if(spotC1.read()>0.5) { patC += 2; }
  if(spotC2.read()>0.5) { patC += 4; }
  if(spotFL.read()>0.5) { patFL += 1;}
  if(spotFR.read()>0.5) { patFR += 1;}
  if(spotFL3.read()>0.5){ patFL += 8;}
  if(spotFR3.read()>0.5){ patFR += 8;}
  if(spotFR2.read()>0.5){;}


  switch ( sensorState )
  {
    case 0:{
      if(((patR | 35)==35)
         &&(patC==6)
         &&(patFR==9) &&(patFR==9)
         &&(patL== 63)
        )
      {
        trike.steerAngleR = -0.9; //- 0.7854;
        println(" offset to right"); // 3" radius  turn
        toGo = 3.614;   // 39.19 deg turn
        sensorState = 3; // goto offset move, step 1
        break;
      }
      if((spotFL3.read()>0.5)&&(spotL2.read()< 0.5) && (spotC1.read()>= 0.5)
        && (spotFL.read()>0.5)&&(spotFR.read()>0.5) &&(patR==63) )
      {
        trike.steerAngleR =  0.7854;
        println(" offset to left"); // 3" radius turn   
        toGo = 3.614;   //  turn
        sensorState = 3; // goto offset move, step 1
        break;
      }
      if((spotFR2.read()< 0.5) && (spotC1.read()< 0.5) && (spotC2.read()<0.5)
         &&(spotFL.read()>=0.5) && (spotFL3.read()>= 0.5)
         &&(spotL1.read()>0.5) && (spotL2.read()>0.5)
         &&(spotAI.read()>0.5)
         &&(spotL5.read()>0.5)) //  angle
      {
        //toGo = (spotR3.read()<0.5) ? 5.8 : 10.5; // 90deg turn
        trike.steerAngleR = - 1.15; println(" acute to right"); //  ACUTE TURN   
        toGo = 10.5;   // approx. 120deg turn
        sensorState = 4; // goto acute move,
        break;
      }
      if   // RIGHT 90
      (
        (
          ( (patR==55)||(patR==35) )
          &&(patC==0)
          &&(patFL==9)
        )   // RIGHT 90 BLK
        ||
        (
          ( ((patR==8 )&&(patL==0 ))||((patR==28)&&(patL==0 )) )
          &&(patC==6)
        )   // RIGHT 90 WHT
      )
      {
        trike.steerAngleR = - 1.05; println(" 90 to right"); //  radius turn   
        toGo = 6.4;   // approx. 90deg turn
        sensorState = 4; // goto acute move,
        break;
      }
      if   // LEFT 90
      (
        (
          ( ((patL==55)&&(patR==63))||((patL==35)&&(patFR==9)) )
          &&(patC==0)
          &&(patFR==9)
        )   // LEFT 90 BLK
        ||
        (
          ( ((patL==8 )&&(patR==0 ))||((patL==28)&&(patR==0 )) )
          &&(patC==6)
          &&(patFR==0)
        )   // LEFT 90 WHT
      )
      {
        trike.steerAngleR = + 1.05; println(" 90 to left"); // 3" radius turn   
        toGo = 6.4;   // approx. 90deg turn
        sensorState = 4; // goto acute move,
        break;
      }
      if( //(robot.steerAngleR >0.5) // WHITE NOTCH
        (patR==8)
        &&(patC>=2)
        &&((patL==1)||(patL==33) )
        &&(patFL==0)
        //&&(patFR<=8)
        )
      {
        trike.steerAngleR = - 1.13; println(" notch  right"); // 1.85   -1.107 2" radius    
        toGo = 10.30;   // approx. 132deg turn
        sensorState = 5; // goto notch 1st move,
        break;
      }

             switch (sensorRun[0][0]) // number of runs in lsa
             {
               case 1:{ // 
                trackingUpdate( cOld, dt); // just keep going
                 break;
               }
               case 2:{
                /* if( (abs(sensorRun[1][0])+ abs(sensorRun[2][0])) > 0) 
                    {robot.steerAngleR = HALF_PI ; println(" wide + run");} // left turn
                 else {robot.steerAngleR = - HALF_PI; println(" wide - run");} // right turn
                 toGo = 4.712;   // 90deg turn
                 sensorState = 1; // 90deg turn, step 1
                */
                 break;
               }
               case 3:{  // 3 runs,  run 2 is path -> normal tracking
                 if ( //( abs((sensorRun[2][1]) - cOld) < 3 ) &&    // center run near previous run
                      ( abs(sensorRun[2][0]) < abs(22) ) )        // and not too wide
                 {
                   c = sensorRun[2][1];
                   trackingUpdate( c, dt);
                   sensorState = 0;  //  use to track line
                 }
                 break;
               }
               case 4:
               case 5:{
                trackingUpdate( cOld, dt); // just keep going
                 break;
               }
               default:{ println( " sensorState 0 default ", sensorRun[0][0]);}
             } // end of runs switch
             break; // out of outer switch case 0 
    } 
    case 1: { // robot is turning open loop
              toGo -= trike.wheelVelocity * dt;
              sensorState = 1; 
              if( toGo < 0.0)                  // turned enough
              {
                trike.steerAngleR = 0.0; toGo = 1.0; // request 
                sensorState = 2; // goto robot is moving straight forward
              }
              break;
    }
    case 2: { //robot is moving straight forward
             sensorState = 2;
             toGo -= trike.wheelVelocity * dt;
             if( toGo < 0.0)// far enough
             { trike.steerAngleR = 0; sensorState = 0; } // manuver complete, return to tracking
             break;
    }   
    case 3: { // robot offset move, step 1 open loop
              toGo -= trike.wheelVelocity * dt;
              sensorState = 3; 
              if( toGo < 0.0)                  // turned enough
              {
                if(trike.steerAngleR > 0 )
                { trike.steerAngleR = 0; toGo = 1.0;}
                else
                {trike.steerAngleR = - trike.steerAngleR;// reverse turn direction
                println(" offset to right, step 2"); // 3" radius left turn
                toGo = 3.614;} // request 
                sensorState = 4; // goto offset move, step 2
              }
              break;
    }
    case 4: { //robot offset move, step 2 and acute move
             toGo -= trike.wheelVelocity * dt;
             sensorState = 4;
             if( toGo < 0.0)                  // far enough
             { trike.steerAngleR = 0.0; sensorState = 0; } // manuver complete, return to tracking
             break;
    }   
    case 5: { // notch, 1st move
             toGo -=  trike.wheelVelocity * dt;
             sensorState = 5;
             if( toGo < 0.0)                  // far enough
             { trike.steerAngleR = 0.852; // 3.5r 0.968 2.75r 1.012 2.5" radius
               println( " notch 2nd move");
               toGo = 5.9; sensorState = 4; // 4.776 goto ending manuver
             } 
             break;
    }   

  default:{ println(" default "); }
  } // switch
  cOld = c;

  // println (" steer2 ", robot.steerAngleR);
  //println(" runs ", sensorRun[0][0], sensorRun[1][0],sensorRun[2][0], sensorRun[3][0]);
  
  trikeDriveUpdate ();  // calculate speed and turn rate 
  
} // Trike controller()
