// ActionScript file
import components.gauge.events.GaugeEvent;

import flash.external.ExternalInterface;
import flash.display.Bitmap;
import flash.media.Camera;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.utils.Timer;


import mx.controls.Alert;
//import mx.core.Application;
import mx.core.FlexGlobals;

NetConnection.defaultObjectEncoding = flash.net.ObjectEncoding.AMF3;
SharedObject.defaultObjectEncoding  = flash.net.ObjectEncoding.AMF3;

public var nc:NetConnection;
public var ns:NetStream;					//
[Bindable] public var so_chat:SharedObject;
public var camera:Camera;
public var mic:Microphone;
public var nsOutGoing:NetStream;
//public var nsInGoing:NetStream;
//public const ROOMMODEL:String="models";
[Bindable] public var myRecorder:Recorder;
public var DEBUG:Boolean = false;
public var recordingTimer:Timer = new Timer( 1000 , 0 );
[Bindable] public var timeLeft:String="";

public function fullScreenHandler(evt:FullScreenEvent):void {
	//dispState = FlexGlobals.topLevelApplication.stage.displayState;
	return;
    if (evt.fullScreen) {
    } else {
    	if (currentState=="") {
    		myWebcam.width=myRecorder.width;
    		myWebcam.height = myRecorder.height;
    	} else {
    		videoPlayer.width=myRecorder.width;
    		videoPlayer.height = myRecorder.height;    		
    		
    	}
    }
}			



private function fullScreen():void {

	try {
    	switch (FlexGlobals.topLevelApplication.stage.displayState) {
        	case StageDisplayState.FULL_SCREEN:
            	/* If already in full screen mode, switch to normal mode. */
            	FlexGlobals.topLevelApplication.stage.fullScreenSourceRect = new Rectangle (0,0,myRecorder.width,myRecorder.height);
            	FlexGlobals.topLevelApplication.stage.displayState = StageDisplayState.NORMAL;
            	break;
            default:
            	/* If not in full screen mode, switch to full screen mode. */
            	FlexGlobals.topLevelApplication.stage.fullScreenSourceRect = new Rectangle (0,0,320,240);
                FlexGlobals.topLevelApplication.stage.displayState = StageDisplayState.FULL_SCREEN;
                //Alert.show("full screen");
				break;
		}
	} catch (err:SecurityError) {
		Alert.show(err.message);
	}
}

