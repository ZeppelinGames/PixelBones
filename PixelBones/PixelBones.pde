import java.util.Map;

HashMap<PVector, Integer> allPixels = new HashMap<PVector, Integer>();
PVector artSize = new PVector(16, 16);
color currDrawColour = color(0);

PVector cameraPos = new PVector(0, 0);

int scaling = 32;
PVector scaleBounds = new PVector(8, 128); //Min, max

UI ui[] = new UI[] {
  new ColourButton(new Rect(new PVector(25, 25), new PVector(25, 25)), color(0)), 
  new ColourPicker(new Rect(new PVector(50, 50), new PVector(100, 100)))
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
  strokeWeight(2);
  stroke(255);

  for (UI uiElement : ui) {
    fill(color(0));
    rect(uiElement.rect.position.x, uiElement.rect.position.y, uiElement.rect.scale.x, uiElement.rect.scale.y);

    if (mousePressed) {
      if (mouseButton == LEFT) {
        if (uiElement.rect.mouseOver()) {
          uiElement.OnClick();
        }
      }
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

boolean OverUIElements(UI[] uiElements) {
  boolean over = false;
  for (UI ui : uiElements) {
    if (ui.OverUI()) {
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

  public boolean OverUI() {
    boolean over = false;
    if (mouseX < rect.position.x + rect.scale.x && mouseX > rect.position.x) {
      if (mouseY < rect.position.y + rect.scale.y && mouseY > rect.position.y) {
        over = true;
      }
    }
    return over;
  }

  public void OnClick() {
  }
}

public class ColourButton extends UI {
  color buttonCol;

  public ColourButton(Rect rect, color buttonCol) 
  {
    this.rect = rect;
    this.buttonCol = buttonCol;
  }

  public  void OnClick() {
    println("CLICKED");
  }
}

public class ColourPicker extends UI {
  public ColourPicker(Rect rect) 
  {
    this.rect = rect;
  }
}
