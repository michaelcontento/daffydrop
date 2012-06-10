
// Flash mojo runtime.
//
// Copyright 2011 Mark Sibly, all rights reserved.
// No warranty implied; use at your own risk.

import flash.display.*;
import flash.events.*;
import flash.media.*;
import flash.geom.*;
import flash.utils.*;
import flash.net.*;

var app:gxtkApp;

class gxtkApp{

	internal var graphics:gxtkGraphics;
	internal var input:gxtkInput;
	internal var audio:gxtkAudio;

	internal var dead:int=0;
	internal var suspended:int=0;
	internal var loading:int=0;
	internal var maxloading:int=0;
	internal var updateRate:int=0;
	internal var nextUpdate:Number=0;
	internal var updatePeriod:Number=0;
	internal var startMillis:Number=0;
	
	function gxtkApp(){
		app=this;
		
		graphics=new gxtkGraphics;
		input=new gxtkInput;
		audio=new gxtkAudio;
		
		startMillis=(new Date).getTime();
		
		game.stage.addEventListener( Event.ACTIVATE,OnActivate );

		game.stage.addEventListener( Event.DEACTIVATE,OnDeactivate );
		
		game.stage.addEventListener( Event.ENTER_FRAME,OnEnterFrame );
		
		SetFrameRate( 0 );
		
		game.runner=function():void{
			InvokeOnCreate();
			InvokeOnRender();
		};
	}

	internal function IncLoading():void{
		++loading;
		if( loading>maxloading ) maxloading=loading;
		if( loading!=1 ) return;
		if( updateRate ) SetFrameRate( 0 );
	}

	internal function DecLoading():void{
		--loading;
		if( loading ) return;
		maxloading=0;
		if( updateRate ) SetFrameRate( updateRate );
	}
	
	internal function SetFrameRate( fps:int ):void{
		if( fps ){
			updatePeriod=1000.0/fps;
			nextUpdate=(new Date).getTime()+updatePeriod;
			game.stage.frameRate=fps;
		}else{
			updatePeriod=0;
			game.stage.frameRate=24;
		}
	}
	
	internal function OnActivate( e:Event ):void{
		if( Config.MOJO_AUTO_SUSPEND_ENABLED=="true" ){
			app.InvokeOnResume();
		}
	}
	
	internal function OnDeactivate( e:Event ):void{
		if( Config.MOJO_AUTO_SUSPEND_ENABLED=="true" ){
			app.InvokeOnSuspend();
		}
	}
	
	internal function OnEnterFrame( e:Event ):void{
		if( !updatePeriod ) return;
		
		var updates:int=0;

		for(;;){
			nextUpdate+=updatePeriod;
			InvokeOnUpdate();
			if( !updatePeriod ) break;
			
			if( nextUpdate>(new Date).getTime() ) break;
			
			if( ++updates==7 ){
				nextUpdate=(new Date).getTime();
				break;
			}
		}
		InvokeOnRender();
	}
	
	internal function Die( err:String ):void{
		dead=1;
		audio.OnSuspend();
		showError( err );
	}
	
	internal function InvokeOnCreate():void{
		if( dead ) return;
		
		try{
			dead=1;
			OnCreate();
			dead=0;
		}catch( err:String ){
			Die( err );
		}
	}

	internal function InvokeOnUpdate():void{
		if( dead || suspended || !updateRate || loading ) return;
		
		try{
			input.BeginUpdate();
			OnUpdate();
			input.EndUpdate();
		}catch( err:String ){
			Die( err );
		}
	}

	internal function InvokeOnRender():void{
		if( dead || suspended ) return;
		
		try{
			graphics.BeginRender();
			if( loading ){
				OnLoading();
			}else{
				OnRender();
			}
			graphics.EndRender();
		}catch( err:String ){
			Die( err );
		}
	}
	
	internal function InvokeOnSuspend():void{
		if( dead || suspended ) return;
		
		try{
			suspended=1;
			OnSuspend();
			audio.OnSuspend();
		}catch( err:String ){
			Die( err );
		}
	}
	
	internal function InvokeOnResume():void{
		if( dead || !suspended ) return;
		
		try{
			audio.OnResume();
			OnResume();
			suspended=0;
		}catch( err:String ){
			Die( err );
		}
	}
	
