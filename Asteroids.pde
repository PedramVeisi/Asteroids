/* Final Project for Creative Programming for Digital Media & Mobile Apps course - Coursera
   A port of RiceRocks miniproject from An Introduction to Interactive Programming in Python course.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.

   Copyright 2013 Pedram Veisi

*/

import processing.core.*;
import java.util.*;
import java.util.Collections;
import java.util.concurrent.ConcurrentHashMap;

// globals for user interface
int WIDTH = 800;
int HEIGHT = 600;
float VEL_CONSTANT = 0.5;
float ANGULAR_VEL_OFFSET = 0.15;
float FRICTION_CONSTANT = 0.01;
int MISSILE_VEL_CONSTANT = 15;
int ROCK_SHIP_DISTANCE_OFFSET = 50;
int[] LIVES_ICON_SIZE = { 30, 30 };

// Explosion Constants
int[] EXPLOSION_CENTER = { 64, 64 };
int[] EXPLOSION_SIZE = { 128, 128 };
int[] EXPLOSION_DIM = { 24, 1 };

Maxim maxim;
AudioPlayer missilePlayer;
AudioPlayer soundtrack;
AudioPlayer explosionSound;
AudioPlayer thrustSound;

Set<Sprite> rockGroup;
Set<Sprite> missileGroup;
Set<Sprite> explosionGroup;

PImage debrisImage, nebulaImage, splashImage, shipImage, missileImage, asteroidImage, explosionImage, livesImage, livesTextImage, scoreTextImage;
ImageInfo debrisInfo, nebulaInfo, splashInfo, shipInfo, missileInfo, asteroidInfo, explosionInfo, livesInfo, livesTextInfo, scoreTextInfo;

float time = (float) 0.5;
int score = 0;
int lives = 3;
boolean started = false;

Ship myShip;

void setup() {
 
  size(WIDTH, HEIGHT);
  background(0);

  // art assets created by Kim Lathrop, may be freely re-used in non-commercial projects, please credit Kim
      
  // debris images - debris1_brown.png, debris2_brown.png, debris3_brown.png, debris4_brown.png
  //                 debris1_blue.png, debris2_blue.png, debris3_blue.png, debris4_blue.png, debris_blend.png
  debrisInfo = new ImageInfo(new int[]{0, 0}, new int[]{800, 600}, 0, 1000000, false);
  debrisImage = loadImage("debris2_blue.png");
  
  // nebula images - nebula_brown.png, nebula_blue.png // http://www.flickr.com/photos/pedramveisi/5249301011/
  nebulaInfo = new ImageInfo(new int[]{0, 0}, new int[]{800, 600}, 0, 1000000, false);
  nebulaImage = loadImage("orion-nebula.jpg");
  
  // splash image
  splashInfo = new ImageInfo(new int[]{200, 150}, new int[]{400, 300}, 0, 1000000, false);
  splashImage = loadImage("splash.png");
  
  // ship image
  shipInfo = new ImageInfo(new int[]{0, 0}, new int[]{90, 90}, 35, 1000000, false);
  shipImage = loadImage("double_ship.png");
  
  // missile image - shot1.png, shot2.png, shot3.png
  missileInfo = new ImageInfo(new int[]{5,5}, new int[]{10, 10}, 3, 20, false);
  missileImage = loadImage("shot2.png");
  
  // asteroid images - asteroid_blue.png, asteroid_brown.png, asteroid_blend.png
  asteroidInfo = new ImageInfo(new int[]{45, 45}, new int[]{90, 90}, 40, 1000000, false);
  asteroidImage = loadImage("asteroid_blue.png");
  
  // animated explosion - explosion_orange.png, explosion_blue.png, explosion_blue2.png, explosion_alpha.png
  explosionInfo = new ImageInfo(new int[]{64, 64}, new int[]{128, 128}, 17, 24, true);
  explosionImage = loadImage("explosion_alpha.png");
  
  //lives image
  livesInfo = new ImageInfo(new int[]{25, 60}, new int[]{30, 30}, 1, 1000000, false);
  livesImage = loadImage("lives2.png");
  
  //lives text
  livesTextInfo = new ImageInfo(new int[]{40, 15}, new int[]{80, 30}, 0, 1000000, false);
  livesTextImage = loadImage("lives-text.png");
  
  //Score text
  scoreTextInfo = new ImageInfo(new int[]{52, 14}, new int[]{104, 28}, 0, 1000000, false);
  scoreTextImage = loadImage("score-text.png");
  
  maxim = new Maxim(this);

  soundtrack = maxim.loadFile("soundtrack.wav");    
  
  missilePlayer = maxim.loadFile("missile.wav");
  missilePlayer.setLooping(false);
  
  explosionSound = maxim.loadFile("explosion.wav");  
  explosionSound.setLooping(false);
  
  thrustSound = maxim.loadFile("thrust.wav");
  
  myShip = new Ship(new float[]{width / 2, height / 2}, new float[]{0, 0}, 0, shipImage, shipInfo);
  
  rockGroup = Collections.newSetFromMap(new ConcurrentHashMap<Sprite, Boolean>());
  missileGroup = Collections.newSetFromMap(new ConcurrentHashMap<Sprite, Boolean>());
  explosionGroup = Collections.newSetFromMap(new ConcurrentHashMap<Sprite, Boolean>());
  
  rockSpawner();
  
//  soundtrack.setLooping(true);
//  
//  soundtrack.cue(0);
//  soundtrack.play();
  
}

