
//Change this to true for a stretchy canvas!
//
var RESIZEABLE_CANVAS=false;

//Start us up!
//
window.onload=function( e ){

	if( RESIZEABLE_CANVAS ){
		window.onresize=function( e ){
			var canvas=document.getElementById( "GameCanvas" );

			//This vs window.innerWidth, which apparently doesn't account for scrollbar?
			var width=document.body.clientWidth;
			
			//This vs document.body.clientHeight, which does weird things - document seems to 'grow'...perhaps canvas resize pushing page down?
			var height=window.innerHeight;			

			canvas.width=width;
			canvas.height=height;
		}
		window.onresize( null );
	}
	
	game_canvas=document.getElementById( "GameCanvas" );
	
	game_console=document.getElementById( "GameConsole" );

	try{
	
		bbInit();
		bbMain();
		
		if( game_runner!=null ) game_runner();
		
	}catch( err ){
	
		showError( err );
	}
}

var game_canvas;
var game_console;
var game_runner;

//${CONFIG_BEGIN}
CFG_ANDROID_APP_LABEL="DaffyDrop";
CFG_ANDROID_APP_PACKAGE="com.coragames.daffydrop";
CFG_ANDROID_NATIVE_GL_ENABLED="true";
CFG_CONFIG="release";
CFG_GLFW_WINDOW_HEIGHT="720";
CFG_GLFW_WINDOW_WIDTH="480";
CFG_HOST="macos";
CFG_IMAGE_FILES="*.png|*.jpg";
CFG_IOS_ACCELEROMETER_ENABLED="false";
CFG_IOS_DISPLAY_LINK_ENABLED="true";
CFG_IOS_RETINA_ENABLED="true";
CFG_LANG="js";
CFG_MOJO_AUTO_SUSPEND_ENABLED="false";
CFG_MUSIC_FILES="*.wav|*.ogg|*.mp3|*.m4a";
CFG_OPENGL_GLES20_ENABLED="false";
CFG_PARSER_FUNC_ATTRS="0";
CFG_SOUND_FILES="*.wav|*.ogg|*.mp3|*.m4a";
CFG_TARGET="html5";
CFG_TEXT_FILES="*.txt|*.xml|*.json";
//${CONFIG_END}

//${METADATA_BEGIN}
var META_DATA="[mojo_font.png];type=image/png;width=864;height=13;\n[01_02-advanced.png];type=image/png;width=475;height=115;\n[01_02-advanced_active.png];type=image/png;width=475;height=115;\n[01_02-easy.png];type=image/png;width=475;height=115;\n[01_02-normal.png];type=image/png;width=475;height=115;\n[01_02-normal_active.png];type=image/png;width=475;height=115;\n[01_02-play_again-active.png];type=image/png;width=475;height=115;\n[01_04button-highscore.png];type=image/png;width=475;height=115;\n[01_05-quit_active.png];type=image/png;width=475;height=115;\n[01_06-continue.png];type=image/png;width=475;height=115;\n[01_07-quit.png];type=image/png;width=475;height=115;\n[01_main.jpg];type=image/jpg;width=640;height=960;\n[CoRa.png];type=image/png;width=512;height=512;\n[arrow_ingame.png];type=image/png;width=64;height=270;\n[arrow_ingame2.png];type=image/png;width=64;height=270;\n[back.png];type=image/png;width=133;height=118;\n[bg_960x640.png];type=image/png;width=640;height=960;\n[chute-bg.png];type=image/png;width=136;height=6;\n[chute-bottom.png];type=image/png;width=148;height=24;\n[circle_inside.png];type=image/png;width=140;height=137;\n[circle_outside.png];type=image/png;width=140;height=137;\n[false.png];type=image/png;width=840;height=88;\n[gameover.png];type=image/png;width=640;height=960;\n[highscore_bg.png];type=image/png;width=640;height=960;\n[locked.png];type=image/png;width=144;height=149;\n[logo.jpg];type=image/jpg;width=565;height=317;\n[newhighscore.png];type=image/png;width=640;height=960;\n[pause-button.png];type=image/png;width=77;height=77;\n[pause.png];type=image/png;width=640;height=960;\n[plus_inside.png];type=image/png;width=140;height=137;\n[plus_outside.png];type=image/png;width=140;height=137;\n[star_inside.png];type=image/png;width=140;height=137;\n[star_outside.png];type=image/png;width=140;height=137;\n[tire_inside.png];type=image/png;width=140;height=137;\n[tire_outside.png];type=image/png;width=140;height=137;\n";
//${METADATA_END}

function getMetaData( path,key ){
	var i=META_DATA.indexOf( "["+path+"]" );
	if( i==-1 ) return "";
	i+=path.length+2;

	var e=META_DATA.indexOf( "\n",i );
	if( e==-1 ) e=META_DATA.length;

	i=META_DATA.indexOf( ";"+key+"=",i )
	if( i==-1 || i>=e ) return "";
	i+=key.length+2;

	e=META_DATA.indexOf( ";",i );
	if( e==-1 ) return "";

	return META_DATA.slice( i,e );
}

function loadString( path ){
	var xhr=new XMLHttpRequest();
	xhr.open( "GET","data/"+path,false );
	xhr.send( null );
	if( (xhr.status==200) || (xhr.status==0) ) return xhr.responseText;
	return "";
}

function loadImage( path,onloadfun ){
	var ty=getMetaData( path,"type" );
	if( ty.indexOf( "image/" )!=0 ) return null;

	var image=new Image();
	
	image.meta_width=parseInt( getMetaData( path,"width" ) );
	image.meta_height=parseInt( getMetaData( path,"height" ) );
	image.onload=onloadfun;
	image.src="data/"+path;
	
	return image;
}

function loadAudio( path ){
	var audio=new Audio( "data/"+path );
	return audio;
}

//${TRANSCODE_BEGIN}

// Javascript Monkey runtime.
//
// Placed into the public domain 24/02/2011.
// No warranty implied; use at your own risk.

//***** JavaScript Runtime *****

var D2R=0.017453292519943295;
var R2D=57.29577951308232;

var err_info="";
var err_stack=[];

function push_err(){
	err_stack.push( err_info );
}

function pop_err(){
	err_info=err_stack.pop();
}

function stackTrace(){
	var str="";
	push_err();
	err_stack.reverse();
	for( var i=0;i<err_stack.length;++i ){
		str+=err_stack[i]+"\n";
	}
	err_stack.reverse();
	pop_err();
	return str;
}

function print( str ){
	if( game_console ){
		game_console.value+=str+"\n";
		game_console.scrollTop = game_console.scrollHeight - game_console.clientHeight;
	}
	if( window.console!=undefined ){
		window.console.log( str );
	}
	return 0;
}

function showError( err ){
	if( typeof(err)=="string" && err=="" ) return;
	var t="Monkey runtime error: "+err+"\n"+stackTrace();
	if( window.console!=undefined ){
		window.console.log( t );
	}
	alert( t );
}

function error( err ){
	throw err;
}

function dbg_object( obj ){
	if( obj ) return obj;
	error( "Null object access" );
}

function dbg_array( arr,index ){
	if( index>=0 && index<arr.length ) return arr;
	error( "Array index out of range" );
}

function new_bool_array( len ){
	var arr=Array( len );
	for( var i=0;i<len;++i ) arr[i]=false;
	return arr;
}

function new_number_array( len ){
	var arr=Array( len );
	for( var i=0;i<len;++i ) arr[i]=0;
	return arr;
}

function new_string_array( len ){
	var arr=Array( len );
	for( var i=0;i<len;++i ) arr[i]='';
	return arr;
}

function new_array_array( len ){
	var arr=Array( len );
	for( var i=0;i<len;++i ) arr[i]=[];
	return arr;
}

function new_object_array( len ){
	var arr=Array( len );
	for( var i=0;i<len;++i ) arr[i]=null;
	return arr;
}

function resize_bool_array( arr,len ){
	var i=arr.length;
	arr=arr.slice(0,len);
	if( len<=i ) return arr;
	arr.length=len;
	while( i<len ) arr[i++]=false;
	return arr;
}

function resize_number_array( arr,len ){
	var i=arr.length;
	arr=arr.slice(0,len);
	if( len<=i ) return arr;
	arr.length=len;
	while( i<len ) arr[i++]=0;
	return arr;
}

function resize_string_array( arr,len ){
	var i=arr.length;
	arr=arr.slice(0,len);
	if( len<=i ) return arr;
	arr.length=len;
	while( i<len ) arr[i++]="";
	return arr;
}

function resize_array_array( arr,len ){
	var i=arr.length;
	arr=arr.slice(0,len);
	if( len<=i ) return arr;
	arr.length=len;
	while( i<len ) arr[i++]=[];
	return arr;
}

function resize_object_array( arr,len ){
	var i=arr.length;
	arr=arr.slice(0,len);
	if( len<=i ) return arr;
	arr.length=len;
	while( i<len ) arr[i++]=null;
	return arr;
}

function string_compare( lhs,rhs ){
	var n=Math.min( lhs.length,rhs.length ),i,t;
	for( i=0;i<n;++i ){
		t=lhs.charCodeAt(i)-rhs.charCodeAt(i);
		if( t ) return t;
	}
	return lhs.length-rhs.length;
}

function string_replace( str,find,rep ){	//no unregex replace all?!?
	var i=0;
	for(;;){
		i=str.indexOf( find,i );
		if( i==-1 ) return str;
		str=str.substring( 0,i )+rep+str.substring( i+find.length );
		i+=rep.length;
	}
}

function string_trim( str ){
	var i=0,i2=str.length;
	while( i<i2 && str.charCodeAt(i)<=32 ) i+=1;
	while( i2>i && str.charCodeAt(i2-1)<=32 ) i2-=1;
	return str.slice( i,i2 );
}

function string_starts_with( str,substr ){
	return substr.length<=str.length && str.slice(0,substr.length)==substr;
}

function string_ends_with( str,substr ){
	return substr.length<=str.length && str.slice(str.length-substr.length,str.length)==substr;
}

function string_from_chars( chars ){
	var str="",i;
	for( i=0;i<chars.length;++i ){
		str+=String.fromCharCode( chars[i] );
	}
	return str;
}


function object_downcast( obj,clas ){
	if( obj instanceof clas ) return obj;
	return null;
}

function object_implements( obj,iface ){
	if( obj && obj.implments && obj.implments[iface] ) return obj;
	return null;
}

function extend_class( clas ){
	var tmp=function(){};
	tmp.prototype=clas.prototype;
	return new tmp;
}

// HTML5 mojo runtime.
//
// Copyright 2011 Mark Sibly, all rights reserved.
// No warranty implied; use at your own risk.

var gl=null;	//global WebGL context - a bit rude!

KEY_LMB=1;
KEY_RMB=2;
KEY_MMB=3;
KEY_TOUCH0=0x180;

function eatEvent( e ){
	if( e.stopPropagation ){
		e.stopPropagation();
		e.preventDefault();
	}else{
		e.cancelBubble=true;
		e.returnValue=false;
	}
}

function keyToChar( key ){
	switch( key ){
	case 8:
	case 9:
	case 13:
	case 27:
	case 32:
		return key;
	case 33:
	case 34:
	case 35:
	case 36:
	case 37:
	case 38:
	case 39:
	case 40:
	case 45:
		return key | 0x10000;
	case 46:
		return 127;
	}
	return 0;
}

//***** gxtkApp class *****

function gxtkApp(){

	if( typeof( CFG_OPENGL_GLES20_ENABLED )!="undefined" && CFG_OPENGL_GLES20_ENABLED=="true" ){
		this.gl=game_canvas.getContext( "webgl" );
		if( !this.gl ) this.gl=game_canvas.getContext( "experimental-webgl" );
	}else{
		this.gl=null;
	}

	this.graphics=new gxtkGraphics( this,game_canvas );
	this.input=new gxtkInput( this );
	this.audio=new gxtkAudio( this );

	this.loading=0;
	this.maxloading=0;

	this.updateRate=0;
	this.startMillis=(new Date).getTime();
	
	this.dead=false;
	this.suspended=false;
	
	var app=this;
	var canvas=game_canvas;
	
	function gxtkMain(){
	
		var input=app.input;
	
		canvas.onkeydown=function( e ){
			input.OnKeyDown( e.keyCode );
			var chr=keyToChar( e.keyCode );
			if( chr ) input.PutChar( chr );
			if( e.keyCode<48 || (e.keyCode>111 && e.keyCode<122) ) eatEvent( e );
		}

		canvas.onkeyup=function( e ){
			input.OnKeyUp( e.keyCode );
		}

		canvas.onkeypress=function( e ){
			if( e.charCode ){
				input.PutChar( e.charCode );
			}else if( e.which ){
				input.PutChar( e.which );
			}
		}

		canvas.onmousedown=function( e ){
			switch( e.button ){
			case 0:input.OnKeyDown( KEY_LMB );break;
			case 1:input.OnKeyDown( KEY_MMB );break;
			case 2:input.OnKeyDown( KEY_RMB );break;
			}
			eatEvent( e );
		}
		
		canvas.onmouseup=function( e ){
			switch( e.button ){
			case 0:input.OnKeyUp( KEY_LMB );break;
			case 1:input.OnKeyUp( KEY_MMB );break;
			case 2:input.OnKeyUp( KEY_RMB );break;
			}
			eatEvent( e );
		}
		
		canvas.onmouseout=function( e ){
			input.OnKeyUp( KEY_LMB );
			input.OnKeyUp( KEY_MMB );
			input.OnKeyUp( KEY_RMB );
			eatEvent( e );
		}

		canvas.onmousemove=function( e ){
			var x=e.clientX+document.body.scrollLeft;
			var y=e.clientY+document.body.scrollTop;
			var c=canvas;
			while( c ){
				x-=c.offsetLeft;
				y-=c.offsetTop;
				c=c.offsetParent;
			}
			input.OnMouseMove( x,y );
			eatEvent( e );
		}

		canvas.onfocus=function( e ){
			if( CFG_MOJO_AUTO_SUSPEND_ENABLED=="true" ){
				app.InvokeOnResume();
			}
		}
		
		canvas.onblur=function( e ){
			if( CFG_MOJO_AUTO_SUSPEND_ENABLED=="true" ){
				app.InvokeOnSuspend();
			}
		}
		
		canvas.ontouchstart=function( e ){
			for( var i=0;i<e.changedTouches.length;++i ){
				var touch=e.changedTouches[i];
				var x=touch.pageX;
				var y=touch.pageY;
				var c=canvas;
				while( c ){
					x-=c.offsetLeft;
					y-=c.offsetTop;
					c=c.offsetParent;
				}
				input.OnTouchStart( touch.identifier,x,y );
			}
			eatEvent( e );
		}
		
		canvas.ontouchmove=function( e ){
			for( var i=0;i<e.changedTouches.length;++i ){
				var touch=e.changedTouches[i];
				var x=touch.pageX;
				var y=touch.pageY;
				var c=canvas;
				while( c ){
					x-=c.offsetLeft;
					y-=c.offsetTop;
					c=c.offsetParent;
				}
				input.OnTouchMove( touch.identifier,x,y );
			}
			eatEvent( e );
		}
		
		canvas.ontouchend=function( e ){
			for( var i=0;i<e.changedTouches.length;++i ){
				input.OnTouchEnd( e.changedTouches[i].identifier );
			}
			eatEvent( e );
		}
		
		window.ondevicemotion=function( e ){
			var tx=e.accelerationIncludingGravity.x/9.81;
			var ty=e.accelerationIncludingGravity.y/9.81;
			var tz=e.accelerationIncludingGravity.z/9.81;
			var x,y;
			switch( window.orientation ){
			case   0:x=+tx;y=-ty;break;
			case 180:x=-tx;y=+ty;break;
			case  90:x=-ty;y=-tx;break;
			case -90:x=+ty;y=+tx;break;
			}
			input.OnDeviceMotion( x,y,tz );
			eatEvent( e );
		}

		canvas.focus();

		app.InvokeOnCreate();
		app.InvokeOnRender();
	}

	game_runner=gxtkMain;
}

var timerSeq=0;

gxtkApp.prototype.SetFrameRate=function( fps ){

	var seq=++timerSeq;
	
	if( !fps ) return;
	
	var app=this;
	var updatePeriod=1000.0/fps;
	var nextUpdate=(new Date).getTime()+updatePeriod;
	
	function timeElapsed(){
		if( seq!=timerSeq ) return;

		var time;		
		var updates=0;

		for(;;){
			nextUpdate+=updatePeriod;

			app.InvokeOnUpdate();
			if( seq!=timerSeq ) return;
			
			if( nextUpdate>(new Date).getTime() ) break;
			
			if( ++updates==7 ){
				nextUpdate=(new Date).getTime();
				break;
			}
		}
		app.InvokeOnRender();
		if( seq!=timerSeq ) return;
			
		var delay=nextUpdate-(new Date).getTime();
		setTimeout( timeElapsed,delay>0 ? delay : 0 );
	}
	
	setTimeout( timeElapsed,updatePeriod );
}

gxtkApp.prototype.IncLoading=function(){
	++this.loading;
	if( this.loading>this.maxloading ) this.maxloading=this.loading;
	if( this.loading==1 ) this.SetFrameRate( 0 );
}

gxtkApp.prototype.DecLoading=function(){
	--this.loading;
	if( this.loading!=0 ) return;
	this.maxloading=0;
	this.SetFrameRate( this.updateRate );
}

gxtkApp.prototype.GetMetaData=function( path,key ){
	return getMetaData( path,key );
}

gxtkApp.prototype.Die=function( err ){
	this.dead=true;
	this.audio.OnSuspend();
	showError( err );
}

gxtkApp.prototype.InvokeOnCreate=function(){
	if( this.dead ) return;
	
	try{
		gl=this.gl;
		this.OnCreate();
		gl=null;
	}catch( ex ){
		this.Die( ex );
	}
}

gxtkApp.prototype.InvokeOnUpdate=function(){
	if( this.dead || this.suspended || !this.updateRate || this.loading ) return;
	
	try{
		gl=this.gl;
		this.input.BeginUpdate();
		this.OnUpdate();		
		this.input.EndUpdate();
		gl=null;
	}catch( ex ){
		this.Die( ex );
	}
}

gxtkApp.prototype.InvokeOnSuspend=function(){
	if( this.dead || this.suspended ) return;
	
	try{
		gl=this.gl;
		this.suspended=true;
		this.OnSuspend();
		this.audio.OnSuspend();
		gl=null;
	}catch( ex ){
		this.Die( ex );
	}
}

gxtkApp.prototype.InvokeOnResume=function(){
	if( this.dead || !this.suspended ) return;
	
	try{
		gl=this.gl;
		this.audio.OnResume();
		this.OnResume();
		this.suspended=false;
		gl=null;
	}catch( ex ){
		this.Die( ex );
	}
}

gxtkApp.prototype.InvokeOnRender=function(){
	if( this.dead || this.suspended ) return;
	
	try{
		gl=this.gl;
		this.graphics.BeginRender();
		if( this.loading ){
			this.OnLoading();
		}else{
			this.OnRender();
		}
		this.graphics.EndRender();
		gl=null;
	}catch( ex ){
		this.Die( ex );
	}
}

//***** GXTK API *****

gxtkApp.prototype.GraphicsDevice=function(){
	return this.graphics;
}

gxtkApp.prototype.InputDevice=function(){
	return this.input;
}

gxtkApp.prototype.AudioDevice=function(){
	return this.audio;
}

gxtkApp.prototype.AppTitle=function(){
	return document.URL;
}

gxtkApp.prototype.LoadState=function(){
	var state=localStorage.getItem( ".mojostate@"+document.URL );
	if( state ) return state;
	return "";
}

gxtkApp.prototype.SaveState=function( state ){
	localStorage.setItem( ".mojostate@"+document.URL,state );
}

gxtkApp.prototype.LoadString=function( path ){
	return loadString( path );
}

gxtkApp.prototype.SetUpdateRate=function( fps ){
	this.updateRate=fps;
	
	if( !this.loading ) this.SetFrameRate( fps );
}

gxtkApp.prototype.MilliSecs=function(){
	return ((new Date).getTime()-this.startMillis)|0;
}

gxtkApp.prototype.Loading=function(){
	return this.loading;
}

gxtkApp.prototype.OnCreate=function(){
}

gxtkApp.prototype.OnUpdate=function(){
}

gxtkApp.prototype.OnSuspend=function(){
}

gxtkApp.prototype.OnResume=function(){
}

gxtkApp.prototype.OnRender=function(){
}

gxtkApp.prototype.OnLoading=function(){
}

//***** gxtkGraphics class *****

function gxtkGraphics( app,canvas ){
	this.app=app;
	this.canvas=canvas;
	this.gc=canvas.getContext( '2d' );
	this.tmpCanvas=null;
	this.r=255;
	this.b=255;
	this.g=255;
	this.white=true;
	this.color="rgb(255,255,255)"
	this.alpha=1;
	this.blend="source-over";
	this.ix=1;this.iy=0;
	this.jx=0;this.jy=1;
	this.tx=0;this.ty=0;
	this.tformed=false;
	this.scissorX=0;
	this.scissorY=0;
	this.scissorWidth=0;
	this.scissorHeight=0;
	this.clipped=false;
}

gxtkGraphics.prototype.BeginRender=function(){
	if( this.gc ) this.gc.save();
}

gxtkGraphics.prototype.EndRender=function(){
	if( this.gc ) this.gc.restore();
}

gxtkGraphics.prototype.Mode=function(){
	if( this.gc ) return 1;
	return 0;
}

gxtkGraphics.prototype.Width=function(){
	return this.canvas.width;
}

gxtkGraphics.prototype.Height=function(){
	return this.canvas.height;
}

gxtkGraphics.prototype.LoadSurface=function( path ){
	var app=this.app;
	
	function onloadfun(){
		app.DecLoading();
	}

	app.IncLoading();

	var image=loadImage( path,onloadfun );
	if( image ) return new gxtkSurface( image,this );

	app.DecLoading();
	return null;
}

gxtkGraphics.prototype.SetAlpha=function( alpha ){
	this.alpha=alpha;
	this.gc.globalAlpha=alpha;
}

gxtkGraphics.prototype.SetColor=function( r,g,b ){
	this.r=r;
	this.g=g;
	this.b=b;
	this.white=(r==255 && g==255 && b==255);
	this.color="rgb("+(r|0)+","+(g|0)+","+(b|0)+")";
	this.gc.fillStyle=this.color;
	this.gc.strokeStyle=this.color;
}

gxtkGraphics.prototype.SetBlend=function( blend ){
	switch( blend ){
	case 1:
		this.blend="lighter";
		break;
	default:
		this.blend="source-over";
	}
	this.gc.globalCompositeOperation=this.blend;
}

gxtkGraphics.prototype.SetScissor=function( x,y,w,h ){
	this.scissorX=x;
	this.scissorY=y;
	this.scissorWidth=w;
	this.scissorHeight=h;
	this.clipped=(x!=0 || y!=0 || w!=this.canvas.width || h!=this.canvas.height);
	this.gc.restore();
	this.gc.save();
	if( this.clipped ){
		this.gc.beginPath();
		this.gc.rect( x,y,w,h );
		this.gc.clip();
		this.gc.closePath();
	}
	this.gc.fillStyle=this.color;
	this.gc.strokeStyle=this.color;
	if( this.tformed ) this.gc.setTransform( this.ix,this.iy,this.jx,this.jy,this.tx,this.ty );
}

gxtkGraphics.prototype.SetMatrix=function( ix,iy,jx,jy,tx,ty ){
	this.ix=ix;this.iy=iy;
	this.jx=jx;this.jy=jy;
	this.tx=tx;this.ty=ty;
	this.gc.setTransform( ix,iy,jx,jy,tx,ty );
	this.tformed=(ix!=1 || iy!=0 || jx!=0 || jy!=1 || tx!=0 || ty!=0);
}

gxtkGraphics.prototype.Cls=function( r,g,b ){
	if( this.tformed ) this.gc.setTransform( 1,0,0,1,0,0 );
	this.gc.fillStyle="rgb("+(r|0)+","+(g|0)+","+(b|0)+")";
	this.gc.globalAlpha=1;
	this.gc.globalCompositeOperation="source-over";
	this.gc.fillRect( 0,0,this.canvas.width,this.canvas.height );
	this.gc.fillStyle=this.color;
	this.gc.globalAlpha=this.alpha;
	this.gc.globalCompositeOperation=this.blend;
	if( this.tformed ) this.gc.setTransform( this.ix,this.iy,this.jx,this.jy,this.tx,this.ty );
}

gxtkGraphics.prototype.DrawPoint=function( x,y ){
	if( this.tformed ){
		var px=x;
		x=px * this.ix + y * this.jx + this.tx;
		y=px * this.iy + y * this.jy + this.ty;
		this.gc.setTransform( 1,0,0,1,0,0 );
		this.gc.fillRect( x,y,1,1 );
		this.gc.setTransform( this.ix,this.iy,this.jx,this.jy,this.tx,this.ty );
	}else{
		this.gc.fillRect( x,y,1,1 );
	}
}

gxtkGraphics.prototype.DrawRect=function( x,y,w,h ){
	if( w<0 ){ x+=w;w=-w; }
	if( h<0 ){ y+=h;h=-h; }
	if( w<=0 || h<=0 ) return;
	//
	this.gc.fillRect( x,y,w,h );
}

gxtkGraphics.prototype.DrawLine=function( x1,y1,x2,y2 ){
	if( this.tformed ){
		var x1_t=x1 * this.ix + y1 * this.jx + this.tx;
		var y1_t=x1 * this.iy + y1 * this.jy + this.ty;
		var x2_t=x2 * this.ix + y2 * this.jx + this.tx;
		var y2_t=x2 * this.iy + y2 * this.jy + this.ty;
		this.gc.setTransform( 1,0,0,1,0,0 );
	  	this.gc.beginPath();
	  	this.gc.moveTo( x1_t,y1_t );
	  	this.gc.lineTo( x2_t,y2_t );
	  	this.gc.stroke();
	  	this.gc.closePath();
		this.gc.setTransform( this.ix,this.iy,this.jx,this.jy,this.tx,this.ty );
	}else{
	  	this.gc.beginPath();
	  	this.gc.moveTo( x1,y1 );
	  	this.gc.lineTo( x2,y2 );
	  	this.gc.stroke();
	  	this.gc.closePath();
	}
}

gxtkGraphics.prototype.DrawOval=function( x,y,w,h ){
	if( w<0 ){ x+=w;w=-w; }
	if( h<0 ){ y+=h;h=-h; }
	if( w<=0 || h<=0 ) return;
	//
  	var w2=w/2,h2=h/2;
	this.gc.save();
	this.gc.translate( x+w2,y+h2 );
	this.gc.scale( w2,h2 );
  	this.gc.beginPath();
	this.gc.arc( 0,0,1,0,Math.PI*2,false );
	this.gc.fill();
  	this.gc.closePath();
	this.gc.restore();
}

gxtkGraphics.prototype.DrawPoly=function( verts ){
	if( verts.length<6 ) return;
	this.gc.beginPath();
	this.gc.moveTo( verts[0],verts[1] );
	for( var i=2;i<verts.length;i+=2 ){
		this.gc.lineTo( verts[i],verts[i+1] );
	}
	this.gc.fill();
	this.gc.closePath();
}

gxtkGraphics.prototype.DrawSurface=function( surface,x,y ){
	if( !surface.image.complete ) return;
	
	if( this.white ){
		this.gc.drawImage( surface.image,x,y );
		return;
	}
	
	this.DrawImageTinted( surface.image,x,y,0,0,surface.swidth,surface.sheight );
}

gxtkGraphics.prototype.DrawSurface2=function( surface,x,y,srcx,srcy,srcw,srch ){
	if( !surface.image.complete ) return;

	if( srcw<0 ){ srcx+=srcw;srcw=-srcw; }
	if( srch<0 ){ srcy+=srch;srch=-srch; }
	if( srcw<=0 || srch<=0 ) return;

	if( this.white ){
		this.gc.drawImage( surface.image,srcx,srcy,srcw,srch,x,y,srcw,srch );
		return;
	}
	
	this.DrawImageTinted( surface.image,x,y,srcx,srcy,srcw,srch  );
}

gxtkGraphics.prototype.DrawImageTinted=function( image,dx,dy,sx,sy,sw,sh ){

	if( !this.tmpCanvas ){
		this.tmpCanvas=document.createElement( "canvas" );
	}

	if( sw>this.tmpCanvas.width || sh>this.tmpCanvas.height ){
		this.tmpCanvas.width=Math.max( sw,this.tmpCanvas.width );
		this.tmpCanvas.height=Math.max( sh,this.tmpCanvas.height );
	}
	
	var tgc=this.tmpCanvas.getContext( "2d" );
	
	tgc.globalCompositeOperation="copy";

	tgc.drawImage( image,sx,sy,sw,sh,0,0,sw,sh );
	
	var imgData=tgc.getImageData( 0,0,sw,sh );
	
	var p=imgData.data,sz=sw*sh*4,i;
	
	for( i=0;i<sz;i+=4 ){
		p[i]=p[i]*this.r/255;
		p[i+1]=p[i+1]*this.g/255;
		p[i+2]=p[i+2]*this.b/255;
	}
	
	tgc.putImageData( imgData,0,0 );
	
	this.gc.drawImage( this.tmpCanvas,0,0,sw,sh,dx,dy,sw,sh );
}

//***** gxtkSurface class *****

function gxtkSurface( image,graphics ){
	this.image=image;
	this.graphics=graphics;
	this.swidth=image.meta_width;
	this.sheight=image.meta_height;
}

//***** GXTK API *****

gxtkSurface.prototype.Discard=function(){
	if( this.image ){
		this.image=null;
	}
}

gxtkSurface.prototype.Width=function(){
	return this.swidth;
}

gxtkSurface.prototype.Height=function(){
	return this.sheight;
}

gxtkSurface.prototype.Loaded=function(){
	return this.image.complete;
}

//***** Class gxtkInput *****

