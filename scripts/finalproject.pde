/* Final Project - pde fil
 * EE260 - Embedded Systems
 * 
 * Group:
 *        Abdi Musse
 *        Samir Martins
 * Start date: 11/10/2010
 * Finish date: / / 2010
 *
 */

const int pin = 2;
int state;


//
// Declare the things that exist in our assembly code
//
extern "C" { 
  
  void initAD(void);
  byte readAD(byte port);
  void go_forward(void);
  void go_backward(void);
  void turn_left(void);
  void turn_right(void);
  void led_on(void);
}

//Coding
byte charMap[15] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 'B', 'L', 'R', 'A', 'S'}; 
byte ascii[15]={0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x42, 0x4c, 0x52, 0x41, 0x53};

//
// function to read a string from a user
//

int i = 0;
byte readUserString(byte buffer[], int maxLength)
{
   Serial.println("Enter the command for the Mars Rover:");
   while (!Serial.available()) delay(100);
   while (Serial.available() && i < maxLength-1) {
      buffer[i++] = Serial.read();
      delay(10); // probably not needed, but safe
   }
   buffer[i] = '\0'; // string terminator
   Serial.print("The command entered is [");
   Serial.print((char*)buffer);
   Serial.println("]");
   
   // C code to map the entered strings
   int j = 0; // Counter
   int k = 0; // Counter
   
   // Maping the ASCII
   for (j = 0; j< (sizeof(charMap)/sizeof(byte)+1); j++)
   {  for (k = 0; k<(sizeof(charMap)/sizeof(byte)+1); k++){
      
        if (buffer[j] == ascii[k]) 
          buffer[j] = charMap[k];
     
      }
   }
   
   return (byte) 0;
}

int d;
byte readReportCommand(byte buffer[], int maxLength)
{
   Serial.println(" "); // Empty line
   Serial.println("Enter the character R to report the results");
   while (!Serial.available()) delay(100);
   while (Serial.available() && d < maxLength-1) {
      buffer[d++] = Serial.read();
      delay(10); // probably not needed, but safe
   }
   buffer[d] = '\0'; // string terminator
   
   // C code to map the entered strings
   int j = 0; // Counter
   int k = 0; // Counter
   
   // Maping the ASCII
   for (j = 0; j< (sizeof(charMap)/sizeof(byte)+1); j++)
   {  for (k = 0; k<(sizeof(charMap)/sizeof(byte)+1); k++){
      
        if (buffer[j] == ascii[k]) 
          buffer[j] = charMap[k];
     
      }
   }
   
   return (byte) 0;
}

//
// Arduino-required setup function (called once)
//
void setup()
{
   
     
   // Initializing variables
   byte message[48]; // Main command
   byte report[48]; // Report command
   byte v; // readAD
   int j; // Counter
   int jj; // Counter
   int jjj; // Counter
   int ii;
   int s=0; // Soil 
   byte soil[10];
   int a=0; // Atmosphere
   byte atmosphere[10];
   
   state = LOW;
     
   Serial.begin(9600);
   /*Initializing the AD converter*/
   initAD();  // call assembly init A/D routine

   // Reading a command from the user   
   readUserString(message,48);   

   pinMode(pin, INPUT);

while(1){
  
    state = digitalRead(pin);
   
    if(state == HIGH){
  
   // i => size of the entered message
    for(j=0;j<i; j++){
  
      if(message[j]=='R'){ // 'R' -- means turn 45 degrees to the right
            
            turn_right();
            delay(50); // Time between a transition
            
        } // End => if char is R
            
        else if(message[j]=='L'){ // 'L' -- means turn 45 degrees to the left
            
            turn_left();
            delay(50); // Time between a transition
            
          } // End => if char is L
      
          else if(message[j]=='S'){ // 'S' -- means perform a soil analysis
          
            // Reading the AD value from the port 4, in decimal.
            delay(1000); // delay one second
            soil[s] = readAD(4); // call assembly read sensor routine, A/D pin #4
            delay(1000); // delay one second
            led_on();
            s++;
            
          } // End => if char is S
          
            else if(message[j]=='A'){ // 'A' -- means perform an atmosphere analysis
                
               // Reading the AD value from the port 1, in decimal.
               delay(1000); // delay one second
               atmosphere[a] = readAD(1); // call assembly read sensor routine, A/D pin #1
               delay(1000); // delay one second 
               led_on();
               a++;  
               
            } // End => if char is A
              else if(message[j]==0 || message[j]== 1 || message[j]== 2 || message[j]== 3 || message[j]== 4 || message[j]== 5 || message[j]== 6 || message[j]== 7 || message[j]== 8 || message[j]== 9){ 
                
                    for(jj=0;jj<message[j];jj++){ // 0'-'9' -- a digit character means drive forward for 0.25*N seconds,
                
                        go_forward();
                        
                    } // for
                 }// else if         
                  if(message[j]=='B'){ // 'B' -- means return to base and report your analysis results
                       
                      for(jjj=(i-1);jjj>=0;jjj--){
              
                          if(message[jjj]=='L'){ 
                            turn_right();
                            delay(1000); // Time between a transition
                          } else if(message[jjj]=='R'){
                              turn_left();
                              delay(1000); // Time between a transition
                            } 
                            else if(message[jjj]==1){
                                for(ii=0;ii<1;ii++){
                                  go_backward();
                                }
                                delay(1000);
                            } // 1
                            else if(message[jjj]==2){ 
                               for(ii=0;ii<2;ii++){
                                  go_backward();
                               }
                                delay(1000);
                            } //2
                            else if(message[jjj]==3){
                                for(ii=0;ii<3;ii++){
                                  go_backward();
                                }
                                delay(1000);
                            } //3
                            else if(message[jjj]==4){
                                 for(ii=0;ii<4;ii++){
                                  go_backward();
                                 }
                                delay(1000);
                            } //4
                            else if(message[jjj]==5){
                              for(ii=0;ii<5;ii++){
                                go_backward();
                              }
                                delay(1000);
                            } //5
                            else if(message[jjj]==6){
                              for(ii=0;ii<6;ii++){
                                go_backward();
                              }
                                delay(1000);
                            } //6
                            else if(message[jjj]==7){
                              for(ii=0;ii<7;ii++){
                                go_backward();
                              }
                                delay(1000);
                            } //7
                            else if(message[jjj]==8){
                              for(ii=0;ii<8;ii++){
                                go_backward();
                              }
                                delay(1000);
                            } //8
                            else if(message[jjj]==9){
                              for(ii=0;ii<9;ii++){
                                go_backward();
                              }
                                delay(1000);
                            } //9
                } //for(jjj=0;jjj<i;jjj++) */
                  } // End => if char is B
                  
                  delay(1000); // Wait to stop
  }
  
readReportCommand(report,48); 

if(report[0] == 'R'){
  
  Serial.println(" ");
  Serial.print("Soil ");
  Serial.print(s,DEC);
  Serial.print(" ");
  for(i=0;i<s;i++){
   
    Serial.print(soil[i],HEX);
    Serial.print(" ");    
  }
  
  Serial.println(" ");
  Serial.println(" ");
  Serial.print("Atmosphere ");
  Serial.print(a,DEC);
  Serial.print(" ");
  for(i=0;i<a;i++){
   
    Serial.print(atmosphere[i],HEX);
    Serial.print(" ");    
  }

} // if report == R

} // if start
 
} // while
 
} // Main function

//
// Arduino-required loop function (called infinitely)
//
void loop()
{

}