	//***** GXTK API *****
	
	public function GraphicsDevice():gxtkGraphics{
		return graphics;
	}

	public function InputDevice():gxtkInput{
		return input;
	}

	public function AudioDevice():gxtkAudio{
		return audio;
	}

	public function AppTitle():String{
		return graphics.bitmap.loaderInfo.url;
	}
	
	public function LoadState():String{
		var file:SharedObject=SharedObject.getLocal( "gxtkapp" );
		var state:String=file.data.state;
		file.close();
		if( state ) return state;
		return "";
	}
	
	public function SaveState( state:String ):int{
		var file:SharedObject=SharedObject.getLocal( "gxtkapp" );
		file.data.state=state;
		file.close();
		return 0;
	}
	
	public function LoadString( path:String ):String{
		return game.loadString( path );
	}

	public function SetUpdateRate( hertz:int ):int{
		updateRate=hertz;

		if( !loading ) SetFrameRate( updateRate );

		return 0;
	}
	
	public function MilliSecs():int{
		return (new Date).getTime()-startMillis;
	}

	public function Loading():int{
		return loading;
	}

	public function OnCreate():int{
		return 0;
	}

	public function OnUpdate():int{
		return 0;
	}
	
	public function OnSuspend():int{
		return 0;
	}
	
	public function OnResume():int{
		return 0;
	}
	
	public function OnRender():int{
		return 0;
	}
	
	public function OnLoading():int{
		return 0;
	}

}

class gxtkGraphics{
	internal var bitmap:Bitmap;
	
	internal var red:Number=255;
	internal var green:Number=255;
	internal var blue:Number=255;
	internal var alpha:Number=1;
	internal var colorARGB:uint=0xffffffff;
	internal var colorTform:ColorTransform=null;
	internal var alphaTform:ColorTransform=null;
	
	internal var matrix:Matrix;
	internal var rectBMData:BitmapData;
	internal var blend:String;
	internal var clipRect:Rectangle;
	
	internal var shape:Shape;
	internal var graphics:Graphics;
	internal var bitmapData:BitmapData;

	internal var pointMat:Matrix=new Matrix;
	internal var rectMat:Matrix=new Matrix;
	
	internal var image_filtering_enabled:Boolean;
	
	function gxtkGraphics(){
	
		var stage:Stage=game.stage;
	
		bitmap=new Bitmap();
		bitmap.bitmapData=new BitmapData( stage.stageWidth,stage.stageHeight,false,0xff0000ff );
		bitmap.width=stage.stageWidth;
		bitmap.height=stage.stageHeight;
		game.addChild( bitmap );

		stage.addEventListener( Event.RESIZE,OnResize );
	
		rectBMData=new BitmapData( 1,1,false,0xffffffff );
		
		image_filtering_enabled=(Config.MOJO_IMAGE_FILTERING_ENABLED=="true");
	}
	
	internal function OnResize( e:Event ):void{
		var stage:Stage=game.stage;
		var w:int=stage.stageWidth;
		var h:int=stage.stageHeight;
		if( w==bitmap.width && h==bitmap.height ) return;
		bitmap.bitmapData=new BitmapData( w,h,false,0xff0000ff );
		bitmap.width=w;
		bitmap.height=h;
	}

	internal function BeginRender():void{
		bitmapData=bitmap.bitmapData;
	}

	internal function UseBitmap():void{
		if( graphics==null ) return;
		bitmapData.draw( shape,matrix,alphaTform,blend,clipRect,false );
		graphics.clear();
		graphics=null;
	}

	internal function UseGraphics():void{
		if( graphics!=null ) return;
		if( shape==null ) shape=new Shape;
		graphics=shape.graphics;
	}

	internal function FlushGraphics():void{
		if( graphics==null ) return;
		bitmapData.draw( shape,matrix,alphaTform,blend,clipRect,false );
		graphics.clear();
	}
	
	internal function EndRender():void{
		UseBitmap();
		bitmapData=null;
	}
	
