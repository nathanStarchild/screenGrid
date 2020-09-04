PGraphics pg;
int w = 800;
int h = 800;
float rw, rh, ratio;
int n, m;
int loopFrames = 30*30;
float zoom = 100;
boolean live = false;

Param rwObj, rMap, frameMap;

ArrayList<PImage> images = new ArrayList<PImage>();
int nVids = 1;

void setup() {
    size(800, 800, P2D);
    pg = createGraphics(w, h, P3D);
    pg.fill(255);
    pg.noStroke();

    ratio = 4.0/5.0;
    rw = 70;
    rh = rw / ratio;
    n = ceil(w / rw);
    m = ceil(h / rh);

    rMap = new Param(0.2, 1.7, 2*PI/loopFrames, new NoiseLoop(loopFrames/900.0, 0.0, 0.0));
    rMap.pause();
    loadImages();
}

void draw() {
    updateParams();
    pg.beginDraw();
    pg.background(0);
    for (int i=0; i<n; i++){
        float x = rw/2 + i * rw;
        for (int j=0; j<m + (i+1%2); j++){
            float y = j * rh + (i%2)*rh*0.5;
            float rDistort = rMap.getValue(x/zoom, y/zoom);
            int frame = int(map(rDistort, 0.2, 1.7, 0, 500));
            frame %= 256;
            pg.pushMatrix();
                pg.translate(0, 0, rDistort*100);
                myRect(x, y, rw * rDistort, ratio, frame);
            pg.popMatrix();
        }
    }
    // myRect(width/2, height/2, rw, ratio, frameCount%256);
    pg.endDraw();

    image(pg, 0, 0, width, height);
}

void myRect(float x, float y, float a, float ratio, int im) {
    float b = a / ratio;
    float gamma = asin(a/sqrt(a*a + b*b));
    float alpha = PI - 2*gamma;
    float beta = PI - alpha;
    float r = sqrt(a*a + b*b)/2.0;
    pg.noStroke();

    float theta = alpha/2.0;

    pg.textureMode(NORMAL);
    pg.beginShape();
    pg.texture(images.get(im));
    pg.vertex(x + r*cos(theta), y + r*sin(theta), 1-0.5*(1-ratio), 1);
    theta += beta;
    pg.vertex(x + r*cos(theta), y + r*sin(theta), 0.5*(1-ratio), 1);
    theta += alpha;
    pg.vertex(x + r*cos(theta), y + r*sin(theta), 0.5*(1-ratio), 0);
    theta += beta;
    pg.vertex(x + r*cos(theta), y + r*sin(theta), 1-0.5*(1-ratio), 0);
    pg.endShape(CLOSE);
}

void updateParams(){
    rMap.advance(1);
}

void loadImages() {
    for (int n=0; n<nVids; n++){
        for (int i=0; i<256; i++){
            images.add(loadImage("vid" + n + "/frame" + nf(i, 5) + ".jpg"));
            println("loading image vid" + n + "/frame" + nf(i, 5) + ".jpg");
        }
    }
}