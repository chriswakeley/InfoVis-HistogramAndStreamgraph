//Window gloabals
public int winWidth;
public int winHeight;
public int winOffset; //buffer around drawing area
public DrawingRange histBounds;
public DrawingRange streamBounds;
public int yAxisOffset;
public int yAxisTickLength;
public int xAxisTickLength;
public int yTicks;

//Data globals
Table table;
FloatList data;

//Histogram globals
public int numBins;
public float binRange;
public int binCounts[];

//stream globals
public float rawDensity[];
public float bandwidth;

void setup(){
  //window setup
  size(800, 1000);
  winWidth = 800;
  winHeight = 1000;
  winOffset = 100;
  histBounds = new DrawingRange(0 + winOffset, winWidth - winOffset, 0 + winOffset, winHeight/2 - winOffset);
  streamBounds = new DrawingRange(0 + winOffset, winWidth - winOffset, winHeight/2 + winOffset, winHeight - winOffset);
  yAxisOffset = 10;
  yAxisTickLength = 10;
  xAxisTickLength = 10;
  yTicks = 10;
  noLoop();
  
  //Data setup
  table = loadTable("events-100K.csv");
  data = table.getFloatList(0);
    
  //Histogram setup
  numBins = 60;
  binCounts = new int[numBins];
  binRange = (data.max() - data.min())/numBins;
  for(float f: data){
    binCounts[min(int((f - data.min())/binRange), numBins - 1)]++;
  }
  
  //Stream setup
  bandwidth = 2.5;
  rawDensity = new float[streamBounds.xrange];
  float minVal = data.min();
  float maxVal = data.max();
  for(int i = 0; i < rawDensity.length; i++){    
    for(float f: data){
      rawDensity[i] += (1/(pow(TWO_PI, 0.5))*
          exp(-0.5*pow((map(i, 0, rawDensity.length - 1, minVal, maxVal) - f)/bandwidth, 2)));
    }
    rawDensity[i] = rawDensity[i]/(data.size() * bandwidth);
  }
}

void draw(){
  background(255);
  
  //draw histogram
  stroke(0);
  strokeWeight(2);
  
  int binCountMax = max(binCounts); //getmax bin count for y axis mapping
  int binWidth = histBounds.xrange/numBins;
  
  //draw y axis
  line(histBounds.xmin - yAxisOffset, histBounds.ymax, histBounds.xmin - yAxisOffset, histBounds.ymin);
  textAlign(CENTER,BOTTOM);
  pushMatrix();
  translate(histBounds.xmin - winOffset*0.7, histBounds.ymin + histBounds.yrange/2);
  rotate(-HALF_PI);
  fill(0);
  text("Frequency",0,0);
  popMatrix();
  
  //draw y axis ticks
  textAlign(RIGHT, CENTER);
  pushMatrix();
  translate(histBounds.xmin - yAxisOffset, 0);
  for(int i = 0; i < yTicks; i++){
    pushMatrix();
    translate(- yAxisTickLength, map(i, 0, yTicks - 1, histBounds.ymax, histBounds.ymin));
    line(0, 0, yAxisTickLength, 0);
    text(int(map(i, 0, yTicks - 1, 0, binCountMax)), -5 , 0);
    popMatrix();
  }
  popMatrix();
  
  //draw x axis ticks
  textAlign(RIGHT, CENTER);
  pushMatrix();
  translate(histBounds.xmin, histBounds.ymax);
  for(int i = 0; i <= numBins; i = i+10){
    pushMatrix();
    translate(map(i, 0, numBins, 0, histBounds.xrange), 0);
    line(0, 0, 0, xAxisTickLength);
    rotate(-QUARTER_PI);    
    text(map(i, 0, numBins, data.min(), data.max()), 0, xAxisTickLength + 5);
    popMatrix();
    //translate();
  }
  textAlign(CENTER, TOP);
  translate(histBounds.xrange/2, xAxisTickLength+60);
  text("Event Time (s)", 0, 0);
  popMatrix();
  stroke(0);
  fill(150, 150, 170);
  for(int i = 0; i < numBins;i++){
    rect(map(i, 0, numBins, histBounds.xmin, histBounds.xmax), 
         map(binCounts[i], 0, binCountMax, histBounds.ymax, histBounds.ymin), 
         binWidth,
         histBounds.ymax - map(binCounts[i], 0, binCountMax, histBounds.ymax, histBounds.ymin));
  }
  
  //draw stream
  float maxDensity = max(rawDensity);
  fill(150, 150, 170);
  
  for(int i = 0; i < rawDensity.length; i++){
    stroke(150, 150, 170);
    strokeWeight(1);
    
    quad(map(i, 0, rawDensity.length - 1, streamBounds.xmin, streamBounds.xmax), 
        map(rawDensity[i]/2, 0, maxDensity/2, streamBounds.ymin + streamBounds.yrange/2, streamBounds.ymin),
        
        map(min(i + 1, rawDensity.length - 1), 0, rawDensity.length - 1, streamBounds.xmin, streamBounds.xmax),
        map(rawDensity[min(i + 1, rawDensity.length - 1)]/2, 0, maxDensity/2, streamBounds.ymin + streamBounds.yrange/2, streamBounds.ymin),
        
        map(min(i + 1, rawDensity.length - 1), 0, rawDensity.length - 1, streamBounds.xmin, streamBounds.xmax),
        map(-rawDensity[min(i + 1, rawDensity.length - 1)]/2, 0, -maxDensity/2, streamBounds.ymin + streamBounds.yrange/2, streamBounds.ymax),
        
        map(i, 0, rawDensity.length - 1, streamBounds.xmin, streamBounds.xmax), 
        map(-rawDensity[i]/2, 0, -maxDensity/2, streamBounds.ymin + streamBounds.yrange/2, streamBounds.ymax));
    
    //stroke(170, 170, 190);
    stroke(0);
    strokeWeight(2);   
    line(map(i, 0, rawDensity.length - 1, streamBounds.xmin, streamBounds.xmax), 
        map(rawDensity[i]/2, 0, maxDensity/2, streamBounds.ymin + streamBounds.yrange/2, streamBounds.ymin),
        map(min(i + 1, rawDensity.length - 1), 0, rawDensity.length - 1, streamBounds.xmin, streamBounds.xmax),
        map(rawDensity[min(i + 1, rawDensity.length - 1)]/2, 0, maxDensity/2, streamBounds.ymin + streamBounds.yrange/2, streamBounds.ymin));
        
    line(map(i, 0, rawDensity.length - 1, streamBounds.xmin, streamBounds.xmax), 
        map(-rawDensity[i]/2, 0, -maxDensity/2, streamBounds.ymin + streamBounds.yrange/2, streamBounds.ymax),
        map(min(i + 1, rawDensity.length - 1), 0, rawDensity.length - 1, streamBounds.xmin, streamBounds.xmax),
        map(-rawDensity[min(i + 1, rawDensity.length - 1)]/2, 0, -maxDensity/2, streamBounds.ymin + streamBounds.yrange/2, streamBounds.ymax));
    
    
  }  
}

class DrawingRange{
  public int xmin;
  public int xmax;
  public int ymin;
  public int ymax;
  public int xrange;
  public int yrange;
  
  DrawingRange(int xmin, int xmax, int ymin, int ymax){
    this.xmin = xmin;
    this.xmax = xmax;
    this.ymin = ymin;
    this.ymax = ymax;
    xrange = abs(this.xmax - this.xmin);
    yrange = abs(this.ymax - this.ymin);    
  }
}
  
  
  
  
  