function gxtkInput( app ){
	this.app=app;
	this.keyStates=new Array( 512 );
	this.charQueue=new Array( 32 );
	this.charPut=0;
	this.charGet=0;
	this.mouseX=0;
	this.mouseY=0;
	this.joyX=0;
	this.joyY=0;
	this.joyZ=0;
	this.touchIds=new Array( 32 );
	this.touchXs=new Array( 32 );
	this.touchYs=new Array( 32 );
	this.accelX=0;
	this.accelY=0;
	this.accelZ=0;
	
	var i;
	
	for( i=0;i<512;++i ){
		this.keyStates[i]=0;
	}
	
	for( i=0;i<32;++i ){
		this.touchIds[i]=-1;
		this.touchXs[i]=0;
		this.touchYs[i]=0;
	}
}

gxtkInput.prototype.BeginUpdate=function(){
}

gxtkInput.prototype.EndUpdate=function(){
	for( var i=0;i<512;++i ){
		this.keyStates[i]&=0x100;
	}
	this.charGet=0;
	this.charPut=0;
}

gxtkInput.prototype.OnKeyDown=function( key ){
	if( (this.keyStates[key]&0x100)==0 ){
		this.keyStates[key]|=0x100;
		++this.keyStates[key];
		//
		if( key==KEY_LMB ){
			this.keyStates[KEY_TOUCH0]|=0x100;
			++this.keyStates[KEY_TOUCH0];
		}else if( key==KEY_TOUCH0 ){
			this.keyStates[KEY_LMB]|=0x100;
			++this.keyStates[KEY_LMB];
		}
		//
	}
}

gxtkInput.prototype.OnKeyUp=function( key ){
	this.keyStates[key]&=0xff;
	//
	if( key==KEY_LMB ){
		this.keyStates[KEY_TOUCH0]&=0xff;
	}else if( key==KEY_TOUCH0 ){
		this.keyStates[KEY_LMB]&=0xff;
	}
	//
}

gxtkInput.prototype.PutChar=function( chr ){
	if( this.charPut-this.charGet<32 ){
		this.charQueue[this.charPut & 31]=chr;
		this.charPut+=1;
	}
}

gxtkInput.prototype.OnMouseMove=function( x,y ){
	this.mouseX=x;
	this.mouseY=y;
	this.touchXs[0]=x;
	this.touchYs[0]=y;
}

gxtkInput.prototype.OnTouchStart=function( id,x,y ){
	for( var i=0;i<32;++i ){
		if( this.touchIds[i]==-1 ){
			this.touchIds[i]=id;
			this.touchXs[i]=x;
			this.touchYs[i]=y;
			this.OnKeyDown( KEY_TOUCH0+i );
			return;
		} 
	}
}

gxtkInput.prototype.OnTouchMove=function( id,x,y ){
	for( var i=0;i<32;++i ){
		if( this.touchIds[i]==id ){
			this.touchXs[i]=x;
			this.touchYs[i]=y;
			if( i==0 ){
				this.mouseX=x;
				this.mouseY=y;
			}
			return;
		}
	}
}

gxtkInput.prototype.OnTouchEnd=function( id ){
	for( var i=0;i<32;++i ){
		if( this.touchIds[i]==id ){
			this.touchIds[i]=-1;
			this.OnKeyUp( KEY_TOUCH0+i );
			return;
		}
	}
}

gxtkInput.prototype.OnDeviceMotion=function( x,y,z ){
	this.accelX=x;
	this.accelY=y;
	this.accelZ=z;
}

//***** GXTK API *****

gxtkInput.prototype.SetKeyboardEnabled=function( enabled ){
	return 0;
}

gxtkInput.prototype.KeyDown=function( key ){
	if( key>0 && key<512 ){
		return this.keyStates[key] >> 8;
	}
	return 0;
}

gxtkInput.prototype.KeyHit=function( key ){
	if( key>0 && key<512 ){
		return this.keyStates[key] & 0xff;
	}
	return 0;
}

gxtkInput.prototype.GetChar=function(){
	if( this.charPut!=this.charGet ){
		var chr=this.charQueue[this.charGet & 31];
		this.charGet+=1;
		return chr;
	}
	return 0;
}

gxtkInput.prototype.MouseX=function(){
	return this.mouseX;
}

gxtkInput.prototype.MouseY=function(){
	return this.mouseY;
}

gxtkInput.prototype.JoyX=function( index ){
	return this.joyX;
}

gxtkInput.prototype.JoyY=function( index ){
	return this.joyY;
}

gxtkInput.prototype.JoyZ=function( index ){
	return this.joyZ;
}

gxtkInput.prototype.TouchX=function( index ){
	return this.touchXs[index];
}

gxtkInput.prototype.TouchY=function( index ){
	return this.touchYs[index];
}

gxtkInput.prototype.AccelX=function(){
	return this.accelX;
}

gxtkInput.prototype.AccelY=function(){
	return this.accelY;
}

gxtkInput.prototype.AccelZ=function(){
	return this.accelZ;
}


//***** gxtkChannel class *****
function gxtkChannel(){
	this.sample=null;
	this.audio=null;
	this.volume=1;
	this.pan=0;
	this.rate=1;
	this.flags=0;
	this.state=0;
}

//***** gxtkAudio class *****
function gxtkAudio( app ){
	this.app=app;
	this.okay=typeof(Audio)!="undefined";
	this.nextchan=0;
	this.music=null;
	this.channels=new Array(33);
	for( var i=0;i<33;++i ){
		this.channels[i]=new gxtkChannel();
	}
}

gxtkAudio.prototype.OnSuspend=function(){
	var i;
	for( i=0;i<33;++i ){
		var chan=this.channels[i];
		if( chan.state==1 ) chan.audio.pause();
	}
}

gxtkAudio.prototype.OnResume=function(){
	var i;
	for( i=0;i<33;++i ){
		var chan=this.channels[i];
		if( chan.state==1 ) chan.audio.play();
	}
}

gxtkAudio.prototype.LoadSample=function( path ){
	var audio=loadAudio( path );
	if( audio ) return new gxtkSample( audio );
	return null;
}

gxtkAudio.prototype.PlaySample=function( sample,channel,flags ){
	if( !this.okay ) return;

	var chan=this.channels[channel];

	if( chan.state!=0 ){
		chan.audio.pause();
		chan.state=0;
	}
	
	for( var i=0;i<33;++i ){
		var chan2=this.channels[i];
		if( chan2.state==1 && chan2.audio.ended && !chan2.audio.loop ) chan.state=0;
		if( chan2.state==0 && chan2.sample ){
			chan2.sample.FreeAudio( chan2.audio );
			chan2.sample=null;
			chan2.audio=null;
		}
	}

	var audio=sample.AllocAudio();
	if( !audio ) return;
	
	audio.loop=(flags&1)!=0;
	audio.volume=chan.volume;
	audio.play();

	chan.sample=sample;
	chan.audio=audio;
	chan.flags=flags;
	chan.state=1;
}

gxtkAudio.prototype.StopChannel=function( channel ){
	var chan=this.channels[channel];
	
	if( chan.state!=0 ){
		chan.audio.pause();
		chan.state=0;
	}
}

gxtkAudio.prototype.PauseChannel=function( channel ){
	var chan=this.channels[channel];
	
	if( chan.state==1 ){
		if( chan.audio.ended && !chan.audio.loop ){
			chan.state=0;
		}else{
			chan.audio.pause();
			chan.state=2;
		}
	}
}

gxtkAudio.prototype.ResumeChannel=function( channel ){
	var chan=this.channels[channel];
	
	if( chan.state==2 ){
		chan.audio.play();
		chan.state=1;
	}
}

gxtkAudio.prototype.ChannelState=function( channel ){
	var chan=this.channels[channel];
	if( chan.state==1 && chan.audio.ended && !chan.audio.loop ) chan.state=0;
	return chan.state;
}

gxtkAudio.prototype.SetVolume=function( channel,volume ){
	var chan=this.channels[channel];
	if( chan.state!=0 ) chan.audio.volume=volume;
	chan.volume=volume;
}

gxtkAudio.prototype.SetPan=function( channel,pan ){
	var chan=this.channels[channel];
	chan.pan=pan;
}

gxtkAudio.prototype.SetRate=function( channel,rate ){
	var chan=this.channels[channel];
	chan.rate=rate;
}

gxtkAudio.prototype.PlayMusic=function( path,flags ){
	this.StopMusic();
	
	this.music=this.LoadSample( path );
	if( !this.music ) return;
	
	this.PlaySample( this.music,32,flags );
}

gxtkAudio.prototype.StopMusic=function(){
	this.StopChannel( 32 );

	if( this.music ){
		this.music.Discard();
		this.music=null;
	}
}

gxtkAudio.prototype.PauseMusic=function(){
	this.PauseChannel( 32 );
}

gxtkAudio.prototype.ResumeMusic=function(){
	this.ResumeChannel( 32 );
}

gxtkAudio.prototype.MusicState=function(){
	return this.ChannelState( 32 );
}

gxtkAudio.prototype.SetMusicVolume=function( volume ){
	this.SetVolume( 32,volume );
}

//***** gxtkSample class *****

function gxtkSample( audio ){
	this.audio=audio;
	this.free=new Array();
	this.insts=new Array();
}

gxtkSample.prototype.Discard=function(){
}

gxtkSample.prototype.FreeAudio=function( audio ){
	this.free.push( audio );
}

gxtkSample.prototype.AllocAudio=function(){
	var audio;
	while( this.free.length ){
		audio=this.free.pop();
		try{
			audio.currentTime=0;
			return audio;
		}catch( ex ){
			print( "AUDIO ERROR1!" );
		}
	}
	
	//Max out?
	if( this.insts.length==8 ) return null;
	
	audio=new Audio( this.audio.src );
	
	//yucky loop handler for firefox!
	//
	audio.addEventListener( 'ended',function(){
		if( this.loop ){
			try{
				this.currentTime=0;
				this.play();
			}catch( ex ){
				print( "AUDIO ERROR2!" );
			}
		}
	},false );

	this.insts.push( audio );
	return audio;
}
function util() {
}

