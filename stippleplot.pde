import geomerative.*;
import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;

int xmargin = 10;
int commandSpacing = 50;

// Vector Drawing
int curPath = 0;
int curPoint = 0;
RShape shp;
RPoint[][] pathsInShape;


// Raster Drawing
int curLine = 0;
int rasterResolution = 3;
RShape rasterLine;


void setup() {
   size(1200, 400);
   
   oscP5 = new OscP5(this,12000);
   
   RG.init(this);
   
   // Load SVG and resize to fit
   shp = RG.loadShape("tiger.svg");
   shp.transform(0, xmargin, 1000, 1000000, true);

   // Vector Drawing
   pathsInShape = shp.getPointsInPaths();
   
   // Raster Drawing
   RPoint start = new RPoint(0,0);
   RPoint end = new RPoint(width, 0);
   RPoint[] line = new RPoint[2];
   line[0] = start;
   line[1] = end;
   rasterLine = new RShape(new RPath(line));
   
   // Plotter Control
   myRemoteLocation = new NetAddress("127.0.0.1",10000);
   ChangeVelocity(450);
   
}

void ChangeVelocity(float velocity) {
  // Only allow a range of velocities
  constrain(velocity,200,5000);

  OscMessage myMessage = new OscMessage("/velocity");
  myMessage.add(velocity);

  oscP5.send(myMessage, myRemoteLocation);
}

void Move(float x, float y) {
  OscMessage myMessage = new OscMessage("/move");
  
  constrain(x, 0, width);
  
  myMessage.add(x);
  myMessage.add(y);

  oscP5.send(myMessage, myRemoteLocation);
}

void ToggleLed(boolean state) {
  OscMessage myMessage = new OscMessage("/led");
  if (state == true) {
    myMessage.add(1);
  }
  else {
    myMessage.add(0);
  }

  oscP5.send(myMessage, myRemoteLocation);
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}

void vectorDraw() {
  RPoint currentPoint = pathsInShape[curPath][curPoint];
  
  pushMatrix();
    translate(0,-currentPoint.y + height/2);
    shp.draw(); 
  popMatrix();
  
  print("Path: " + curPath + " Point: " + curPoint);
  println(" X: " + currentPoint.x + " Y: " + currentPoint.y);
  
  pushMatrix();
    translate(0, height/2);
    noFill();
    ellipse(currentPoint.x, 0, 20, 20);
    fill(0);
    ellipse(currentPoint.x, 0, 4, 4);
    line(0, 0, width, 0);
    line(currentPoint.x, -height, currentPoint.x, height);
  popMatrix();
  
  ToggleLed(true);
  Move(currentPoint.x, currentPoint.y);
  ToggleLed(false);
  
  curPoint++;
  if (curPoint == pathsInShape[curPath].length) {
    curPoint = 0;
    curPath++;
    if (curPath == pathsInShape.length) {
      curPath = 0;
      println("Done!"); 
    }
  }
  
  delay(commandSpacing);
}

void rasterVectorDraw() {
  println("Current Line: " + curLine);
  
  pushMatrix();
    translate(0, -curLine + height/2);
    shp.draw(); 
  popMatrix();
  
  //RPoint cent = rasterLine.getPoint(0);
  //println("Line X: " + cent.x + " Y: " + cent.y);
  
  pushMatrix();
    translate(0, height/2 - curLine);
    rasterLine.draw();
  popMatrix();
  
  pushMatrix();
  RPoint[] intersections = shp.getIntersections(rasterLine);
  if (intersections != null) {
    translate(0, height/2);
    for (RPoint inter : intersections) {
      //println("\tX: " + inter.x + " Y: " + inter.y);
      
      noFill();
      ellipse(inter.x, 0, 20, 20);
      fill(255);
      ellipse(inter.x, 0, 4, 4);
    }
  }
  popMatrix();
  
  curLine += rasterResolution;  
  rasterLine.translate(0,rasterResolution);
    
}


void draw() {

  background(255);
  
  vectorDraw();
  //rasterVectorDraw();
  
}
