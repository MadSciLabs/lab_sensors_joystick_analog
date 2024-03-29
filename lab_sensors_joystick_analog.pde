/*
 * Draws a set of thermometers for incoming XBee Sensor data
 * by Rob Faludi http://faludi.com
 */

/*
  Modified Madsci:
  
  Removed all display logic and just grab sensor data
*/

// used for communication via xbee api
import processing.serial.*; 

// xbee api libraries available at http://code.google.com/p/xbee-api/
// Download the zip file, extract it, and copy the xbee-api jar file 
// and the log4j.jar file (located in the lib folder) inside a "code" 
// folder under this Processing sketch’s folder (save this sketch, then 
// click the Sketch menu and choose Show Sketch Folder).
import com.rapplogic.xbee.api.ApiId;
import com.rapplogic.xbee.api.PacketListener;
import com.rapplogic.xbee.api.XBee;
import com.rapplogic.xbee.api.XBeeResponse;
import com.rapplogic.xbee.api.zigbee.ZNetRxIoSampleResponse;

String version = "1.1";

// *** REPLACE WITH THE SERIAL PORT (COM PORT) FOR YOUR LOCAL XBEE ***

String mySerialPort = Serial.list()[8];
  
// create and initialize a new xbee object
XBee xbee = new XBee();

int error=0;

int ballX = 0;

// make an array list of thermometer objects for display
ArrayList thermometers = new ArrayList();
// create a font for display
PFont font;

SimpleThread testThread;

void setup() {
  size(800, 600); // screen size

  // The log4j.properties file is required by the xbee api library, and 
  // needs to be in your data folder. You can find this file in the xbee
  // api library you downloaded earlier
  PropertyConfigurator.configure(dataPath("")+"/log4j.properties"); 
  // Print a list in case the selected one doesn't work out
  println("Available serial ports:");
  println(Serial.list());
  
  /*
  try {
    // opens your serial port defined above, at 9600 baud
    xbee.open(mySerialPort, 9600);
  }
  catch (XBeeException e) {
    println("** Error opening XBee port: " + e + " **");
    println("Is your XBee plugged in to your computer?");
    println("Did you set your COM port in the code near line 20?");
    error=1;
  }
  */
  
  //Create Thread
  testThread = new SimpleThread(100,"a");
  testThread.start();
  
  smooth();
}


// draw loop executes continuously
void draw() {
    
  fill(#000000);  
  rect(0,0,width,height);
  
  fill(#c9c9c9);
  ellipse(ballX,height/2,50,50);
  
  ballX += 2;
  if (ballX > width) { ballX = 0;}
  
  if (error == 1) {
    fill(0);
    text("** Error opening XBee port: **\n"+
      "Is your XBee plugged in to your computer?\n" +
      "Did you set your COM port in the code near line 20?", width/3, height/2);
  }
  
  int a = testThread.getCount();
  text(a,10,50);
  
  //Get sensor data
  /*  
  SensorData data = new SensorData(); // create a data object
  data = getData(); // put data into the data object
  
  // check that actual data came in:
  if (data.value >=0 && data.address != null) { 
    println ("Address: " + data.address + " : " + data.value);
  }
  */
  
} // end of draw loop


// defines the data object
class SensorData {
  int value;
  String address;
}

// queries the XBee for incoming I/O data frames 
// and parses them into a data object
SensorData getData() {

  println("hey");
  
  SensorData data = new SensorData();
  int value = -1;      // returns an impossible value if there's an error
  String address = ""; // returns a null value if there's an error

  try {
 
    // we wait here until a packet is received.
    XBeeResponse response = xbee.getResponse();
    // uncomment next line for additional debugging information
    //println("Received response " + response.toString()); 

    // check that this frame is a valid I/O sample, then parse it as such
    if (response.getApiId() == ApiId.ZNET_IO_SAMPLE_RESPONSE 
      && !response.isError()) {
      ZNetRxIoSampleResponse ioSample = 
        (ZNetRxIoSampleResponse)(XBeeResponse) response;

      // get the sender's 64-bit address
      int[] addressArray = ioSample.getRemoteAddress64().getAddress();
      // parse the address int array into a formatted string
      String[] hexAddress = new String[addressArray.length];
      for (int i=0; i<addressArray.length;i++) {
        // format each address byte with leading zeros:
        hexAddress[i] = String.format("%02x", addressArray[i]);
      }

      // join the array together with colons for readability:
      String senderAddress = join(hexAddress, ":"); 
      //print("Sender address: " + senderAddress);
      
      data.address = senderAddress;
      // get the value of the first input pin
      if (ioSample.containsAnalog()) {
        value = ioSample.getAnalog0();
      } else {
                                // we know it's change detect since analog was not sent
        println("Received change detect for Digital pin 12: " + (ioSample.isD5On() ? "on" : "off"));
      }
      
      print(value + "\n"); 
      //data.value = value;
    }
    else if (!response.isError()) {
      println("Got error in data frame");
    }
    else {
      println("Got non-i/o data frame");
    }
  }
  catch (XBeeException e) {
    println("Error receiving response: " + e);
  }
  return data; // sends the data back to the calling function
}


class SimpleThread extends Thread {
 
  boolean running;           // Is the thread running?  Yes or no?
  int wait;                  // How many milliseconds should we wait in between executions?
  String id;                 // Thread name
  int count;                 // counter


  // Constructor, create the thread
  // It is not running by default
  SimpleThread (int w, String s) {
    wait = w;
    running = false;
    id = s;
    count = 0;
  }
 
  int getCount() {
    return count;
  }
 
  // Overriding "start()"
  void start () {

    
      try {
    // opens your serial port defined above, at 9600 baud
    xbee.open(mySerialPort, 19200);
  }
  catch (XBeeException e) {
    println("** Error opening XBee port: " + e + " **");
    println("Is your XBee plugged in to your computer?");
    println("Did you set your COM port in the code near line 20?");
    error=1;
  }
  
    // Set running equal to true
    running = true;
    // Print messages
    println("Starting thread (will execute every " + wait + " milliseconds.)");

    // Do whatever start does in Thread, don't forget this!
    super.start();
    
    println("START");


  }
 
 
  // We must implement run, this gets triggered by start()
  void run () {
    
  println("RUNNING");
  

 
  
    while (running) {
      println(id + ": " + count);
      count++;
      // Ok, let's wait for however long we should wait
      
        SensorData data = new SensorData(); // create a data object
  data = getData(); // put data into the data object
  
  //println(">" + data.value);
  
  // check that actual data came in:
  if (data.value >=0 && data.address != null) { 
    //println ("Address: " + data.address + " : " + data.value);
  }
  
      try {
        sleep((long)(wait));
      } catch (Exception e) {
      }
    }
  

    //System.out.println(id + " thread is done!");  // The thread is done when we get to the end of run()
    
  }
 
 
  // Our method that quits the thread
  void quit() {
    System.out.println("Quitting."); 
    running = false;  // Setting running to false ends the loop in run()
    // IUn case the thread is waiting. . .
    interrupt();
  }
}