util.GetTimestamp = function() {
    var ts = Math.round((new Date()).getTime() / 1000);
    return ts;
}
function bb_router_Router(){
	Object.call(this);
	this.f_handlers=bb_map_StringMap_new.call(new bb_map_StringMap);
	this.f_routers=bb_map_StringMap2_new.call(new bb_map_StringMap2);
	this.f__currentName="";
	this.f__current=null;
	this.f__previous=null;
	this.f__previousName="";
	this.f_director=null;
	this.f_created=bb_list_List_new.call(new bb_list_List);
	this.implments={bb_directorevents_DirectorEvents:1};
}
function bb_router_Router_new(){
	return this;
}
bb_router_Router.prototype.m_Add=function(t_name,t_handler){
	if(this.f_handlers.m_Contains(t_name)){
		error("Router already contains a handler named "+t_name);
	}
	this.f_handlers.m_Set(t_name,t_handler);
	this.f_routers.m_Set2(t_name,object_implements((t_handler),"bb_routerevents_RouterEvents"));
}
bb_router_Router.prototype.m_Get=function(t_name){
	if(!this.f_handlers.m_Contains(t_name)){
		error("Router has no handler named "+t_name);
	}
	return this.f_handlers.m_Get(t_name);
}
bb_router_Router.prototype.m_DispatchOnCreate=function(){
	if(!((this.f_director)!=null)){
		return;
	}
	if(!((this.f__current)!=null)){
		return;
	}
	if(this.f_created.m_Contains(this.f__currentName)){
		return;
	}
	this.f__current.m_OnCreate(this.f_director);
	this.f_created.m_AddLast(this.f__currentName);
}
bb_router_Router.prototype.m_Goto=function(t_name){
	if(t_name==this.f__currentName){
		return;
	}
	this.f__previous=this.f__current;
	this.f__previousName=this.f__currentName;
	this.f__current=this.m_Get(t_name);
	this.f__currentName=t_name;
	this.m_DispatchOnCreate();
	var t_tmpRouter=this.f_routers.m_Get(this.f__previousName);
	if((t_tmpRouter)!=null){
		t_tmpRouter.m_OnLeave();
	}
	t_tmpRouter=this.f_routers.m_Get(this.f__currentName);
	if((t_tmpRouter)!=null){
		t_tmpRouter.m_OnEnter();
	}
}
bb_router_Router.prototype.m_OnCreate=function(t_director){
	this.f_director=t_director;
	this.m_DispatchOnCreate();
}
bb_router_Router.prototype.m_OnLoading=function(){
	if((this.f__current)!=null){
		this.f__current.m_OnLoading();
	}
}
bb_router_Router.prototype.m_OnUpdate=function(t_delta,t_frameTime){
	if((this.f__current)!=null){
		this.f__current.m_OnUpdate(t_delta,t_frameTime);
	}
}
bb_router_Router.prototype.m_OnRender=function(){
	if((this.f__current)!=null){
		this.f__current.m_OnRender();
	}
}
bb_router_Router.prototype.m_OnSuspend=function(){
	if((this.f__current)!=null){
		this.f__current.m_OnSuspend();
	}
}
bb_router_Router.prototype.m_OnResume=function(t_delta){
	if((this.f__current)!=null){
		this.f__current.m_OnResume(t_delta);
	}
}
bb_router_Router.prototype.m_OnKeyDown=function(t_event){
	if((this.f__current)!=null){
		this.f__current.m_OnKeyDown(t_event);
	}
}
bb_router_Router.prototype.m_OnKeyPress=function(t_event){
	if((this.f__current)!=null){
		this.f__current.m_OnKeyPress(t_event);
	}
}
bb_router_Router.prototype.m_OnKeyUp=function(t_event){
	if((this.f__current)!=null){
		this.f__current.m_OnKeyUp(t_event);
	}
}
bb_router_Router.prototype.m_OnTouchDown=function(t_event){
	if((this.f__current)!=null){
		this.f__current.m_OnTouchDown(t_event);
	}
}
bb_router_Router.prototype.m_OnTouchMove=function(t_event){
	if((this.f__current)!=null){
		this.f__current.m_OnTouchMove(t_event);
	}
}
bb_router_Router.prototype.m_OnTouchUp=function(t_event){
	if((this.f__current)!=null){
		this.f__current.m_OnTouchUp(t_event);
	}
}
bb_router_Router.prototype.m_previous=function(){
	return this.f__previous;
}
bb_router_Router.prototype.m_previousName=function(){
	return this.f__previousName;
}
function bb_partial_Partial(){
	Object.call(this);
	this.f__director=null;
	this.implments={bb_directorevents_DirectorEvents:1};
}
function bb_partial_Partial_new(){
	return this;
}
bb_partial_Partial.prototype.m_OnCreate=function(t_director){
	this.f__director=t_director;
}
bb_partial_Partial.prototype.m_director=function(){
	return this.f__director;
}
bb_partial_Partial.prototype.m_OnRender=function(){
}
bb_partial_Partial.prototype.m_OnUpdate=function(t_delta,t_frameTime){
}
bb_partial_Partial.prototype.m_OnKeyUp=function(t_event){
}
bb_partial_Partial.prototype.m_OnLoading=function(){
}
bb_partial_Partial.prototype.m_OnSuspend=function(){
}
bb_partial_Partial.prototype.m_OnResume=function(t_delta){
}
bb_partial_Partial.prototype.m_OnKeyDown=function(t_event){
}
bb_partial_Partial.prototype.m_OnKeyPress=function(t_event){
}
bb_partial_Partial.prototype.m_OnTouchDown=function(t_event){
}
bb_partial_Partial.prototype.m_OnTouchMove=function(t_event){
}
bb_partial_Partial.prototype.m_OnTouchUp=function(t_event){
}
function bb_scene_Scene(){
	bb_partial_Partial.call(this);
	this.f__layer=bb_fanout_FanOut_new.call(new bb_fanout_FanOut);
	this.f__router=null;
	this.implments={bb_routerevents_RouterEvents:1,bb_directorevents_DirectorEvents:1};
}
bb_scene_Scene.prototype=extend_class(bb_partial_Partial);
function bb_scene_Scene_new(){
	bb_partial_Partial_new.call(this);
	return this;
}
bb_scene_Scene.prototype.m_OnEnter=function(){
}
bb_scene_Scene.prototype.m_OnLeave=function(){
}
bb_scene_Scene.prototype.m_OnCreate=function(t_director){
	bb_partial_Partial.prototype.m_OnCreate.call(this,t_director);
	this.f__layer.m_OnCreate(t_director);
	this.f__router=object_downcast((t_director.m_handler()),bb_router_Router);
}
bb_scene_Scene.prototype.m_layer=function(){
	return this.f__layer;
}
bb_scene_Scene.prototype.m_OnLoading=function(){
	this.f__layer.m_OnLoading();
}
bb_scene_Scene.prototype.m_OnUpdate=function(t_delta,t_frameTime){
	this.f__layer.m_OnUpdate(t_delta,t_frameTime);
}
bb_scene_Scene.prototype.m_OnRender=function(){
	this.f__layer.m_OnRender();
}
bb_scene_Scene.prototype.m_OnSuspend=function(){
	this.f__layer.m_OnSuspend();
}
bb_scene_Scene.prototype.m_OnResume=function(t_delta){
	this.f__layer.m_OnResume(t_delta);
}
bb_scene_Scene.prototype.m_OnKeyDown=function(t_event){
	this.f__layer.m_OnKeyDown(t_event);
}
bb_scene_Scene.prototype.m_OnKeyPress=function(t_event){
	this.f__layer.m_OnKeyPress(t_event);
}
bb_scene_Scene.prototype.m_OnKeyUp=function(t_event){
	this.f__layer.m_OnKeyUp(t_event);
}
bb_scene_Scene.prototype.m_OnTouchDown=function(t_event){
	this.f__layer.m_OnTouchDown(t_event);
}
bb_scene_Scene.prototype.m_OnTouchMove=function(t_event){
	this.f__layer.m_OnTouchMove(t_event);
}
bb_scene_Scene.prototype.m_OnTouchUp=function(t_event){
	this.f__layer.m_OnTouchUp(t_event);
}
bb_scene_Scene.prototype.m_router=function(){
	return this.f__router;
}
function bb_introscene_IntroScene(){
	bb_scene_Scene.call(this);
	this.f_background=null;
	this.f_timer=0;
	this.implments={bb_routerevents_RouterEvents:1,bb_directorevents_DirectorEvents:1};
}
bb_introscene_IntroScene.prototype=extend_class(bb_scene_Scene);
function bb_introscene_IntroScene_new(){
	bb_scene_Scene_new.call(this);
	return this;
}
bb_introscene_IntroScene.prototype.m_OnCreate=function(t_director){
	this.f_background=bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"logo.jpg",null);
	this.m_layer().m_Add4(this.f_background);
	bb_scene_Scene.prototype.m_OnCreate.call(this,t_director);
	this.f_background.m_Center(t_director);
}
bb_introscene_IntroScene.prototype.m_OnUpdate=function(t_delta,t_frameTime){
	if(this.f_timer>=1500){
		this.m_router().m_Goto("menu");
	}
	this.f_timer=(((this.f_timer)+t_frameTime)|0);
}
bb_introscene_IntroScene.prototype.m_OnRender=function(){
	bb_graphics_Cls(255.0,255.0,255.0);
	bb_scene_Scene.prototype.m_OnRender.call(this);
}
function bb_map_Map(){
	Object.call(this);
	this.f_root=null;
}
function bb_map_Map_new(){
	return this;
}
bb_map_Map.prototype.m_Compare=function(t_lhs,t_rhs){
}
bb_map_Map.prototype.m_FindNode=function(t_key){
	var t_node=this.f_root;
	while((t_node)!=null){
		var t_cmp=this.m_Compare(t_key,t_node.f_key);
		if(t_cmp>0){
			t_node=t_node.f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node.f_left;
			}else{
				return t_node;
			}
		}
	}
	return t_node;
}
bb_map_Map.prototype.m_Contains=function(t_key){
	return this.m_FindNode(t_key)!=null;
}
bb_map_Map.prototype.m_RotateLeft=function(t_node){
	var t_child=t_node.f_right;
	t_node.f_right=t_child.f_left;
	if((t_child.f_left)!=null){
		t_child.f_left.f_parent=t_node;
	}
	t_child.f_parent=t_node.f_parent;
	if((t_node.f_parent)!=null){
		if(t_node==t_node.f_parent.f_left){
			t_node.f_parent.f_left=t_child;
		}else{
			t_node.f_parent.f_right=t_child;
		}
	}else{
		this.f_root=t_child;
	}
	t_child.f_left=t_node;
	t_node.f_parent=t_child;
	return 0;
}
bb_map_Map.prototype.m_RotateRight=function(t_node){
	var t_child=t_node.f_left;
	t_node.f_left=t_child.f_right;
	if((t_child.f_right)!=null){
		t_child.f_right.f_parent=t_node;
	}
	t_child.f_parent=t_node.f_parent;
	if((t_node.f_parent)!=null){
		if(t_node==t_node.f_parent.f_right){
			t_node.f_parent.f_right=t_child;
		}else{
			t_node.f_parent.f_left=t_child;
		}
	}else{
		this.f_root=t_child;
	}
	t_child.f_right=t_node;
	t_node.f_parent=t_child;
	return 0;
}
bb_map_Map.prototype.m_InsertFixup=function(t_node){
	while(((t_node.f_parent)!=null) && t_node.f_parent.f_color==-1 && ((t_node.f_parent.f_parent)!=null)){
		if(t_node.f_parent==t_node.f_parent.f_parent.f_left){
			var t_uncle=t_node.f_parent.f_parent.f_right;
			if(((t_uncle)!=null) && t_uncle.f_color==-1){
				t_node.f_parent.f_color=1;
				t_uncle.f_color=1;
				t_uncle.f_parent.f_color=-1;
				t_node=t_uncle.f_parent;
			}else{
				if(t_node==t_node.f_parent.f_right){
					t_node=t_node.f_parent;
					this.m_RotateLeft(t_node);
				}
				t_node.f_parent.f_color=1;
				t_node.f_parent.f_parent.f_color=-1;
				this.m_RotateRight(t_node.f_parent.f_parent);
			}
		}else{
			var t_uncle2=t_node.f_parent.f_parent.f_left;
			if(((t_uncle2)!=null) && t_uncle2.f_color==-1){
				t_node.f_parent.f_color=1;
				t_uncle2.f_color=1;
				t_uncle2.f_parent.f_color=-1;
				t_node=t_uncle2.f_parent;
			}else{
				if(t_node==t_node.f_parent.f_left){
					t_node=t_node.f_parent;
					this.m_RotateRight(t_node);
				}
				t_node.f_parent.f_color=1;
				t_node.f_parent.f_parent.f_color=-1;
				this.m_RotateLeft(t_node.f_parent.f_parent);
			}
		}
	}
	this.f_root.f_color=1;
	return 0;
}
bb_map_Map.prototype.m_Set=function(t_key,t_value){
	var t_node=this.f_root;
	var t_parent=null;
	var t_cmp=0;
	while((t_node)!=null){
		t_parent=t_node;
		t_cmp=this.m_Compare(t_key,t_node.f_key);
		if(t_cmp>0){
			t_node=t_node.f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node.f_left;
			}else{
				t_node.f_value=t_value;
				return false;
			}
		}
	}
	t_node=bb_map_Node_new.call(new bb_map_Node,t_key,t_value,-1,t_parent);
	if((t_parent)!=null){
		if(t_cmp>0){
			t_parent.f_right=t_node;
		}else{
			t_parent.f_left=t_node;
		}
		this.m_InsertFixup(t_node);
	}else{
		this.f_root=t_node;
	}
	return true;
}
bb_map_Map.prototype.m_Get=function(t_key){
	var t_node=this.m_FindNode(t_key);
	if((t_node)!=null){
		return t_node.f_value;
	}
	return null;
}
function bb_map_StringMap(){
	bb_map_Map.call(this);
}
bb_map_StringMap.prototype=extend_class(bb_map_Map);
function bb_map_StringMap_new(){
	bb_map_Map_new.call(this);
	return this;
}
bb_map_StringMap.prototype.m_Compare=function(t_lhs,t_rhs){
	return string_compare(t_lhs,t_rhs);
}
function bb_map_Node(){
	Object.call(this);
	this.f_key="";
	this.f_right=null;
	this.f_left=null;
	this.f_value=null;
	this.f_color=0;
	this.f_parent=null;
}
function bb_map_Node_new(t_key,t_value,t_color,t_parent){
	this.f_key=t_key;
	this.f_value=t_value;
	this.f_color=t_color;
	this.f_parent=t_parent;
	return this;
}
function bb_map_Node_new2(){
	return this;
}
function bb_map_Map2(){
	Object.call(this);
	this.f_root=null;
}
function bb_map_Map2_new(){
	return this;
}
bb_map_Map2.prototype.m_Compare=function(t_lhs,t_rhs){
}
bb_map_Map2.prototype.m_RotateLeft2=function(t_node){
	var t_child=t_node.f_right;
	t_node.f_right=t_child.f_left;
	if((t_child.f_left)!=null){
		t_child.f_left.f_parent=t_node;
	}
	t_child.f_parent=t_node.f_parent;
	if((t_node.f_parent)!=null){
		if(t_node==t_node.f_parent.f_left){
			t_node.f_parent.f_left=t_child;
		}else{
			t_node.f_parent.f_right=t_child;
		}
	}else{
		this.f_root=t_child;
	}
	t_child.f_left=t_node;
	t_node.f_parent=t_child;
	return 0;
}
bb_map_Map2.prototype.m_RotateRight2=function(t_node){
	var t_child=t_node.f_left;
	t_node.f_left=t_child.f_right;
	if((t_child.f_right)!=null){
		t_child.f_right.f_parent=t_node;
	}
	t_child.f_parent=t_node.f_parent;
	if((t_node.f_parent)!=null){
		if(t_node==t_node.f_parent.f_right){
			t_node.f_parent.f_right=t_child;
		}else{
			t_node.f_parent.f_left=t_child;
		}
	}else{
		this.f_root=t_child;
	}
	t_child.f_right=t_node;
	t_node.f_parent=t_child;
	return 0;
}
bb_map_Map2.prototype.m_InsertFixup2=function(t_node){
	while(((t_node.f_parent)!=null) && t_node.f_parent.f_color==-1 && ((t_node.f_parent.f_parent)!=null)){
		if(t_node.f_parent==t_node.f_parent.f_parent.f_left){
			var t_uncle=t_node.f_parent.f_parent.f_right;
			if(((t_uncle)!=null) && t_uncle.f_color==-1){
				t_node.f_parent.f_color=1;
				t_uncle.f_color=1;
				t_uncle.f_parent.f_color=-1;
				t_node=t_uncle.f_parent;
			}else{
				if(t_node==t_node.f_parent.f_right){
					t_node=t_node.f_parent;
					this.m_RotateLeft2(t_node);
				}
				t_node.f_parent.f_color=1;
				t_node.f_parent.f_parent.f_color=-1;
				this.m_RotateRight2(t_node.f_parent.f_parent);
			}
		}else{
			var t_uncle2=t_node.f_parent.f_parent.f_left;
			if(((t_uncle2)!=null) && t_uncle2.f_color==-1){
				t_node.f_parent.f_color=1;
				t_uncle2.f_color=1;
				t_uncle2.f_parent.f_color=-1;
				t_node=t_uncle2.f_parent;
			}else{
				if(t_node==t_node.f_parent.f_left){
					t_node=t_node.f_parent;
					this.m_RotateRight2(t_node);
				}
				t_node.f_parent.f_color=1;
				t_node.f_parent.f_parent.f_color=-1;
				this.m_RotateLeft2(t_node.f_parent.f_parent);
			}
		}
	}
	this.f_root.f_color=1;
	return 0;
}
bb_map_Map2.prototype.m_Set2=function(t_key,t_value){
	var t_node=this.f_root;
	var t_parent=null;
	var t_cmp=0;
	while((t_node)!=null){
		t_parent=t_node;
		t_cmp=this.m_Compare(t_key,t_node.f_key);
		if(t_cmp>0){
			t_node=t_node.f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node.f_left;
			}else{
				t_node.f_value=t_value;
				return false;
			}
		}
	}
	t_node=bb_map_Node2_new.call(new bb_map_Node2,t_key,t_value,-1,t_parent);
	if((t_parent)!=null){
		if(t_cmp>0){
			t_parent.f_right=t_node;
		}else{
			t_parent.f_left=t_node;
		}
		this.m_InsertFixup2(t_node);
	}else{
		this.f_root=t_node;
	}
	return true;
}
bb_map_Map2.prototype.m_FindNode=function(t_key){
	var t_node=this.f_root;
	while((t_node)!=null){
		var t_cmp=this.m_Compare(t_key,t_node.f_key);
		if(t_cmp>0){
			t_node=t_node.f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node.f_left;
			}else{
				return t_node;
			}
		}
	}
	return t_node;
}
bb_map_Map2.prototype.m_Get=function(t_key){
	var t_node=this.m_FindNode(t_key);
	if((t_node)!=null){
		return t_node.f_value;
	}
	return null;
}
function bb_map_StringMap2(){
	bb_map_Map2.call(this);
}
bb_map_StringMap2.prototype=extend_class(bb_map_Map2);
function bb_map_StringMap2_new(){
	bb_map_Map2_new.call(this);
	return this;
}
bb_map_StringMap2.prototype.m_Compare=function(t_lhs,t_rhs){
	return string_compare(t_lhs,t_rhs);
}
function bb_map_Node2(){
	Object.call(this);
	this.f_key="";
	this.f_right=null;
	this.f_left=null;
	this.f_value=null;
	this.f_color=0;
	this.f_parent=null;
}
function bb_map_Node2_new(t_key,t_value,t_color,t_parent){
	this.f_key=t_key;
	this.f_value=t_value;
	this.f_color=t_color;
	this.f_parent=t_parent;
	return this;
}
function bb_map_Node2_new2(){
	return this;
}
function bb_menuscene_MenuScene(){
	bb_scene_Scene.call(this);
	this.f_easy=null;
	this.f_normal=null;
	this.f_normalActive=null;
	this.f_advanced=null;
	this.f_advancedActive=null;
	this.f_highscore=null;
	this.f_lock=null;
	this.f_isLocked=true;
	this.implments={bb_routerevents_RouterEvents:1,bb_directorevents_DirectorEvents:1};
}
bb_menuscene_MenuScene.prototype=extend_class(bb_scene_Scene);
function bb_menuscene_MenuScene_new(){
	bb_scene_Scene_new.call(this);
	return this;
}
bb_menuscene_MenuScene.prototype.m_toggleLock=function(){
	if(this.f_isLocked){
		this.f_isLocked=false;
		this.m_layer().m_Remove(this.f_lock);
		this.m_layer().m_Remove(this.f_normal);
		this.m_layer().m_Remove(this.f_advanced);
		this.m_layer().m_Add4(this.f_normalActive);
		this.m_layer().m_Add4(this.f_advancedActive);
	}else{
		this.f_isLocked=true;
		this.m_layer().m_Remove(this.f_normalActive);
		this.m_layer().m_Remove(this.f_advancedActive);
		this.m_layer().m_Add4(this.f_normal);
		this.m_layer().m_Add4(this.f_advanced);
		this.m_layer().m_Add4(this.f_lock);
	}
}
bb_menuscene_MenuScene.prototype.m_OnCreate=function(t_director){
	var t_offset=bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,0.0,150.0);
	this.f_easy=bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"01_02-easy.png",bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,0.0,290.0));
	this.f_normal=bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"01_02-normal.png",this.f_easy.m_pos().m_Copy().m_Add2(t_offset));
	this.f_normalActive=bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"01_02-normal_active.png",this.f_normal.m_pos());
	this.f_advanced=bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"01_02-advanced.png",this.f_normal.m_pos().m_Copy().m_Add2(t_offset));
	this.f_advancedActive=bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"01_02-advanced_active.png",this.f_advanced.m_pos());
	this.f_highscore=bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"01_04button-highscore.png",this.f_advanced.m_pos().m_Copy().m_Add2(t_offset));
	var t_pos=this.f_advanced.m_pos().m_Copy().m_Add2(this.f_advanced.m_size()).m_Sub(this.f_normal.m_pos()).m_Div2(2.0);
	t_pos.f_y+=this.f_normal.m_pos().f_y;
	this.f_lock=bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"locked.png",t_pos);
	this.f_lock.m_pos().f_y-=this.f_lock.m_center().f_y;
	this.m_layer().m_Add4(bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"01_main.jpg",null));
	this.m_layer().m_Add4(this.f_easy);
	this.m_layer().m_Add4(this.f_normal);
	this.m_layer().m_Add4(this.f_advanced);
	this.m_layer().m_Add4(this.f_highscore);
	this.m_layer().m_Add4(this.f_lock);
	bb_scene_Scene.prototype.m_OnCreate.call(this,t_director);
	this.m_toggleLock();
	this.f_easy.m_CenterX(t_director);
	this.f_normal.m_CenterX(t_director);
	this.f_advanced.m_CenterX(t_director);
	this.f_highscore.m_CenterX(t_director);
}
bb_menuscene_MenuScene.prototype.m_PlayEasy=function(){
	bb_severity_CurrentSeverity().m_Set5(0);
	this.m_router().m_Goto("game");
}
bb_menuscene_MenuScene.prototype.m_PlayNormal=function(){
	if(this.f_isLocked){
		return;
	}
	bb_severity_CurrentSeverity().m_Set5(1);
	this.m_router().m_Goto("game");
}
bb_menuscene_MenuScene.prototype.m_PlayAdvanced=function(){
	if(this.f_isLocked){
		return;
	}
	bb_severity_CurrentSeverity().m_Set5(2);
	this.m_router().m_Goto("game");
}
bb_menuscene_MenuScene.prototype.m_OnTouchDown=function(t_event){
	if(this.f_easy.m_Collide(t_event.m_pos())){
		this.m_PlayEasy();
	}
	if(this.f_normal.m_Collide(t_event.m_pos())){
		this.m_PlayNormal();
	}
	if(this.f_advanced.m_Collide(t_event.m_pos())){
		this.m_PlayAdvanced();
	}
	if(this.f_highscore.m_Collide(t_event.m_pos())){
		this.m_router().m_Goto("highscore");
	}
}
bb_menuscene_MenuScene.prototype.m_OnKeyDown=function(t_event){
	var t_1=t_event.m_code();
	if(t_1==69){
		this.m_PlayEasy();
	}else{
		if(t_1==78){
			this.m_PlayNormal();
		}else{
			if(t_1==65){
				this.m_PlayAdvanced();
			}else{
				if(t_1==72){
					this.m_router().m_Goto("highscore");
				}else{
					if(t_1==76){
						this.m_toggleLock();
					}
				}
			}
		}
	}
}
function bb_highscorescene_HighscoreScene(){
	bb_scene_Scene.call(this);
	this.f_font=null;
	this.f_background=null;
	this.f_highscore=bb_gamehighscore_GameHighscore_new.call(new bb_gamehighscore_GameHighscore);
	this.implments={bb_routerevents_RouterEvents:1,bb_directorevents_DirectorEvents:1};
}
bb_highscorescene_HighscoreScene.prototype=extend_class(bb_scene_Scene);
function bb_highscorescene_HighscoreScene_new(){
	bb_scene_Scene_new.call(this);
	return this;
}
bb_highscorescene_HighscoreScene.prototype.m_OnCreate=function(t_director){
	this.f_font=bb_angelfont2_AngelFont_new.call(new bb_angelfont2_AngelFont,"CoRa");
	this.f_background=bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"highscore_bg.png",null);
	this.f_background.m_OnCreate(t_director);
	bb_scene_Scene.prototype.m_OnCreate.call(this,t_director);
}
bb_highscorescene_HighscoreScene.prototype.m_OnEnter=function(){
	bb_statestore_StateStore_Load(this.f_highscore);
}
bb_highscorescene_HighscoreScene.prototype.m_OnLeave=function(){
}
bb_highscorescene_HighscoreScene.prototype.m_DrawEntries=function(){
	var t_posY=190;
	var t_=this.f_highscore.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_score=t_.m_NextObject();
		this.f_font.m_DrawText2(String(t_score.f_value),100,t_posY,2);
		this.f_font.m_DrawText(t_score.f_key,110,t_posY);
		t_posY+=35;
	}
}
bb_highscorescene_HighscoreScene.prototype.m_OnRender=function(){
	this.f_background.m_OnRender();
	bb_graphics_PushMatrix();
	bb_graphics_SetColor(255.0,133.0,0.0);
	bb_graphics_Scale(1.5,1.5);
	this.m_DrawEntries();
	bb_graphics_PopMatrix();
}
bb_highscorescene_HighscoreScene.prototype.m_OnKeyDown=function(t_event){
	this.m_router().m_Goto("menu");
}
bb_highscorescene_HighscoreScene.prototype.m_OnTouchDown=function(t_event){
	this.m_router().m_Goto("menu");
}
function bb_gamescene_GameScene(){
	bb_scene_Scene.call(this);
	this.f_chute=null;
	this.f_lowerShapes=null;
	this.f_severity=null;
	this.f_slider=null;
	this.f_upperShapes=null;
	this.f_errorAnimations=null;
	this.f_pauseButton=null;
	this.f_scoreFont=null;
	this.f_comboFont=null;
	this.f_comboAnimation=null;
	this.f_newHighscoreFont=null;
	this.f_newHighscoreAnimation=null;
	this.f_minHighscore=0;
	this.f_isNewHighscoreRecord=false;
	this.f_checkPosY=.0;
	this.f_pauseTime=0;
	this.f_score=0;
	this.f_collisionCheckedLastUpdate=false;
	this.f_falseSpriteStrack=bb_stack_Stack2_new.call(new bb_stack_Stack2);
	this.f_lastMatchTime=[0,0,0,0];
	this.f_comboPending=false;
	this.f_comboPendingSince=0;
	this.f_lastSlowUpdate=.0;
	this.implments={bb_routerevents_RouterEvents:1,bb_directorevents_DirectorEvents:1};
}
bb_gamescene_GameScene.prototype=extend_class(bb_scene_Scene);
function bb_gamescene_GameScene_new(){
	bb_scene_Scene_new.call(this);
	return this;
}
bb_gamescene_GameScene.prototype.m_LoadHighscoreMinValue=function(){
	var t_highscore=bb_gamehighscore_GameHighscore_new.call(new bb_gamehighscore_GameHighscore);
	bb_statestore_StateStore_Load(t_highscore);
	this.f_minHighscore=t_highscore.m_Last().f_value;
	this.f_isNewHighscoreRecord=!(t_highscore.m_Count()==t_highscore.m_maxCount());
}
bb_gamescene_GameScene.prototype.m_OnCreate=function(t_director){
	this.f_chute=bb_chute_Chute_new.call(new bb_chute_Chute);
	this.f_lowerShapes=bb_fanout_FanOut_new.call(new bb_fanout_FanOut);
	this.f_severity=bb_severity_CurrentSeverity();
	this.f_slider=bb_slider_Slider_new.call(new bb_slider_Slider);
	this.f_upperShapes=bb_fanout_FanOut_new.call(new bb_fanout_FanOut);
	this.f_errorAnimations=bb_fanout_FanOut_new.call(new bb_fanout_FanOut);
	this.f_pauseButton=bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"pause-button.png",null);
	this.f_pauseButton.m_pos2(t_director.m_size().m_Copy().m_Sub(this.f_pauseButton.m_size()));
	this.f_pauseButton.m_pos().f_y=0.0;
	this.f_scoreFont=bb_font_Font_new.call(new bb_font_Font,"CoRa",null);
	this.f_scoreFont.m_pos2(bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,t_director.m_center().f_x,t_director.m_size().f_y-50.0));
	this.f_scoreFont.m_text("Score: 0");
	this.f_scoreFont.m_align(1);
	this.f_comboFont=bb_font_Font_new.call(new bb_font_Font,"CoRa",t_director.m_center().m_Copy());
	this.f_comboFont.m_text("COMBO x 2");
	var t_=this.f_comboFont.m_pos();
	t_.f_y=t_.f_y-150.0;
	var t_2=this.f_comboFont.m_pos();
	t_2.f_x=t_2.f_x-70.0;
	this.f_comboAnimation=bb_animation_Animation_new.call(new bb_animation_Animation,2.0,0.0,750.0);
	this.f_comboAnimation.f_effect=(bb_fader_FaderScale_new.call(new bb_fader_FaderScale));
	this.f_comboAnimation.f_transition=(bb_transition_TransitionInCubic_new.call(new bb_transition_TransitionInCubic));
	this.f_comboAnimation.m_Add4(this.f_comboFont);
	this.f_comboAnimation.m_Pause();
	this.f_newHighscoreFont=bb_font_Font_new.call(new bb_font_Font,"CoRa",t_director.m_center().m_Copy());
	this.f_newHighscoreFont.m_text("NEW HIGHSCORE");
	var t_3=this.f_newHighscoreFont.m_pos();
	t_3.f_y=t_3.f_y/2.0;
	var t_4=this.f_newHighscoreFont.m_pos();
	t_4.f_x=t_4.f_x-120.0;
	this.f_newHighscoreAnimation=bb_animation_Animation_new.call(new bb_animation_Animation,2.0,0.0,2000.0);
	this.f_newHighscoreAnimation.f_effect=(bb_fader_FaderScale_new.call(new bb_fader_FaderScale));
	this.f_newHighscoreAnimation.f_transition=(bb_transition_TransitionInCubic_new.call(new bb_transition_TransitionInCubic));
	this.f_newHighscoreAnimation.m_Add4(this.f_newHighscoreFont);
	this.f_newHighscoreAnimation.m_Pause();
	this.m_LoadHighscoreMinValue();
	this.m_layer().m_Add4(bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"bg_960x640.png",null));
	this.m_layer().m_Add4(this.f_lowerShapes);
	this.m_layer().m_Add4(this.f_slider);
	this.m_layer().m_Add4(this.f_upperShapes);
	this.m_layer().m_Add4(this.f_errorAnimations);
	this.m_layer().m_Add4(this.f_newHighscoreAnimation);
	this.m_layer().m_Add4(this.f_comboAnimation);
	this.m_layer().m_Add4(this.f_chute);
	this.m_layer().m_Add4(this.f_scoreFont);
	this.m_layer().m_Add4(this.f_pauseButton);
	bb_scene_Scene.prototype.m_OnCreate.call(this,t_director);
	this.f_checkPosY=t_director.m_size().f_y-((this.f_slider.f_images[0].m_Height()/2)|0)-15.0;
}
bb_gamescene_GameScene.prototype.m_OnEnterPaused=function(){
	var t_diff=bb_app_Millisecs()-this.f_pauseTime;
	this.f_pauseTime=0;
	this.f_severity.m_WarpTime(t_diff);
}
bb_gamescene_GameScene.prototype.m_OnEnter=function(){
	if(this.f_pauseTime>0){
		this.m_OnEnterPaused();
		return;
	}
	this.f_score=0;
	this.f_lowerShapes.m_Clear();
	this.f_upperShapes.m_Clear();
	this.f_errorAnimations.m_Clear();
	this.f_severity.m_Restart();
	this.f_chute.m_Restart();
	this.f_slider.m_Restart();
}
bb_gamescene_GameScene.prototype.m_OnLeave=function(){
}
bb_gamescene_GameScene.prototype.m_HandleGameOver=function(){
	if((this.f_chute.m_Height())<this.f_slider.f_arrowLeft.m_pos().f_y){
		return false;
	}
	if(this.f_isNewHighscoreRecord){
		object_downcast((this.m_router().m_Get("newhighscore")),bb_newhighscorescene_NewHighscoreScene).f_score=this.f_score;
		this.m_router().m_Goto("newhighscore");
	}else{
		this.m_router().m_Goto("gameover");
	}
	return true;
}
bb_gamescene_GameScene.prototype.m_OnMissmatch=function(t_shape){
	var t_sprite=null;
	if(this.f_falseSpriteStrack.m_Length()>0){
		t_sprite=this.f_falseSpriteStrack.m_Pop();
	}else{
		t_sprite=bb_sprite_Sprite_new2.call(new bb_sprite_Sprite,"false.png",140,88,6,100,null);
	}
	t_sprite.m_pos2(t_shape.m_pos());
	t_sprite.m_Restart();
	this.f_chute.f_height+=15;
	this.f_lastMatchTime=[0,0,0,0];
	this.f_errorAnimations.m_Add4(t_sprite);
}
bb_gamescene_GameScene.prototype.m_IncrementScore=function(t_value){
	this.f_score+=t_value;
	this.f_scoreFont.m_text("Score: "+String(this.f_score));
	if(!this.f_isNewHighscoreRecord && this.f_score>=this.f_minHighscore){
		this.f_isNewHighscoreRecord=true;
		this.f_newHighscoreAnimation.m_Restart();
		this.m_layer().m_Add4(this.f_newHighscoreAnimation);
	}
}
bb_gamescene_GameScene.prototype.m_OnMatch=function(t_shape){
	this.f_lastMatchTime[t_shape.f_lane]=bb_app_Millisecs();
	this.m_IncrementScore(10);
}
bb_gamescene_GameScene.prototype.m_CheckShapeCollisions=function(){
	var t_shape=null;
	var t_=this.f_upperShapes.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_obj=t_.m_NextObject();
		t_shape=object_downcast((t_obj),bb_shape_Shape);
		if(t_shape.m_pos().f_y+(bb_shape_Shape_images[0].m_Height())<this.f_checkPosY){
			continue;
		}
		this.f_upperShapes.m_Remove(t_shape);
		if(!this.f_slider.m_Match(t_shape)){
			this.m_OnMissmatch(t_shape);
		}else{
			this.f_lowerShapes.m_Add4(t_shape);
			this.m_OnMatch(t_shape);
		}
	}
}
bb_gamescene_GameScene.prototype.m_DetectComboTrigger=function(){
	var t_lanesNotZero=0;
	var t_hotLanes=0;
	var t_now=bb_app_Millisecs();
	for(var t_lane=0;t_lane<this.f_lastMatchTime.length;t_lane=t_lane+1){
		if(this.f_lastMatchTime[t_lane]==0){
			continue;
		}
		t_lanesNotZero+=1;
		if(this.f_lastMatchTime[t_lane]+300>=t_now){
			t_hotLanes+=1;
			if(t_hotLanes>=2 && !this.f_comboPending){
				this.f_comboPending=true;
				this.f_comboPendingSince=t_now;
			}
		}else{
			if(!this.f_comboPending){
				this.f_lastMatchTime[t_lane]=0;
			}
		}
	}
	if(!this.f_comboPending){
		return;
	}
	if(this.f_comboPendingSince+300>t_now){
		return;
	}
	this.f_lastMatchTime=[0,0,0,0];
	this.f_comboPending=false;
	this.f_chute.f_height=bb_math_Max(75,this.f_chute.f_height-35);
	this.m_IncrementScore(10*t_lanesNotZero);
	this.f_comboFont.m_text("COMBO x "+String(t_lanesNotZero));
	this.f_comboAnimation.m_Restart();
	this.m_layer().m_Add4(this.f_comboAnimation);
}
bb_gamescene_GameScene.prototype.m_DropNewShapeIfRequested=function(){
	if(!this.f_severity.m_ShapeShouldBeDropped()){
		return;
	}
	this.f_upperShapes.m_Add4(bb_shape_Shape_new.call(new bb_shape_Shape,this.f_severity.m_RandomType(),this.f_severity.m_RandomLane(),this.f_chute));
	this.f_severity.m_ShapeDropped();
}
bb_gamescene_GameScene.prototype.m_RemoveLostShapes=function(){
	var t_directoySizeY=this.m_director().m_size().f_y;
	var t_shape=null;
	var t_=this.f_lowerShapes.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_obj=t_.m_NextObject();
		t_shape=object_downcast((t_obj),bb_shape_Shape);
		if(t_shape.m_pos().f_y>t_directoySizeY){
			this.f_lowerShapes.m_Remove(t_shape);
		}
	}
}
bb_gamescene_GameScene.prototype.m_RemoveFinishedErroAnimations=function(){
	var t_sprite=null;
	var t_=this.f_errorAnimations.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_obj=t_.m_NextObject();
		t_sprite=object_downcast((t_obj),bb_sprite_Sprite);
		if(t_sprite.m_animationIsDone()){
			this.f_errorAnimations.m_Remove(t_sprite);
			this.f_falseSpriteStrack.m_Push2(t_sprite);
		}
	}
}
bb_gamescene_GameScene.prototype.m_OnUpdate=function(t_delta,t_frameTime){
	bb_scene_Scene.prototype.m_OnUpdate.call(this,t_delta,t_frameTime);
	if(this.m_HandleGameOver()){
		return;
	}
	if(this.f_collisionCheckedLastUpdate){
		this.f_collisionCheckedLastUpdate=false;
	}else{
		this.f_collisionCheckedLastUpdate=true;
		this.m_CheckShapeCollisions();
	}
	this.m_DetectComboTrigger();
	this.f_severity.m_OnUpdate(t_delta,t_frameTime);
	this.m_DropNewShapeIfRequested();
	this.f_lastSlowUpdate+=t_frameTime;
	if(this.f_lastSlowUpdate>=1000.0){
		this.f_lastSlowUpdate=0.0;
		this.m_RemoveLostShapes();
		this.m_RemoveFinishedErroAnimations();
		if(!this.f_comboAnimation.m_IsPlaying()){
			this.m_layer().m_Remove(this.f_comboAnimation);
		}
		if(!this.f_newHighscoreAnimation.m_IsPlaying()){
			this.m_layer().m_Remove(this.f_newHighscoreAnimation);
		}
	}
}
bb_gamescene_GameScene.prototype.m_StartPause=function(){
	this.f_pauseTime=bb_app_Millisecs();
	this.m_router().m_Goto("pause");
}
bb_gamescene_GameScene.prototype.m_FastDropMatchingShapes=function(){
	var t_shape=null;
	var t_=this.f_upperShapes.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_obj=t_.m_NextObject();
		t_shape=object_downcast((t_obj),bb_shape_Shape);
		if(t_shape.f_isFast){
			continue;
		}
		if(this.f_slider.m_Match(t_shape)){
			t_shape.f_isFast=true;
		}
	}
}
bb_gamescene_GameScene.prototype.m_OnKeyDown=function(t_event){
	var t_1=t_event.m_code();
	if(t_1==80){
		this.m_StartPause();
	}else{
		if(t_1==40 || t_1==65576){
			this.m_FastDropMatchingShapes();
		}else{
			if(t_1==37 || t_1==65573){
				this.f_slider.m_SlideLeft();
			}else{
				if(t_1==39 || t_1==65575){
					this.f_slider.m_SlideRight();
				}
			}
		}
	}
}
bb_gamescene_GameScene.prototype.m_OnTouchDown=function(t_event){
	if(this.f_pauseButton.m_Collide(t_event.m_pos())){
		this.m_StartPause();
	}
	if(this.f_slider.f_arrowRight.m_Collide(t_event.m_pos())){
		this.f_slider.m_SlideRight();
	}
	if(this.f_slider.f_arrowLeft.m_Collide(t_event.m_pos())){
		this.f_slider.m_SlideLeft();
	}
}
bb_gamescene_GameScene.prototype.m_HandleSliderSwipe=function(t_event){
	var t_swipe=t_event.m_startDelta().m_Normalize();
	if(bb_math_Abs2(t_swipe.f_x)<=0.2){
		return;
	}
	if(t_swipe.f_x<0.0){
		this.f_slider.m_SlideLeft();
	}else{
		this.f_slider.m_SlideRight();
	}
}
bb_gamescene_GameScene.prototype.m_HandleBackgroundSwipe=function(t_event){
	var t_swipe=t_event.m_startDelta().m_Normalize();
	if(t_swipe.f_y>0.2){
		this.m_FastDropMatchingShapes();
	}
}
bb_gamescene_GameScene.prototype.m_OnTouchUp=function(t_event){
	if(t_event.m_startPos().f_y>=this.f_slider.m_pos().f_y){
		this.m_HandleSliderSwipe(t_event);
	}else{
		this.m_HandleBackgroundSwipe(t_event);
	}
}
bb_gamescene_GameScene.prototype.m_OnTouchMove=function(t_event){
}
bb_gamescene_GameScene.prototype.m_OnPauseLeaveGame=function(){
	this.f_pauseTime=0;
}
function bb_gameoverscene_GameOverScene(){
	bb_scene_Scene.call(this);
	this.f_overlay=null;
	this.implments={bb_routerevents_RouterEvents:1,bb_directorevents_DirectorEvents:1};
}
bb_gameoverscene_GameOverScene.prototype=extend_class(bb_scene_Scene);
function bb_gameoverscene_GameOverScene_new(){
	bb_scene_Scene_new.call(this);
	return this;
}
bb_gameoverscene_GameOverScene.prototype.m_OnCreate=function(t_director){
	bb_scene_Scene.prototype.m_OnCreate.call(this,t_director);
	this.f_overlay=bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"gameover.png",null);
	this.f_overlay.m_OnCreate(t_director);
}
bb_gameoverscene_GameOverScene.prototype.m_OnRender=function(){
	this.m_router().m_previous().m_OnRender();
	this.f_overlay.m_OnRender();
}
bb_gameoverscene_GameOverScene.prototype.m_OnTouchDown=function(t_event){
	this.m_router().m_Goto("menu");
}
bb_gameoverscene_GameOverScene.prototype.m_OnKeyDown=function(t_event){
	this.m_router().m_Goto("menu");
}
function bb_pausescene_PauseScene(){
	bb_scene_Scene.call(this);
	this.f_overlay=null;
	this.f_continueBtn=null;
	this.f_quitBtn=null;
	this.implments={bb_routerevents_RouterEvents:1,bb_directorevents_DirectorEvents:1};
}
bb_pausescene_PauseScene.prototype=extend_class(bb_scene_Scene);
function bb_pausescene_PauseScene_new(){
	bb_scene_Scene_new.call(this);
	return this;
}
bb_pausescene_PauseScene.prototype.m_OnCreate=function(t_director){
	this.f_overlay=bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"pause.png",null);
	this.m_layer().m_Add4(this.f_overlay);
	this.f_continueBtn=bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"01_06-continue.png",null);
	this.m_layer().m_Add4(this.f_continueBtn);
	this.f_quitBtn=bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"01_07-quit.png",null);
	this.m_layer().m_Add4(this.f_quitBtn);
	bb_scene_Scene.prototype.m_OnCreate.call(this,t_director);
}
bb_pausescene_PauseScene.prototype.m_OnEnter=function(){
	this.f_continueBtn.m_Center(this.m_director());
	this.f_quitBtn.m_pos2(this.f_continueBtn.m_pos().m_Copy());
	this.f_quitBtn.m_pos().f_y+=this.f_continueBtn.m_size().f_y+40.0;
}
bb_pausescene_PauseScene.prototype.m_OnRender=function(){
	this.m_router().m_previous().m_OnRender();
	bb_scene_Scene.prototype.m_OnRender.call(this);
}
bb_pausescene_PauseScene.prototype.m_OnKeyDown=function(t_event){
	var t_1=t_event.m_code();
	if(t_1==27 || t_1==81){
		object_downcast((this.m_router().m_previous()),bb_gamescene_GameScene).m_OnPauseLeaveGame();
		this.m_router().m_Goto("menu");
	}else{
		this.m_router().m_Goto(this.m_router().m_previousName());
	}
}
bb_pausescene_PauseScene.prototype.m_OnTouchDown=function(t_event){
	if(this.f_continueBtn.m_Collide(t_event.m_pos())){
		this.m_router().m_Goto(this.m_router().m_previousName());
	}
	if(this.f_quitBtn.m_Collide(t_event.m_pos())){
		object_downcast((this.m_router().m_previous()),bb_gamescene_GameScene).m_OnPauseLeaveGame();
		this.m_router().m_Goto("menu");
	}
}
function bb_newhighscorescene_NewHighscoreScene(){
	bb_scene_Scene.call(this);
	this.f_continueBtn=null;
	this.f_input=null;
	this.f_score=0;
	this.f_highscore=bb_gamehighscore_GameHighscore_new.call(new bb_gamehighscore_GameHighscore);
	this.implments={bb_routerevents_RouterEvents:1,bb_directorevents_DirectorEvents:1};
}
bb_newhighscorescene_NewHighscoreScene.prototype=extend_class(bb_scene_Scene);
function bb_newhighscorescene_NewHighscoreScene_new(){
	bb_scene_Scene_new.call(this);
	return this;
}
bb_newhighscorescene_NewHighscoreScene.prototype.m_OnCreate=function(t_director){
	var t_background=bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"newhighscore.png",null);
	this.m_layer().m_Add4(t_background);
	this.f_continueBtn=bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"01_06-continue.png",null);
	this.m_layer().m_Add4(this.f_continueBtn);
	this.f_input=bb_textinput_TextInput_new.call(new bb_textinput_TextInput,"CoRa",bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,90.0,430.0));
	this.m_layer().m_Add4(this.f_input);
	bb_scene_Scene.prototype.m_OnCreate.call(this,t_director);
}
bb_newhighscorescene_NewHighscoreScene.prototype.m_OnEnter=function(){
	this.f_continueBtn.m_CenterX(this.m_director());
	this.f_continueBtn.m_pos().f_y=this.f_input.m_pos().f_y+175.0;
}
bb_newhighscorescene_NewHighscoreScene.prototype.m_OnRender=function(){
	this.m_router().m_previous().m_OnRender();
	bb_scene_Scene.prototype.m_OnRender.call(this);
}
bb_newhighscorescene_NewHighscoreScene.prototype.m_SaveAndContinue=function(){
	var t_level=bb_severity_CurrentSeverity().m_ToString()+" ";
	bb_statestore_StateStore_Load(this.f_highscore);
	this.f_highscore.m_Add5(t_level+this.f_input.m_text2(),this.f_score);
	bb_statestore_StateStore_Save(this.f_highscore);
	this.m_router().m_Goto("highscore");
}
bb_newhighscorescene_NewHighscoreScene.prototype.m_OnKeyDown=function(t_event){
	bb_scene_Scene.prototype.m_OnKeyDown.call(this,t_event);
	if(t_event.m_code()==13){
		this.m_SaveAndContinue();
	}
}
bb_newhighscorescene_NewHighscoreScene.prototype.m_OnTouchDown=function(t_event){
	if(this.f_continueBtn.m_Collide(t_event.m_pos())){
		this.m_SaveAndContinue();
	}
}
function bb_app_App(){
	Object.call(this);
}
function bb_app_App_new(){
	bb_app_device=bb_app_AppDevice_new.call(new bb_app_AppDevice,this);
	return this;
}
bb_app_App.prototype.m_OnCreate2=function(){
	return 0;
}
bb_app_App.prototype.m_OnUpdate2=function(){
	return 0;
}
bb_app_App.prototype.m_OnSuspend=function(){
	return 0;
}
bb_app_App.prototype.m_OnResume2=function(){
	return 0;
}
bb_app_App.prototype.m_OnRender=function(){
	return 0;
}
bb_app_App.prototype.m_OnLoading=function(){
	return 0;
}
function bb_director_Director(){
	bb_app_App.call(this);
	this.f__size=null;
	this.f__center=null;
	this.f__device=bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,0.0,0.0);
	this.f__scale=null;
	this.f__inputController=bb_inputcontroller_InputController_new.call(new bb_inputcontroller_InputController);
	this.f__handler=null;
	this.f_onCreateDispatched=false;
	this.f_appOnCreateCatched=false;
	this.f_deltaTimer=null;
	this.implments={bb_sizeable_Sizeable:1};
}
bb_director_Director.prototype=extend_class(bb_app_App);
bb_director_Director.prototype.m_size=function(){
	return this.f__size;
}
bb_director_Director.prototype.m_RecalculateScale=function(){
	this.f__scale=this.f__device.m_Copy().m_Div(this.f__size);
}
bb_director_Director.prototype.m_size2=function(t_newSize){
	this.f__size=t_newSize;
	this.f__center=this.f__size.m_Copy().m_Div2(2.0);
	this.m_RecalculateScale();
}
function bb_director_Director_new(t_width,t_height){
	bb_app_App_new.call(this);
	this.m_size2(bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,(t_width),(t_height)));
	return this;
}
function bb_director_Director_new2(){
	bb_app_App_new.call(this);
	return this;
}
bb_director_Director.prototype.m_inputController=function(){
	return this.f__inputController;
}
bb_director_Director.prototype.m_DispatchOnCreate=function(){
	if(this.f_onCreateDispatched){
		return;
	}
	if(!((this.f__handler)!=null)){
		return;
	}
	if(!this.f_appOnCreateCatched){
		return;
	}
	this.f__handler.m_OnCreate(this);
	this.f_onCreateDispatched=true;
}
bb_director_Director.prototype.m_Run=function(t__handler){
	this.f__handler=t__handler;
	this.m_DispatchOnCreate();
}
bb_director_Director.prototype.m_handler=function(){
	return this.f__handler;
}
bb_director_Director.prototype.m_center=function(){
	return this.f__center;
}
bb_director_Director.prototype.m_scale=function(){
	return this.f__scale;
}
bb_director_Director.prototype.m_OnCreate2=function(){
	this.f__device=bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,(bb_graphics_DeviceWidth()),(bb_graphics_DeviceHeight()));
	if(!((this.m_size())!=null)){
		this.m_size2(this.f__device.m_Copy());
	}
	this.m_RecalculateScale();
	this.m_inputController().f_scale=this.m_scale();
	bb_random_Seed=util.GetTimestamp();
	this.f_deltaTimer=bb_deltatimer_DeltaTimer_new.call(new bb_deltatimer_DeltaTimer,30.0);
	bb_app_SetUpdateRate(60);
	this.f_appOnCreateCatched=true;
	this.m_DispatchOnCreate();
	return 0;
}
bb_director_Director.prototype.m_OnLoading=function(){
	if((this.f__handler)!=null){
		this.f__handler.m_OnLoading();
	}
	return 0;
}
bb_director_Director.prototype.m_OnUpdate2=function(){
	this.f_deltaTimer.m_OnUpdate2();
	if((this.f__handler)!=null){
		this.f__handler.m_OnUpdate(this.f_deltaTimer.m_delta(),this.f_deltaTimer.m_frameTime());
		this.m_inputController().m_OnUpdate3(this.f__handler);
	}
	return 0;
}
bb_director_Director.prototype.m_OnResume2=function(){
	if((this.f__handler)!=null){
		this.f__handler.m_OnResume(0);
	}
	return 0;
}
bb_director_Director.prototype.m_OnSuspend=function(){
	if((this.f__handler)!=null){
		this.f__handler.m_OnSuspend();
	}
	return 0;
}
bb_director_Director.prototype.m_OnRender=function(){
	bb_graphics_PushMatrix();
	bb_graphics_Scale(this.f__scale.f_x,this.f__scale.f_y);
	bb_graphics_SetScissor(0.0,0.0,this.f__device.f_x,this.f__device.f_y);
	bb_graphics_Cls(0.0,0.0,0.0);
	bb_graphics_PushMatrix();
	if((this.f__handler)!=null){
		this.f__handler.m_OnRender();
	}
	bb_graphics_PopMatrix();
	bb_graphics_PopMatrix();
	return 0;
}
function bb_list_List(){
	Object.call(this);
	this.f__head=(bb_list_HeadNode_new.call(new bb_list_HeadNode));
}
function bb_list_List_new(){
	return this;
}
bb_list_List.prototype.m_AddLast=function(t_data){
	return bb_list_Node_new.call(new bb_list_Node,this.f__head,this.f__head.f__pred,t_data);
}
function bb_list_List_new2(t_data){
	var t_=t_data;
	var t_2=0;
	while(t_2<t_.length){
		var t_t=t_[t_2];
		t_2=t_2+1;
		this.m_AddLast(t_t);
	}
	return this;
}
bb_list_List.prototype.m_Equals=function(t_lhs,t_rhs){
	return t_lhs==t_rhs;
}
bb_list_List.prototype.m_Contains=function(t_value){
	var t_node=this.f__head.f__succ;
	while(t_node!=this.f__head){
		if(this.m_Equals(t_node.f__data,t_value)){
			return true;
		}
		t_node=t_node.f__succ;
	}
	return false;
}
function bb_list_Node(){
	Object.call(this);
	this.f__succ=null;
	this.f__pred=null;
	this.f__data="";
}
function bb_list_Node_new(t_succ,t_pred,t_data){
	this.f__succ=t_succ;
	this.f__pred=t_pred;
	this.f__succ.f__pred=this;
	this.f__pred.f__succ=this;
	this.f__data=t_data;
	return this;
}
function bb_list_Node_new2(){
	return this;
}
function bb_list_HeadNode(){
	bb_list_Node.call(this);
}
bb_list_HeadNode.prototype=extend_class(bb_list_Node);
function bb_list_HeadNode_new(){
	bb_list_Node_new2.call(this);
	this.f__succ=(this);
	this.f__pred=(this);
	return this;
}
function bb_app_AppDevice(){
	gxtkApp.call(this);
	this.f_app=null;
	this.f_updateRate=0;
}
bb_app_AppDevice.prototype=extend_class(gxtkApp);
function bb_app_AppDevice_new(t_app){
	this.f_app=t_app;
	bb_graphics_SetGraphicsContext(bb_graphics_GraphicsContext_new.call(new bb_graphics_GraphicsContext,this.GraphicsDevice()));
	bb_input_SetInputDevice(this.InputDevice());
	bb_audio_SetAudioDevice(this.AudioDevice());
	return this;
}
function bb_app_AppDevice_new2(){
	return this;
}
bb_app_AppDevice.prototype.OnCreate=function(){
	bb_graphics_SetFont(null,32);
	return this.f_app.m_OnCreate2();
}
bb_app_AppDevice.prototype.OnUpdate=function(){
	return this.f_app.m_OnUpdate2();
}
bb_app_AppDevice.prototype.OnSuspend=function(){
	return this.f_app.m_OnSuspend();
}
bb_app_AppDevice.prototype.OnResume=function(){
	return this.f_app.m_OnResume2();
}
bb_app_AppDevice.prototype.OnRender=function(){
	bb_graphics_BeginRender();
	var t_r=this.f_app.m_OnRender();
	bb_graphics_EndRender();
	return t_r;
}
bb_app_AppDevice.prototype.OnLoading=function(){
	bb_graphics_BeginRender();
	var t_r=this.f_app.m_OnLoading();
	bb_graphics_EndRender();
	return t_r;
}
bb_app_AppDevice.prototype.SetUpdateRate=function(t_hertz){
	gxtkApp.prototype.SetUpdateRate.call(this,t_hertz);
	this.f_updateRate=t_hertz;
	return 0;
}
function bb_graphics_GraphicsContext(){
	Object.call(this);
	this.f_device=null;
	this.f_defaultFont=null;
	this.f_font=null;
	this.f_firstChar=0;
	this.f_matrixSp=0;
	this.f_ix=1.0;
	this.f_iy=.0;
	this.f_jx=.0;
	this.f_jy=1.0;
	this.f_tx=.0;
	this.f_ty=.0;
	this.f_tformed=0;
	this.f_matDirty=0;
	this.f_color_r=.0;
	this.f_color_g=.0;
	this.f_color_b=.0;
	this.f_alpha=.0;
	this.f_blend=0;
	this.f_scissor_x=.0;
	this.f_scissor_y=.0;
	this.f_scissor_width=.0;
	this.f_scissor_height=.0;
	this.f_matrixStack=new_number_array(192);
}
function bb_graphics_GraphicsContext_new(t_device){
	this.f_device=t_device;
	return this;
}
function bb_graphics_GraphicsContext_new2(){
	return this;
}
var bb_graphics_context;
function bb_graphics_SetGraphicsContext(t_gc){
	bb_graphics_context=t_gc;
	return 0;
}
var bb_input_device;
function bb_input_SetInputDevice(t_dev){
	bb_input_device=t_dev;
	return 0;
}
var bb_audio_device;
function bb_audio_SetAudioDevice(t_dev){
	bb_audio_device=t_dev;
	return 0;
}
var bb_app_device;
function bb_vector2d_Vector2D(){
	Object.call(this);
	this.f_x=.0;
	this.f_y=.0;
}
function bb_vector2d_Vector2D_new(t_x,t_y){
	this.f_x=t_x;
	this.f_y=t_y;
	return this;
}
bb_vector2d_Vector2D.prototype.m_Copy=function(){
	return bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,this.f_x,this.f_y);
}
bb_vector2d_Vector2D.prototype.m_Div=function(t_v2){
	this.f_x/=t_v2.f_x;
	this.f_y/=t_v2.f_y;
	return this;
}
bb_vector2d_Vector2D.prototype.m_Div2=function(t_factor){
	this.f_y/=t_factor;
	this.f_x/=t_factor;
	return this;
}
bb_vector2d_Vector2D.prototype.m_Sub=function(t_v2){
	this.f_x-=t_v2.f_x;
	this.f_y-=t_v2.f_y;
	return this;
}
bb_vector2d_Vector2D.prototype.m_Sub2=function(t_factor){
	this.f_x-=t_factor;
	this.f_y-=t_factor;
	return this;
}
bb_vector2d_Vector2D.prototype.m_Add2=function(t_v2){
	this.f_x+=t_v2.f_x;
	this.f_y+=t_v2.f_y;
	return this;
}
bb_vector2d_Vector2D.prototype.m_Add3=function(t_factor){
	this.f_x+=t_factor;
	this.f_y+=t_factor;
	return this;
}
bb_vector2d_Vector2D.prototype.m_Length=function(){
	return Math.sqrt(this.f_x*this.f_x+this.f_y*this.f_y);
}
bb_vector2d_Vector2D.prototype.m_Normalize=function(){
	var t_length=this.m_Length();
	if(t_length==0.0){
		return this;
	}
	this.f_x/=t_length;
	this.f_y/=t_length;
	return this;
}
bb_vector2d_Vector2D.prototype.m_Mul=function(t_v2){
	this.f_x*=t_v2.f_x;
	this.f_y*=t_v2.f_y;
	return this;
}
bb_vector2d_Vector2D.prototype.m_Mul2=function(t_factor){
	this.f_x*=t_factor;
	this.f_y*=t_factor;
	return this;
}
function bb_inputcontroller_InputController(){
	Object.call(this);
	this.f_trackKeys=false;
	this.f_trackTouch=false;
	this.f__touchFingers=1;
	this.f_touchRetainSize=5;
	this.f_scale=bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,0.0,0.0);
	this.f_isTouchDown=new_bool_array(31);
	this.f_touchEvents=new_object_array(31);
	this.f_touchDownDispatched=new_bool_array(31);
	this.f_touchMinDistance=5.0;
	this.f_keyboardEnabled=false;
	this.f_keysActive=bb_set_IntSet_new.call(new bb_set_IntSet);
	this.f_keyEvents=bb_map_IntMap2_new.call(new bb_map_IntMap2);
	this.f_dispatchedKeyEvents=bb_set_IntSet_new.call(new bb_set_IntSet);
}
function bb_inputcontroller_InputController_new(){
	return this;
}
bb_inputcontroller_InputController.prototype.m_touchFingers=function(t_number){
	if(t_number>31){
		error("Only 31 can be tracked.");
	}
	if(((!((t_number)!=0))?1:0)>0){
		error("Number of fingers must be greater than 0.");
	}
	this.f__touchFingers=t_number;
}
bb_inputcontroller_InputController.prototype.m_ReadTouch=function(){
	var t_scaledVector=null;
	var t_diffVector=null;
	var t_lastTouchDown=false;
	for(var t_i=0;t_i<this.f__touchFingers;t_i=t_i+1){
		t_lastTouchDown=this.f_isTouchDown[t_i];
		this.f_isTouchDown[t_i]=((bb_input_TouchDown(t_i))!=0);
		if(!this.f_isTouchDown[t_i] && !t_lastTouchDown){
			continue;
		}
		if(this.f_touchEvents[t_i]==null){
			this.f_touchDownDispatched[t_i]=false;
			this.f_touchEvents[t_i]=bb_touchevent_TouchEvent_new.call(new bb_touchevent_TouchEvent,t_i);
		}
		t_scaledVector=(bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,bb_input_TouchX(t_i),bb_input_TouchY(t_i))).m_Div(this.f_scale);
		t_diffVector=t_scaledVector.m_Copy().m_Sub(this.f_touchEvents[t_i].m_prevPos());
		if(t_diffVector.m_Length()>=this.f_touchMinDistance){
			this.f_touchEvents[t_i].m_Add2(t_scaledVector);
			if(this.f_touchRetainSize>-1){
				this.f_touchEvents[t_i].m_Trim(this.f_touchRetainSize);
			}
		}
	}
}
bb_inputcontroller_InputController.prototype.m_ProcessTouch=function(t_handler){
	for(var t_i=0;t_i<this.f__touchFingers;t_i=t_i+1){
		if(this.f_touchEvents[t_i]==null){
			continue;
		}
		if(!this.f_touchDownDispatched[t_i]){
			t_handler.m_OnTouchDown(this.f_touchEvents[t_i].m_Copy());
			this.f_touchDownDispatched[t_i]=true;
		}else{
			if(!this.f_isTouchDown[t_i]){
				t_handler.m_OnTouchUp(this.f_touchEvents[t_i]);
				this.f_touchEvents[t_i]=null;
			}else{
				t_handler.m_OnTouchMove(this.f_touchEvents[t_i]);
			}
		}
	}
}
bb_inputcontroller_InputController.prototype.m_ReadKeys=function(){
	this.f_keysActive.m_Clear();
	var t_charCode=0;
	do{
		t_charCode=bb_input_GetChar();
		if(!((t_charCode)!=0)){
			return;
		}
		this.f_keysActive.m_Insert4(t_charCode);
		if(!this.f_keyEvents.m_Contains2(t_charCode)){
			this.f_keyEvents.m_Add6(t_charCode,bb_keyevent_KeyEvent_new.call(new bb_keyevent_KeyEvent,t_charCode));
			this.f_dispatchedKeyEvents.m_Remove4(t_charCode);
		}
	}while(!(false));
}
bb_inputcontroller_InputController.prototype.m_ProcessKeys=function(t_handler){
	var t_=this.f_keyEvents.m_Values().m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_event=t_.m_NextObject();
		if(!this.f_dispatchedKeyEvents.m_Contains2(t_event.m_code())){
			t_handler.m_OnKeyDown(t_event);
			this.f_dispatchedKeyEvents.m_Insert4(t_event.m_code());
			continue;
		}
		if(!this.f_keysActive.m_Contains2(t_event.m_code())){
			t_handler.m_OnKeyUp(t_event);
			this.f_dispatchedKeyEvents.m_Remove4(t_event.m_code());
			this.f_keyEvents.m_Remove4(t_event.m_code());
		}else{
			t_handler.m_OnKeyPress(t_event);
		}
	}
}
bb_inputcontroller_InputController.prototype.m_OnUpdate3=function(t_handler){
	if(this.f_trackTouch){
		this.m_ReadTouch();
		this.m_ProcessTouch(t_handler);
	}
	if(this.f_trackKeys){
		if(!this.f_keyboardEnabled){
			this.f_keyboardEnabled=true;
			bb_input_EnableKeyboard();
		}
		this.m_ReadKeys();
		this.m_ProcessKeys(t_handler);
	}else{
		if(this.f_keyboardEnabled){
			this.f_keyboardEnabled=false;
			bb_input_DisableKeyboard();
			this.f_keysActive.m_Clear();
			this.f_keyEvents.m_Clear();
			this.f_dispatchedKeyEvents.m_Clear();
		}
	}
}
function bbMain(){
	var t_router=bb_router_Router_new.call(new bb_router_Router);
	t_router.m_Add("intro",(bb_introscene_IntroScene_new.call(new bb_introscene_IntroScene)));
	t_router.m_Add("menu",(bb_menuscene_MenuScene_new.call(new bb_menuscene_MenuScene)));
	t_router.m_Add("highscore",(bb_highscorescene_HighscoreScene_new.call(new bb_highscorescene_HighscoreScene)));
	t_router.m_Add("game",(bb_gamescene_GameScene_new.call(new bb_gamescene_GameScene)));
	t_router.m_Add("gameover",(bb_gameoverscene_GameOverScene_new.call(new bb_gameoverscene_GameOverScene)));
	t_router.m_Add("pause",(bb_pausescene_PauseScene_new.call(new bb_pausescene_PauseScene)));
	t_router.m_Add("newhighscore",(bb_newhighscorescene_NewHighscoreScene_new.call(new bb_newhighscorescene_NewHighscoreScene)));
	t_router.m_Goto("intro");
	var t_director=bb_director_Director_new.call(new bb_director_Director,640,960);
	t_director.m_inputController().f_trackKeys=true;
	t_director.m_inputController().f_trackTouch=true;
	t_director.m_inputController().m_touchFingers(1);
	t_director.m_inputController().f_touchRetainSize=25;
	t_director.m_Run(t_router);
	return 0;
}
function bb_fanout_FanOut(){
	Object.call(this);
	this.f_objects=bb_list_List2_new.call(new bb_list_List2);
	this.implments={bb_directorevents_DirectorEvents:1};
}
function bb_fanout_FanOut_new(){
	return this;
}
bb_fanout_FanOut.prototype.m_OnCreate=function(t_director){
	if(!((this.f_objects)!=null)){
		return;
	}
	var t_=this.f_objects.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_obj=t_.m_NextObject();
		t_obj.m_OnCreate(t_director);
	}
}
bb_fanout_FanOut.prototype.m_Add4=function(t_obj){
	this.f_objects.m_AddLast2(t_obj);
}
bb_fanout_FanOut.prototype.m_Remove=function(t_obj){
	this.f_objects.m_RemoveEach(t_obj);
}
bb_fanout_FanOut.prototype.m_Clear=function(){
	this.f_objects.m_Clear();
}
bb_fanout_FanOut.prototype.m_OnLoading=function(){
	if(!((this.f_objects)!=null)){
		return;
	}
	var t_=this.f_objects.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_obj=t_.m_NextObject();
		t_obj.m_OnLoading();
	}
}
bb_fanout_FanOut.prototype.m_OnUpdate=function(t_delta,t_frameTime){
	if(!((this.f_objects)!=null)){
		return;
	}
	var t_=this.f_objects.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_obj=t_.m_NextObject();
		t_obj.m_OnUpdate(t_delta,t_frameTime);
	}
}
bb_fanout_FanOut.prototype.m_OnRender=function(){
	if(!((this.f_objects)!=null)){
		return;
	}
	var t_=this.f_objects.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_obj=t_.m_NextObject();
		t_obj.m_OnRender();
	}
}
bb_fanout_FanOut.prototype.m_OnSuspend=function(){
	if(!((this.f_objects)!=null)){
		return;
	}
	var t_=this.f_objects.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_obj=t_.m_NextObject();
		t_obj.m_OnSuspend();
	}
}
bb_fanout_FanOut.prototype.m_OnResume=function(t_delta){
	if(!((this.f_objects)!=null)){
		return;
	}
	var t_=this.f_objects.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_obj=t_.m_NextObject();
		t_obj.m_OnResume(t_delta);
	}
}
bb_fanout_FanOut.prototype.m_OnKeyDown=function(t_event){
	if(!((this.f_objects)!=null)){
		return;
	}
	var t_=this.f_objects.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_obj=t_.m_NextObject();
		t_obj.m_OnKeyDown(t_event);
	}
}
bb_fanout_FanOut.prototype.m_OnKeyPress=function(t_event){
	if(!((this.f_objects)!=null)){
		return;
	}
	var t_=this.f_objects.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_obj=t_.m_NextObject();
		t_obj.m_OnKeyPress(t_event);
	}
}
bb_fanout_FanOut.prototype.m_OnKeyUp=function(t_event){
	if(!((this.f_objects)!=null)){
		return;
	}
	var t_=this.f_objects.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_obj=t_.m_NextObject();
		t_obj.m_OnKeyUp(t_event);
	}
}
bb_fanout_FanOut.prototype.m_OnTouchDown=function(t_event){
	if(!((this.f_objects)!=null)){
		return;
	}
	var t_=this.f_objects.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_obj=t_.m_NextObject();
		t_obj.m_OnTouchDown(t_event);
	}
}
bb_fanout_FanOut.prototype.m_OnTouchMove=function(t_event){
	if(!((this.f_objects)!=null)){
		return;
	}
	var t_=this.f_objects.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_obj=t_.m_NextObject();
		t_obj.m_OnTouchMove(t_event);
	}
}
bb_fanout_FanOut.prototype.m_OnTouchUp=function(t_event){
	if(!((this.f_objects)!=null)){
		return;
	}
	var t_=this.f_objects.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_obj=t_.m_NextObject();
		t_obj.m_OnTouchUp(t_event);
	}
}
bb_fanout_FanOut.prototype.m_Count=function(){
	return this.f_objects.m_Count();
}
bb_fanout_FanOut.prototype.m_ObjectEnumerator=function(){
	return this.f_objects.m_ObjectEnumerator();
}
function bb_list_List2(){
	Object.call(this);
	this.f__head=(bb_list_HeadNode2_new.call(new bb_list_HeadNode2));
}
function bb_list_List2_new(){
	return this;
}
bb_list_List2.prototype.m_AddLast2=function(t_data){
	return bb_list_Node2_new.call(new bb_list_Node2,this.f__head,this.f__head.f__pred,t_data);
}
function bb_list_List2_new2(t_data){
	var t_=t_data;
	var t_2=0;
	while(t_2<t_.length){
		var t_t=t_[t_2];
		t_2=t_2+1;
		this.m_AddLast2(t_t);
	}
	return this;
}
bb_list_List2.prototype.m_ObjectEnumerator=function(){
	return bb_list_Enumerator_new.call(new bb_list_Enumerator,this);
}
bb_list_List2.prototype.m_Equals2=function(t_lhs,t_rhs){
	return t_lhs==t_rhs;
}
bb_list_List2.prototype.m_RemoveEach=function(t_value){
	var t_node=this.f__head.f__succ;
	while(t_node!=this.f__head){
		var t_succ=t_node.f__succ;
		if(this.m_Equals2(t_node.f__data,t_value)){
			t_node.m_Remove2();
		}
		t_node=t_succ;
	}
	return 0;
}
bb_list_List2.prototype.m_Clear=function(){
	this.f__head.f__succ=this.f__head;
	this.f__head.f__pred=this.f__head;
	return 0;
}
bb_list_List2.prototype.m_Count=function(){
	var t_n=0;
	var t_node=this.f__head.f__succ;
	while(t_node!=this.f__head){
		t_node=t_node.f__succ;
		t_n+=1;
	}
	return t_n;
}
function bb_list_Node2(){
	Object.call(this);
	this.f__succ=null;
	this.f__pred=null;
	this.f__data=null;
}
function bb_list_Node2_new(t_succ,t_pred,t_data){
	this.f__succ=t_succ;
	this.f__pred=t_pred;
	this.f__succ.f__pred=this;
	this.f__pred.f__succ=this;
	this.f__data=t_data;
	return this;
}
function bb_list_Node2_new2(){
	return this;
}
bb_list_Node2.prototype.m_Remove2=function(){
	this.f__succ.f__pred=this.f__pred;
	this.f__pred.f__succ=this.f__succ;
	return 0;
}
function bb_list_HeadNode2(){
	bb_list_Node2.call(this);
}
bb_list_HeadNode2.prototype=extend_class(bb_list_Node2);
function bb_list_HeadNode2_new(){
	bb_list_Node2_new2.call(this);
	this.f__succ=(this);
	this.f__pred=(this);
	return this;
}
function bb_list_Enumerator(){
	Object.call(this);
	this.f__list=null;
	this.f__curr=null;
}
function bb_list_Enumerator_new(t_list){
	this.f__list=t_list;
	this.f__curr=t_list.f__head.f__succ;
	return this;
}
function bb_list_Enumerator_new2(){
	return this;
}
bb_list_Enumerator.prototype.m_HasNext=function(){
	while(this.f__curr.f__succ.f__pred!=this.f__curr){
		this.f__curr=this.f__curr.f__succ;
	}
	return this.f__curr!=this.f__list.f__head;
}
bb_list_Enumerator.prototype.m_NextObject=function(){
	var t_data=this.f__curr.f__data;
	this.f__curr=this.f__curr.f__succ;
	return t_data;
}
function bb_baseobject_BaseObject(){
	bb_partial_Partial.call(this);
	this.f__pos=null;
	this.f__size=null;
	this.f__center=null;
	this.implments={bb_positionable_Positionable:1,bb_sizeable_Sizeable:1,bb_directorevents_DirectorEvents:1};
}
bb_baseobject_BaseObject.prototype=extend_class(bb_partial_Partial);
function bb_baseobject_BaseObject_new(){
	bb_partial_Partial_new.call(this);
	return this;
}
bb_baseobject_BaseObject.prototype.m_pos=function(){
	if(this.f__pos==null){
		error("Position not set yet.");
	}
	return this.f__pos;
}
bb_baseobject_BaseObject.prototype.m_pos2=function(t_newPos){
	this.f__pos=t_newPos;
}
bb_baseobject_BaseObject.prototype.m_size=function(){
	if(this.f__size==null){
		error("Size not set yet.");
	}
	return this.f__size;
}
bb_baseobject_BaseObject.prototype.m_size2=function(t_newSize){
	this.f__size=t_newSize;
	this.f__center=t_newSize.m_Copy().m_Div2(2.0);
}
bb_baseobject_BaseObject.prototype.m_center=function(){
	if(this.f__center==null){
		error("No size set and center therefore unset.");
	}
	return this.f__center;
}
bb_baseobject_BaseObject.prototype.m_Center=function(t_entity){
	this.m_pos2(t_entity.m_center().m_Copy().m_Sub(this.m_center()));
}
bb_baseobject_BaseObject.prototype.m_CenterX=function(t_entity){
	this.m_pos().f_x=t_entity.m_center().f_x-this.m_center().f_x;
}
function bb_sprite_Sprite(){
	bb_baseobject_BaseObject.call(this);
	this.f_image=null;
	this.f_frameCount=0;
	this.f_frameSpeed=0;
	this.f_rotation=.0;
	this.f_scale=bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,1.0,1.0);
	this.f_currentFrame=0;
	this.f_loopAnimation=false;
	this.f_frameTimer=0;
	this.implments={bb_positionable_Positionable:1,bb_sizeable_Sizeable:1,bb_directorevents_DirectorEvents:1};
}
bb_sprite_Sprite.prototype=extend_class(bb_baseobject_BaseObject);
bb_sprite_Sprite.prototype.m_InitVectors=function(t_width,t_height,t_pos){
	if(t_pos==null){
		this.m_pos2(bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,0.0,0.0));
	}else{
		this.m_pos2(t_pos);
	}
	this.m_size2(bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,(t_width),(t_height)));
}
function bb_sprite_Sprite_new(t_imageName,t_pos){
	bb_baseobject_BaseObject_new.call(this);
	this.f_image=bb_graphics_LoadImage(t_imageName,1,bb_graphics_Image_DefaultFlags);
	this.m_InitVectors(this.f_image.m_Width(),this.f_image.m_Height(),t_pos);
	return this;
}
function bb_sprite_Sprite_new2(t_imageName,t_frameWidth,t_frameHeight,t_frameCount,t_frameSpeed,t_pos){
	bb_baseobject_BaseObject_new.call(this);
	this.f_frameCount=t_frameCount-1;
	this.f_frameSpeed=t_frameSpeed;
	this.f_image=bb_graphics_LoadImage2(t_imageName,t_frameWidth,t_frameHeight,t_frameCount,bb_graphics_Image_DefaultFlags);
	this.m_InitVectors(t_frameWidth,t_frameHeight,t_pos);
	return this;
}
function bb_sprite_Sprite_new3(){
	bb_baseobject_BaseObject_new.call(this);
	return this;
}
bb_sprite_Sprite.prototype.m_OnRender=function(){
	bb_partial_Partial.prototype.m_OnRender.call(this);
	bb_graphics_DrawImage2(this.f_image,this.m_pos().f_x,this.m_pos().f_y,this.f_rotation,this.f_scale.f_x,this.f_scale.f_y,this.f_currentFrame);
}
bb_sprite_Sprite.prototype.m_animationIsDone=function(){
	if(this.f_loopAnimation){
		return false;
	}
	return this.f_currentFrame==this.f_frameCount;
}
bb_sprite_Sprite.prototype.m_OnUpdate=function(t_delta,t_frameTime){
	bb_partial_Partial.prototype.m_OnUpdate.call(this,t_delta,t_frameTime);
	if(this.f_frameCount<=0){
		return;
	}
	if(this.m_animationIsDone()){
		return;
	}
	if(this.f_frameTimer<this.f_frameSpeed){
		this.f_frameTimer=(((this.f_frameTimer)+t_frameTime)|0);
		return;
	}
	if(this.f_currentFrame==this.f_frameCount){
		if(this.f_loopAnimation){
			this.f_currentFrame=1;
		}
	}else{
		this.f_currentFrame+=1;
	}
	this.f_frameTimer=0;
}
bb_sprite_Sprite.prototype.m_Collide=function(t_checkPos){
	if(t_checkPos.f_x<this.m_pos().f_x || t_checkPos.f_x>this.m_pos().f_x+this.m_size().f_x){
		return false;
	}
	if(t_checkPos.f_y<this.m_pos().f_y || t_checkPos.f_y>this.m_pos().f_y+this.m_size().f_y){
		return false;
	}
	return true;
}
bb_sprite_Sprite.prototype.m_Restart=function(){
	this.f_currentFrame=0;
}
function bb_graphics_Image(){
	Object.call(this);
	this.f_surface=null;
	this.f_width=0;
	this.f_height=0;
	this.f_frames=[];
	this.f_flags=0;
	this.f_tx=.0;
	this.f_ty=.0;
	this.f_source=null;
}
var bb_graphics_Image_DefaultFlags;
function bb_graphics_Image_new(){
	return this;
}
bb_graphics_Image.prototype.m_SetHandle=function(t_tx,t_ty){
	this.f_tx=t_tx;
	this.f_ty=t_ty;
	this.f_flags=this.f_flags&-2;
	return 0;
}
bb_graphics_Image.prototype.m_ApplyFlags=function(t_iflags){
	this.f_flags=t_iflags;
	if((this.f_flags&2)!=0){
		var t_=this.f_frames;
		var t_2=0;
		while(t_2<t_.length){
			var t_f=t_[t_2];
			t_2=t_2+1;
			t_f.f_x+=1;
		}
		this.f_width-=2;
	}
	if((this.f_flags&4)!=0){
		var t_3=this.f_frames;
		var t_4=0;
		while(t_4<t_3.length){
			var t_f2=t_3[t_4];
			t_4=t_4+1;
			t_f2.f_y+=1;
		}
		this.f_height-=2;
	}
	if((this.f_flags&1)!=0){
		this.m_SetHandle((this.f_width)/2.0,(this.f_height)/2.0);
	}
	if(this.f_frames.length==1 && this.f_frames[0].f_x==0 && this.f_frames[0].f_y==0 && this.f_width==this.f_surface.Width() && this.f_height==this.f_surface.Height()){
		this.f_flags|=65536;
	}
	return 0;
}
bb_graphics_Image.prototype.m_Load=function(t_path,t_nframes,t_iflags){
	this.f_surface=bb_graphics_context.f_device.LoadSurface(t_path);
	if(!((this.f_surface)!=null)){
		return null;
	}
	this.f_width=((this.f_surface.Width()/t_nframes)|0);
	this.f_height=this.f_surface.Height();
	this.f_frames=new_object_array(t_nframes);
	for(var t_i=0;t_i<t_nframes;t_i=t_i+1){
		this.f_frames[t_i]=bb_graphics_Frame_new.call(new bb_graphics_Frame,t_i*this.f_width,0);
	}
	this.m_ApplyFlags(t_iflags);
	return this;
}
bb_graphics_Image.prototype.m_Grab=function(t_x,t_y,t_iwidth,t_iheight,t_nframes,t_iflags,t_source){
	this.f_source=t_source;
	this.f_surface=t_source.f_surface;
	this.f_width=t_iwidth;
	this.f_height=t_iheight;
	this.f_frames=new_object_array(t_nframes);
	var t_ix=t_x;
	var t_iy=t_y;
	for(var t_i=0;t_i<t_nframes;t_i=t_i+1){
		if(t_ix+this.f_width>t_source.f_width){
			t_ix=0;
			t_iy+=this.f_height;
		}
		if(t_ix+this.f_width>t_source.f_width || t_iy+this.f_height>t_source.f_height){
			error("Image frame outside surface");
		}
		this.f_frames[t_i]=bb_graphics_Frame_new.call(new bb_graphics_Frame,t_ix+t_source.f_frames[0].f_x,t_iy+t_source.f_frames[0].f_y);
		t_ix+=this.f_width;
	}
	this.m_ApplyFlags(t_iflags);
	return this;
}
bb_graphics_Image.prototype.m_GrabImage=function(t_x,t_y,t_width,t_height,t_frames,t_flags){
	if(this.f_frames.length!=1){
		return null;
	}
	return (bb_graphics_Image_new.call(new bb_graphics_Image)).m_Grab(t_x,t_y,t_width,t_height,t_frames,t_flags,this);
}
bb_graphics_Image.prototype.m_Width=function(){
	return this.f_width;
}
bb_graphics_Image.prototype.m_Height=function(){
	return this.f_height;
}
function bb_graphics_Frame(){
	Object.call(this);
	this.f_x=0;
	this.f_y=0;
}
function bb_graphics_Frame_new(t_x,t_y){
	this.f_x=t_x;
	this.f_y=t_y;
	return this;
}
function bb_graphics_Frame_new2(){
	return this;
}
function bb_graphics_LoadImage(t_path,t_frameCount,t_flags){
	return (bb_graphics_Image_new.call(new bb_graphics_Image)).m_Load(t_path,t_frameCount,t_flags);
}
function bb_graphics_LoadImage2(t_path,t_frameWidth,t_frameHeight,t_frameCount,t_flags){
	var t_atlas=(bb_graphics_Image_new.call(new bb_graphics_Image)).m_Load(t_path,1,0);
	if((t_atlas)!=null){
		return t_atlas.m_GrabImage(0,0,t_frameWidth,t_frameHeight,t_frameCount,t_flags);
	}
	return null;
}
function bb_angelfont2_AngelFont(){
	Object.call(this);
	this.f_iniText="";
	this.f_kernPairs=bb_map_StringMap3_new.call(new bb_map_StringMap3);
	this.f_chars=new_object_array(256);
	this.f_height=0;
	this.f_heightOffset=9999;
	this.f_image=null;
	this.f_name="";
	this.f_xOffset=0;
	this.f_useKerning=true;
}
var bb_angelfont2_AngelFont_error;
var bb_angelfont2_AngelFont_current;
bb_angelfont2_AngelFont.prototype.m_LoadFont=function(t_url){
	bb_angelfont2_AngelFont_error="";
	bb_angelfont2_AngelFont_current=this;
	this.f_iniText=bb_app_LoadString(t_url+".txt");
	var t_lines=this.f_iniText.split(String.fromCharCode(10));
	var t_=t_lines;
	var t_2=0;
	while(t_2<t_.length){
		var t_line=t_[t_2];
		t_2=t_2+1;
		t_line=string_trim(t_line);
		if(string_starts_with(t_line,"id,") || t_line==""){
			continue;
		}
		if(string_starts_with(t_line,"first,")){
			continue;
		}
		var t_data=t_line.split(",");
		for(var t_i=0;t_i<t_data.length;t_i=t_i+1){
			t_data[t_i]=string_trim(t_data[t_i]);
		}
		bb_angelfont2_AngelFont_error=bb_angelfont2_AngelFont_error+(String(t_data.length)+",");
		if(t_data.length>0){
			if(t_data.length==3){
				this.f_kernPairs.m_Insert(String.fromCharCode(parseInt((t_data[0]),10))+"_"+String.fromCharCode(parseInt((t_data[1]),10)),bb_kernpair_KernPair_new.call(new bb_kernpair_KernPair,parseInt((t_data[0]),10),parseInt((t_data[1]),10),parseInt((t_data[2]),10)));
			}else{
				if(t_data.length>=8){
					this.f_chars[parseInt((t_data[0]),10)]=bb_char_Char_new.call(new bb_char_Char,parseInt((t_data[1]),10),parseInt((t_data[2]),10),parseInt((t_data[3]),10),parseInt((t_data[4]),10),parseInt((t_data[5]),10),parseInt((t_data[6]),10),parseInt((t_data[7]),10));
					var t_ch=this.f_chars[parseInt((t_data[0]),10)];
					if(t_ch.f_height>this.f_height){
						this.f_height=t_ch.f_height;
					}
					if(t_ch.f_yOffset<this.f_heightOffset){
						this.f_heightOffset=t_ch.f_yOffset;
					}
				}
			}
		}
	}
	this.f_image=bb_graphics_LoadImage(t_url+".png",1,bb_graphics_Image_DefaultFlags);
}
var bb_angelfont2_AngelFont__list;
function bb_angelfont2_AngelFont_new(t_url){
	if(t_url!=""){
		this.m_LoadFont(t_url);
		this.f_name=t_url;
		bb_angelfont2_AngelFont__list.m_Insert2(t_url,this);
	}
	return this;
}
bb_angelfont2_AngelFont.prototype.m_DrawText=function(t_txt,t_x,t_y){
	var t_prevChar="";
	this.f_xOffset=0;
	for(var t_i=0;t_i<t_txt.length;t_i=t_i+1){
		var t_asc=t_txt.charCodeAt(t_i);
		var t_ac=this.f_chars[t_asc];
		var t_thisChar=String.fromCharCode(t_asc);
		if(t_ac!=null){
			if(this.f_useKerning){
				var t_key=t_prevChar+"_"+t_thisChar;
				if(this.f_kernPairs.m_Contains(t_key)){
					this.f_xOffset+=this.f_kernPairs.m_Get(t_key).f_amount;
				}
			}
			t_ac.m_Draw(this.f_image,t_x+this.f_xOffset,t_y);
			this.f_xOffset+=t_ac.f_xAdvance;
			t_prevChar=t_thisChar;
		}
	}
}
bb_angelfont2_AngelFont.prototype.m_TextWidth=function(t_txt){
	var t_prevChar="";
	var t_width=0;
	for(var t_i=0;t_i<t_txt.length;t_i=t_i+1){
		var t_asc=t_txt.charCodeAt(t_i);
		var t_ac=this.f_chars[t_asc];
		var t_thisChar=String.fromCharCode(t_asc);
		if(t_ac!=null){
			if(this.f_useKerning){
				var t_key=t_prevChar+"_"+t_thisChar;
				if(this.f_kernPairs.m_Contains(t_key)){
					t_width+=this.f_kernPairs.m_Get(t_key).f_amount;
				}
			}
			t_width+=t_ac.f_xAdvance;
			t_prevChar=t_thisChar;
		}
	}
	return t_width;
}
bb_angelfont2_AngelFont.prototype.m_DrawText2=function(t_txt,t_x,t_y,t_align){
	this.f_xOffset=0;
	var t_1=t_align;
	if(t_1==1){
		this.m_DrawText(t_txt,t_x-((this.m_TextWidth(t_txt)/2)|0),t_y);
	}else{
		if(t_1==2){
			this.m_DrawText(t_txt,t_x-this.m_TextWidth(t_txt),t_y);
		}else{
			if(t_1==0){
				this.m_DrawText(t_txt,t_x,t_y);
			}
		}
	}
}
function bb_app_LoadString(t_path){
	return bb_app_device.LoadString(t_path);
}
function bb_kernpair_KernPair(){
	Object.call(this);
	this.f_first="";
	this.f_second="";
	this.f_amount=0;
}
function bb_kernpair_KernPair_new(t_first,t_second,t_amount){
	this.f_first=String(t_first);
	this.f_second=String(t_second);
	this.f_amount=t_amount;
	return this;
}
function bb_kernpair_KernPair_new2(){
	return this;
}
function bb_map_Map3(){
	Object.call(this);
	this.f_root=null;
}
function bb_map_Map3_new(){
	return this;
}
bb_map_Map3.prototype.m_Compare=function(t_lhs,t_rhs){
}
bb_map_Map3.prototype.m_RotateLeft3=function(t_node){
	var t_child=t_node.f_right;
	t_node.f_right=t_child.f_left;
	if((t_child.f_left)!=null){
		t_child.f_left.f_parent=t_node;
	}
	t_child.f_parent=t_node.f_parent;
	if((t_node.f_parent)!=null){
		if(t_node==t_node.f_parent.f_left){
			t_node.f_parent.f_left=t_child;
		}else{
			t_node.f_parent.f_right=t_child;
		}
	}else{
		this.f_root=t_child;
	}
	t_child.f_left=t_node;
	t_node.f_parent=t_child;
	return 0;
}
bb_map_Map3.prototype.m_RotateRight3=function(t_node){
	var t_child=t_node.f_left;
	t_node.f_left=t_child.f_right;
	if((t_child.f_right)!=null){
		t_child.f_right.f_parent=t_node;
	}
	t_child.f_parent=t_node.f_parent;
	if((t_node.f_parent)!=null){
		if(t_node==t_node.f_parent.f_right){
			t_node.f_parent.f_right=t_child;
		}else{
			t_node.f_parent.f_left=t_child;
		}
	}else{
		this.f_root=t_child;
	}
	t_child.f_right=t_node;
	t_node.f_parent=t_child;
	return 0;
}
bb_map_Map3.prototype.m_InsertFixup3=function(t_node){
	while(((t_node.f_parent)!=null) && t_node.f_parent.f_color==-1 && ((t_node.f_parent.f_parent)!=null)){
		if(t_node.f_parent==t_node.f_parent.f_parent.f_left){
			var t_uncle=t_node.f_parent.f_parent.f_right;
			if(((t_uncle)!=null) && t_uncle.f_color==-1){
				t_node.f_parent.f_color=1;
				t_uncle.f_color=1;
				t_uncle.f_parent.f_color=-1;
				t_node=t_uncle.f_parent;
			}else{
				if(t_node==t_node.f_parent.f_right){
					t_node=t_node.f_parent;
					this.m_RotateLeft3(t_node);
				}
				t_node.f_parent.f_color=1;
				t_node.f_parent.f_parent.f_color=-1;
				this.m_RotateRight3(t_node.f_parent.f_parent);
			}
		}else{
			var t_uncle2=t_node.f_parent.f_parent.f_left;
			if(((t_uncle2)!=null) && t_uncle2.f_color==-1){
				t_node.f_parent.f_color=1;
				t_uncle2.f_color=1;
				t_uncle2.f_parent.f_color=-1;
				t_node=t_uncle2.f_parent;
			}else{
				if(t_node==t_node.f_parent.f_left){
					t_node=t_node.f_parent;
					this.m_RotateRight3(t_node);
				}
				t_node.f_parent.f_color=1;
				t_node.f_parent.f_parent.f_color=-1;
				this.m_RotateLeft3(t_node.f_parent.f_parent);
			}
		}
	}
	this.f_root.f_color=1;
	return 0;
}
bb_map_Map3.prototype.m_Set3=function(t_key,t_value){
	var t_node=this.f_root;
	var t_parent=null;
	var t_cmp=0;
	while((t_node)!=null){
		t_parent=t_node;
		t_cmp=this.m_Compare(t_key,t_node.f_key);
		if(t_cmp>0){
			t_node=t_node.f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node.f_left;
			}else{
				t_node.f_value=t_value;
				return false;
			}
		}
	}
	t_node=bb_map_Node3_new.call(new bb_map_Node3,t_key,t_value,-1,t_parent);
	if((t_parent)!=null){
		if(t_cmp>0){
			t_parent.f_right=t_node;
		}else{
			t_parent.f_left=t_node;
		}
		this.m_InsertFixup3(t_node);
	}else{
		this.f_root=t_node;
	}
	return true;
}
bb_map_Map3.prototype.m_Insert=function(t_key,t_value){
	return this.m_Set3(t_key,t_value);
}
bb_map_Map3.prototype.m_FindNode=function(t_key){
	var t_node=this.f_root;
	while((t_node)!=null){
		var t_cmp=this.m_Compare(t_key,t_node.f_key);
		if(t_cmp>0){
			t_node=t_node.f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node.f_left;
			}else{
				return t_node;
			}
		}
	}
	return t_node;
}
bb_map_Map3.prototype.m_Contains=function(t_key){
	return this.m_FindNode(t_key)!=null;
}
bb_map_Map3.prototype.m_Get=function(t_key){
	var t_node=this.m_FindNode(t_key);
	if((t_node)!=null){
		return t_node.f_value;
	}
	return null;
}
function bb_map_StringMap3(){
	bb_map_Map3.call(this);
}
bb_map_StringMap3.prototype=extend_class(bb_map_Map3);
function bb_map_StringMap3_new(){
	bb_map_Map3_new.call(this);
	return this;
}
bb_map_StringMap3.prototype.m_Compare=function(t_lhs,t_rhs){
	return string_compare(t_lhs,t_rhs);
}
function bb_map_Node3(){
	Object.call(this);
	this.f_key="";
	this.f_right=null;
	this.f_left=null;
	this.f_value=null;
	this.f_color=0;
	this.f_parent=null;
}
function bb_map_Node3_new(t_key,t_value,t_color,t_parent){
	this.f_key=t_key;
	this.f_value=t_value;
	this.f_color=t_color;
	this.f_parent=t_parent;
	return this;
}
function bb_map_Node3_new2(){
	return this;
}
function bb_char_Char(){
	Object.call(this);
	this.f_x=0;
	this.f_y=0;
	this.f_width=0;
	this.f_height=0;
	this.f_xOffset=0;
	this.f_yOffset=0;
	this.f_xAdvance=0;
}
function bb_char_Char_new(t_x,t_y,t_w,t_h,t_xoff,t_yoff,t_xadv){
	this.f_x=t_x;
	this.f_y=t_y;
	this.f_width=t_w;
	this.f_height=t_h;
	this.f_xOffset=t_xoff;
	this.f_yOffset=t_yoff;
	this.f_xAdvance=t_xadv;
	return this;
}
function bb_char_Char_new2(){
	return this;
}
bb_char_Char.prototype.m_Draw=function(t_fontImage,t_linex,t_liney){
	bb_graphics_DrawImageRect(t_fontImage,(t_linex+this.f_xOffset),(t_liney+this.f_yOffset),this.f_x,this.f_y,this.f_width,this.f_height,0);
	return 0;
}
function bb_map_Map4(){
	Object.call(this);
	this.f_root=null;
}
function bb_map_Map4_new(){
	return this;
}
bb_map_Map4.prototype.m_Compare=function(t_lhs,t_rhs){
}
bb_map_Map4.prototype.m_RotateLeft4=function(t_node){
	var t_child=t_node.f_right;
	t_node.f_right=t_child.f_left;
	if((t_child.f_left)!=null){
		t_child.f_left.f_parent=t_node;
	}
	t_child.f_parent=t_node.f_parent;
	if((t_node.f_parent)!=null){
		if(t_node==t_node.f_parent.f_left){
			t_node.f_parent.f_left=t_child;
		}else{
			t_node.f_parent.f_right=t_child;
		}
	}else{
		this.f_root=t_child;
	}
	t_child.f_left=t_node;
	t_node.f_parent=t_child;
	return 0;
}
bb_map_Map4.prototype.m_RotateRight4=function(t_node){
	var t_child=t_node.f_left;
	t_node.f_left=t_child.f_right;
	if((t_child.f_right)!=null){
		t_child.f_right.f_parent=t_node;
	}
	t_child.f_parent=t_node.f_parent;
	if((t_node.f_parent)!=null){
		if(t_node==t_node.f_parent.f_right){
			t_node.f_parent.f_right=t_child;
		}else{
			t_node.f_parent.f_left=t_child;
		}
	}else{
		this.f_root=t_child;
	}
	t_child.f_right=t_node;
	t_node.f_parent=t_child;
	return 0;
}
bb_map_Map4.prototype.m_InsertFixup4=function(t_node){
	while(((t_node.f_parent)!=null) && t_node.f_parent.f_color==-1 && ((t_node.f_parent.f_parent)!=null)){
		if(t_node.f_parent==t_node.f_parent.f_parent.f_left){
			var t_uncle=t_node.f_parent.f_parent.f_right;
			if(((t_uncle)!=null) && t_uncle.f_color==-1){
				t_node.f_parent.f_color=1;
				t_uncle.f_color=1;
				t_uncle.f_parent.f_color=-1;
				t_node=t_uncle.f_parent;
			}else{
				if(t_node==t_node.f_parent.f_right){
					t_node=t_node.f_parent;
					this.m_RotateLeft4(t_node);
				}
				t_node.f_parent.f_color=1;
				t_node.f_parent.f_parent.f_color=-1;
				this.m_RotateRight4(t_node.f_parent.f_parent);
			}
		}else{
			var t_uncle2=t_node.f_parent.f_parent.f_left;
			if(((t_uncle2)!=null) && t_uncle2.f_color==-1){
				t_node.f_parent.f_color=1;
				t_uncle2.f_color=1;
				t_uncle2.f_parent.f_color=-1;
				t_node=t_uncle2.f_parent;
			}else{
				if(t_node==t_node.f_parent.f_left){
					t_node=t_node.f_parent;
					this.m_RotateRight4(t_node);
				}
				t_node.f_parent.f_color=1;
				t_node.f_parent.f_parent.f_color=-1;
				this.m_RotateLeft4(t_node.f_parent.f_parent);
			}
		}
	}
	this.f_root.f_color=1;
	return 0;
}
bb_map_Map4.prototype.m_Set4=function(t_key,t_value){
	var t_node=this.f_root;
	var t_parent=null;
	var t_cmp=0;
	while((t_node)!=null){
		t_parent=t_node;
		t_cmp=this.m_Compare(t_key,t_node.f_key);
		if(t_cmp>0){
			t_node=t_node.f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node.f_left;
			}else{
				t_node.f_value=t_value;
				return false;
			}
		}
	}
	t_node=bb_map_Node4_new.call(new bb_map_Node4,t_key,t_value,-1,t_parent);
	if((t_parent)!=null){
		if(t_cmp>0){
			t_parent.f_right=t_node;
		}else{
			t_parent.f_left=t_node;
		}
		this.m_InsertFixup4(t_node);
	}else{
		this.f_root=t_node;
	}
	return true;
}
bb_map_Map4.prototype.m_Insert2=function(t_key,t_value){
	return this.m_Set4(t_key,t_value);
}
function bb_map_StringMap4(){
	bb_map_Map4.call(this);
}
bb_map_StringMap4.prototype=extend_class(bb_map_Map4);
function bb_map_StringMap4_new(){
	bb_map_Map4_new.call(this);
	return this;
}
bb_map_StringMap4.prototype.m_Compare=function(t_lhs,t_rhs){
	return string_compare(t_lhs,t_rhs);
}
function bb_map_Node4(){
	Object.call(this);
	this.f_key="";
	this.f_right=null;
	this.f_left=null;
	this.f_value=null;
	this.f_color=0;
	this.f_parent=null;
}
function bb_map_Node4_new(t_key,t_value,t_color,t_parent){
	this.f_key=t_key;
	this.f_value=t_value;
	this.f_color=t_color;
	this.f_parent=t_parent;
	return this;
}
function bb_map_Node4_new2(){
	return this;
}
function bb_highscore_Highscore(){
	Object.call(this);
	this.f__maxCount=0;
	this.f_objects=bb_list_List3_new.call(new bb_list_List3);
	this.implments={bb_persistable_Persistable:1};
}
function bb_highscore_Highscore_new(t_maxCount){
	this.f__maxCount=t_maxCount;
	return this;
}
function bb_highscore_Highscore_new2(){
	return this;
}
bb_highscore_Highscore.prototype.m_Count=function(){
	return this.f_objects.m_Count();
}
bb_highscore_Highscore.prototype.m_maxCount=function(){
	return this.f__maxCount;
}
bb_highscore_Highscore.prototype.m_Sort=function(){
	if(this.f_objects.m_Count()<2){
		return;
	}
	var t_newList=bb_list_List3_new.call(new bb_list_List3);
	var t_current=null;
	while(this.f_objects.m_Count()>0){
		t_current=this.f_objects.m_First();
		var t_=this.f_objects.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			var t_check=t_.m_NextObject();
			if(t_check.f_value<t_current.f_value){
				t_current=t_check;
			}
		}
		t_newList.m_AddFirst(t_current);
		this.f_objects.m_Remove3(t_current);
	}
	this.f_objects.m_Clear();
	this.f_objects=t_newList;
}
bb_highscore_Highscore.prototype.m_SizeTrim=function(){
	while(this.f_objects.m_Count()>this.f__maxCount){
		this.f_objects.m_RemoveLast();
	}
}
bb_highscore_Highscore.prototype.m_Add5=function(t_key,t_value){
	this.f_objects.m_AddLast3(bb_score_Score_new.call(new bb_score_Score,t_key,t_value));
	this.m_Sort();
	this.m_SizeTrim();
}
bb_highscore_Highscore.prototype.m_Last=function(){
	if(this.f_objects.m_Count()==0){
		return bb_score_Score_new.call(new bb_score_Score,"",0);
	}
	return this.f_objects.m_Last();
}
bb_highscore_Highscore.prototype.m_FromString=function(t_input){
	this.f_objects.m_Clear();
	var t_key="";
	var t_value=0;
	var t_splitted=t_input.split(",");
	for(var t_count=0;t_count<=t_splitted.length-2;t_count=t_count+2){
		t_key=string_replace(t_splitted[t_count],"[COMMA]",",");
		t_value=parseInt((t_splitted[t_count+1]),10);
		this.f_objects.m_AddLast3(bb_score_Score_new.call(new bb_score_Score,t_key,t_value));
	}
	this.m_Sort();
}
bb_highscore_Highscore.prototype.m_ObjectEnumerator=function(){
	return this.f_objects.m_ObjectEnumerator();
}
bb_highscore_Highscore.prototype.m_ToString=function(){
	var t_result="";
	var t_=this.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_score=t_.m_NextObject();
		t_result=t_result+(string_replace(t_score.f_key,",","[COMMA]")+","+String(t_score.f_value)+",");
	}
	return t_result;
}
function bb_highscore_IntHighscore(){
	bb_highscore_Highscore.call(this);
	this.implments={bb_persistable_Persistable:1};
}
bb_highscore_IntHighscore.prototype=extend_class(bb_highscore_Highscore);
function bb_highscore_IntHighscore_new(t_maxCount){
	bb_highscore_Highscore_new.call(this,t_maxCount);
	return this;
}
function bb_highscore_IntHighscore_new2(){
	bb_highscore_Highscore_new2.call(this);
	return this;
}
function bb_gamehighscore_GameHighscore(){
	bb_highscore_IntHighscore.call(this);
	this.implments={bb_persistable_Persistable:1};
}
bb_gamehighscore_GameHighscore.prototype=extend_class(bb_highscore_IntHighscore);
var bb_gamehighscore_GameHighscore_names;
var bb_gamehighscore_GameHighscore_scores;
bb_gamehighscore_GameHighscore.prototype.m_LoadNamesAndScores=function(){
	bb_gamehighscore_GameHighscore_names=["Michael","Sena","Joe","Mouser","Tinnet","Horas-Ra","Monkey","Mike","Bono","Angel"];
	bb_gamehighscore_GameHighscore_scores=[1000,900,800,700,600,500,400,300,200,100];
}
bb_gamehighscore_GameHighscore.prototype.m_PrefillMissing=function(){
	if(this.m_Count()>=this.m_maxCount()){
		return;
	}
	for(var t_i=0;t_i<this.m_maxCount();t_i=t_i+1){
		this.m_Add5("easy "+bb_gamehighscore_GameHighscore_names[t_i],bb_gamehighscore_GameHighscore_scores[t_i]);
	}
}
function bb_gamehighscore_GameHighscore_new(){
	bb_highscore_IntHighscore_new.call(this,10);
	this.m_LoadNamesAndScores();
	this.m_PrefillMissing();
	return this;
}
bb_gamehighscore_GameHighscore.prototype.m_FromString=function(t_input){
	bb_highscore_Highscore.prototype.m_FromString.call(this,t_input);
	this.m_PrefillMissing();
}
function bb_score_Score(){
	Object.call(this);
	this.f_key="";
	this.f_value=0;
}
function bb_score_Score_new(t_key,t_value){
	this.f_key=t_key;
	this.f_value=t_value;
	return this;
}
function bb_score_Score_new2(){
	return this;
}
function bb_list_List3(){
	Object.call(this);
	this.f__head=(bb_list_HeadNode3_new.call(new bb_list_HeadNode3));
}
function bb_list_List3_new(){
	return this;
}
bb_list_List3.prototype.m_AddLast3=function(t_data){
	return bb_list_Node3_new.call(new bb_list_Node3,this.f__head,this.f__head.f__pred,t_data);
}
function bb_list_List3_new2(t_data){
	var t_=t_data;
	var t_2=0;
	while(t_2<t_.length){
		var t_t=t_[t_2];
		t_2=t_2+1;
		this.m_AddLast3(t_t);
	}
	return this;
}
bb_list_List3.prototype.m_Count=function(){
	var t_n=0;
	var t_node=this.f__head.f__succ;
	while(t_node!=this.f__head){
		t_node=t_node.f__succ;
		t_n+=1;
	}
	return t_n;
}
bb_list_List3.prototype.m_First=function(){
	return this.f__head.m_NextNode().f__data;
}
bb_list_List3.prototype.m_ObjectEnumerator=function(){
	return bb_list_Enumerator2_new.call(new bb_list_Enumerator2,this);
}
bb_list_List3.prototype.m_AddFirst=function(t_data){
	return bb_list_Node3_new.call(new bb_list_Node3,this.f__head.f__succ,this.f__head,t_data);
}
bb_list_List3.prototype.m_Equals3=function(t_lhs,t_rhs){
	return t_lhs==t_rhs;
}
bb_list_List3.prototype.m_RemoveEach2=function(t_value){
	var t_node=this.f__head.f__succ;
	while(t_node!=this.f__head){
		var t_succ=t_node.f__succ;
		if(this.m_Equals3(t_node.f__data,t_value)){
			t_node.m_Remove2();
		}
		t_node=t_succ;
	}
	return 0;
}
bb_list_List3.prototype.m_Remove3=function(t_value){
	this.m_RemoveEach2(t_value);
	return 0;
}
bb_list_List3.prototype.m_Clear=function(){
	this.f__head.f__succ=this.f__head;
	this.f__head.f__pred=this.f__head;
	return 0;
}
bb_list_List3.prototype.m_RemoveLast=function(){
	var t_data=this.f__head.m_PrevNode().f__data;
	this.f__head.f__pred.m_Remove2();
	return t_data;
}
bb_list_List3.prototype.m_Last=function(){
	return this.f__head.m_PrevNode().f__data;
}
function bb_list_Node3(){
	Object.call(this);
	this.f__succ=null;
	this.f__pred=null;
	this.f__data=null;
}
function bb_list_Node3_new(t_succ,t_pred,t_data){
	this.f__succ=t_succ;
	this.f__pred=t_pred;
	this.f__succ.f__pred=this;
	this.f__pred.f__succ=this;
	this.f__data=t_data;
	return this;
}
function bb_list_Node3_new2(){
	return this;
}
bb_list_Node3.prototype.m_GetNode=function(){
	return this;
}
bb_list_Node3.prototype.m_NextNode=function(){
	return this.f__succ.m_GetNode();
}
bb_list_Node3.prototype.m_Remove2=function(){
	this.f__succ.f__pred=this.f__pred;
	this.f__pred.f__succ=this.f__succ;
	return 0;
}
bb_list_Node3.prototype.m_PrevNode=function(){
	return this.f__pred.m_GetNode();
}
function bb_list_HeadNode3(){
	bb_list_Node3.call(this);
}
bb_list_HeadNode3.prototype=extend_class(bb_list_Node3);
function bb_list_HeadNode3_new(){
	bb_list_Node3_new2.call(this);
	this.f__succ=(this);
	this.f__pred=(this);
	return this;
}
bb_list_HeadNode3.prototype.m_GetNode=function(){
	return null;
}
function bb_list_Enumerator2(){
	Object.call(this);
	this.f__list=null;
	this.f__curr=null;
}
function bb_list_Enumerator2_new(t_list){
	this.f__list=t_list;
	this.f__curr=t_list.f__head.f__succ;
	return this;
}
function bb_list_Enumerator2_new2(){
	return this;
}
bb_list_Enumerator2.prototype.m_HasNext=function(){
	while(this.f__curr.f__succ.f__pred!=this.f__curr){
		this.f__curr=this.f__curr.f__succ;
	}
	return this.f__curr!=this.f__list.f__head;
}
bb_list_Enumerator2.prototype.m_NextObject=function(){
	var t_data=this.f__curr.f__data;
	this.f__curr=this.f__curr.f__succ;
	return t_data;
}
function bb_statestore_StateStore(){
	Object.call(this);
}
function bb_statestore_StateStore_Load(t_obj){
	t_obj.m_FromString(bb_app_LoadState());
}
function bb_statestore_StateStore_Save(t_obj){
	bb_app_SaveState(t_obj.m_ToString());
}
function bb_app_LoadState(){
	return bb_app_device.LoadState();
}
function bb_chute_Chute(){
	bb_baseobject_BaseObject.call(this);
	this.f_height=0;
	this.f_bg=null;
	this.f_width=0;
	this.f_bottom=null;
	this.f_severity=null;
	this.implments={bb_positionable_Positionable:1,bb_sizeable_Sizeable:1,bb_directorevents_DirectorEvents:1};
}
bb_chute_Chute.prototype=extend_class(bb_baseobject_BaseObject);
function bb_chute_Chute_new(){
	bb_baseobject_BaseObject_new.call(this);
	return this;
}
bb_chute_Chute.prototype.m_Restart=function(){
	this.f_height=75;
}
bb_chute_Chute.prototype.m_OnCreate=function(t_director){
	this.f_bg=bb_graphics_LoadImage("chute-bg.png",1,bb_graphics_Image_DefaultFlags);
	this.f_width=this.f_bg.m_Width();
	this.f_bottom=bb_graphics_LoadImage("chute-bottom.png",1,bb_graphics_Image_DefaultFlags);
	this.f_severity=bb_severity_CurrentSeverity();
	this.m_Restart();
	bb_partial_Partial.prototype.m_OnCreate.call(this,t_director);
}
bb_chute_Chute.prototype.m_OnUpdate=function(t_delta,t_frameTime){
	if(this.f_severity.m_ChuteShouldAdvance()){
		this.f_height+=this.f_severity.m_ChuteAdvanceHeight();
		this.f_severity.m_ChuteMarkAsAdvanced();
	}
}
bb_chute_Chute.prototype.m_OnRender=function(){
	for(var t_posY=0.0;t_posY<=(this.f_height);t_posY=t_posY+6.0){
		bb_graphics_DrawImage(this.f_bg,(46+this.f_width*0),t_posY,0);
		bb_graphics_DrawImage(this.f_bg,(46+this.f_width*1),t_posY,0);
		bb_graphics_DrawImage(this.f_bg,(46+this.f_width*2),t_posY,0);
		bb_graphics_DrawImage(this.f_bg,(46+this.f_width*3),t_posY,0);
	}
	bb_graphics_DrawImage(this.f_bottom,(44+this.f_width*0),(this.f_height),0);
	bb_graphics_DrawImage(this.f_bottom,(44+this.f_width*1),(this.f_height),0);
	bb_graphics_DrawImage(this.f_bottom,(44+this.f_width*2),(this.f_height),0);
	bb_graphics_DrawImage(this.f_bottom,(44+this.f_width*3),(this.f_height),0);
}
bb_chute_Chute.prototype.m_Height=function(){
	return this.f_height;
}
function bb_severity_Severity(){
	Object.call(this);
	this.f_nextChuteAdvanceTime=0;
	this.f_nextShapeDropTime=0;
	this.f_lastTime=0;
	this.f_level=0;
	this.f_activatedShapes=0;
	this.f_slowDownDuration=0;
	this.f_lastTypes=bb_stack_IntStack_new.call(new bb_stack_IntStack);
	this.f_progress=1.0;
	this.f_shapeTypes=[0,1,2,3];
	this.f_startTime=0;
	this.f_laneTimes=[0,0,0,0];
}
function bb_severity_Severity_new(){
	return this;
}
bb_severity_Severity.prototype.m_WarpTime=function(t_diff){
	this.f_nextChuteAdvanceTime+=t_diff;
	this.f_nextShapeDropTime+=t_diff;
	this.f_lastTime+=t_diff;
}
bb_severity_Severity.prototype.m_ChuteMarkAsAdvanced=function(){
	this.f_nextChuteAdvanceTime=((bb_random_Rnd2(1700.0,3000.0))|0);
	var t_2=this.f_level;
	if(t_2==0){
		this.f_nextChuteAdvanceTime=(((this.f_nextChuteAdvanceTime)+2500.0*this.f_progress)|0);
	}else{
		if(t_2==1){
			this.f_nextChuteAdvanceTime=(((this.f_nextChuteAdvanceTime)+2000.0*this.f_progress)|0);
		}else{
			if(t_2==2){
				this.f_nextChuteAdvanceTime=(((this.f_nextChuteAdvanceTime)+1500.0*this.f_progress)|0);
			}
		}
	}
	this.f_nextChuteAdvanceTime*=2;
	this.f_nextChuteAdvanceTime+=this.f_lastTime;
}
bb_severity_Severity.prototype.m_ShapeDropped=function(){
	var t_3=this.f_level;
	if(t_3==0){
		this.f_nextShapeDropTime=(((this.f_lastTime)+bb_random_Rnd2(450.0,1800.0+2500.0*this.f_progress))|0);
	}else{
		if(t_3==1){
			this.f_nextShapeDropTime=(((this.f_lastTime)+bb_random_Rnd2(350.0,1700.0+2100.0*this.f_progress))|0);
		}else{
			if(t_3==2){
				this.f_nextShapeDropTime=(((this.f_lastTime)+bb_random_Rnd2(250.0,1600.0+1700.0*this.f_progress))|0);
			}
		}
	}
}
bb_severity_Severity.prototype.m_RandomizeShapeTypes=function(){
	var t_swapIndex=0;
	var t_tmpType=0;
	for(var t_i=0;t_i<this.f_shapeTypes.length;t_i=t_i+1){
		do{
			t_swapIndex=((bb_random_Rnd2(0.0,(this.f_shapeTypes.length)))|0);
		}while(!(t_swapIndex!=t_i));
		t_tmpType=this.f_shapeTypes[t_i];
		this.f_shapeTypes[t_i]=this.f_shapeTypes[t_swapIndex];
		this.f_shapeTypes[t_swapIndex]=t_tmpType;
	}
}
bb_severity_Severity.prototype.m_Restart=function(){
	var t_1=this.f_level;
	if(t_1==0){
		this.f_activatedShapes=2;
		this.f_slowDownDuration=120000;
	}else{
		if(t_1==1){
			this.f_activatedShapes=3;
			this.f_slowDownDuration=90000;
		}else{
			if(t_1==2){
				this.f_activatedShapes=4;
				this.f_slowDownDuration=60000;
			}
		}
	}
	this.f_lastTypes.m_Clear();
	this.m_ChuteMarkAsAdvanced();
	this.m_ShapeDropped();
	this.m_RandomizeShapeTypes();
	this.f_progress=1.0;
	this.f_startTime=bb_app_Millisecs();
}
bb_severity_Severity.prototype.m_MinSliderTypes=function(){
	if(this.f_level==0){
		return 2;
	}else{
		if(this.f_level==1){
			return 3;
		}else{
			return 4;
		}
	}
}
bb_severity_Severity.prototype.m_ConfigureSlider=function(t_config){
	var t_usedTypes=bb_set_IntSet_new.call(new bb_set_IntSet);
	t_config.m_Clear();
	for(var t_i=0;t_i<this.m_MinSliderTypes();t_i=t_i+1){
		t_usedTypes.m_Insert4(this.f_shapeTypes[t_i]);
		t_config.m_AddLast4(this.f_shapeTypes[t_i]);
	}
	while(t_config.m_Count()<4){
		if(t_usedTypes.m_Count()>=this.f_activatedShapes || bb_random_Rnd()<0.5){
			t_config.m_AddLast4(this.f_shapeTypes[((bb_random_Rnd2(0.0,(t_usedTypes.m_Count())))|0)]);
		}else{
			t_config.m_AddLast4(this.f_shapeTypes[t_usedTypes.m_Count()]);
			t_usedTypes.m_Insert4(this.f_shapeTypes[t_usedTypes.m_Count()]);
		}
	}
	this.f_activatedShapes=t_usedTypes.m_Count();
}
bb_severity_Severity.prototype.m_ChuteShouldAdvance=function(){
	return this.f_lastTime>=this.f_nextChuteAdvanceTime;
}
bb_severity_Severity.prototype.m_ChuteAdvanceHeight=function(){
	return 40;
}
bb_severity_Severity.prototype.m_Set5=function(t_level){
	this.f_level=t_level;
	this.m_Restart();
}
bb_severity_Severity.prototype.m_OnUpdate=function(t_delta,t_frameTime){
	this.f_lastTime=bb_app_Millisecs();
	if(this.f_progress>0.0){
		this.f_progress=1.0-1.0/(this.f_slowDownDuration)*(this.f_lastTime-this.f_startTime);
		this.f_progress=bb_math_Max2(0.0,this.f_progress);
	}
}
bb_severity_Severity.prototype.m_ShapeShouldBeDropped=function(){
	return this.f_lastTime>=this.f_nextShapeDropTime;
}
bb_severity_Severity.prototype.m_RandomType=function(){
	var t_newType=0;
	var t_finished=false;
	do{
		t_finished=true;
		t_newType=((bb_random_Rnd2(0.0,(this.f_activatedShapes)))|0);
		if(this.f_lastTypes.m_Length()>=2){
			if(this.f_lastTypes.m_Get2(0)==t_newType){
				if(this.f_lastTypes.m_Get2(1)==t_newType){
					t_finished=false;
				}
			}
		}
	}while(!(t_finished==true));
	if(this.f_lastTypes.m_Length()>=2){
		this.f_lastTypes.m_Remove4(0);
	}
	this.f_lastTypes.m_Push(t_newType);
	return this.f_shapeTypes[t_newType];
}
bb_severity_Severity.prototype.m_RandomLane=function(){
	var t_newLane=0;
	var t_now=bb_app_Millisecs();
	do{
		t_newLane=((bb_random_Rnd2(0.0,4.0))|0);
	}while(!(this.f_laneTimes[t_newLane]<t_now));
	this.f_laneTimes[t_newLane]=t_now+1000;
	return t_newLane;
}
bb_severity_Severity.prototype.m_ToString=function(){
	if(this.f_level==0){
		return "easy";
	}else{
		if(this.f_level==1){
			return "norm";
		}else{
			return "adv.";
		}
	}
}
var bb_severity_globalSeverityInstance;
function bb_severity_CurrentSeverity(){
	if(!((bb_severity_globalSeverityInstance)!=null)){
		bb_severity_globalSeverityInstance=bb_severity_Severity_new.call(new bb_severity_Severity);
	}
	return bb_severity_globalSeverityInstance;
}
function bb_slider_Slider(){
	bb_baseobject_BaseObject.call(this);
	this.f_images=[];
	this.f_config=bb_list_IntList_new.call(new bb_list_IntList);
	this.f_configArray=[];
	this.f_movementActive=false;
	this.f_movementStart=0;
	this.f_arrowLeft=null;
	this.f_arrowRight=null;
	this.f_posY=.0;
	this.f_direction=0;
	this.implments={bb_positionable_Positionable:1,bb_sizeable_Sizeable:1,bb_directorevents_DirectorEvents:1};
}
bb_slider_Slider.prototype=extend_class(bb_baseobject_BaseObject);
function bb_slider_Slider_new(){
	bb_baseobject_BaseObject_new.call(this);
	return this;
}
bb_slider_Slider.prototype.m_InitializeConfig=function(){
	bb_severity_CurrentSeverity().m_ConfigureSlider(this.f_config);
	this.f_configArray=this.f_config.m_ToArray();
}
bb_slider_Slider.prototype.m_Restart=function(){
	this.m_InitializeConfig();
	this.f_movementActive=false;
	this.f_movementStart=0;
}
bb_slider_Slider.prototype.m_OnCreate=function(t_director){
	this.f_images=[bb_graphics_LoadImage("circle_outside.png",1,bb_graphics_Image_DefaultFlags),bb_graphics_LoadImage("plus_outside.png",1,bb_graphics_Image_DefaultFlags),bb_graphics_LoadImage("star_outside.png",1,bb_graphics_Image_DefaultFlags),bb_graphics_LoadImage("tire_outside.png",1,bb_graphics_Image_DefaultFlags)];
	this.f_arrowLeft=bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"arrow_ingame.png",null);
	this.f_arrowLeft.m_pos().f_y=t_director.m_size().f_y-this.f_arrowLeft.m_size().f_y;
	this.f_arrowRight=bb_sprite_Sprite_new.call(new bb_sprite_Sprite,"arrow_ingame2.png",null);
	this.f_arrowRight.m_pos2(t_director.m_size().m_Copy().m_Sub(this.f_arrowRight.m_size()));
	bb_partial_Partial.prototype.m_OnCreate.call(this,t_director);
	this.f_posY=t_director.m_size().f_y-(this.f_images[0].m_Height())-60.0;
}
bb_slider_Slider.prototype.m_pos=function(){
	return this.f_arrowLeft.m_pos();
}
bb_slider_Slider.prototype.m_GetMovementOffset=function(){
	if(!this.f_movementActive){
		return 0.0;
	}
	var t_now=bb_app_Millisecs();
	var t_percent=100.0;
	var t_movementOffset=0.0;
	if(this.f_movementStart+300>=t_now){
		t_percent=Math.ceil(0.33333333333333331*(t_now-this.f_movementStart));
		t_movementOffset=Math.ceil((this.f_images[0].m_Width())/100.0*t_percent);
	}
	if(this.f_direction==1){
		t_movementOffset=t_movementOffset*-1.0;
	}
	if(this.f_movementStart+300<t_now){
		this.f_movementActive=false;
		if(this.f_direction==1){
			var t_tmpType=this.f_config.m_First();
			this.f_config.m_RemoveFirst();
			this.f_config.m_AddLast4(t_tmpType);
			this.f_configArray=this.f_config.m_ToArray();
		}else{
			var t_tmpType2=this.f_config.m_Last();
			this.f_config.m_RemoveLast();
			this.f_config.m_AddFirst2(t_tmpType2);
			this.f_configArray=this.f_config.m_ToArray();
		}
	}
	return t_movementOffset;
}
bb_slider_Slider.prototype.m_OnRender=function(){
	var t_posX=46.0+this.m_GetMovementOffset();
	var t_img=null;
	bb_graphics_PushMatrix();
	bb_graphics_SetColor(255.0,255.0,255.0);
	bb_graphics_DrawRect(0.0,this.f_posY+(this.f_images[this.f_config.m_First()].m_Height()),this.m_director().m_size().f_x,this.m_director().m_size().f_y);
	bb_graphics_PopMatrix();
	if(t_posX>46.0){
		t_img=this.f_images[this.f_config.m_Last()];
		bb_graphics_DrawImage(t_img,(t_img.m_Width()*-1)+t_posX,this.f_posY,0);
	}
	if(t_posX<46.0){
		t_img=this.f_images[this.f_config.m_First()];
		bb_graphics_DrawImage(t_img,(t_img.m_Width()*4)+t_posX,this.f_posY,0);
	}
	var t_=this.f_config.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_type=t_.m_NextObject();
		bb_graphics_DrawImage(this.f_images[t_type],t_posX,this.f_posY,0);
		t_posX=t_posX+(this.f_images[t_type].m_Width());
	}
	this.f_arrowRight.m_OnRender();
	this.f_arrowLeft.m_OnRender();
}
bb_slider_Slider.prototype.m_Match=function(t_shape){
	if(this.f_movementActive){
		return false;
	}
	if(t_shape.f_type==this.f_configArray[t_shape.f_lane]){
		return true;
	}
	return false;
}
bb_slider_Slider.prototype.m_SlideLeft=function(){
	if(this.f_movementActive){
		return;
	}
	this.f_direction=1;
	this.f_movementStart=bb_app_Millisecs();
	this.f_movementActive=true;
}
bb_slider_Slider.prototype.m_SlideRight=function(){
	if(this.f_movementActive){
		return;
	}
	this.f_direction=2;
	this.f_movementStart=bb_app_Millisecs();
	this.f_movementActive=true;
}
function bb_font_Font(){
	bb_baseobject_BaseObject.call(this);
	this.f_name="";
	this.f__text="";
	this.f_fontStore=bb_map_StringMap5_new.call(new bb_map_StringMap5);
	this.f_recalculateSize=false;
	this.f__align=0;
	this.f_color=null;
	this.implments={bb_positionable_Positionable:1,bb_sizeable_Sizeable:1,bb_directorevents_DirectorEvents:1};
}
bb_font_Font.prototype=extend_class(bb_baseobject_BaseObject);
function bb_font_Font_new(t_fontName,t_pos){
	bb_baseobject_BaseObject_new.call(this);
	if(t_pos==null){
		t_pos=bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,0.0,0.0);
	}
	this.f_name=t_fontName;
	this.m_pos2(t_pos);
	return this;
}
function bb_font_Font_new2(){
	bb_baseobject_BaseObject_new.call(this);
	return this;
}
bb_font_Font.prototype.m_font=function(){
	return this.f_fontStore.m_Get(this.f_name);
}
bb_font_Font.prototype.m_text=function(t_newText){
	this.f__text=t_newText;
	if(!((this.m_font())!=null)){
		this.f_recalculateSize=true;
		return;
	}
	var t_width=(this.m_font().m_TextWidth(t_newText));
	var t_height=(this.m_font().m_TextHeight(t_newText));
	this.m_size2(bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,t_width,t_height));
}
bb_font_Font.prototype.m_text2=function(){
	return this.f__text;
}
bb_font_Font.prototype.m_align=function(t_newAlign){
	var t_1=t_newAlign;
	if(t_1==0 || t_1==1 || t_1==2){
		this.f__align=t_newAlign;
	}else{
		error("Invalid align value specified.");
	}
}
bb_font_Font.prototype.m_align2=function(){
	return this.f__align;
}
bb_font_Font.prototype.m_OnCreate=function(t_director){
	bb_partial_Partial.prototype.m_OnCreate.call(this,t_director);
	if(!this.f_fontStore.m_Contains(this.f_name)){
		this.f_fontStore.m_Set6(this.f_name,bb_angelfont_AngelFont_new.call(new bb_angelfont_AngelFont,""));
		this.f_fontStore.m_Get(this.f_name).m_LoadFont(this.f_name);
	}
	if(this.f_recalculateSize){
		this.f_recalculateSize=false;
		this.m_text(this.f__text);
	}
}
bb_font_Font.prototype.m_OnRender=function(){
	if((this.f_color)!=null){
		this.f_color.m_Activate();
	}
	this.m_font().m_DrawText2(this.f__text,((this.m_pos().f_x)|0),((this.m_pos().f_y)|0),this.f__align);
	if((this.f_color)!=null){
		this.f_color.m_Deactivate();
	}
}
function bb_angelfont_AngelFont(){
	Object.call(this);
	this.f_chars=new_object_array(256);
	this.f_useKerning=true;
	this.f_kernPairs=bb_map_StringMap3_new.call(new bb_map_StringMap3);
	this.f_iniText="";
	this.f_height=0;
	this.f_heightOffset=9999;
	this.f_image=null;
	this.f_name="";
	this.f_xOffset=0;
}
bb_angelfont_AngelFont.prototype.m_TextWidth=function(t_txt){
	var t_prevChar="";
	var t_width=0;
	for(var t_i=0;t_i<t_txt.length;t_i=t_i+1){
		var t_asc=t_txt.charCodeAt(t_i);
		var t_ac=this.f_chars[t_asc];
		var t_thisChar=String.fromCharCode(t_asc);
		if(t_ac!=null){
			if(this.f_useKerning){
				var t_key=t_prevChar+"_"+t_thisChar;
				if(this.f_kernPairs.m_Contains(t_key)){
					t_width+=this.f_kernPairs.m_Get(t_key).f_amount;
				}
			}
			t_width+=t_ac.f_xAdvance;
			t_prevChar=t_thisChar;
		}
	}
	return t_width;
}
bb_angelfont_AngelFont.prototype.m_TextHeight=function(t_txt){
	var t_h=0;
	for(var t_i=0;t_i<t_txt.length;t_i=t_i+1){
		var t_asc=t_txt.charCodeAt(t_i);
		var t_ac=this.f_chars[t_asc];
		if(t_ac.f_height>t_h){
			t_h=t_ac.f_height;
		}
	}
	return t_h;
}
var bb_angelfont_AngelFont_error;
var bb_angelfont_AngelFont_current;
bb_angelfont_AngelFont.prototype.m_LoadFont=function(t_url){
	bb_angelfont_AngelFont_error="";
	bb_angelfont_AngelFont_current=this;
	this.f_iniText=bb_app_LoadString(t_url+".txt");
	var t_lines=this.f_iniText.split(String.fromCharCode(10));
	var t_=t_lines;
	var t_2=0;
	while(t_2<t_.length){
		var t_line=t_[t_2];
		t_2=t_2+1;
		t_line=string_trim(t_line);
		if(string_starts_with(t_line,"id,") || t_line==""){
			continue;
		}
		if(string_starts_with(t_line,"first,")){
			continue;
		}
		var t_data=t_line.split(",");
		for(var t_i=0;t_i<t_data.length;t_i=t_i+1){
			t_data[t_i]=string_trim(t_data[t_i]);
		}
		bb_angelfont_AngelFont_error=bb_angelfont_AngelFont_error+(String(t_data.length)+",");
		if(t_data.length>0){
			if(t_data.length==3){
				this.f_kernPairs.m_Insert(String.fromCharCode(parseInt((t_data[0]),10))+"_"+String.fromCharCode(parseInt((t_data[1]),10)),bb_kernpair_KernPair_new.call(new bb_kernpair_KernPair,parseInt((t_data[0]),10),parseInt((t_data[1]),10),parseInt((t_data[2]),10)));
			}else{
				if(t_data.length>=8){
					this.f_chars[parseInt((t_data[0]),10)]=bb_char_Char_new.call(new bb_char_Char,parseInt((t_data[1]),10),parseInt((t_data[2]),10),parseInt((t_data[3]),10),parseInt((t_data[4]),10),parseInt((t_data[5]),10),parseInt((t_data[6]),10),parseInt((t_data[7]),10));
					var t_ch=this.f_chars[parseInt((t_data[0]),10)];
					if(t_ch.f_height>this.f_height){
						this.f_height=t_ch.f_height;
					}
					if(t_ch.f_yOffset<this.f_heightOffset){
						this.f_heightOffset=t_ch.f_yOffset;
					}
				}
			}
		}
	}
	this.f_image=bb_graphics_LoadImage(t_url+".png",1,bb_graphics_Image_DefaultFlags);
}
var bb_angelfont_AngelFont__list;
function bb_angelfont_AngelFont_new(t_url){
	if(t_url!=""){
		this.m_LoadFont(t_url);
		this.f_name=t_url;
		bb_angelfont_AngelFont__list.m_Insert3(t_url,this);
	}
	return this;
}
bb_angelfont_AngelFont.prototype.m_DrawText=function(t_txt,t_x,t_y){
	var t_prevChar="";
	this.f_xOffset=0;
	for(var t_i=0;t_i<t_txt.length;t_i=t_i+1){
		var t_asc=t_txt.charCodeAt(t_i);
		var t_ac=this.f_chars[t_asc];
		var t_thisChar=String.fromCharCode(t_asc);
		if(t_ac!=null){
			if(this.f_useKerning){
				var t_key=t_prevChar+"_"+t_thisChar;
				if(this.f_kernPairs.m_Contains(t_key)){
					this.f_xOffset+=this.f_kernPairs.m_Get(t_key).f_amount;
				}
			}
			t_ac.m_Draw(this.f_image,t_x+this.f_xOffset,t_y);
			this.f_xOffset+=t_ac.f_xAdvance;
			t_prevChar=t_thisChar;
		}
	}
}
bb_angelfont_AngelFont.prototype.m_DrawText2=function(t_txt,t_x,t_y,t_align){
	this.f_xOffset=0;
	var t_1=t_align;
	if(t_1==1){
		this.m_DrawText(t_txt,t_x-((this.m_TextWidth(t_txt)/2)|0),t_y);
	}else{
		if(t_1==2){
			this.m_DrawText(t_txt,t_x-this.m_TextWidth(t_txt),t_y);
		}else{
			if(t_1==0){
				this.m_DrawText(t_txt,t_x,t_y);
			}
		}
	}
}
function bb_map_Map5(){
	Object.call(this);
	this.f_root=null;
}
function bb_map_Map5_new(){
	return this;
}
bb_map_Map5.prototype.m_Compare=function(t_lhs,t_rhs){
}
bb_map_Map5.prototype.m_FindNode=function(t_key){
	var t_node=this.f_root;
	while((t_node)!=null){
		var t_cmp=this.m_Compare(t_key,t_node.f_key);
		if(t_cmp>0){
			t_node=t_node.f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node.f_left;
			}else{
				return t_node;
			}
		}
	}
	return t_node;
}
bb_map_Map5.prototype.m_Get=function(t_key){
	var t_node=this.m_FindNode(t_key);
	if((t_node)!=null){
		return t_node.f_value;
	}
	return null;
}
bb_map_Map5.prototype.m_Contains=function(t_key){
	return this.m_FindNode(t_key)!=null;
}
bb_map_Map5.prototype.m_RotateLeft5=function(t_node){
	var t_child=t_node.f_right;
	t_node.f_right=t_child.f_left;
	if((t_child.f_left)!=null){
		t_child.f_left.f_parent=t_node;
	}
	t_child.f_parent=t_node.f_parent;
	if((t_node.f_parent)!=null){
		if(t_node==t_node.f_parent.f_left){
			t_node.f_parent.f_left=t_child;
		}else{
			t_node.f_parent.f_right=t_child;
		}
	}else{
		this.f_root=t_child;
	}
	t_child.f_left=t_node;
	t_node.f_parent=t_child;
	return 0;
}
bb_map_Map5.prototype.m_RotateRight5=function(t_node){
	var t_child=t_node.f_left;
	t_node.f_left=t_child.f_right;
	if((t_child.f_right)!=null){
		t_child.f_right.f_parent=t_node;
	}
	t_child.f_parent=t_node.f_parent;
	if((t_node.f_parent)!=null){
		if(t_node==t_node.f_parent.f_right){
			t_node.f_parent.f_right=t_child;
		}else{
			t_node.f_parent.f_left=t_child;
		}
	}else{
		this.f_root=t_child;
	}
	t_child.f_right=t_node;
	t_node.f_parent=t_child;
	return 0;
}
bb_map_Map5.prototype.m_InsertFixup5=function(t_node){
	while(((t_node.f_parent)!=null) && t_node.f_parent.f_color==-1 && ((t_node.f_parent.f_parent)!=null)){
		if(t_node.f_parent==t_node.f_parent.f_parent.f_left){
			var t_uncle=t_node.f_parent.f_parent.f_right;
			if(((t_uncle)!=null) && t_uncle.f_color==-1){
				t_node.f_parent.f_color=1;
				t_uncle.f_color=1;
				t_uncle.f_parent.f_color=-1;
				t_node=t_uncle.f_parent;
			}else{
				if(t_node==t_node.f_parent.f_right){
					t_node=t_node.f_parent;
					this.m_RotateLeft5(t_node);
				}
				t_node.f_parent.f_color=1;
				t_node.f_parent.f_parent.f_color=-1;
				this.m_RotateRight5(t_node.f_parent.f_parent);
			}
		}else{
			var t_uncle2=t_node.f_parent.f_parent.f_left;
			if(((t_uncle2)!=null) && t_uncle2.f_color==-1){
				t_node.f_parent.f_color=1;
				t_uncle2.f_color=1;
				t_uncle2.f_parent.f_color=-1;
				t_node=t_uncle2.f_parent;
			}else{
				if(t_node==t_node.f_parent.f_left){
					t_node=t_node.f_parent;
					this.m_RotateRight5(t_node);
				}
				t_node.f_parent.f_color=1;
				t_node.f_parent.f_parent.f_color=-1;
				this.m_RotateLeft5(t_node.f_parent.f_parent);
			}
		}
	}
	this.f_root.f_color=1;
	return 0;
}
bb_map_Map5.prototype.m_Set6=function(t_key,t_value){
	var t_node=this.f_root;
	var t_parent=null;
	var t_cmp=0;
	while((t_node)!=null){
		t_parent=t_node;
		t_cmp=this.m_Compare(t_key,t_node.f_key);
		if(t_cmp>0){
			t_node=t_node.f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node.f_left;
			}else{
				t_node.f_value=t_value;
				return false;
			}
		}
	}
	t_node=bb_map_Node5_new.call(new bb_map_Node5,t_key,t_value,-1,t_parent);
	if((t_parent)!=null){
		if(t_cmp>0){
			t_parent.f_right=t_node;
		}else{
			t_parent.f_left=t_node;
		}
		this.m_InsertFixup5(t_node);
	}else{
		this.f_root=t_node;
	}
	return true;
}
bb_map_Map5.prototype.m_Insert3=function(t_key,t_value){
	return this.m_Set6(t_key,t_value);
}
function bb_map_StringMap5(){
	bb_map_Map5.call(this);
}
bb_map_StringMap5.prototype=extend_class(bb_map_Map5);
function bb_map_StringMap5_new(){
	bb_map_Map5_new.call(this);
	return this;
}
bb_map_StringMap5.prototype.m_Compare=function(t_lhs,t_rhs){
	return string_compare(t_lhs,t_rhs);
}
function bb_map_Node5(){
	Object.call(this);
	this.f_key="";
	this.f_right=null;
	this.f_left=null;
	this.f_value=null;
	this.f_color=0;
	this.f_parent=null;
}
function bb_map_Node5_new(t_key,t_value,t_color,t_parent){
	this.f_key=t_key;
	this.f_value=t_value;
	this.f_color=t_color;
	this.f_parent=t_parent;
	return this;
}
function bb_map_Node5_new2(){
	return this;
}
function bb_animation_Animation(){
	bb_fanout_FanOut.call(this);
	this.f_startValue=.0;
	this.f_endValue=.0;
	this.f_duration=.0;
	this.f_effect=null;
	this.f_transition=(bb_transition_TransitionLinear_new.call(new bb_transition_TransitionLinear));
	this.f_finished=false;
	this.f_animationTime=.0;
	this.f__value=.0;
	this.implments={bb_directorevents_DirectorEvents:1};
}
bb_animation_Animation.prototype=extend_class(bb_fanout_FanOut);
function bb_animation_Animation_new(t_startValue,t_endValue,t_duration){
	bb_fanout_FanOut_new.call(this);
	this.f_startValue=t_startValue;
	this.f_endValue=t_endValue;
	this.f_duration=t_duration;
	return this;
}
function bb_animation_Animation_new2(){
	bb_fanout_FanOut_new.call(this);
	return this;
}
bb_animation_Animation.prototype.m_Pause=function(){
	this.f_finished=true;
}
bb_animation_Animation.prototype.m_OnUpdate=function(t_delta,t_frameTime){
	bb_fanout_FanOut.prototype.m_OnUpdate.call(this,t_delta,t_frameTime);
	if(this.f_finished){
		return;
	}
	this.f_animationTime+=t_frameTime;
	var t_progress=bb_math_Min2(1.0,this.f_animationTime/this.f_duration);
	var t_t=this.f_transition.m_Calculate(t_progress);
	this.f__value=this.f_startValue*(1.0-t_t)+this.f_endValue*t_t;
	if(this.f_animationTime>=this.f_duration){
		this.f_animationTime=this.f_duration;
		this.f_finished=true;
	}
}
bb_animation_Animation.prototype.m_OnRender=function(){
	if(!((this.f_effect)!=null)){
		bb_fanout_FanOut.prototype.m_OnRender.call(this);
		return;
	}
	if(this.m_Count()==0){
		return;
	}
	this.f_effect.m_PreRender(this.f__value);
	var t_=this.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_obj=t_.m_NextObject();
		this.f_effect.m_PreNode(this.f__value,t_obj);
		t_obj.m_OnRender();
		this.f_effect.m_PostNode(this.f__value,t_obj);
	}
	this.f_effect.m_PostRender(this.f__value);
}
bb_animation_Animation.prototype.m_Play=function(){
	this.f_finished=false;
}
bb_animation_Animation.prototype.m_Restart=function(){
	this.f_animationTime=0.0;
	this.m_Play();
}
bb_animation_Animation.prototype.m_IsPlaying=function(){
	return !this.f_finished;
}
function bb_fader_FaderScale(){
	Object.call(this);
	this.f_sizeNode=null;
	this.f_offsetX=.0;
	this.f_offsetY=.0;
	this.f_posNode=null;
	this.implments={bb_fader_Fader:1};
}
function bb_fader_FaderScale_new(){
	return this;
}
bb_fader_FaderScale.prototype.m_PreRender=function(t_value){
}
bb_fader_FaderScale.prototype.m_PostRender=function(t_value){
}
bb_fader_FaderScale.prototype.m_PreNode=function(t_value,t_node){
	if(t_value==1.0){
		return;
	}
	bb_graphics_PushMatrix();
	this.f_sizeNode=object_implements((t_node),"bb_sizeable_Sizeable");
	if((this.f_sizeNode)!=null){
		this.f_offsetX=this.f_sizeNode.m_center().f_x*(t_value-1.0);
		this.f_offsetY=this.f_sizeNode.m_center().f_y*(t_value-1.0);
		bb_graphics_Translate(-this.f_offsetX,-this.f_offsetY);
	}
	this.f_posNode=object_implements((t_node),"bb_positionable_Positionable");
	if((this.f_posNode)!=null){
		this.f_offsetX=this.f_posNode.m_pos().f_x*(t_value-1.0);
		this.f_offsetY=this.f_posNode.m_pos().f_y*(t_value-1.0);
		bb_graphics_Translate(-this.f_offsetX,-this.f_offsetY);
	}
	bb_graphics_Scale(t_value,t_value);
}
bb_fader_FaderScale.prototype.m_PostNode=function(t_value,t_node){
	if(t_value==1.0){
		return;
	}
	bb_graphics_PopMatrix();
}
function bb_transition_TransitionInCubic(){
	Object.call(this);
	this.implments={bb_transition_Transition:1};
}
function bb_transition_TransitionInCubic_new(){
	return this;
}
bb_transition_TransitionInCubic.prototype.m_Calculate=function(t_progress){
	return Math.pow(t_progress,3.0);
}
function bb_transition_TransitionLinear(){
	Object.call(this);
	this.implments={bb_transition_Transition:1};
}
function bb_transition_TransitionLinear_new(){
	return this;
}
bb_transition_TransitionLinear.prototype.m_Calculate=function(t_progress){
	return t_progress;
}
function bb_app_Millisecs(){
	return bb_app_device.MilliSecs();
}
function bb_stack_Stack(){
	Object.call(this);
	this.f_data=[];
	this.f_length=0;
}
function bb_stack_Stack_new(){
	return this;
}
function bb_stack_Stack_new2(t_data){
	this.f_data=t_data.slice(0);
	this.f_length=t_data.length;
	return this;
}
bb_stack_Stack.prototype.m_Clear=function(){
	this.f_length=0;
	return 0;
}
bb_stack_Stack.prototype.m_Length=function(){
	return this.f_length;
}
bb_stack_Stack.prototype.m_Get2=function(t_index){
	return this.f_data[t_index];
}
bb_stack_Stack.prototype.m_Remove4=function(t_index){
	for(var t_i=t_index;t_i<this.f_length-1;t_i=t_i+1){
		this.f_data[t_i]=this.f_data[t_i+1];
	}
	this.f_length-=1;
	return 0;
}
bb_stack_Stack.prototype.m_Push=function(t_value){
	if(this.f_length==this.f_data.length){
		this.f_data=resize_number_array(this.f_data,this.f_length*2+10);
	}
	this.f_data[this.f_length]=t_value;
	this.f_length+=1;
	return 0;
}
function bb_stack_IntStack(){
	bb_stack_Stack.call(this);
}
bb_stack_IntStack.prototype=extend_class(bb_stack_Stack);
function bb_stack_IntStack_new(){
	bb_stack_Stack_new.call(this);
	return this;
}
var bb_random_Seed;
function bb_random_Rnd(){
	bb_random_Seed=bb_random_Seed*1664525+1013904223|0;
	return (bb_random_Seed>>8&16777215)/16777216.0;
}
function bb_random_Rnd2(t_low,t_high){
	return bb_random_Rnd3(t_high-t_low)+t_low;
}
function bb_random_Rnd3(t_range){
	return bb_random_Rnd()*t_range;
}
function bb_list_List4(){
	Object.call(this);
	this.f__head=(bb_list_HeadNode4_new.call(new bb_list_HeadNode4));
}
function bb_list_List4_new(){
	return this;
}
bb_list_List4.prototype.m_AddLast4=function(t_data){
	return bb_list_Node4_new.call(new bb_list_Node4,this.f__head,this.f__head.f__pred,t_data);
}
function bb_list_List4_new2(t_data){
	var t_=t_data;
	var t_2=0;
	while(t_2<t_.length){
		var t_t=t_[t_2];
		t_2=t_2+1;
		this.m_AddLast4(t_t);
	}
	return this;
}
bb_list_List4.prototype.m_Clear=function(){
	this.f__head.f__succ=this.f__head;
	this.f__head.f__pred=this.f__head;
	return 0;
}
bb_list_List4.prototype.m_Count=function(){
	var t_n=0;
	var t_node=this.f__head.f__succ;
	while(t_node!=this.f__head){
		t_node=t_node.f__succ;
		t_n+=1;
	}
	return t_n;
}
bb_list_List4.prototype.m_ObjectEnumerator=function(){
	return bb_list_Enumerator3_new.call(new bb_list_Enumerator3,this);
}
bb_list_List4.prototype.m_ToArray=function(){
	var t_arr=new_number_array(this.m_Count());
	var t_i=0;
	var t_=this.m_ObjectEnumerator();
	while(t_.m_HasNext()){
		var t_t=t_.m_NextObject();
		t_arr[t_i]=t_t;
		t_i+=1;
	}
	return t_arr;
}
bb_list_List4.prototype.m_First=function(){
	return this.f__head.m_NextNode().f__data;
}
bb_list_List4.prototype.m_RemoveFirst=function(){
	var t_data=this.f__head.m_NextNode().f__data;
	this.f__head.f__succ.m_Remove2();
	return t_data;
}
bb_list_List4.prototype.m_Last=function(){
	return this.f__head.m_PrevNode().f__data;
}
bb_list_List4.prototype.m_RemoveLast=function(){
	var t_data=this.f__head.m_PrevNode().f__data;
	this.f__head.f__pred.m_Remove2();
	return t_data;
}
bb_list_List4.prototype.m_AddFirst2=function(t_data){
	return bb_list_Node4_new.call(new bb_list_Node4,this.f__head.f__succ,this.f__head,t_data);
}
function bb_list_IntList(){
	bb_list_List4.call(this);
}
bb_list_IntList.prototype=extend_class(bb_list_List4);
function bb_list_IntList_new(){
	bb_list_List4_new.call(this);
	return this;
}
function bb_list_Node4(){
	Object.call(this);
	this.f__succ=null;
	this.f__pred=null;
	this.f__data=0;
}
function bb_list_Node4_new(t_succ,t_pred,t_data){
	this.f__succ=t_succ;
	this.f__pred=t_pred;
	this.f__succ.f__pred=this;
	this.f__pred.f__succ=this;
	this.f__data=t_data;
	return this;
}
function bb_list_Node4_new2(){
	return this;
}
bb_list_Node4.prototype.m_GetNode=function(){
	return this;
}
bb_list_Node4.prototype.m_NextNode=function(){
	return this.f__succ.m_GetNode();
}
bb_list_Node4.prototype.m_Remove2=function(){
	this.f__succ.f__pred=this.f__pred;
	this.f__pred.f__succ=this.f__succ;
	return 0;
}
bb_list_Node4.prototype.m_PrevNode=function(){
	return this.f__pred.m_GetNode();
}
function bb_list_HeadNode4(){
	bb_list_Node4.call(this);
}
bb_list_HeadNode4.prototype=extend_class(bb_list_Node4);
function bb_list_HeadNode4_new(){
	bb_list_Node4_new2.call(this);
	this.f__succ=(this);
	this.f__pred=(this);
	return this;
}
bb_list_HeadNode4.prototype.m_GetNode=function(){
	return null;
}
function bb_set_Set(){
	Object.call(this);
	this.f_map=null;
}
function bb_set_Set_new(t_map){
	this.f_map=t_map;
	return this;
}
function bb_set_Set_new2(){
	return this;
}
bb_set_Set.prototype.m_Insert4=function(t_value){
	this.f_map.m_Insert5(t_value,null);
	return 0;
}
bb_set_Set.prototype.m_Count=function(){
	return this.f_map.m_Count();
}
bb_set_Set.prototype.m_Clear=function(){
	this.f_map.m_Clear();
	return 0;
}
bb_set_Set.prototype.m_Remove4=function(t_value){
	this.f_map.m_Remove4(t_value);
	return 0;
}
bb_set_Set.prototype.m_Contains2=function(t_value){
	return this.f_map.m_Contains2(t_value);
}
function bb_set_IntSet(){
	bb_set_Set.call(this);
}
bb_set_IntSet.prototype=extend_class(bb_set_Set);
function bb_set_IntSet_new(){
	bb_set_Set_new.call(this,(bb_map_IntMap_new.call(new bb_map_IntMap)));
	return this;
}
function bb_map_Map6(){
	Object.call(this);
	this.f_root=null;
}
function bb_map_Map6_new(){
	return this;
}
bb_map_Map6.prototype.m_Compare2=function(t_lhs,t_rhs){
}
bb_map_Map6.prototype.m_RotateLeft6=function(t_node){
	var t_child=t_node.f_right;
	t_node.f_right=t_child.f_left;
	if((t_child.f_left)!=null){
		t_child.f_left.f_parent=t_node;
	}
	t_child.f_parent=t_node.f_parent;
	if((t_node.f_parent)!=null){
		if(t_node==t_node.f_parent.f_left){
			t_node.f_parent.f_left=t_child;
		}else{
			t_node.f_parent.f_right=t_child;
		}
	}else{
		this.f_root=t_child;
	}
	t_child.f_left=t_node;
	t_node.f_parent=t_child;
	return 0;
}
bb_map_Map6.prototype.m_RotateRight6=function(t_node){
	var t_child=t_node.f_left;
	t_node.f_left=t_child.f_right;
	if((t_child.f_right)!=null){
		t_child.f_right.f_parent=t_node;
	}
	t_child.f_parent=t_node.f_parent;
	if((t_node.f_parent)!=null){
		if(t_node==t_node.f_parent.f_right){
			t_node.f_parent.f_right=t_child;
		}else{
			t_node.f_parent.f_left=t_child;
		}
	}else{
		this.f_root=t_child;
	}
	t_child.f_right=t_node;
	t_node.f_parent=t_child;
	return 0;
}
bb_map_Map6.prototype.m_InsertFixup6=function(t_node){
	while(((t_node.f_parent)!=null) && t_node.f_parent.f_color==-1 && ((t_node.f_parent.f_parent)!=null)){
		if(t_node.f_parent==t_node.f_parent.f_parent.f_left){
			var t_uncle=t_node.f_parent.f_parent.f_right;
			if(((t_uncle)!=null) && t_uncle.f_color==-1){
				t_node.f_parent.f_color=1;
				t_uncle.f_color=1;
				t_uncle.f_parent.f_color=-1;
				t_node=t_uncle.f_parent;
			}else{
				if(t_node==t_node.f_parent.f_right){
					t_node=t_node.f_parent;
					this.m_RotateLeft6(t_node);
				}
				t_node.f_parent.f_color=1;
				t_node.f_parent.f_parent.f_color=-1;
				this.m_RotateRight6(t_node.f_parent.f_parent);
			}
		}else{
			var t_uncle2=t_node.f_parent.f_parent.f_left;
			if(((t_uncle2)!=null) && t_uncle2.f_color==-1){
				t_node.f_parent.f_color=1;
				t_uncle2.f_color=1;
				t_uncle2.f_parent.f_color=-1;
				t_node=t_uncle2.f_parent;
			}else{
				if(t_node==t_node.f_parent.f_left){
					t_node=t_node.f_parent;
					this.m_RotateRight6(t_node);
				}
				t_node.f_parent.f_color=1;
				t_node.f_parent.f_parent.f_color=-1;
				this.m_RotateLeft6(t_node.f_parent.f_parent);
			}
		}
	}
	this.f_root.f_color=1;
	return 0;
}
bb_map_Map6.prototype.m_Set7=function(t_key,t_value){
	var t_node=this.f_root;
	var t_parent=null;
	var t_cmp=0;
	while((t_node)!=null){
		t_parent=t_node;
		t_cmp=this.m_Compare2(t_key,t_node.f_key);
		if(t_cmp>0){
			t_node=t_node.f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node.f_left;
			}else{
				t_node.f_value=t_value;
				return false;
			}
		}
	}
	t_node=bb_map_Node6_new.call(new bb_map_Node6,t_key,t_value,-1,t_parent);
	if((t_parent)!=null){
		if(t_cmp>0){
			t_parent.f_right=t_node;
		}else{
			t_parent.f_left=t_node;
		}
		this.m_InsertFixup6(t_node);
	}else{
		this.f_root=t_node;
	}
	return true;
}
bb_map_Map6.prototype.m_Insert5=function(t_key,t_value){
	return this.m_Set7(t_key,t_value);
}
bb_map_Map6.prototype.m_Count=function(){
	if((this.f_root)!=null){
		return this.f_root.m_Count2(0);
	}
	return 0;
}
bb_map_Map6.prototype.m_Clear=function(){
	this.f_root=null;
	return 0;
}
bb_map_Map6.prototype.m_FindNode2=function(t_key){
	var t_node=this.f_root;
	while((t_node)!=null){
		var t_cmp=this.m_Compare2(t_key,t_node.f_key);
		if(t_cmp>0){
			t_node=t_node.f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node.f_left;
			}else{
				return t_node;
			}
		}
	}
	return t_node;
}
bb_map_Map6.prototype.m_DeleteFixup=function(t_node,t_parent){
	while(t_node!=this.f_root && (!((t_node)!=null) || t_node.f_color==1)){
		if(t_node==t_parent.f_left){
			var t_sib=t_parent.f_right;
			if(t_sib.f_color==-1){
				t_sib.f_color=1;
				t_parent.f_color=-1;
				this.m_RotateLeft6(t_parent);
				t_sib=t_parent.f_right;
			}
			if((!((t_sib.f_left)!=null) || t_sib.f_left.f_color==1) && (!((t_sib.f_right)!=null) || t_sib.f_right.f_color==1)){
				t_sib.f_color=-1;
				t_node=t_parent;
				t_parent=t_parent.f_parent;
			}else{
				if(!((t_sib.f_right)!=null) || t_sib.f_right.f_color==1){
					t_sib.f_left.f_color=1;
					t_sib.f_color=-1;
					this.m_RotateRight6(t_sib);
					t_sib=t_parent.f_right;
				}
				t_sib.f_color=t_parent.f_color;
				t_parent.f_color=1;
				t_sib.f_right.f_color=1;
				this.m_RotateLeft6(t_parent);
				t_node=this.f_root;
			}
		}else{
			var t_sib2=t_parent.f_left;
			if(t_sib2.f_color==-1){
				t_sib2.f_color=1;
				t_parent.f_color=-1;
				this.m_RotateRight6(t_parent);
				t_sib2=t_parent.f_left;
			}
			if((!((t_sib2.f_right)!=null) || t_sib2.f_right.f_color==1) && (!((t_sib2.f_left)!=null) || t_sib2.f_left.f_color==1)){
				t_sib2.f_color=-1;
				t_node=t_parent;
				t_parent=t_parent.f_parent;
			}else{
				if(!((t_sib2.f_left)!=null) || t_sib2.f_left.f_color==1){
					t_sib2.f_right.f_color=1;
					t_sib2.f_color=-1;
					this.m_RotateLeft6(t_sib2);
					t_sib2=t_parent.f_left;
				}
				t_sib2.f_color=t_parent.f_color;
				t_parent.f_color=1;
				t_sib2.f_left.f_color=1;
				this.m_RotateRight6(t_parent);
				t_node=this.f_root;
			}
		}
	}
	if((t_node)!=null){
		t_node.f_color=1;
	}
	return 0;
}
bb_map_Map6.prototype.m_RemoveNode=function(t_node){
	var t_splice=null;
	var t_child=null;
	if(!((t_node.f_left)!=null)){
		t_splice=t_node;
		t_child=t_node.f_right;
	}else{
		if(!((t_node.f_right)!=null)){
			t_splice=t_node;
			t_child=t_node.f_left;
		}else{
			t_splice=t_node.f_left;
			while((t_splice.f_right)!=null){
				t_splice=t_splice.f_right;
			}
			t_child=t_splice.f_left;
			t_node.f_key=t_splice.f_key;
			t_node.f_value=t_splice.f_value;
		}
	}
	var t_parent=t_splice.f_parent;
	if((t_child)!=null){
		t_child.f_parent=t_parent;
	}
	if(!((t_parent)!=null)){
		this.f_root=t_child;
		return 0;
	}
	if(t_splice==t_parent.f_left){
		t_parent.f_left=t_child;
	}else{
		t_parent.f_right=t_child;
	}
	if(t_splice.f_color==1){
		this.m_DeleteFixup(t_child,t_parent);
	}
	return 0;
}
bb_map_Map6.prototype.m_Remove4=function(t_key){
	var t_node=this.m_FindNode2(t_key);
	if(!((t_node)!=null)){
		return 0;
	}
	this.m_RemoveNode(t_node);
	return 1;
}
bb_map_Map6.prototype.m_Contains2=function(t_key){
	return this.m_FindNode2(t_key)!=null;
}
function bb_map_IntMap(){
	bb_map_Map6.call(this);
}
bb_map_IntMap.prototype=extend_class(bb_map_Map6);
function bb_map_IntMap_new(){
	bb_map_Map6_new.call(this);
	return this;
}
bb_map_IntMap.prototype.m_Compare2=function(t_lhs,t_rhs){
	return t_lhs-t_rhs;
}
function bb_map_Node6(){
	Object.call(this);
	this.f_key=0;
	this.f_right=null;
	this.f_left=null;
	this.f_value=null;
	this.f_color=0;
	this.f_parent=null;
}
function bb_map_Node6_new(t_key,t_value,t_color,t_parent){
	this.f_key=t_key;
	this.f_value=t_value;
	this.f_color=t_color;
	this.f_parent=t_parent;
	return this;
}
function bb_map_Node6_new2(){
	return this;
}
bb_map_Node6.prototype.m_Count2=function(t_n){
	if((this.f_left)!=null){
		t_n=this.f_left.m_Count2(t_n);
	}
	if((this.f_right)!=null){
		t_n=this.f_right.m_Count2(t_n);
	}
	return t_n+1;
}
function bb_list_Enumerator3(){
	Object.call(this);
	this.f__list=null;
	this.f__curr=null;
}
function bb_list_Enumerator3_new(t_list){
	this.f__list=t_list;
	this.f__curr=t_list.f__head.f__succ;
	return this;
}
function bb_list_Enumerator3_new2(){
	return this;
}
bb_list_Enumerator3.prototype.m_HasNext=function(){
	while(this.f__curr.f__succ.f__pred!=this.f__curr){
		this.f__curr=this.f__curr.f__succ;
	}
	return this.f__curr!=this.f__list.f__head;
}
bb_list_Enumerator3.prototype.m_NextObject=function(){
	var t_data=this.f__curr.f__data;
	this.f__curr=this.f__curr.f__succ;
	return t_data;
}
function bb_textinput_TextInput(){
	bb_font_Font.call(this);
	this.f_cursorPos=0;
	this.implments={bb_positionable_Positionable:1,bb_sizeable_Sizeable:1,bb_directorevents_DirectorEvents:1};
}
bb_textinput_TextInput.prototype=extend_class(bb_font_Font);
function bb_textinput_TextInput_new(t_fontName,t_pos){
	bb_font_Font_new.call(this,t_fontName,t_pos);
	return this;
}
function bb_textinput_TextInput_new2(){
	bb_font_Font_new2.call(this);
	return this;
}
bb_textinput_TextInput.prototype.m_MoveCursorRight=function(){
	if(this.f_cursorPos>=this.m_text2().length){
		return;
	}
	this.f_cursorPos+=1;
}
bb_textinput_TextInput.prototype.m_InsertChar=function(t_char){
	this.m_text(this.m_text2().slice(0,this.f_cursorPos)+t_char+this.m_text2().slice(this.f_cursorPos,this.m_text2().length));
	this.m_MoveCursorRight();
}
bb_textinput_TextInput.prototype.m_MoveCursorLeft=function(){
	if(this.f_cursorPos<=0){
		return;
	}
	this.f_cursorPos-=1;
}
bb_textinput_TextInput.prototype.m_RemoveChar=function(){
	if(this.m_text2().length==0 || this.f_cursorPos==0){
		return;
	}
	this.m_text(this.m_text2().slice(0,this.f_cursorPos-1)+this.m_text2().slice(this.f_cursorPos,this.m_text2().length));
	this.m_MoveCursorLeft();
}
bb_textinput_TextInput.prototype.m_OnKeyUp=function(t_event){
	if(t_event.m_code()>31 && t_event.m_code()<127){
		this.m_InsertChar(t_event.m_char());
	}else{
		var t_1=t_event.m_code();
		if(t_1==8){
			this.m_RemoveChar();
		}else{
			if(t_1==65573){
				this.m_MoveCursorLeft();
			}else{
				if(t_1==65575){
					this.m_MoveCursorRight();
				}
			}
		}
	}
}
function bb_graphics_SetFont(t_font,t_firstChar){
	if(!((t_font)!=null)){
		if(!((bb_graphics_context.f_defaultFont)!=null)){
			bb_graphics_context.f_defaultFont=bb_graphics_LoadImage("mojo_font.png",96,2);
		}
		t_font=bb_graphics_context.f_defaultFont;
		t_firstChar=32;
	}
	bb_graphics_context.f_font=t_font;
	bb_graphics_context.f_firstChar=t_firstChar;
	return 0;
}
var bb_graphics_renderDevice;
function bb_graphics_SetMatrix(t_ix,t_iy,t_jx,t_jy,t_tx,t_ty){
	bb_graphics_context.f_ix=t_ix;
	bb_graphics_context.f_iy=t_iy;
	bb_graphics_context.f_jx=t_jx;
	bb_graphics_context.f_jy=t_jy;
	bb_graphics_context.f_tx=t_tx;
	bb_graphics_context.f_ty=t_ty;
	bb_graphics_context.f_tformed=((t_ix!=1.0 || t_iy!=0.0 || t_jx!=0.0 || t_jy!=1.0 || t_tx!=0.0 || t_ty!=0.0)?1:0);
	bb_graphics_context.f_matDirty=1;
	return 0;
}
function bb_graphics_SetMatrix2(t_m){
	bb_graphics_SetMatrix(t_m[0],t_m[1],t_m[2],t_m[3],t_m[4],t_m[5]);
	return 0;
}
function bb_graphics_SetColor(t_r,t_g,t_b){
	bb_graphics_context.f_color_r=t_r;
	bb_graphics_context.f_color_g=t_g;
	bb_graphics_context.f_color_b=t_b;
	bb_graphics_context.f_device.SetColor(t_r,t_g,t_b);
	return 0;
}
function bb_graphics_SetAlpha(t_alpha){
	bb_graphics_context.f_alpha=t_alpha;
	bb_graphics_context.f_device.SetAlpha(t_alpha);
	return 0;
}
function bb_graphics_SetBlend(t_blend){
	bb_graphics_context.f_blend=t_blend;
	bb_graphics_context.f_device.SetBlend(t_blend);
	return 0;
}
function bb_graphics_DeviceWidth(){
	return bb_graphics_context.f_device.Width();
}
function bb_graphics_DeviceHeight(){
	return bb_graphics_context.f_device.Height();
}
function bb_graphics_SetScissor(t_x,t_y,t_width,t_height){
	bb_graphics_context.f_scissor_x=t_x;
	bb_graphics_context.f_scissor_y=t_y;
	bb_graphics_context.f_scissor_width=t_width;
	bb_graphics_context.f_scissor_height=t_height;
	bb_graphics_context.f_device.SetScissor(((t_x)|0),((t_y)|0),((t_width)|0),((t_height)|0));
	return 0;
}
function bb_graphics_BeginRender(){
	if(!((bb_graphics_context.f_device.Mode())!=0)){
		return 0;
	}
	bb_graphics_renderDevice=bb_graphics_context.f_device;
	bb_graphics_context.f_matrixSp=0;
	bb_graphics_SetMatrix(1.0,0.0,0.0,1.0,0.0,0.0);
	bb_graphics_SetColor(255.0,255.0,255.0);
	bb_graphics_SetAlpha(1.0);
	bb_graphics_SetBlend(0);
	bb_graphics_SetScissor(0.0,0.0,(bb_graphics_DeviceWidth()),(bb_graphics_DeviceHeight()));
	return 0;
}
function bb_graphics_EndRender(){
	bb_graphics_renderDevice=null;
	return 0;
}
function bb_deltatimer_DeltaTimer(){
	Object.call(this);
	this.f_targetFps=.0;
	this.f_lastTicks=.0;
	this.f_currentTicks=.0;
	this.f__frameTime=.0;
	this.f__delta=.0;
}
function bb_deltatimer_DeltaTimer_new(t_fps){
	this.f_targetFps=t_fps;
	this.f_lastTicks=(bb_app_Millisecs());
	return this;
}
function bb_deltatimer_DeltaTimer_new2(){
	return this;
}
bb_deltatimer_DeltaTimer.prototype.m_frameTime=function(){
	return this.f__frameTime;
}
bb_deltatimer_DeltaTimer.prototype.m_OnUpdate2=function(){
	this.f_currentTicks=(bb_app_Millisecs());
	this.f__frameTime=this.f_currentTicks-this.f_lastTicks;
	this.f__delta=this.m_frameTime()/(1000.0/this.f_targetFps);
	this.f_lastTicks=this.f_currentTicks;
}
bb_deltatimer_DeltaTimer.prototype.m_delta=function(){
	return this.f__delta;
}
function bb_app_SetUpdateRate(t_hertz){
	return bb_app_device.SetUpdateRate(t_hertz);
}
function bb_input_TouchDown(t_index){
	return bb_input_device.KeyDown(384+t_index);
}
function bb_touchevent_TouchEvent(){
	Object.call(this);
	this.f__finger=0;
	this.f__startTime=0;
	this.f_positions=bb_list_List5_new.call(new bb_list_List5);
	this.f__endTime=0;
}
function bb_touchevent_TouchEvent_new(t_finger){
	this.f__finger=t_finger;
	this.f__startTime=bb_app_Millisecs();
	return this;
}
function bb_touchevent_TouchEvent_new2(){
	return this;
}
bb_touchevent_TouchEvent.prototype.m_startPos=function(){
	if(this.f_positions.m_Count()==0){
		return bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,0.0,0.0);
	}
	return this.f_positions.m_First();
}
bb_touchevent_TouchEvent.prototype.m_prevPos=function(){
	if(this.f_positions.m_Count()==0){
		return bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,0.0,0.0);
	}
	if(this.f_positions.m_Count()==1){
		return this.m_startPos();
	}
	return this.f_positions.m_LastNode().m_PrevNode().m_Value();
}
bb_touchevent_TouchEvent.prototype.m_Add2=function(t_pos){
	this.f__endTime=bb_app_Millisecs();
	if(this.m_prevPos().f_x==t_pos.f_x && this.m_prevPos().f_y==t_pos.f_y){
		return;
	}
	this.f_positions.m_AddLast5(t_pos);
}
bb_touchevent_TouchEvent.prototype.m_Trim=function(t_size){
	if(t_size==0){
		this.f_positions.m_Clear();
		return;
	}
	while(this.f_positions.m_Count()>t_size){
		this.f_positions.m_RemoveFirst();
	}
}
bb_touchevent_TouchEvent.prototype.m_pos=function(){
	if(this.f_positions.m_Count()==0){
		return bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,0.0,0.0);
	}
	return this.f_positions.m_Last();
}
bb_touchevent_TouchEvent.prototype.m_Copy=function(){
	var t_obj=bb_touchevent_TouchEvent_new.call(new bb_touchevent_TouchEvent,this.f__finger);
	t_obj.m_Add2(this.m_pos());
	return t_obj;
}
bb_touchevent_TouchEvent.prototype.m_startDelta=function(){
	return this.m_pos().m_Copy().m_Sub(this.m_startPos());
}
function bb_input_TouchX(t_index){
	return bb_input_device.TouchX(t_index);
}
function bb_input_TouchY(t_index){
	return bb_input_device.TouchY(t_index);
}
function bb_list_List5(){
	Object.call(this);
	this.f__head=(bb_list_HeadNode5_new.call(new bb_list_HeadNode5));
}
function bb_list_List5_new(){
	return this;
}
bb_list_List5.prototype.m_AddLast5=function(t_data){
	return bb_list_Node5_new.call(new bb_list_Node5,this.f__head,this.f__head.f__pred,t_data);
}
function bb_list_List5_new2(t_data){
	var t_=t_data;
	var t_2=0;
	while(t_2<t_.length){
		var t_t=t_[t_2];
		t_2=t_2+1;
		this.m_AddLast5(t_t);
	}
	return this;
}
bb_list_List5.prototype.m_Count=function(){
	var t_n=0;
	var t_node=this.f__head.f__succ;
	while(t_node!=this.f__head){
		t_node=t_node.f__succ;
		t_n+=1;
	}
	return t_n;
}
bb_list_List5.prototype.m_First=function(){
	return this.f__head.m_NextNode().f__data;
}
bb_list_List5.prototype.m_LastNode=function(){
	return this.f__head.m_PrevNode();
}
bb_list_List5.prototype.m_Clear=function(){
	this.f__head.f__succ=this.f__head;
	this.f__head.f__pred=this.f__head;
	return 0;
}
bb_list_List5.prototype.m_RemoveFirst=function(){
	var t_data=this.f__head.m_NextNode().f__data;
	this.f__head.f__succ.m_Remove2();
	return t_data;
}
bb_list_List5.prototype.m_Last=function(){
	return this.f__head.m_PrevNode().f__data;
}
function bb_list_Node5(){
	Object.call(this);
	this.f__succ=null;
	this.f__pred=null;
	this.f__data=null;
}
function bb_list_Node5_new(t_succ,t_pred,t_data){
	this.f__succ=t_succ;
	this.f__pred=t_pred;
	this.f__succ.f__pred=this;
	this.f__pred.f__succ=this;
	this.f__data=t_data;
	return this;
}
function bb_list_Node5_new2(){
	return this;
}
bb_list_Node5.prototype.m_GetNode=function(){
	return this;
}
bb_list_Node5.prototype.m_NextNode=function(){
	return this.f__succ.m_GetNode();
}
bb_list_Node5.prototype.m_PrevNode=function(){
	return this.f__pred.m_GetNode();
}
bb_list_Node5.prototype.m_Value=function(){
	return this.f__data;
}
bb_list_Node5.prototype.m_Remove2=function(){
	this.f__succ.f__pred=this.f__pred;
	this.f__pred.f__succ=this.f__succ;
	return 0;
}
function bb_list_HeadNode5(){
	bb_list_Node5.call(this);
}
bb_list_HeadNode5.prototype=extend_class(bb_list_Node5);
function bb_list_HeadNode5_new(){
	bb_list_Node5_new2.call(this);
	this.f__succ=(this);
	this.f__pred=(this);
	return this;
}
bb_list_HeadNode5.prototype.m_GetNode=function(){
	return null;
}
function bb_input_EnableKeyboard(){
	return bb_input_device.SetKeyboardEnabled(1);
}
function bb_input_GetChar(){
	return bb_input_device.GetChar();
}
function bb_keyevent_KeyEvent(){
	Object.call(this);
	this.f__code=0;
	this.f__char="";
}
function bb_keyevent_KeyEvent_new(t_code){
	this.f__code=t_code;
	this.f__char=String.fromCharCode(this.f__code);
	return this;
}
function bb_keyevent_KeyEvent_new2(){
	return this;
}
bb_keyevent_KeyEvent.prototype.m_code=function(){
	return this.f__code;
}
bb_keyevent_KeyEvent.prototype.m_char=function(){
	return this.f__char;
}
function bb_map_Map7(){
	Object.call(this);
	this.f_root=null;
}
function bb_map_Map7_new(){
	return this;
}
bb_map_Map7.prototype.m_Compare2=function(t_lhs,t_rhs){
}
bb_map_Map7.prototype.m_FindNode2=function(t_key){
	var t_node=this.f_root;
	while((t_node)!=null){
		var t_cmp=this.m_Compare2(t_key,t_node.f_key);
		if(t_cmp>0){
			t_node=t_node.f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node.f_left;
			}else{
				return t_node;
			}
		}
	}
	return t_node;
}
bb_map_Map7.prototype.m_Contains2=function(t_key){
	return this.m_FindNode2(t_key)!=null;
}
bb_map_Map7.prototype.m_RotateLeft7=function(t_node){
	var t_child=t_node.f_right;
	t_node.f_right=t_child.f_left;
	if((t_child.f_left)!=null){
		t_child.f_left.f_parent=t_node;
	}
	t_child.f_parent=t_node.f_parent;
	if((t_node.f_parent)!=null){
		if(t_node==t_node.f_parent.f_left){
			t_node.f_parent.f_left=t_child;
		}else{
			t_node.f_parent.f_right=t_child;
		}
	}else{
		this.f_root=t_child;
	}
	t_child.f_left=t_node;
	t_node.f_parent=t_child;
	return 0;
}
bb_map_Map7.prototype.m_RotateRight7=function(t_node){
	var t_child=t_node.f_left;
	t_node.f_left=t_child.f_right;
	if((t_child.f_right)!=null){
		t_child.f_right.f_parent=t_node;
	}
	t_child.f_parent=t_node.f_parent;
	if((t_node.f_parent)!=null){
		if(t_node==t_node.f_parent.f_right){
			t_node.f_parent.f_right=t_child;
		}else{
			t_node.f_parent.f_left=t_child;
		}
	}else{
		this.f_root=t_child;
	}
	t_child.f_right=t_node;
	t_node.f_parent=t_child;
	return 0;
}
bb_map_Map7.prototype.m_InsertFixup7=function(t_node){
	while(((t_node.f_parent)!=null) && t_node.f_parent.f_color==-1 && ((t_node.f_parent.f_parent)!=null)){
		if(t_node.f_parent==t_node.f_parent.f_parent.f_left){
			var t_uncle=t_node.f_parent.f_parent.f_right;
			if(((t_uncle)!=null) && t_uncle.f_color==-1){
				t_node.f_parent.f_color=1;
				t_uncle.f_color=1;
				t_uncle.f_parent.f_color=-1;
				t_node=t_uncle.f_parent;
			}else{
				if(t_node==t_node.f_parent.f_right){
					t_node=t_node.f_parent;
					this.m_RotateLeft7(t_node);
				}
				t_node.f_parent.f_color=1;
				t_node.f_parent.f_parent.f_color=-1;
				this.m_RotateRight7(t_node.f_parent.f_parent);
			}
		}else{
			var t_uncle2=t_node.f_parent.f_parent.f_left;
			if(((t_uncle2)!=null) && t_uncle2.f_color==-1){
				t_node.f_parent.f_color=1;
				t_uncle2.f_color=1;
				t_uncle2.f_parent.f_color=-1;
				t_node=t_uncle2.f_parent;
			}else{
				if(t_node==t_node.f_parent.f_left){
					t_node=t_node.f_parent;
					this.m_RotateRight7(t_node);
				}
				t_node.f_parent.f_color=1;
				t_node.f_parent.f_parent.f_color=-1;
				this.m_RotateLeft7(t_node.f_parent.f_parent);
			}
		}
	}
	this.f_root.f_color=1;
	return 0;
}
bb_map_Map7.prototype.m_Add6=function(t_key,t_value){
	var t_node=this.f_root;
	var t_parent=null;
	var t_cmp=0;
	while((t_node)!=null){
		t_parent=t_node;
		t_cmp=this.m_Compare2(t_key,t_node.f_key);
		if(t_cmp>0){
			t_node=t_node.f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node.f_left;
			}else{
				return false;
			}
		}
	}
	t_node=bb_map_Node7_new.call(new bb_map_Node7,t_key,t_value,-1,t_parent);
	if((t_parent)!=null){
		if(t_cmp>0){
			t_parent.f_right=t_node;
		}else{
			t_parent.f_left=t_node;
		}
		this.m_InsertFixup7(t_node);
	}else{
		this.f_root=t_node;
	}
	return true;
}
bb_map_Map7.prototype.m_Values=function(){
	return bb_map_MapValues_new.call(new bb_map_MapValues,this);
}
bb_map_Map7.prototype.m_FirstNode=function(){
	if(!((this.f_root)!=null)){
		return null;
	}
	var t_node=this.f_root;
	while((t_node.f_left)!=null){
		t_node=t_node.f_left;
	}
	return t_node;
}
bb_map_Map7.prototype.m_DeleteFixup2=function(t_node,t_parent){
	while(t_node!=this.f_root && (!((t_node)!=null) || t_node.f_color==1)){
		if(t_node==t_parent.f_left){
			var t_sib=t_parent.f_right;
			if(t_sib.f_color==-1){
				t_sib.f_color=1;
				t_parent.f_color=-1;
				this.m_RotateLeft7(t_parent);
				t_sib=t_parent.f_right;
			}
			if((!((t_sib.f_left)!=null) || t_sib.f_left.f_color==1) && (!((t_sib.f_right)!=null) || t_sib.f_right.f_color==1)){
				t_sib.f_color=-1;
				t_node=t_parent;
				t_parent=t_parent.f_parent;
			}else{
				if(!((t_sib.f_right)!=null) || t_sib.f_right.f_color==1){
					t_sib.f_left.f_color=1;
					t_sib.f_color=-1;
					this.m_RotateRight7(t_sib);
					t_sib=t_parent.f_right;
				}
				t_sib.f_color=t_parent.f_color;
				t_parent.f_color=1;
				t_sib.f_right.f_color=1;
				this.m_RotateLeft7(t_parent);
				t_node=this.f_root;
			}
		}else{
			var t_sib2=t_parent.f_left;
			if(t_sib2.f_color==-1){
				t_sib2.f_color=1;
				t_parent.f_color=-1;
				this.m_RotateRight7(t_parent);
				t_sib2=t_parent.f_left;
			}
			if((!((t_sib2.f_right)!=null) || t_sib2.f_right.f_color==1) && (!((t_sib2.f_left)!=null) || t_sib2.f_left.f_color==1)){
				t_sib2.f_color=-1;
				t_node=t_parent;
				t_parent=t_parent.f_parent;
			}else{
				if(!((t_sib2.f_left)!=null) || t_sib2.f_left.f_color==1){
					t_sib2.f_right.f_color=1;
					t_sib2.f_color=-1;
					this.m_RotateLeft7(t_sib2);
					t_sib2=t_parent.f_left;
				}
				t_sib2.f_color=t_parent.f_color;
				t_parent.f_color=1;
				t_sib2.f_left.f_color=1;
				this.m_RotateRight7(t_parent);
				t_node=this.f_root;
			}
		}
	}
	if((t_node)!=null){
		t_node.f_color=1;
	}
	return 0;
}
bb_map_Map7.prototype.m_RemoveNode2=function(t_node){
	var t_splice=null;
	var t_child=null;
	if(!((t_node.f_left)!=null)){
		t_splice=t_node;
		t_child=t_node.f_right;
	}else{
		if(!((t_node.f_right)!=null)){
			t_splice=t_node;
			t_child=t_node.f_left;
		}else{
			t_splice=t_node.f_left;
			while((t_splice.f_right)!=null){
				t_splice=t_splice.f_right;
			}
			t_child=t_splice.f_left;
			t_node.f_key=t_splice.f_key;
			t_node.f_value=t_splice.f_value;
		}
	}
	var t_parent=t_splice.f_parent;
	if((t_child)!=null){
		t_child.f_parent=t_parent;
	}
	if(!((t_parent)!=null)){
		this.f_root=t_child;
		return 0;
	}
	if(t_splice==t_parent.f_left){
		t_parent.f_left=t_child;
	}else{
		t_parent.f_right=t_child;
	}
	if(t_splice.f_color==1){
		this.m_DeleteFixup2(t_child,t_parent);
	}
	return 0;
}
bb_map_Map7.prototype.m_Remove4=function(t_key){
	var t_node=this.m_FindNode2(t_key);
	if(!((t_node)!=null)){
		return 0;
	}
	this.m_RemoveNode2(t_node);
	return 1;
}
bb_map_Map7.prototype.m_Clear=function(){
	this.f_root=null;
	return 0;
}
function bb_map_IntMap2(){
	bb_map_Map7.call(this);
}
bb_map_IntMap2.prototype=extend_class(bb_map_Map7);
function bb_map_IntMap2_new(){
	bb_map_Map7_new.call(this);
	return this;
}
bb_map_IntMap2.prototype.m_Compare2=function(t_lhs,t_rhs){
	return t_lhs-t_rhs;
}
function bb_map_Node7(){
	Object.call(this);
	this.f_key=0;
	this.f_right=null;
	this.f_left=null;
	this.f_value=null;
	this.f_color=0;
	this.f_parent=null;
}
function bb_map_Node7_new(t_key,t_value,t_color,t_parent){
	this.f_key=t_key;
	this.f_value=t_value;
	this.f_color=t_color;
	this.f_parent=t_parent;
	return this;
}
function bb_map_Node7_new2(){
	return this;
}
bb_map_Node7.prototype.m_NextNode=function(){
	var t_node=null;
	if((this.f_right)!=null){
		t_node=this.f_right;
		while((t_node.f_left)!=null){
			t_node=t_node.f_left;
		}
		return t_node;
	}
	t_node=this;
	var t_parent=this.f_parent;
	while(((t_parent)!=null) && t_node==t_parent.f_right){
		t_node=t_parent;
		t_parent=t_parent.f_parent;
	}
	return t_parent;
}
function bb_map_MapValues(){
	Object.call(this);
	this.f_map=null;
}
function bb_map_MapValues_new(t_map){
	this.f_map=t_map;
	return this;
}
function bb_map_MapValues_new2(){
	return this;
}
bb_map_MapValues.prototype.m_ObjectEnumerator=function(){
	return bb_map_ValueEnumerator_new.call(new bb_map_ValueEnumerator,this.f_map.m_FirstNode());
}
function bb_map_ValueEnumerator(){
	Object.call(this);
	this.f_node=null;
}
function bb_map_ValueEnumerator_new(t_node){
	this.f_node=t_node;
	return this;
}
function bb_map_ValueEnumerator_new2(){
	return this;
}
bb_map_ValueEnumerator.prototype.m_HasNext=function(){
	return this.f_node!=null;
}
bb_map_ValueEnumerator.prototype.m_NextObject=function(){
	var t_t=this.f_node;
	this.f_node=this.f_node.m_NextNode();
	return t_t.f_value;
}
function bb_input_DisableKeyboard(){
	return bb_input_device.SetKeyboardEnabled(0);
}
function bb_graphics_PushMatrix(){
	var t_sp=bb_graphics_context.f_matrixSp;
	bb_graphics_context.f_matrixStack[t_sp+0]=bb_graphics_context.f_ix;
	bb_graphics_context.f_matrixStack[t_sp+1]=bb_graphics_context.f_iy;
	bb_graphics_context.f_matrixStack[t_sp+2]=bb_graphics_context.f_jx;
	bb_graphics_context.f_matrixStack[t_sp+3]=bb_graphics_context.f_jy;
	bb_graphics_context.f_matrixStack[t_sp+4]=bb_graphics_context.f_tx;
	bb_graphics_context.f_matrixStack[t_sp+5]=bb_graphics_context.f_ty;
	bb_graphics_context.f_matrixSp=t_sp+6;
	return 0;
}
function bb_graphics_Transform(t_ix,t_iy,t_jx,t_jy,t_tx,t_ty){
	var t_ix2=t_ix*bb_graphics_context.f_ix+t_iy*bb_graphics_context.f_jx;
	var t_iy2=t_ix*bb_graphics_context.f_iy+t_iy*bb_graphics_context.f_jy;
	var t_jx2=t_jx*bb_graphics_context.f_ix+t_jy*bb_graphics_context.f_jx;
	var t_jy2=t_jx*bb_graphics_context.f_iy+t_jy*bb_graphics_context.f_jy;
	var t_tx2=t_tx*bb_graphics_context.f_ix+t_ty*bb_graphics_context.f_jx+bb_graphics_context.f_tx;
	var t_ty2=t_tx*bb_graphics_context.f_iy+t_ty*bb_graphics_context.f_jy+bb_graphics_context.f_ty;
	bb_graphics_SetMatrix(t_ix2,t_iy2,t_jx2,t_jy2,t_tx2,t_ty2);
	return 0;
}
function bb_graphics_Transform2(t_m){
	bb_graphics_Transform(t_m[0],t_m[1],t_m[2],t_m[3],t_m[4],t_m[5]);
	return 0;
}
function bb_graphics_Scale(t_x,t_y){
	bb_graphics_Transform(t_x,0.0,0.0,t_y,0.0,0.0);
	return 0;
}
function bb_graphics_Cls(t_r,t_g,t_b){
	bb_graphics_renderDevice.Cls(t_r,t_g,t_b);
	return 0;
}
function bb_graphics_PopMatrix(){
	var t_sp=bb_graphics_context.f_matrixSp-6;
	bb_graphics_SetMatrix(bb_graphics_context.f_matrixStack[t_sp+0],bb_graphics_context.f_matrixStack[t_sp+1],bb_graphics_context.f_matrixStack[t_sp+2],bb_graphics_context.f_matrixStack[t_sp+3],bb_graphics_context.f_matrixStack[t_sp+4],bb_graphics_context.f_matrixStack[t_sp+5]);
	bb_graphics_context.f_matrixSp=t_sp;
	return 0;
}
function bb_graphics_Translate(t_x,t_y){
	bb_graphics_Transform(1.0,0.0,0.0,1.0,t_x,t_y);
	return 0;
}
function bb_graphics_ValidateMatrix(){
	if((bb_graphics_context.f_matDirty)!=0){
		bb_graphics_context.f_device.SetMatrix(bb_graphics_context.f_ix,bb_graphics_context.f_iy,bb_graphics_context.f_jx,bb_graphics_context.f_jy,bb_graphics_context.f_tx,bb_graphics_context.f_ty);
		bb_graphics_context.f_matDirty=0;
	}
	return 0;
}
function bb_graphics_DrawImage(t_image,t_x,t_y,t_frame){
	var t_f=t_image.f_frames[t_frame];
	if((bb_graphics_context.f_tformed)!=0){
		bb_graphics_PushMatrix();
		bb_graphics_Translate(t_x-t_image.f_tx,t_y-t_image.f_ty);
		bb_graphics_ValidateMatrix();
		if((t_image.f_flags&65536)!=0){
			bb_graphics_context.f_device.DrawSurface(t_image.f_surface,0.0,0.0);
		}else{
			bb_graphics_context.f_device.DrawSurface2(t_image.f_surface,0.0,0.0,t_f.f_x,t_f.f_y,t_image.f_width,t_image.f_height);
		}
		bb_graphics_PopMatrix();
	}else{
		bb_graphics_ValidateMatrix();
		if((t_image.f_flags&65536)!=0){
			bb_graphics_context.f_device.DrawSurface(t_image.f_surface,t_x-t_image.f_tx,t_y-t_image.f_ty);
		}else{
			bb_graphics_context.f_device.DrawSurface2(t_image.f_surface,t_x-t_image.f_tx,t_y-t_image.f_ty,t_f.f_x,t_f.f_y,t_image.f_width,t_image.f_height);
		}
	}
	return 0;
}
function bb_graphics_Rotate(t_angle){
	bb_graphics_Transform(Math.cos((t_angle)*D2R),-Math.sin((t_angle)*D2R),Math.sin((t_angle)*D2R),Math.cos((t_angle)*D2R),0.0,0.0);
	return 0;
}
function bb_graphics_DrawImage2(t_image,t_x,t_y,t_rotation,t_scaleX,t_scaleY,t_frame){
	var t_f=t_image.f_frames[t_frame];
	bb_graphics_PushMatrix();
	bb_graphics_Translate(t_x,t_y);
	bb_graphics_Rotate(t_rotation);
	bb_graphics_Scale(t_scaleX,t_scaleY);
	bb_graphics_Translate(-t_image.f_tx,-t_image.f_ty);
	bb_graphics_ValidateMatrix();
	if((t_image.f_flags&65536)!=0){
		bb_graphics_context.f_device.DrawSurface(t_image.f_surface,0.0,0.0);
	}else{
		bb_graphics_context.f_device.DrawSurface2(t_image.f_surface,0.0,0.0,t_f.f_x,t_f.f_y,t_image.f_width,t_image.f_height);
	}
	bb_graphics_PopMatrix();
	return 0;
}
function bb_graphics_DrawRect(t_x,t_y,t_w,t_h){
	bb_graphics_ValidateMatrix();
	bb_graphics_renderDevice.DrawRect(t_x,t_y,t_w,t_h);
	return 0;
}
function bb_color_Color(){
	Object.call(this);
	this.f_oldColor=null;
	this.f_red=.0;
	this.f_green=.0;
	this.f_blue=.0;
	this.f_alpha=.0;
}
function bb_color_Color_new(t_red,t_green,t_blue,t_alpha){
	this.f_red=t_red;
	this.f_green=t_green;
	this.f_blue=t_blue;
	this.f_alpha=t_alpha;
	return this;
}
function bb_color_Color_new2(){
	return this;
}
bb_color_Color.prototype.m_Set8=function(t_color){
	bb_graphics_SetColor(t_color.f_red,t_color.f_green,t_color.f_blue);
	bb_graphics_SetAlpha(t_color.f_alpha);
}
bb_color_Color.prototype.m_Activate=function(){
	if(!((this.f_oldColor)!=null)){
		this.f_oldColor=bb_color_Color_new.call(new bb_color_Color,0.0,0.0,0.0,0.0);
	}
	var t_colorStack=bb_graphics_GetColor();
	this.f_oldColor.f_red=t_colorStack[0];
	this.f_oldColor.f_green=t_colorStack[1];
	this.f_oldColor.f_blue=t_colorStack[2];
	this.f_oldColor.f_alpha=bb_graphics_GetAlpha();
	this.m_Set8(this);
}
bb_color_Color.prototype.m_Deactivate=function(){
	if((this.f_oldColor)!=null){
		this.m_Set8(this.f_oldColor);
	}
}
function bb_graphics_GetColor(){
	return [bb_graphics_context.f_color_r,bb_graphics_context.f_color_g,bb_graphics_context.f_color_b];
}
function bb_graphics_GetAlpha(){
	return bb_graphics_context.f_alpha;
}
function bb_graphics_DrawImageRect(t_image,t_x,t_y,t_srcX,t_srcY,t_srcWidth,t_srcHeight,t_frame){
	var t_f=t_image.f_frames[t_frame];
	if((bb_graphics_context.f_tformed)!=0){
		bb_graphics_PushMatrix();
		bb_graphics_Translate(-t_image.f_tx+t_x,-t_image.f_ty+t_y);
		bb_graphics_ValidateMatrix();
		bb_graphics_context.f_device.DrawSurface2(t_image.f_surface,0.0,0.0,t_srcX+t_f.f_x,t_srcY+t_f.f_y,t_srcWidth,t_srcHeight);
		bb_graphics_PopMatrix();
	}else{
		bb_graphics_ValidateMatrix();
		bb_graphics_context.f_device.DrawSurface2(t_image.f_surface,-t_image.f_tx+t_x,-t_image.f_ty+t_y,t_srcX+t_f.f_x,t_srcY+t_f.f_y,t_srcWidth,t_srcHeight);
	}
	return 0;
}
function bb_graphics_DrawImageRect2(t_image,t_x,t_y,t_srcX,t_srcY,t_srcWidth,t_srcHeight,t_rotation,t_scaleX,t_scaleY,t_frame){
	var t_f=t_image.f_frames[t_frame];
	bb_graphics_PushMatrix();
	bb_graphics_Translate(t_x,t_y);
	bb_graphics_Rotate(t_rotation);
	bb_graphics_Scale(t_scaleX,t_scaleY);
	bb_graphics_Translate(-t_image.f_tx,-t_image.f_ty);
	bb_graphics_ValidateMatrix();
	bb_graphics_context.f_device.DrawSurface2(t_image.f_surface,0.0,0.0,t_srcX+t_f.f_x,t_srcY+t_f.f_y,t_srcWidth,t_srcHeight);
	bb_graphics_PopMatrix();
	return 0;
}
function bb_math_Min(t_x,t_y){
	if(t_x<t_y){
		return t_x;
	}
	return t_y;
}
function bb_math_Min2(t_x,t_y){
	if(t_x<t_y){
		return t_x;
	}
	return t_y;
}
function bb_shape_Shape(){
	bb_baseobject_BaseObject.call(this);
	this.f_type=0;
	this.f_lane=0;
	this.f_chute=null;
	this.f_isFast=false;
	this.implments={bb_positionable_Positionable:1,bb_sizeable_Sizeable:1,bb_directorevents_DirectorEvents:1};
}
bb_shape_Shape.prototype=extend_class(bb_baseobject_BaseObject);
var bb_shape_Shape_images;
var bb_shape_Shape_SPEED_SLOW;
var bb_shape_Shape_SPEED_FAST;
function bb_shape_Shape_new(t_type,t_lane,t_chute){
	bb_baseobject_BaseObject_new.call(this);
	this.f_type=t_type;
	this.f_lane=t_lane;
	this.f_chute=t_chute;
	if(bb_shape_Shape_images.length==0){
		bb_shape_Shape_images=[bb_graphics_LoadImage("circle_inside.png",1,bb_graphics_Image_DefaultFlags),bb_graphics_LoadImage("plus_inside.png",1,bb_graphics_Image_DefaultFlags),bb_graphics_LoadImage("star_inside.png",1,bb_graphics_Image_DefaultFlags),bb_graphics_LoadImage("tire_inside.png",1,bb_graphics_Image_DefaultFlags)];
	}
	var t_posX=(46+bb_shape_Shape_images[0].m_Width()*t_lane);
	var t_posY=(t_chute.m_Height()-bb_shape_Shape_images[t_type].m_Height());
	this.m_pos2(bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,t_posX,t_posY));
	if(!((bb_shape_Shape_SPEED_SLOW)!=null)){
		bb_shape_Shape_SPEED_SLOW=bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,0.0,3.0);
	}
	if(!((bb_shape_Shape_SPEED_FAST)!=null)){
		bb_shape_Shape_SPEED_FAST=bb_vector2d_Vector2D_new.call(new bb_vector2d_Vector2D,0.0,10.0);
	}
	return this;
}
function bb_shape_Shape_new2(){
	bb_baseobject_BaseObject_new.call(this);
	return this;
}
bb_shape_Shape.prototype.m_OnUpdate=function(t_delta,t_frameTime){
	if(this.f_isFast){
		this.m_pos().m_Add2(bb_shape_Shape_SPEED_FAST.m_Copy().m_Mul2(t_delta));
	}else{
		this.m_pos().m_Add2(bb_shape_Shape_SPEED_SLOW.m_Copy().m_Mul2(t_delta));
	}
}
bb_shape_Shape.prototype.m_OnRender=function(){
	bb_graphics_DrawImage(bb_shape_Shape_images[this.f_type],this.m_pos().f_x,this.m_pos().f_y,0);
}
function bb_stack_Stack2(){
	Object.call(this);
	this.f_data=[];
	this.f_length=0;
}
function bb_stack_Stack2_new(){
	return this;
}
function bb_stack_Stack2_new2(t_data){
	this.f_data=t_data.slice(0);
	this.f_length=t_data.length;
	return this;
}
bb_stack_Stack2.prototype.m_Length=function(){
	return this.f_length;
}
bb_stack_Stack2.prototype.m_Pop=function(){
	this.f_length-=1;
	return this.f_data[this.f_length];
}
bb_stack_Stack2.prototype.m_Push2=function(t_value){
	if(this.f_length==this.f_data.length){
		this.f_data=resize_object_array(this.f_data,this.f_length*2+10);
	}
	this.f_data[this.f_length]=t_value;
	this.f_length+=1;
	return 0;
}
function bb_math_Max(t_x,t_y){
	if(t_x>t_y){
		return t_x;
	}
	return t_y;
}
function bb_math_Max2(t_x,t_y){
	if(t_x>t_y){
		return t_x;
	}
	return t_y;
}
function bb_math_Abs(t_x){
	if(t_x>=0){
		return t_x;
	}
	return -t_x;
}
function bb_math_Abs2(t_x){
	if(t_x>=0.0){
		return t_x;
	}
	return -t_x;
}
function bb_app_SaveState(t_state){
	return bb_app_device.SaveState(t_state);
}
function bbInit(){
	bb_graphics_context=null;
	bb_input_device=null;
	bb_audio_device=null;
	bb_app_device=null;
	bb_graphics_Image_DefaultFlags=256;
	bb_angelfont2_AngelFont_error="";
	bb_angelfont2_AngelFont_current=null;
	bb_angelfont2_AngelFont__list=bb_map_StringMap4_new.call(new bb_map_StringMap4);
	bb_gamehighscore_GameHighscore_names=[];
	bb_gamehighscore_GameHighscore_scores=[];
	bb_severity_globalSeverityInstance=null;
	bb_random_Seed=1234;
	bb_graphics_renderDevice=null;
	bb_angelfont_AngelFont_error="";
	bb_angelfont_AngelFont_current=null;
	bb_angelfont_AngelFont__list=bb_map_StringMap5_new.call(new bb_map_StringMap5);
	bb_shape_Shape_images=[];
	bb_shape_Shape_SPEED_SLOW=null;
	bb_shape_Shape_SPEED_FAST=null;
}
//${TRANSCODE_END}
