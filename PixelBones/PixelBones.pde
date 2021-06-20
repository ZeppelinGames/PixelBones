import java.util.Map;

HashMap<PVector, Integer> allPixels = new HashMap<PVector, Integer>();
PVector artSize = new PVector(32, 32);
color currDrawColour = color(0);

IntList artPalette = new IntList(); //Store colours that have been used on canvas

PVector cameraPos = new PVector(0, 0);

int scaling = 32;
PVector scaleBounds = new PVector(8, 128); //Min, max

ArrayList<UI> ui = new ArrayList<UI>();

Mode currMode = Mode.DRAWING;
enum Mode {
  DRAWING, RIGGING, POSING
}

void setup() {
  size(800, 800);
  surface.setTitle("PixelBones");

  LoadUI();
}

void LoadUI() {
  ui.add(new ColourButton(new Rect(new PVector(25, 25), new PVector(25, 25)), color(0)));
  ui.add(new ColourPicker(new Rect(new PVector(50, 50), new PVector(250, 250))));
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
    DrawArtPalette();
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

      square(x + cameraPos.x, y + cameraPos.y, gridScale);
    }
  }

  stroke(255);
  strokeWeight(3);
  noFill();
  rect(cameraPos.x, cameraPos.y, artSize.x * scaling, artSize.y * scaling);
}

void UpdateUI() {
  for (UI uiElement : ui) {
    uiElement.drawUIElement();

    if (uiElement.clicked()) {
      uiElement.onClick();
    }
    if (uiElement.dragging()) {
      uiElement.onDrag();
    }
  }
}