void draw() {

  //animiate background
  time += 0.015;
  int[] startCoordinate = debrisInfo.getStartCoordinate();
  int[] size = debrisInfo.getSize();
  float wtime = ((time / 8) % 1.1 * width) + width;
  
  
  image(nebulaImage, nebulaInfo.getStartCoordinate()[0], nebulaInfo.getStartCoordinate()[1], nebulaInfo.getStartCoordinate()[0]
        + nebulaInfo.getSize()[0], nebulaInfo.getStartCoordinate()[1] + nebulaInfo.getSize()[1]);
  
  image(debrisImage, - width + wtime, debrisInfo.getStartCoordinate()[1], debrisInfo.getStartCoordinate()[0]
        + debrisInfo.getSize()[0],  debrisInfo.getStartCoordinate()[1] + debrisInfo.getSize()[1]);
        
  image(debrisImage, - 2 * width + wtime, debrisInfo.getStartCoordinate()[1], debrisInfo.getStartCoordinate()[0]
        + debrisInfo.getSize()[0], debrisInfo.getStartCoordinate()[1] + debrisInfo.getSize()[1]);
     
     
  //draw ship and sprites
  myShip.draw();
  processSpriteGroup(rockGroup);
  processSpriteGroup(missileGroup);
  processSpriteGroup(explosionGroup);
        
  //update ship and sprites
  myShip.update();

  //Collision Detection
  lives -= groupCollide(rockGroup, myShip);
  score += groupGroupCollide(missileGroup, rockGroup);
    
  //Draw lives and score
  int textHeight = 20;
  int numberHeight = 90;
  
  int livesOffset = 30;
  
  int scoreTextOffset = 90;
  int scoreImageOffset = 130;
        
  image(scoreTextImage, width - scoreImageOffset, textHeight);                      
  
  textSize(32);
  text(score, width - scoreTextOffset, numberHeight);
  
  image(livesTextImage, livesOffset, textHeight);
  
  
  for(int i = 0; i < lives; i++)
    //size(livesInfo.getSize()[0], livesInfo.getSize()[1]);
    image(livesImage, livesInfo.getStartCoordinate()[0] + i * LIVES_ICON_SIZE[0],
                      livesInfo.getStartCoordinate()[1],
                      livesInfo.getSize()[0], livesInfo.getSize()[1]
                      ); 
  
  //Background image info
  String message = "Background image is my own work: http://www.flickr.com/photos/pedramveisi/5249301011/";
  textSize(12);
  text(message, 10, HEIGHT - 10);   
 
 
  //Game restart
  if(lives == 0){
    rockGroup = new HashSet<Sprite>();
    started = false;
  }
  //draw splash screen if not started
  if(!started){
     int[] splashCoordinates = splashInfo.getStartCoordinate();
     image(splashImage, splashCoordinates[0], splashCoordinates[1]);
  }
 
}

//mouseclick handlers that reset UI and conditions whether splash image is drawn
void mousePressed(){

  float[] center = new float[] {width / 2, height / 2};
  int[] size = splashInfo.getSize();
  boolean inWidth = false, inHeight = false;
  
  if((center[0] - size[0] / 2) < mouseX && mouseX < (center[0] + size[0] / 2))
    inWidth = true;
  
  if((center[1] - size[1] / 2) < mouseY && mouseY < (center[1] + size[1] / 2))
    inHeight = true;
  
  if (!started && inWidth && inHeight){
    started = true;
    myShip.setPosition(center);
    myShip.setVel(new float[]{0, 0});
    myShip.setAngle(0);
    lives = 3;
    score = 0;
    soundtrack.cue(0);
    soundtrack.play();
  }
}

void keyPressed(){
  if (keyCode == LEFT)
    myShip.decAngularVel();
  else if (keyCode == RIGHT)
    myShip.incAngularVel();
  else if (keyCode == UP)
    myShip.setThrust(true);
  else if (keyCode == ' ')
    myShip.shoot();   
}

