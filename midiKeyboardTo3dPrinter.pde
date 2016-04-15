/**
* Midi Keyboard to 3D Printer
* by FMS_Cat
* tested with BonsaiLab BS01+, MicroKORG, YAMAHA UX16, and MacBook Pro
* press R key to init
* MIT License
*/

// ---

final boolean SERIAL_LIST = false;
final boolean MIDI_LIST = false;

// ---

import processing.serial.*;
import themidibus.*;

// ---

Serial serial;
MidiBus midiBus;

float x = 0.0;
boolean xDir = false;
float y = 0.0;
boolean yDir = false;
float z = 100.0;

int [] notes = new int[ 2 ];
int nextEvent = 0;
boolean inited = false;

// ---

void setup() {
  size( 400, 400 );
  background( 0 );
  frameRate( 1000 );
  
  String [] serialList = Serial.list();
  if ( SERIAL_LIST ) {
    println( serialList );
    exit();
  } else {
    serial = new Serial( this, "/dev/cu.usbmodem1421", 115200 );
  }
  
  if ( MIDI_LIST ) {
    MidiBus.list();
    exit();
  } else {
    midiBus = new MidiBus( this, "Port1", -1 );
  }
}

void draw() {
  int now = millis();
  
  if ( !inited ) {
    return;
  }
  
  if ( nextEvent < now + 10 ) {
    int interval = 50;
    nextEvent += interval;
    
    int axis = 0;
    float feedX = 0.0;
    float feedY = 0.0;
    
    if ( 0 != notes[ 0 ] ) {
      float pitch = pow( 2.0, ( notes[ 0 ] - 96.0 - 5.0 ) / 12.0 );
      x += ( xDir ? -1.0 : 1.0 ) * pitch;
      if ( 50.0 < x ) { xDir = true; }
      if ( x < 10.0 ) { xDir = false; }
      feedX = pitch;
    }
    
    if ( 0 != notes[ 1 ] ) {
      float pitch = pow( 2.0, ( notes[ 1 ] - 96.0 - 5.0 ) / 12.0 );
      y += ( yDir ? -1.0 : 1.0 ) * pitch;
      if ( 50.0 < y ) { yDir = true; }
      if ( y < 10.0 ) { yDir = false; }
      feedY = pitch;
    }
    
    float feed = dist( 0.0, 0.0, feedX, feedY );
    serialG1( x, y, z, 1000.0 / interval * 60.0 * feed );
  }
}

void serialG1( float _x, float _y, float _z, float _f ) {
  serial.write( "G1 X" + _x + " Y" + _y + " Z" + _z + " F" + _f + "\n" );
}

void initPosition() {
  x = 30.0;
  y = 30.0;
  z = 100.0;
  
  serial.write( "G28\n" );
  serialG1( x, y, z, 4000 );
  inited = true;
}

void noteOn( int _ch, int _pitch, int _vel ) {
  if ( 0 == notes[ 0 ] ) {
    notes[ 0 ] = _pitch;
  } else if ( 0 == notes[ 1 ] ) {
    notes[ 1 ] = _pitch;
  }
  println( "on  : " + _ch + ", " + _pitch + ", " + _vel );
}

void noteOff( int _ch, int _pitch, int _vel ) {
  if ( _pitch == notes[ 0 ] ) {
    notes[ 0 ] = 0;
  } else if ( _pitch == notes[ 1 ] ) {
    notes[ 1 ] = 0;
  }
  println( "off : " + _ch + ", " + _pitch + ", " + _vel );
}

void keyPressed() {
  if ( key == 'r' ) {
    initPosition();
  }
}