public function init():void {
	myRecorder = new Recorder();
	
	if (DEBUG) {
		FlexGlobals.topLevelApplication.parameters.server="rtmp://192.168.1.10/red5recorder/";
		FlexGlobals.topLevelApplication.parameters.fileName="video";
		FlexGlobals.topLevelApplication.parameters.mode="player";
		FlexGlobals.topLevelApplication.parameters.logo ="fspace.png";
		FlexGlobals.topLevelApplication.parameters.fullScreen=true;
	}	
	
	// get parameters
	if(FlexGlobals.topLevelApplication.parameters.maxLength!=null) myRecorder.maxLength= FlexGlobals.topLevelApplication.parameters.maxLength;
	if(FlexGlobals.topLevelApplication.parameters.fileName!=null) myRecorder.fileName = FlexGlobals.topLevelApplication.parameters.fileName;
	if(FlexGlobals.topLevelApplication.parameters.width!=null) myRecorder.width= FlexGlobals.topLevelApplication.parameters.width;
	if(FlexGlobals.topLevelApplication.parameters.height!=null) myRecorder.height= FlexGlobals.topLevelApplication.parameters.height;
	if(FlexGlobals.topLevelApplication.parameters.server!=null) myRecorder.server= FlexGlobals.topLevelApplication.parameters.server;
	if(FlexGlobals.topLevelApplication.parameters.fps!=null) myRecorder.fps= FlexGlobals.topLevelApplication.parameters.fps;
	if(FlexGlobals.topLevelApplication.parameters.microRate!=null) myRecorder.microRate= FlexGlobals.topLevelApplication.parameters.microRate;
	if(FlexGlobals.topLevelApplication.parameters.showVolume!=null) myRecorder.showVolume = (FlexGlobals.topLevelApplication.parameters.showVolume=="true" || FlexGlobals.topLevelApplication.parameters.showVolume==1);
	if(FlexGlobals.topLevelApplication.parameters.recordingText!=null) myRecorder.recordingText= FlexGlobals.topLevelApplication.parameters.recordingText;
	if(FlexGlobals.topLevelApplication.parameters.timeLeftText!=null) myRecorder.timeLeftText= FlexGlobals.topLevelApplication.parameters.timeLeftText;
	if(FlexGlobals.topLevelApplication.parameters.timeLeft!=null) myRecorder.timeLeft= FlexGlobals.topLevelApplication.parameters.timeLeft;
	if(FlexGlobals.topLevelApplication.parameters.mode!=null) myRecorder.mode= FlexGlobals.topLevelApplication.parameters.mode;
	if(FlexGlobals.topLevelApplication.parameters.backToRecorder!=null) myRecorder.backToRecorder = (FlexGlobals.topLevelApplication.parameters.backToRecorder=="true" || FlexGlobals.topLevelApplication.parameters.backToRecorder==1);
	if(FlexGlobals.topLevelApplication.parameters.backText!=null) myRecorder.backText= FlexGlobals.topLevelApplication.parameters.backText;
	if(FlexGlobals.topLevelApplication.parameters.noVideo!=null) myRecorder.noVideo= (FlexGlobals.topLevelApplication.parameters.noVideo=="true" || FlexGlobals.topLevelApplication.parameters.noVideo==1);
	if(FlexGlobals.topLevelApplication.parameters.quality!=null) myRecorder.quality= FlexGlobals.topLevelApplication.parameters.quality;
	if(FlexGlobals.topLevelApplication.parameters.keyFrame!=null) myRecorder.keyFrame = FlexGlobals.topLevelApplication.parameters.keyFrame;
	if(FlexGlobals.topLevelApplication.parameters.urlForward!=null) myRecorder.urlForward = FlexGlobals.topLevelApplication.parameters.urlForward;
	if(FlexGlobals.topLevelApplication.parameters.logo!=null) myRecorder.logo = FlexGlobals.topLevelApplication.parameters.logo;
	if(FlexGlobals.topLevelApplication.parameters.fullScreen!=null) myRecorder.fullScreen = (FlexGlobals.topLevelApplication.parameters.fullScreen=="true" || FlexGlobals.topLevelApplication.parameters.fullScreen==1);
	//myRecorder.server="rtmp://207.134.71.251/red5recorder/";
	//myRecorder.server="rtmp://72.249.0.158/red5recorder/";

	
	if (myRecorder.noVideo==true) {
		myWebcam.visible=false;
	}
	stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenHandler);
		
	FlexGlobals.topLevelApplication.width = myRecorder.width;
	FlexGlobals.topLevelApplication.height = myRecorder.height;

	recordingTimer.addEventListener( "timer" , decrementTimer );

	timeLeft = myRecorder.maxLength.toString();
	myRecorder.timeLeft = myRecorder.maxLength; 
	formatTime();
	
  		nc=new NetConnection();		
		nc.client=this;		
		nc.addEventListener(NetStatusEvent.NET_STATUS,netStatusHandler);
		nc.connect(myRecorder.server);	
	
	if (myRecorder.mode=="player" || myRecorder.mode=="play") {
		currentState="player";
		if (myRecorder.fileName.indexOf(".flv")<=0) myRecorder.fileName+=".flv";
		var s:String = myRecorder.server+myRecorder.fileName;
		videoPlayer.source = s;
			
		//Alert.show("playing:"+videoPlayer.source);
		//videoPlayer.play();
		
	} else {
		currentState="";
	}

    ExternalInterface.addCallback('startRecord', recClicked);
    ExternalInterface.addCallback('playMovie', replay);
    ExternalInterface.addCallback('stopMovie', stopVideo);
    ExternalInterface.addCallback('stopRecord', stopClicked);
    ExternalInterface.addCallback('webcamParameters', webcamParameters);

    if (ExternalInterface.available) {
        ExternalInterface.call("camcorderOnload", myRecorder.fileName);
    }
}

private function recClicked():void {

    if (currentState == "player" || currentState == "play")
    {
        stopVideo();
        currentState="";
        myRecorder.mode = "record";
    }

    myRecorder.timeLeft = myRecorder.maxLength;
    formatTime();

		recordingTimer.start();
		recordStart();
}

private function stopClicked():void {
        recordingTimer.stop();
        recordFinished();
}

private function videoIsComplete():void {
	stopVideo();
}
private function thumbClicked(e:MouseEvent):void {
	//videoPlayer.playheadTime = position.value;
}
public function stopVideo():void {	
	var s:String = myRecorder.server+myRecorder.fileName+".flv";
	videoPlayer.source = s;
	videoPlayer.stop();

    if (ExternalInterface.available) {
        ExternalInterface.call("camcorderMovieStoped", myRecorder.fileName);
    }
}
private function replay():void {
    stopClicked();
    /**
    var myVideo:FLVPlayback = new FLVPlayback();
    myVideo.source = "http://www.appartoo.com:5080/red5recorder/streams/" + myRecorder.fileName + ".flv";

    addChild(myVideo);
     */

	currentState="player";
	var s:String = myRecorder.server+myRecorder.fileName+".flv";
	videoPlayer.source = s;
	// and start the video !
	play();
    //fullScreen();

}

