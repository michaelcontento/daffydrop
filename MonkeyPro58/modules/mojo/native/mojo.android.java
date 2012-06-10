
// Android mojo runtime.
//
// Copyright 2011 Mark Sibly, all rights reserved.
// No warranty implied; use at your own risk.

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

		msg="";
		
		if( t instanceof NullPointerException ){
			msg="Null object error";
		}else if( t instanceof ArithmeticException ){
			msg="Arithmetic error";
		}else if( t instanceof ArrayIndexOutOfBoundsException ){
			msg="Array index out of range";
		}
		
		String p=t.getMessage();
		
		if( p==null || p.length()==0 ){
			if( t instanceof Error ){
				System.exit(0);
			}
		}else{
			if( msg.length()!=0 ){
				msg+=" ("+p+")";
			}else{
				msg=p;
			}
		}
		
		if( msg.length()==0 ){
			msg="Unknown runtime error";
		}

		MonkeyGame.view.postDelayed( this,0 );
	}

	public void run(){
		String t="Monkey runtime error: "+msg+"\n"+bb_std_lang.stackTrace();
		
		AlertDialog.Builder db=new AlertDialog.Builder( MonkeyGame.activity );
		db.setMessage( t );
		
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
