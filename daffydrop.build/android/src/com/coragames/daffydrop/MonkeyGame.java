
//${PACKAGE_BEGIN}
package com.coragames.daffydrop;
//${PACKAGE_END}

//${IMPORTS_BEGIN}
import java.lang.Math;
import java.lang.reflect.Array;
import java.util.Vector;
import java.text.NumberFormat;
import java.text.ParseException;
import java.io.*;
import java.nio.*;
import java.util.*;
import java.lang.reflect.*;
import android.os.*;
import android.app.*;
import android.media.*;
import android.view.*;
import android.graphics.*;
import android.content.*;
import android.util.*;
import android.hardware.*;
import android.view.inputmethod.*;
import android.opengl.*;
import javax.microedition.khronos.opengles.GL10;
import javax.microedition.khronos.egl.EGLConfig;
import android.content.res.AssetManager;
import com.payment.BillingService.RequestPurchase;
import com.payment.BillingService.RestoreTransactions;
import com.payment.Consts.PurchaseState;
import com.payment.Consts;
import com.payment.Consts.ResponseCode;
import com.payment.PurchaseObserver;
import com.payment.ResponseHandler;
import com.payment.PurchaseDatabase;
import android.database.Cursor;
//${IMPORTS_END}

class MonkeyConfig{
//${CONFIG_BEGIN}
static final String ANDROID_APP_LABEL="DaffyDrop";
static final String ANDROID_APP_PACKAGE="com.coragames.daffydrop";
static final String ANDROID_NATIVE_GL_ENABLED="true";
static final String ANDROID_SCREEN_ORIENTATION="portrait";
static final String ANDROID_SDK_DIR="/Volumes/Daten/Users/michaelcontento/android-sdk-macosx";
static final String CONFIG="release";
static final String GLFW_WINDOW_HEIGHT="960";
static final String GLFW_WINDOW_WIDTH="640";
static final String HOST="macos";
static final String IMAGE_FILES="*.png|*.jpg|*.gif|*.bmp";
static final String IOS_ACCELEROMETER_ENABLED="false";
static final String IOS_DISPLAY_LINK_ENABLED="true";
static final String IOS_RETINA_ENABLED="true";
static final String LANG="java";
static final String MOJO_HICOLOR_TEXTURES="true";
static final String MOJO_IMAGE_FILTERING_ENABLED="true";
static final String MUSIC_FILES="*.wav|*.ogg|*.mp3|*.m4a";
static final String OPENGL_GLES20_ENABLED="false";
static final String PARSER_FUNC_ATTRS="0";
static final String SOUND_FILES="*.wav|*.ogg|*.mp3|*.m4a";
static final String TARGET="android";
static final String TEXT_FILES="*.txt|*.xml|*.json";
//${CONFIG_END}
}

class MonkeyData{

	static AssetManager getAssets(){
		return MonkeyGame.activity.getAssets();
	}

	static String toString( byte[] buf ){
		int n=buf.length;
		char tmp[]=new char[n];
		for( int i=0;i<n;++i ){
			tmp[i]=(char)(buf[i] & 0xff);
		}
		return new String( tmp );
	}
	
	static String loadString( byte[] buf ){
	
		int n=buf.length;
		if( n<3 ) return toString( buf );
		
		StringBuilder out=new StringBuilder();
		
		int i=0;
		int cc=buf[i++] & 0xff;
		int dd=buf[i++] & 0xff;
		
		if( cc==0xfe && dd==0xff ){
			while( i<n-1 ){
				int x=buf[i++] & 0xff;
				int y=buf[i++] & 0xff;
				out.append( (char)((x<<8)|y) ); 
			}
		}else if( cc==0xff && dd==0xfe ){
			while( i<n-1 ){
				int x=buf[i++] & 0xff;
				int y=buf[i++] & 0xff;
				out.append( (char)((y<<8)|x) ); 
			}
		}else{
			int ee=buf[i++] & 0xff;
			if( cc!=0xef || dd!=0xbb || ee!=0xbf ) return toString( buf );
			while( i<n ){
				int c=buf[i++] & 0xff;
				if( c>=128 && i<n ){
					int d=buf[i++] & 0xff;
					if( c>=224 && i<n ){
						int e=buf[i++] & 0xff;
						if( c>=240 ) break;
						c=(c-224)*4096+(d-128)*64+(e-128);
					}else{
						c=(c-192)*64+(d-128);
					}
				}
				out.append( (char)c );
			}
		}
		return out.toString();
	}

	static String loadString( String path ){
		path="monkey/"+path;
		
		try{
			InputStream stream=getAssets().open( path );
			ByteArrayOutputStream buf=new ByteArrayOutputStream();

			int n;
			byte[] tmp=new byte[4096];

			while( (n=stream.read( tmp,0,tmp.length) )!=-1 ){
				buf.write( tmp,0,n );
			}

			buf.flush();
			stream.close();

			return loadString( buf.toByteArray() );
			
//			This doesn't appear to handle BOMs:
//			return new String( buf.toByteArray() );	

		}catch( IOException e ){
		}
		return "";		
	}

	static Bitmap loadBitmap( String path ){
		path="monkey/"+path;

		try{
			BitmapFactory.Options opts = new BitmapFactory.Options(); 
			opts.inPurgeable=true; 
			return BitmapFactory.decodeStream( getAssets().open( path ),null,opts );
		}catch( IOException e ){
		}
		return null;
	}

	static int loadSound( String path,SoundPool pool ){
		path="monkey/"+path;

		try{
			return pool.load( getAssets().openFd( path ),1 );
		}catch( IOException e ){
		}
		return 0;
	}
	
	static MediaPlayer openMedia( String path ){
		path="monkey/"+path;

		try{
			android.content.res.AssetFileDescriptor afd=getAssets().openFd( path );

			MediaPlayer mp=new MediaPlayer();
			mp.setDataSource( afd.getFileDescriptor(),afd.getStartOffset(),afd.getLength() );
			mp.prepare();
			
			afd.close();
			return mp;
		}catch( IOException e ){
		}
		return null;
	}

}

//${TRANSCODE_BEGIN}

// Java Monkey runtime.
//
// Placed into the public domain 24/02/2011.
// No warranty implied; use at your own risk.



class bb_std_lang{

	//***** Error handling *****

	static String errInfo="";
	static Vector errStack=new Vector();
	
	static float D2R=0.017453292519943295f;
	static float R2D=57.29577951308232f;
	
	static NumberFormat numberFormat=NumberFormat.getInstance();
	
	static void pushErr(){
		errStack.addElement( errInfo );
	}
	
	static void popErr(){
		if( errStack.size()==0 ) throw new Error( "STACK ERROR!" );
		errInfo=(String)errStack.remove( errStack.size()-1 );
	}
	
	static String stackTrace(){
		if( errInfo.length()==0 ) return "";
		String str=errInfo+"\n";
		for( int i=errStack.size()-1;i>0;--i ){
			str+=(String)errStack.elementAt(i)+"\n";
		}
		return str;
	}
	
	static int print( String str ){
		System.out.println( str );
		return 0;
	}
	
	static int error( String str ){
		throw new Error( str );
	}
	
	static String makeError( String err ){
		if( err.length()==0 ) return "";
		return "Monkey Runtime Error : "+err+"\n\n"+stackTrace();
	}
	
	static int debugLog( String str ){
		print( str );
		return 0;
	}
	
	static int debugStop(){
		error( "STOP" );
		return 0;
	}
	
	//***** String stuff *****

	static public String[] stringArray( int n ){
		String[] t=new String[n];
		for( int i=0;i<n;++i ) t[i]="";
		return t;
	}
	
	static String slice( String str,int from ){
		return slice( str,from,str.length() );
	}
	
	static String slice( String str,int from,int term ){
		int len=str.length();
		if( from<0 ){
			from+=len;
			if( from<0 ) from=0;
		}else if( from>len ){
			from=len;
		}
		if( term<0 ){
			term+=len;
		}else if( term>len ){
			term=len;
		}
		if( term>from ) return str.substring( from,term );
		return "";
	}
	
	static public String[] split( String str,String sep ){
		if( sep.length()==0 ){
			String[] bits=new String[str.length()];
			for( int i=0;i<str.length();++i){
				bits[i]=String.valueOf( str.charAt(i) );
			}
			return bits;
		}else{
			int i=0,i2,n=1;
			while( (i2=str.indexOf( sep,i ))!=-1 ){
				++n;
				i=i2+sep.length();
			}
			String[] bits=new String[n];
			i=0;
			for( int j=0;j<n;++j ){
				i2=str.indexOf( sep,i );
				if( i2==-1 ) i2=str.length();
				bits[j]=slice( str,i,i2 );
				i=i2+sep.length();
			}
			return bits;
		}
	}
	
	static public String join( String sep,String[] bits ){
		if( bits.length<2 ) return bits.length==1 ? bits[0] : "";
		StringBuilder buf=new StringBuilder( bits[0] );
		boolean hasSep=sep.length()>0;
		for( int i=1;i<bits.length;++i ){
			if( hasSep ) buf.append( sep );
			buf.append( bits[i] );
		}
		return buf.toString();
	}
	
	static public String replace( String str,String find,String rep ){
		int i=0;
		for(;;){
			i=str.indexOf( find,i );
			if( i==-1 ) return str;
			str=str.substring( 0,i )+rep+str.substring( i+find.length() );
			i+=rep.length();
		}
	}
	
	static public String fromChars( int[] chars ){
		int n=chars.length;
		char[] chrs=new char[n];
		for( int i=0;i<n;++i ){
			chrs[i]=(char)chars[i];
		}
		return new String( chrs,0,n );
	}
	
	//***** Array Stuff *****
	
	static Object sliceArray( Object arr,int from ){
		return sliceArray( arr,from,Array.getLength( arr ) );
	}
	
	static Object sliceArray( Object arr,int from,int term ){
		int len=Array.getLength( arr );
		if( from<0 ){
			from+=len;
			if( from<0 ) from=0;
		}else if( from>len ){
			from=len;
		}
		if( term<0 ){
			term+=len;
		}else if( term>len ){
			term=len;
		}
		if( term<from ) term=from;
		int newlen=term-from;
		Object res=Array.newInstance( arr.getClass().getComponentType(),newlen );
		if( newlen>0 ) System.arraycopy( arr,from,res,0,newlen );
		return res;
	}
	
	static Object resizeArray( Object arr,int newlen ){
		int len=Array.getLength( arr );
		Object res=Array.newInstance( arr.getClass().getComponentType(),newlen );
		int n=Math.min( len,newlen );
		if( n>0 ) System.arraycopy( arr,0,res,0,n );
		return res;
	}
	
	static Object[] resizeArrayArray( Object[] arr,int newlen ){
		int i=arr.length;
		arr=(Object[])resizeArray( arr,newlen );
		if( i<newlen ){
			Object empty=Array.newInstance( arr.getClass().getComponentType().getComponentType(),0 );
			while( i<newlen ) arr[i++]=empty;
		}
		return arr;
	}
	
	static String[] resizeStringArray( String[] arr,int newlen ){
		int i=arr.length;
		arr=(String[])resizeArray( arr,newlen );
		while( i<newlen ) arr[i++]="";
		return arr;
	}
	
	static Object concatArrays( Object lhs,Object rhs ){
		int lhslen=Array.getLength( lhs );
		int rhslen=Array.getLength( rhs );
		int len=lhslen+rhslen;
		Object res=Array.newInstance( lhs.getClass().getComponentType(),len );
		if( lhslen>0 ) System.arraycopy( lhs,0,res,0,lhslen );
		if( rhslen>0 ) System.arraycopy( rhs,0,res,lhslen,rhslen );
		return res;
	}
	
	static int arrayLength( Object arr ){
		return arr!=null ? Array.getLength( arr ) : 0;
	}

}

class ThrowableObject extends RuntimeException{
	ThrowableObject(){
		super( "Uncaught Throwable Object" );
	}
}

// Android mojo runtime.
//
// Copyright 2011 Mark Sibly, all rights reserved.
// No warranty implied; use at your own risk.






public class MonkeyGame extends Activity {

	static MonkeyGame activity;
	static MonkeyView view;
	static gxtkApp app;
	
	public static class LogTool extends OutputStream{
	
		private ByteArrayOutputStream bos=new ByteArrayOutputStream();
	  
		@Override
		public void write( int b ) throws IOException{
			if( b==(int)'\n' ){
				Log.i( "[Monkey]",new String( this.bos.toByteArray() ) );
				this.bos=new ByteArrayOutputStream();
			}else{
				this.bos.write(b);
			}
		}
	}
	
	public static class MonkeyView extends GLSurfaceView implements GLSurfaceView.Renderer{

		public MonkeyView( Context context ){
			super( context );
		}
		
		public MonkeyView( Context context,AttributeSet attrs ){
			super( context,attrs );
		}
		
		public boolean dispatchKeyEventPreIme( KeyEvent event ){
			if( app==null ) return false;
			
			if( app.input.keyboardEnabled ) {
				if( event.getKeyCode()==KeyEvent.KEYCODE_BACK ){
					if( event.getAction()==KeyEvent.ACTION_DOWN ){
						app.input.PutChar( 27 );
					}
					return true;
				}
			}else{
				if( event.getKeyCode()==KeyEvent.KEYCODE_BACK ){
					if( event.getAction()==KeyEvent.ACTION_DOWN ){
						app.input.OnKeyDown( 27 );
					}else if( event.getAction()==KeyEvent.ACTION_UP ){
						app.input.OnKeyUp( 27 );
					}
					return true;
				}
			}
			return false;
		}
		
		public boolean onKeyDown( int key,KeyEvent event ){
			if( app==null || !app.input.keyboardEnabled ) return false;
			
			if( event.getKeyCode()==KeyEvent.KEYCODE_DEL ){
				app.input.PutChar( 8 );
			}else{
				int chr=event.getUnicodeChar();
				if( chr!=0 ){
					if( chr==10 ) chr=13;
					app.input.PutChar( chr );
				}
			}
			return true;
		}
		
		public boolean onKeyMultiple( int keyCode,int repeatCount,KeyEvent event ){
			if( app==null || !app.input.keyboardEnabled ) return false;
		
			gxtkInput input=app.input;
			
			String str=event.getCharacters();
			for( int i=0;i<str.length();++i ){
				int chr=str.charAt( i );
				if( chr!=0 ){
					if( chr==10 ) chr=13;
					input.PutChar( chr );
				}
			}
			return true;
		}
		
		//fields for touch event handling
		boolean useMulti,checkedMulti;
		Method getPointerCount,getPointerId,getX,getY;
		Object args1[]=new Object[1];
		
		public boolean onTouchEvent( MotionEvent event ){
			if( app==null ) return false;
		
			if( !checkedMulti ){
				//Check for multi-touch support
				//
				try{
					Class cls=event.getClass();
					Class intClass[]=new Class[]{ Integer.TYPE };
					getPointerCount=cls.getMethod( "getPointerCount" );
					getPointerId=cls.getMethod( "getPointerId",intClass );
					getX=cls.getMethod( "getX",intClass );
					getY=cls.getMethod( "getY",intClass );
					useMulti=true;
				}catch( NoSuchMethodException ex ){
					useMulti=false;
				}
				checkedMulti=true;
			}
			
			if( !useMulti ){
				//mono-touch version...
				//
				gxtkInput input=app.input;
				int action=event.getAction();
				
				switch( action ){
				case MotionEvent.ACTION_DOWN:
					input.OnKeyDown( gxtkInput.KEY_TOUCH0 );
					break;
				case MotionEvent.ACTION_UP:
					input.OnKeyUp( gxtkInput.KEY_TOUCH0 );
					break;
				}
				
				input.touchX[0]=event.getX();
				input.touchY[0]=event.getY();
		
				return true;
			}

			try{

				//multi-touch version...
				//
				final int ACTION_DOWN=0;
				final int ACTION_UP=1;
				final int ACTION_POINTER_DOWN=5;
				final int ACTION_POINTER_UP=6;
				final int ACTION_POINTER_ID_SHIFT=8;
				final int ACTION_MASK=255;
				
				gxtkInput input=app.input;
				
				int action=event.getAction();
				int maskedAction=action & ACTION_MASK;
				int pid=0;
				
				if( maskedAction==ACTION_POINTER_DOWN || maskedAction==ACTION_POINTER_UP ){
					args1[0]=Integer.valueOf( action>>ACTION_POINTER_ID_SHIFT );
					pid=((Integer)getPointerId.invoke( event,args1 )).intValue();
				}else{
					args1[0]=Integer.valueOf( 0 );
					pid=((Integer)getPointerId.invoke( event,args1 )).intValue();
				}
				
				switch( maskedAction ){
				case ACTION_DOWN:
				case ACTION_POINTER_DOWN:
					input.OnKeyDown( pid+gxtkInput.KEY_TOUCH0 );
					break;
				case ACTION_UP:
				case ACTION_POINTER_UP:
					input.OnKeyUp( pid+gxtkInput.KEY_TOUCH0 );
					break;
				}
				
				int pointerCount=((Integer)getPointerCount.invoke( event )).intValue();
				
				for( int i=0;i<pointerCount;++i ){
					args1[0]=Integer.valueOf( i );
					int pid2=((Integer)getPointerId.invoke( event,args1 )).intValue();
					input.touchX[pid2]=((Float)getX.invoke( event,args1 )).floatValue();
					input.touchY[pid2]=((Float)getY.invoke( event,args1 )).floatValue();
				}

			}catch( Exception e ){
			}
	
			return true;
		}
		
		public void onDrawFrame( GL10 gl ){
		}
	
		public void onSurfaceChanged( GL10 gl,int width,int height ){
		}
	
		public void onSurfaceCreated( GL10 gl,EGLConfig config ){
		}
	}
	
	/** Called when the activity is first created. */
	@Override
	public void onCreate( Bundle savedInstanceState ){	//onStart
		super.onCreate( savedInstanceState );
		
		System.setOut( new PrintStream( new LogTool() ) );

		activity=this;

		setContentView( R.layout.main );

		view=(MonkeyView)findViewById( R.id.monkeyview );
		view.setFocusableInTouchMode( true );
		view.requestFocus();
		
		setVolumeControlStream( AudioManager.STREAM_MUSIC );
			
		try{
		
			bb_.bbInit();
			bb_.bbMain();
			
			if( app==null ) System.exit( 0 );
			
			if( MonkeyConfig.OPENGL_GLES20_ENABLED.equals( "true" ) ){
				
				//view.setEGLContextClientVersion( 2 );	//API 8 only!
				//
				try{
					Class clas=view.getClass();
					Class parms[]=new Class[]{ Integer.TYPE };
					Method setVersion=clas.getMethod( "setEGLContextClientVersion",parms );
					Object args[]=new Object[1];
					args[0]=Integer.valueOf( 2 );
					setVersion.invoke( view,args );
				}catch( NoSuchMethodException ex ){
				}
			}
			view.setRenderer( app );
			view.setRenderMode( GLSurfaceView.RENDERMODE_WHEN_DIRTY );
			view.requestRender();

		}catch( Throwable t ){
		
			app=null;
		
			view.setRenderer( view );
			view.setRenderMode( GLSurfaceView.RENDERMODE_WHEN_DIRTY );
			view.requestRender();
			
			new gxtkAlert( t );
		}
	}
	
	@Override
	public void onRestart(){
		super.onRestart();
	}
	
	@Override
	public void onStart(){
		super.onStart();
	}
	
	@Override
	public void onResume(){
		super.onResume();
		view.onResume();
		if( app!=null ){
			app.InvokeOnResume();
		}
	}
	
	@Override 
	public void onPause(){
		super.onPause();
		if( app!=null ){
			app.InvokeOnSuspend();
		}
		view.onPause();
	}

	@Override
	public void onStop(){
		super.onStop();
	}
	
	@Override
	public void onDestroy(){
		super.onDestroy();
	}
}

class gxtkTimer implements Runnable{

	private double nextUpdate;
	private double updatePeriod;
	private boolean cancelled=false;

	public gxtkTimer( int fps ){
		updatePeriod=1000.0/fps;
		nextUpdate=SystemClock.uptimeMillis()+updatePeriod;
		MonkeyGame.view.postDelayed( this,(long)updatePeriod );
	}

	public void cancel(){
		cancelled=true;
	}

	public void run(){
		if( cancelled ) return;

		int updates=0;
		for(;;){
			nextUpdate+=updatePeriod;

			MonkeyGame.app.InvokeOnUpdate();

			if( cancelled ) return;
			
			if( (long)nextUpdate>SystemClock.uptimeMillis() ) break;
			
			if( ++updates==7 ){
				nextUpdate=SystemClock.uptimeMillis()+updatePeriod;
				break;
			}
		}

		MonkeyGame.view.requestRender();

		if( cancelled ) return;
		
		long delay=(long)nextUpdate-SystemClock.uptimeMillis();
		MonkeyGame.view.postDelayed( this,delay>0 ? delay : 0 );
	}
}

class gxtkAlert implements Runnable{

	String msg;

	gxtkAlert( Throwable t ){
	
		bb_std_lang.print( "Java exception:"+t.toString() );
		
		if( t instanceof NullPointerException ){
			msg="Attempt to access null object";
		}else if( t instanceof ArithmeticException ){
			msg="Arithmetic exception";
		}else if( t instanceof ArrayIndexOutOfBoundsException ){
			msg="Array index out of bounds";
		}else{
			msg=t.getMessage();
		}
		
		if( msg.length()==0 ) System.exit( 0 );
		
		msg=bb_std_lang.makeError( msg );

		MonkeyGame.view.postDelayed( this,0 );
	}

	public void run(){

		AlertDialog.Builder db=new AlertDialog.Builder( MonkeyGame.activity );

		db.setMessage( msg );
		
		AlertDialog dlg=db.show();
	}
	
};

class gxtkApp implements GLSurfaceView.Renderer{

	gxtkGraphics graphics;
	gxtkInput input;
	gxtkAudio audio;

	int updateRate;
	gxtkTimer timer;
	
	long startMillis;
	
	boolean dead,suspended,canrender,created;
	
	int seq;

	gxtkApp(){
		MonkeyGame.app=this;

		graphics=new gxtkGraphics();
		input=new gxtkInput();
		audio=new gxtkAudio();
		
		startMillis=System.currentTimeMillis();
	}
	
	void Die( Throwable t ){
	
		dead=true;
		audio.OnDestroy();
		
		new gxtkAlert( t );
	}
	
	//interface GLSurfaceView.Renderer
	synchronized public void onDrawFrame( GL10 gl ){
		InvokeOnRender( gl );
	}
	
	//interface GLSurfaceView.Renderer
	synchronized public void onSurfaceChanged( GL10 gl,int width,int height ){
		graphics.SetSize( width,height );
	}
	
	//interface GLSurfaceView.Renderer
	synchronized public void onSurfaceCreated( GL10 gl,EGLConfig config ){
		gxtkSurface.discarded.clear();
		canrender=true;
		seq+=1;
	}
	
	synchronized int InvokeOnUpdate(){
		if( dead || suspended || updateRate==0 ) return 0;

		try{
			input.BeginUpdate();
			OnUpdate();
			input.EndUpdate();
		}catch( Throwable t ){
			Die( t );
		}
		return 0;
	}

	synchronized int InvokeOnSuspend(){
		if( dead || suspended ) return 0;

		try{
			suspended=true;
			canrender=false;
			OnSuspend();
			audio.OnSuspend();
			if( updateRate!=0 ){
				int upr=updateRate;
				SetUpdateRate( 0 );
				updateRate=upr;
			}
		}catch( Throwable t ){
			Die( t );
		}
		return 0;
	}

	synchronized int InvokeOnResume(){
		if( dead || !suspended ) return 0;
		
		try{
			suspended=false;
			audio.OnResume();
			if( updateRate!=0 ){
				int upr=updateRate;
				updateRate=0;
				SetUpdateRate( upr );
			}
			OnResume();
		}catch( Throwable t ){
			Die( t );
		}
		return 0;
	}

	synchronized int InvokeOnRender( GL10 gl ){
		if( dead || suspended || !canrender ) return 0;
		
		try{
			graphics.BeginRender( gl );
			if( !created ){
				created=true;
				OnCreate();
			}
			OnRender();
			graphics.EndRender();
		}catch( Throwable t ){
			Die( t );
		}
		return 0;
	}
	
	//***** GXTK API *****

	gxtkGraphics GraphicsDevice(){
		return graphics;

	}
	gxtkInput InputDevice(){
		return input;
	}
	
	gxtkAudio AudioDevice(){
		return audio;
	}

	String LoadState(){
		SharedPreferences prefs=MonkeyGame.activity.getPreferences( 0 );
		return prefs.getString( "gxtkAppState","" );
	}
	
	int SaveState( String state ){
		SharedPreferences prefs=MonkeyGame.activity.getPreferences( 0 );
		SharedPreferences.Editor editor=prefs.edit();
		editor.putString( "gxtkAppState",state );
		editor.commit();
		return 0;
	}
	
	String LoadString( String path ){
		return MonkeyData.loadString( path );
	}

	int SetUpdateRate( int hertz ){
		if( timer!=null ){
			timer.cancel();
			timer=null;
		}
		updateRate=hertz;
		if( updateRate!=0 ){
			timer=new gxtkTimer( updateRate );
		}
		return 0;
	}

	int MilliSecs(){
		return (int)( System.currentTimeMillis()-startMillis );
	}
	
	int Loading(){
		return 0;
	}

	int OnCreate(){
		return 0;
	}

	int OnUpdate(){
		return 0;
	}
	
	int OnSuspend(){
		return 0;
	}
	
	int OnResume(){
		return 0;
	}

	int OnRender(){
		return 0;
	}
	
	int OnLoading(){
		return 0;
	}
	
}

class RenderOp{
	int type,count,alpha;
	gxtkSurface surf;
};

class gxtkGraphics{

	static final int MAX_VERTICES=65536/20;
	static final int MAX_RENDEROPS=MAX_VERTICES/2;	//ie: max lines
	
	int mode,width,height;
	
	float alpha;
	float r,g,b;
	int colorARGB;
	int blend;
	float ix,iy,jx,jy,tx,ty;
	boolean tformed;
	
	RenderOp renderOps[]=new RenderOp[MAX_RENDEROPS];
	RenderOp rop,nullRop;
	int nextOp,vcount;

	float[] vertices=new float[MAX_VERTICES*4];	//x,y,u,v
	int[] colors=new int[MAX_VERTICES];	//rgba
	int vp,cp;
	
	FloatBuffer vbuffer;
	IntBuffer cbuffer;
	int vbo,vbo_seq;
	
	gxtkGraphics(){
	
		if( MonkeyConfig.OPENGL_GLES20_ENABLED.equals( "true" ) ){
			mode=0;
			return;
		}
		
		mode=1;
	
		for( int i=0;i<MAX_RENDEROPS;++i ){
			renderOps[i]=new RenderOp();
		}
		nullRop=new RenderOp();
		nullRop.type=-1;

		vbuffer=FloatBuffer.wrap( vertices,0,MAX_VERTICES*4 );
		cbuffer=IntBuffer.wrap( colors,0,MAX_VERTICES );
	}
	
	void SetSize( int width,int height ){
		this.width=width;
		this.height=height;
	}
	
	void BeginRender( GL10 _gl ){
		if( mode==0 ) return;
		
		if( vbo_seq!=MonkeyGame.app.seq ){

			vbo_seq=MonkeyGame.app.seq;
			
			int[] bufs=new int[1];
			GLES11.glGenBuffers( 1,bufs,0 );
			vbo=bufs[0];
			
			GLES11.glBindBuffer( GLES11.GL_ARRAY_BUFFER,vbo );
			GLES11.glBufferData( GLES11.GL_ARRAY_BUFFER,MAX_VERTICES*20,null,GLES11.GL_DYNAMIC_DRAW );
		}
		
		GLES11.glViewport( 0,0,width,height );
		
		GLES11.glMatrixMode( GLES11.GL_PROJECTION );
		GLES11.glLoadIdentity();
		GLES11.glOrthof( 0,width,height,0,-1,1 );
		
		GLES11.glMatrixMode( GLES11.GL_MODELVIEW );
		GLES11.glLoadIdentity();
		
		GLES11.glEnable( GLES11.GL_BLEND );
		GLES11.glBlendFunc( GLES11.GL_ONE,GLES11.GL_ONE_MINUS_SRC_ALPHA );

		GLES11.glBindBuffer( GLES11.GL_ARRAY_BUFFER,vbo );
		GLES11.glEnableClientState( GLES11.GL_VERTEX_ARRAY );
		GLES11.glEnableClientState( GLES11.GL_TEXTURE_COORD_ARRAY );
		GLES11.glEnableClientState( GLES11.GL_COLOR_ARRAY );
		GLES11.glVertexPointer( 2,GLES11.GL_FLOAT,16,0 );
		GLES11.glTexCoordPointer( 2,GLES11.GL_FLOAT,16,8 );
		GLES11.glColorPointer( 4,GLES11.GL_UNSIGNED_BYTE,0,MAX_VERTICES*16 );

		Reset();
	}
	
	void EndRender(){
		if( mode==0 ) return;
		Flush();
	}

	void Reset(){
		rop=nullRop;
		nextOp=0;
		vcount=0;
	}

	void Flush(){
		if( vcount==0 ) return;
	
		GLES11.glBufferData( GLES11.GL_ARRAY_BUFFER,vcount*20,null,GLES11.GL_DYNAMIC_DRAW );
		GLES11.glBufferSubData( GLES11.GL_ARRAY_BUFFER,0,vcount*16,vbuffer );
		GLES11.glBufferSubData( GLES11.GL_ARRAY_BUFFER,vcount*16,vcount*4,cbuffer );
		GLES11.glColorPointer( 4,GLES11.GL_UNSIGNED_BYTE,0,vcount*16 );

		GLES11.glDisable( GLES11.GL_TEXTURE_2D );
		GLES11.glDisable( GLES11.GL_BLEND );

		int index=0;
		boolean blendon=false;
		gxtkSurface surf=null;

		for( int i=0;i<nextOp;++i ){
		
			RenderOp op=renderOps[i];
			
			if( op.surf!=null ){
				if( op.surf!=surf ){
					if( surf==null ) GLES11.glEnable( GLES11.GL_TEXTURE_2D );
					surf=op.surf;
					surf.Bind();
				}
			}else if( surf!=null ){
				GLES11.glDisable( GLES11.GL_TEXTURE_2D );
				surf=null;
			}
			
			//should just have another blend mode...
			if( blend==1 || (op.alpha>>>24)!=0xff || (op.surf!=null && op.surf.hasAlpha) ){
				if( !blendon ){
					GLES11.glEnable( GLES11.GL_BLEND );
					blendon=true;
				}
			}else{
				if( blendon ){
					GLES11.glDisable( GLES11.GL_BLEND );
					blendon=false;
				}
			}
	
			GLES11.glDrawArrays( op.type,index,op.count );
			
			index+=op.count;
		}
		
		Reset();
	}
	
	void Begin( int type,int count,gxtkSurface surf ){
		if( vcount+count>MAX_VERTICES ){
			Flush();
		}
		if( type!=rop.type || surf!=rop.surf ){
			if( nextOp==MAX_RENDEROPS ){
				Flush();
			}
			rop=renderOps[nextOp];
			nextOp+=1;
			rop.type=type;
			rop.surf=surf;
			rop.count=0;
			rop.alpha=~0;
		}
		rop.alpha&=colorARGB;
		rop.count+=count;
		vp=vcount*4;
		cp=vcount;
		vcount+=count;
	}

	//***** GXTK API *****

	int Mode(){
		return mode;
	}
	
	int Width(){
		return width;
	}
	
	int Height(){
		return height;
	}
	
	gxtkSurface LoadSurface( String path ){
		Bitmap bitmap=null;
		try{
			bitmap=MonkeyData.loadBitmap( path );
		}catch( OutOfMemoryError e ){
			throw new Error( "Out of memory error loading bitmap" );
		}
		if( bitmap!=null ) return new gxtkSurface( bitmap );
		return null;
	}
	
	int SetAlpha( float alpha ){
		this.alpha=alpha;
		int a=(int)(alpha*255);
		colorARGB=(a<<24) | ((int)(b*alpha)<<16) | ((int)(g*alpha)<<8) | (int)(r*alpha);
		return 0;
	}

	int SetColor( float r,float g,float b ){
		this.r=r;
		this.g=g;
		this.b=b;
		int a=(int)(alpha*255);
		colorARGB=(a<<24) | ((int)(b*alpha)<<16) | ((int)(g*alpha)<<8) | (int)(r*alpha);
		return 0;
	}
	
	int SetBlend( int blend ){
		if( blend==this.blend ) return 0;
		
		Flush();
		
		this.blend=blend;
		
		switch( blend ){
		case 1:
			GLES11.glBlendFunc( GLES11.GL_ONE,GLES11.GL_ONE );
			break;
		default:
			GLES11.glBlendFunc( GLES11.GL_ONE,GLES11.GL_ONE_MINUS_SRC_ALPHA );
		}
		return 0;
	}
	
	int SetScissor( int x,int y,int w,int h ){
		Flush();
		
		if( x!=0 || y!=0 || w!=Width() || h!=Height() ){
			GLES11.glEnable( GLES11.GL_SCISSOR_TEST );
			y=Height()-y-h;
			GLES11.glScissor( x,y,w,h );
		}else{
			GLES11.glDisable( GLES11.GL_SCISSOR_TEST );
		}
		return 0;
	}
	
	int SetMatrix( float ix,float iy,float jx,float jy,float tx,float ty ){
	
		tformed=(ix!=1 || iy!=0 || jx!=0 || jy!=1 || tx!=0 || ty!=0);
		this.ix=ix;
		this.iy=iy;
		this.jx=jx;
		this.jy=jy;
		this.tx=tx;
		this.ty=ty;
		
		return 0;
	}
	
	int Cls( float r,float g,float b ){
		Reset();
		
		GLES11.glClearColor( r/255.0f,g/255.0f,b/255.0f,1 );
		GLES11.glClear( GLES11.GL_COLOR_BUFFER_BIT|GLES11.GL_DEPTH_BUFFER_BIT );
		
		return 0;
	}
	
