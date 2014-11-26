// Jason Jacob


// The Graph class where the main ThemeRiver visualization is drawn.
class Graph
{
  // Used to store the color scheme of the ThemeRiver visualization.
  ColorRGB[] colorScheme;
  
  // Used to store the highlight color when a particular stream is hovered over.
  ColorRGB highlightColor;
  
  // A set distance, in pixels, for both axes from the edge.
  final int AXIS_DISTANCE_FROM_EDGE = 70;
  
  // odd x label position
  final int ODD_X_LABEL_Y_POSITION = 30;
  
  //even x label position
  final int EVEN_X_LABEL_Y_POSITION = 15;
  
  // Used to scale the entire ThemeRiver as a percentage of the height
  // of the canvas. This is intended to keep the visualization from
  // overflowing the screen and from being too small.
  final float SCALE_FACTOR_ON_HEIGHT = 0.5;
  
  // This is intended to start the visualization at 20% of the screen height.
  final float RIVER_START_ON_HEIGHT = 0.20;
  
  // x-axis labels, stream names and the theme river data.
  String [] streamNames = null;
  String [] xAxisLabels = null;
  double [][] themeRiverData  = null;
  
  // Keeps track of the hash interval on the x-axis as the frame is resized.
  double xHashInterval;
  
  // Keeps track of the x-axis length as the frame is resized.
  double xAxisLength;
  
  // Keeps track of the max sum
  double maxSum = 0.0;
  
  // keeps track of how to scale down the sums
  float scaleDown = 1.0;
  
  // keeps track of where to start the river
  int riverStart = 0;
  
  // the stream that the mouse hovered over
  int streamIntersected = -1;
  
  // Constructor
  public Graph(String [] xAxisLabels, String[] streamNames, double [][] themeRiverData)
  {
    // Stores the x-axis labels, ThemeRiver data and names of the streams.
    setXAxisLabels(xAxisLabels);
    setThemeRiverData(themeRiverData);
    setStreamNames(streamNames);
    
    // Instantiates the color scheme that will be used for the streams. This will
    // rotate every three streams.
    colorScheme = new ColorRGB[3];
    colorScheme[0] = new ColorRGB(139, 136, 255);
    colorScheme[1] = new ColorRGB(123, 179, 26);
    colorScheme[2] = new ColorRGB(238, 219, 0);
    
    // Instantiates the highlight color when the user hovers over a stream.
    highlightColor = new ColorRGB(255, 0, 0);
  }
  
  // Sets stream names
  public void setStreamNames(String [] streamNames)
  {
    this.streamNames = streamNames;
  }
  
  // Sets x-axis labels
  public void setXAxisLabels(String [] xAxisLabels)
  {
    this.xAxisLabels = xAxisLabels;
  }
  
  // Sets the ID of the stream that was intersected.
  public void setStreamIntersected(int id)
  {
    streamIntersected = id;
  }
  
  // Sets the ThemeRiver data and performs other processing.
  public void setThemeRiverData(double [][] themeRiverData)
  {
    int i = 0;
    int j = 0;
    
    this.themeRiverData = themeRiverData;
    
    // This goes through all the time intervals and calculates the overall
    // sum at each interval (i.e. sum of each column).
    double[] timeSums = new double[themeRiverData[0].length];
    for(i = 0; i < timeSums.length; ++i)
    {
      timeSums[i] = 0.0;
    }
    
    for(i = 0; i < themeRiverData.length; ++i)
    {
      for(j = 0; j < themeRiverData[i].length; ++j)
      {
        timeSums[j] += themeRiverData[i][j];
      }
    }
    
    // Find and store the max sum.
    findMaxInArray(timeSums);
  }
  
  // Helper function to find and store the max sum at
  // time intervals.
  private void findMaxInArray(double[] sums)
  {
    if(sums != null)
    {
      for(int i = 0; i < sums.length; ++i)
      {
        if(sums[i] > maxSum)
        {
          maxSum = sums[i];
        }
      }
    }
    
  }
  
