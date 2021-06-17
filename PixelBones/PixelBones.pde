import java.util.Map;

HashMap<PVector, Integer> allPixels = new HashMap<PVector, Integer>();
PVector artSize = new PVector(16, 16);
color currDrawColour = color(0);

PVector cameraPos = new PVector(0, 0);

int scaling = 32;
PVector scaleBounds = new PVector(8, 128); //Min, max

UI ui[] = new UI[] {
  new ColourButton(new Rect(new PVector(25, 25), new PVector(25, 25)), color(0)), 
  new ColourPicker(new Rect(new PVector(50, 50), new PVector(250, 250)))
};

Mode currMode = Mode.DRAWING;
enum Mode {
  DRAWING, RIGGING, POSING
}

void setup() {
  size(800, 800);
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
    RemovePixel();
    DrawPixels();
    UpdateUI();

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

  for (int x =0; x < artSize.x * scaling; x+= gridScale) {
    for (int y =0; y <  artSize.y * scaling; y += gridScale) {
      boolean xGrid = (x/gridScale) % 2 == 0;
      boolean yGrid = (y/gridScale) % 2 == 0;

      fill(xGrid != yGrid ? gridCol : gridColAlt);

      square(x +cameraPos.x, y+cameraPos.y, gridScale);
    }
  }
}

void UpdateUI() {
  for (UI uiElement : ui) {
    uiElement.drawUIElement();

    if (uiElement.clicked()) {
      uiElement.onClick();
    }
  }
}

void PlotPixel() {
  if (mousePressed) {
    if (mouseButton == LEFT) {
      if (!OverUIElements(ui)) {
        PVector pixelPos = new PVector(int((mouseX - cameraPos.x) / scaling), int((mouseY - cameraPos.y) / scaling));

        if (pixelPos.x >= 0 && pixelPos.y >= 0) { 
          if (pixelPos.x < artSize.x && pixelPos.y < artSize.y) {
            if (!allPixels.containsKey(pixelPos)) {
              //If pixel doesnt exist at location, add one
              allPixels.put(pixelPos, currDrawColour);
            } else {
              //Pixel does exist at location
              //See if colour is different
              if (currDrawColour != allPixels.get(pixelPos)) {
                //Colour is different. Update pixel color
                allPixels.replace(pixelPos, currDrawColour);
              }
            }
          }
        }
      }
    }
  }
}

void RemovePixel() {
  if (mousePressed) {
    if (mouseButton == RIGHT) {
      PVector pixelPos = new PVector(int((mouseX - cameraPos.x) / scaling), int((mouseY - cameraPos.y) / scaling));
      if (allPixels.containsKey(pixelPos)) {
        allPixels.remove(pixelPos);
      }
    }
  }
}

void DrawPixels() {
  noStroke();
  for (Map.Entry<PVector, Integer> p : allPixels.entrySet()) {
    PVector drawPos = new PVector(p.getKey().x * scaling, p.getKey().y * scaling);
    fill(p.getValue());
    square(drawPos.x + cameraPos.x, drawPos.y + cameraPos.y, scaling);
  }
}

void SetDrawColour(color col) {
  currDrawColour = col;
}

boolean OverUIElements(UI[] uiElements) {
  boolean over = false;
  for (UI ui : uiElements) {
    if (ui.overUI()) {
      over = true;
    }
  }
  return over;
}

PVector lastDragPos = new PVector(0, 0);
boolean dragging = false;
PVector unscaledCameraPos = new PVector(0, 0);
void mouseDragged() {
  if (mouseButton == CENTER) {
    if (!dragging) {
      lastDragPos = new PVector(mouseX, mouseY);
      dragging = true;
    }
  }

  if (dragging) {
    unscaledCameraPos = new PVector(unscaledCameraPos.x  + (mouseX - lastDragPos.x), unscaledCameraPos.y + ( mouseY - lastDragPos.y));
    cameraPos = new PVector(int(unscaledCameraPos.x / scaling) * scaling, int(unscaledCameraPos.y / scaling) * scaling);
    lastDragPos = new PVector(mouseX, mouseY);
  }
}

void mouseReleased() {
  if (mouseButton == CENTER) {
    dragging=false;
  }
}

void mouseWheel(MouseEvent event) {
  float e  = event.getCount();

  scaling += (e * 8); 
  scaling  = scaling < int(scaleBounds.x) ? int(scaleBounds.x) : scaling;
  scaling = scaling > int(scaleBounds.y) ? int(scaleBounds.y) : scaling;

  println(scaling);
}

public class Rect {
  PVector position;
  PVector scale;

  public Rect() {
    this.position = new PVector(0, 0);
    this.scale = new PVector(1, 1);
  }

  public Rect(PVector pos, PVector scl) {
    this.position = pos;
    this.scale = scl;
  }

  public boolean mouseOver() {
    if (mouseX > position.x && mouseX < position.x + scale.x) {
      if (mouseY > position.y && mouseY < position.y  +scale.y) {
        return true;
      }
    }
    return false;
  }
}

public class UI 
{
  Rect rect;

  public boolean overUI() {
    boolean over = false;
    if (mouseX < rect.position.x + rect.scale.x && mouseX > rect.position.x) {
      if (mouseY < rect.position.y + rect.scale.y && mouseY > rect.position.y) {
        over = true;
      }
    }
    return over;
  }

  boolean mouseDown = false;
  public boolean clicked() {
    if (overUI()) {
      if (mousePressed) { 
        if (mouseButton == LEFT) {
          mouseDown = true;
        }
      } else {
        if (mouseDown) {
          mouseDown = false;
          return true;
        }
      }
    }
    return false;
  }

  public void onClick() {
  }

  public void drawUIElement() {
    stroke(255);
    strokeWeight(2);
    fill(0);
    rect(rect.position.x, rect.position.y, rect.scale.x, rect.scale.y);
  }
}

public class ColourButton extends UI {
  color buttonCol;

  public ColourButton(Rect rect, color buttonCol) 
  {
    this.rect = rect;
    this.buttonCol = buttonCol;
  }

  public void onClick() {
    println("Clicked Colour Button");
  }

  public void drawUIElement() {
    stroke(255);
    strokeWeight(2);
    fill(buttonCol);
    rect(rect.position.x, rect.position.y, rect.scale.x, rect.scale.y);
  }
}

public class ColourPicker extends UI {
  public ColourPicker(Rect rect) 
  {
    this.rect = rect;
  }

  public void onClick() {
    println("Clicked colour picker");
    SetDrawColour(get(mouseX, mouseY));
  }

  public void drawUIElement() {
    stroke(255);
    strokeWeight(2);
    fill(0);
    rect(rect.position.x, rect.position.y, rect.scale.x, rect.scale.y);

    //Draw coloured pixels
    //fade from red to blue, left to right
    //Fade from white to black, top to bottom
    noStroke();
    PVector scaling = new PVector(255/rect.scale.x, 255/rect.scale.y);
    for (int x = 1; x < rect.scale.x; x++) {
      for (int y=1; y < rect.scale.y; y++) {
        fill((x * scaling.x)+(y * scaling.x)/2%2, (rect.scale.x * scaling.x)-(y * scaling.x), (x * scaling.x) %2);
        square(rect.position.x + x, rect.position.y + y, 1);
      }
    }
  }
}