	int DrawPoint( float x,float y ){
	
		if( tformed ){
			float px=x;
			x=px * ix + y * jx + tx;
			y=px * iy + y * jy + ty;
		}
		
		Begin( GLES11.GL_POINTS,1,null );
		
		vertices[vp]=x;vertices[vp+1]=y;
		
		colors[cp]=colorARGB;
		
		return 0;
	}
	
	int DrawRect( float x,float y,float w,float h ){
	
		float x0=x,x1=x+w,x2=x+w,x3=x;
		float y0=y,y1=y,y2=y+h,y3=y+h;
		
		if( tformed ){
			float tx0=x0,tx1=x1,tx2=x2,tx3=x3;
			x0=tx0 * ix + y0 * jx + tx;
			y0=tx0 * iy + y0 * jy + ty;
			x1=tx1 * ix + y1 * jx + tx;
			y1=tx1 * iy + y1 * jy + ty;
			x2=tx2 * ix + y2 * jx + tx;
			y2=tx2 * iy + y2 * jy + ty;
			x3=tx3 * ix + y3 * jx + tx;
			y3=tx3 * iy + y3 * jy + ty;
		}

		Begin( GLES11.GL_TRIANGLES,6,null );
		
		vertices[vp]=x0;vertices[vp+1]=y0;
		vertices[vp+4]=x1;vertices[vp+5]=y1;
		vertices[vp+8]=x2;vertices[vp+9]=y2;
		
		vertices[vp+12]=x0;vertices[vp+13]=y0;
		vertices[vp+16]=x2;vertices[vp+17]=y2;
		vertices[vp+20]=x3;vertices[vp+21]=y3;

		colors[cp]=colors[cp+1]=colors[cp+2]=colors[cp+3]=colors[cp+4]=colors[cp+5]=colorARGB;

		return 0;
	}
	
	int DrawLine( float x0,float y0,float x1,float y1 ){
		
		if( tformed ){
			float tx0=x0,tx1=x1;
			x0=tx0 * ix + y0 * jx + tx;
			y0=tx0 * iy + y0 * jy + ty;
			x1=tx1 * ix + y1 * jx + tx;
			y1=tx1 * iy + y1 * jy + ty;
		}

		Begin( GLES11.GL_LINES,2,null );

		vertices[vp]=x0;vertices[vp+1]=y0;
		vertices[vp+4]=x1;vertices[vp+5]=y1;

		colors[cp]=colors[cp+1]=colorARGB;

		return 0;
 	}

	int DrawOval( float x,float y,float w,float h ){

		float xr=w/2.0f;
		float yr=h/2.0f;

		int segs;	
		if( tformed ){
			float xx=xr*ix,xy=xr*iy,xd=(float)Math.sqrt(xx*xx+xy*xy);
			float yx=yr*jx,yy=yr*jy,yd=(float)Math.sqrt(yx*yx+yy*yy);
			segs=(int)( xd+yd );
		}else{
			segs=(int)( Math.abs(xr)+Math.abs(yr) );
		}

		if( segs>MAX_VERTICES ){
			segs=MAX_VERTICES;
		}else if( segs<12 ){
			segs=12;
		}else{
			segs&=~3;
		}
		
		x+=xr;
		y+=yr;
		
		Begin( GLES11.GL_TRIANGLE_FAN,segs,null );

		for( int i=0;i<segs;++i ){
			float th=i * 6.28318531f / segs;
			float x0=(float)(x+Math.cos(th)*xr);
			float y0=(float)(y+Math.sin(th)*yr);
			if( tformed ){
				float tx0=x0;
				x0=tx0 * ix + y0 * jx + tx;
				y0=tx0 * iy + y0 * jy + ty;
			}
			vertices[vp]=x0;
			vertices[vp+1]=y0;
			colors[cp+i]=colorARGB;
			vp+=4;
		}
		
		Flush();	//Note: could really queue these too now...

		return 0;
	}
	
	int DrawPoly( float[] verts ){
		if( verts.length<6 || verts.length>MAX_VERTICES*2 ) return 0;
	
		Begin( GLES11.GL_TRIANGLE_FAN,verts.length/2,null );
		
		if( tformed ){
			for( int i=0;i<verts.length;i+=2 ){
				vertices[vp  ]=verts[i] * ix + verts[i+1] * jx + tx;
				vertices[vp+1]=verts[i] * iy + verts[i+1] * jy + ty;
				colors[cp]=colorARGB;
				vp+=4;
				cp+=1;
			}
		}else{
			for( int i=0;i<verts.length;i+=2 ){
				vertices[vp  ]=verts[i];
				vertices[vp+1]=verts[i+1];
				colors[cp]=colorARGB;
				vp+=4;
				cp+=1;
			}
		}

		Flush();	//Note: could really queue these too now...

		return 0;
	}

	int DrawSurface( gxtkSurface surface,float x,float y ){
	
		float w=surface.width;
		float h=surface.height;
		float u0=0,u1=w*surface.uscale;
		float v0=0,v1=h*surface.vscale;
		
		float x0=x,x1=x+w,x2=x+w,x3=x;
		float y0=y,y1=y,y2=y+h,y3=y+h;
		
		if( tformed ){
			float tx0=x0,tx1=x1,tx2=x2,tx3=x3;
			x0=tx0 * ix + y0 * jx + tx;
			y0=tx0 * iy + y0 * jy + ty;
			x1=tx1 * ix + y1 * jx + tx;
			y1=tx1 * iy + y1 * jy + ty;
			x2=tx2 * ix + y2 * jx + tx;
			y2=tx2 * iy + y2 * jy + ty;
			x3=tx3 * ix + y3 * jx + tx;
			y3=tx3 * iy + y3 * jy + ty;
		}

		Begin( GLES11.GL_TRIANGLES,6,surface );
		
		vertices[vp]=x0;vertices[vp+1]=y0;vertices[vp+2]=u0;vertices[vp+3]=v0;
		vertices[vp+4]=x1;vertices[vp+5]=y1;vertices[vp+6]=u1;vertices[vp+7]=v0;
		vertices[vp+8]=x2;vertices[vp+9]=y2;vertices[vp+10]=u1;vertices[vp+11]=v1;
		
		vertices[vp+12]=x0;vertices[vp+13]=y0;vertices[vp+14]=u0;vertices[vp+15]=v0;
		vertices[vp+16]=x2;vertices[vp+17]=y2;vertices[vp+18]=u1;vertices[vp+19]=v1;
		vertices[vp+20]=x3;vertices[vp+21]=y3;vertices[vp+22]=u0;vertices[vp+23]=v1;

		colors[cp]=colors[cp+1]=colors[cp+2]=colors[cp+3]=colors[cp+4]=colors[cp+5]=colorARGB;

		return 0;
	}
	
	int DrawSurface2( gxtkSurface surface,float x,float y,int srcx,int srcy,int srcw,int srch ){
	
		float w=srcw;
		float h=srch;
		float u0=srcx*surface.uscale,u1=(srcx+srcw)*surface.uscale;
		float v0=srcy*surface.vscale,v1=(srcy+srch)*surface.vscale;
		
		float x0=x,x1=x+w,x2=x+w,x3=x;
		float y0=y,y1=y,y2=y+h,y3=y+h;
		
		if( tformed ){
			float tx0=x0,tx1=x1,tx2=x2,tx3=x3;
			x0=tx0 * ix + y0 * jx + tx;
			y0=tx0 * iy + y0 * jy + ty;
			x1=tx1 * ix + y1 * jx + tx;
			y1=tx1 * iy + y1 * jy + ty;
			x2=tx2 * ix + y2 * jx + tx;
			y2=tx2 * iy + y2 * jy + ty;
			x3=tx3 * ix + y3 * jx + tx;
			y3=tx3 * iy + y3 * jy + ty;
		}

		Begin( GLES11.GL_TRIANGLES,6,surface );
		
		vertices[vp]=x0;vertices[vp+1]=y0;vertices[vp+2]=u0;vertices[vp+3]=v0;
		vertices[vp+4]=x1;vertices[vp+5]=y1;vertices[vp+6]=u1;vertices[vp+7]=v0;
		vertices[vp+8]=x2;vertices[vp+9]=y2;vertices[vp+10]=u1;vertices[vp+11]=v1;
		
		vertices[vp+12]=x0;vertices[vp+13]=y0;vertices[vp+14]=u0;vertices[vp+15]=v0;
		vertices[vp+16]=x2;vertices[vp+17]=y2;vertices[vp+18]=u1;vertices[vp+19]=v1;
		vertices[vp+20]=x3;vertices[vp+21]=y3;vertices[vp+22]=u0;vertices[vp+23]=v1;

		colors[cp]=colors[cp+1]=colors[cp+2]=colors[cp+3]=colors[cp+4]=colors[cp+5]=colorARGB;

		return 0;
	}
}

class gxtkSurface{

	Bitmap bitmap;
	
	int width,height;
	
	boolean hasAlpha;
	
	int texId,seq;
	float uscale,vscale;

	static Vector discarded=new Vector();
	
	gxtkSurface( Bitmap bitmap ){
		this.bitmap=bitmap;
		width=bitmap.getWidth();
		height=bitmap.getHeight();
		hasAlpha=bitmap.hasAlpha();
	}

	protected void finalize(){
		Discard();
	}
	
	int Pow2Size( int n ){
		int i=1;
		while( i<n ) i*=2;
		return i;
	}
	
	static void FlushDiscarded(){
		int n=discarded.size();
		if( n==0 ) return;
		int[] texs=new int[n];
		for( int i=0;i<n;++i ){
			texs[i]=((Integer)discarded.elementAt(i)).intValue();
		}
		GLES11.glDeleteTextures( n,texs,0 );
		discarded.clear();
	}
	
	void Bind(){
	
		if( texId!=0 && seq==MonkeyGame.app.seq ){
			GLES11.glBindTexture( GLES11.GL_TEXTURE_2D,texId );
			return;
		}
		
		FlushDiscarded();
		
		int[] texs=new int[1];
		GLES11.glGenTextures( 1,texs,0 );
		texId=texs[0];
		if( texId==0 ) throw new Error( "glGenTextures failed" );
		seq=MonkeyGame.app.seq;
		
		GLES11.glBindTexture( GLES11.GL_TEXTURE_2D,texId );
		
		if( MonkeyConfig.MOJO_IMAGE_FILTERING_ENABLED.equals( "true" ) ){
			GLES11.glTexParameteri( GLES11.GL_TEXTURE_2D,GLES11.GL_TEXTURE_MAG_FILTER,GLES11.GL_LINEAR );
			GLES11.glTexParameteri( GLES11.GL_TEXTURE_2D,GLES11.GL_TEXTURE_MIN_FILTER,GLES11.GL_LINEAR );
		}else{
			GLES11.glTexParameteri( GLES11.GL_TEXTURE_2D,GLES11.GL_TEXTURE_MAG_FILTER,GLES11.GL_NEAREST );
			GLES11.glTexParameteri( GLES11.GL_TEXTURE_2D,GLES11.GL_TEXTURE_MIN_FILTER,GLES11.GL_NEAREST );
		}

		GLES11.glTexParameteri( GLES11.GL_TEXTURE_2D,GLES11.GL_TEXTURE_WRAP_S,GLES11.GL_CLAMP_TO_EDGE );
		GLES11.glTexParameteri( GLES11.GL_TEXTURE_2D,GLES11.GL_TEXTURE_WRAP_T,GLES11.GL_CLAMP_TO_EDGE );
		
		int texwidth=Pow2Size( width );
		int texheight=Pow2Size( height );
		
		uscale=1.0f/(float)texwidth;
		vscale=1.0f/(float)texheight;
		
		int pwidth=(width==texwidth) ? width : width+1;
		int pheight=(height==texheight) ? height : height+1;

		int sz=pwidth*pheight;
		int[] pixels=new int[sz];
		bitmap.getPixels( pixels,0,pwidth,0,0,width,height );
		
		//pad edges for non pow-2 images - not sexy!
		if( width!=pwidth ){
			for( int y=0;y<height;++y ){
				pixels[y*pwidth+width]=pixels[y*pwidth+width-1];
			}
		}
		if( height!=pheight ){
			for( int x=0;x<width;++x ){
				pixels[height*pwidth+x]=pixels[height*pwidth+x-pwidth];
			}
		}
		if( width!=pwidth && height!=pheight ){
			pixels[height*pwidth+width]=pixels[height*pwidth+width-pwidth-1];
		}
		
		GLES11.glPixelStorei( GLES11.GL_UNPACK_ALIGNMENT,1 );
		
		boolean hicolor_textures=MonkeyConfig.MOJO_HICOLOR_TEXTURES.equals("true");
		
		if( hicolor_textures && hasAlpha ){

			//RGBA8888...
			ByteBuffer buf=ByteBuffer.allocate( sz*4 );
			buf.order( ByteOrder.BIG_ENDIAN );

			for( int i=0;i<sz;++i ){
				int p=pixels[i];
				int a=(p>>24) & 255;
				int r=((p>>16) & 255)*a/255;
				int g=((p>>8) & 255)*a/255;
				int b=(p & 255)*a/255;
				buf.putInt( (r<<24)|(g<<16)|(b<<8)|a );
			}
			GLES11.glTexImage2D( GLES11.GL_TEXTURE_2D,0,GLES11.GL_RGBA,texwidth,texheight,0,GLES11.GL_RGBA,GLES11.GL_UNSIGNED_BYTE,null );
			GLES11.glTexSubImage2D( GLES11.GL_TEXTURE_2D,0,0,0,pwidth,pheight,GLES11.GL_RGBA,GLES11.GL_UNSIGNED_BYTE,buf );
			
		}else if( hicolor_textures && !hasAlpha ){
		
			//RGB888...
			ByteBuffer buf=ByteBuffer.allocate( sz*3 );
			buf.order( ByteOrder.BIG_ENDIAN );
			
			for( int i=0;i<sz;++i ){
				int p=pixels[i];
				int r=(p>>16) & 255;
				int g=(p>>8) & 255;
				int b=p & 255;
				buf.put( (byte)r );
				buf.put( (byte)g );
				buf.put( (byte)b );
			}
			GLES11.glTexImage2D( GLES11.GL_TEXTURE_2D,0,GLES11.GL_RGB,texwidth,texheight,0,GLES11.GL_RGB,GLES11.GL_UNSIGNED_BYTE,null );
			GLES11.glTexSubImage2D( GLES11.GL_TEXTURE_2D,0,0,0,pwidth,pheight,GLES11.GL_RGB,GLES11.GL_UNSIGNED_BYTE,buf );
			
		}else if( hicolor_textures && hasAlpha ){

			//16 bit RGBA...
			ByteBuffer buf=ByteBuffer.allocate( sz*2 );
			buf.order( ByteOrder.LITTLE_ENDIAN );
			
			//do we need 4 bit alpha?
			boolean a4=false;
			for( int i=0;i<sz;++i ){
				int a=(pixels[i]>>28) & 15;
				if( a!=0 && a!=15 ){
					a4=true;
					break;
				}
			}
			if( a4 ){
				//RGBA4444...
				for( int i=0;i<sz;++i ){
					int p=pixels[i];
					int a=(p>>28) & 15;
					int r=((p>>20) & 15)*a/15;
					int g=((p>>12) & 15)*a/15;
					int b=((p>> 4) & 15)*a/15;
					buf.putShort( (short)( (r<<12)|(g<<8)|(b<<4)|a ) );
				}
				GLES11.glTexImage2D( GLES11.GL_TEXTURE_2D,0,GLES11.GL_RGBA,texwidth,texheight,0,GLES11.GL_RGBA,GLES11.GL_UNSIGNED_SHORT_4_4_4_4,null );
				GLES11.glTexSubImage2D( GLES11.GL_TEXTURE_2D,0,0,0,pwidth,pheight,GLES11.GL_RGBA,GLES11.GL_UNSIGNED_SHORT_4_4_4_4,buf );
			}else{
				//RGBA5551...
				for( int i=0;i<sz;++i ){
					int p=pixels[i];
					int a=(p>>31) & 1;
					int r=((p>>19) & 31)*a;
					int g=((p>>11) & 31)*a;
					int b=((p>> 3) & 31)*a;
					buf.putShort( (short)( (r<<11)|(g<<6)|(b<<1)|a ) );
				}
				GLES11.glTexImage2D( GLES11.GL_TEXTURE_2D,0,GLES11.GL_RGBA,texwidth,texheight,0,GLES11.GL_RGBA,GLES11.GL_UNSIGNED_SHORT_5_5_5_1,null );
				GLES11.glTexSubImage2D( GLES11.GL_TEXTURE_2D,0,0,0,pwidth,pheight,GLES11.GL_RGBA,GLES11.GL_UNSIGNED_SHORT_5_5_5_1,buf );
			}
		}else if( hicolor_textures && !hasAlpha ){
		
			ByteBuffer buf=ByteBuffer.allocate( sz*2 );
			buf.order( ByteOrder.LITTLE_ENDIAN );
			
			//RGB565...
			for( int i=0;i<sz;++i ){
				int p=pixels[i];
				int r=(p>>19) & 31;
				int g=(p>>10) & 63;
				int b=(p>> 3) & 31;
				buf.putShort( (short)( (r<<11)|(g<<5)|b ) );
			}
			GLES11.glTexImage2D( GLES11.GL_TEXTURE_2D,0,GLES11.GL_RGB,texwidth,texheight,0,GLES11.GL_RGB,GLES11.GL_UNSIGNED_SHORT_5_6_5,null );
			GLES11.glTexSubImage2D( GLES11.GL_TEXTURE_2D,0,0,0,pwidth,pheight,GLES11.GL_RGB,GLES11.GL_UNSIGNED_SHORT_5_6_5,buf );
		}
	}
	
	//***** GXTK API *****
	
	int Discard(){
		if( bitmap!=null ){
//			bitmap.recycle();	//causes memory issues on ICS! Shouldn't need it anyway...
			bitmap=null;
		}
		if( texId!=0 ){
			discarded.add( Integer.valueOf( texId ) );
			texId=0;
		}
		return 0;
	}

	int Width(){
		return width;
	}
	
	int Height(){
		return height;
	}

	int Loaded(){
		return 1;
	}
	
}

//***** gxtkInput *****

class gxtkInput implements SensorEventListener{

	int keyStates[]=new int[512];
	int charQueue[]=new int[32];
	int charPut,charGet;
	float touchX[]=new float[32];
	float touchY[]=new float[32];
	float accelX,accelY,accelZ;
	boolean keyboardEnabled,keyboardLost;
	
	static int KEY_LMB=1;
	static int KEY_TOUCH0=0x180;
	
	gxtkInput(){
		SensorManager sensorManager=(SensorManager)MonkeyGame.activity.getSystemService( Context.SENSOR_SERVICE );

//		List<Sensor> sensorList=sensorManager.getSensorList( Sensor.TYPE_ORIENTATION );
		List<Sensor> sensorList=sensorManager.getSensorList( Sensor.TYPE_ACCELEROMETER );
		Iterator<Sensor> it=sensorList.iterator();
		while( it.hasNext() ){
			Sensor sensor=it.next();
			sensorManager.registerListener( this,sensor,SensorManager.SENSOR_DELAY_GAME );
			break;	//which one?
		}
	}

	//SensorEventListener
	public void onAccuracyChanged( Sensor sensor,int accuracy ){
	}
	
	//SensorEventListener
	public void onSensorChanged( SensorEvent event ){
		Sensor sensor=event.sensor;
		switch( sensor.getType() ){
		case Sensor.TYPE_ORIENTATION:
			break;
		case Sensor.TYPE_ACCELEROMETER:
			accelX=-event.values[0]/9.81f;
			accelY=event.values[1]/9.81f;
			accelZ=-event.values[2]/9.81f;
			break;
		}
	}
	
	void BeginUpdate(){
		//
		//Ok, this isn't very polite - if keyboard enabled, we just thrash showSoftInput.
		//
		//But showSoftInput doesn't seem to be too reliable - esp. after onResume - and I haven't found a way to
		//determine if keyboard is showing, so what can yer do...
		//
		if( keyboardEnabled ){
			InputMethodManager mgr=(InputMethodManager)MonkeyGame.activity.getSystemService( Context.INPUT_METHOD_SERVICE );
			mgr.showSoftInput( MonkeyGame.view,0 );//InputMethodManager.SHOW_IMPLICIT );
		}
	}
	
	void EndUpdate(){
		for( int i=0;i<512;++i ){
			keyStates[i]&=0x100;
		}
		charGet=charPut=0;
	}
	
	void PutChar( int chr ){
		if( charPut<32 ) charQueue[charPut++]=chr;
	}

	void OnKeyDown( int key ){
		if( (keyStates[key]&0x100)==0 ){
			keyStates[key]|=0x100;
			++keyStates[key];
		}
	}
	
	void OnKeyUp( int key ){
		keyStates[key]&=0xff;
	}
	
	//***** GXTK API *****

	int SetKeyboardEnabled( int enabled ){
	
		InputMethodManager mgr=(InputMethodManager)MonkeyGame.activity.getSystemService( Context.INPUT_METHOD_SERVICE );
		
		if( enabled!=0 ){
		
			// Hack for someone's phone...My LG or Samsung don't need it...
			mgr.hideSoftInputFromWindow( MonkeyGame.view.getWindowToken(),0 );
			
			keyboardEnabled=true;
			mgr.showSoftInput( MonkeyGame.view,0 );//InputMethodManager.SHOW_IMPLICIT );
		}else{
			keyboardEnabled=false;
			mgr.hideSoftInputFromWindow( MonkeyGame.view.getWindowToken(),0 );
		}
		
		return 0;
	}
	
	int KeyDown( int key ){
		if( key>0 && key<512 ){
			if( key==KEY_LMB ) key=KEY_TOUCH0;
			return keyStates[key] >> 8;
		}
		return 0;
	}

	int KeyHit( int key ){
		if( key>0 && key<512 ){
			if( key==KEY_LMB ) key=KEY_TOUCH0;
			return keyStates[key] & 0xff;
		}
		return 0;
	}

	int GetChar(){
		if( charGet!=charPut ){
			return charQueue[ charGet++ ];
		}
		return 0;
	}
	
	float MouseX(){
		return touchX[0];
	}

	float MouseY(){
		return touchY[0];
	}

	float JoyX( int index ){
		return 0;
	}
	
	float JoyY( int index ){
		return 0;
	}
	
	float JoyZ( int index ){
		return 0;
	}
	
	float TouchX( int index ){
		if( index>=0 && index<32 ){
			return touchX[index];
		}
		return 0;
	}
	
	float TouchY( int index ){
		if( index>=0 && index<32 ){
			return touchY[index];
		}
		return 0;
	}
	
	float AccelX(){
		return accelX;
	}

	float AccelY(){
		return accelY;
	}

	float AccelZ(){
		return accelZ;
	}
}

class gxtkChannel{
	int stream;		//SoundPool stream ID, 0=none
	float volume=1;
	float rate=1;
	float pan;
	int state;
};

class gxtkAudio{

	SoundPool pool;
	MediaPlayer music;
	float musicVolume=1;
	int musicState=0;
	
	gxtkChannel[] channels=new gxtkChannel[32];
	
	gxtkAudio(){
		pool=new SoundPool( 32,AudioManager.STREAM_MUSIC,0 );
		for( int i=0;i<32;++i ){
			channels[i]=new gxtkChannel();
		}
	}
	
	void OnSuspend(){
		if( musicState==1 ) music.pause();
		for( int i=0;i<32;++i ){
			if( channels[i].state==1 ) pool.pause( channels[i].stream );
		}
	}
	
	void OnResume(){
		if( musicState==1 ) music.start();
		for( int i=0;i<32;++i ){
			if( channels[i].state==1 ) pool.resume( channels[i].stream );
		}
	}
	
	void OnDestroy(){
		for( int i=0;i<32;++i ){
			if( channels[i].state!=0 ) pool.stop( channels[i].stream );
		}
		pool.release();
		pool=null;
	}
	
	//***** GXTK API *****

	gxtkSample LoadSample( String path ){
		gxtkSample.FlushDiscarded( pool );
		int sound=MonkeyData.loadSound( path,pool );
		if( sound!=0 ) return new gxtkSample( sound );
		return null;
	}
	
	int PlaySample( gxtkSample sample,int channel,int flags ){
		gxtkChannel chan=channels[channel];
		if( chan.stream!=0 ) pool.stop( chan.stream );
		float rv=(chan.pan * .5f + .5f) * chan.volume;
		float lv=chan.volume-rv;
		int loops=(flags&1)!=0 ? -1 : 0;

		//chan.stream=pool.play( sample.sound,lv,rv,0,loops,chan.rate );
		//chan.state=1;
		//return 0;
		
		//Ugly as hell, but seems to work for now...pauses 10 secs max...
		for( int i=0;i<100;++i ){
			chan.stream=pool.play( sample.sound,lv,rv,0,loops,chan.rate );
			if( chan.stream!=0 ){
				chan.state=1;
				return 0;
			}
//			throw new Error( "PlaySample failed to play sound" );
			try{
				Thread.sleep( 100 );
			}catch( java.lang.InterruptedException ex ){
			}
		}
		throw new Error( "PlaySample failed to play sound" );
	}
	
	int StopChannel( int channel ){
		gxtkChannel chan=channels[channel];
		if( chan.state!=0 ){
			pool.stop( chan.stream );
			chan.state=0;
		}
		return 0;
	}
	
	int PauseChannel( int channel ){
		gxtkChannel chan=channels[channel];
		if( chan.state==1 ){
			pool.pause( chan.stream );
			chan.state=2;
		}
		return 0;
	}
	
	int ResumeChannel( int channel ){
		gxtkChannel chan=channels[channel];
		if( chan.state==2 ){
			pool.resume( chan.stream );
			chan.state=1;
		}
		return 0;
	}
	
	int ChannelState( int channel ){
		return -1;
	}
	
	int SetVolume( int channel,float volume ){
		gxtkChannel chan=channels[channel];
		chan.volume=volume;
		if( chan.stream!=0 ){
			float rv=(chan.pan * .5f + .5f) * chan.volume;
			float lv=chan.volume-rv;
			pool.setVolume( chan.stream,lv,rv );
		}
		return 0;
	}
	
	int SetPan( int channel,float pan ){
		gxtkChannel chan=channels[channel];
		chan.pan=pan;
		if( chan.stream!=0 ){
			float rv=(chan.pan * .5f + .5f) * chan.volume;
			float lv=chan.volume-rv;
			pool.setVolume( chan.stream,lv,rv );
		}
		return 0;
	}

	int SetRate( int channel,float rate ){
		gxtkChannel chan=channels[channel];
		chan.rate=rate;
		if( chan.stream!=0 ){
			pool.setRate( chan.stream,chan.rate );
		}
		return 0;
	}
	
	int PlayMusic( String path,int flags ){
		StopMusic();
		music=MonkeyData.openMedia( path );
		if( music==null ) return -1;
		music.setLooping( (flags&1)!=0 );
		music.setVolume( musicVolume,musicVolume );
		music.start();
		musicState=1;
		return 0;
	}
	
	int StopMusic(){
		if( musicState!=0 ){
			music.stop();
			music.release();
			musicState=0;
			music=null;
		}
		return 0;
	}
	
	int PauseMusic(){
		if( musicState==1 && music.isPlaying() ){
			music.pause();
			musicState=2;
		}
		return 0;
	}
	
	int ResumeMusic(){
		if( musicState==2 ){
			music.start();
			musicState=1;
		}
		return 0;
	}
	
	int MusicState(){
		if( musicState==1 && !music.isPlaying() ) musicState=0;
		return musicState;
	}
	
	int SetMusicVolume( float volume ){
		if( musicState!=0 ) music.setVolume( volume,volume );
		musicVolume=volume;
		return 0;
	}	
}

class gxtkSample{

	int sound;
	
	static Vector discarded=new Vector();
	
	gxtkSample( int sound ){
		this.sound=sound;
	}
	
	protected void finalize(){
		Discard();
	}
	
	static void FlushDiscarded( SoundPool pool ){
		int n=discarded.size();
		if( n==0 ) return;
		Vector out=new Vector();
		for( int i=0;i<n;++i ){
			Integer val=(Integer)discarded.elementAt(i);
			if( pool.unload( val.intValue() ) ){
//				bb_std_lang.print( "unload OK!" );
			}else{
//				bb_std_lang.print( "unload failed!" );
				out.add( val );
			}
		}
		discarded=out;
//		bb_std_lang.print( "undiscarded="+out.size() );
	}

	//***** GXTK API *****
	
	int Discard(){
		if( sound!=0 ){
			discarded.add( Integer.valueOf( sound ) );
			sound=0;
		}
		return 0;
	}
}
class util
{
    static int GetTimestamp()
    {
        return (int) (System.currentTimeMillis() / 1000);
    }
}


class MonkeyPurchaseObserver extends PurchaseObserver {
    private static final String DB_INITIALIZED = "db_initialized";

    private PurchaseDatabase mPurchaseDatabase;
    private Set<String> mOwnedItems = new HashSet<String>();

    private com.payment.BillingService mBillingService;

 	protected boolean inProgress = false;

    public void initDatabase()
    {
        mPurchaseDatabase = new PurchaseDatabase(MonkeyGame.activity);
    }

    public void destroy()
    {
        mPurchaseDatabase.close();
    }

    public void SetBillingService(com.payment.BillingService bs)
    {
        mBillingService = bs;
    }
 	public void SetInProgress(boolean p)
 	{
 		inProgress = p;
 	}

 	public boolean IsInProgress()
 	{
 		return inProgress;
 	}

    public MonkeyPurchaseObserver(Handler handler) {
        super(MonkeyGame.activity, handler);
        // bb_std_lang.print("Payment purchaseobserver started!");
        initDatabase();
    }

    @Override
    public void onBillingSupported(boolean supported) {
        // bb_std_lang.print("onBilling Support!");
       restoreDatabase();
    }

    public boolean IsBought(String productId)
    {
    	return mOwnedItems.contains(productId);
    }

    @Override
    public void onRequestPurchaseResponse(RequestPurchase request,
            ResponseCode responseCode) {
    	// bb_std_lang.print("Payment onRequestPurchaseResponse");
        // bb_std_lang.print("Payment "  + request.mProductId + ": " + responseCode);
        if (responseCode == ResponseCode.RESULT_OK) {
          // bb_std_lang.print("Payment purchase was successfully sent to server");


        } else if (responseCode == ResponseCode.RESULT_USER_CANCELED) {
            SetInProgress(false);

           // bb_std_lang.print("Payment user canceled purchase");


        } else {
            SetInProgress(false);

           // bb_std_lang.print("Payment purchase failed");


        }
    }

    @Override
    public void onRestoreTransactionsResponse(RestoreTransactions request,
            ResponseCode responseCode) {
    	// bb_std_lang.print("Payment onRestoreTransactionsResponse");
        if (responseCode == ResponseCode.RESULT_OK) {
            if (Consts.DEBUG) {
                //bb_std_lang.print(TAG, "completed RestoreTransactions request");
            }
            SharedPreferences prefs = MonkeyGame.activity.getPreferences(Context.MODE_PRIVATE);
            SharedPreferences.Editor edit = prefs.edit();
            edit.putBoolean(DB_INITIALIZED, true);
            edit.commit();
            // bb_std_lang.print("set db initialized to TRUE");
        } else {
            if (Consts.DEBUG) {
                SharedPreferences prefs = MonkeyGame.activity.getPreferences(Context.MODE_PRIVATE);
                SharedPreferences.Editor edit = prefs.edit();
                edit.putBoolean(DB_INITIALIZED, true);
                edit.commit();
                // bb_std_lang.print("ResponseCode invalid");
            }
        }
        SetInProgress(false);
    }

    private void restoreDatabase() {
        // bb_std_lang.print("restoreDatabase");
        SharedPreferences prefs = MonkeyGame.activity.getPreferences(Context.MODE_PRIVATE);
        boolean initialized = prefs.getBoolean(DB_INITIALIZED, false);
        if (!initialized) {
            // bb_std_lang.print("restoreTransactions");
            mBillingService.restoreTransactions();
        }

        Cursor c = mPurchaseDatabase.queryAll();
        try {
            while (c.moveToNext()) {
                int quantity = c.getInt(1);
                if (quantity > 0) {
                    // bb_std_lang.print("add item: " + c.getString(0));
                    mOwnedItems.add(c.getString(0));
                }
            }
        } finally {
                Log.d("_DB", "_DB FINALLY");
            if (c != null) {
                c.close();
            }
        }
     }


    @Override
    public void onPurchaseStateChange(PurchaseState purchaseState, String itemId,
            int quantity, long purchaseTime, String developerPayload) {
    	// bb_std_lang.print("Payment -> onPurchaseStateChange");
           //  bb_std_lang.print("onPurchaseStateChange() itemId: " + itemId + " " + purchaseState);

        if (developerPayload == null) {

        } else {

        }

        if (purchaseState == PurchaseState.PURCHASED) {
        	// bb_std_lang.print("Payment bought!!!! " + itemId);
            SetInProgress(false);
            //bb_std_lang.print("add to owned items!!!! " + itemId);
            mOwnedItems.add(itemId);
            //bb_std_lang.print("update db!!!! " + itemId);
            mPurchaseDatabase.updatePurchasedItem(itemId, 1);
            //bb_std_lang.print("done db!!!! " + itemId);
        }
    }
}

class PaymentWrapper {
    private MonkeyPurchaseObserver mPurchaseObserver;
    private Handler mHandler;
    private com.payment.BillingService mBillingService;

    public void Init()
    {
		mHandler = new Handler();
		mPurchaseObserver = new MonkeyPurchaseObserver(mHandler);
		mBillingService = new com.payment.BillingService();
		mBillingService.setContext(MonkeyGame.activity);
        mPurchaseObserver.SetBillingService(mBillingService);

	    // Check if billing is supported.
	    ResponseHandler.register(mPurchaseObserver);
	    if (!mBillingService.checkBillingSupported()) {
	        // showDialog(DIALOG_CANNOT_CONNECT_ID);
	    }
    }

