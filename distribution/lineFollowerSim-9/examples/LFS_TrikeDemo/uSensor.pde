/* uSensor - Trike Sensor Code 
   Will Kuhnle  Sept 2020

   add 3rd colum to sensorRun, removed color [][0] to [][2] white is now 1 not +
   
*/

// below was [8][3]  -- increased to prevent program crash when accidentally running over text...  -- rdg 9/11/2020

int[][] sensorRun = new int[32][3]; // [][0] is run length, [][1] centroid, [][2] is color (0 or 1)

void sensorRunDetector(float[] sensor)
{
  int n = sensor.length; // total number of sensor samples
  int whtN ;   // New cell is white = 1, black = 0
  int whtO;   // Previous cell
  
  // clear out previous data from sensorRun array
  for(int i=0; i<32; i++) {sensorRun[i][0]=0; sensorRun[i][1]=0; sensorRun[i][2]=0;}   // increased from 8 to 32 -- rdg
  
  // process sensor[0] first cell of sensor, first cell of first run
  int runIndex = 1;      // for first sensorRun it is 1, runCount is in 0
  int sum = 1;           // moment of sensor[i] = i+1; for sensor[0] it is 1
  int count = 1;         // number of cells in run; for first cell, sensor[0] it is 1
  
  //process remainder of sensor cells
  for (int i=1; i<n; i++)
  {
      if (sensor[i-1]>0.5) whtO = 1; else whtO = 0; // color of previous cell
      if (sensor[i]>0.5) whtN = 1; else whtN = 0;   // color of this curren cell
      if (whtN == whtO)                             // if cell color has not changed, continue run 
        {sum += i+1; count++;}                 // add moment and count of this cell to current run
      else                                     // this cell is first of new run
      {                                        // save run data and start new run 
        sensorRun[runIndex][1] = (n/2)-(sum/count); // save centroid of run      
        sensorRun[runIndex][0] = count;             // save length of run
        sensorRun[runIndex][2] = whtO;              // save color of run
        sum = i+1; count = 1; runIndex++;           // starting moment and count is that of this cell
      }
  } // end for i
  // need to save data for last run
  sensorRun[runIndex][1] = (n/2)-(sum/count); // save centroid of last run      
  sensorRun[runIndex][0] = count;             // save length 
  sensorRun[runIndex][2] = (sensor[n-1]>0.5)? 1 : 0; whtO = -count; // color is that of last cell
  sensorRun[0][0] = runIndex;                 // save number of runs
} // end sensorRunDetector()

//------------------------------------
int[] pathWidthRun = new int[8];  // [0] is number of path width runs, [1] is run index of first path width run

 void pathWidthRuns(int[][] sensorRun)
 {
   int j = 0; 
   for (int i =1; i < sensorRun[0][0] ; i++ )
   {
     if( ( (sensorRun[i][0]>8)  && (sensorRun[i][0]<12) ) // 3/4" path is 9.6 cells wide
       ||( (sensorRun[i][0]>3)  && (sensorRun[i][0]<7 ) ) // 3/8" path is 4.8 cells wide
       ||( (sensorRun[i][0]>17) && (sensorRun[i][0]<25) ) ) //  1 1/5" path is 19.2 cells wide  
     { j++; pathWidthRun[j] = i; }
     pathWidthRun[0] = j;
   }
 }