void keyReleased(){  
  if (keyCode == LEFT)
    myShip.incAngularVel();
  else if (keyCode == RIGHT)
    myShip.decAngularVel();
  else if (keyCode == UP)
    myShip.setThrust(false);
}

//timer handler that spawns a rock    
void rockSpawner(){
  new Timer().schedule(new TimerTask() {
  public void run() {
    //Multplication and division by 100 to create more randomeness
    float[] rockPos = new float[]{random(width), random(height)};
    float[] rockVel = new float[] {random(0, 1) * 0.6 + score / 5, random(0, 1) * 0.6 + score / 5};
    float rockAngVel = random(0, 1) * 0.2 - 0.1 + score / 100;
    
    double rockShipDistance = calculateDistance(myShip.getPosition(), rockPos);
    if(rockGroup.size() < 12 && started && rockShipDistance > myShip.getRadius() + ROCK_SHIP_DISTANCE_OFFSET)
        rockGroup.add(new Sprite(rockPos, rockVel, 0, rockAngVel, asteroidImage, asteroidInfo));
  }
}, 1, 1000);

}

void processSpriteGroup(Set<Sprite> group){  
  
  for (Iterator<Sprite> iterator = group.iterator(); iterator.hasNext();) {
    Sprite sprite = iterator.next();
    if (sprite.update()) {
        iterator.remove();
    }
    sprite.draw();
  }
}


int groupCollide(Set<Sprite> group, Sprite otherObject){
  
  int collisionCount = 0;
  Iterator<Sprite> iterator = group.iterator();
  while (iterator.hasNext()) {
    Sprite sprite = iterator.next();
    if (sprite.collide(otherObject)) {
      collisionCount += 1;
      explosionGroup.add(new Sprite(sprite.getPosition(), new float[]{0, 0}, 0, 0, explosionImage, explosionInfo, explosionSound));
      iterator.remove();
    }
  }
  return collisionCount;
}

int groupGroupCollide(Set<Sprite> groupOne, Set<Sprite> groupTwo){
  int collisionCount = 0;
    
  Iterator<Sprite> iterator = groupOne.iterator();
  while (iterator.hasNext()) {
    Sprite sprite = iterator.next();
    collisionCount += groupCollide(groupTwo, sprite);
    if (collisionCount != 0)
      iterator.remove();
  }
  
  return collisionCount;
}

//helper functions to handle transformations
float[] angleToVector(float ang){
    return new float[]{cos(ang), sin(ang)};
}

double calculateDistance(float[] posOne, float[] posTwo){
    return Math.sqrt(Math.pow((posOne[0] - posTwo[0]), 2) + Math.pow((posOne[1] - posTwo[1]), 2));
}

class ImageInfo{
  
  int[] startCoordinate, size;
  int radius, lifespan;
  boolean animated;
  
  ImageInfo(int[] startCoordinate, int[] size, int radius, int lifespan, boolean animated){
      this.startCoordinate = startCoordinate;
      this.size = size;
      this.radius = radius;
      this.lifespan = lifespan;           
      this.animated = animated;
    }
    int[] getStartCoordinate(){
        return this.startCoordinate;
    }
    int[] getSize(){
        return this.size;
    }
    int getRadius(){
        return this.radius;
    }
    int getLifespan(){
        return this.lifespan;
    }
    boolean getAnimated(){
        return this.animated;
    }
}

//Ship class
class Ship extends Sprite{
  
  int[] imageStartCoordinate, shipSize;
  int radius;
  float[] pos, vel;
  float angleVel, angle;
  boolean thrust;
  PImage shipImage;
  ImageInfo info;
  
  Ship(float[] pos, float[] vel, float angle, PImage image, ImageInfo info){
    super(pos, vel, angle, 0, image, info);
    this.pos = pos;
    this.vel = vel;
    this.thrust = false;
    this.angle = angle;
    this.angleVel = 0;
    this.shipImage = image;
    this.imageStartCoordinate = info.getStartCoordinate();
    this.shipSize = info.getSize();
    this.radius = info.getRadius();      
  }
  
  float[] getPosition(){
    return this.pos;
  }
  void setPosition(float[] pos){
    this.pos = pos;
  }
  void setVel(float[] vel){
    this.vel = vel;
  }
  void setAngle(float angle){
    this.angle = angle;
  }
  int getRadius(){
    return this.radius;    
  }
   