    public boolean Purchase(String productId)
    {
    	// android.test.purchased
		// bb_std_lang.print("Purchase");
		mPurchaseObserver.SetInProgress(true);
		return mBillingService.requestPurchase(productId, null);
    }

    public boolean IsBought(String productId)
    {
    	return mPurchaseObserver.IsBought(productId);
    }

    public boolean IsPurchaseInProgress()
    {
    	return mPurchaseObserver.IsInProgress();
    }

    protected void finalize() throws Throwable
    {
        mPurchaseObserver.destroy();
        mBillingService.unbind();
    }
}
interface bb_directorevents_DirectorEvents{
	public void m_OnCreate(bb_director_Director t_director);
	public void m_OnLoading();
	public void m_OnUpdate(float t_delta,float t_frameTime);
	public void m_OnTouchDown(bb_touchevent_TouchEvent t_event);
	public void m_OnTouchUp(bb_touchevent_TouchEvent t_event);
	public void m_OnTouchMove(bb_touchevent_TouchEvent t_event);
	public void m_OnKeyDown(bb_keyevent_KeyEvent t_event);
	public void m_OnKeyUp(bb_keyevent_KeyEvent t_event);
	public void m_OnKeyPress(bb_keyevent_KeyEvent t_event);
	public void m_OnResume(int t_delta);
	public void m_OnSuspend();
	public void m_OnRender();
}
class bb_router_Router extends Object implements bb_directorevents_DirectorEvents{
	public bb_router_Router g_new(){
		return this;
	}
	bb_map_StringMap f_handlers=(new bb_map_StringMap()).g_new();
	bb_map_StringMap2 f_routers=(new bb_map_StringMap2()).g_new();
	public void m_Add(String t_name,bb_directorevents_DirectorEvents t_handler){
		if(f_handlers.m_Contains(t_name)){
			bb_std_lang.error("Router already contains a handler named "+t_name);
		}
		f_handlers.m_Set(t_name,t_handler);
		bb_directorevents_DirectorEvents t_=t_handler;
		f_routers.m_Set2(t_name,(t_ instanceof bb_routerevents_RouterEvents ? (bb_routerevents_RouterEvents)t_ : null));
	}
	String f__currentName="";
	bb_directorevents_DirectorEvents f__current=null;
	bb_directorevents_DirectorEvents f__previous=null;
	String f__previousName="";
	public bb_directorevents_DirectorEvents m_Get(String t_name){
		if(!f_handlers.m_Contains(t_name)){
			bb_std_lang.error("Router has no handler named "+t_name);
		}
		return f_handlers.m_Get(t_name);
	}
	bb_director_Director f_director=null;
	bb_list_List f_created=(new bb_list_List()).g_new();
	public void m_DispatchOnCreate(){
		if(!((f_director)!=null)){
			return;
		}
		if(!((f__current)!=null)){
			return;
		}
		if(f_created.m_Contains(f__currentName)){
			return;
		}
		f__current.m_OnCreate(f_director);
		f_created.m_AddLast(f__currentName);
	}
	public void m_Goto(String t_name){
		if(t_name.compareTo(f__currentName)==0){
			return;
		}
		f__previous=f__current;
		f__previousName=f__currentName;
		f__current=m_Get(t_name);
		f__currentName=t_name;
		m_DispatchOnCreate();
		bb_routerevents_RouterEvents t_tmpRouter=f_routers.m_Get(f__previousName);
		if((t_tmpRouter)!=null){
			t_tmpRouter.m_OnLeave();
		}
		t_tmpRouter=f_routers.m_Get(f__currentName);
		if((t_tmpRouter)!=null){
			t_tmpRouter.m_OnEnter();
		}
	}
	public void m_OnCreate(bb_director_Director t_director){
		this.f_director=t_director;
		m_DispatchOnCreate();
	}
	public void m_OnLoading(){
		if((f__current)!=null){
			f__current.m_OnLoading();
		}
	}
	public void m_OnUpdate(float t_delta,float t_frameTime){
		if((f__current)!=null){
			f__current.m_OnUpdate(t_delta,t_frameTime);
		}
	}
	public void m_OnRender(){
		if((f__current)!=null){
			f__current.m_OnRender();
		}
	}
	public void m_OnSuspend(){
		if((f__current)!=null){
			f__current.m_OnSuspend();
		}
	}
	public void m_OnResume(int t_delta){
		if((f__current)!=null){
			f__current.m_OnResume(t_delta);
		}
	}
	public void m_OnKeyDown(bb_keyevent_KeyEvent t_event){
		if((f__current)!=null){
			f__current.m_OnKeyDown(t_event);
		}
	}
	public void m_OnKeyPress(bb_keyevent_KeyEvent t_event){
		if((f__current)!=null){
			f__current.m_OnKeyPress(t_event);
		}
	}
	public void m_OnKeyUp(bb_keyevent_KeyEvent t_event){
		if((f__current)!=null){
			f__current.m_OnKeyUp(t_event);
		}
	}
	public void m_OnTouchDown(bb_touchevent_TouchEvent t_event){
		if((f__current)!=null){
			f__current.m_OnTouchDown(t_event);
		}
	}
	public void m_OnTouchMove(bb_touchevent_TouchEvent t_event){
		if((f__current)!=null){
			f__current.m_OnTouchMove(t_event);
		}
	}
	public void m_OnTouchUp(bb_touchevent_TouchEvent t_event){
		if((f__current)!=null){
			f__current.m_OnTouchUp(t_event);
		}
	}
	public bb_directorevents_DirectorEvents m_previous(){
		return f__previous;
	}
	public String m_previousName(){
		return f__previousName;
	}
}
abstract class bb_partial_Partial extends Object implements bb_directorevents_DirectorEvents{
	public bb_partial_Partial g_new(){
		return this;
	}
	bb_director_Director f__director=null;
	public void m_OnCreate(bb_director_Director t_director){
		f__director=t_director;
	}
	public bb_director_Director m_director(){
		return f__director;
	}
	public void m_OnRender(){
	}
	public void m_OnUpdate(float t_delta,float t_frameTime){
	}
	public void m_OnKeyUp(bb_keyevent_KeyEvent t_event){
	}
	public void m_OnLoading(){
	}
	public void m_OnSuspend(){
	}
	public void m_OnResume(int t_delta){
	}
	public void m_OnKeyDown(bb_keyevent_KeyEvent t_event){
	}
	public void m_OnKeyPress(bb_keyevent_KeyEvent t_event){
	}
	public void m_OnTouchDown(bb_touchevent_TouchEvent t_event){
	}
	public void m_OnTouchMove(bb_touchevent_TouchEvent t_event){
	}
	public void m_OnTouchUp(bb_touchevent_TouchEvent t_event){
	}
}
interface bb_routerevents_RouterEvents{
	public void m_OnLeave();
	public void m_OnEnter();
}
class bb_scene_Scene extends bb_partial_Partial implements bb_routerevents_RouterEvents{
	public bb_scene_Scene g_new(){
		super.g_new();
		return this;
	}
	public void m_OnEnter(){
	}
	public void m_OnLeave(){
	}
	bb_fanout_FanOut f__layer=(new bb_fanout_FanOut()).g_new();
	bb_router_Router f__router=null;
	static bb_graphics_Image g_blend;
	public void m_OnCreate(bb_director_Director t_director){
		super.m_OnCreate(t_director);
		f__layer.m_OnCreate(t_director);
		bb_directorevents_DirectorEvents t_=t_director.m_handler();
		f__router=(t_ instanceof bb_router_Router ? (bb_router_Router)t_ : null);
		if(!((g_blend)!=null)){
			g_blend=bb_graphics.bb_graphics_LoadImage("blend.png",1,bb_graphics_Image.g_DefaultFlags);
		}
	}
	public bb_fanout_FanOut m_layer(){
		return f__layer;
	}
	public void m_OnLoading(){
		f__layer.m_OnLoading();
	}
	public void m_OnUpdate(float t_delta,float t_frameTime){
		f__layer.m_OnUpdate(t_delta,t_frameTime);
	}
	public void m_OnRender(){
		f__layer.m_OnRender();
	}
	public void m_OnSuspend(){
		f__layer.m_OnSuspend();
	}
	public void m_OnResume(int t_delta){
		f__layer.m_OnResume(t_delta);
	}
	public void m_OnKeyDown(bb_keyevent_KeyEvent t_event){
		f__layer.m_OnKeyDown(t_event);
	}
	public void m_OnKeyPress(bb_keyevent_KeyEvent t_event){
		f__layer.m_OnKeyPress(t_event);
	}
	public void m_OnKeyUp(bb_keyevent_KeyEvent t_event){
		f__layer.m_OnKeyUp(t_event);
	}
	public void m_OnTouchDown(bb_touchevent_TouchEvent t_event){
		f__layer.m_OnTouchDown(t_event);
	}
	public void m_OnTouchMove(bb_touchevent_TouchEvent t_event){
		f__layer.m_OnTouchMove(t_event);
	}
	public void m_OnTouchUp(bb_touchevent_TouchEvent t_event){
		f__layer.m_OnTouchUp(t_event);
	}
	public bb_router_Router m_router(){
		return f__router;
	}
	public void m_RenderBlend(){
		for(int t_posY=0;(float)(t_posY)<m_director().m_size().f_y;t_posY=t_posY+8){
			bb_graphics.bb_graphics_DrawImage(g_blend,0.0f,(float)(t_posY),0);
		}
	}
}
class bb_introscene_IntroScene extends bb_scene_Scene{
	public bb_introscene_IntroScene g_new(){
		super.g_new();
		return this;
	}
	bb_sprite_Sprite f_background=null;
	public void m_OnCreate(bb_director_Director t_director){
		f_background=(new bb_sprite_Sprite()).g_new("logo.jpg",null);
		m_layer().m_Add4(f_background);
		super.m_OnCreate(t_director);
		f_background.m_Center(t_director);
	}
	int f_timer=0;
	public void m_OnUpdate(float t_delta,float t_frameTime){
		if(f_timer>=1500){
			m_router().m_Goto("menu");
		}
		f_timer=(int)((float)(f_timer)+t_frameTime);
	}
	public void m_OnRender(){
		bb_graphics.bb_graphics_Cls(255.0f,255.0f,255.0f);
		super.m_OnRender();
	}
}
abstract class bb_map_Map extends Object{
	public bb_map_Map g_new(){
		return this;
	}
	bb_map_Node f_root=null;
	abstract public int m_Compare(String t_lhs,String t_rhs);
	public bb_map_Node m_FindNode(String t_key){
		bb_map_Node t_node=f_root;
		while((t_node)!=null){
			int t_cmp=m_Compare(t_key,t_node.f_key);
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
	public boolean m_Contains(String t_key){
		return m_FindNode(t_key)!=null;
	}
	public int m_RotateLeft(bb_map_Node t_node){
		bb_map_Node t_child=t_node.f_right;
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
			f_root=t_child;
		}
		t_child.f_left=t_node;
		t_node.f_parent=t_child;
		return 0;
	}
	public int m_RotateRight(bb_map_Node t_node){
		bb_map_Node t_child=t_node.f_left;
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
			f_root=t_child;
		}
		t_child.f_right=t_node;
		t_node.f_parent=t_child;
		return 0;
	}
	public int m_InsertFixup(bb_map_Node t_node){
		while(((t_node.f_parent)!=null) && t_node.f_parent.f_color==-1 && ((t_node.f_parent.f_parent)!=null)){
			if(t_node.f_parent==t_node.f_parent.f_parent.f_left){
				bb_map_Node t_uncle=t_node.f_parent.f_parent.f_right;
				if(((t_uncle)!=null) && t_uncle.f_color==-1){
					t_node.f_parent.f_color=1;
					t_uncle.f_color=1;
					t_uncle.f_parent.f_color=-1;
					t_node=t_uncle.f_parent;
				}else{
					if(t_node==t_node.f_parent.f_right){
						t_node=t_node.f_parent;
						m_RotateLeft(t_node);
					}
					t_node.f_parent.f_color=1;
					t_node.f_parent.f_parent.f_color=-1;
					m_RotateRight(t_node.f_parent.f_parent);
				}
			}else{
				bb_map_Node t_uncle2=t_node.f_parent.f_parent.f_left;
				if(((t_uncle2)!=null) && t_uncle2.f_color==-1){
					t_node.f_parent.f_color=1;
					t_uncle2.f_color=1;
					t_uncle2.f_parent.f_color=-1;
					t_node=t_uncle2.f_parent;
				}else{
					if(t_node==t_node.f_parent.f_left){
						t_node=t_node.f_parent;
						m_RotateRight(t_node);
					}
					t_node.f_parent.f_color=1;
					t_node.f_parent.f_parent.f_color=-1;
					m_RotateLeft(t_node.f_parent.f_parent);
				}
			}
		}
		f_root.f_color=1;
		return 0;
	}
	public boolean m_Set(String t_key,bb_directorevents_DirectorEvents t_value){
		bb_map_Node t_node=f_root;
		bb_map_Node t_parent=null;
		int t_cmp=0;
		while((t_node)!=null){
			t_parent=t_node;
			t_cmp=m_Compare(t_key,t_node.f_key);
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
		t_node=(new bb_map_Node()).g_new(t_key,t_value,-1,t_parent);
		if((t_parent)!=null){
			if(t_cmp>0){
				t_parent.f_right=t_node;
			}else{
				t_parent.f_left=t_node;
			}
			m_InsertFixup(t_node);
		}else{
			f_root=t_node;
		}
		return true;
	}
	public bb_directorevents_DirectorEvents m_Get(String t_key){
		bb_map_Node t_node=m_FindNode(t_key);
		if((t_node)!=null){
			return t_node.f_value;
		}
		return null;
	}
}
class bb_map_StringMap extends bb_map_Map{
	public bb_map_StringMap g_new(){
		super.g_new();
		return this;
	}
	public int m_Compare(String t_lhs,String t_rhs){
		return t_lhs.compareTo(t_rhs);
	}
}
class bb_map_Node extends Object{
	String f_key="";
	bb_map_Node f_right=null;
	bb_map_Node f_left=null;
	bb_directorevents_DirectorEvents f_value=null;
	int f_color=0;
	bb_map_Node f_parent=null;
	public bb_map_Node g_new(String t_key,bb_directorevents_DirectorEvents t_value,int t_color,bb_map_Node t_parent){
		this.f_key=t_key;
		this.f_value=t_value;
		this.f_color=t_color;
		this.f_parent=t_parent;
		return this;
	}
	public bb_map_Node g_new2(){
		return this;
	}
}
abstract class bb_map_Map2 extends Object{
	public bb_map_Map2 g_new(){
		return this;
	}
	bb_map_Node2 f_root=null;
	abstract public int m_Compare(String t_lhs,String t_rhs);
	public int m_RotateLeft2(bb_map_Node2 t_node){
		bb_map_Node2 t_child=t_node.f_right;
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
			f_root=t_child;
		}
		t_child.f_left=t_node;
		t_node.f_parent=t_child;
		return 0;
	}
	public int m_RotateRight2(bb_map_Node2 t_node){
		bb_map_Node2 t_child=t_node.f_left;
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
			f_root=t_child;
		}
		t_child.f_right=t_node;
		t_node.f_parent=t_child;
		return 0;
	}
	public int m_InsertFixup2(bb_map_Node2 t_node){
		while(((t_node.f_parent)!=null) && t_node.f_parent.f_color==-1 && ((t_node.f_parent.f_parent)!=null)){
			if(t_node.f_parent==t_node.f_parent.f_parent.f_left){
				bb_map_Node2 t_uncle=t_node.f_parent.f_parent.f_right;
				if(((t_uncle)!=null) && t_uncle.f_color==-1){
					t_node.f_parent.f_color=1;
					t_uncle.f_color=1;
					t_uncle.f_parent.f_color=-1;
					t_node=t_uncle.f_parent;
				}else{
					if(t_node==t_node.f_parent.f_right){
						t_node=t_node.f_parent;
						m_RotateLeft2(t_node);
					}
					t_node.f_parent.f_color=1;
					t_node.f_parent.f_parent.f_color=-1;
					m_RotateRight2(t_node.f_parent.f_parent);
				}
			}else{
				bb_map_Node2 t_uncle2=t_node.f_parent.f_parent.f_left;
				if(((t_uncle2)!=null) && t_uncle2.f_color==-1){
					t_node.f_parent.f_color=1;
					t_uncle2.f_color=1;
					t_uncle2.f_parent.f_color=-1;
					t_node=t_uncle2.f_parent;
				}else{
					if(t_node==t_node.f_parent.f_left){
						t_node=t_node.f_parent;
						m_RotateRight2(t_node);
					}
					t_node.f_parent.f_color=1;
					t_node.f_parent.f_parent.f_color=-1;
					m_RotateLeft2(t_node.f_parent.f_parent);
				}
			}
		}
		f_root.f_color=1;
		return 0;
	}
	public boolean m_Set2(String t_key,bb_routerevents_RouterEvents t_value){
		bb_map_Node2 t_node=f_root;
		bb_map_Node2 t_parent=null;
		int t_cmp=0;
		while((t_node)!=null){
			t_parent=t_node;
			t_cmp=m_Compare(t_key,t_node.f_key);
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
		t_node=(new bb_map_Node2()).g_new(t_key,t_value,-1,t_parent);
		if((t_parent)!=null){
			if(t_cmp>0){
				t_parent.f_right=t_node;
			}else{
				t_parent.f_left=t_node;
			}
			m_InsertFixup2(t_node);
		}else{
			f_root=t_node;
		}
		return true;
	}
	public bb_map_Node2 m_FindNode(String t_key){
		bb_map_Node2 t_node=f_root;
		while((t_node)!=null){
			int t_cmp=m_Compare(t_key,t_node.f_key);
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
	public bb_routerevents_RouterEvents m_Get(String t_key){
		bb_map_Node2 t_node=m_FindNode(t_key);
		if((t_node)!=null){
			return t_node.f_value;
		}
		return null;
	}
}
class bb_map_StringMap2 extends bb_map_Map2{
	public bb_map_StringMap2 g_new(){
		super.g_new();
		return this;
	}
	public int m_Compare(String t_lhs,String t_rhs){
		return t_lhs.compareTo(t_rhs);
	}
}
class bb_map_Node2 extends Object{
	String f_key="";
	bb_map_Node2 f_right=null;
	bb_map_Node2 f_left=null;
	bb_routerevents_RouterEvents f_value=null;
	int f_color=0;
	bb_map_Node2 f_parent=null;
	public bb_map_Node2 g_new(String t_key,bb_routerevents_RouterEvents t_value,int t_color,bb_map_Node2 t_parent){
		this.f_key=t_key;
		this.f_value=t_value;
		this.f_color=t_color;
		this.f_parent=t_parent;
		return this;
	}
	public bb_map_Node2 g_new2(){
		return this;
	}
}
class bb_menuscene_MenuScene extends bb_scene_Scene{
	public bb_menuscene_MenuScene g_new(){
		super.g_new();
		return this;
	}
	bb_sprite_Sprite f_easy=null;
	bb_sprite_Sprite f_normal=null;
	bb_sprite_Sprite f_normalActive=null;
	bb_sprite_Sprite f_advanced=null;
	bb_sprite_Sprite f_advancedActive=null;
	bb_sprite_Sprite f_highscore=null;
	bb_sprite_Sprite f_lock=null;
	bb_menuscene_FullVersion f_fullVersion=null;
	bb_service_PaymentService f_paymentService=null;
	boolean f_isLocked=true;
	public void m_ToggleLock(){
		if(f_isLocked){
			f_isLocked=false;
			m_layer().m_Remove(f_lock);
			m_layer().m_Remove(f_normal);
			m_layer().m_Remove(f_advanced);
			m_layer().m_Add4(f_normalActive);
			m_layer().m_Add4(f_advancedActive);
		}else{
			f_isLocked=true;
			m_layer().m_Remove(f_normalActive);
			m_layer().m_Remove(f_advancedActive);
			m_layer().m_Add4(f_normal);
			m_layer().m_Add4(f_advanced);
			m_layer().m_Add4(f_lock);
		}
	}
	public void m_OnCreate(bb_director_Director t_director){
		bb_vector2d_Vector2D t_offset=(new bb_vector2d_Vector2D()).g_new(0.0f,150.0f);
		f_easy=(new bb_sprite_Sprite()).g_new("01_02-easy.png",(new bb_vector2d_Vector2D()).g_new(0.0f,290.0f));
		f_normal=(new bb_sprite_Sprite()).g_new("01_02-normal.png",f_easy.m_pos().m_Copy().m_Add2(t_offset));
		f_normalActive=(new bb_sprite_Sprite()).g_new("01_02-normal_active.png",f_normal.m_pos());
		f_advanced=(new bb_sprite_Sprite()).g_new("01_02-advanced.png",f_normal.m_pos().m_Copy().m_Add2(t_offset));
		f_advancedActive=(new bb_sprite_Sprite()).g_new("01_02-advanced_active.png",f_advanced.m_pos());
		f_highscore=(new bb_sprite_Sprite()).g_new("01_04button-highscore.png",f_advanced.m_pos().m_Copy().m_Add2(t_offset));
		bb_vector2d_Vector2D t_pos=f_advanced.m_pos().m_Copy().m_Add2(f_advanced.m_size()).m_Sub(f_normal.m_pos()).m_Div2(2.0f);
		t_pos.f_y+=f_normal.m_pos().f_y;
		f_lock=(new bb_sprite_Sprite()).g_new("locked.png",t_pos);
		f_lock.m_pos().f_y-=f_lock.m_center().f_y;
		m_layer().m_Add4((new bb_sprite_Sprite()).g_new("01_main.jpg",null));
		m_layer().m_Add4(f_easy);
		m_layer().m_Add4(f_normal);
		m_layer().m_Add4(f_advanced);
		m_layer().m_Add4(f_highscore);
		m_layer().m_Add4(f_lock);
		super.m_OnCreate(t_director);
		f_easy.m_CenterX(t_director);
		f_normal.m_CenterX(t_director);
		f_advanced.m_CenterX(t_director);
		f_highscore.m_CenterX(t_director);
		f_fullVersion=(new bb_menuscene_FullVersion()).g_new();
		f_paymentService=(new bb_service_PaymentService()).g_new();
		f_paymentService.m_SetBundleId("com.coragames.daffydrop");
		f_paymentService.m_SetPublicKey("");
		f_paymentService.m_AddProduct(f_fullVersion);
		f_paymentService.m_StartService();
		f_fullVersion.m_UpdatePurchasedState();
		if(f_fullVersion.m_IsProductPurchased()){
			m_ToggleLock();
		}
		bb_appirater_Appirater.g_Launched();
	}
	public void m_OnResume(int t_delta){
		bb_appirater_Appirater.g_Launched();
	}
	boolean f_paymentProcessing=false;
	public void m_PlayEasy(){
		bb_severity.bb_severity_CurrentSeverity().m_Set5(0);
		m_router().m_Goto("game");
	}
	bb_font_Font f_waitingText=null;
	bb_sprite_Sprite f_waitingImage=null;
	public void m_InitializeWaitingImages(){
		f_waitingText=(new bb_font_Font()).g_new("CoRa",null);
		f_waitingText.m_OnCreate(m_director());
		f_waitingText.m_text("Loading");
		f_waitingText.m_align(1);
		f_waitingText.m_pos2(m_director().m_center().m_Copy());
		f_waitingImage=(new bb_sprite_Sprite()).g_new("star_inside.png",null);
		f_waitingImage.m_OnCreate(m_director());
		f_waitingImage.m_Center(m_director());
		bb_vector2d_Vector2D t_=f_waitingImage.m_pos();
		t_.f_y=t_.f_y-50.0f;
	}
	public void m_HandleLocked(){
		if(f_paymentProcessing){
			return;
		}
		if(!f_isLocked){
			return;
		}
		m_InitializeWaitingImages();
		f_paymentProcessing=true;
		f_fullVersion.m_Buy();
	}
	public void m_PlayNormal(){
		if(f_isLocked){
			m_HandleLocked();
			return;
		}
		bb_severity.bb_severity_CurrentSeverity().m_Set5(1);
		m_router().m_Goto("game");
	}
	public void m_PlayAdvanced(){
		if(f_isLocked){
			m_HandleLocked();
			return;
		}
		bb_severity.bb_severity_CurrentSeverity().m_Set5(2);
		m_router().m_Goto("game");
	}
	public void m_OnTouchDown(bb_touchevent_TouchEvent t_event){
		if(f_paymentProcessing){
			return;
		}
		if(f_easy.m_Collide(t_event.m_pos())){
			m_PlayEasy();
		}
		if(f_normal.m_Collide(t_event.m_pos())){
			m_PlayNormal();
		}
		if(f_advanced.m_Collide(t_event.m_pos())){
			m_PlayAdvanced();
		}
		if(f_highscore.m_Collide(t_event.m_pos())){
			m_router().m_Goto("highscore");
		}
		if(f_lock.m_Collide(t_event.m_pos())){
			m_HandleLocked();
		}
	}
	public void m_OnKeyDown(bb_keyevent_KeyEvent t_event){
		if(f_paymentProcessing){
			return;
		}
		int t_1=t_event.m_code();
		if(t_1==69){
			m_PlayEasy();
		}else{
			if(t_1==78){
				m_PlayNormal();
			}else{
				if(t_1==65){
					m_PlayAdvanced();
				}else{
					if(t_1==72){
						m_router().m_Goto("highscore");
					}
				}
			}
		}
	}
	public void m_OnUpdate(float t_delta,float t_frameTime){
		super.m_OnUpdate(t_delta,t_frameTime);
		if(!f_isLocked){
			return;
		}
		if(!f_paymentProcessing){
			return;
		}
		if(f_paymentService.m_IsPurchaseInProgress()){
			return;
		}
		f_paymentProcessing=false;
		if(!f_fullVersion.m_IsProductPurchased()){
			return;
		}
		m_ToggleLock();
	}
	public void m_OnRender(){
		super.m_OnRender();
		if(f_paymentProcessing){
			m_RenderBlend();
			bb_graphics.bb_graphics_PushMatrix();
			bb_graphics.bb_graphics_Translate(-m_director().m_center().f_x,-m_director().m_center().f_y);
			bb_graphics.bb_graphics_Scale(2.0f,2.0f);
			f_waitingImage.m_OnRender();
			bb_graphics.bb_graphics_PushMatrix();
			bb_graphics.bb_graphics_Translate(-2.0f,1.0f);
			bb_graphics.bb_graphics_SetColor(47.0f,85.0f,98.0f);
			f_waitingText.m_OnRender();
			bb_graphics.bb_graphics_PopMatrix();
			bb_graphics.bb_graphics_PushMatrix();
			bb_graphics.bb_graphics_SetColor(255.0f,255.0f,255.0f);
			f_waitingText.m_OnRender();
			bb_graphics.bb_graphics_PopMatrix();
			bb_graphics.bb_graphics_PopMatrix();
		}
	}
}
class bb_highscorescene_HighscoreScene extends bb_scene_Scene implements bb_routerevents_RouterEvents{
	public bb_highscorescene_HighscoreScene g_new(){
		super.g_new();
		return this;
	}
	bb_angelfont2_AngelFont f_font=null;
	bb_sprite_Sprite f_background=null;
	public void m_OnCreate(bb_director_Director t_director){
		f_font=(new bb_angelfont2_AngelFont()).g_new("CoRa");
		f_background=(new bb_sprite_Sprite()).g_new("highscore_bg.jpg",null);
		f_background.m_OnCreate(t_director);
		super.m_OnCreate(t_director);
	}
	bb_gamehighscore_GameHighscore f_highscore=(new bb_gamehighscore_GameHighscore()).g_new();
	public void m_OnEnter(){
		bb_statestore_StateStore.g_Load(f_highscore);
	}
	int f_lastScoreValue=0;
	String f_lastScoreKey="";
	public void m_OnLeave(){
		f_lastScoreValue=0;
		f_lastScoreKey="";
	}
	float f_disableTimer=.0f;
	public void m_OnUpdate(float t_delta,float t_frameTime){
		f_disableTimer+=t_frameTime;
		if(f_disableTimer>=500.0f){
			m_director().m_inputController().f_trackKeys=false;
		}
	}
	public void m_DrawEntries(){
		int t_posY=290;
		boolean t_found=false;
		bb_list_Enumerator4 t_=f_highscore.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_score_Score t_score=t_.m_NextObject();
			if(!t_found && t_score.f_value==f_lastScoreValue && (t_score.f_key.compareTo(f_lastScoreKey)==0)){
				bb_graphics.bb_graphics_SetColor(3.0f,105.0f,187.0f);
			}
			f_font.m_DrawText2(String.valueOf(t_score.f_value),150,t_posY,2);
			f_font.m_DrawText(t_score.f_key,160,t_posY);
			t_posY+=55;
			if(!t_found && t_score.f_value==f_lastScoreValue && (t_score.f_key.compareTo(f_lastScoreKey)==0)){
				bb_graphics.bb_graphics_SetColor(95.0f,85.0f,83.0f);
				t_found=true;
			}
		}
	}
	public void m_OnRender(){
		f_background.m_OnRender();
		bb_graphics.bb_graphics_PushMatrix();
		bb_graphics.bb_graphics_SetColor(95.0f,85.0f,83.0f);
		m_DrawEntries();
		bb_graphics.bb_graphics_PopMatrix();
	}
	public void m_OnKeyDown(bb_keyevent_KeyEvent t_event){
		m_router().m_Goto("menu");
	}
	public void m_OnTouchDown(bb_touchevent_TouchEvent t_event){
		m_router().m_Goto("menu");
	}
}
class bb_gamescene_GameScene extends bb_scene_Scene implements bb_routerevents_RouterEvents{
	public bb_gamescene_GameScene g_new(){
		super.g_new();
		return this;
	}
	bb_chute_Chute f_chute=null;
	bb_fanout_FanOut f_lowerShapes=null;
	bb_severity_Severity f_severity=null;
	bb_slider_Slider f_slider=null;
	bb_fanout_FanOut f_upperShapes=null;
	bb_fanout_FanOut f_errorAnimations=null;
	bb_sprite_Sprite f_pauseButton=null;
	bb_font_Font f_scoreFont=null;
	bb_font_Font f_comboFont=null;
	bb_animation_Animation f_comboAnimation=null;
	bb_font_Font f_newHighscoreFont=null;
	bb_animation_Animation f_newHighscoreAnimation=null;
	float f_checkPosY=.0f;
	public void m_OnCreate(bb_director_Director t_director){
		f_chute=(new bb_chute_Chute()).g_new();
		f_lowerShapes=(new bb_fanout_FanOut()).g_new();
		f_severity=bb_severity.bb_severity_CurrentSeverity();
		f_slider=(new bb_slider_Slider()).g_new();
		f_upperShapes=(new bb_fanout_FanOut()).g_new();
		f_errorAnimations=(new bb_fanout_FanOut()).g_new();
		f_pauseButton=(new bb_sprite_Sprite()).g_new("pause-button.png",null);
		f_pauseButton.m_pos2(t_director.m_size().m_Copy().m_Sub(f_pauseButton.m_size()));
		f_pauseButton.m_pos().f_y=0.0f;
		f_scoreFont=(new bb_font_Font()).g_new("CoRa",null);
		f_scoreFont.m_pos2((new bb_vector2d_Vector2D()).g_new(t_director.m_center().f_x,t_director.m_size().f_y-65.0f));
		f_scoreFont.m_align(1);
		f_scoreFont.f_color=(new bb_color_Color()).g_new(3.0f,105.0f,187.0f,1.0f);
		f_comboFont=(new bb_font_Font()).g_new("CoRa",t_director.m_center().m_Copy());
		f_comboFont.f_color=(new bb_color_Color()).g_new(3.0f,105.0f,187.0f,1.0f);
		f_comboFont.m_text("COMBO x 2");
		bb_vector2d_Vector2D t_=f_comboFont.m_pos();
		t_.f_y=t_.f_y-150.0f;
		bb_vector2d_Vector2D t_2=f_comboFont.m_pos();
		t_2.f_x=t_2.f_x-130.0f;
		f_comboAnimation=(new bb_animation_Animation()).g_new(1.8f,0.0f,850.0f);
		f_comboAnimation.f_effect=((new bb_fader_FaderScale()).g_new());
		f_comboAnimation.f_transition=((new bb_transition_TransitionInCubic()).g_new());
		f_comboAnimation.m_Add4(f_comboFont);
		f_comboAnimation.m_Pause();
		f_newHighscoreFont=(new bb_font_Font()).g_new("CoRa",t_director.m_center().m_Copy());
		f_newHighscoreFont.f_color=(new bb_color_Color()).g_new(209.0f,146.0f,31.0f,1.0f);
		f_newHighscoreFont.m_text("NEW HIGHSCORE");
		bb_vector2d_Vector2D t_3=f_newHighscoreFont.m_pos();
		t_3.f_y=t_3.f_y/2.0f;
		bb_vector2d_Vector2D t_4=f_newHighscoreFont.m_pos();
		t_4.f_x=t_4.f_x-200.0f;
		f_newHighscoreAnimation=(new bb_animation_Animation()).g_new(1.5f,0.0f,2500.0f);
		f_newHighscoreAnimation.f_effect=((new bb_fader_FaderScale()).g_new());
		f_newHighscoreAnimation.f_transition=((new bb_transition_TransitionInCubic()).g_new());
		f_newHighscoreAnimation.m_Add4(f_newHighscoreFont);
		f_newHighscoreAnimation.m_Pause();
		m_layer().m_Add4((new bb_sprite_Sprite()).g_new("bg_960x640.jpg",null));
		m_layer().m_Add4(f_lowerShapes);
		m_layer().m_Add4(f_slider);
		m_layer().m_Add4(f_upperShapes);
		m_layer().m_Add4(f_errorAnimations);
		m_layer().m_Add4(f_newHighscoreAnimation);
		m_layer().m_Add4(f_comboAnimation);
		m_layer().m_Add4(f_chute);
		m_layer().m_Add4(f_scoreFont);
		m_layer().m_Add4(f_pauseButton);
		super.m_OnCreate(t_director);
		f_checkPosY=t_director.m_size().f_y-(float)(f_slider.f_images[0].m_Height()/2)-5.0f;
	}
	int f_pauseTime=0;
	public void m_OnEnterPaused(){
		int t_diff=bb_app.bb_app_Millisecs()-f_pauseTime;
		f_pauseTime=0;
		f_severity.m_WarpTime(t_diff);
	}
	boolean f_ignoreFirstTouchUp=false;
	int f_score=0;
	int f_minHighscore=0;
	boolean f_isNewHighscoreRecord=false;
	public void m_LoadHighscoreMinValue(){
		bb_gamehighscore_GameHighscore t_highscore=(new bb_gamehighscore_GameHighscore()).g_new();
		bb_statestore_StateStore.g_Load(t_highscore);
		f_minHighscore=t_highscore.m_Last().f_value;
		f_isNewHighscoreRecord=!(t_highscore.m_Count()==t_highscore.m_maxCount());
	}
	public void m_OnEnter(){
		if(f_pauseTime>0){
			m_OnEnterPaused();
			return;
		}
		f_ignoreFirstTouchUp=true;
		f_score=0;
		f_scoreFont.m_text("Score: 0");
		f_lowerShapes.m_Clear();
		f_upperShapes.m_Clear();
		f_errorAnimations.m_Clear();
		f_severity.m_Restart();
		f_chute.m_Restart();
		f_slider.m_Restart();
		m_LoadHighscoreMinValue();
	}
	public void m_OnLeave(){
	}
	public boolean m_HandleGameOver(){
		if((float)(f_chute.m_Height())<f_slider.f_arrowLeft.m_pos().f_y+50.0f){
			return false;
		}
		if(f_isNewHighscoreRecord){
			m_director().m_inputController().f_trackKeys=true;
			bb_directorevents_DirectorEvents t_=m_router().m_Get("newhighscore");
			(t_ instanceof bb_newhighscorescene_NewHighscoreScene ? (bb_newhighscorescene_NewHighscoreScene)t_ : null).f_score=f_score;
			m_router().m_Goto("newhighscore");
		}else{
			m_router().m_Goto("gameover");
		}
		return true;
	}
	boolean f_collisionCheckedLastUpdate=false;
	bb_stack_Stack2 f_falseSpriteStrack=(new bb_stack_Stack2()).g_new();
	int[] f_lastMatchTime=new int[]{0,0,0,0};
	boolean f_comboPending=false;
	int f_comboPendingSince=0;
	public void m_OnMissmatch(bb_shape_Shape t_shape){
		bb_sprite_Sprite t_sprite=null;
		if(f_falseSpriteStrack.m_Length()>0){
			t_sprite=f_falseSpriteStrack.m_Pop();
		}else{
			t_sprite=(new bb_sprite_Sprite()).g_new2("false.png",140,88,6,100,null);
		}
		t_sprite.m_pos2(t_shape.m_pos());
		t_sprite.m_Restart();
		f_chute.f_height+=15;
		f_lastMatchTime=new int[]{0,0,0,0};
		f_comboPending=false;
		f_comboPendingSince=0;
		f_errorAnimations.m_Add4(t_sprite);
	}
	public void m_IncrementScore(int t_value){
		f_score+=t_value;
		f_scoreFont.m_text("Score: "+String.valueOf(f_score));
		if(!f_isNewHighscoreRecord && f_score>=f_minHighscore){
			f_isNewHighscoreRecord=true;
			f_newHighscoreAnimation.m_Restart();
			m_layer().m_Add4(f_newHighscoreAnimation);
		}
	}
	public void m_OnMatch(bb_shape_Shape t_shape){
		f_lastMatchTime[t_shape.f_lane]=bb_app.bb_app_Millisecs();
		m_IncrementScore(10);
	}
	public void m_CheckShapeCollisions(){
		bb_shape_Shape t_shape=null;
		bb_list_Enumerator t_=f_upperShapes.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_directorevents_DirectorEvents t_obj=t_.m_NextObject();
			bb_directorevents_DirectorEvents t_2=t_obj;
			t_shape=(t_2 instanceof bb_shape_Shape ? (bb_shape_Shape)t_2 : null);
			if(t_shape.m_pos().f_y+(float)(bb_shape_Shape.g_images[0].m_Height())<f_checkPosY){
				continue;
			}
			f_upperShapes.m_Remove(t_shape);
			if(!f_slider.m_Match(t_shape)){
				m_OnMissmatch(t_shape);
			}else{
				f_lowerShapes.m_Add4(t_shape);
				m_OnMatch(t_shape);
			}
		}
	}
	public void m_DetectComboTrigger(){
		int t_lanesNotZero=0;
		int t_hotLanes=0;
		int t_now=bb_app.bb_app_Millisecs();
		for(int t_lane=0;t_lane<bb_std_lang.arrayLength(f_lastMatchTime);t_lane=t_lane+1){
			if(f_lastMatchTime[t_lane]==0){
				continue;
			}
			t_lanesNotZero+=1;
			if(f_lastMatchTime[t_lane]+325>=t_now){
				t_hotLanes+=1;
				if(t_hotLanes>=2 && !f_comboPending){
					f_comboPending=true;
					f_comboPendingSince=t_now;
				}
			}else{
				if(!f_comboPending){
					f_lastMatchTime[t_lane]=0;
				}
			}
		}
		if(!f_comboPending){
			return;
		}
		if(f_comboPendingSince+325>t_now){
			return;
		}
		f_lastMatchTime=new int[]{0,0,0,0};
		f_comboPending=false;
		f_chute.f_height=bb_math.bb_math_Max(75,f_chute.f_height-18*t_lanesNotZero);
		m_IncrementScore(15*t_lanesNotZero);
		f_comboFont.m_text("COMBO x "+String.valueOf(t_lanesNotZero));
		f_comboAnimation.m_Restart();
		m_layer().m_Add4(f_comboAnimation);
	}
	public void m_DropNewShapeIfRequested(){
		if(!f_severity.m_ShapeShouldBeDropped()){
			return;
		}
		f_upperShapes.m_Add4((new bb_shape_Shape()).g_new(f_severity.m_RandomType(),f_severity.m_RandomLane(),f_chute));
		f_severity.m_ShapeDropped();
	}
	float f_lastSlowUpdate=.0f;
	public void m_RemoveLostShapes(){
		float t_directoySizeY=m_director().m_size().f_y;
		bb_shape_Shape t_shape=null;
		bb_list_Enumerator t_=f_lowerShapes.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_directorevents_DirectorEvents t_obj=t_.m_NextObject();
			bb_directorevents_DirectorEvents t_2=t_obj;
			t_shape=(t_2 instanceof bb_shape_Shape ? (bb_shape_Shape)t_2 : null);
			if(t_shape.m_pos().f_y>t_directoySizeY){
				f_lowerShapes.m_Remove(t_shape);
			}
		}
	}
	public void m_RemoveFinishedErroAnimations(){
		bb_sprite_Sprite t_sprite=null;
		bb_list_Enumerator t_=f_errorAnimations.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_directorevents_DirectorEvents t_obj=t_.m_NextObject();
			bb_directorevents_DirectorEvents t_2=t_obj;
			t_sprite=(t_2 instanceof bb_sprite_Sprite ? (bb_sprite_Sprite)t_2 : null);
			if(t_sprite.m_animationIsDone()){
				f_errorAnimations.m_Remove(t_sprite);
				f_falseSpriteStrack.m_Push2(t_sprite);
			}
		}
	}
	public void m_OnUpdate(float t_delta,float t_frameTime){
		super.m_OnUpdate(t_delta,t_frameTime);
		if(m_HandleGameOver()){
			return;
		}
		if(f_collisionCheckedLastUpdate){
			f_collisionCheckedLastUpdate=false;
		}else{
			f_collisionCheckedLastUpdate=true;
			m_CheckShapeCollisions();
		}
		m_DetectComboTrigger();
		f_severity.m_OnUpdate(t_delta,t_frameTime);
		m_DropNewShapeIfRequested();
		f_lastSlowUpdate+=t_frameTime;
		if(f_lastSlowUpdate>=1000.0f){
			f_lastSlowUpdate=0.0f;
			m_RemoveLostShapes();
			m_RemoveFinishedErroAnimations();
			if(!f_comboAnimation.m_IsPlaying()){
				m_layer().m_Remove(f_comboAnimation);
			}
			if(!f_newHighscoreAnimation.m_IsPlaying()){
				m_layer().m_Remove(f_newHighscoreAnimation);
			}
		}
	}
	public void m_StartPause(){
		f_pauseTime=bb_app.bb_app_Millisecs();
		m_router().m_Goto("pause");
	}
	public void m_FastDropMatchingShapes(){
		bb_shape_Shape t_shape=null;
		bb_list_Enumerator t_=f_upperShapes.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_directorevents_DirectorEvents t_obj=t_.m_NextObject();
			bb_directorevents_DirectorEvents t_2=t_obj;
			t_shape=(t_2 instanceof bb_shape_Shape ? (bb_shape_Shape)t_2 : null);
			if(t_shape.f_isFast){
				continue;
			}
			if(f_slider.m_Match(t_shape)){
				t_shape.f_isFast=true;
			}
		}
	}
	public void m_OnKeyDown(bb_keyevent_KeyEvent t_event){
		int t_1=t_event.m_code();
		if(t_1==80){
			m_StartPause();
		}else{
			if(t_1==40 || t_1==65576){
				m_FastDropMatchingShapes();
			}else{
				if(t_1==37 || t_1==65573){
					f_slider.m_SlideLeft();
				}else{
					if(t_1==39 || t_1==65575){
						f_slider.m_SlideRight();
					}
				}
			}
		}
	}
	public void m_OnSuspend(){
		m_StartPause();
	}
	public void m_OnTouchDown(bb_touchevent_TouchEvent t_event){
		if(f_pauseButton.m_Collide(t_event.m_pos())){
			m_StartPause();
		}
		if(f_slider.f_arrowRight.m_Collide(t_event.m_pos())){
			f_slider.m_SlideRight();
		}
		if(f_slider.f_arrowLeft.m_Collide(t_event.m_pos())){
			f_slider.m_SlideLeft();
		}
	}
	public void m_HandleSliderSwipe(bb_touchevent_TouchEvent t_event){
		bb_vector2d_Vector2D t_swipe=t_event.m_startDelta().m_Normalize();
		if(bb_math.bb_math_Abs2(t_swipe.f_x)<=0.4f){
			return;
		}
		if(t_swipe.f_x<0.0f){
			f_slider.m_SlideLeft();
		}else{
			f_slider.m_SlideRight();
		}
	}
	public void m_HandleBackgroundSwipe(bb_touchevent_TouchEvent t_event){
		bb_vector2d_Vector2D t_swipe=t_event.m_startDelta().m_Normalize();
		if(t_swipe.f_y>0.2f){
			m_FastDropMatchingShapes();
		}
	}
	public void m_OnTouchUp(bb_touchevent_TouchEvent t_event){
		if(f_ignoreFirstTouchUp){
			f_ignoreFirstTouchUp=false;
			return;
		}
		if(t_event.m_startPos().f_y>=f_slider.m_pos().f_y){
			m_HandleSliderSwipe(t_event);
		}else{
			m_HandleBackgroundSwipe(t_event);
		}
	}
	public void m_OnTouchMove(bb_touchevent_TouchEvent t_event){
	}
	public void m_OnPauseLeaveGame(){
		f_pauseTime=0;
	}
}
class bb_gameoverscene_GameOverScene extends bb_scene_Scene{
	public bb_gameoverscene_GameOverScene g_new(){
		super.g_new();
		return this;
	}
	bb_sprite_Sprite f_main=null;
	bb_sprite_Sprite f_small=null;
	public void m_OnCreate(bb_director_Director t_director){
		super.m_OnCreate(t_director);
		f_main=(new bb_sprite_Sprite()).g_new("gameover_main.png",null);
		f_main.m_OnCreate(t_director);
		f_main.m_Center(t_director);
		f_small=(new bb_sprite_Sprite()).g_new("gameover_small.png",null);
		f_small.m_OnCreate(t_director);
		f_small.m_pos().f_x=t_director.m_size().f_x-f_small.m_size().f_x;
	}
	public void m_OnRender(){
		m_router().m_previous().m_OnRender();
		m_RenderBlend();
		f_small.m_OnRender();
		f_main.m_OnRender();
	}
	public void m_OnTouchDown(bb_touchevent_TouchEvent t_event){
		m_router().m_Goto("menu");
	}
	public void m_OnKeyDown(bb_keyevent_KeyEvent t_event){
		m_router().m_Goto("menu");
	}
}
class bb_pausescene_PauseScene extends bb_scene_Scene{
	public bb_pausescene_PauseScene g_new(){
		super.g_new();
		return this;
	}
	bb_sprite_Sprite f_overlay=null;
	bb_sprite_Sprite f_continueBtn=null;
	bb_sprite_Sprite f_quitBtn=null;
	public void m_OnCreate(bb_director_Director t_director){
		f_overlay=(new bb_sprite_Sprite()).g_new("pause.png",null);
		m_layer().m_Add4(f_overlay);
		f_continueBtn=(new bb_sprite_Sprite()).g_new("01_06-continue.png",null);
		m_layer().m_Add4(f_continueBtn);
		f_quitBtn=(new bb_sprite_Sprite()).g_new("01_07-quit.png",null);
		m_layer().m_Add4(f_quitBtn);
		super.m_OnCreate(t_director);
	}
	public void m_OnEnter(){
		f_overlay.m_Center(m_director());
		f_overlay.m_pos().f_y-=f_overlay.m_size().f_y;
		bb_vector2d_Vector2D t_=f_overlay.m_pos();
		t_.f_y=t_.f_y-50.0f;
		f_continueBtn.m_Center(m_director());
		f_quitBtn.m_pos2(f_continueBtn.m_pos().m_Copy());
		f_quitBtn.m_pos().f_y+=f_continueBtn.m_size().f_y+40.0f;
	}
	public void m_OnRender(){
		m_router().m_previous().m_OnRender();
		m_RenderBlend();
		super.m_OnRender();
	}
	public void m_OnKeyDown(bb_keyevent_KeyEvent t_event){
		int t_1=t_event.m_code();
		if(t_1==27 || t_1==81){
			bb_directorevents_DirectorEvents t_=m_router().m_previous();
			(t_ instanceof bb_gamescene_GameScene ? (bb_gamescene_GameScene)t_ : null).m_OnPauseLeaveGame();
			m_router().m_Goto("menu");
		}else{
			m_router().m_Goto(m_router().m_previousName());
		}
	}
	public void m_OnTouchDown(bb_touchevent_TouchEvent t_event){
		if(f_continueBtn.m_Collide(t_event.m_pos())){
			m_router().m_Goto(m_router().m_previousName());
		}
		if(f_quitBtn.m_Collide(t_event.m_pos())){
			bb_directorevents_DirectorEvents t_=m_router().m_previous();
			(t_ instanceof bb_gamescene_GameScene ? (bb_gamescene_GameScene)t_ : null).m_OnPauseLeaveGame();
			m_router().m_Goto("menu");
		}
	}
}
class bb_newhighscorescene_NewHighscoreScene extends bb_scene_Scene{
	public bb_newhighscorescene_NewHighscoreScene g_new(){
		super.g_new();
		return this;
	}
	bb_textinput_TextInput f_input=null;
	public void m_OnCreate(bb_director_Director t_director){
		bb_sprite_Sprite t_background=(new bb_sprite_Sprite()).g_new("newhighscore.png",null);
		t_background.m_pos().f_y=40.0f;
		m_layer().m_Add4(t_background);
		f_input=(new bb_textinput_TextInput()).g_new("CoRa",(new bb_vector2d_Vector2D()).g_new(110.0f,415.0f));
		f_input.f_color=(new bb_color_Color()).g_new(3.0f,105.0f,187.0f,1.0f);
		m_layer().m_Add4(f_input);
		super.m_OnCreate(t_director);
	}
	int f_score=0;
	public void m_OnRender(){
		m_router().m_previous().m_OnRender();
		m_RenderBlend();
		super.m_OnRender();
	}
	bb_gamehighscore_GameHighscore f_highscore=(new bb_gamehighscore_GameHighscore()).g_new();
	public void m_SaveAndContinue(){
		String t_level=bb_severity.bb_severity_CurrentSeverity().m_ToString()+" ";
		bb_statestore_StateStore.g_Load(f_highscore);
		f_highscore.m_Add5(t_level+f_input.m_text2(),f_score);
		bb_statestore_StateStore.g_Save(f_highscore);
		bb_directorevents_DirectorEvents t_=m_router().m_Get("highscore");
		(t_ instanceof bb_highscorescene_HighscoreScene ? (bb_highscorescene_HighscoreScene)t_ : null).f_lastScoreKey=t_level+f_input.m_text2();
		bb_directorevents_DirectorEvents t_2=m_router().m_Get("highscore");
		(t_2 instanceof bb_highscorescene_HighscoreScene ? (bb_highscorescene_HighscoreScene)t_2 : null).f_lastScoreValue=f_score;
		m_router().m_Goto("highscore");
	}
	public void m_OnKeyDown(bb_keyevent_KeyEvent t_event){
		super.m_OnKeyDown(t_event);
		if(t_event.m_code()==13){
			m_SaveAndContinue();
		}
	}
}
class bb_app_App extends Object{
	public bb_app_App g_new(){
		bb_app.bb_app_device=(new bb_app_AppDevice()).g_new(this);
		return this;
	}
	public int m_OnCreate2(){
		return 0;
	}
	public int m_OnUpdate2(){
		return 0;
	}
	public int m_OnSuspend(){
		return 0;
	}
	public int m_OnResume2(){
		return 0;
	}
	public int m_OnRender(){
		return 0;
	}
	public int m_OnLoading(){
		return 0;
	}
}
interface bb_sizeable_Sizeable{
	public bb_vector2d_Vector2D m_center();
}
class bb_director_Director extends bb_app_App implements bb_sizeable_Sizeable{
	bb_vector2d_Vector2D f__size=null;
	public bb_vector2d_Vector2D m_size(){
		return f__size;
	}
	bb_vector2d_Vector2D f__center=null;
	bb_vector2d_Vector2D f__device=(new bb_vector2d_Vector2D()).g_new(0.0f,0.0f);
	bb_vector2d_Vector2D f__scale=null;
	public void m_RecalculateScale(){
		f__scale=f__device.m_Copy().m_Div(f__size);
	}
	public void m_size2(bb_vector2d_Vector2D t_newSize){
		f__size=t_newSize;
		f__center=f__size.m_Copy().m_Div2(2.0f);
		m_RecalculateScale();
	}
	public bb_director_Director g_new(int t_width,int t_height){
		super.g_new();
		m_size2((new bb_vector2d_Vector2D()).g_new((float)(t_width),(float)(t_height)));
		return this;
	}
	public bb_director_Director g_new2(){
		super.g_new();
		return this;
	}
	bb_inputcontroller_InputController f__inputController=(new bb_inputcontroller_InputController()).g_new();
	public bb_inputcontroller_InputController m_inputController(){
		return f__inputController;
	}
	bb_directorevents_DirectorEvents f__handler=null;
	boolean f_onCreateDispatched=false;
	boolean f_appOnCreateCatched=false;
	public void m_DispatchOnCreate(){
		if(f_onCreateDispatched){
			return;
		}
		if(!((f__handler)!=null)){
			return;
		}
		if(!f_appOnCreateCatched){
			return;
		}
		f__handler.m_OnCreate(this);
		f_onCreateDispatched=true;
	}
	public void m_Run(bb_directorevents_DirectorEvents t__handler){
		this.f__handler=t__handler;
		m_DispatchOnCreate();
	}
	public bb_directorevents_DirectorEvents m_handler(){
		return f__handler;
	}
	public bb_vector2d_Vector2D m_center(){
		return f__center;
	}
	public bb_vector2d_Vector2D m_scale(){
		return f__scale;
	}
	bb_deltatimer_DeltaTimer f_deltaTimer=null;
	public int m_OnCreate2(){
		f__device=(new bb_vector2d_Vector2D()).g_new((float)(bb_graphics.bb_graphics_DeviceWidth()),(float)(bb_graphics.bb_graphics_DeviceHeight()));
		if(!((m_size())!=null)){
			m_size2(f__device.m_Copy());
		}
		m_RecalculateScale();
		m_inputController().f_scale=m_scale();
		bb_random.bb_random_Seed=util.GetTimestamp();
		f_deltaTimer=(new bb_deltatimer_DeltaTimer()).g_new(30.0f);
		bb_app.bb_app_SetUpdateRate(60);
		f_appOnCreateCatched=true;
		m_DispatchOnCreate();
		return 0;
	}
	public int m_OnLoading(){
		if((f__handler)!=null){
			f__handler.m_OnLoading();
		}
		return 0;
	}
	public int m_OnUpdate2(){
		f_deltaTimer.m_OnUpdate2();
		if((f__handler)!=null){
			f__handler.m_OnUpdate(f_deltaTimer.m_delta(),f_deltaTimer.m_frameTime());
			m_inputController().m_OnUpdate3(f__handler);
		}
		return 0;
	}
	public int m_OnResume2(){
		if((f__handler)!=null){
			f__handler.m_OnResume(0);
		}
		return 0;
	}
	public int m_OnSuspend(){
		if((f__handler)!=null){
			f__handler.m_OnSuspend();
		}
		return 0;
	}
	public int m_OnRender(){
		bb_graphics.bb_graphics_PushMatrix();
		bb_graphics.bb_graphics_Scale(f__scale.f_x,f__scale.f_y);
		bb_graphics.bb_graphics_SetScissor(0.0f,0.0f,f__device.f_x,f__device.f_y);
		bb_graphics.bb_graphics_Cls(0.0f,0.0f,0.0f);
		bb_graphics.bb_graphics_PushMatrix();
		if((f__handler)!=null){
			f__handler.m_OnRender();
		}
		bb_graphics.bb_graphics_PopMatrix();
		bb_graphics.bb_graphics_PopMatrix();
		return 0;
	}
}
class bb_list_List extends Object{
	public bb_list_List g_new(){
		return this;
	}
	bb_list_Node f__head=((new bb_list_HeadNode()).g_new());
	public bb_list_Node m_AddLast(String t_data){
		return (new bb_list_Node()).g_new(f__head,f__head.f__pred,t_data);
	}
	public bb_list_List g_new2(String[] t_data){
		String[] t_=t_data;
		int t_2=0;
		while(t_2<bb_std_lang.arrayLength(t_)){
			String t_t=t_[t_2];
			t_2=t_2+1;
			m_AddLast(t_t);
		}
		return this;
	}
	public boolean m_Equals(String t_lhs,String t_rhs){
		return (t_lhs.compareTo(t_rhs)==0);
	}
	public boolean m_Contains(String t_value){
		bb_list_Node t_node=f__head.f__succ;
		while(t_node!=f__head){
			if(m_Equals(t_node.f__data,t_value)){
				return true;
			}
			t_node=t_node.f__succ;
		}
		return false;
	}
	public int m_Count(){
		int t_n=0;
		bb_list_Node t_node=f__head.f__succ;
		while(t_node!=f__head){
			t_node=t_node.f__succ;
			t_n+=1;
		}
		return t_n;
	}
	public bb_list_Enumerator3 m_ObjectEnumerator(){
		return (new bb_list_Enumerator3()).g_new(this);
	}
	public String[] m_ToArray(){
		String[] t_arr=bb_std_lang.stringArray(m_Count());
		int t_i=0;
		bb_list_Enumerator3 t_=this.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			String t_t=t_.m_NextObject();
			t_arr[t_i]=t_t;
			t_i+=1;
		}
		return t_arr;
	}
}
class bb_list_Node extends Object{
	bb_list_Node f__succ=null;
	bb_list_Node f__pred=null;
	String f__data="";
	public bb_list_Node g_new(bb_list_Node t_succ,bb_list_Node t_pred,String t_data){
		f__succ=t_succ;
		f__pred=t_pred;
		f__succ.f__pred=this;
		f__pred.f__succ=this;
		f__data=t_data;
		return this;
	}
	public bb_list_Node g_new2(){
		return this;
	}
}
class bb_list_HeadNode extends bb_list_Node{
	public bb_list_HeadNode g_new(){
		super.g_new2();
		f__succ=(this);
		f__pred=(this);
		return this;
	}
}
class bb_app_AppDevice extends gxtkApp{
	bb_app_App f_app=null;
	public bb_app_AppDevice g_new(bb_app_App t_app){
		this.f_app=t_app;
		bb_graphics.bb_graphics_SetGraphicsContext((new bb_graphics_GraphicsContext()).g_new(GraphicsDevice()));
		bb_input.bb_input_SetInputDevice(InputDevice());
		bb_audio.bb_audio_SetAudioDevice(AudioDevice());
		return this;
	}
	public bb_app_AppDevice g_new2(){
		return this;
	}
	public int OnCreate(){
		bb_graphics.bb_graphics_SetFont(null,32);
		return f_app.m_OnCreate2();
	}
	public int OnUpdate(){
		return f_app.m_OnUpdate2();
	}
	public int OnSuspend(){
		return f_app.m_OnSuspend();
	}
	public int OnResume(){
		return f_app.m_OnResume2();
	}
	public int OnRender(){
		bb_graphics.bb_graphics_BeginRender();
		int t_r=f_app.m_OnRender();
		bb_graphics.bb_graphics_EndRender();
		return t_r;
	}
	public int OnLoading(){
		bb_graphics.bb_graphics_BeginRender();
		int t_r=f_app.m_OnLoading();
		bb_graphics.bb_graphics_EndRender();
		return t_r;
	}
	int f_updateRate=0;
	public int SetUpdateRate(int t_hertz){
		super.SetUpdateRate(t_hertz);
		f_updateRate=t_hertz;
		return 0;
	}
}
class bb_graphics_GraphicsContext extends Object{
	gxtkGraphics f_device=null;
	public bb_graphics_GraphicsContext g_new(gxtkGraphics t_device){
		this.f_device=t_device;
		return this;
	}
	public bb_graphics_GraphicsContext g_new2(){
		return this;
	}
	bb_graphics_Image f_defaultFont=null;
	bb_graphics_Image f_font=null;
	int f_firstChar=0;
	int f_matrixSp=0;
	float f_ix=1.0f;
	float f_iy=.0f;
	float f_jx=.0f;
	float f_jy=1.0f;
	float f_tx=.0f;
	float f_ty=.0f;
	int f_tformed=0;
	int f_matDirty=0;
	float f_color_r=.0f;
	float f_color_g=.0f;
	float f_color_b=.0f;
	float f_alpha=.0f;
	int f_blend=0;
	float f_scissor_x=.0f;
	float f_scissor_y=.0f;
	float f_scissor_width=.0f;
	float f_scissor_height=.0f;
	float[] f_matrixStack=new float[192];
}
class bb_vector2d_Vector2D extends Object{
	float f_x=.0f;
	float f_y=.0f;
	public bb_vector2d_Vector2D g_new(float t_x,float t_y){
		this.f_x=t_x;
		this.f_y=t_y;
		return this;
	}
	public bb_vector2d_Vector2D m_Copy(){
		return (new bb_vector2d_Vector2D()).g_new(f_x,f_y);
	}
	public bb_vector2d_Vector2D m_Div(bb_vector2d_Vector2D t_v2){
		f_x/=t_v2.f_x;
		f_y/=t_v2.f_y;
		return this;
	}
	public bb_vector2d_Vector2D m_Div2(float t_factor){
		f_y/=t_factor;
		f_x/=t_factor;
		return this;
	}
	public bb_vector2d_Vector2D m_Sub(bb_vector2d_Vector2D t_v2){
		f_x-=t_v2.f_x;
		f_y-=t_v2.f_y;
		return this;
	}
	public bb_vector2d_Vector2D m_Sub2(float t_factor){
		f_x-=t_factor;
		f_y-=t_factor;
		return this;
	}
	public bb_vector2d_Vector2D m_Add2(bb_vector2d_Vector2D t_v2){
		f_x+=t_v2.f_x;
		f_y+=t_v2.f_y;
		return this;
	}
	public bb_vector2d_Vector2D m_Add3(float t_factor){
		f_x+=t_factor;
		f_y+=t_factor;
		return this;
	}
	public float m_Length(){
		return (float)Math.sqrt(f_x*f_x+f_y*f_y);
	}
	public bb_vector2d_Vector2D m_Normalize(){
		float t_length=m_Length();
		if(t_length==0.0f){
			return this;
		}
		f_x/=t_length;
		f_y/=t_length;
		return this;
	}
	public bb_vector2d_Vector2D m_Mul(bb_vector2d_Vector2D t_v2){
		f_x*=t_v2.f_x;
		f_y*=t_v2.f_y;
		return this;
	}
	public bb_vector2d_Vector2D m_Mul2(float t_factor){
		f_x*=t_factor;
		f_y*=t_factor;
		return this;
	}
}
class bb_inputcontroller_InputController extends Object{
	public bb_inputcontroller_InputController g_new(){
		return this;
	}
	boolean f_trackTouch=false;
	int f__touchFingers=1;
	public void m_touchFingers(int t_number){
		if(t_number>31){
			bb_std_lang.error("Only 31 can be tracked.");
		}
		if(((!((t_number)!=0))?1:0)>0){
			bb_std_lang.error("Number of fingers must be greater than 0.");
		}
		f__touchFingers=t_number;
	}
	int f_touchRetainSize=5;
	bb_vector2d_Vector2D f_scale=(new bb_vector2d_Vector2D()).g_new(0.0f,0.0f);
	boolean[] f_isTouchDown=new boolean[31];
	bb_touchevent_TouchEvent[] f_touchEvents=new bb_touchevent_TouchEvent[31];
	boolean[] f_touchDownDispatched=new boolean[31];
	float f_touchMinDistance=5.0f;
	public void m_ReadTouch(){
		bb_vector2d_Vector2D t_scaledVector=null;
		bb_vector2d_Vector2D t_diffVector=null;
		boolean t_lastTouchDown=false;
		for(int t_i=0;t_i<f__touchFingers;t_i=t_i+1){
			t_lastTouchDown=f_isTouchDown[t_i];
			f_isTouchDown[t_i]=((bb_input.bb_input_TouchDown(t_i))!=0);
			if(!f_isTouchDown[t_i] && !t_lastTouchDown){
				continue;
			}
			if(f_touchEvents[t_i]==null){
				f_touchDownDispatched[t_i]=false;
				f_touchEvents[t_i]=(new bb_touchevent_TouchEvent()).g_new(t_i);
			}
			t_scaledVector=((new bb_vector2d_Vector2D()).g_new(bb_input.bb_input_TouchX(t_i),bb_input.bb_input_TouchY(t_i))).m_Div(f_scale);
			t_diffVector=t_scaledVector.m_Copy().m_Sub(f_touchEvents[t_i].m_prevPos());
			if(t_diffVector.m_Length()>=f_touchMinDistance){
				f_touchEvents[t_i].m_Add2(t_scaledVector);
				if(f_touchRetainSize>-1){
					f_touchEvents[t_i].m_Trim(f_touchRetainSize);
				}
			}
		}
	}
	public void m_ProcessTouch(bb_directorevents_DirectorEvents t_handler){
		for(int t_i=0;t_i<f__touchFingers;t_i=t_i+1){
			if(f_touchEvents[t_i]==null){
				continue;
			}
			if(!f_touchDownDispatched[t_i]){
				t_handler.m_OnTouchDown(f_touchEvents[t_i].m_Copy());
				f_touchDownDispatched[t_i]=true;
			}else{
				if(!f_isTouchDown[t_i]){
					t_handler.m_OnTouchUp(f_touchEvents[t_i]);
					f_touchEvents[t_i]=null;
				}else{
					t_handler.m_OnTouchMove(f_touchEvents[t_i]);
				}
			}
		}
	}
	boolean f_trackKeys=false;
	boolean f_keyboardEnabled=false;
	bb_set_IntSet f_keysActive=(new bb_set_IntSet()).g_new();
	bb_map_IntMap2 f_keyEvents=(new bb_map_IntMap2()).g_new();
	bb_set_IntSet f_dispatchedKeyEvents=(new bb_set_IntSet()).g_new();
	public void m_ReadKeys(){
		f_keysActive.m_Clear();
		int t_charCode=0;
		do{
			t_charCode=bb_input.bb_input_GetChar();
			if(!((t_charCode)!=0)){
				return;
			}
			f_keysActive.m_Insert4(t_charCode);
			if(!f_keyEvents.m_Contains2(t_charCode)){
				f_keyEvents.m_Add6(t_charCode,(new bb_keyevent_KeyEvent()).g_new(t_charCode));
				f_dispatchedKeyEvents.m_Remove4(t_charCode);
			}
		}while(!(false));
	}
	public void m_ProcessKeys(bb_directorevents_DirectorEvents t_handler){
		bb_map_ValueEnumerator t_=f_keyEvents.m_Values().m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_keyevent_KeyEvent t_event=t_.m_NextObject();
			if(!f_dispatchedKeyEvents.m_Contains2(t_event.m_code())){
				t_handler.m_OnKeyDown(t_event);
				f_dispatchedKeyEvents.m_Insert4(t_event.m_code());
				continue;
			}
			if(!f_keysActive.m_Contains2(t_event.m_code())){
				t_handler.m_OnKeyUp(t_event);
				f_dispatchedKeyEvents.m_Remove4(t_event.m_code());
				f_keyEvents.m_Remove4(t_event.m_code());
			}else{
				t_handler.m_OnKeyPress(t_event);
			}
		}
	}
	public void m_OnUpdate3(bb_directorevents_DirectorEvents t_handler){
		if(f_trackTouch){
			m_ReadTouch();
			m_ProcessTouch(t_handler);
		}
		if(f_trackKeys){
			if(!f_keyboardEnabled){
				f_keyboardEnabled=true;
				bb_input.bb_input_EnableKeyboard();
			}
			m_ReadKeys();
			m_ProcessKeys(t_handler);
		}else{
			if(f_keyboardEnabled){
				f_keyboardEnabled=false;
				bb_input.bb_input_DisableKeyboard();
				f_keysActive.m_Clear();
				f_keyEvents.m_Clear();
				f_dispatchedKeyEvents.m_Clear();
			}
		}
	}
}
class bb_fanout_FanOut extends Object implements bb_directorevents_DirectorEvents{
	public bb_fanout_FanOut g_new(){
		return this;
	}
	bb_list_List2 f_objects=(new bb_list_List2()).g_new();
	public void m_OnCreate(bb_director_Director t_director){
		if(!((f_objects)!=null)){
			return;
		}
		bb_list_Enumerator t_=f_objects.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_directorevents_DirectorEvents t_obj=t_.m_NextObject();
			t_obj.m_OnCreate(t_director);
		}
	}
	public void m_Add4(bb_directorevents_DirectorEvents t_obj){
		f_objects.m_AddLast2(t_obj);
	}
	public void m_Remove(bb_directorevents_DirectorEvents t_obj){
		f_objects.m_RemoveEach(t_obj);
	}
	public void m_Clear(){
		f_objects.m_Clear();
	}
	public void m_OnLoading(){
		if(!((f_objects)!=null)){
			return;
		}
		bb_list_Enumerator t_=f_objects.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_directorevents_DirectorEvents t_obj=t_.m_NextObject();
			t_obj.m_OnLoading();
		}
	}
	public void m_OnUpdate(float t_delta,float t_frameTime){
		if(!((f_objects)!=null)){
			return;
		}
		bb_list_Enumerator t_=f_objects.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_directorevents_DirectorEvents t_obj=t_.m_NextObject();
			t_obj.m_OnUpdate(t_delta,t_frameTime);
		}
	}
	public void m_OnRender(){
		if(!((f_objects)!=null)){
			return;
		}
		bb_list_Enumerator t_=f_objects.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_directorevents_DirectorEvents t_obj=t_.m_NextObject();
			t_obj.m_OnRender();
		}
	}
	public void m_OnSuspend(){
		if(!((f_objects)!=null)){
			return;
		}
		bb_list_Enumerator t_=f_objects.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_directorevents_DirectorEvents t_obj=t_.m_NextObject();
			t_obj.m_OnSuspend();
		}
	}
	public void m_OnResume(int t_delta){
		if(!((f_objects)!=null)){
			return;
		}
		bb_list_Enumerator t_=f_objects.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_directorevents_DirectorEvents t_obj=t_.m_NextObject();
			t_obj.m_OnResume(t_delta);
		}
	}
	public void m_OnKeyDown(bb_keyevent_KeyEvent t_event){
		if(!((f_objects)!=null)){
			return;
		}
		bb_list_Enumerator t_=f_objects.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_directorevents_DirectorEvents t_obj=t_.m_NextObject();
			t_obj.m_OnKeyDown(t_event);
		}
	}
	public void m_OnKeyPress(bb_keyevent_KeyEvent t_event){
		if(!((f_objects)!=null)){
			return;
		}
		bb_list_Enumerator t_=f_objects.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_directorevents_DirectorEvents t_obj=t_.m_NextObject();
			t_obj.m_OnKeyPress(t_event);
		}
	}
	public void m_OnKeyUp(bb_keyevent_KeyEvent t_event){
		if(!((f_objects)!=null)){
			return;
		}
		bb_list_Enumerator t_=f_objects.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_directorevents_DirectorEvents t_obj=t_.m_NextObject();
			t_obj.m_OnKeyUp(t_event);
		}
	}
	public void m_OnTouchDown(bb_touchevent_TouchEvent t_event){
		if(!((f_objects)!=null)){
			return;
		}
		bb_list_Enumerator t_=f_objects.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_directorevents_DirectorEvents t_obj=t_.m_NextObject();
			t_obj.m_OnTouchDown(t_event);
		}
	}
	public void m_OnTouchMove(bb_touchevent_TouchEvent t_event){
		if(!((f_objects)!=null)){
			return;
		}
		bb_list_Enumerator t_=f_objects.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_directorevents_DirectorEvents t_obj=t_.m_NextObject();
			t_obj.m_OnTouchMove(t_event);
		}
	}
	public void m_OnTouchUp(bb_touchevent_TouchEvent t_event){
		if(!((f_objects)!=null)){
			return;
		}
		bb_list_Enumerator t_=f_objects.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_directorevents_DirectorEvents t_obj=t_.m_NextObject();
			t_obj.m_OnTouchUp(t_event);
		}
	}
	public int m_Count(){
		return f_objects.m_Count();
	}
	public bb_list_Enumerator m_ObjectEnumerator(){
		return f_objects.m_ObjectEnumerator();
	}
}
class bb_list_List2 extends Object{
	public bb_list_List2 g_new(){
		return this;
	}
	bb_list_Node2 f__head=((new bb_list_HeadNode2()).g_new());
	public bb_list_Node2 m_AddLast2(bb_directorevents_DirectorEvents t_data){
		return (new bb_list_Node2()).g_new(f__head,f__head.f__pred,t_data);
	}
	public bb_list_List2 g_new2(bb_directorevents_DirectorEvents[] t_data){
		bb_directorevents_DirectorEvents[] t_=t_data;
		int t_2=0;
		while(t_2<bb_std_lang.arrayLength(t_)){
			bb_directorevents_DirectorEvents t_t=t_[t_2];
			t_2=t_2+1;
			m_AddLast2(t_t);
		}
		return this;
	}
	public bb_list_Enumerator m_ObjectEnumerator(){
		return (new bb_list_Enumerator()).g_new(this);
	}
	public boolean m_Equals2(bb_directorevents_DirectorEvents t_lhs,bb_directorevents_DirectorEvents t_rhs){
		return t_lhs==t_rhs;
	}
	public int m_RemoveEach(bb_directorevents_DirectorEvents t_value){
		bb_list_Node2 t_node=f__head.f__succ;
		while(t_node!=f__head){
			bb_list_Node2 t_succ=t_node.f__succ;
			if(m_Equals2(t_node.f__data,t_value)){
				t_node.m_Remove2();
			}
			t_node=t_succ;
		}
		return 0;
	}
	public int m_Clear(){
		f__head.f__succ=f__head;
		f__head.f__pred=f__head;
		return 0;
	}
	public int m_Count(){
		int t_n=0;
		bb_list_Node2 t_node=f__head.f__succ;
		while(t_node!=f__head){
			t_node=t_node.f__succ;
			t_n+=1;
		}
		return t_n;
	}
}
class bb_list_Node2 extends Object{
	bb_list_Node2 f__succ=null;
	bb_list_Node2 f__pred=null;
	bb_directorevents_DirectorEvents f__data=null;
	public bb_list_Node2 g_new(bb_list_Node2 t_succ,bb_list_Node2 t_pred,bb_directorevents_DirectorEvents t_data){
		f__succ=t_succ;
		f__pred=t_pred;
		f__succ.f__pred=this;
		f__pred.f__succ=this;
		f__data=t_data;
		return this;
	}
	public bb_list_Node2 g_new2(){
		return this;
	}
	public int m_Remove2(){
		f__succ.f__pred=f__pred;
		f__pred.f__succ=f__succ;
		return 0;
	}
}
class bb_list_HeadNode2 extends bb_list_Node2{
	public bb_list_HeadNode2 g_new(){
		super.g_new2();
		f__succ=(this);
		f__pred=(this);
		return this;
	}
}
class bb_list_Enumerator extends Object{
	bb_list_List2 f__list=null;
	bb_list_Node2 f__curr=null;
	public bb_list_Enumerator g_new(bb_list_List2 t_list){
		f__list=t_list;
		f__curr=t_list.f__head.f__succ;
		return this;
	}
	public bb_list_Enumerator g_new2(){
		return this;
	}
	public boolean m_HasNext(){
		while(f__curr.f__succ.f__pred!=f__curr){
			f__curr=f__curr.f__succ;
		}
		return f__curr!=f__list.f__head;
	}
	public bb_directorevents_DirectorEvents m_NextObject(){
		bb_directorevents_DirectorEvents t_data=f__curr.f__data;
		f__curr=f__curr.f__succ;
		return t_data;
	}
}
class bb_graphics_Image extends Object{
	static int g_DefaultFlags;
	public bb_graphics_Image g_new(){
		return this;
	}
	gxtkSurface f_surface=null;
	int f_width=0;
	int f_height=0;
	bb_graphics_Frame[] f_frames=new bb_graphics_Frame[0];
	int f_flags=0;
	float f_tx=.0f;
	float f_ty=.0f;
	public int m_SetHandle(float t_tx,float t_ty){
		this.f_tx=t_tx;
		this.f_ty=t_ty;
		this.f_flags=this.f_flags&-2;
		return 0;
	}
	public int m_ApplyFlags(int t_iflags){
		f_flags=t_iflags;
		if((f_flags&2)!=0){
			bb_graphics_Frame[] t_=f_frames;
			int t_2=0;
			while(t_2<bb_std_lang.arrayLength(t_)){
				bb_graphics_Frame t_f=t_[t_2];
				t_2=t_2+1;
				t_f.f_x+=1;
			}
			f_width-=2;
		}
		if((f_flags&4)!=0){
			bb_graphics_Frame[] t_3=f_frames;
			int t_4=0;
			while(t_4<bb_std_lang.arrayLength(t_3)){
				bb_graphics_Frame t_f2=t_3[t_4];
				t_4=t_4+1;
				t_f2.f_y+=1;
			}
			f_height-=2;
		}
		if((f_flags&1)!=0){
			m_SetHandle((float)(f_width)/2.0f,(float)(f_height)/2.0f);
		}
		if(bb_std_lang.arrayLength(f_frames)==1 && f_frames[0].f_x==0 && f_frames[0].f_y==0 && f_width==f_surface.Width() && f_height==f_surface.Height()){
			f_flags|=65536;
		}
		return 0;
	}
	public bb_graphics_Image m_Load(String t_path,int t_nframes,int t_iflags){
		f_surface=bb_graphics.bb_graphics_context.f_device.LoadSurface(t_path);
		if(!((f_surface)!=null)){
			return null;
		}
		f_width=f_surface.Width()/t_nframes;
		f_height=f_surface.Height();
		f_frames=new bb_graphics_Frame[t_nframes];
		for(int t_i=0;t_i<t_nframes;t_i=t_i+1){
			f_frames[t_i]=(new bb_graphics_Frame()).g_new(t_i*f_width,0);
		}
		m_ApplyFlags(t_iflags);
		return this;
	}
	bb_graphics_Image f_source=null;
	public bb_graphics_Image m_Grab(int t_x,int t_y,int t_iwidth,int t_iheight,int t_nframes,int t_iflags,bb_graphics_Image t_source){
		this.f_source=t_source;
		f_surface=t_source.f_surface;
		f_width=t_iwidth;
		f_height=t_iheight;
		f_frames=new bb_graphics_Frame[t_nframes];
		int t_ix=t_x;
		int t_iy=t_y;
		for(int t_i=0;t_i<t_nframes;t_i=t_i+1){
			if(t_ix+f_width>t_source.f_width){
				t_ix=0;
				t_iy+=f_height;
			}
			if(t_ix+f_width>t_source.f_width || t_iy+f_height>t_source.f_height){
				bb_std_lang.error("Image frame outside surface");
			}
			f_frames[t_i]=(new bb_graphics_Frame()).g_new(t_ix+t_source.f_frames[0].f_x,t_iy+t_source.f_frames[0].f_y);
			t_ix+=f_width;
		}
		m_ApplyFlags(t_iflags);
		return this;
	}
	public bb_graphics_Image m_GrabImage(int t_x,int t_y,int t_width,int t_height,int t_frames,int t_flags){
		if(bb_std_lang.arrayLength(this.f_frames)!=1){
			return null;
		}
		return ((new bb_graphics_Image()).g_new()).m_Grab(t_x,t_y,t_width,t_height,t_frames,t_flags,this);
	}
	public int m_Width(){
		return f_width;
	}
	public int m_Height(){
		return f_height;
	}
}
class bb_graphics_Frame extends Object{
	int f_x=0;
	int f_y=0;
	public bb_graphics_Frame g_new(int t_x,int t_y){
		this.f_x=t_x;
		this.f_y=t_y;
		return this;
	}
	public bb_graphics_Frame g_new2(){
		return this;
	}
}
interface bb_positionable_Positionable{
	public bb_vector2d_Vector2D m_pos();
	public void m_pos2(bb_vector2d_Vector2D t_newPos);
}
abstract class bb_baseobject_BaseObject extends bb_partial_Partial implements bb_positionable_Positionable,bb_sizeable_Sizeable{
	public bb_baseobject_BaseObject g_new(){
		super.g_new();
		return this;
	}
	bb_vector2d_Vector2D f__pos=null;
	public bb_vector2d_Vector2D m_pos(){
		if(f__pos==null){
			bb_std_lang.error("Position not set yet.");
		}
		return f__pos;
	}
	public void m_pos2(bb_vector2d_Vector2D t_newPos){
		f__pos=t_newPos;
	}
	bb_vector2d_Vector2D f__size=null;
	public bb_vector2d_Vector2D m_size(){
		if(f__size==null){
			bb_std_lang.error("Size not set yet.");
		}
		return f__size;
	}
	bb_vector2d_Vector2D f__center=null;
	public void m_size2(bb_vector2d_Vector2D t_newSize){
		f__size=t_newSize;
		f__center=t_newSize.m_Copy().m_Div2(2.0f);
	}
	public bb_vector2d_Vector2D m_center(){
		if(f__center==null){
			bb_std_lang.error("No size set and center therefore unset.");
		}
		return f__center;
	}
	public void m_Center(bb_sizeable_Sizeable t_entity){
		m_pos2(t_entity.m_center().m_Copy().m_Sub(m_center()));
	}
	public void m_CenterX(bb_sizeable_Sizeable t_entity){
		m_pos().f_x=t_entity.m_center().f_x-m_center().f_x;
	}
}
class bb_sprite_Sprite extends bb_baseobject_BaseObject{
	bb_graphics_Image f_image=null;
	public void m_InitVectors(int t_width,int t_height,bb_vector2d_Vector2D t_pos){
		if(t_pos==null){
			this.m_pos2((new bb_vector2d_Vector2D()).g_new(0.0f,0.0f));
		}else{
			this.m_pos2(t_pos);
		}
		m_size2((new bb_vector2d_Vector2D()).g_new((float)(t_width),(float)(t_height)));
	}
	public bb_sprite_Sprite g_new(String t_imageName,bb_vector2d_Vector2D t_pos){
		super.g_new();
		f_image=bb_graphics.bb_graphics_LoadImage(t_imageName,1,bb_graphics_Image.g_DefaultFlags);
		m_InitVectors(f_image.m_Width(),f_image.m_Height(),t_pos);
		return this;
	}
	int f_frameCount=0;
	int f_frameSpeed=0;
	public bb_sprite_Sprite g_new2(String t_imageName,int t_frameWidth,int t_frameHeight,int t_frameCount,int t_frameSpeed,bb_vector2d_Vector2D t_pos){
		super.g_new();
		this.f_frameCount=t_frameCount-1;
		this.f_frameSpeed=t_frameSpeed;
		f_image=bb_graphics.bb_graphics_LoadImage2(t_imageName,t_frameWidth,t_frameHeight,t_frameCount,bb_graphics_Image.g_DefaultFlags);
		m_InitVectors(t_frameWidth,t_frameHeight,t_pos);
		return this;
	}
	public bb_sprite_Sprite g_new3(){
		super.g_new();
		return this;
	}
	float f_rotation=.0f;
	bb_vector2d_Vector2D f_scale=(new bb_vector2d_Vector2D()).g_new(1.0f,1.0f);
	int f_currentFrame=0;
	public void m_OnRender(){
		super.m_OnRender();
		bb_graphics.bb_graphics_DrawImage2(f_image,m_pos().f_x,m_pos().f_y,f_rotation,f_scale.f_x,f_scale.f_y,f_currentFrame);
	}
	boolean f_loopAnimation=false;
	public boolean m_animationIsDone(){
		if(f_loopAnimation){
			return false;
		}
		return f_currentFrame==f_frameCount;
	}
	int f_frameTimer=0;
	public void m_OnUpdate(float t_delta,float t_frameTime){
		super.m_OnUpdate(t_delta,t_frameTime);
		if(f_frameCount<=0){
			return;
		}
		if(m_animationIsDone()){
			return;
		}
		if(f_frameTimer<f_frameSpeed){
			f_frameTimer=(int)((float)(f_frameTimer)+t_frameTime);
			return;
		}
		if(f_currentFrame==f_frameCount){
			if(f_loopAnimation){
				f_currentFrame=1;
			}
		}else{
			f_currentFrame+=1;
		}
		f_frameTimer=0;
	}
	public boolean m_Collide(bb_vector2d_Vector2D t_checkPos){
		if(t_checkPos.f_x<m_pos().f_x || t_checkPos.f_x>m_pos().f_x+m_size().f_x){
			return false;
		}
		if(t_checkPos.f_y<m_pos().f_y || t_checkPos.f_y>m_pos().f_y+m_size().f_y){
			return false;
		}
		return true;
	}
	public void m_Restart(){
		f_currentFrame=0;
	}
}
abstract class bb_product_PaymentProduct extends Object{
	boolean f_purchased=false;
	boolean f_startBuy=false;
	public bb_product_PaymentProduct g_new(){
		f_purchased=false;
		f_startBuy=false;
		return this;
	}
	bb_service_PaymentService f_service=null;
	public void m_SetService(bb_service_PaymentService t_s){
		f_service=t_s;
	}
	abstract public String m_GetAppleId();
	abstract public String m_GetAndroidId();
	public void m_UpdatePurchasedState(){
		f_purchased=bb_service_PaymentService.g_androidPayment.IsBought(m_GetAndroidId());
	}
	public boolean m_IsProductPurchased(){
		if(f_purchased){
			return true;
		}
		f_purchased=bb_service_PaymentService.g_androidPayment.IsBought(m_GetAndroidId());
		return f_purchased;
	}
	public void m_Buy(){
		f_startBuy=true;
		bb_iap.bb_iap_buyProduct(m_GetAppleId());
		bb_service_PaymentService.g_androidPayment.Purchase(m_GetAndroidId());
	}
}
class bb_menuscene_FullVersion extends bb_product_PaymentProduct{
	public bb_menuscene_FullVersion g_new(){
		super.g_new();
		return this;
	}
	public String m_GetAppleId(){
		return "com.coragames.daffydrop.fullversion";
	}
	public String m_GetAndroidId(){
		return "android.test.purchased";
	}
}
class bb_service_PaymentService extends Object{
	public bb_service_PaymentService g_new(){
		return this;
	}
	String f_bundleId="";
	public void m_SetBundleId(String t_bundleId){
		this.f_bundleId=t_bundleId;
	}
	String f_publicKey="";
	public void m_SetPublicKey(String t_k){
		f_publicKey=t_k;
	}
	bb_list_List3 f_products=(new bb_list_List3()).g_new();
	public void m_AddProduct(bb_product_PaymentProduct t_p){
		t_p.m_SetService(this);
		f_products.m_AddLast3(t_p);
	}
	static PaymentWrapper g_androidPayment;
	public void m_StartService(){
		g_androidPayment=(new PaymentWrapper());
		g_androidPayment.Init();
		bb_list_List t_prodIds=(new bb_list_List()).g_new();
		bb_list_Enumerator2 t_=f_products.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_product_PaymentProduct t_p=t_.m_NextObject();
			t_prodIds.m_AddLast(t_p.m_GetAppleId());
		}
		bb_iap.bb_iap_InitInAppPurchases(f_bundleId,t_prodIds.m_ToArray());
		com.payment.Security.SetPublicKey(f_publicKey);
	}
	public boolean m_IsPurchaseInProgress(){
		return g_androidPayment.IsPurchaseInProgress();
	}
}
class bb_list_List3 extends Object{
	public bb_list_List3 g_new(){
		return this;
	}
	bb_list_Node3 f__head=((new bb_list_HeadNode3()).g_new());
	public bb_list_Node3 m_AddLast3(bb_product_PaymentProduct t_data){
		return (new bb_list_Node3()).g_new(f__head,f__head.f__pred,t_data);
	}
	public bb_list_List3 g_new2(bb_product_PaymentProduct[] t_data){
		bb_product_PaymentProduct[] t_=t_data;
		int t_2=0;
		while(t_2<bb_std_lang.arrayLength(t_)){
			bb_product_PaymentProduct t_t=t_[t_2];
			t_2=t_2+1;
			m_AddLast3(t_t);
		}
		return this;
	}
	public bb_list_Enumerator2 m_ObjectEnumerator(){
		return (new bb_list_Enumerator2()).g_new(this);
	}
}
class bb_list_Node3 extends Object{
	bb_list_Node3 f__succ=null;
	bb_list_Node3 f__pred=null;
	bb_product_PaymentProduct f__data=null;
	public bb_list_Node3 g_new(bb_list_Node3 t_succ,bb_list_Node3 t_pred,bb_product_PaymentProduct t_data){
		f__succ=t_succ;
		f__pred=t_pred;
		f__succ.f__pred=this;
		f__pred.f__succ=this;
		f__data=t_data;
		return this;
	}
	public bb_list_Node3 g_new2(){
		return this;
	}
}
class bb_list_HeadNode3 extends bb_list_Node3{
	public bb_list_HeadNode3 g_new(){
		super.g_new2();
		f__succ=(this);
		f__pred=(this);
		return this;
	}
}
class bb_list_Enumerator2 extends Object{
	bb_list_List3 f__list=null;
	bb_list_Node3 f__curr=null;
	public bb_list_Enumerator2 g_new(bb_list_List3 t_list){
		f__list=t_list;
		f__curr=t_list.f__head.f__succ;
		return this;
	}
	public bb_list_Enumerator2 g_new2(){
		return this;
	}
	public boolean m_HasNext(){
		while(f__curr.f__succ.f__pred!=f__curr){
			f__curr=f__curr.f__succ;
		}
		return f__curr!=f__list.f__head;
	}
	public bb_product_PaymentProduct m_NextObject(){
		bb_product_PaymentProduct t_data=f__curr.f__data;
		f__curr=f__curr.f__succ;
		return t_data;
	}
}
class bb_list_Enumerator3 extends Object{
	bb_list_List f__list=null;
	bb_list_Node f__curr=null;
	public bb_list_Enumerator3 g_new(bb_list_List t_list){
		f__list=t_list;
		f__curr=t_list.f__head.f__succ;
		return this;
	}
	public bb_list_Enumerator3 g_new2(){
		return this;
	}
	public boolean m_HasNext(){
		while(f__curr.f__succ.f__pred!=f__curr){
			f__curr=f__curr.f__succ;
		}
		return f__curr!=f__list.f__head;
	}
	public String m_NextObject(){
		String t_data=f__curr.f__data;
		f__curr=f__curr.f__succ;
		return t_data;
	}
}
class bb_appirater_Appirater extends Object{
	static public void g_Launched(){
		bb_std_lang.print("Appirater: App launched");
	}
}
class bb_angelfont2_AngelFont extends Object{
	static String g_error;
	static bb_angelfont2_AngelFont g_current;
	String f_iniText="";
	bb_map_StringMap3 f_kernPairs=(new bb_map_StringMap3()).g_new();
	bb_char_Char[] f_chars=new bb_char_Char[256];
	int f_height=0;
	int f_heightOffset=9999;
	bb_graphics_Image f_image=null;
	public void m_LoadFont(String t_url){
		g_error="";
		g_current=this;
		f_iniText=bb_app.bb_app_LoadString(t_url+".txt");
		String[] t_lines=bb_std_lang.split(f_iniText,String.valueOf((char)(10)));
		String[] t_=t_lines;
		int t_2=0;
		while(t_2<bb_std_lang.arrayLength(t_)){
			String t_line=t_[t_2];
			t_2=t_2+1;
			t_line=t_line.trim();
			if(t_line.startsWith("id,") || (t_line.compareTo("")==0)){
				continue;
			}
			if(t_line.startsWith("first,")){
				continue;
			}
			String[] t_data=bb_std_lang.split(t_line,",");
			for(int t_i=0;t_i<bb_std_lang.arrayLength(t_data);t_i=t_i+1){
				t_data[t_i]=t_data[t_i].trim();
			}
			g_error=g_error+(String.valueOf(bb_std_lang.arrayLength(t_data))+",");
			if(bb_std_lang.arrayLength(t_data)>0){
				if(bb_std_lang.arrayLength(t_data)==3){
					f_kernPairs.m_Insert(String.valueOf((char)(Integer.parseInt((t_data[0]).trim())))+"_"+String.valueOf((char)(Integer.parseInt((t_data[1]).trim()))),(new bb_kernpair_KernPair()).g_new(Integer.parseInt((t_data[0]).trim()),Integer.parseInt((t_data[1]).trim()),Integer.parseInt((t_data[2]).trim())));
				}else{
					if(bb_std_lang.arrayLength(t_data)>=8){
						f_chars[Integer.parseInt((t_data[0]).trim())]=(new bb_char_Char()).g_new(Integer.parseInt((t_data[1]).trim()),Integer.parseInt((t_data[2]).trim()),Integer.parseInt((t_data[3]).trim()),Integer.parseInt((t_data[4]).trim()),Integer.parseInt((t_data[5]).trim()),Integer.parseInt((t_data[6]).trim()),Integer.parseInt((t_data[7]).trim()));
						bb_char_Char t_ch=f_chars[Integer.parseInt((t_data[0]).trim())];
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
		f_image=bb_graphics.bb_graphics_LoadImage(t_url+".png",1,bb_graphics_Image.g_DefaultFlags);
	}
	String f_name="";
	static bb_map_StringMap4 g__list;
	public bb_angelfont2_AngelFont g_new(String t_url){
		if(t_url.compareTo("")!=0){
			this.m_LoadFont(t_url);
			this.f_name=t_url;
			g__list.m_Insert2(t_url,this);
		}
		return this;
	}
	int f_xOffset=0;
	boolean f_useKerning=true;
	public void m_DrawText(String t_txt,int t_x,int t_y){
		String t_prevChar="";
		f_xOffset=0;
		for(int t_i=0;t_i<t_txt.length();t_i=t_i+1){
			int t_asc=(int)t_txt.charAt(t_i);
			bb_char_Char t_ac=f_chars[t_asc];
			String t_thisChar=String.valueOf((char)(t_asc));
			if(t_ac!=null){
				if(f_useKerning){
					String t_key=t_prevChar+"_"+t_thisChar;
					if(f_kernPairs.m_Contains(t_key)){
						f_xOffset+=f_kernPairs.m_Get(t_key).f_amount;
					}
				}
				t_ac.m_Draw(f_image,t_x+f_xOffset,t_y);
				f_xOffset+=t_ac.f_xAdvance;
				t_prevChar=t_thisChar;
			}
		}
	}
	public int m_TextWidth(String t_txt){
		String t_prevChar="";
		int t_width=0;
		for(int t_i=0;t_i<t_txt.length();t_i=t_i+1){
			int t_asc=(int)t_txt.charAt(t_i);
			bb_char_Char t_ac=f_chars[t_asc];
			String t_thisChar=String.valueOf((char)(t_asc));
			if(t_ac!=null){
				if(f_useKerning){
					String t_key=t_prevChar+"_"+t_thisChar;
					if(f_kernPairs.m_Contains(t_key)){
						t_width+=f_kernPairs.m_Get(t_key).f_amount;
					}
				}
				t_width+=t_ac.f_xAdvance;
				t_prevChar=t_thisChar;
			}
		}
		return t_width;
	}
	public void m_DrawText2(String t_txt,int t_x,int t_y,int t_align){
		f_xOffset=0;
		int t_1=t_align;
		if(t_1==1){
			m_DrawText(t_txt,t_x-m_TextWidth(t_txt)/2,t_y);
		}else{
			if(t_1==2){
				m_DrawText(t_txt,t_x-m_TextWidth(t_txt),t_y);
			}else{
				if(t_1==0){
					m_DrawText(t_txt,t_x,t_y);
				}
			}
		}
	}
}
class bb_kernpair_KernPair extends Object{
	String f_first="";
	String f_second="";
	int f_amount=0;
	public bb_kernpair_KernPair g_new(int t_first,int t_second,int t_amount){
		this.f_first=String.valueOf(t_first);
		this.f_second=String.valueOf(t_second);
		this.f_amount=t_amount;
		return this;
	}
	public bb_kernpair_KernPair g_new2(){
		return this;
	}
}
abstract class bb_map_Map3 extends Object{
	public bb_map_Map3 g_new(){
		return this;
	}
	bb_map_Node3 f_root=null;
	abstract public int m_Compare(String t_lhs,String t_rhs);
	public int m_RotateLeft3(bb_map_Node3 t_node){
		bb_map_Node3 t_child=t_node.f_right;
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
			f_root=t_child;
		}
		t_child.f_left=t_node;
		t_node.f_parent=t_child;
		return 0;
	}
	public int m_RotateRight3(bb_map_Node3 t_node){
		bb_map_Node3 t_child=t_node.f_left;
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
			f_root=t_child;
		}
		t_child.f_right=t_node;
		t_node.f_parent=t_child;
		return 0;
	}
	public int m_InsertFixup3(bb_map_Node3 t_node){
		while(((t_node.f_parent)!=null) && t_node.f_parent.f_color==-1 && ((t_node.f_parent.f_parent)!=null)){
			if(t_node.f_parent==t_node.f_parent.f_parent.f_left){
				bb_map_Node3 t_uncle=t_node.f_parent.f_parent.f_right;
				if(((t_uncle)!=null) && t_uncle.f_color==-1){
					t_node.f_parent.f_color=1;
					t_uncle.f_color=1;
					t_uncle.f_parent.f_color=-1;
					t_node=t_uncle.f_parent;
				}else{
					if(t_node==t_node.f_parent.f_right){
						t_node=t_node.f_parent;
						m_RotateLeft3(t_node);
					}
					t_node.f_parent.f_color=1;
					t_node.f_parent.f_parent.f_color=-1;
					m_RotateRight3(t_node.f_parent.f_parent);
				}
			}else{
				bb_map_Node3 t_uncle2=t_node.f_parent.f_parent.f_left;
				if(((t_uncle2)!=null) && t_uncle2.f_color==-1){
					t_node.f_parent.f_color=1;
					t_uncle2.f_color=1;
					t_uncle2.f_parent.f_color=-1;
					t_node=t_uncle2.f_parent;
				}else{
					if(t_node==t_node.f_parent.f_left){
						t_node=t_node.f_parent;
						m_RotateRight3(t_node);
					}
					t_node.f_parent.f_color=1;
					t_node.f_parent.f_parent.f_color=-1;
					m_RotateLeft3(t_node.f_parent.f_parent);
				}
			}
		}
		f_root.f_color=1;
		return 0;
	}
	public boolean m_Set3(String t_key,bb_kernpair_KernPair t_value){
		bb_map_Node3 t_node=f_root;
		bb_map_Node3 t_parent=null;
		int t_cmp=0;
		while((t_node)!=null){
			t_parent=t_node;
			t_cmp=m_Compare(t_key,t_node.f_key);
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
		t_node=(new bb_map_Node3()).g_new(t_key,t_value,-1,t_parent);
		if((t_parent)!=null){
			if(t_cmp>0){
				t_parent.f_right=t_node;
			}else{
				t_parent.f_left=t_node;
			}
			m_InsertFixup3(t_node);
		}else{
			f_root=t_node;
		}
		return true;
	}
	public boolean m_Insert(String t_key,bb_kernpair_KernPair t_value){
		return m_Set3(t_key,t_value);
	}
	public bb_map_Node3 m_FindNode(String t_key){
		bb_map_Node3 t_node=f_root;
		while((t_node)!=null){
			int t_cmp=m_Compare(t_key,t_node.f_key);
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
	public boolean m_Contains(String t_key){
		return m_FindNode(t_key)!=null;
	}
	public bb_kernpair_KernPair m_Get(String t_key){
		bb_map_Node3 t_node=m_FindNode(t_key);
		if((t_node)!=null){
			return t_node.f_value;
		}
		return null;
	}
}
class bb_map_StringMap3 extends bb_map_Map3{
	public bb_map_StringMap3 g_new(){
		super.g_new();
		return this;
	}
	public int m_Compare(String t_lhs,String t_rhs){
		return t_lhs.compareTo(t_rhs);
	}
}
class bb_map_Node3 extends Object{
	String f_key="";
	bb_map_Node3 f_right=null;
	bb_map_Node3 f_left=null;
	bb_kernpair_KernPair f_value=null;
	int f_color=0;
	bb_map_Node3 f_parent=null;
	public bb_map_Node3 g_new(String t_key,bb_kernpair_KernPair t_value,int t_color,bb_map_Node3 t_parent){
		this.f_key=t_key;
		this.f_value=t_value;
		this.f_color=t_color;
		this.f_parent=t_parent;
		return this;
	}
	public bb_map_Node3 g_new2(){
		return this;
	}
}
class bb_char_Char extends Object{
	int f_x=0;
	int f_y=0;
	int f_width=0;
	int f_height=0;
	int f_xOffset=0;
	int f_yOffset=0;
	int f_xAdvance=0;
	public bb_char_Char g_new(int t_x,int t_y,int t_w,int t_h,int t_xoff,int t_yoff,int t_xadv){
		this.f_x=t_x;
		this.f_y=t_y;
		this.f_width=t_w;
		this.f_height=t_h;
		this.f_xOffset=t_xoff;
		this.f_yOffset=t_yoff;
		this.f_xAdvance=t_xadv;
		return this;
	}
	public bb_char_Char g_new2(){
		return this;
	}
	public int m_Draw(bb_graphics_Image t_fontImage,int t_linex,int t_liney){
		bb_graphics.bb_graphics_DrawImageRect(t_fontImage,(float)(t_linex+f_xOffset),(float)(t_liney+f_yOffset),f_x,f_y,f_width,f_height,0);
		return 0;
	}
}
abstract class bb_map_Map4 extends Object{
	public bb_map_Map4 g_new(){
		return this;
	}
	bb_map_Node4 f_root=null;
	abstract public int m_Compare(String t_lhs,String t_rhs);
	public int m_RotateLeft4(bb_map_Node4 t_node){
		bb_map_Node4 t_child=t_node.f_right;
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
			f_root=t_child;
		}
		t_child.f_left=t_node;
		t_node.f_parent=t_child;
		return 0;
	}
	public int m_RotateRight4(bb_map_Node4 t_node){
		bb_map_Node4 t_child=t_node.f_left;
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
			f_root=t_child;
		}
		t_child.f_right=t_node;
		t_node.f_parent=t_child;
		return 0;
	}
	public int m_InsertFixup4(bb_map_Node4 t_node){
		while(((t_node.f_parent)!=null) && t_node.f_parent.f_color==-1 && ((t_node.f_parent.f_parent)!=null)){
			if(t_node.f_parent==t_node.f_parent.f_parent.f_left){
				bb_map_Node4 t_uncle=t_node.f_parent.f_parent.f_right;
				if(((t_uncle)!=null) && t_uncle.f_color==-1){
					t_node.f_parent.f_color=1;
					t_uncle.f_color=1;
					t_uncle.f_parent.f_color=-1;
					t_node=t_uncle.f_parent;
				}else{
					if(t_node==t_node.f_parent.f_right){
						t_node=t_node.f_parent;
						m_RotateLeft4(t_node);
					}
					t_node.f_parent.f_color=1;
					t_node.f_parent.f_parent.f_color=-1;
					m_RotateRight4(t_node.f_parent.f_parent);
				}
			}else{
				bb_map_Node4 t_uncle2=t_node.f_parent.f_parent.f_left;
				if(((t_uncle2)!=null) && t_uncle2.f_color==-1){
					t_node.f_parent.f_color=1;
					t_uncle2.f_color=1;
					t_uncle2.f_parent.f_color=-1;
					t_node=t_uncle2.f_parent;
				}else{
					if(t_node==t_node.f_parent.f_left){
						t_node=t_node.f_parent;
						m_RotateRight4(t_node);
					}
					t_node.f_parent.f_color=1;
					t_node.f_parent.f_parent.f_color=-1;
					m_RotateLeft4(t_node.f_parent.f_parent);
				}
			}
		}
		f_root.f_color=1;
		return 0;
	}
	public boolean m_Set4(String t_key,bb_angelfont2_AngelFont t_value){
		bb_map_Node4 t_node=f_root;
		bb_map_Node4 t_parent=null;
		int t_cmp=0;
		while((t_node)!=null){
			t_parent=t_node;
			t_cmp=m_Compare(t_key,t_node.f_key);
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
		t_node=(new bb_map_Node4()).g_new(t_key,t_value,-1,t_parent);
		if((t_parent)!=null){
			if(t_cmp>0){
				t_parent.f_right=t_node;
			}else{
				t_parent.f_left=t_node;
			}
			m_InsertFixup4(t_node);
		}else{
			f_root=t_node;
		}
		return true;
	}
	public boolean m_Insert2(String t_key,bb_angelfont2_AngelFont t_value){
		return m_Set4(t_key,t_value);
	}
}
class bb_map_StringMap4 extends bb_map_Map4{
	public bb_map_StringMap4 g_new(){
		super.g_new();
		return this;
	}
	public int m_Compare(String t_lhs,String t_rhs){
		return t_lhs.compareTo(t_rhs);
	}
}
class bb_map_Node4 extends Object{
	String f_key="";
	bb_map_Node4 f_right=null;
	bb_map_Node4 f_left=null;
	bb_angelfont2_AngelFont f_value=null;
	int f_color=0;
	bb_map_Node4 f_parent=null;
	public bb_map_Node4 g_new(String t_key,bb_angelfont2_AngelFont t_value,int t_color,bb_map_Node4 t_parent){
		this.f_key=t_key;
		this.f_value=t_value;
		this.f_color=t_color;
		this.f_parent=t_parent;
		return this;
	}
	public bb_map_Node4 g_new2(){
		return this;
	}
}
interface bb_persistable_Persistable{
	public void m_FromString(String t_data);
	public String m_ToString();
}
class bb_highscore_Highscore extends Object implements bb_persistable_Persistable{
	int f__maxCount=0;
	public bb_highscore_Highscore g_new(int t_maxCount){
		f__maxCount=t_maxCount;
		return this;
	}
	public bb_highscore_Highscore g_new2(){
		return this;
	}
	bb_list_List4 f_objects=(new bb_list_List4()).g_new();
	public int m_Count(){
		return f_objects.m_Count();
	}
	public int m_maxCount(){
		return f__maxCount;
	}
	public void m_Sort(){
		if(f_objects.m_Count()<2){
			return;
		}
		bb_list_List4 t_newList=(new bb_list_List4()).g_new();
		bb_score_Score t_current=null;
		while(f_objects.m_Count()>0){
			t_current=f_objects.m_First();
			bb_list_Enumerator4 t_=f_objects.m_ObjectEnumerator();
			while(t_.m_HasNext()){
				bb_score_Score t_check=t_.m_NextObject();
				if(t_check.f_value<t_current.f_value){
					t_current=t_check;
				}
			}
			t_newList.m_AddFirst(t_current);
			f_objects.m_Remove3(t_current);
		}
		f_objects.m_Clear();
		f_objects=t_newList;
	}
	public void m_SizeTrim(){
		while(f_objects.m_Count()>f__maxCount){
			f_objects.m_RemoveLast();
		}
	}
	public void m_Add5(String t_key,int t_value){
		f_objects.m_AddLast4((new bb_score_Score()).g_new(t_key,t_value));
		m_Sort();
		m_SizeTrim();
	}
	public bb_score_Score m_Last(){
		if(f_objects.m_Count()==0){
			return (new bb_score_Score()).g_new("",0);
		}
		return f_objects.m_Last();
	}
	public void m_FromString(String t_input){
		f_objects.m_Clear();
		String t_key="";
		int t_value=0;
		String[] t_splitted=bb_std_lang.split(t_input,",");
		for(int t_count=0;t_count<=bb_std_lang.arrayLength(t_splitted)-2;t_count=t_count+2){
			t_key=bb_std_lang.replace(t_splitted[t_count],"[COMMA]",",");
			t_value=Integer.parseInt((t_splitted[t_count+1]).trim());
			f_objects.m_AddLast4((new bb_score_Score()).g_new(t_key,t_value));
		}
		m_Sort();
	}
	public bb_list_Enumerator4 m_ObjectEnumerator(){
		return f_objects.m_ObjectEnumerator();
	}
	public String m_ToString(){
		String t_result="";
		bb_list_Enumerator4 t_=this.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_score_Score t_score=t_.m_NextObject();
			t_result=t_result+(bb_std_lang.replace(t_score.f_key,",","[COMMA]")+","+String.valueOf(t_score.f_value)+",");
		}
		return t_result;
	}
}
class bb_highscore_IntHighscore extends bb_highscore_Highscore{
	public bb_highscore_IntHighscore g_new(int t_maxCount){
		super.g_new(t_maxCount);
		return this;
	}
	public bb_highscore_IntHighscore g_new2(){
		super.g_new2();
		return this;
	}
}
class bb_gamehighscore_GameHighscore extends bb_highscore_IntHighscore{
	static String[] g_names;
	static int[] g_scores;
	public void m_LoadNamesAndScores(){
		g_names=new String[]{"Michael","Sena","Joe","Mouser","Tinnet","Horas-Ra","Chris","Jana","Bono","Oli"};
		g_scores=new int[]{1000,900,800,700,600,500,400,300,200,100};
	}
	public void m_PrefillMissing(){
		if(m_Count()>=m_maxCount()){
			return;
		}
		for(int t_i=0;t_i<m_maxCount();t_i=t_i+1){
			m_Add5("easy "+g_names[t_i],g_scores[t_i]);
		}
	}
	public bb_gamehighscore_GameHighscore g_new(){
		super.g_new(10);
		m_LoadNamesAndScores();
		m_PrefillMissing();
		return this;
	}
	public void m_FromString(String t_input){
		super.m_FromString(t_input);
		m_PrefillMissing();
	}
}
class bb_score_Score extends Object{
	String f_key="";
	int f_value=0;
	public bb_score_Score g_new(String t_key,int t_value){
		this.f_key=t_key;
		this.f_value=t_value;
		return this;
	}
	public bb_score_Score g_new2(){
		return this;
	}
}
class bb_list_List4 extends Object{
	public bb_list_List4 g_new(){
		return this;
	}
	bb_list_Node4 f__head=((new bb_list_HeadNode4()).g_new());
	public bb_list_Node4 m_AddLast4(bb_score_Score t_data){
		return (new bb_list_Node4()).g_new(f__head,f__head.f__pred,t_data);
	}
	public bb_list_List4 g_new2(bb_score_Score[] t_data){
		bb_score_Score[] t_=t_data;
		int t_2=0;
		while(t_2<bb_std_lang.arrayLength(t_)){
			bb_score_Score t_t=t_[t_2];
			t_2=t_2+1;
			m_AddLast4(t_t);
		}
		return this;
	}
	public int m_Count(){
		int t_n=0;
		bb_list_Node4 t_node=f__head.f__succ;
		while(t_node!=f__head){
			t_node=t_node.f__succ;
			t_n+=1;
		}
		return t_n;
	}
	public bb_score_Score m_First(){
		return f__head.m_NextNode().f__data;
	}
	public bb_list_Enumerator4 m_ObjectEnumerator(){
		return (new bb_list_Enumerator4()).g_new(this);
	}
	public bb_list_Node4 m_AddFirst(bb_score_Score t_data){
		return (new bb_list_Node4()).g_new(f__head.f__succ,f__head,t_data);
	}
	public boolean m_Equals3(bb_score_Score t_lhs,bb_score_Score t_rhs){
		return t_lhs==t_rhs;
	}
	public int m_RemoveEach2(bb_score_Score t_value){
		bb_list_Node4 t_node=f__head.f__succ;
		while(t_node!=f__head){
			bb_list_Node4 t_succ=t_node.f__succ;
			if(m_Equals3(t_node.f__data,t_value)){
				t_node.m_Remove2();
			}
			t_node=t_succ;
		}
		return 0;
	}
	public int m_Remove3(bb_score_Score t_value){
		m_RemoveEach2(t_value);
		return 0;
	}
	public int m_Clear(){
		f__head.f__succ=f__head;
		f__head.f__pred=f__head;
		return 0;
	}
	public bb_score_Score m_RemoveLast(){
		bb_score_Score t_data=f__head.m_PrevNode().f__data;
		f__head.f__pred.m_Remove2();
		return t_data;
	}
	public bb_score_Score m_Last(){
		return f__head.m_PrevNode().f__data;
	}
}
class bb_list_Node4 extends Object{
	bb_list_Node4 f__succ=null;
	bb_list_Node4 f__pred=null;
	bb_score_Score f__data=null;
	public bb_list_Node4 g_new(bb_list_Node4 t_succ,bb_list_Node4 t_pred,bb_score_Score t_data){
		f__succ=t_succ;
		f__pred=t_pred;
		f__succ.f__pred=this;
		f__pred.f__succ=this;
		f__data=t_data;
		return this;
	}
	public bb_list_Node4 g_new2(){
		return this;
	}
	public bb_list_Node4 m_GetNode(){
		return this;
	}
	public bb_list_Node4 m_NextNode(){
		return f__succ.m_GetNode();
	}
	public int m_Remove2(){
		f__succ.f__pred=f__pred;
		f__pred.f__succ=f__succ;
		return 0;
	}
	public bb_list_Node4 m_PrevNode(){
		return f__pred.m_GetNode();
	}
}
class bb_list_HeadNode4 extends bb_list_Node4{
	public bb_list_HeadNode4 g_new(){
		super.g_new2();
		f__succ=(this);
		f__pred=(this);
		return this;
	}
	public bb_list_Node4 m_GetNode(){
		return null;
	}
}
class bb_list_Enumerator4 extends Object{
	bb_list_List4 f__list=null;
	bb_list_Node4 f__curr=null;
	public bb_list_Enumerator4 g_new(bb_list_List4 t_list){
		f__list=t_list;
		f__curr=t_list.f__head.f__succ;
		return this;
	}
	public bb_list_Enumerator4 g_new2(){
		return this;
	}
	public boolean m_HasNext(){
		while(f__curr.f__succ.f__pred!=f__curr){
			f__curr=f__curr.f__succ;
		}
		return f__curr!=f__list.f__head;
	}
	public bb_score_Score m_NextObject(){
		bb_score_Score t_data=f__curr.f__data;
		f__curr=f__curr.f__succ;
		return t_data;
	}
}
class bb_statestore_StateStore extends Object{
	static public void g_Load(bb_persistable_Persistable t_obj){
		t_obj.m_FromString(bb_app.bb_app_LoadState());
	}
	static public void g_Save(bb_persistable_Persistable t_obj){
		bb_app.bb_app_SaveState(t_obj.m_ToString());
	}
}
class bb_chute_Chute extends bb_baseobject_BaseObject{
	public bb_chute_Chute g_new(){
		super.g_new();
		return this;
	}
	int f_height=0;
	public void m_Restart(){
		f_height=75;
	}
	bb_graphics_Image f_bg=null;
	int f_width=0;
	bb_graphics_Image f_bottom=null;
	bb_severity_Severity f_severity=null;
	public void m_OnCreate(bb_director_Director t_director){
		f_bg=bb_graphics.bb_graphics_LoadImage("chute-bg.png",1,bb_graphics_Image.g_DefaultFlags);
		f_width=f_bg.m_Width()+4;
		f_bottom=bb_graphics.bb_graphics_LoadImage("chute-bottom.png",1,bb_graphics_Image.g_DefaultFlags);
		f_severity=bb_severity.bb_severity_CurrentSeverity();
		m_Restart();
		super.m_OnCreate(t_director);
	}
	public void m_OnUpdate(float t_delta,float t_frameTime){
		if(f_severity.m_ChuteShouldAdvance()){
			f_height+=f_severity.m_ChuteAdvanceHeight();
			f_severity.m_ChuteMarkAsAdvanced();
		}
	}
	public void m_OnRender(){
		for(float t_posY=0.0f;t_posY<=(float)(f_height);t_posY=t_posY+6.0f){
			bb_graphics.bb_graphics_DrawImage(f_bg,(float)(44+f_width*0),t_posY,0);
			bb_graphics.bb_graphics_DrawImage(f_bg,(float)(44+f_width*1),t_posY,0);
			bb_graphics.bb_graphics_DrawImage(f_bg,(float)(44+f_width*2),t_posY,0);
			bb_graphics.bb_graphics_DrawImage(f_bg,(float)(44+f_width*3),t_posY,0);
		}
		bb_graphics.bb_graphics_DrawImage(f_bottom,(float)(42+f_width*0),(float)(f_height),0);
		bb_graphics.bb_graphics_DrawImage(f_bottom,(float)(42+f_width*1),(float)(f_height),0);
		bb_graphics.bb_graphics_DrawImage(f_bottom,(float)(42+f_width*2),(float)(f_height),0);
		bb_graphics.bb_graphics_DrawImage(f_bottom,(float)(42+f_width*3),(float)(f_height),0);
	}
	public int m_Height(){
		return f_height;
	}
}
class bb_severity_Severity extends Object{
	public bb_severity_Severity g_new(){
		return this;
	}
	int f_nextChuteAdvanceTime=0;
	int f_nextShapeDropTime=0;
	int f_lastTime=0;
	public void m_WarpTime(int t_diff){
		f_nextChuteAdvanceTime+=t_diff;
		f_nextShapeDropTime+=t_diff;
		f_lastTime+=t_diff;
	}
	int f_level=0;
	int f_activatedShapes=0;
	int f_slowDownDuration=0;
	bb_stack_IntStack f_lastTypes=(new bb_stack_IntStack()).g_new();
	float f_progress=1.0f;
	public void m_ChuteMarkAsAdvanced(){
		f_nextChuteAdvanceTime=(int)(bb_random.bb_random_Rnd2(2000.0f,4000.0f));
		int t_2=f_level;
		if(t_2==0){
			f_nextChuteAdvanceTime=(int)((float)(f_nextChuteAdvanceTime)+5000.0f*f_progress);
		}else{
			if(t_2==1){
				f_nextChuteAdvanceTime=(int)((float)(f_nextChuteAdvanceTime)+5000.0f*f_progress);
			}else{
				if(t_2==2){
					f_nextChuteAdvanceTime=(int)((float)(f_nextChuteAdvanceTime)+5000.0f*f_progress);
				}
			}
		}
		f_nextChuteAdvanceTime*=2;
		f_nextChuteAdvanceTime+=f_lastTime;
	}
	public void m_ShapeDropped(){
		int t_3=f_level;
		if(t_3==0){
			f_nextShapeDropTime=(int)((float)(f_lastTime)+bb_random.bb_random_Rnd2(450.0f,1800.0f+2500.0f*f_progress));
		}else{
			if(t_3==1){
				f_nextShapeDropTime=(int)((float)(f_lastTime)+bb_random.bb_random_Rnd2(375.0f,1800.0f+2500.0f*f_progress));
			}else{
				if(t_3==2){
					f_nextShapeDropTime=(int)((float)(f_lastTime)+bb_random.bb_random_Rnd2(300.0f,1800.0f+2500.0f*f_progress));
				}
			}
		}
	}
	int[] f_shapeTypes=new int[]{0,1,2,3};
	public void m_RandomizeShapeTypes(){
		int t_swapIndex=0;
		int t_tmpType=0;
		for(int t_i=0;t_i<bb_std_lang.arrayLength(f_shapeTypes);t_i=t_i+1){
			do{
				t_swapIndex=(int)(bb_random.bb_random_Rnd2(0.0f,(float)(bb_std_lang.arrayLength(f_shapeTypes))));
			}while(!(t_swapIndex!=t_i));
			t_tmpType=f_shapeTypes[t_i];
			f_shapeTypes[t_i]=f_shapeTypes[t_swapIndex];
			f_shapeTypes[t_swapIndex]=t_tmpType;
		}
	}
	int f_startTime=0;
	public void m_Restart(){
		int t_1=f_level;
		if(t_1==0){
			f_activatedShapes=2;
			f_slowDownDuration=160000;
		}else{
			if(t_1==1){
				f_activatedShapes=3;
				f_slowDownDuration=140000;
			}else{
				if(t_1==2){
					f_activatedShapes=4;
					f_slowDownDuration=120000;
				}
			}
		}
		f_lastTypes.m_Clear();
		m_ChuteMarkAsAdvanced();
		m_ShapeDropped();
		m_RandomizeShapeTypes();
		f_progress=1.0f;
		f_startTime=bb_app.bb_app_Millisecs();
	}
	public int m_MinSliderTypes(){
		if(f_level==0){
			return 2;
		}else{
			if(f_level==1){
				return 3;
			}else{
				return 4;
			}
		}
	}
	public void m_ConfigureSlider(bb_list_IntList t_config){
		bb_set_IntSet t_usedTypes=(new bb_set_IntSet()).g_new();
		t_config.m_Clear();
		for(int t_i=0;t_i<m_MinSliderTypes();t_i=t_i+1){
			t_usedTypes.m_Insert4(f_shapeTypes[t_i]);
			t_config.m_AddLast5(f_shapeTypes[t_i]);
		}
		while(t_config.m_Count()<4){
			if(t_usedTypes.m_Count()>=f_activatedShapes || bb_random.bb_random_Rnd()<0.5f){
				t_config.m_AddLast5(f_shapeTypes[(int)(bb_random.bb_random_Rnd2(0.0f,(float)(t_usedTypes.m_Count())))]);
			}else{
				t_config.m_AddLast5(f_shapeTypes[t_usedTypes.m_Count()]);
				t_usedTypes.m_Insert4(f_shapeTypes[t_usedTypes.m_Count()]);
			}
		}
		f_activatedShapes=t_usedTypes.m_Count();
	}
	public boolean m_ChuteShouldAdvance(){
		return f_lastTime>=f_nextChuteAdvanceTime;
	}
	public int m_ChuteAdvanceHeight(){
		return 40;
	}
	public void m_Set5(int t_level){
		this.f_level=t_level;
		m_Restart();
	}
	public void m_OnUpdate(float t_delta,float t_frameTime){
		f_lastTime=bb_app.bb_app_Millisecs();
		if(f_progress>0.0f){
			f_progress=1.0f-1.0f/(float)(f_slowDownDuration)*(float)(f_lastTime-f_startTime);
			f_progress=bb_math.bb_math_Max2(0.0f,f_progress);
		}
	}
	public boolean m_ShapeShouldBeDropped(){
		return f_lastTime>=f_nextShapeDropTime;
	}
	public int m_RandomType(){
		int t_newType=0;
		boolean t_finished=false;
		do{
			t_finished=true;
			t_newType=(int)(bb_random.bb_random_Rnd2(0.0f,(float)(f_activatedShapes)));
			if(f_lastTypes.m_Length()>=2){
				if(f_lastTypes.m_Get2(0)==t_newType){
					if(f_lastTypes.m_Get2(1)==t_newType){
						t_finished=false;
					}
				}
			}
		}while(!(t_finished==true));
		if(f_lastTypes.m_Length()>=2){
			f_lastTypes.m_Remove4(0);
		}
		f_lastTypes.m_Push(t_newType);
		return f_shapeTypes[t_newType];
	}
	int[] f_laneTimes=new int[]{0,0,0,0};
	public int m_RandomLane(){
		int t_newLane=0;
		int t_now=bb_app.bb_app_Millisecs();
		do{
			t_newLane=(int)(bb_random.bb_random_Rnd2(0.0f,4.0f));
		}while(!(f_laneTimes[t_newLane]<t_now));
		f_laneTimes[t_newLane]=t_now+1400;
		return t_newLane;
	}
	public String m_ToString(){
		if(f_level==0){
			return "easy";
		}else{
			if(f_level==1){
				return "norm";
			}else{
				return "adv.";
			}
		}
	}
}
class bb_slider_Slider extends bb_baseobject_BaseObject{
	public bb_slider_Slider g_new(){
		super.g_new();
		return this;
	}
	bb_graphics_Image[] f_images=new bb_graphics_Image[0];
	bb_list_IntList f_config=(new bb_list_IntList()).g_new();
	int[] f_configArray=new int[0];
	public void m_InitializeConfig(){
		bb_severity.bb_severity_CurrentSeverity().m_ConfigureSlider(f_config);
		f_configArray=f_config.m_ToArray();
	}
	boolean f_movementActive=false;
	int f_movementStart=0;
	public void m_Restart(){
		m_InitializeConfig();
		f_movementActive=false;
		f_movementStart=0;
	}
	bb_sprite_Sprite f_arrowLeft=null;
	bb_sprite_Sprite f_arrowRight=null;
	float f_posY=.0f;
	public void m_OnCreate(bb_director_Director t_director){
		f_images=new bb_graphics_Image[]{bb_graphics.bb_graphics_LoadImage("circle_outside.png",1,bb_graphics_Image.g_DefaultFlags),bb_graphics.bb_graphics_LoadImage("plus_outside.png",1,bb_graphics_Image.g_DefaultFlags),bb_graphics.bb_graphics_LoadImage("star_outside.png",1,bb_graphics_Image.g_DefaultFlags),bb_graphics.bb_graphics_LoadImage("tire_outside.png",1,bb_graphics_Image.g_DefaultFlags)};
		f_arrowLeft=(new bb_sprite_Sprite()).g_new("arrow_ingame.png",null);
		f_arrowLeft.m_pos().f_y=t_director.m_size().f_y-f_arrowLeft.m_size().f_y;
		bb_vector2d_Vector2D t_=f_arrowLeft.m_pos();
		t_.f_x=t_.f_x-4.0f;
		f_arrowRight=(new bb_sprite_Sprite()).g_new("arrow_ingame2.png",null);
		f_arrowRight.m_pos2(t_director.m_size().m_Copy().m_Sub(f_arrowRight.m_size()));
		bb_vector2d_Vector2D t_2=f_arrowRight.m_pos();
		t_2.f_x=t_2.f_x+4.0f;
		super.m_OnCreate(t_director);
		f_posY=t_director.m_size().f_y-(float)(f_images[0].m_Height())-60.0f;
	}
	public bb_vector2d_Vector2D m_pos(){
		return f_arrowLeft.m_pos();
	}
	int f_direction=0;
	public float m_GetMovementOffset(){
		if(!f_movementActive){
			return 0.0f;
		}
		int t_now=bb_app.bb_app_Millisecs();
		float t_percent=100.0f;
		float t_movementOffset=0.0f;
		if(f_movementStart+300>=t_now){
			t_percent=(float)Math.ceil(0.33333333333333331f*(float)(t_now-f_movementStart));
			t_movementOffset=(float)Math.ceil((float)(f_images[0].m_Width())/100.0f*t_percent);
		}
		if(f_direction==1){
			t_movementOffset=t_movementOffset*-1.0f;
		}
		if(f_movementStart+300<t_now){
			f_movementActive=false;
			if(f_direction==1){
				int t_tmpType=f_config.m_First();
				f_config.m_RemoveFirst();
				f_config.m_AddLast5(t_tmpType);
				f_configArray=f_config.m_ToArray();
			}else{
				int t_tmpType2=f_config.m_Last();
				f_config.m_RemoveLast();
				f_config.m_AddFirst2(t_tmpType2);
				f_configArray=f_config.m_ToArray();
			}
		}
		return t_movementOffset;
	}
	public void m_OnRender(){
		float t_posX=44.0f+m_GetMovementOffset();
		bb_graphics_Image t_img=null;
		bb_graphics.bb_graphics_PushMatrix();
		bb_graphics.bb_graphics_SetColor(255.0f,255.0f,255.0f);
		bb_graphics.bb_graphics_DrawRect(0.0f,f_posY+(float)(f_images[f_config.m_First()].m_Height()),m_director().m_size().f_x,m_director().m_size().f_y);
		bb_graphics.bb_graphics_PopMatrix();
		if(t_posX>44.0f){
			t_img=f_images[f_config.m_Last()];
			bb_graphics.bb_graphics_DrawImage(t_img,(float)(t_img.m_Width()*-1)+t_posX,f_posY,0);
		}
		if(t_posX<44.0f){
			t_img=f_images[f_config.m_First()];
			bb_graphics.bb_graphics_DrawImage(t_img,(float)(t_img.m_Width()*4)+t_posX,f_posY,0);
		}
		bb_list_Enumerator5 t_=f_config.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			int t_type=t_.m_NextObject();
			bb_graphics.bb_graphics_DrawImage(f_images[t_type],t_posX,f_posY,0);
			t_posX=t_posX+(float)(f_images[t_type].m_Width());
		}
		f_arrowRight.m_OnRender();
		f_arrowLeft.m_OnRender();
	}
	public boolean m_Match(bb_shape_Shape t_shape){
		if(f_movementActive){
			return false;
		}
		if(t_shape.f_type==f_configArray[t_shape.f_lane]){
			return true;
		}
		return false;
	}
	public void m_SlideLeft(){
		if(f_movementActive){
			return;
		}
		f_direction=1;
		f_movementStart=bb_app.bb_app_Millisecs();
		f_movementActive=true;
	}
	public void m_SlideRight(){
		if(f_movementActive){
			return;
		}
		f_direction=2;
		f_movementStart=bb_app.bb_app_Millisecs();
		f_movementActive=true;
	}
}
class bb_font_Font extends bb_baseobject_BaseObject{
	String f_name="";
	public bb_font_Font g_new(String t_fontName,bb_vector2d_Vector2D t_pos){
		super.g_new();
		if(t_pos==null){
			t_pos=(new bb_vector2d_Vector2D()).g_new(0.0f,0.0f);
		}
		this.f_name=t_fontName;
		this.m_pos2(t_pos);
		return this;
	}
	public bb_font_Font g_new2(){
		super.g_new();
		return this;
	}
	int f__align=0;
	public void m_align(int t_newAlign){
		int t_1=t_newAlign;
		if(t_1==0 || t_1==1 || t_1==2){
			f__align=t_newAlign;
		}else{
			bb_std_lang.error("Invalid align value specified.");
		}
	}
	public int m_align2(){
		return f__align;
	}
	bb_color_Color f_color=null;
	String f__text="";
	bb_map_StringMap5 f_fontStore=(new bb_map_StringMap5()).g_new();
	public bb_angelfont_AngelFont m_font(){
		return f_fontStore.m_Get(f_name);
	}
	boolean f_recalculateSize=false;
	public void m_text(String t_newText){
		f__text=t_newText;
		if(!((m_font())!=null)){
			f_recalculateSize=true;
			return;
		}
		float t_width=(float)(m_font().m_TextWidth(t_newText));
		float t_height=(float)(m_font().m_TextHeight(t_newText));
		m_size2((new bb_vector2d_Vector2D()).g_new(t_width,t_height));
	}
	public String m_text2(){
		return f__text;
	}
	public void m_OnCreate(bb_director_Director t_director){
		super.m_OnCreate(t_director);
		if(!f_fontStore.m_Contains(f_name)){
			f_fontStore.m_Set7(f_name,(new bb_angelfont_AngelFont()).g_new(""));
			f_fontStore.m_Get(f_name).m_LoadFont(f_name);
		}
		if(f_recalculateSize){
			f_recalculateSize=false;
			m_text(f__text);
		}
	}
	public void m_OnRender(){
		if((f_color)!=null){
			f_color.m_Activate();
		}
		m_font().m_DrawText2(f__text,(int)(m_pos().f_x),(int)(m_pos().f_y),f__align);
		if((f_color)!=null){
			f_color.m_Deactivate();
		}
	}
}
class bb_angelfont_AngelFont extends Object{
	bb_char_Char[] f_chars=new bb_char_Char[256];
	boolean f_useKerning=true;
	bb_map_StringMap3 f_kernPairs=(new bb_map_StringMap3()).g_new();
	public int m_TextWidth(String t_txt){
		String t_prevChar="";
		int t_width=0;
		for(int t_i=0;t_i<t_txt.length();t_i=t_i+1){
			int t_asc=(int)t_txt.charAt(t_i);
			bb_char_Char t_ac=f_chars[t_asc];
			String t_thisChar=String.valueOf((char)(t_asc));
			if(t_ac!=null){
				if(f_useKerning){
					String t_key=t_prevChar+"_"+t_thisChar;
					if(f_kernPairs.m_Contains(t_key)){
						t_width+=f_kernPairs.m_Get(t_key).f_amount;
					}
				}
				t_width+=t_ac.f_xAdvance;
				t_prevChar=t_thisChar;
			}
		}
		return t_width;
	}
	public int m_TextHeight(String t_txt){
		int t_h=0;
		for(int t_i=0;t_i<t_txt.length();t_i=t_i+1){
			int t_asc=(int)t_txt.charAt(t_i);
			bb_char_Char t_ac=f_chars[t_asc];
			if(t_ac.f_height>t_h){
				t_h=t_ac.f_height;
			}
		}
		return t_h;
	}
	static String g_error;
	static bb_angelfont_AngelFont g_current;
	String f_iniText="";
	int f_height=0;
	int f_heightOffset=9999;
	bb_graphics_Image f_image=null;
	public void m_LoadFont(String t_url){
		g_error="";
		g_current=this;
		f_iniText=bb_app.bb_app_LoadString(t_url+".txt");
		String[] t_lines=bb_std_lang.split(f_iniText,String.valueOf((char)(10)));
		String[] t_=t_lines;
		int t_2=0;
		while(t_2<bb_std_lang.arrayLength(t_)){
			String t_line=t_[t_2];
			t_2=t_2+1;
			t_line=t_line.trim();
			if(t_line.startsWith("id,") || (t_line.compareTo("")==0)){
				continue;
			}
			if(t_line.startsWith("first,")){
				continue;
			}
			String[] t_data=bb_std_lang.split(t_line,",");
			for(int t_i=0;t_i<bb_std_lang.arrayLength(t_data);t_i=t_i+1){
				t_data[t_i]=t_data[t_i].trim();
			}
			g_error=g_error+(String.valueOf(bb_std_lang.arrayLength(t_data))+",");
			if(bb_std_lang.arrayLength(t_data)>0){
				if(bb_std_lang.arrayLength(t_data)==3){
					f_kernPairs.m_Insert(String.valueOf((char)(Integer.parseInt((t_data[0]).trim())))+"_"+String.valueOf((char)(Integer.parseInt((t_data[1]).trim()))),(new bb_kernpair_KernPair()).g_new(Integer.parseInt((t_data[0]).trim()),Integer.parseInt((t_data[1]).trim()),Integer.parseInt((t_data[2]).trim())));
				}else{
					if(bb_std_lang.arrayLength(t_data)>=8){
						f_chars[Integer.parseInt((t_data[0]).trim())]=(new bb_char_Char()).g_new(Integer.parseInt((t_data[1]).trim()),Integer.parseInt((t_data[2]).trim()),Integer.parseInt((t_data[3]).trim()),Integer.parseInt((t_data[4]).trim()),Integer.parseInt((t_data[5]).trim()),Integer.parseInt((t_data[6]).trim()),Integer.parseInt((t_data[7]).trim()));
						bb_char_Char t_ch=f_chars[Integer.parseInt((t_data[0]).trim())];
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
		f_image=bb_graphics.bb_graphics_LoadImage(t_url+".png",1,bb_graphics_Image.g_DefaultFlags);
	}
	String f_name="";
	static bb_map_StringMap5 g__list;
	public bb_angelfont_AngelFont g_new(String t_url){
		if(t_url.compareTo("")!=0){
			this.m_LoadFont(t_url);
			this.f_name=t_url;
			g__list.m_Insert3(t_url,this);
		}
		return this;
	}
	int f_xOffset=0;
	public void m_DrawText(String t_txt,int t_x,int t_y){
		String t_prevChar="";
		f_xOffset=0;
		for(int t_i=0;t_i<t_txt.length();t_i=t_i+1){
			int t_asc=(int)t_txt.charAt(t_i);
			bb_char_Char t_ac=f_chars[t_asc];
			String t_thisChar=String.valueOf((char)(t_asc));
			if(t_ac!=null){
				if(f_useKerning){
					String t_key=t_prevChar+"_"+t_thisChar;
					if(f_kernPairs.m_Contains(t_key)){
						f_xOffset+=f_kernPairs.m_Get(t_key).f_amount;
					}
				}
				t_ac.m_Draw(f_image,t_x+f_xOffset,t_y);
				f_xOffset+=t_ac.f_xAdvance;
				t_prevChar=t_thisChar;
			}
		}
	}
	public void m_DrawText2(String t_txt,int t_x,int t_y,int t_align){
		f_xOffset=0;
		int t_1=t_align;
		if(t_1==1){
			m_DrawText(t_txt,t_x-m_TextWidth(t_txt)/2,t_y);
		}else{
			if(t_1==2){
				m_DrawText(t_txt,t_x-m_TextWidth(t_txt),t_y);
			}else{
				if(t_1==0){
					m_DrawText(t_txt,t_x,t_y);
				}
			}
		}
	}
}
class bb_color_Color extends Object{
	float f_red=.0f;
	float f_green=.0f;
	float f_blue=.0f;
	float f_alpha=.0f;
	public bb_color_Color g_new(float t_red,float t_green,float t_blue,float t_alpha){
		this.f_red=t_red;
		this.f_green=t_green;
		this.f_blue=t_blue;
		this.f_alpha=t_alpha;
		return this;
	}
	public bb_color_Color g_new2(){
		return this;
	}
	bb_color_Color f_oldColor=null;
	public void m_Set6(bb_color_Color t_color){
		bb_graphics.bb_graphics_SetColor(t_color.f_red,t_color.f_green,t_color.f_blue);
		bb_graphics.bb_graphics_SetAlpha(t_color.f_alpha);
	}
	public void m_Activate(){
		if(!((f_oldColor)!=null)){
			f_oldColor=(new bb_color_Color()).g_new(0.0f,0.0f,0.0f,0.0f);
		}
		float[] t_colorStack=bb_graphics.bb_graphics_GetColor();
		f_oldColor.f_red=t_colorStack[0];
		f_oldColor.f_green=t_colorStack[1];
		f_oldColor.f_blue=t_colorStack[2];
		f_oldColor.f_alpha=bb_graphics.bb_graphics_GetAlpha();
		m_Set6(this);
	}
	public void m_Deactivate(){
		if((f_oldColor)!=null){
			m_Set6(f_oldColor);
		}
	}
}
abstract class bb_map_Map5 extends Object{
	public bb_map_Map5 g_new(){
		return this;
	}
	bb_map_Node5 f_root=null;
	abstract public int m_Compare(String t_lhs,String t_rhs);
	public bb_map_Node5 m_FindNode(String t_key){
		bb_map_Node5 t_node=f_root;
		while((t_node)!=null){
			int t_cmp=m_Compare(t_key,t_node.f_key);
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
	public bb_angelfont_AngelFont m_Get(String t_key){
		bb_map_Node5 t_node=m_FindNode(t_key);
		if((t_node)!=null){
			return t_node.f_value;
		}
		return null;
	}
	public boolean m_Contains(String t_key){
		return m_FindNode(t_key)!=null;
	}
	public int m_RotateLeft5(bb_map_Node5 t_node){
		bb_map_Node5 t_child=t_node.f_right;
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
			f_root=t_child;
		}
		t_child.f_left=t_node;
		t_node.f_parent=t_child;
		return 0;
	}
	public int m_RotateRight5(bb_map_Node5 t_node){
		bb_map_Node5 t_child=t_node.f_left;
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
			f_root=t_child;
		}
		t_child.f_right=t_node;
		t_node.f_parent=t_child;
		return 0;
	}
	public int m_InsertFixup5(bb_map_Node5 t_node){
		while(((t_node.f_parent)!=null) && t_node.f_parent.f_color==-1 && ((t_node.f_parent.f_parent)!=null)){
			if(t_node.f_parent==t_node.f_parent.f_parent.f_left){
				bb_map_Node5 t_uncle=t_node.f_parent.f_parent.f_right;
				if(((t_uncle)!=null) && t_uncle.f_color==-1){
					t_node.f_parent.f_color=1;
					t_uncle.f_color=1;
					t_uncle.f_parent.f_color=-1;
					t_node=t_uncle.f_parent;
				}else{
					if(t_node==t_node.f_parent.f_right){
						t_node=t_node.f_parent;
						m_RotateLeft5(t_node);
					}
					t_node.f_parent.f_color=1;
					t_node.f_parent.f_parent.f_color=-1;
					m_RotateRight5(t_node.f_parent.f_parent);
				}
			}else{
				bb_map_Node5 t_uncle2=t_node.f_parent.f_parent.f_left;
				if(((t_uncle2)!=null) && t_uncle2.f_color==-1){
					t_node.f_parent.f_color=1;
					t_uncle2.f_color=1;
					t_uncle2.f_parent.f_color=-1;
					t_node=t_uncle2.f_parent;
				}else{
					if(t_node==t_node.f_parent.f_left){
						t_node=t_node.f_parent;
						m_RotateRight5(t_node);
					}
					t_node.f_parent.f_color=1;
					t_node.f_parent.f_parent.f_color=-1;
					m_RotateLeft5(t_node.f_parent.f_parent);
				}
			}
		}
		f_root.f_color=1;
		return 0;
	}
	public boolean m_Set7(String t_key,bb_angelfont_AngelFont t_value){
		bb_map_Node5 t_node=f_root;
		bb_map_Node5 t_parent=null;
		int t_cmp=0;
		while((t_node)!=null){
			t_parent=t_node;
			t_cmp=m_Compare(t_key,t_node.f_key);
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
		t_node=(new bb_map_Node5()).g_new(t_key,t_value,-1,t_parent);
		if((t_parent)!=null){
			if(t_cmp>0){
				t_parent.f_right=t_node;
			}else{
				t_parent.f_left=t_node;
			}
			m_InsertFixup5(t_node);
		}else{
			f_root=t_node;
		}
		return true;
	}
	public boolean m_Insert3(String t_key,bb_angelfont_AngelFont t_value){
		return m_Set7(t_key,t_value);
	}
}
class bb_map_StringMap5 extends bb_map_Map5{
	public bb_map_StringMap5 g_new(){
		super.g_new();
		return this;
	}
	public int m_Compare(String t_lhs,String t_rhs){
		return t_lhs.compareTo(t_rhs);
	}
}
class bb_map_Node5 extends Object{
	String f_key="";
	bb_map_Node5 f_right=null;
	bb_map_Node5 f_left=null;
	bb_angelfont_AngelFont f_value=null;
	int f_color=0;
	bb_map_Node5 f_parent=null;
	public bb_map_Node5 g_new(String t_key,bb_angelfont_AngelFont t_value,int t_color,bb_map_Node5 t_parent){
		this.f_key=t_key;
		this.f_value=t_value;
		this.f_color=t_color;
		this.f_parent=t_parent;
		return this;
	}
	public bb_map_Node5 g_new2(){
		return this;
	}
}
class bb_animation_Animation extends bb_fanout_FanOut{
	float f_startValue=.0f;
	float f_endValue=.0f;
	float f_duration=.0f;
	public bb_animation_Animation g_new(float t_startValue,float t_endValue,float t_duration){
		super.g_new();
		this.f_startValue=t_startValue;
		this.f_endValue=t_endValue;
		this.f_duration=t_duration;
		return this;
	}
	public bb_animation_Animation g_new2(){
		super.g_new();
		return this;
	}
	bb_fader_Fader f_effect=null;
	bb_transition_Transition f_transition=((new bb_transition_TransitionLinear()).g_new());
	boolean f_finished=false;
	public void m_Pause(){
		f_finished=true;
	}
	float f_animationTime=.0f;
	float f__value=.0f;
	public void m_OnUpdate(float t_delta,float t_frameTime){
		super.m_OnUpdate(t_delta,t_frameTime);
		if(f_finished){
			return;
		}
		f_animationTime+=t_frameTime;
		float t_progress=bb_math.bb_math_Min2(1.0f,f_animationTime/f_duration);
		float t_t=f_transition.m_Calculate(t_progress);
		f__value=f_startValue*(1.0f-t_t)+f_endValue*t_t;
		if(f_animationTime>=f_duration){
			f_animationTime=f_duration;
			f_finished=true;
		}
	}
	public void m_OnRender(){
		if(!((f_effect)!=null)){
			super.m_OnRender();
			return;
		}
		if(m_Count()==0){
			return;
		}
		f_effect.m_PreRender(f__value);
		bb_list_Enumerator t_=this.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			bb_directorevents_DirectorEvents t_obj=t_.m_NextObject();
			f_effect.m_PreNode(f__value,t_obj);
			t_obj.m_OnRender();
			f_effect.m_PostNode(f__value,t_obj);
		}
		f_effect.m_PostRender(f__value);
	}
	public void m_Play(){
		f_finished=false;
	}
	public void m_Restart(){
		f_animationTime=0.0f;
		m_Play();
	}
	public boolean m_IsPlaying(){
		return !f_finished;
	}
}
interface bb_fader_Fader{
	public void m_PreRender(float t_value);
	public void m_PreNode(float t_value,bb_directorevents_DirectorEvents t_node);
	public void m_PostNode(float t_value,bb_directorevents_DirectorEvents t_node);
	public void m_PostRender(float t_value);
}
class bb_fader_FaderScale extends Object implements bb_fader_Fader{
	public bb_fader_FaderScale g_new(){
		return this;
	}
	public void m_PreRender(float t_value){
	}
	public void m_PostRender(float t_value){
	}
	bb_sizeable_Sizeable f_sizeNode=null;
	float f_offsetX=.0f;
	float f_offsetY=.0f;
	bb_positionable_Positionable f_posNode=null;
	public void m_PreNode(float t_value,bb_directorevents_DirectorEvents t_node){
		if(t_value==1.0f){
			return;
		}
		bb_graphics.bb_graphics_PushMatrix();
		bb_directorevents_DirectorEvents t_=t_node;
		f_sizeNode=(t_ instanceof bb_sizeable_Sizeable ? (bb_sizeable_Sizeable)t_ : null);
		if((f_sizeNode)!=null){
			f_offsetX=f_sizeNode.m_center().f_x*(t_value-1.0f);
			f_offsetY=f_sizeNode.m_center().f_y*(t_value-1.0f);
			bb_graphics.bb_graphics_Translate(-f_offsetX,-f_offsetY);
		}
		bb_directorevents_DirectorEvents t_2=t_node;
		f_posNode=(t_2 instanceof bb_positionable_Positionable ? (bb_positionable_Positionable)t_2 : null);
		if((f_posNode)!=null){
			f_offsetX=f_posNode.m_pos().f_x*(t_value-1.0f);
			f_offsetY=f_posNode.m_pos().f_y*(t_value-1.0f);
			bb_graphics.bb_graphics_Translate(-f_offsetX,-f_offsetY);
		}
		bb_graphics.bb_graphics_Scale(t_value,t_value);
	}
	public void m_PostNode(float t_value,bb_directorevents_DirectorEvents t_node){
		if(t_value==1.0f){
			return;
		}
		bb_graphics.bb_graphics_PopMatrix();
	}
}
interface bb_transition_Transition{
	public float m_Calculate(float t_progress);
}
class bb_transition_TransitionInCubic extends Object implements bb_transition_Transition{
	public bb_transition_TransitionInCubic g_new(){
		return this;
	}
	public float m_Calculate(float t_progress){
		return (float)Math.pow(t_progress,3.0f);
	}
}
class bb_transition_TransitionLinear extends Object implements bb_transition_Transition{
	public bb_transition_TransitionLinear g_new(){
		return this;
	}
	public float m_Calculate(float t_progress){
		return t_progress;
	}
}
class bb_stack_Stack extends Object{
	public bb_stack_Stack g_new(){
		return this;
	}
	int[] f_data=new int[0];
	int f_length=0;
	public bb_stack_Stack g_new2(int[] t_data){
		this.f_data=((int[])bb_std_lang.sliceArray(t_data,0));
		this.f_length=bb_std_lang.arrayLength(t_data);
		return this;
	}
	public int m_Clear(){
		f_length=0;
		return 0;
	}
	public int m_Length(){
		return f_length;
	}
	public int m_Get2(int t_index){
		return f_data[t_index];
	}
	public int m_Remove4(int t_index){
		for(int t_i=t_index;t_i<f_length-1;t_i=t_i+1){
			f_data[t_i]=f_data[t_i+1];
		}
		f_length-=1;
		return 0;
	}
	public int m_Push(int t_value){
		if(f_length==bb_std_lang.arrayLength(f_data)){
			f_data=(int[])bb_std_lang.resizeArray(f_data,f_length*2+10);
		}
		f_data[f_length]=t_value;
		f_length+=1;
		return 0;
	}
}
class bb_stack_IntStack extends bb_stack_Stack{
	public bb_stack_IntStack g_new(){
		super.g_new();
		return this;
	}
}
class bb_list_List5 extends Object{
	public bb_list_List5 g_new(){
		return this;
	}
	bb_list_Node5 f__head=((new bb_list_HeadNode5()).g_new());
	public bb_list_Node5 m_AddLast5(int t_data){
		return (new bb_list_Node5()).g_new(f__head,f__head.f__pred,t_data);
	}
	public bb_list_List5 g_new2(int[] t_data){
		int[] t_=t_data;
		int t_2=0;
		while(t_2<bb_std_lang.arrayLength(t_)){
			int t_t=t_[t_2];
			t_2=t_2+1;
			m_AddLast5(t_t);
		}
		return this;
	}
	public int m_Clear(){
		f__head.f__succ=f__head;
		f__head.f__pred=f__head;
		return 0;
	}
	public int m_Count(){
		int t_n=0;
		bb_list_Node5 t_node=f__head.f__succ;
		while(t_node!=f__head){
			t_node=t_node.f__succ;
			t_n+=1;
		}
		return t_n;
	}
	public bb_list_Enumerator5 m_ObjectEnumerator(){
		return (new bb_list_Enumerator5()).g_new(this);
	}
	public int[] m_ToArray(){
		int[] t_arr=new int[m_Count()];
		int t_i=0;
		bb_list_Enumerator5 t_=this.m_ObjectEnumerator();
		while(t_.m_HasNext()){
			int t_t=t_.m_NextObject();
			t_arr[t_i]=t_t;
			t_i+=1;
		}
		return t_arr;
	}
	public int m_First(){
		return f__head.m_NextNode().f__data;
	}
	public int m_RemoveFirst(){
		int t_data=f__head.m_NextNode().f__data;
		f__head.f__succ.m_Remove2();
		return t_data;
	}
	public int m_Last(){
		return f__head.m_PrevNode().f__data;
	}
	public int m_RemoveLast(){
		int t_data=f__head.m_PrevNode().f__data;
		f__head.f__pred.m_Remove2();
		return t_data;
	}
	public bb_list_Node5 m_AddFirst2(int t_data){
		return (new bb_list_Node5()).g_new(f__head.f__succ,f__head,t_data);
	}
}
class bb_list_IntList extends bb_list_List5{
	public bb_list_IntList g_new(){
		super.g_new();
		return this;
	}
}
class bb_list_Node5 extends Object{
	bb_list_Node5 f__succ=null;
	bb_list_Node5 f__pred=null;
	int f__data=0;
	public bb_list_Node5 g_new(bb_list_Node5 t_succ,bb_list_Node5 t_pred,int t_data){
		f__succ=t_succ;
		f__pred=t_pred;
		f__succ.f__pred=this;
		f__pred.f__succ=this;
		f__data=t_data;
		return this;
	}
	public bb_list_Node5 g_new2(){
		return this;
	}
	public bb_list_Node5 m_GetNode(){
		return this;
	}
	public bb_list_Node5 m_NextNode(){
		return f__succ.m_GetNode();
	}
	public int m_Remove2(){
		f__succ.f__pred=f__pred;
		f__pred.f__succ=f__succ;
		return 0;
	}
	public bb_list_Node5 m_PrevNode(){
		return f__pred.m_GetNode();
	}
}
class bb_list_HeadNode5 extends bb_list_Node5{
	public bb_list_HeadNode5 g_new(){
		super.g_new2();
		f__succ=(this);
		f__pred=(this);
		return this;
	}
	public bb_list_Node5 m_GetNode(){
		return null;
	}
}
class bb_set_Set extends Object{
	bb_map_Map6 f_map=null;
	public bb_set_Set g_new(bb_map_Map6 t_map){
		this.f_map=t_map;
		return this;
	}
	public bb_set_Set g_new2(){
		return this;
	}
	public int m_Insert4(int t_value){
		f_map.m_Insert5(t_value,null);
		return 0;
	}
	public int m_Count(){
		return f_map.m_Count();
	}
	public int m_Clear(){
		f_map.m_Clear();
		return 0;
	}
	public int m_Remove4(int t_value){
		f_map.m_Remove4(t_value);
		return 0;
	}
	public boolean m_Contains2(int t_value){
		return f_map.m_Contains2(t_value);
	}
}
class bb_set_IntSet extends bb_set_Set{
	public bb_set_IntSet g_new(){
		super.g_new((new bb_map_IntMap()).g_new());
		return this;
	}
}
abstract class bb_map_Map6 extends Object{
	public bb_map_Map6 g_new(){
		return this;
	}
	bb_map_Node6 f_root=null;
	abstract public int m_Compare2(int t_lhs,int t_rhs);
	public int m_RotateLeft6(bb_map_Node6 t_node){
		bb_map_Node6 t_child=t_node.f_right;
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
			f_root=t_child;
		}
		t_child.f_left=t_node;
		t_node.f_parent=t_child;
		return 0;
	}
	public int m_RotateRight6(bb_map_Node6 t_node){
		bb_map_Node6 t_child=t_node.f_left;
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
			f_root=t_child;
		}
		t_child.f_right=t_node;
		t_node.f_parent=t_child;
		return 0;
	}
	public int m_InsertFixup6(bb_map_Node6 t_node){
		while(((t_node.f_parent)!=null) && t_node.f_parent.f_color==-1 && ((t_node.f_parent.f_parent)!=null)){
			if(t_node.f_parent==t_node.f_parent.f_parent.f_left){
				bb_map_Node6 t_uncle=t_node.f_parent.f_parent.f_right;
				if(((t_uncle)!=null) && t_uncle.f_color==-1){
					t_node.f_parent.f_color=1;
					t_uncle.f_color=1;
					t_uncle.f_parent.f_color=-1;
					t_node=t_uncle.f_parent;
				}else{
					if(t_node==t_node.f_parent.f_right){
						t_node=t_node.f_parent;
						m_RotateLeft6(t_node);
					}
					t_node.f_parent.f_color=1;
					t_node.f_parent.f_parent.f_color=-1;
					m_RotateRight6(t_node.f_parent.f_parent);
				}
			}else{
				bb_map_Node6 t_uncle2=t_node.f_parent.f_parent.f_left;
				if(((t_uncle2)!=null) && t_uncle2.f_color==-1){
					t_node.f_parent.f_color=1;
					t_uncle2.f_color=1;
					t_uncle2.f_parent.f_color=-1;
					t_node=t_uncle2.f_parent;
				}else{
					if(t_node==t_node.f_parent.f_left){
						t_node=t_node.f_parent;
						m_RotateRight6(t_node);
					}
					t_node.f_parent.f_color=1;
					t_node.f_parent.f_parent.f_color=-1;
					m_RotateLeft6(t_node.f_parent.f_parent);
				}
			}
		}
		f_root.f_color=1;
		return 0;
	}
	public boolean m_Set8(int t_key,Object t_value){
		bb_map_Node6 t_node=f_root;
		bb_map_Node6 t_parent=null;
		int t_cmp=0;
		while((t_node)!=null){
			t_parent=t_node;
			t_cmp=m_Compare2(t_key,t_node.f_key);
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
		t_node=(new bb_map_Node6()).g_new(t_key,t_value,-1,t_parent);
		if((t_parent)!=null){
			if(t_cmp>0){
				t_parent.f_right=t_node;
			}else{
				t_parent.f_left=t_node;
			}
			m_InsertFixup6(t_node);
		}else{
			f_root=t_node;
		}
		return true;
	}
	public boolean m_Insert5(int t_key,Object t_value){
		return m_Set8(t_key,t_value);
	}
	public int m_Count(){
		if((f_root)!=null){
			return f_root.m_Count2(0);
		}
		return 0;
	}
	public int m_Clear(){
		f_root=null;
		return 0;
	}
	public bb_map_Node6 m_FindNode2(int t_key){
		bb_map_Node6 t_node=f_root;
		while((t_node)!=null){
			int t_cmp=m_Compare2(t_key,t_node.f_key);
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
	public int m_DeleteFixup(bb_map_Node6 t_node,bb_map_Node6 t_parent){
		while(t_node!=f_root && (!((t_node)!=null) || t_node.f_color==1)){
			if(t_node==t_parent.f_left){
				bb_map_Node6 t_sib=t_parent.f_right;
				if(t_sib.f_color==-1){
					t_sib.f_color=1;
					t_parent.f_color=-1;
					m_RotateLeft6(t_parent);
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
						m_RotateRight6(t_sib);
						t_sib=t_parent.f_right;
					}
					t_sib.f_color=t_parent.f_color;
					t_parent.f_color=1;
					t_sib.f_right.f_color=1;
					m_RotateLeft6(t_parent);
					t_node=f_root;
				}
			}else{
				bb_map_Node6 t_sib2=t_parent.f_left;
				if(t_sib2.f_color==-1){
					t_sib2.f_color=1;
					t_parent.f_color=-1;
					m_RotateRight6(t_parent);
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
						m_RotateLeft6(t_sib2);
						t_sib2=t_parent.f_left;
					}
					t_sib2.f_color=t_parent.f_color;
					t_parent.f_color=1;
					t_sib2.f_left.f_color=1;
					m_RotateRight6(t_parent);
					t_node=f_root;
				}
			}
		}
		if((t_node)!=null){
			t_node.f_color=1;
		}
		return 0;
	}
	public int m_RemoveNode(bb_map_Node6 t_node){
		bb_map_Node6 t_splice=null;
		bb_map_Node6 t_child=null;
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
		bb_map_Node6 t_parent=t_splice.f_parent;
		if((t_child)!=null){
			t_child.f_parent=t_parent;
		}
		if(!((t_parent)!=null)){
			f_root=t_child;
			return 0;
		}
		if(t_splice==t_parent.f_left){
			t_parent.f_left=t_child;
		}else{
			t_parent.f_right=t_child;
		}
		if(t_splice.f_color==1){
			m_DeleteFixup(t_child,t_parent);
		}
		return 0;
	}
	public int m_Remove4(int t_key){
		bb_map_Node6 t_node=m_FindNode2(t_key);
		if(!((t_node)!=null)){
			return 0;
		}
		m_RemoveNode(t_node);
		return 1;
	}
	public boolean m_Contains2(int t_key){
		return m_FindNode2(t_key)!=null;
	}
}
class bb_map_IntMap extends bb_map_Map6{
	public bb_map_IntMap g_new(){
		super.g_new();
		return this;
	}
	public int m_Compare2(int t_lhs,int t_rhs){
		return t_lhs-t_rhs;
	}
}
class bb_map_Node6 extends Object{
	int f_key=0;
	bb_map_Node6 f_right=null;
	bb_map_Node6 f_left=null;
	Object f_value=null;
	int f_color=0;
	bb_map_Node6 f_parent=null;
	public bb_map_Node6 g_new(int t_key,Object t_value,int t_color,bb_map_Node6 t_parent){
		this.f_key=t_key;
		this.f_value=t_value;
		this.f_color=t_color;
		this.f_parent=t_parent;
		return this;
	}
	public bb_map_Node6 g_new2(){
		return this;
	}
	public int m_Count2(int t_n){
		if((f_left)!=null){
			t_n=f_left.m_Count2(t_n);
		}
		if((f_right)!=null){
			t_n=f_right.m_Count2(t_n);
		}
		return t_n+1;
	}
}
class bb_list_Enumerator5 extends Object{
	bb_list_List5 f__list=null;
	bb_list_Node5 f__curr=null;
	public bb_list_Enumerator5 g_new(bb_list_List5 t_list){
		f__list=t_list;
		f__curr=t_list.f__head.f__succ;
		return this;
	}
	public bb_list_Enumerator5 g_new2(){
		return this;
	}
	public boolean m_HasNext(){
		while(f__curr.f__succ.f__pred!=f__curr){
			f__curr=f__curr.f__succ;
		}
		return f__curr!=f__list.f__head;
	}
	public int m_NextObject(){
		int t_data=f__curr.f__data;
		f__curr=f__curr.f__succ;
		return t_data;
	}
}
class bb_textinput_TextInput extends bb_font_Font{
	public bb_textinput_TextInput g_new(String t_fontName,bb_vector2d_Vector2D t_pos){
		super.g_new(t_fontName,t_pos);
		return this;
	}
	public bb_textinput_TextInput g_new2(){
		super.g_new2();
		return this;
	}
	int f_cursorPos=0;
	public void m_MoveCursorRight(){
		if(f_cursorPos>=m_text2().length()){
			return;
		}
		f_cursorPos+=1;
	}
	public void m_InsertChar(String t_char){
		m_text(bb_std_lang.slice(m_text2(),0,f_cursorPos)+t_char+bb_std_lang.slice(m_text2(),f_cursorPos,m_text2().length()));
		m_MoveCursorRight();
	}
	public void m_MoveCursorLeft(){
		if(f_cursorPos<=0){
			return;
		}
		f_cursorPos-=1;
	}
	public void m_RemoveChar(){
		if(m_text2().length()==0 || f_cursorPos==0){
			return;
		}
		m_text(bb_std_lang.slice(m_text2(),0,f_cursorPos-1)+bb_std_lang.slice(m_text2(),f_cursorPos,m_text2().length()));
		m_MoveCursorLeft();
	}
	public void m_OnKeyUp(bb_keyevent_KeyEvent t_event){
		if(t_event.m_code()>31 && t_event.m_code()<127){
			m_InsertChar(t_event.m_char());
		}else{
			int t_1=t_event.m_code();
			if(t_1==8){
				m_RemoveChar();
			}else{
				if(t_1==65573){
					m_MoveCursorLeft();
				}else{
					if(t_1==65575){
						m_MoveCursorRight();
					}
				}
			}
		}
	}
}
class bb_deltatimer_DeltaTimer extends Object{
	float f_targetFps=.0f;
	float f_lastTicks=.0f;
	public bb_deltatimer_DeltaTimer g_new(float t_fps){
		f_targetFps=t_fps;
		f_lastTicks=(float)(bb_app.bb_app_Millisecs());
		return this;
	}
	public bb_deltatimer_DeltaTimer g_new2(){
		return this;
	}
	float f_currentTicks=.0f;
	float f__frameTime=.0f;
	public float m_frameTime(){
		return f__frameTime;
	}
	float f__delta=.0f;
	public void m_OnUpdate2(){
		f_currentTicks=(float)(bb_app.bb_app_Millisecs());
		f__frameTime=f_currentTicks-f_lastTicks;
		f__delta=m_frameTime()/(1000.0f/f_targetFps);
		f_lastTicks=f_currentTicks;
	}
	public float m_delta(){
		return f__delta;
	}
}
class bb_touchevent_TouchEvent extends Object{
	int f__finger=0;
	int f__startTime=0;
	public bb_touchevent_TouchEvent g_new(int t_finger){
		f__finger=t_finger;
		f__startTime=bb_app.bb_app_Millisecs();
		return this;
	}
	public bb_touchevent_TouchEvent g_new2(){
		return this;
	}
	bb_list_List6 f_positions=(new bb_list_List6()).g_new();
	public bb_vector2d_Vector2D m_startPos(){
		if(f_positions.m_Count()==0){
			return (new bb_vector2d_Vector2D()).g_new(0.0f,0.0f);
		}
		return f_positions.m_First();
	}
	public bb_vector2d_Vector2D m_prevPos(){
		if(f_positions.m_Count()==0){
			return (new bb_vector2d_Vector2D()).g_new(0.0f,0.0f);
		}
		if(f_positions.m_Count()==1){
			return m_startPos();
		}
		return f_positions.m_LastNode().m_PrevNode().m_Value();
	}
	int f__endTime=0;
	public void m_Add2(bb_vector2d_Vector2D t_pos){
		f__endTime=bb_app.bb_app_Millisecs();
		if(m_prevPos().f_x==t_pos.f_x && m_prevPos().f_y==t_pos.f_y){
			return;
		}
		f_positions.m_AddLast6(t_pos);
	}
	public void m_Trim(int t_size){
		if(t_size==0){
			f_positions.m_Clear();
			return;
		}
		while(f_positions.m_Count()>t_size){
			f_positions.m_RemoveFirst();
		}
	}
	public bb_vector2d_Vector2D m_pos(){
		if(f_positions.m_Count()==0){
			return (new bb_vector2d_Vector2D()).g_new(0.0f,0.0f);
		}
		return f_positions.m_Last();
	}
	public bb_touchevent_TouchEvent m_Copy(){
		bb_touchevent_TouchEvent t_obj=(new bb_touchevent_TouchEvent()).g_new(f__finger);
		t_obj.m_Add2(m_pos());
		return t_obj;
	}
	public bb_vector2d_Vector2D m_startDelta(){
		return m_pos().m_Copy().m_Sub(m_startPos());
	}
}
class bb_list_List6 extends Object{
	public bb_list_List6 g_new(){
		return this;
	}
	bb_list_Node6 f__head=((new bb_list_HeadNode6()).g_new());
	public bb_list_Node6 m_AddLast6(bb_vector2d_Vector2D t_data){
		return (new bb_list_Node6()).g_new(f__head,f__head.f__pred,t_data);
	}
	public bb_list_List6 g_new2(bb_vector2d_Vector2D[] t_data){
		bb_vector2d_Vector2D[] t_=t_data;
		int t_2=0;
		while(t_2<bb_std_lang.arrayLength(t_)){
			bb_vector2d_Vector2D t_t=t_[t_2];
			t_2=t_2+1;
			m_AddLast6(t_t);
		}
		return this;
	}
	public int m_Count(){
		int t_n=0;
		bb_list_Node6 t_node=f__head.f__succ;
		while(t_node!=f__head){
			t_node=t_node.f__succ;
			t_n+=1;
		}
		return t_n;
	}
	public bb_vector2d_Vector2D m_First(){
		return f__head.m_NextNode().f__data;
	}
	public bb_list_Node6 m_LastNode(){
		return f__head.m_PrevNode();
	}
	public int m_Clear(){
		f__head.f__succ=f__head;
		f__head.f__pred=f__head;
		return 0;
	}
	public bb_vector2d_Vector2D m_RemoveFirst(){
		bb_vector2d_Vector2D t_data=f__head.m_NextNode().f__data;
		f__head.f__succ.m_Remove2();
		return t_data;
	}
	public bb_vector2d_Vector2D m_Last(){
		return f__head.m_PrevNode().f__data;
	}
}
class bb_list_Node6 extends Object{
	bb_list_Node6 f__succ=null;
	bb_list_Node6 f__pred=null;
	bb_vector2d_Vector2D f__data=null;
	public bb_list_Node6 g_new(bb_list_Node6 t_succ,bb_list_Node6 t_pred,bb_vector2d_Vector2D t_data){
		f__succ=t_succ;
		f__pred=t_pred;
		f__succ.f__pred=this;
		f__pred.f__succ=this;
		f__data=t_data;
		return this;
	}
	public bb_list_Node6 g_new2(){
		return this;
	}
	public bb_list_Node6 m_GetNode(){
		return this;
	}
	public bb_list_Node6 m_NextNode(){
		return f__succ.m_GetNode();
	}
	public bb_list_Node6 m_PrevNode(){
		return f__pred.m_GetNode();
	}
	public bb_vector2d_Vector2D m_Value(){
		return f__data;
	}
	public int m_Remove2(){
		f__succ.f__pred=f__pred;
		f__pred.f__succ=f__succ;
		return 0;
	}
}
class bb_list_HeadNode6 extends bb_list_Node6{
	public bb_list_HeadNode6 g_new(){
		super.g_new2();
		f__succ=(this);
		f__pred=(this);
		return this;
	}
	public bb_list_Node6 m_GetNode(){
		return null;
	}
}
class bb_keyevent_KeyEvent extends Object{
	int f__code=0;
	String f__char="";
	public bb_keyevent_KeyEvent g_new(int t_code){
		f__code=t_code;
		f__char=String.valueOf((char)(f__code));
		return this;
	}
	public bb_keyevent_KeyEvent g_new2(){
		return this;
	}
	public int m_code(){
		return f__code;
	}
	public String m_char(){
		return f__char;
	}
}
abstract class bb_map_Map7 extends Object{
	public bb_map_Map7 g_new(){
		return this;
	}
	bb_map_Node7 f_root=null;
	abstract public int m_Compare2(int t_lhs,int t_rhs);
	public bb_map_Node7 m_FindNode2(int t_key){
		bb_map_Node7 t_node=f_root;
		while((t_node)!=null){
			int t_cmp=m_Compare2(t_key,t_node.f_key);
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
	public boolean m_Contains2(int t_key){
		return m_FindNode2(t_key)!=null;
	}
	public int m_RotateLeft7(bb_map_Node7 t_node){
		bb_map_Node7 t_child=t_node.f_right;
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
			f_root=t_child;
		}
		t_child.f_left=t_node;
		t_node.f_parent=t_child;
		return 0;
	}
	public int m_RotateRight7(bb_map_Node7 t_node){
		bb_map_Node7 t_child=t_node.f_left;
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
			f_root=t_child;
		}
		t_child.f_right=t_node;
		t_node.f_parent=t_child;
		return 0;
	}
	public int m_InsertFixup7(bb_map_Node7 t_node){
		while(((t_node.f_parent)!=null) && t_node.f_parent.f_color==-1 && ((t_node.f_parent.f_parent)!=null)){
			if(t_node.f_parent==t_node.f_parent.f_parent.f_left){
				bb_map_Node7 t_uncle=t_node.f_parent.f_parent.f_right;
				if(((t_uncle)!=null) && t_uncle.f_color==-1){
					t_node.f_parent.f_color=1;
					t_uncle.f_color=1;
					t_uncle.f_parent.f_color=-1;
					t_node=t_uncle.f_parent;
				}else{
					if(t_node==t_node.f_parent.f_right){
						t_node=t_node.f_parent;
						m_RotateLeft7(t_node);
					}
					t_node.f_parent.f_color=1;
					t_node.f_parent.f_parent.f_color=-1;
					m_RotateRight7(t_node.f_parent.f_parent);
				}
			}else{
				bb_map_Node7 t_uncle2=t_node.f_parent.f_parent.f_left;
				if(((t_uncle2)!=null) && t_uncle2.f_color==-1){
					t_node.f_parent.f_color=1;
					t_uncle2.f_color=1;
					t_uncle2.f_parent.f_color=-1;
					t_node=t_uncle2.f_parent;
				}else{
					if(t_node==t_node.f_parent.f_left){
						t_node=t_node.f_parent;
						m_RotateRight7(t_node);
					}
					t_node.f_parent.f_color=1;
					t_node.f_parent.f_parent.f_color=-1;
					m_RotateLeft7(t_node.f_parent.f_parent);
				}
			}
		}
		f_root.f_color=1;
		return 0;
	}
	public boolean m_Add6(int t_key,bb_keyevent_KeyEvent t_value){
		bb_map_Node7 t_node=f_root;
		bb_map_Node7 t_parent=null;
		int t_cmp=0;
		while((t_node)!=null){
			t_parent=t_node;
			t_cmp=m_Compare2(t_key,t_node.f_key);
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
		t_node=(new bb_map_Node7()).g_new(t_key,t_value,-1,t_parent);
		if((t_parent)!=null){
			if(t_cmp>0){
				t_parent.f_right=t_node;
			}else{
				t_parent.f_left=t_node;
			}
			m_InsertFixup7(t_node);
		}else{
			f_root=t_node;
		}
		return true;
	}
	public bb_map_MapValues m_Values(){
		return (new bb_map_MapValues()).g_new(this);
	}
	public bb_map_Node7 m_FirstNode(){
		if(!((f_root)!=null)){
			return null;
		}
		bb_map_Node7 t_node=f_root;
		while((t_node.f_left)!=null){
			t_node=t_node.f_left;
		}
		return t_node;
	}
	public int m_DeleteFixup2(bb_map_Node7 t_node,bb_map_Node7 t_parent){
		while(t_node!=f_root && (!((t_node)!=null) || t_node.f_color==1)){
			if(t_node==t_parent.f_left){
				bb_map_Node7 t_sib=t_parent.f_right;
				if(t_sib.f_color==-1){
					t_sib.f_color=1;
					t_parent.f_color=-1;
					m_RotateLeft7(t_parent);
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
						m_RotateRight7(t_sib);
						t_sib=t_parent.f_right;
					}
					t_sib.f_color=t_parent.f_color;
					t_parent.f_color=1;
					t_sib.f_right.f_color=1;
					m_RotateLeft7(t_parent);
					t_node=f_root;
				}
			}else{
				bb_map_Node7 t_sib2=t_parent.f_left;
				if(t_sib2.f_color==-1){
					t_sib2.f_color=1;
					t_parent.f_color=-1;
					m_RotateRight7(t_parent);
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
						m_RotateLeft7(t_sib2);
						t_sib2=t_parent.f_left;
					}
					t_sib2.f_color=t_parent.f_color;
					t_parent.f_color=1;
					t_sib2.f_left.f_color=1;
					m_RotateRight7(t_parent);
					t_node=f_root;
				}
			}
		}
		if((t_node)!=null){
			t_node.f_color=1;
		}
		return 0;
	}
	public int m_RemoveNode2(bb_map_Node7 t_node){
		bb_map_Node7 t_splice=null;
		bb_map_Node7 t_child=null;
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
		bb_map_Node7 t_parent=t_splice.f_parent;
		if((t_child)!=null){
			t_child.f_parent=t_parent;
		}
		if(!((t_parent)!=null)){
			f_root=t_child;
			return 0;
		}
		if(t_splice==t_parent.f_left){
			t_parent.f_left=t_child;
		}else{
			t_parent.f_right=t_child;
		}
		if(t_splice.f_color==1){
			m_DeleteFixup2(t_child,t_parent);
		}
		return 0;
	}
	public int m_Remove4(int t_key){
		bb_map_Node7 t_node=m_FindNode2(t_key);
		if(!((t_node)!=null)){
			return 0;
		}
		m_RemoveNode2(t_node);
		return 1;
	}
	public int m_Clear(){
		f_root=null;
		return 0;
	}
}
class bb_map_IntMap2 extends bb_map_Map7{
	public bb_map_IntMap2 g_new(){
		super.g_new();
		return this;
	}
	public int m_Compare2(int t_lhs,int t_rhs){
		return t_lhs-t_rhs;
	}
}
class bb_map_Node7 extends Object{
	int f_key=0;
	bb_map_Node7 f_right=null;
	bb_map_Node7 f_left=null;
	bb_keyevent_KeyEvent f_value=null;
	int f_color=0;
	bb_map_Node7 f_parent=null;
	public bb_map_Node7 g_new(int t_key,bb_keyevent_KeyEvent t_value,int t_color,bb_map_Node7 t_parent){
		this.f_key=t_key;
		this.f_value=t_value;
		this.f_color=t_color;
		this.f_parent=t_parent;
		return this;
	}
	public bb_map_Node7 g_new2(){
		return this;
	}
	public bb_map_Node7 m_NextNode(){
		bb_map_Node7 t_node=null;
		if((f_right)!=null){
			t_node=f_right;
			while((t_node.f_left)!=null){
				t_node=t_node.f_left;
			}
			return t_node;
		}
		t_node=this;
		bb_map_Node7 t_parent=this.f_parent;
		while(((t_parent)!=null) && t_node==t_parent.f_right){
			t_node=t_parent;
			t_parent=t_parent.f_parent;
		}
		return t_parent;
	}
}
class bb_map_MapValues extends Object{
	bb_map_Map7 f_map=null;
	public bb_map_MapValues g_new(bb_map_Map7 t_map){
		this.f_map=t_map;
		return this;
	}
	public bb_map_MapValues g_new2(){
		return this;
	}
	public bb_map_ValueEnumerator m_ObjectEnumerator(){
		return (new bb_map_ValueEnumerator()).g_new(f_map.m_FirstNode());
	}
}
class bb_map_ValueEnumerator extends Object{
	bb_map_Node7 f_node=null;
	public bb_map_ValueEnumerator g_new(bb_map_Node7 t_node){
		this.f_node=t_node;
		return this;
	}
	public bb_map_ValueEnumerator g_new2(){
		return this;
	}
	public boolean m_HasNext(){
		return f_node!=null;
	}
	public bb_keyevent_KeyEvent m_NextObject(){
		bb_map_Node7 t_t=f_node;
		f_node=f_node.m_NextNode();
		return t_t.f_value;
	}
}
class bb_shape_Shape extends bb_baseobject_BaseObject{
	static bb_graphics_Image[] g_images;
	int f_type=0;
	int f_lane=0;
	bb_chute_Chute f_chute=null;
	static bb_vector2d_Vector2D g_SPEED_SLOW;
	static bb_vector2d_Vector2D g_SPEED_FAST;
	public bb_shape_Shape g_new(int t_type,int t_lane,bb_chute_Chute t_chute){
		super.g_new();
		this.f_type=t_type;
		this.f_lane=t_lane;
		this.f_chute=t_chute;
		if(bb_std_lang.arrayLength(g_images)==0){
			g_images=new bb_graphics_Image[]{bb_graphics.bb_graphics_LoadImage("circle_inside.png",1,bb_graphics_Image.g_DefaultFlags),bb_graphics.bb_graphics_LoadImage("plus_inside.png",1,bb_graphics_Image.g_DefaultFlags),bb_graphics.bb_graphics_LoadImage("star_inside.png",1,bb_graphics_Image.g_DefaultFlags),bb_graphics.bb_graphics_LoadImage("tire_inside.png",1,bb_graphics_Image.g_DefaultFlags)};
		}
		float t_posX=(float)(44+g_images[0].m_Width()*t_lane);
		float t_posY=(float)(t_chute.m_Height()-g_images[t_type].m_Height()+37);
		m_pos2((new bb_vector2d_Vector2D()).g_new(t_posX,t_posY));
		if(!((g_SPEED_SLOW)!=null)){
			g_SPEED_SLOW=(new bb_vector2d_Vector2D()).g_new(0.0f,3.0f);
		}
		if(!((g_SPEED_FAST)!=null)){
			g_SPEED_FAST=(new bb_vector2d_Vector2D()).g_new(0.0f,10.0f);
		}
		return this;
	}
	public bb_shape_Shape g_new2(){
		super.g_new();
		return this;
	}
	boolean f_isFast=false;
	boolean f_isReadyForFast=false;
	float f_readyTime=.0f;
	public void m_OnUpdate(float t_delta,float t_frameTime){
		if(!f_isReadyForFast){
			f_readyTime+=t_frameTime;
			f_isFast=false;
			if(f_readyTime>=250.0f){
				f_isReadyForFast=true;
			}
		}
		if(f_isFast && f_isReadyForFast){
			m_pos().m_Add2(g_SPEED_FAST.m_Copy().m_Mul2(t_delta));
		}else{
			m_pos().m_Add2(g_SPEED_SLOW.m_Copy().m_Mul2(t_delta));
		}
	}
	public void m_OnRender(){
		bb_graphics.bb_graphics_DrawImage(g_images[f_type],m_pos().f_x,m_pos().f_y,0);
	}
}
class bb_stack_Stack2 extends Object{
	public bb_stack_Stack2 g_new(){
		return this;
	}
	bb_sprite_Sprite[] f_data=new bb_sprite_Sprite[0];
	int f_length=0;
	public bb_stack_Stack2 g_new2(bb_sprite_Sprite[] t_data){
		this.f_data=((bb_sprite_Sprite[])bb_std_lang.sliceArray(t_data,0));
		this.f_length=bb_std_lang.arrayLength(t_data);
		return this;
	}
	public int m_Length(){
		return f_length;
	}
	public bb_sprite_Sprite m_Pop(){
		f_length-=1;
		return f_data[f_length];
	}
	public int m_Push2(bb_sprite_Sprite t_value){
		if(f_length==bb_std_lang.arrayLength(f_data)){
			f_data=(bb_sprite_Sprite[])bb_std_lang.resizeArray(f_data,f_length*2+10);
		}
		f_data[f_length]=t_value;
		f_length+=1;
		return 0;
	}
}
class bb_app{
	static bb_app_AppDevice bb_app_device;
	static public String bb_app_LoadString(String t_path){
		return bb_app.bb_app_device.LoadString(t_path);
	}
	static public String bb_app_LoadState(){
		return bb_app.bb_app_device.LoadState();
	}
	static public int bb_app_Millisecs(){
		return bb_app.bb_app_device.MilliSecs();
	}
	static public int bb_app_SetUpdateRate(int t_hertz){
		return bb_app.bb_app_device.SetUpdateRate(t_hertz);
	}
	static public int bb_app_SaveState(String t_state){
		return bb_app.bb_app_device.SaveState(t_state);
	}
}
class bb_audio{
	static gxtkAudio bb_audio_device;
	static public int bb_audio_SetAudioDevice(gxtkAudio t_dev){
		bb_audio.bb_audio_device=t_dev;
		return 0;
	}
}
class bb_graphics{
	static bb_graphics_GraphicsContext bb_graphics_context;
	static public int bb_graphics_SetGraphicsContext(bb_graphics_GraphicsContext t_gc){
		bb_graphics.bb_graphics_context=t_gc;
		return 0;
	}
	static public bb_graphics_Image bb_graphics_LoadImage(String t_path,int t_frameCount,int t_flags){
		return ((new bb_graphics_Image()).g_new()).m_Load(t_path,t_frameCount,t_flags);
	}
	static public bb_graphics_Image bb_graphics_LoadImage2(String t_path,int t_frameWidth,int t_frameHeight,int t_frameCount,int t_flags){
		bb_graphics_Image t_atlas=((new bb_graphics_Image()).g_new()).m_Load(t_path,1,0);
		if((t_atlas)!=null){
			return t_atlas.m_GrabImage(0,0,t_frameWidth,t_frameHeight,t_frameCount,t_flags);
		}
		return null;
	}
	static public int bb_graphics_SetFont(bb_graphics_Image t_font,int t_firstChar){
		if(!((t_font)!=null)){
			if(!((bb_graphics.bb_graphics_context.f_defaultFont)!=null)){
				bb_graphics.bb_graphics_context.f_defaultFont=bb_graphics.bb_graphics_LoadImage("mojo_font.png",96,2);
			}
			t_font=bb_graphics.bb_graphics_context.f_defaultFont;
			t_firstChar=32;
		}
		bb_graphics.bb_graphics_context.f_font=t_font;
		bb_graphics.bb_graphics_context.f_firstChar=t_firstChar;
		return 0;
	}
	static gxtkGraphics bb_graphics_renderDevice;
	static public int bb_graphics_SetMatrix(float t_ix,float t_iy,float t_jx,float t_jy,float t_tx,float t_ty){
		bb_graphics.bb_graphics_context.f_ix=t_ix;
		bb_graphics.bb_graphics_context.f_iy=t_iy;
		bb_graphics.bb_graphics_context.f_jx=t_jx;
		bb_graphics.bb_graphics_context.f_jy=t_jy;
		bb_graphics.bb_graphics_context.f_tx=t_tx;
		bb_graphics.bb_graphics_context.f_ty=t_ty;
		bb_graphics.bb_graphics_context.f_tformed=((t_ix!=1.0f || t_iy!=0.0f || t_jx!=0.0f || t_jy!=1.0f || t_tx!=0.0f || t_ty!=0.0f)?1:0);
		bb_graphics.bb_graphics_context.f_matDirty=1;
		return 0;
	}
	static public int bb_graphics_SetMatrix2(float[] t_m){
		bb_graphics.bb_graphics_SetMatrix(t_m[0],t_m[1],t_m[2],t_m[3],t_m[4],t_m[5]);
		return 0;
	}
	static public int bb_graphics_SetColor(float t_r,float t_g,float t_b){
		bb_graphics.bb_graphics_context.f_color_r=t_r;
		bb_graphics.bb_graphics_context.f_color_g=t_g;
		bb_graphics.bb_graphics_context.f_color_b=t_b;
		bb_graphics.bb_graphics_context.f_device.SetColor(t_r,t_g,t_b);
		return 0;
	}
	static public int bb_graphics_SetAlpha(float t_alpha){
		bb_graphics.bb_graphics_context.f_alpha=t_alpha;
		bb_graphics.bb_graphics_context.f_device.SetAlpha(t_alpha);
		return 0;
	}
	static public int bb_graphics_SetBlend(int t_blend){
		bb_graphics.bb_graphics_context.f_blend=t_blend;
		bb_graphics.bb_graphics_context.f_device.SetBlend(t_blend);
		return 0;
	}
	static public int bb_graphics_DeviceWidth(){
		return bb_graphics.bb_graphics_context.f_device.Width();
	}
	static public int bb_graphics_DeviceHeight(){
		return bb_graphics.bb_graphics_context.f_device.Height();
	}
	static public int bb_graphics_SetScissor(float t_x,float t_y,float t_width,float t_height){
		bb_graphics.bb_graphics_context.f_scissor_x=t_x;
		bb_graphics.bb_graphics_context.f_scissor_y=t_y;
		bb_graphics.bb_graphics_context.f_scissor_width=t_width;
		bb_graphics.bb_graphics_context.f_scissor_height=t_height;
		bb_graphics.bb_graphics_context.f_device.SetScissor((int)(t_x),(int)(t_y),(int)(t_width),(int)(t_height));
		return 0;
	}
	static public int bb_graphics_BeginRender(){
		if(!((bb_graphics.bb_graphics_context.f_device.Mode())!=0)){
			return 0;
		}
		bb_graphics.bb_graphics_renderDevice=bb_graphics.bb_graphics_context.f_device;
		bb_graphics.bb_graphics_context.f_matrixSp=0;
		bb_graphics.bb_graphics_SetMatrix(1.0f,0.0f,0.0f,1.0f,0.0f,0.0f);
		bb_graphics.bb_graphics_SetColor(255.0f,255.0f,255.0f);
		bb_graphics.bb_graphics_SetAlpha(1.0f);
		bb_graphics.bb_graphics_SetBlend(0);
		bb_graphics.bb_graphics_SetScissor(0.0f,0.0f,(float)(bb_graphics.bb_graphics_DeviceWidth()),(float)(bb_graphics.bb_graphics_DeviceHeight()));
		return 0;
	}
	static public int bb_graphics_EndRender(){
		bb_graphics.bb_graphics_renderDevice=null;
		return 0;
	}
	static public int bb_graphics_PushMatrix(){
		int t_sp=bb_graphics.bb_graphics_context.f_matrixSp;
		bb_graphics.bb_graphics_context.f_matrixStack[t_sp+0]=bb_graphics.bb_graphics_context.f_ix;
		bb_graphics.bb_graphics_context.f_matrixStack[t_sp+1]=bb_graphics.bb_graphics_context.f_iy;
		bb_graphics.bb_graphics_context.f_matrixStack[t_sp+2]=bb_graphics.bb_graphics_context.f_jx;
		bb_graphics.bb_graphics_context.f_matrixStack[t_sp+3]=bb_graphics.bb_graphics_context.f_jy;
		bb_graphics.bb_graphics_context.f_matrixStack[t_sp+4]=bb_graphics.bb_graphics_context.f_tx;
		bb_graphics.bb_graphics_context.f_matrixStack[t_sp+5]=bb_graphics.bb_graphics_context.f_ty;
		bb_graphics.bb_graphics_context.f_matrixSp=t_sp+6;
		return 0;
	}
	static public int bb_graphics_Transform(float t_ix,float t_iy,float t_jx,float t_jy,float t_tx,float t_ty){
		float t_ix2=t_ix*bb_graphics.bb_graphics_context.f_ix+t_iy*bb_graphics.bb_graphics_context.f_jx;
		float t_iy2=t_ix*bb_graphics.bb_graphics_context.f_iy+t_iy*bb_graphics.bb_graphics_context.f_jy;
		float t_jx2=t_jx*bb_graphics.bb_graphics_context.f_ix+t_jy*bb_graphics.bb_graphics_context.f_jx;
		float t_jy2=t_jx*bb_graphics.bb_graphics_context.f_iy+t_jy*bb_graphics.bb_graphics_context.f_jy;
		float t_tx2=t_tx*bb_graphics.bb_graphics_context.f_ix+t_ty*bb_graphics.bb_graphics_context.f_jx+bb_graphics.bb_graphics_context.f_tx;
		float t_ty2=t_tx*bb_graphics.bb_graphics_context.f_iy+t_ty*bb_graphics.bb_graphics_context.f_jy+bb_graphics.bb_graphics_context.f_ty;
		bb_graphics.bb_graphics_SetMatrix(t_ix2,t_iy2,t_jx2,t_jy2,t_tx2,t_ty2);
		return 0;
	}
	static public int bb_graphics_Transform2(float[] t_m){
		bb_graphics.bb_graphics_Transform(t_m[0],t_m[1],t_m[2],t_m[3],t_m[4],t_m[5]);
		return 0;
	}
	static public int bb_graphics_Scale(float t_x,float t_y){
		bb_graphics.bb_graphics_Transform(t_x,0.0f,0.0f,t_y,0.0f,0.0f);
		return 0;
	}
	static public int bb_graphics_Cls(float t_r,float t_g,float t_b){
		bb_graphics.bb_graphics_renderDevice.Cls(t_r,t_g,t_b);
		return 0;
	}
	static public int bb_graphics_PopMatrix(){
		int t_sp=bb_graphics.bb_graphics_context.f_matrixSp-6;
		bb_graphics.bb_graphics_SetMatrix(bb_graphics.bb_graphics_context.f_matrixStack[t_sp+0],bb_graphics.bb_graphics_context.f_matrixStack[t_sp+1],bb_graphics.bb_graphics_context.f_matrixStack[t_sp+2],bb_graphics.bb_graphics_context.f_matrixStack[t_sp+3],bb_graphics.bb_graphics_context.f_matrixStack[t_sp+4],bb_graphics.bb_graphics_context.f_matrixStack[t_sp+5]);
		bb_graphics.bb_graphics_context.f_matrixSp=t_sp;
		return 0;
	}
	static public int bb_graphics_Translate(float t_x,float t_y){
		bb_graphics.bb_graphics_Transform(1.0f,0.0f,0.0f,1.0f,t_x,t_y);
		return 0;
	}
	static public int bb_graphics_ValidateMatrix(){
		if((bb_graphics.bb_graphics_context.f_matDirty)!=0){
			bb_graphics.bb_graphics_context.f_device.SetMatrix(bb_graphics.bb_graphics_context.f_ix,bb_graphics.bb_graphics_context.f_iy,bb_graphics.bb_graphics_context.f_jx,bb_graphics.bb_graphics_context.f_jy,bb_graphics.bb_graphics_context.f_tx,bb_graphics.bb_graphics_context.f_ty);
			bb_graphics.bb_graphics_context.f_matDirty=0;
		}
		return 0;
	}
	static public int bb_graphics_DrawImage(bb_graphics_Image t_image,float t_x,float t_y,int t_frame){
		bb_graphics_Frame t_f=t_image.f_frames[t_frame];
		if((bb_graphics.bb_graphics_context.f_tformed)!=0){
			bb_graphics.bb_graphics_PushMatrix();
			bb_graphics.bb_graphics_Translate(t_x-t_image.f_tx,t_y-t_image.f_ty);
			bb_graphics.bb_graphics_ValidateMatrix();
			if((t_image.f_flags&65536)!=0){
				bb_graphics.bb_graphics_context.f_device.DrawSurface(t_image.f_surface,0.0f,0.0f);
			}else{
				bb_graphics.bb_graphics_context.f_device.DrawSurface2(t_image.f_surface,0.0f,0.0f,t_f.f_x,t_f.f_y,t_image.f_width,t_image.f_height);
			}
			bb_graphics.bb_graphics_PopMatrix();
		}else{
			bb_graphics.bb_graphics_ValidateMatrix();
			if((t_image.f_flags&65536)!=0){
				bb_graphics.bb_graphics_context.f_device.DrawSurface(t_image.f_surface,t_x-t_image.f_tx,t_y-t_image.f_ty);
			}else{
				bb_graphics.bb_graphics_context.f_device.DrawSurface2(t_image.f_surface,t_x-t_image.f_tx,t_y-t_image.f_ty,t_f.f_x,t_f.f_y,t_image.f_width,t_image.f_height);
			}
		}
		return 0;
	}
	static public int bb_graphics_Rotate(float t_angle){
		bb_graphics.bb_graphics_Transform((float)Math.cos((t_angle)*bb_std_lang.D2R),-(float)Math.sin((t_angle)*bb_std_lang.D2R),(float)Math.sin((t_angle)*bb_std_lang.D2R),(float)Math.cos((t_angle)*bb_std_lang.D2R),0.0f,0.0f);
		return 0;
	}
	static public int bb_graphics_DrawImage2(bb_graphics_Image t_image,float t_x,float t_y,float t_rotation,float t_scaleX,float t_scaleY,int t_frame){
		bb_graphics_Frame t_f=t_image.f_frames[t_frame];
		bb_graphics.bb_graphics_PushMatrix();
		bb_graphics.bb_graphics_Translate(t_x,t_y);
		bb_graphics.bb_graphics_Rotate(t_rotation);
		bb_graphics.bb_graphics_Scale(t_scaleX,t_scaleY);
		bb_graphics.bb_graphics_Translate(-t_image.f_tx,-t_image.f_ty);
		bb_graphics.bb_graphics_ValidateMatrix();
		if((t_image.f_flags&65536)!=0){
			bb_graphics.bb_graphics_context.f_device.DrawSurface(t_image.f_surface,0.0f,0.0f);
		}else{
			bb_graphics.bb_graphics_context.f_device.DrawSurface2(t_image.f_surface,0.0f,0.0f,t_f.f_x,t_f.f_y,t_image.f_width,t_image.f_height);
		}
		bb_graphics.bb_graphics_PopMatrix();
		return 0;
	}
	static public int bb_graphics_DrawRect(float t_x,float t_y,float t_w,float t_h){
		bb_graphics.bb_graphics_ValidateMatrix();
		bb_graphics.bb_graphics_renderDevice.DrawRect(t_x,t_y,t_w,t_h);
		return 0;
	}
	static public float[] bb_graphics_GetColor(){
		return new float[]{bb_graphics.bb_graphics_context.f_color_r,bb_graphics.bb_graphics_context.f_color_g,bb_graphics.bb_graphics_context.f_color_b};
	}
	static public float bb_graphics_GetAlpha(){
		return bb_graphics.bb_graphics_context.f_alpha;
	}
	static public int bb_graphics_DrawImageRect(bb_graphics_Image t_image,float t_x,float t_y,int t_srcX,int t_srcY,int t_srcWidth,int t_srcHeight,int t_frame){
		bb_graphics_Frame t_f=t_image.f_frames[t_frame];
		if((bb_graphics.bb_graphics_context.f_tformed)!=0){
			bb_graphics.bb_graphics_PushMatrix();
			bb_graphics.bb_graphics_Translate(-t_image.f_tx+t_x,-t_image.f_ty+t_y);
			bb_graphics.bb_graphics_ValidateMatrix();
			bb_graphics.bb_graphics_context.f_device.DrawSurface2(t_image.f_surface,0.0f,0.0f,t_srcX+t_f.f_x,t_srcY+t_f.f_y,t_srcWidth,t_srcHeight);
			bb_graphics.bb_graphics_PopMatrix();
		}else{
			bb_graphics.bb_graphics_ValidateMatrix();
			bb_graphics.bb_graphics_context.f_device.DrawSurface2(t_image.f_surface,-t_image.f_tx+t_x,-t_image.f_ty+t_y,t_srcX+t_f.f_x,t_srcY+t_f.f_y,t_srcWidth,t_srcHeight);
		}
		return 0;
	}
	static public int bb_graphics_DrawImageRect2(bb_graphics_Image t_image,float t_x,float t_y,int t_srcX,int t_srcY,int t_srcWidth,int t_srcHeight,float t_rotation,float t_scaleX,float t_scaleY,int t_frame){
		bb_graphics_Frame t_f=t_image.f_frames[t_frame];
		bb_graphics.bb_graphics_PushMatrix();
		bb_graphics.bb_graphics_Translate(t_x,t_y);
		bb_graphics.bb_graphics_Rotate(t_rotation);
		bb_graphics.bb_graphics_Scale(t_scaleX,t_scaleY);
		bb_graphics.bb_graphics_Translate(-t_image.f_tx,-t_image.f_ty);
		bb_graphics.bb_graphics_ValidateMatrix();
		bb_graphics.bb_graphics_context.f_device.DrawSurface2(t_image.f_surface,0.0f,0.0f,t_srcX+t_f.f_x,t_srcY+t_f.f_y,t_srcWidth,t_srcHeight);
		bb_graphics.bb_graphics_PopMatrix();
		return 0;
	}
}
class bb_input{
	static gxtkInput bb_input_device;
	static public int bb_input_SetInputDevice(gxtkInput t_dev){
		bb_input.bb_input_device=t_dev;
		return 0;
	}
	static public int bb_input_TouchDown(int t_index){
		return bb_input.bb_input_device.KeyDown(384+t_index);
	}
	static public float bb_input_TouchX(int t_index){
		return bb_input.bb_input_device.TouchX(t_index);
	}
	static public float bb_input_TouchY(int t_index){
		return bb_input.bb_input_device.TouchY(t_index);
	}
	static public int bb_input_EnableKeyboard(){
		return bb_input.bb_input_device.SetKeyboardEnabled(1);
	}
	static public int bb_input_GetChar(){
		return bb_input.bb_input_device.GetChar();
	}
	static public int bb_input_DisableKeyboard(){
		return bb_input.bb_input_device.SetKeyboardEnabled(0);
	}
}
class bb_mojo{
}
class bb_boxes{
}
class bb_lang{
}
class bb_list{
}
class bb_map{
}
class bb_math{
	static public int bb_math_Min(int t_x,int t_y){
		if(t_x<t_y){
			return t_x;
		}
		return t_y;
	}
	static public float bb_math_Min2(float t_x,float t_y){
		if(t_x<t_y){
			return t_x;
		}
		return t_y;
	}
	static public int bb_math_Max(int t_x,int t_y){
		if(t_x>t_y){
			return t_x;
		}
		return t_y;
	}
	static public float bb_math_Max2(float t_x,float t_y){
		if(t_x>t_y){
			return t_x;
		}
		return t_y;
	}
	static public int bb_math_Abs(int t_x){
		if(t_x>=0){
			return t_x;
		}
		return -t_x;
	}
	static public float bb_math_Abs2(float t_x){
		if(t_x>=0.0f){
			return t_x;
		}
		return -t_x;
	}
}
class bb_monkey{
}
class bb_random{
	static int bb_random_Seed;
	static public float bb_random_Rnd(){
		bb_random.bb_random_Seed=bb_random.bb_random_Seed*1664525+1013904223|0;
		return (float)(bb_random.bb_random_Seed>>8&16777215)/16777216.0f;
	}
	static public float bb_random_Rnd2(float t_low,float t_high){
		return bb_random.bb_random_Rnd3(t_high-t_low)+t_low;
	}
	static public float bb_random_Rnd3(float t_range){
		return bb_random.bb_random_Rnd()*t_range;
	}
}
class bb_set{
}
class bb_stack{
}
class bb_{
	static public int bbMain(){
		bb_router_Router t_router=(new bb_router_Router()).g_new();
		t_router.m_Add("intro",((new bb_introscene_IntroScene()).g_new()));
		t_router.m_Add("menu",((new bb_menuscene_MenuScene()).g_new()));
		t_router.m_Add("highscore",((new bb_highscorescene_HighscoreScene()).g_new()));
		t_router.m_Add("game",((new bb_gamescene_GameScene()).g_new()));
		t_router.m_Add("gameover",((new bb_gameoverscene_GameOverScene()).g_new()));
		t_router.m_Add("pause",((new bb_pausescene_PauseScene()).g_new()));
		t_router.m_Add("newhighscore",((new bb_newhighscorescene_NewHighscoreScene()).g_new()));
		t_router.m_Goto("intro");
		bb_director_Director t_director=(new bb_director_Director()).g_new(640,960);
		t_director.m_inputController().f_trackTouch=true;
		t_director.m_inputController().m_touchFingers(1);
		t_director.m_inputController().f_touchRetainSize=25;
		t_director.m_Run(t_router);
		return 0;
	}
	public static int bbInit(){
		bb_graphics.bb_graphics_context=null;
		bb_input.bb_input_device=null;
		bb_audio.bb_audio_device=null;
		bb_app.bb_app_device=null;
		bb_scene_Scene.g_blend=null;
		bb_graphics_Image.g_DefaultFlags=256;
		bb_service_PaymentService.g_androidPayment=null;
		bb_angelfont2_AngelFont.g_error="";
		bb_angelfont2_AngelFont.g_current=null;
		bb_angelfont2_AngelFont.g__list=(new bb_map_StringMap4()).g_new();
		bb_gamehighscore_GameHighscore.g_names=new String[0];
		bb_gamehighscore_GameHighscore.g_scores=new int[0];
		bb_severity.bb_severity_globalSeverityInstance=null;
		bb_random.bb_random_Seed=1234;
		bb_graphics.bb_graphics_renderDevice=null;
		bb_angelfont_AngelFont.g_error="";
		bb_angelfont_AngelFont.g_current=null;
		bb_angelfont_AngelFont.g__list=(new bb_map_StringMap5()).g_new();
		bb_iap.bb_iap_iapPurchaseInProgress=false;
		bb_iap.bb_iap_iapCount=0;
		bb_shape_Shape.g_images=new bb_graphics_Image[0];
		bb_shape_Shape.g_SPEED_SLOW=null;
		bb_shape_Shape.g_SPEED_FAST=null;
		return 0;
	}
}
class bb_appirater{
}
class bb_bono{
}
class bb_animation{
}
class bb_baseobject{
}
class bb_color{
}
class bb_deltatimer{
}
class bb_director{
}
class bb_directorevents{
}
class bb_fader{
}
class bb_fanout{
}
class bb_font{
}
class bb_highscore{
}
class bb_inputcontroller{
}
class bb_keyevent{
}
class bb_partial{
}
class bb_persistable{
}
class bb_positionable{
}
class bb_router{
}
class bb_routerevents{
}
class bb_score{
}
class bb_sizeable{
}
class bb_sprite{
}
class bb_statestore{
}
class bb_textinput{
}
class bb_touchevent{
}
class bb_transition{
}
class bb_util{
}
class bb_vector2d{
}
class bb_angelfont{
}
class bb_angelfont2{
}
class bb_char{
}
class bb_kernpair{
}
class bb_chute{
}
class bb_gamehighscore{
}
class bb_gameoverscene{
}
class bb_gamescene{
}
class bb_highscorescene{
}
class bb_iap{
	static public int bb_iap_InitInAppPurchases(String t_bundleID,String[] t_productList){
		return 0;
	}
	static boolean bb_iap_iapPurchaseInProgress;
	static int bb_iap_iapCount;
	static public int bb_iap_buyProduct(String t_product){
		bb_iap.bb_iap_iapPurchaseInProgress=true;
		bb_iap.bb_iap_iapCount=0;
		return 0;
	}
}
class bb_introscene{
}
class bb_menuscene{
}
class bb_newhighscorescene{
}
class bb_pausescene{
}
class bb_payment{
}
class bb_product{
}
class bb_scene{
}
class bb_service{
}
class bb_severity{
	static bb_severity_Severity bb_severity_globalSeverityInstance;
	static public bb_severity_Severity bb_severity_CurrentSeverity(){
		if(!((bb_severity.bb_severity_globalSeverityInstance)!=null)){
			bb_severity.bb_severity_globalSeverityInstance=(new bb_severity_Severity()).g_new();
		}
		return bb_severity.bb_severity_globalSeverityInstance;
	}
}
class bb_shape{
}
class bb_slider{
}
//${TRANSCODE_END}