void PlotPixel() {
  if (mousePressed) {
    if (mouseButton == LEFT) {
      if (!OverUIElements(ui.toArray(new UI[ui.size()]))) {
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

            if (!artPalette.hasValue(currDrawColour)) {
              artPalette.append(currDrawColour);
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
        color pixelCol = allPixels.get(pixelPos);
        allPixels.remove(pixelPos);

        //Remove colour from art palette if none are left
        boolean hasColour = false;
        for (Map.Entry<PVector, Integer> p : allPixels.entrySet()) {
          if (!hasColour) {
            if (p.getValue() == pixelCol) {
              hasColour = true;
            }
          }
        }

        if (!hasColour) {
          artPalette.removeValue(pixelCol);
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
    square(drawPos.x + cameraPos.x, drawPos.y + cameraPos.y, scaling);
  }
}

void DrawArtPalette() {
  int x = 0;
  int y=0;
  for (int n =0; n < artPalette.size(); n++) {
    fill(artPalette.get(n));
    stroke(255);
    square(25 + (x*25), 75 + (y * 25), 25);

    //Add palette button to UI

    x++;
    if (x >= 4) {
      x=0; 
      y++;
    }
  }
}

void SetDrawColour(color col) {
  currDrawColour = col;
}

UI[] getUIType(Class<? extends UI> uiClass) {  
  ArrayList<UI> uiTypeList = new ArrayList<UI>();

  for (UI uiElement : ui) {
    if (uiClass.isInstance(uiElement)) {
      uiTypeList.add(uiElement);
    }
  }

  return uiTypeList.toArray(new UI[uiTypeList.size()]);
}

boolean OverUIElements(UI[] uiElements) {
  boolean over = false;
  for (UI ui : uiElements) {
    if (ui.overUI()) {
      if (ui.active) {
        over = true;
      }
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
  boolean active = true;

  public boolean overUI() {
    if (active) {
      boolean over = false;
      if (mouseX < rect.position.x + rect.scale.x && mouseX > rect.position.x) {
        if (mouseY < rect.position.y + rect.scale.y && mouseY > rect.position.y) {
          over = true;
        }
      }
      return over;
    }
    return false;
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
  public boolean dragging() {
    if (overUI()) {
      if (mousePressed) { 
        if (mouseButton == LEFT) {
          return true;
        }
      }
    } 
    return false;
  }

  public void onClick() {
  }
  public void onDrag() {
  }

  public void drawUIElement() {
    if (active) {
      stroke(255);
      strokeWeight(2);
      fill(0);
      rect(rect.position.x, rect.position.y, rect.scale.x, rect.scale.y);
    }
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
    if (active) {
      println("Clicked Colour Button");
      UI[] colourPickers = getUIType(ColourPicker.class);
      for (UI cpUI : colourPickers) {
        ColourPicker cp = (ColourPicker)cpUI;
        if (cp.active) {
          cp.Close();
        } else {
          cp.Open();
        }
      }
    }
  }

  public void drawUIElement() {
    stroke(255);
    strokeWeight(2);
    fill(buttonCol);
    rect(rect.position.x, rect.position.y, rect.scale.x, rect.scale.y);
  }
}

public class PaletteButton extends UI {
  color buttonCol;

  public PaletteButton(Rect rect, color buttonCol) 
  {
    this.rect = rect;
    this.buttonCol = buttonCol;
  }

  public void onClick() {
    currDrawColour = buttonCol;
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
    if (active) {
      println("Clicked colour picker");
      if (mouseX < rect.position.x + rect.scale.x && mouseX > rect.position.x) {
        if (mouseY < rect.position.y + (rect.scale.y * 0.9) && mouseY > rect.position.y) {
          color newCol = get(mouseX, mouseY);
          SetDrawColour(newCol);
          UI[] colourButtons = getUIType(ColourButton.class);
          for (UI cbUI : colourButtons) {
            ColourButton cb = (ColourButton)cbUI;
            cb.buttonCol = newCol;
          }
        }
        if (mouseY < rect.position.y + rect.scale.y && mouseY > rect.position.y + (rect.scale.y * 0.9)) {
          PVector scaling = new PVector(255/rect.scale.x, 255/(rect.scale.y*0.9));
          h = mouseX * scaling.x - rect.position.x;
        }
      }
    }
  }

  public void onDrag() {
    if (active) {
      println("Clicked colour picker");
      if (mouseX < rect.position.x + rect.scale.x && mouseX > rect.position.x) {
        if (mouseY < rect.position.y + (rect.scale.y * 0.9) && mouseY > rect.position.y) {
          color newCol = get(mouseX, mouseY);
          SetDrawColour(newCol);
          UI[] colourButtons = getUIType(ColourButton.class);
          for (UI cbUI : colourButtons) {
            ColourButton cb = (ColourButton)cbUI;
            cb.buttonCol = newCol;
          }
        }
        if (mouseY < rect.position.y + rect.scale.y && mouseY > rect.position.y + (rect.scale.y * 0.9)) {
          PVector scaling = new PVector(255/rect.scale.x, 255/(rect.scale.y*0.9));
          h = mouseX * scaling.x - rect.position.x;
        }
      }
    }
  }

  public void Open() {
    active = true;
    drawUIElement();
  }
  public void Close() {
    active = false;
  }

  float h = 0;
  public void drawUIElement() {
    if (active) {
      PVector scaling = new PVector(255/rect.scale.x, 255/(rect.scale.y*0.9));
      noStroke();
      colorMode(HSB);
      for (int x = 1; x < rect.scale.x; x++) {
        fill(x*scaling.x, 255, 255);
        rect(x + rect.position.x, rect.position.y + (rect.scale.y  *0.9), 1, (rect.scale.y*0.1));
      }

      //Draw coloured pixels
      //fade from red to blue, left to right
      //Fade from white to black, top to bottom
      for (int x = 1; x < rect.scale.x; x++) {
        for (int y=1; y < rect.scale.y * 0.9; y++) {
          fill(h, x * scaling.x, y * scaling.y);
          square(rect.position.x + x, rect.position.y + y, 1);
        }
      }
      colorMode(RGB);

      stroke(255);
      strokeWeight(2);
      noFill();
      rect(rect.position.x, rect.position.y, rect.scale.x, rect.scale.y);
      rect(rect.position.x, rect.position.y  + (rect.scale.y * 0.9), rect.scale.x, rect.scale.y * 0.1);
    }
  }
}