  // The render function.
  public void render()
  {
    // Calculates where the ThemeRiver visualization will start.
    riverStart = (int) (height * RIVER_START_ON_HEIGHT);
    
    // This calculates how each stream will be scaled down in height as a
    // proportion of the height of the screen and a pre-determined scaling factor.
    // This takes into account the maximum sum across the intervals in the data.
    scaleDown = (float) (maxSum/( height * SCALE_FACTOR_ON_HEIGHT ));
    
    // Draws the x-axis and all the related text.
    addXAxis();
    
    // Draws the ThemeRiver visualization.
    drawThemeRiver();
  }
  
  
  // This function contains the main logic for drawing the ThemeRiver visualization
  // based on the data. This function draws each stream as self-contained curvy shapes.
  // This is done by placing curve vertices and using the curveVertex() function to have Processing
  // fill in the curves. The logic contained here draws a top curve for the shape and a bottom
  // curve and then encloses it so it can be colored. Each subsequent curvy shape is drawn
  // below the previous one. Therefore, the bottom curve of any given shape becomes the top curve
  // of the next shape.
  public void drawThemeRiver()
  {
    int i;
    int j;
    double currentHashX = 0;
    
    // The top curve of the first shape will use the first row of the ThemeRiver data
    // that was parsed.
    double[] topCurve = new double[themeRiverData[0].length];
    arrayCopy(themeRiverData[0], topCurve);
    
    // The top curve of the first shape is scaled down and
    // offset by where the river should start.
    for(i = 0; i < topCurve.length; ++i)
    {
      topCurve[i] /= scaleDown;
      topCurve[i] += riverStart;
    }
    
    // Instantiate the bottom curve.
    double[] bottomCurve = new double[topCurve.length];
    arrayCopy(topCurve, bottomCurve);
    
    for(i = 0; i < themeRiverData.length; ++i)
    {
      // The bottom curve of each shape will be the values of hte top curve
      // offset by the current row of ThemeRiver data. The values of the ThemeRiver
      // data is scaled down to ensure it fits properly on the screen.
      for(j = 0; j < themeRiverData[i].length; ++j)
      {
        bottomCurve[j] = topCurve[j] + (themeRiverData[i][j] / scaleDown);
      }
      
      // If the stream is being hovered over by the mouse, it is filled with the highlight color.
      if(streamIntersected == i)
      {                
        fill(highlightColor.r, highlightColor.g, highlightColor.b);
      }
      // Otherwise, the stream is filled with the color scheme based on the row id modulo the
      // number of color schemes there are.
      else
      {
        fill(colorScheme[i % colorScheme.length].r, 
             colorScheme[i % colorScheme.length].g, 
             colorScheme[i % colorScheme.length].b);
      }
      
      // Begin to draw the shape by starting at the first hash.
      currentHashX = 0;
      
      // The decision was made to used no stroke to reduce visual noise between each stream.
      // This also made the overlaid text more visible when the user hovers over a particular stream.
      noStroke();
      
      // Start drawing the shape.
      beginShape();
      
      // Place a vertex at the beginning of the top curve. This will ensure the
      // shape properly closes up at the end.
      vertex((float) currentHashX, (float) topCurve[0]);
      
      // Place a curve vertex at the same place.
      curveVertex((float) currentHashX, (float) topCurve[0]);
      
      // Iterate through the top curve and place a curve vertex at each interval.
      for(j = 0; j < topCurve.length; ++j)
      {
        curveVertex((float) currentHashX, (float) topCurve[j]);
              
        currentHashX += xHashInterval;
        
        // If the interval tracker goes past the width, set it to the width.
        if(currentHashX > width)
        {
          currentHashX = width;
        }
      }
      // Place a curve vertex and vertex at the very end of the top curve.
      curveVertex((float) currentHashX, (float) topCurve[topCurve.length - 1]);
      vertex((float) currentHashX, (float) topCurve[topCurve.length - 1]);
  
      // Make sure the tracker starts at the very right edge of the screen, but no further.
      currentHashX = width;
      // Start at the rightmost edge of canvas and draw the bottom curve going left or "backwards".
      // Place a vertex and a curve vertex.
      vertex((float) currentHashX, (float) bottomCurve[bottomCurve.length - 1]);
      curveVertex((float) currentHashX, (float) bottomCurve[bottomCurve.length - 1]);
      
      // Draw the bottom curve by going left.
      for(j = bottomCurve.length - 1; j >= 0; --j)
      {
        curveVertex((float) currentHashX, (float) bottomCurve[j]);
              
        currentHashX -= xHashInterval;
        
        // If the interval tracker becomes negative then set it to zero. This should
        // only happen at the very end.
        if(currentHashX < 0)
        {
          currentHashX = 0;
        }
      }
      // Place the last curve vertex and vertex.
      curveVertex((float) currentHashX, (float) bottomCurve[0]);
      vertex((float) currentHashX, (float) bottomCurve[0]);
      
      // End the shape.
      endShape();
      
      // Make the top curve for the next shape the bottom curve of the current shape.
      arrayCopy(bottomCurve, topCurve);
    }
    
    // Set the stroke back to black to draw the hover text.
    stroke(0);
    
    // Goes though the rows in the ThemeRiver data and checks to see if the user
    // is hovering over a particular stream and then draws the hover text over that
    // stream with the relevant information: Name of the stream, time interval, and value.
    // The nearest time interval is found by rounding the x position of the mouse to the
    // nearest interval.
    for(i = 0; i < themeRiverData.length; ++i)
    {
      if(streamIntersected == i)
      {
        fill(0);
        textSize(20);
        String hoverText = "[" + streamNames[i] + ", " + 
                            xAxisLabels[round((float) (mouseX / xHashInterval))] + ", " + 
                            themeRiverData[i][round((float) (mouseX / xHashInterval))] + "]";
        int xPos = mouseX;
        int yPos = mouseY;
        
        // If the text is falling off the screen, this code makes sure it's moved
        // within the bounds of the screen.
        if((xPos + textWidth(hoverText)) > width)
        {
          xPos = (int) (width - textWidth(hoverText));
        }
        
        text(hoverText, xPos, yPos - 5);
      }
    }
  }
  