private function play():void{
		videoPlayer.play();
}

private function pause():void{
        videoPlayer.pause();
}

private function thumbPressed():void {
	videoPlayer.pause();
}	


private function thumbReleased():void {
	//videoPlayer.playheadTime = position.value;
	return;
}

 private function formatPositionToolTip(value:Number):String{
	return value.toFixed(2) +" s";
 }
private function handleGaugeEvent( event:GaugeEvent ) : void{	
	videoPlayer.volume = event.value/100;
}
private function rollOut(e:MouseEvent):void {
}
private function rollOver(e:MouseEvent):void {
} 
private function netStatusHandler(event:NetStatusEvent):void {
	switch (event.info.code) {
	case "NetConnection.Connect.Failed":
		Alert.show("ERROR:Could not connect to: "+myRecorder.server);
	break;	
    case "NetConnection.Connect.Success":
    	prepareStreams();
    break;
	default:
		nc.close();
		break;
    }
}
public function recordStart():void {
	nsOutGoing.close();
    //nsOutGoing.bufferTime = 0.1;
    nsOutGoing.publish(myRecorder.fileName, "record");
	myRecorder.hasRecorded = true;

    if (ExternalInterface.available) {
        ExternalInterface.call("recordStarted", myRecorder.fileName);
    }
}
public function recordFinished():void {
	nsOutGoing.close();
    //nsOutGoing.bufferTime = 60;
    recordingTimer.stop();
    if (ExternalInterface.available) {
        ExternalInterface.call("recordFinished", myRecorder.fileName);
    }
}
private function formatTime():void {
	var minutes:int;
	var seconds:int;
	minutes = myRecorder.timeLeft / 60;
	seconds = myRecorder.timeLeft % 60;
	if (minutes<10) timeLeft="0"+ minutes+":" else timeLeft=minutes+":";
	if (seconds<10) timeLeft=timeLeft+"0"+ seconds else timeLeft=timeLeft+seconds;

    if (ExternalInterface.available) {
        ExternalInterface.call("camcorderTimeUpdated", myRecorder.fileName, timeLeft);
    }
}

private  function decrementTimer( event:TimerEvent ):void {
	myRecorder.timeLeft--;
	formatTime();	
	// format to display mm:ss format
	if (myRecorder.timeLeft<=0) {
		recordingTimer.stop();
		recordFinished();
	}
}

public function webcamParameters():void {
	Security.showSettings(SecurityPanel.DEFAULT);
}
private function drawMicLevel(evt:TimerEvent):void {
		var ac:int=mic.activityLevel;
		//micLevel.setProgress(ac,100);
}

private  function prepareStreams():void {
	if (myRecorder.mode!="record") return;
	nsOutGoing = new NetStream(nc);

    //nsOutGoing.bufferTime = 0;
    //nsOutGoing.backBufferTime = 0;
	camera=Camera.getCamera();
	if (camera==null) {
		Alert.show("Webcam not detected !");
	}
	if (camera!=null) {
		if (camera.muted) 	{
			Security.showSettings(SecurityPanel.DEFAULT);
		}
		camera.setMode(myRecorder.width,myRecorder.height,myRecorder.fps);
		camera.setKeyFrameInterval(myRecorder.keyFrame);
		camera.setQuality(0,myRecorder.quality);
		myWebcam.attachCamera(camera);
		nsOutGoing.attachCamera(camera);
		myRecorder.cameraDetected=true;
		camera.addEventListener(StatusEvent.STATUS, cameraStatus); 
	}	

	mic=Microphone.getMicrophone(0);
	if (mic!=null) {
        mic.rate=myRecorder.microRate;
        var timer:Timer=new Timer(50);
		//timer.addEventListener(TimerEvent.TIMER, drawMicLevel);
		timer.start();
		nsOutGoing.attachAudio(mic);
	}	
	//nsInGoing= new NetStream(nc);
    //nsInGoing.client=this;    
			            
}   
private function cameraStatus(evt:StatusEvent):void {
	switch (evt.code) {
	case "Camera.Muted":
		myRecorder.cameraDetected=false;
		break;
	case "Camera.Unmuted":
    	myRecorder.cameraDetected=true;
	break;
    }
}   
