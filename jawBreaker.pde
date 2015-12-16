import processing.pdf.*;

//Declare Globals
int rSn; // randomSeed number. put into var so can be saved in file name. defaults to 47
final float PHI = 0.618033989;

boolean PDFOUT = false;

// Declare Positioning Variables
float margin;
float PLOT_X1, PLOT_X2, PLOT_Y1, PLOT_Y2, PLOT_W, PLOT_H;


PImage[] srcs;
PImage src;
JawBreaker jb;
ArrayList<JawBreaker> jbs;
boolean showHelp = true;
// Declare Font Variables
PFont mainTitleF;
int si = 0; // src index


void setup() {
  srcs = new PImage[6];
  srcs[0] = loadImage("IMG00217-20110105-1634-cropped.jpg");
  srcs[1] = loadImage("P1000889_4226705156_l.jpg");
  srcs[3] = loadImage("P1020004_4498274926_l.jpg");
  srcs[4] = loadImage("P1020746_4740563967_l.jpg");
  srcs[5] = loadImage("P1020770_4740609177_l.jpg");
  srcs[2] = loadImage("P1030193_4796867851_l.jpg");
  src = srcs[0];



  margin = width * pow(PHI, 6);
  println("margin: " + margin);
  PLOT_X1 = margin;
  PLOT_X2 = width-margin;
  PLOT_Y1 = margin;
  PLOT_Y2 = height-margin;
  PLOT_W = PLOT_X2 - PLOT_X1;
  PLOT_H = PLOT_Y2 - PLOT_Y1;


  jbs = new ArrayList<JawBreaker>();
  // jb = new JawBreaker(new PVector(0, 0));
  smooth();
  mainTitleF = createFont("Futura-Medium", 60);  //requires a font file in the data folder?
}

void settings(){

    if (PDFOUT) {
    size(src.width, src.height, PDF, generateSaveImgFileName(".pdf"));
  }
  else {
    size(src.width, src.height);
  }

}

void draw() {
  background(255);
  image(src, 0, 0, width, height);
  if (showHelp) {
    //fill(255, 200);
    //stroke(255);
    //rect(100, 100, width-200, height-200);
    fill(255,137);
    textFont(mainTitleF);
    text("click anywhere to start", mouseX, mouseY+textAscent()*-0.5);
    text("c = change image / colour palette", mouseX, mouseY+textAscent());
    text("r = reset", mouseX, mouseY+textAscent()*2);
    text("s = save an image", mouseX, mouseY+textAscent()*3);
    text("esc to quit", mouseX, mouseY+textAscent()*4);
  }

  for (JawBreaker j : jbs) { 
    j.render();
  }
}

void mousePressed() {
  if (showHelp) {
    showHelp = !showHelp;
  }
  jbs.add(new JawBreaker(new PVector(mouseX, mouseY)));  
}

void keyPressed() {
  if (key == 'r' || key == 'R') jbs.clear();
  if (key == 'S' || key == 's') screenCap(".pdf");
  if (key == 'C' || key == 'c') cycleSrc();
}

void cycleSrc(){
  // println("cycled src index: " + si);
  // si = (si < srcs.length) ? si++ : 0;
  if(si < srcs.length-1){
    si++; 
  }else{ 
    si=0;
  }
  // println("cycled src index: " + si);
  src = srcs[si];
}

class JawBreaker {
  PVector orig = new PVector();
  PVector edge = new PVector();
  float ribSz; // ribbon size

  JawBreaker(PVector _o) {
    orig = _o;
    ribSz = 7*pow(PHI,floor(random(1,4)));
    //ribSz = 7;
    // println("ribSz: " + ribSz);
  }

  void render() {
    edge.x = mouseX;
    edge.y = mouseY;
    float radius = PVector.dist(orig, edge);
    for (int i=0; i<radius; i+=11) { //<>//
      PVector currPxl = PVector.lerp(orig, edge, i/radius);
      color s = src.get(round(currPxl.x), round(currPxl.y)); // i don;t remember why I need to use the round function here
      stroke(s);
      strokeWeight(ribSz);

      noFill();
      // ellipse(orig.x, orig.y, orig.dist(currPxl)*2, orig.dist(currPxl)*2); //<>//
      // line(orig.x+i, lerp(orig.y, mouseY, i/radius), orig.x+i, height);
      // float linelength = map(brightness(s), 0, 255, 0,TWO_PI); // brightness based, naming things is hard
      float linelength = map(saturation(s), 0, 255, 0,TWO_PI); // brightness based, naming things is hard
      // normalize 
      // fuck it, just try it randomized.
      // line length is a function of distance from the origin, 
      // 
      arc(orig.x, orig.y,  orig.dist(currPxl)*PHI,orig.dist(currPxl)*PHI, HALF_PI+PVector.angleBetween(edge, orig), HALF_PI+PVector.angleBetween(orig,edge)+linelength);
      // arc(orig.x, orig.y,  orig.dist(currPxl)*PHI,orig.dist(currPxl)*PHI, 0, linelength);
      fill(s); //<>//
      ellipse(mouseX, mouseY, 47, 47);
    }
    strokeWeight(.5);
    stroke(0, 100);
    line(orig.x, orig.y, edge.x, edge.y);
  }
}


String generateSaveImgFileName(String fileType) {
  String fileName;
  // save functionality in here
  String outputDir = "savedImages/";
  String sketchName = getSketchName() + "-";
  String dateTimeStamp = "" + year() + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
  fileName = outputDir + sketchName + dateTimeStamp + fileType;
  return fileName;
}

void screenCap(String fileType) {
  String saveName = generateSaveImgFileName(fileType);
  save(saveName);
  println("Screen shot saved to: " + saveName);
}

String getSketchName() {
  String spath = sketchPath();
  String[] path = split(spath, "/");
  return path[path.length-1];
}