	internal function updateColor():void{
	
		colorARGB=(int(alpha*255)<<24)|(int(red)<<16)|(int(green)<<8)|int(blue);
		
		if( colorARGB==0xffffffff ){
			colorTform=null;
			alphaTform=null;
		}else{
			colorTform=new ColorTransform( red/255.0,green/255.0,blue/255.0,alpha );
			if( alpha==1 ){
				alphaTform=null;
			}else{
				alphaTform=new ColorTransform( 1,1,1,alpha );
			}
		}
	}

	//***** GXTK API *****

	public function Mode():int{
		return 1;
	}
	
	public function Width():int{
		return bitmap.width;
	}

	public function Height():int{
		return bitmap.height;
	}

	public function LoadSurface( path:String ):gxtkSurface{
		var bitmap:Bitmap=game.loadBitmap( path );
		if( bitmap ) return new gxtkSurface( bitmap );
		return null;
	}
	
	public function SetAlpha( a:Number ):int{
		FlushGraphics();
		
		alpha=a;
		
		updateColor();
		
		return 0;
	}
	
	public function SetColor( r:Number,g:Number,b:Number ):int{
		FlushGraphics();
		
		red=r;
		green=g;
		blue=b;
		
		updateColor();
		
		return 0;
	}
	
	public function SetBlend( blend:int ):int{
		switch( blend ){
		case 1:
			this.blend=BlendMode.ADD;
			break;
		default:
			this.blend=null;
		}
		return 0;
	}
	
	public function SetScissor( x:int,y:int,w:int,h:int ):int{
		FlushGraphics();
		
		if( x!=0 || y!=0 || w!=bitmap.width || h!=bitmap.height ){
			clipRect=new Rectangle( x,y,w,h );
		}else{
			clipRect=null;
		}
		return 0;
	}

	public function SetMatrix( ix:Number,iy:Number,jx:Number,jy:Number,tx:Number,ty:Number ):int{
		FlushGraphics();
		
		if( ix!=1 || iy!=0 || jx!=0 || jy!=1 || tx!=0 || ty!=0 ){
			matrix=new Matrix( ix,iy,jx,jy,tx,ty );
		}else{
			matrix=null;
		}
		return 0;
	}

	public function Cls( r:Number,g:Number,b:Number ):int{
		UseBitmap();

		var clsColor:uint=0xff000000|(int(r)<<16)|(int(g)<<8)|int(b);
		var rect:Rectangle=clipRect;
		if( !rect ) rect=new Rectangle( 0,0,bitmap.width,bitmap.height );
		bitmapData.fillRect( rect,clsColor );
		return 0;
	}
	
	public function DrawPoint( x:Number,y:Number ):int{
		UseBitmap();
		
		if( matrix ){
			var px:Number=x;
			x=px * matrix.a + y * matrix.c + matrix.tx;
			y=px * matrix.b + y * matrix.d + matrix.ty;
		}
		if( clipRect || alphaTform || blend ){
			pointMat.tx=x;pointMat.ty=y;
			bitmapData.draw( rectBMData,pointMat,colorTform,blend,clipRect,false );
		}else{
			bitmapData.fillRect( new Rectangle( x,y,1,1 ),colorARGB );
		}
		return 0;
	}
	
	
	public function DrawRect( x:Number,y:Number,w:Number,h:Number ):int{
		UseBitmap();

		if( matrix ){
			var mat:Matrix=new Matrix( w,0,0,h,x,y );
			mat.concat( matrix );
			bitmapData.draw( rectBMData,mat,colorTform,blend,clipRect,false );
		}else if( clipRect || alphaTform || blend ){
			rectMat.a=w;rectMat.d=h;rectMat.tx=x;rectMat.ty=y;
			bitmapData.draw( rectBMData,rectMat,colorTform,blend,clipRect,false );
		}else{
			bitmapData.fillRect( new Rectangle( x,y,w,h ),colorARGB );
		}
		return 0;
	}

