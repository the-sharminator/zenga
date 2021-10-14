import processing.sound.*;
SoundFile file;
boolean isPlaying = false;
boolean gameInProgres = false;
JengaTower jengaTower;

void setup() {
    fullScreen(P3D);
    frameRate(30);
    textSize(60);
    textAlign(CENTER, CENTER);
    jengaTower =  new JengaTower();
}

void draw() {
    background(25);
    camera(0, (gameInProgres ? -(jengaTower.towerSize.y * 100) : 0), (gameInProgres ? 2000 + mouseY : 2000), 0, 0, 0, 0, 1, 0);
    if (!gameInProgres) {
        fill(200);
        text(
            "ZENGA\nby william sharman\n\nw - up\ns - down\na - left\nd - right\nf - remove or place\nr - restart\nspace - open menu\nq - exit\n\npress space to begin",
            0,
            0);
    } else {
        jengaTower.displayTower();
    }
    if (!isPlaying) {
        file = new SoundFile (this, "music_dave_miles_warm_layers_006.mp3");
        file.loop();
        isPlaying = true;
    }
}

void keyPressed() {
    switch(key) {
        case ' ': gameInProgres = !gameInProgres; break;
        case 'q': exit(); break;
        case 'r': setup();
        default: jengaTower.towerInterface(); break;
    }
}
