6.835 Dance Augmenter, by Andy Kuang and Priscilla Wong

All the necessary code is included. If desired, it can also be viewed on GitHub at 
https://github.mit.edu/akuang/6835-dance

Files: 
Dance Main.pde 
	- The main code file to execute. Contains initialization of the Kinect, Kinect tracking, pose instantiation logic, pose checking logic, voice processing logic, and most importantly, all the state machine logic to transition between the different states of the system (gesture and voice).
KeyBoardOutput.pde
    - This file contains the keyTrigger code that, when called, triggers the desired keyboard stroke.
SkeletonPoser.pde
    - class PoseRule
    	- A class that defines the relations terminology between different joints (e.g. ABOVE), and performs the relations check
    - class SkeletonPoser
    	- A class that has a set of PoseRules, with a check function that checks if the user assumes a particular pose (e.g resting position) defined by all the PoseRules. 
TextToSpeechClass.pde
	- A class that is used for voice output from the system to the user. Contains a say command that is invoked in order to provide speech output. 
UIdrawingFunctions.pde
    - This file contains all the functions that are used to draw the user interface.


Necessary Hardware:
Mac running High Sierra or El Capitan
XBox Kinect

Necessary Resources and Setup Instructions (also listed in writeup)
Processing 3.5.3
https://processing.org/download/
The code for our system utilizes Processing, for both the SimpleOpenNI Kinect code as well as the user interface. Our system was tested on Processing 3.5.3.

Simple OpenNI for Processing
https://github.com/totovr/SimpleOpenNI
The author of this library was able to get the Kinect to work with the Mac, using Processing. The included demo code (depth maps, body tracking, joint detection) worked very well and was a good springboard to our main project. In addition to cloning this library, we followed the instructions under the instructions.md file to install libfreenect, as well as to copy the file libfreenect2-openni2.0.dylib to the Processing Simple OpenNI library folder. The library tested to work on both Mac High Sierra and Mac El Capitan.

Speech to Text Recognition Codepen for Processing - by Florian Schulz 
https://codepen.io/getflourish/pen/NpBGqe
Prior to using the Codepen, follow the instructions on http://florianschulz.info/stt/ to install the WebSockets library from https://github.com/alexandrainst/processing_websockets and create a Processing sketch that interacts with the Codepen. This is a Speech Recognition library that basically worked out of the box with Processing. A limitation, however, is that everytime the Processing sketch is recompiled, the Codepen must be refreshed.