	public function DrawLine( x1:Number,y1:Number,x2:Number,y2:Number ):int{
		UseGraphics();
		
		if( matrix ){

			var x1_t:Number=x1 * matrix.a + y1 * matrix.c + matrix.tx;
			var y1_t:Number=x1 * matrix.b + y1 * matrix.d + matrix.ty;
			var x2_t:Number=x2 * matrix.a + y2 * matrix.c + matrix.tx;
			var y2_t:Number=x2 * matrix.b + y2 * matrix.d + matrix.ty;
			
			graphics.lineStyle( 1,colorARGB & 0xffffff );	//why the mask?
			graphics.moveTo( x1_t,y1_t );
			graphics.lineTo( x2_t,y2_t );
			graphics.lineStyle();
			
			var mat:Matrix=matrix;matrix=null;

			FlushGraphics();

			matrix=mat;
			
		}else{

			graphics.lineStyle( 1,colorARGB & 0xffffff );	//why the mask?
			graphics.moveTo( x1,y1 );
			graphics.lineTo( x2,y2 );
			graphics.lineStyle();
		
			if( alphaTform ) FlushGraphics();
		}

		return 0;
 	}

	public function DrawOval( x:Number,y:Number,w:Number,h:Number ):int{
		UseGraphics();

		graphics.beginFill( colorARGB & 0xffffff );			//why the mask?
		graphics.drawEllipse( x,y,w,h );
		graphics.endFill();
		
		if( alphaTform ) FlushGraphics();

		return 0;
	}
	
	public function DrawPoly( verts:Array ):int{
		if( verts.length<6 ) return 0;
		
		UseGraphics();
		
		graphics.beginFill( colorARGB & 0xffffff );			//why the mask?
		
		graphics.moveTo( verts[0],verts[1] );
		for( var i:int=0;i<verts.length;i+=2 ){
			graphics.lineTo( verts[i],verts[i+1] );
		}
		graphics.endFill();
		
		if( alphaTform ) FlushGraphics();

		return 0;
	}

	public function DrawSurface( surface:gxtkSurface,x:Number,y:Number ):int{
		UseBitmap();

		if( matrix ){
			if( x!=0 || y!=0 ){
				//have to translate matrix! TODO!
				return -1;
			}
			bitmapData.draw( surface.bitmap.bitmapData,matrix,colorTform,blend,clipRect,image_filtering_enabled );
		}else if( clipRect || colorTform || blend ){
			var mat:Matrix=new Matrix( 1,0,0,1,x,y );
			bitmapData.draw( surface.bitmap.bitmapData,mat,colorTform,blend,clipRect,image_filtering_enabled );
		}else{
			bitmapData.copyPixels( surface.bitmap.bitmapData,surface.rect,new Point( x,y ) );
		}
		return 0;
	}

	public function DrawSurface2( surface:gxtkSurface,x:Number,y:Number,srcx:int,srcy:int,srcw:int,srch:int ):int{
		if( srcw<0 ){ srcx+=srcw;srcw=-srcw; }
		if( srch<0 ){ srcy+=srch;srch=-srch; }
		if( srcw<=0 || srch<=0 ) return 0;
		
		UseBitmap();

		var srcrect:Rectangle=new Rectangle( srcx,srcy,srcw,srch );
		
		if( matrix || clipRect || colorTform || blend ){

			var scratch:BitmapData=surface.scratch;
			if( scratch==null || srcw!=scratch.width || srch!=scratch.height ){
				if( scratch!=null ) scratch.dispose();
				scratch=new BitmapData( srcw,srch );
				surface.scratch=scratch;
			}
			scratch.copyPixels( surface.bitmap.bitmapData,srcrect,new Point( 0,0 ) );
			
			var mmatrix:Matrix=matrix;
			if( mmatrix==null ){
				mmatrix=new Matrix( 1,0,0,1,x,y );
			}else if( x!=0 || y!=0 ){
				//have to translate matrix! TODO!
				return -1;
			}

			bitmapData.draw( scratch,mmatrix,colorTform,blend,clipRect,image_filtering_enabled );
		}else{
			bitmapData.copyPixels( surface.bitmap.bitmapData,srcrect,new Point( x,y ) );
		}
		return 0;
	}
}

//***** gxtkSurface *****

class gxtkSurface{
	internal var bitmap:Bitmap;
	internal var rect:Rectangle;
	internal var scratch:BitmapData;
	
	function gxtkSurface( bitmap:Bitmap ){
		this.bitmap=bitmap;
		rect=new Rectangle( 0,0,bitmap.width,bitmap.height );
	}

	//***** GXTK API *****

	public function Discard():int{
		return 0;
	}
	
