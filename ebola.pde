// Jason Jacob
// The names of all the streams
String[] streamNames;

// Stores the labels
String [] xAxisLabels;

// Stores the data
double [][] themeRiverData;

// Holds error text.
String errorText;

// Flags a data error.
boolean dataError = false;

// The pick buffer.
PGraphics pickBuffer;

// The graph that stores the ThemeRiver
Graph myGraph;

void setup()
{
  smooth();

  // Set the background to white
  background(255);

  // Set the size of the canvas
  size(700, 500);

  pickBuffer = createGraphics(width, height);

  // Process the data we need to graph and set up the graphical elements.
  // If we have invalid data, then display an error message instead.
  if (processData())
  {
    setupGraph();
  }
  else
  {
    dataError = true;
    errorText = "Not all the data is numeric!";
  }


  //frame.setResizable(true);
}

// Draws the graph only if the data is free of error.
void draw()
{
  // Clears the background.
  background(255);

  // Updates the size of the pick buffer in case the screen is resized.
  //pickBuffer.setSize(width, height);

  if (dataError == false)
  {
    // Render the graph.
    myGraph.render();

    //    if (mousePressed == true) {
    //      myGraph.renderBackBuffer(pickBuffer);
    //      image(pickBuffer, 0, 0);
    //    }
  }
}

// This function reads the data from the csv file. Returns true if
// all the values processed in the second column are numbers.
boolean processData()
{
  // counters
  int i = 0;
  int j = 0;

  boolean returnVal = true;
  String[] data = loadStrings("ebola-new-deaths.csv");


  // Reads the axis labels.
  if (data.length > 1)
  {
    String [] tempXAxisLabels = data[0].split(",");
    xAxisLabels = new String[tempXAxisLabels.length - 1];

    arrayCopy(tempXAxisLabels, 1, xAxisLabels, 0, xAxisLabels.length);
  }

  // Store off the stream names
  streamNames = new String[data.length - 1];

  // Set up the theme river array
  themeRiverData = new double[data.length - 1][xAxisLabels.length];

  // Stores the quantitative column as doubles.
  for (i = 1; i < data.length; ++i)
  {
    String [] currentDataRow = data[i].split(",");

    if (currentDataRow != null)
    {
      streamNames[i - 1] = currentDataRow[0];

      for (j = 1; j < currentDataRow.length; ++j)
      {
        try
        {
          // Parse the value.
          themeRiverData[i - 1][j - 1] = (double) float(currentDataRow[j]);

          // If the value is less than zero, set it to zero.
          if (themeRiverData[i - 1][j - 1] < 0.0)
          {
            themeRiverData[i - 1][j - 1] = new Double(0.0);
          }
        }
        catch(Exception e)
        {
          return false;
        }
      }
    }
  }

  return returnVal;
}


// This function sets up the graph.
void setupGraph()
{
  myGraph = new Graph(xAxisLabels, streamNames, themeRiverData);
}

// Called when the mouse moves. Checks the back buffer for intersection.
void mouseMoved()
{
  myGraph.renderBackBuffer(pickBuffer);

  int c = pickBuffer.get(mouseX, mouseY);

  int testID = c & 0xFFFFFF;

  myGraph.setStreamIntersected(testID);
}

