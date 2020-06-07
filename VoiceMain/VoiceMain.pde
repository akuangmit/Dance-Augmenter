/*
  Simple WebSocketServer example that can receive voice transcripts from Chrome
  Requires WebSockets Library: https://github.com/alexandrainst/processing_websockets
 */

import websockets.*;

WebsocketServer socket;
Process lastVoiceProcess;
void setup() {
  socket = new WebsocketServer(this, 1337, "/p5websocket");
}

void draw() { 
  background(0);
}          

void webSocketServerEvent(String msg){
  if (msg.toLowerCase().contains("stop") && !(msg.toLowerCase().contains("video"))){
    keyTrigger(STOPSTART);
    TextToSpeech.say("video stopped", "Victoria", 200);
  } else if (msg.toLowerCase().contains("start") && !(msg.toLowerCase().contains("video"))){
    keyTrigger(STOPSTART);
    TextToSpeech.say("video started", "Victoria", 200);
  } else if (msg.toLowerCase().contains("speed up") && !(msg.toLowerCase().contains("video"))){
    keyTrigger(SPEEDUP); 
    TextToSpeech.say("video sped up", "Victoria", 200);
  } else if (msg.toLowerCase().contains("slow down") && !(msg.toLowerCase().contains("video"))){
    keyTrigger(SLOWDOWN);
    TextToSpeech.say("video slowed down", "Victoria", 200);
  } else if (msg.toLowerCase().contains("rewind") && !(msg.toLowerCase().contains("video"))){
    keyTrigger(REWIND);
    TextToSpeech.say("video rewineded", "Victoria", 200);
  } else if (msg.toLowerCase().contains("fast forward") && !(msg.toLowerCase().contains("video"))){
    keyTrigger(FASTFORWARD);
    TextToSpeech.say("video fast forwarded", "Victoria", 200);
  }
 println(msg);
}
