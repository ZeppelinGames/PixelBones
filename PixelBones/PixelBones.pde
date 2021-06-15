import java.util.Map;

HashMap<PVector, Integer> allPixels = new HashMap<PVector, Integer>();

color currDrawColor = color(0);
int scaling = 32;
PVector scaleBounds = new PVector(8, 128); //Min, max

Mode currMode = Mode.DRAWING;
enum Mode {
  DRAWING, RIGGING, POSING
}

void setup() {
  size(1024, 1024);
  surface.setTitle("PixelBones");
}

void draw() {
  background(0);
  DrawGrid(scaling);

  switch(currMode) {
  case DRAWING:
    //Change colours
    //Pick brushes
    //Draw on canvas
    PlotPixel();
    DrawPixels();
    //Swap layers
    break;
  case RIGGING:
    //Add and connect bones
    //Select and assign groups of pixels for each bone
    break;
  case POSING:
    //Move bones (and transform pixels) to pose model
    break;
  }
}

void DrawGrid(int gridScale) {
  noStroke();

  color gridCol = color(110);
  color gridColAlt = color(127);

  for (int x =0; x < width; x+= gridScale) {
    for (int y =0; y < height; y += gridScale) {
      boolean xGrid = (x/gridScale) % 2 == 0;
      boolean yGrid = (y/gridScale) % 2 == 0;

      fill(xGrid != yGrid ? gridCol : gridColAlt);

      square(x, y, gridScale);
    }
  }
}

void PlotPixel() {
  if (mousePressed) {
    if (mouseButton == LEFT) {
      PVector pixelPos = new PVector(mouseX / scaling, mouseY / scaling);
      if (!allPixels.containsKey(pixelPos)) {
        //If pixel doesnt exist at location, add one
        allPixels.put(pixelPos, currDrawColor);
      } else {
        //Pixel does exist at location
        //See if colour is different
        if (currDrawColor != allPixels.get(pixelPos)) {
          //Colour is different. Update pixel color
          allPixels.replace(pixelPos, currDrawColor);
        }
      }
    }
  }
}

void DrawPixels() {
  noStroke();
  for (Map.Entry<PVector, Integer> p : allPixels.entrySet()) {
    PVector drawPos = new PVector(p.getKey().x * scaling, p.getKey().y * scaling);
    fill(p.getValue());
    square(drawPos.x, drawPos.y, scaling);
  }
}

void mouseWheel(MouseEvent event) {
  float e  = event.getCount();

  scaling += (e * 8); 
  scaling  = scaling < int(scaleBounds.x) ? int(scaleBounds.x) : scaling;
  scaling = scaling > int(scaleBounds.y) ? int(scaleBounds.y) : scaling;

  println(scaling);
}