  void draw(){
    
    imageMode(CENTER);
    pushMatrix();
    
    translate(pos[0], pos[1]);
    rotate(this.angle);
      
    if(this.thrust){      
      image(this.shipImage.get(this.shipImage.width / 2, 0, this.shipImage.width / 2, this.shipImage.height), 0, 0);
    }else{
      image(this.shipImage.get(0, 0, this.shipImage.width / 2, this.shipImage.height), 0, 0);      
    }
    
    popMatrix();
    imageMode(CORNER);
  }
  
  
  boolean update(){
        
    //Position Update
    this.pos[0] = (this.pos[0] + this.vel[0] + width) % width;
    this.pos[1] = (this.pos[1] + this.vel[1] + height) % height;
     
    //Angle Update
    this.angle += this.angleVel;
     
    //Velocity Update - Acceleration in direction of forward vector
    float[] forwardVector = angleToVector(this.angle);
    if(this.thrust){
      this.vel[0] += forwardVector[0] * VEL_CONSTANT;
      this.vel[1] += forwardVector[1] * VEL_CONSTANT;
    }      
    //Friction Update
    this.vel[0] *= (1 - FRICTION_CONSTANT);
    this.vel[1] *= (1 - FRICTION_CONSTANT);

    return true;    
  }
   
  void incAngularVel(){
    this.angleVel += ANGULAR_VEL_OFFSET;
  }

  void decAngularVel(){
    this.angleVel -= ANGULAR_VEL_OFFSET;
  }
  
  void setThrust(boolean thrust){
    this.thrust = thrust;
  
    if(this.thrust){
      thrustSound.play();
    }else{
      thrustSound.stop();
    }
  }   
  
  
  void shoot(){
    
    float[] forward = angleToVector(this.angle);
    float[] missilePos = new float[]{this.pos[0] + this.radius * forward[0], this.pos[1] + this.radius * forward[1]};
    float[] missileVel = new float[]{this.vel[0] + MISSILE_VEL_CONSTANT * forward[0], this.vel[1] + MISSILE_VEL_CONSTANT * forward[1]};       
        
    missileGroup.add(new Sprite(missilePos, missileVel, this.angle, (float)0, missileImage, missileInfo, missilePlayer));

  }

}

//Sprite class
class Sprite{
  
  int[] startCoordinate, imageSize;
  int radius, lifespan, age;
  float[] pos, vel;
  float angleVel, angle;
  boolean animated;
  PImage image;
  
  Sprite(float[] pos, float[] vel, float angle, float angleVel, PImage image, ImageInfo info, AudioPlayer sound){
    this.pos = pos;
    this.vel = vel;
    this.angle = angle;
    this.angleVel = angleVel;
    this.image = image;
    this.startCoordinate = info.getStartCoordinate();
    this.imageSize = info.getSize();
    this.radius = info.getRadius();
    this.lifespan = info.getLifespan();
    this.animated = info.getAnimated();
    this.age = 0;
    if(sound != null){
      sound.cue(0);
      sound.play();
    }
  }
  
  Sprite(float[] pos, float[] vel, float angle, float angleVel, PImage image, ImageInfo info){
    this(pos, vel, angle, angleVel, image, info, null);
  }
  
    
  float[] getPosition(){
    return this.pos;
  }

  int getRadius(){
    return this.radius; 
  }   

  void draw(){
    if(this.animated){

      int[] explosionIndex = new int[]{this.age % EXPLOSION_DIM[0], ((int)(this.age / EXPLOSION_DIM[0])) % EXPLOSION_DIM[1]};      
      int[] explostionImageFragment = new int[]{explosionIndex[0] * EXPLOSION_SIZE[0], 0};
      imageMode(CENTER);
      image(explosionImage.get(explostionImageFragment[0], explostionImageFragment[1], EXPLOSION_SIZE[0], EXPLOSION_SIZE[1]), this.pos[0], this.pos[1]);
      imageMode(CORNER);
      
    }else{
      
      imageMode(CENTER); 
      pushMatrix();
      translate(pos[0], pos[1]);
      rotate(this.angle);
      image(this.image, 0, 0);
      popMatrix();
      imageMode(CORNER); 
    }
  }
  
  
  boolean update(){       
      //Position Update
      this.pos[0] = (this.pos[0] + this.vel[0]) % width;
      this.pos[1] = (this.pos[1] + this.vel[1]) % height;
   
      //Angle Update
      this.angle += this.angleVel;     
      
      //Age Update
      this.age += 1;
      if(this.age >= this.lifespan)
          return true;
      else
          return false;
  }
  boolean collide(Sprite otherObject){
      float[] thisPos = this.getPosition();
      float[] otherPos = otherObject.getPosition();
      double distance = calculateDistance(thisPos, otherPos);
      
      if(distance < this.getRadius() + otherObject.getRadius())
          return true;
      else
          return false;
  }
}



