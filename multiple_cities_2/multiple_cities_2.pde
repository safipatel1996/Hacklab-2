import com.temboo.core.*;
import com.temboo.Library.Yahoo.Weather.*;

// Create a session using your Temboo account application details
TembooSession session = new TembooSession("hacklab-saf", "myFirstApp", "WMQOekhN8sGWE2x8cHflVio7xXyGlykY");

float temperatureColor;

import processing.serial.*;
Serial myPort;  // Create object from Serial class
public static final char HEADER = 'H';
public static final char A_TAG = 'M';
public static final char B_TAG = 'X';

//Delare location array 
String[] location;
int currentLocation = 0;

// Declare fonts
PFont fontTemperature, fontLocation, fontInstructions;

// Give on-screen user instructions
String instructions = "Press any key to change cities";

// Set up some global values
int temperature;
XML weatherResults;
float f;

void setup() {
  size(700, 350  );

  printArray(Serial.list());// prints all connected serial devices.
  //check the list and select teh arduino
  String portName = Serial.list()[1]; // whatevr the number
  myPort = new Serial(this, portName, 9600); //set the serial rate

  // Set up fonts
  fontTemperature = createFont("Arial Black", 150);
  fontLocation = createFont("Arial Black", 36);
  fontInstructions = createFont("Arial Black", 16);
  fill(255); // Font color

  // Set up locations
  location = new String[4]; // Total number of locations listed below
  location[0] = "Barcelona";
  location[1] = "Coventry";
  location[2] = "dubai";
  location[3] = "Saguenay, Quebec";

  // Display initial location
  runGetWeatherByAddressChoreo(); // Run the GetWeatherByAddress Choreo function
  getTemperatureFromXML(); // Get the temperature from the XML results
  displayColor(); // Set the background color
  displayText(); // Display text
}

void draw() {
  if (keyPressed&&key==' ') {
    // Switch to next location
    currentLocation++;

    // If you've reached the end of the list, go back to the start
    if (currentLocation > location.length-1 ) {
      currentLocation = 0;
    }

    runGetWeatherByAddressChoreo(); // Run the GetWeatherByAddress Choreo function
    getTemperatureFromXML(); // Get the temperature from the XML results
    displayColor(); // Set the background color
    displayText(); // Display text
    
    sendMessage(A_TAG, int(temperatureColor), 0, 255-int(temperatureColor), 0);
  }

}


void serialEvent(Serial p) {
  // handle incoming serial data
  String inString = myPort.readStringUntil('\n');
  if (inString != null) {     
    print( inString );   // echo text string from Arduino
  }
}
void mousePressed() {
  sendMessage(A_TAG, int(temperatureColor), 0, 255-int(temperatureColor), 0);
  println("tag sent");
}

void sendMessage(char tag, int a, int b, int c, int d) {
  // send the given index and value to the serial port
  myPort.write(HEADER);
  myPort.write(tag);
  myPort.write((char)(a / 256)); // msb
  myPort.write(a & 0xff);  //lsb
  myPort.write((char)(b / 256)); // msb
  myPort.write(b & 0xff);  //lsb
  myPort.write((char)(c / 256)); // msb
  myPort.write(c & 0xff);  //lsb
  myPort.write((char)(d / 256)); // msb
  myPort.write(d & 0xff);  //lsb
}

void runGetWeatherByAddressChoreo() {
  // Create the Choreo object using your Temboo session
  GetWeatherByAddress getWeatherByAddressChoreo = new GetWeatherByAddress(session);

  // Set inputs
  getWeatherByAddressChoreo.setAddress(location[currentLocation]);

  // Run the Choreo and store the results
  GetWeatherByAddressResultSet getWeatherByAddressResults = getWeatherByAddressChoreo.run();

  // Store results in an XML object
  weatherResults = parseXML(getWeatherByAddressResults.getResponse());
}

void getTemperatureFromXML() {
  // Narrow down to weather condition
  XML condition = weatherResults.getChild("channel/item/yweather:condition");

  // Get the current temperature in Fahrenheit from the weather conditions
  temperature = condition.getInt("temp");

  f = (temperature - 32) * 5/9;
  println(f);

  // Print temperature value
  println("The current temperature in "+location[currentLocation]+" is "+temperature+"ºc");
}

void displayColor() {
  // Set up the temperature range in Fahrenheit
  int minTemp = 10;
  int maxTemp = 95;

  // Convert temperature to a 0-255 color value
  temperatureColor = map(temperature, minTemp, maxTemp, 0, 255);    

  // Set background color using temperature on a blue to red scale     
  background(color(temperatureColor, 0, 255-temperatureColor));
}

void displayText() {
  // Set up text margins
  int margin = 35;
  int marginTopTemperature = 150;
  int marginTopLocation = 175;

  // Display temperature
  textFont(fontTemperature);
  text(f, margin, marginTopTemperature);

  // Display location
  textFont(fontLocation);
  text(location[currentLocation], margin, marginTopLocation, width-margin, height-margin);

  // Display instructions
  textFont(fontInstructions);
  text(instructions, margin, height-margin);
}