  // This function renders the back buffer with the exact same logic as the main renderer above.
  public void renderBackBuffer(PGraphics backBuffer)
  {
    backBuffer.beginDraw();
    backBuffer.background(255, 255, 255);
    int i;
    int j;
    double currentHashX = 0;
    
    double[] topCurve = new double[themeRiverData[0].length];
    arrayCopy(themeRiverData[0], topCurve);
    
    for(i = 0; i < topCurve.length; ++i)
    {
      topCurve[i] /= scaleDown;
      topCurve[i] += riverStart;
    }
    
    double[] bottomCurve = new double[topCurve.length];
    arrayCopy(topCurve, bottomCurve);
    
    for(i = 0; i < themeRiverData.length; ++i)
    {
      for(j = 0; j < themeRiverData[i].length; ++j)
      {
        bottomCurve[j] = topCurve[j] + (themeRiverData[i][j] / scaleDown);
      }
      
      backBuffer.noStroke();
      backBuffer.fill((int) red(i), (int) green(i), (int) blue(i));
      
      currentHashX = 0;
      backBuffer.beginShape();
      backBuffer.vertex((float) currentHashX, (float) topCurve[0]);
      backBuffer.curveVertex((float) currentHashX, (float) topCurve[0]);
      for(j = 0; j < topCurve.length; ++j)
      {
        backBuffer.curveVertex((float) currentHashX, (float) topCurve[j]);
              
        currentHashX += xHashInterval;
        
        if(currentHashX > width)
        {
          currentHashX = width;
        }
      }
      backBuffer.curveVertex((float) currentHashX, (float) topCurve[topCurve.length - 1]);
      
      backBuffer.vertex((float) currentHashX, (float) topCurve[topCurve.length - 1]);
  
      currentHashX = width;
      backBuffer.vertex((float) currentHashX, (float) bottomCurve[bottomCurve.length - 1]);
      
      backBuffer.curveVertex((float) currentHashX, (float) bottomCurve[bottomCurve.length - 1]);
      
      for(j = bottomCurve.length - 1; j >= 0; --j)
      {
        backBuffer.curveVertex((float) currentHashX, (float) bottomCurve[j]);
              
        currentHashX -= xHashInterval;
        
        if(currentHashX < 0)
        {
          currentHashX = 0;
        }
      }
      backBuffer.curveVertex((float) currentHashX, (float) bottomCurve[0]);
      
      backBuffer.vertex((float) currentHashX, (float) bottomCurve[0]);
      backBuffer.endShape();
      
      arrayCopy(bottomCurve, topCurve);
    }
    
    backBuffer.endDraw();
  }
  
  
    // Draws the x-axis along with its hash marks and the text for the categorical data.
  private void addXAxis()
  {
    stroke(0);
    // x-axis line
    line(0, height - AXIS_DISTANCE_FROM_EDGE, width, height - AXIS_DISTANCE_FROM_EDGE);
    
    // Updates the x-axis length.
    xAxisLength = distance(0, height - AXIS_DISTANCE_FROM_EDGE, width, height - AXIS_DISTANCE_FROM_EDGE);
    
    // The hash interval.
    xHashInterval = xAxisLength / (xAxisLabels.length - 1);
        
    double currentHashX = 0;
    
    for(int i = 0; i < xAxisLabels.length; ++i)
    {
      int xLabelYPos = 0;
      
      // Alternates the height of the positioning of the x-axis
      // labels so they don't collide with each other if there are a
      // lot of columns or if each label is very long.
      if(i % 2 == 0)
      {
        xLabelYPos = EVEN_X_LABEL_Y_POSITION;
      }
      else
      {
        xLabelYPos = ODD_X_LABEL_Y_POSITION;
      }
      
      fill(0);
      stroke(0);
      textSize(14);
      // If the current hash isn't the last one, then draw the text just underneath
      // the hash. If the current hash is the last one, then draw the hash and the text
      // just inside the right edge of the canvas.
      double currentTextXPos;
      if(i < xAxisLabels.length  - 1)
      {
        textAlign(LEFT);
        currentTextXPos = currentHashX; 
      }
      else
      {
        currentHashX -= 1;
        currentTextXPos = currentHashX - textWidth(xAxisLabels[i]);
      }
      
      // Draws each hash based on the calculations from above.
      line((float) currentHashX, height - AXIS_DISTANCE_FROM_EDGE, (float) currentHashX, height - AXIS_DISTANCE_FROM_EDGE + 3);
      
      // Draws each axis label based on the above calculations.
      text(xAxisLabels[i], (float) currentTextXPos, height - AXIS_DISTANCE_FROM_EDGE + xLabelYPos);
      
      // Increments the current hash.
      currentHashX += xHashInterval;
    }
  }
  
  // A distance helper function
  private double distance(double x1 ,double  y1,double  x2,double  y2)
  {
    double d;// = Point2D.distance(x1, y1, x2, y2);
    d = Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
    
    return d;
  }
}