	public function Width():int{
		return rect.width;
	}

	public function Height():int{
		return rect.height;
	}

	public function Loaded():int{
		return 1;
	}
}

class gxtkInput{

	internal var KEY_LMB:int=1;
	internal var KEY_TOUCH0:int=0x180;

	internal var keyStates:Array=new Array( 512 );
	internal var charQueue:Array=new Array( 32 );
	internal var charPut:int=0;
	internal var charGet:int=0;
	internal var mouseX:Number=0;
	internal var mouseY:Number=0;
	
	function gxtkInput(){
	
		for( var i:int=0;i<512;++i ){
			keyStates[i]=0;
		}

		var stage:Stage=game.stage;
	
		stage.addEventListener( KeyboardEvent.KEY_DOWN,function( e:KeyboardEvent ):void{
			OnKeyDown( e.keyCode );
			if( e.charCode!=0 ){
				PutChar( e.charCode );
			}else{
				var chr:int=KeyToChar( e.keyCode );
				if( chr ) PutChar( chr );
			}
		} );
		
		stage.addEventListener( KeyboardEvent.KEY_UP,function( e:KeyboardEvent ):void{
			OnKeyUp( e.keyCode );
		} );
		
		stage.addEventListener( MouseEvent.MOUSE_DOWN,function( e:MouseEvent ):void{
			OnKeyDown( KEY_LMB );
		} );
		
		stage.addEventListener( MouseEvent.MOUSE_UP,function( e:MouseEvent ):void{
			OnKeyUp( KEY_LMB );
		} );
		
		stage.addEventListener( MouseEvent.MOUSE_MOVE,function( e:MouseEvent ):void{
			OnMouseMove( e.localX,e.localY );
		} );
	}
	
	internal function KeyToChar( key:int ):int{
		switch( key ){
		case 8:case 9:case 13:case 27:
			return key;
		case 33:case 34:case 35:case 36:case 37:case 38:case 39:case 40:case 45:
			return key | 0x10000;
		case 46:
			return 127;
		}
		return 0;
	}
	
	internal function BeginUpdate():void{
	}
	
	internal function EndUpdate():void{
		for( var i:int=0;i<512;++i ){
			keyStates[i]&=0x100;
		}
		charGet=0;
		charPut=0;
	}
	
	internal function OnKeyDown( key:int ):void{
		if( (keyStates[key]&0x100)==0 ){
			keyStates[key]|=0x100;
			++keyStates[key];
		}
	}

	internal function OnKeyUp( key:int ):void{
		keyStates[key]&=0xff;
	}
	
	internal function PutChar( chr:int ):void{
		if( chr==0 ) return;
		if( charPut-charGet<32 ){
			charQueue[charPut & 31]=chr;
			charPut+=1;
		}
	}
	
	internal function OnMouseMove( x:Number,y:Number ):void{
		mouseX=x;
		mouseY=y;
	}

	//***** GXTK API *****
	
	public function SetKeyboardEnabled( enabled:int ):int{
		return 0;
	}
	
	public function KeyDown( key:int ):int{
		if( key>0 && key<512 ){
			if( key==KEY_TOUCH0 ) key=KEY_LMB;
			return keyStates[key] >> 8;
		}
		return 0;
	}

	public function KeyHit( key:int ):int{
		if( key>0 && key<512 ){
			if( key==KEY_TOUCH0 ) key=KEY_LMB;
			return keyStates[key] & 0xff;
		}
		return 0;
	}

	public function GetChar():int{
		if( charGet!=charPut ){
			var chr:int=charQueue[charGet & 31];
			charGet+=1;
			return chr;
		}
		return 0;
	}
	
	public function MouseX():Number{
		return mouseX;
	}

	public function MouseY():Number{
		return mouseY;
	}

	public function JoyX( index:int ):Number{
		return 0;
	}
	
	public function JoyY( index:int ):Number{
		return 0;
	}
	
	public function JoyZ( index:int ):Number{
		return 0;
	}
	
	public function TouchX( index:int ):Number{
		return mouseX;
	}

	public function TouchY( index:int ):Number{
		return mouseY;
	}
	
	public function AccelX():Number{
		return 0;
	}
	
	public function AccelY():Number{
		return 0;
	}
	
	public function AccelZ():Number{
		return 0;
	}
}

class gxtkChannel{
	internal var channel:SoundChannel;	//null then not playing
	internal var sample:gxtkSample;
	internal var loops:int;
	internal var transform:SoundTransform=new SoundTransform();
	internal var pausepos:Number;
	internal var state:int;
}

class gxtkAudio{

	internal var music:gxtkSample;

	internal var channels:Array=new Array( 33 );

	function gxtkAudio(){
		for( var i:int=0;i<33;++i ){
			channels[i]=new gxtkChannel();
		}
	}
	
	internal function OnSuspend():void{
		for( var i:int=0;i<33;++i ){
			var chan:gxtkChannel=channels[i];
			if( chan.state==1 ){
				chan.pausepos=chan.channel.position;
				chan.channel.stop();
			}
		}
	}
	
	internal function OnResume():void{
		for( var i:int=0;i<33;++i ){
			var chan:gxtkChannel=channels[i];
			if( chan.state==1 ){
				chan.channel=chan.sample.sound.play( chan.pausepos,chan.loops,chan.transform );
			}
		}
	}
	
	//***** GXTK API *****
	
	public function LoadSample( path:String ):gxtkSample{
		var sound:Sound=game.loadSound( path );
		if( sound ) return new gxtkSample( sound );
		return null;
	}
	
	public function PlaySample( sample:gxtkSample,channel:int,flags:int ):int{
		var chan:gxtkChannel=channels[channel];
		
		if( chan.state!=0 ) chan.channel.stop();
		
		chan.sample=sample;
		chan.loops=flags ? 0x7fffffff : 0;
		chan.channel=sample.sound.play( 0,chan.loops,chan.transform );
		chan.state=1;

		return 0;
	}
	
	public function StopChannel( channel:int ):int{
		var chan:gxtkChannel=channels[channel];
		
		if( chan.state!=0 ){
			chan.channel.stop();
			chan.channel=null;
			chan.sample=null;
			chan.state=0;
		}
		return 0;
	}
	
	public function PauseChannel( channel:int ):int{
		var chan:gxtkChannel=channels[channel];
		
		if( chan.state==1 ){
			chan.pausepos=chan.channel.position;
			chan.channel.stop();
			chan.state=2;
		}
		return 0;
	}
	
	public function ResumeChannel( channel:int ):int{
		var chan:gxtkChannel=channels[channel];
		
		if( chan.state==2 ){
			chan.channel=chan.sample.sound.play( chan.pausepos,chan.loops,chan.transform );
			chan.state=1;
		}
		return 0;
	}
	
	public function ChannelState( channel:int ):int{
		return -1;
	}
	
	public function SetVolume( channel:int,volume:Number ):int{
		var chan:gxtkChannel=channels[channel];
		
		chan.transform.volume=volume;

		if( chan.state!=0 ) chan.channel.soundTransform=chan.transform;

		return 0;
	}
	
	public function SetPan( channel:int,pan:Number ):int{
		var chan:gxtkChannel=channels[channel];
		
		chan.transform.pan=pan;

		if( chan.state!=0 ) chan.channel.soundTransform=chan.transform;

		return 0;
	}
	
	public function SetRate( channel:int,rate:Number ):int{
		return -1;
	}
	
	public function PlayMusic( path:String,flags:int ):int{
		StopMusic();
		
		music=LoadSample( path );
		if( !music ) return -1;
		
		PlaySample( music,32,flags );
		return 0;
	}
	
	public function StopMusic():int{
		StopChannel( 32 );
		
		if( music ){
			music.Discard();
			music=null;
		}
		return 0;
	}
	
	public function PauseMusic():int{
		PauseChannel( 32 );
		
		return 0;
	}
	
	public function ResumeMusic():int{
		ResumeChannel( 32 );
		
		return 0;
	}
	
	public function MusicState():int{
		return ChannelState( 32 );
	}
	
	public function SetMusicVolume( volume:Number ):int{
		SetVolume( 32,volume );
		return 0;
	}
}

class gxtkSample{

	internal var sound:Sound;

	function gxtkSample( sound:Sound ){
		this.sound=sound;
	}
	
	public function Discard():int{
		return 0;
	}
	
}
