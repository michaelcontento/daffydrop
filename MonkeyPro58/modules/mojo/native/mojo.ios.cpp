
// iOS mojo runtime.
//
// Copyright 2011 Mark Sibly, all rights reserved.
// No warranty implied; use at your own risk.

class gxtkApp;
class gxtkGraphics;
class gxtkSurface;
class gxtkInput;
class gxtkAudio;
class gxtkSample;

#include <mach/mach_time.h>
#include <AudioToolbox/ExtendedAudioFile.h>
#include <AVFoundation/AVAudioPlayer.h>

#define KEY_LMB 1
#define KEY_TOUCH0 0x180

gxtkApp *app;
UITextField *textField;
int textFieldState;

int Pow2Size( int n ){
	int i=1;
	while( i<n ) i*=2;
	return i;
}

BOOL CheckForExtension( NSString *name ){
	static NSArray *extensions;
	if( !extensions ){
		NSString *extensionsString=[NSString stringWithCString:(const char*)glGetString(GL_EXTENSIONS) encoding:NSASCIIStringEncoding];
		extensions=[extensionsString componentsSeparatedByString:@" "];
		[extensions retain];	//?Really needed?
	}
	return [extensions containsObject:name];
}

void RuntimeError( const char *p ){

	if( !p || !*p ) exit( 0 );
	
	app=0;

	String t=String("Monkey runtime error: ")+p+"\n"+StackTrace();
	
	UIAlertView *aview=[[UIAlertView alloc] 
	initWithTitle:@"Monkey Error" 
	message:t.ToNSString() 
	delegate:nil
	cancelButtonTitle:nil
	otherButtonTitles:nil];
	[aview autorelease];
	[aview show];
}

class gxtkObject : public Object{
public:
};

class gxtkApp : public gxtkObject{
public:
	MonkeyAppDelegate *appDelegate;

	gxtkGraphics *graphics;
	gxtkInput *input;
	gxtkAudio *audio;
	
	uint64_t startTime;
	mach_timebase_info_data_t timeInfo;
	
	int created;
	int updateRate;
	double nextUpdate;
	double updatePeriod;
	
	NSTimer *updateTimer;
	
	id display_link;
	int display_link_supported;
	
	bool suspended;	
	
	gxtkApp();
	
	void InvokeOnUpdate();
	void InvokeOnSuspend();
	void InvokeOnResume();
	void InvokeOnRender();
	
	double Time();

	//***** GXTK API *****

	virtual gxtkGraphics *GraphicsDevice();
	virtual gxtkInput *InputDevice();
	virtual gxtkAudio *AudioDevice();
	virtual String AppTitle();
	virtual String LoadState();
	virtual int SaveState( String state );
	virtual String LoadString( String path );
	virtual int SetUpdateRate( int hertz );
	virtual int MilliSecs();
	virtual int Loading();
	virtual int OnCreate();
	virtual int OnUpdate();
	virtual int OnSuspend();
	virtual int OnResume();
	virtual int OnRender();
	virtual int OnLoading();
};

//***** START OF COMMON OPENGL CODE *****

#define MAX_VERTS 1024
#define MAX_POINTS MAX_VERTS
#define MAX_LINES (MAX_VERTS/2)
#define MAX_QUADS (MAX_VERTS/4)

class gxtkGraphics : public gxtkObject{
public:

	int mode;
	int width;
	int height;

	int colorARGB;
	float r,g,b,alpha;
	float ix,iy,jx,jy,tx,ty;
	bool tformed;

	float vertices[MAX_VERTS*5];
	unsigned short quadIndices[MAX_QUADS*6];

	int primType;
	int primCount;
	gxtkSurface *primSurf;
	
	gxtkGraphics();
	
	bool Validate();		
	void BeginRender();
	void EndRender();
	void Flush();
	
	//***** GXTK API *****
	virtual int Mode();
	virtual int Width();
	virtual int Height();

	virtual gxtkSurface *LoadSurface( String path );
	
	virtual int Cls( float r,float g,float b );
	virtual int SetAlpha( float alpha );
	virtual int SetColor( float r,float g,float b );
	virtual int SetBlend( int blend );
	virtual int SetScissor( int x,int y,int w,int h );
	virtual int SetMatrix( float ix,float iy,float jx,float jy,float tx,float ty );
	
	virtual int DrawPoint( float x,float y );
	virtual int DrawRect( float x,float y,float w,float h );
	virtual int DrawLine( float x1,float y1,float x2,float y2 );
	virtual int DrawOval( float x1,float y1,float x2,float y2 );
	virtual int DrawPoly( Array<float> verts );
	virtual int DrawSurface( gxtkSurface *surface,float x,float y );
	virtual int DrawSurface2( gxtkSurface *surface,float x,float y,int srcx,int srcy,int srcw,int srch );
};

//***** gxtkSurface *****

class gxtkSurface : public gxtkObject{
public:
	GLuint texture;
	int width;
	int height;
	float uscale;
	float vscale;
	
	gxtkSurface( GLuint texture,int width,int height,float uscale,float vscale );
	~gxtkSurface();
	
	//***** GXTK API *****
	virtual int Discard();
	virtual int Width();
	virtual int Height();
	virtual int Loaded();
};

//***** gxtkGraphics *****

gxtkGraphics::gxtkGraphics(){

	mode=width=height=0;
	
	if( CFG_OPENGL_GLES20_ENABLED ) return;
	
	mode=1;
	
	for( int i=0;i<MAX_QUADS;++i ){
		quadIndices[i*6  ]=(short)(i*4);
		quadIndices[i*6+1]=(short)(i*4+1);
		quadIndices[i*6+2]=(short)(i*4+2);
		quadIndices[i*6+3]=(short)(i*4);
		quadIndices[i*6+4]=(short)(i*4+2);
		quadIndices[i*6+5]=(short)(i*4+3);
	}
}

void gxtkGraphics::BeginRender(){
	if( !mode ) return;
	
	glViewport( 0,0,width,height );

	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();
	glOrthof( 0,width,height,0,-1,1 );
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();

	glEnableClientState( GL_VERTEX_ARRAY );
	glVertexPointer( 2,GL_FLOAT,20,&vertices[0] );	
	
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	glTexCoordPointer( 2,GL_FLOAT,20,&vertices[2] );
	
	glEnableClientState( GL_COLOR_ARRAY );
	glColorPointer( 4,GL_UNSIGNED_BYTE,20,&vertices[4] );
	
	glEnable( GL_BLEND );
	glBlendFunc( GL_ONE,GL_ONE_MINUS_SRC_ALPHA );
	
	glDisable( GL_TEXTURE_2D );
	
	primCount=0;
}

void gxtkGraphics::Flush(){
	if( !primCount ) return;

	if( primSurf ){
		glEnable( GL_TEXTURE_2D );
		glBindTexture( GL_TEXTURE_2D,primSurf->texture );
	}
		
	switch( primType ){
	case 1:
		glDrawArrays( GL_POINTS,0,primCount );
		break;
	case 2:
		glDrawArrays( GL_LINES,0,primCount*2 );
		break;
	case 4:
		glDrawElements( GL_TRIANGLES,primCount*6,GL_UNSIGNED_SHORT,quadIndices );
		break;
	case 5:
		glDrawArrays( GL_TRIANGLE_FAN,0,primCount );
		break;
	}

	if( primSurf ){
		glDisable( GL_TEXTURE_2D );
	}

	primCount=0;
}

//***** GXTK API *****

int gxtkGraphics::Mode(){
	return mode;
}

int gxtkGraphics::Width(){
	return width;
}

int gxtkGraphics::Height(){
	return height;
}

int gxtkGraphics::Cls( float r,float g,float b ){
	primCount=0;

	glClearColor( r/255.0f,g/255.0f,b/255.0f,1 );
	glClear( GL_COLOR_BUFFER_BIT );

	return 0;
}

int gxtkGraphics::SetAlpha( float alpha ){
	this->alpha=alpha;
	
	int a=int(alpha*255);
	
	colorARGB=(a<<24) | (int(b*alpha)<<16) | (int(g*alpha)<<8) | int(r*alpha);
	
	return 0;
}

int gxtkGraphics::SetColor( float r,float g,float b ){
	this->r=r;
	this->g=g;
	this->b=b;

	int a=int(alpha*255);
	
	colorARGB=(a<<24) | (int(b*alpha)<<16) | (int(g*alpha)<<8) | int(r*alpha);
	
	return 0;
}

int gxtkGraphics::SetBlend( int blend ){
	Flush();
	
	switch( blend ){
	case 1:
		glBlendFunc( GL_ONE,GL_ONE );
		break;
	default:
		glBlendFunc( GL_ONE,GL_ONE_MINUS_SRC_ALPHA );
	}

	return 0;
}

int gxtkGraphics::SetScissor( int x,int y,int w,int h ){
	Flush();
	
	if( x!=0 || y!=0 || w!=Width() || h!=Height() ){
		glEnable( GL_SCISSOR_TEST );
		y=Height()-y-h;
		glScissor( x,y,w,h );
	}else{
		glDisable( GL_SCISSOR_TEST );
	}
	return 0;
}

int gxtkGraphics::SetMatrix( float ix,float iy,float jx,float jy,float tx,float ty ){

	tformed=(ix!=1 || iy!=0 || jx!=0 || jy!=1 || tx!=0 || ty!=0);

	this->ix=ix;this->iy=iy;this->jx=jx;this->jy=jy;this->tx=tx;this->ty=ty;

	return 0;
}

int gxtkGraphics::DrawLine( float x0,float y0,float x1,float y1 ){
	if( primType!=2 || primCount==MAX_LINES || primSurf ){
		Flush();
		primType=2;
		primSurf=0;
	}

	if( tformed ){
		float tx0=x0,tx1=x1;
		x0=tx0 * ix + y0 * jx + tx;y0=tx0 * iy + y0 * jy + ty;
		x1=tx1 * ix + y1 * jx + tx;y1=tx1 * iy + y1 * jy + ty;
	}
	
	float *vp=&vertices[primCount++*10];
	
	vp[0]=x0;vp[1]=y0;(int&)vp[4]=colorARGB;
	vp[5]=x1;vp[6]=y1;(int&)vp[9]=colorARGB;
	
	return 0;
}

int gxtkGraphics::DrawPoint( float x,float y ){
	if( primType!=1 || primCount==MAX_POINTS || primSurf ){
		Flush();
		primType=1;
		primSurf=0;
	}
	
	if( tformed ){
		float px=x;
		x=px * ix + y * jx + tx;
		y=px * iy + y * jy + ty;
	}
	
	float *vp=&vertices[primCount++*5];
	
	vp[0]=x;vp[1]=y;(int&)vp[4]=colorARGB;

	return 0;	
}
	
int gxtkGraphics::DrawRect( float x,float y,float w,float h ){
	if( primType!=4 || primCount==MAX_QUADS || primSurf ){
		Flush();
		primType=4;
		primSurf=0;
	}

	float x0=x,x1=x+w,x2=x+w,x3=x;
	float y0=y,y1=y,y2=y+h,y3=y+h;

	if( tformed ){
		float tx0=x0,tx1=x1,tx2=x2,tx3=x3;
		x0=tx0 * ix + y0 * jx + tx;y0=tx0 * iy + y0 * jy + ty;
		x1=tx1 * ix + y1 * jx + tx;y1=tx1 * iy + y1 * jy + ty;
		x2=tx2 * ix + y2 * jx + tx;y2=tx2 * iy + y2 * jy + ty;
		x3=tx3 * ix + y3 * jx + tx;y3=tx3 * iy + y3 * jy + ty;
	}
	
	float *vp=&vertices[primCount++*20];
	
	vp[0 ]=x0;vp[1 ]=y0;(int&)vp[4 ]=colorARGB;
	vp[5 ]=x1;vp[6 ]=y1;(int&)vp[9 ]=colorARGB;
	vp[10]=x2;vp[11]=y2;(int&)vp[14]=colorARGB;
	vp[15]=x3;vp[16]=y3;(int&)vp[19]=colorARGB;

	return 0;
}

int gxtkGraphics::DrawOval( float x,float y,float w,float h ){
	Flush();
	primType=5;
	primSurf=0;
	
	float xr=w/2.0f;
	float yr=h/2.0f;

	int segs;
	if( tformed ){
		float dx_x=xr * ix;
		float dx_y=xr * iy;
		float dx=sqrtf( dx_x*dx_x+dx_y*dx_y );
		float dy_x=yr * jx;
		float dy_y=yr * jy;
		float dy=sqrtf( dy_x*dy_x+dy_y*dy_y );
		segs=(int)( dx+dy );
	}else{
		segs=(int)( abs( xr )+abs( yr ) );
	}
	
	if( segs<12 ){
		segs=12;
	}else if( segs>MAX_VERTS ){
		segs=MAX_VERTS;
	}else{
		segs&=~3;
	}

	float x0=x+xr,y0=y+yr;
	
	float *vp=vertices;

	for( int i=0;i<segs;++i ){
	
		float th=i * 6.28318531f / segs;

		float px=x0+cosf( th ) * xr;
		float py=y0-sinf( th ) * yr;
		
		if( tformed ){
			float ppx=px;
			px=ppx * ix + py * jx + tx;
			py=ppx * iy + py * jy + ty;
		}
		
		vp[0]=px;vp[1]=py;(int&)vp[4]=colorARGB;
		vp+=5;
	}
	
	primCount=segs;

	Flush();
	
	return 0;
}

int gxtkGraphics::DrawPoly( Array<float> verts ){
	int n=verts.Length()/2;
	if( n<3 || n>MAX_VERTS ) return 0;
	
	Flush();
	primType=5;
	primSurf=0;
	
	float *vp=vertices;
	
	for( int i=0;i<n;++i ){
	
		float px=verts[i*2];
		float py=verts[i*2+1];
		
		if( tformed ){
			float ppx=px;
			px=ppx * ix + py * jx + tx;
			py=ppx * iy + py * jy + ty;
		}
		
		vp[0]=px;vp[1]=py;(int&)vp[4]=colorARGB;
		vp+=5;
	}

	primCount=n;
	
	Flush();
	
	return 0;
}


int gxtkGraphics::DrawSurface( gxtkSurface *surf,float x,float y ){
	if( primType!=4 || primCount==MAX_QUADS || surf!=primSurf ){
		Flush();
		primType=4;
		primSurf=surf;
	}

	float w=surf->Width();
	float h=surf->Height();
	float x0=x,x1=x+w,x2=x+w,x3=x;
	float y0=y,y1=y,y2=y+h,y3=y+h;
	float u0=0,u1=w*surf->uscale;
	float v0=0,v1=h*surf->vscale;

	if( tformed ){
		float tx0=x0,tx1=x1,tx2=x2,tx3=x3;
		x0=tx0 * ix + y0 * jx + tx;y0=tx0 * iy + y0 * jy + ty;
		x1=tx1 * ix + y1 * jx + tx;y1=tx1 * iy + y1 * jy + ty;
		x2=tx2 * ix + y2 * jx + tx;y2=tx2 * iy + y2 * jy + ty;
		x3=tx3 * ix + y3 * jx + tx;y3=tx3 * iy + y3 * jy + ty;
	}
	
	float *vp=&vertices[primCount++*20];
	
	vp[0 ]=x0;vp[1 ]=y0;vp[2 ]=u0;vp[3 ]=v0;(int&)vp[4 ]=colorARGB;
	vp[5 ]=x1;vp[6 ]=y1;vp[7 ]=u1;vp[8 ]=v0;(int&)vp[9 ]=colorARGB;
	vp[10]=x2;vp[11]=y2;vp[12]=u1;vp[13]=v1;(int&)vp[14]=colorARGB;
	vp[15]=x3;vp[16]=y3;vp[17]=u0;vp[18]=v1;(int&)vp[19]=colorARGB;
	
	return 0;
}

int gxtkGraphics::DrawSurface2( gxtkSurface *surf,float x,float y,int srcx,int srcy,int srcw,int srch ){
	if( primType!=4 || primCount==MAX_QUADS || surf!=primSurf ){
		Flush();
		primType=4;
		primSurf=surf;
	}

	float w=srcw;
	float h=srch;
	float x0=x,x1=x+w,x2=x+w,x3=x;
	float y0=y,y1=y,y2=y+h,y3=y+h;
	float u0=srcx*surf->uscale,u1=(srcx+srcw)*surf->uscale;
	float v0=srcy*surf->vscale,v1=(srcy+srch)*surf->vscale;

	if( tformed ){
		float tx0=x0,tx1=x1,tx2=x2,tx3=x3;
		x0=tx0 * ix + y0 * jx + tx;y0=tx0 * iy + y0 * jy + ty;
		x1=tx1 * ix + y1 * jx + tx;y1=tx1 * iy + y1 * jy + ty;
		x2=tx2 * ix + y2 * jx + tx;y2=tx2 * iy + y2 * jy + ty;
		x3=tx3 * ix + y3 * jx + tx;y3=tx3 * iy + y3 * jy + ty;
	}
	
	float *vp=&vertices[primCount++*20];
	
	vp[0 ]=x0;vp[1 ]=y0;vp[2 ]=u0;vp[3 ]=v0;(int&)vp[4 ]=colorARGB;
	vp[5 ]=x1;vp[6 ]=y1;vp[7 ]=u1;vp[8 ]=v0;(int&)vp[9 ]=colorARGB;
	vp[10]=x2;vp[11]=y2;vp[12]=u1;vp[13]=v1;(int&)vp[14]=colorARGB;
	vp[15]=x3;vp[16]=y3;vp[17]=u0;vp[18]=v1;(int&)vp[19]=colorARGB;
	
	return 0;
}

//***** gxtkSurface *****

gxtkSurface::gxtkSurface( GLuint texture,int width,int height,float uscale,float vscale ):
	texture(texture),width(width),height(height),uscale(uscale),vscale(vscale){
}

gxtkSurface::~gxtkSurface(){
	Discard();
}

int gxtkSurface::Discard(){
	if( texture ){
		glDeleteTextures( 1,&texture );
		texture=0;
	}
	return 0;
}

int gxtkSurface::Width(){
	return width;
}

int gxtkSurface::Height(){
	return height;
}

int gxtkSurface::Loaded(){
	return 1;
}

//***** END OF COMMON OPENGL CODE *****

bool gxtkGraphics::Validate(){
	width=app->appDelegate->view->backingWidth;
	height=app->appDelegate->view->backingHeight;
	return width>0 && height>0;
}

void gxtkGraphics::EndRender(){
	if( mode ) Flush();
	[app->appDelegate->view presentRenderbuffer];
}

gxtkSurface *gxtkGraphics::LoadSurface( String path ){

	path=String( "data/" )+path;
	NSString *nspath=path.ToNSString();

	//This was apparently buggy in iOS2.x, but NO MORE?
	UIImage *uiimage=[ UIImage imageNamed:nspath ];

	if( !uiimage ) return 0;
	
	CGImageRef cgimage=uiimage.CGImage;
	
	int width=CGImageGetWidth( cgimage );
	int height=CGImageGetHeight( cgimage );
	
	int texwidth,texheight;
	
	if( CheckForExtension( @"GL_APPLE_texture_2D_limited_npot" ) ){
		texwidth=width;
		texheight=height;
	}else{
		texwidth=Pow2Size( width );
		texheight=Pow2Size( height );
	}
	
	float uscale=1.0f/texwidth;
	float vscale=1.0f/texheight;

	void *data=calloc( texwidth*texheight,4 );
	
	CGContextRef context=CGBitmapContextCreate( data,width,height,8,texwidth*4,CGImageGetColorSpace(cgimage),kCGImageAlphaPremultipliedLast );
	CGContextDrawImage( context,CGRectMake(0,0,width,height),cgimage );
	CGContextRelease( context );
	
	GLuint texture;
	glGenTextures( 1,&texture );
	glBindTexture( GL_TEXTURE_2D,texture );

	if( CFG_MOJO_IMAGE_FILTERING_ENABLED ){
		glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR );
		glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR );
	}else{
		glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST );
		glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST );
	}
	
	glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE );
	glTexParameteri( GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE );
	
	glPixelStorei( GL_UNPACK_ALIGNMENT,1 );
	
	glTexImage2D( GL_TEXTURE_2D,0,GL_RGBA,texwidth,texheight,0,GL_RGBA,GL_UNSIGNED_BYTE,data );
	
	free( data );
	
	return new gxtkSurface( texture,width,height,uscale,vscale );
}

//***** END OF GRAPHICS *****


class gxtkInput : public gxtkObject{
public:
	int keyStates[512];
	int charQueue[32];
	int charPut,charGet;
	UITouch *touches[32];
	float touchX[32];
	float touchY[32];
	float accelX,accelY,accelZ;
	
	gxtkInput();
	
	void OnEvent( UIEvent *event );
	void OnAcceleration( UIAcceleration *accel );
	
	void BeginUpdate();
	void EndUpdate();
	
	void PutChar( int chr );
	
	//***** GXTK API *****
	virtual int SetKeyboardEnabled( int enabled );
	
	virtual int KeyDown( int key );
	virtual int KeyHit( int key );
	virtual int GetChar();
	
	virtual float MouseX();
	virtual float MouseY();

	virtual float JoyX( int index );
	virtual float JoyY( int index );
	virtual float JoyZ( int index );

	virtual float TouchX( int index );
	virtual float TouchY( int index );
	
	virtual float AccelX();
	virtual float AccelY();
	virtual float AccelZ();
};

class gxtkChannel{
public:
	ALuint source;
	gxtkSample *sample;
	int flags;
	int state;
	
	int AL_Source();
};

class gxtkAudio : public gxtkObject{
public:

	AVAudioPlayer *music;
	float musicVolume;
	int musicState;
	
	gxtkChannel channels[33];

	gxtkAudio();

	void mark();
	void OnSuspend();
	void OnResume();
	
	int AL_Source( int channel );
	
	//***** GXTK API *****
	virtual gxtkSample *LoadSample( String path );
	virtual int PlaySample( gxtkSample *sample,int channel,int flags );
	
	virtual int StopChannel( int channel );
	virtual int PauseChannel( int channel );
	virtual int ResumeChannel( int channel );
	virtual int ChannelState( int channel );
	virtual int SetVolume( int channel,float volume );
	virtual int SetPan( int channel,float pan );
	virtual int SetRate( int channel,float rate );
	
	virtual int PlayMusic( String path,int flags );
	virtual int StopMusic();
	virtual int PauseMusic();
	virtual int ResumeMusic();
	virtual int MusicState();
	virtual int SetMusicVolume( float volume );
};

class gxtkSample : public gxtkObject{
public:
	ALuint al_buffer;
	
	gxtkSample();
	~gxtkSample();
	
	gxtkSample *Load( String path );
	gxtkSample *LoadWAV( String path );
	
	//***** GXTK API *****
	
	virtual int Discard();
};

//***** gxtkApp *****

gxtkApp::gxtkApp(){
	app=this;
	
	appDelegate=(MonkeyAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	graphics=new gxtkGraphics;
	input=new gxtkInput;
	audio=new gxtkAudio;
	
	mach_timebase_info( &timeInfo );
	startTime=mach_absolute_time();
	
	created=0;
	updateRate=0;
	updateTimer=0;
	display_link=0;
	display_link_supported=0;
	suspended=false;
	
	NSString *reqSysVer = @"3.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	if( [currSysVer compare:reqSysVer options:NSNumericSearch]!=NSOrderedAscending ){
		display_link_supported=1;
	}
}

void gxtkApp::InvokeOnUpdate(){
	if( suspended || updateRate==0 ) return;
	
	try{
		if( graphics->Validate() ){
			if( !created ){
				created=1;
				OnCreate();
				gc_collect();
			}
			input->BeginUpdate();
			OnUpdate();
			input->EndUpdate();
		}
	}catch( const char *p ){
		RuntimeError( p );
	}
	gc_collect();
}

void gxtkApp::InvokeOnSuspend(){
	if( suspended ) return;
	
	try{
		suspended=true;
		OnSuspend();
		audio->OnSuspend();
		if( updateRate ){
			int upr=updateRate;
			SetUpdateRate( 0 );
			updateRate=upr;
		}
	}catch( const char *p ){
		RuntimeError( p );
	}
	gc_collect();
}

void gxtkApp::InvokeOnResume(){
	if( !suspended ) return;
	
	try{
		if( updateRate ){
			int upr=updateRate;
			updateRate=0;
			SetUpdateRate( upr );
		}
		audio->OnResume();
		OnResume();
		suspended=false;
	}catch( const char *p ){
		RuntimeError( p );
	}
	gc_collect();
}

void gxtkApp::InvokeOnRender(){
	if( suspended ) return;
	
	try{
		if( graphics->Validate() ){
			if( !created ){
				created=1;
				OnCreate();
				gc_collect();
			}
			graphics->BeginRender();
			OnRender();
			graphics->EndRender();
		}
	}catch( const char *p ){
		RuntimeError( p );
	}
	gc_collect();
}

double gxtkApp::Time(){
	uint64_t nanos=mach_absolute_time()-startTime;
	nanos*=timeInfo.numer;
	nanos/=timeInfo.denom;
	return nanos/1000000000.0;
}

//***** Mojo API *****

gxtkGraphics *gxtkApp::GraphicsDevice(){
	return graphics;
}

gxtkInput *gxtkApp::InputDevice(){
	return input;
}

gxtkAudio *gxtkApp::AudioDevice(){
	return audio;
}

String gxtkApp::AppTitle(){
	return "<TODO>";
}

String gxtkApp::LoadState(){
	NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
	NSString *nsstr=[prefs stringForKey:@".monkeystate"];
	if( nsstr ) return String( nsstr );
	return "";
}

int gxtkApp::SaveState( String state ){
	NSString *nsstr=state.ToNSString();
	NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
	[prefs setObject:nsstr forKey:@".monkeystate"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	return 0;
}

static NSString *pathForResource( String fpath ){
	NSString *path=fpath.ToNSString();
	NSString *ext=[path pathExtension];
	NSString *file=[[path lastPathComponent] stringByDeletingPathExtension];
	NSString *dir=[@"data/" stringByAppendingString:[path stringByDeletingLastPathComponent]];
	NSString *rpath=[[NSBundle mainBundle] pathForResource:file ofType:ext inDirectory:dir];
	return rpath;
}

String gxtkApp::LoadString( String fpath ){
	NSString *rpath=pathForResource( fpath );
	if( !rpath ) return "";

	NSURL *url=[NSURL fileURLWithPath:rpath];
	NSStringEncoding enc;

	NSString *str=[NSString stringWithContentsOfURL:url usedEncoding:&enc error:nil];
	if( str ) return String( str );
	
	return "";
}

int gxtkApp::SetUpdateRate( int hertz ){

	if( updateTimer || display_link ){
		//Kill acceler/timer
		//
		if( CFG_IOS_ACCELEROMETER_ENABLED ){
			UIAccelerometer *acc=[UIAccelerometer sharedAccelerometer];
			UIApplication *app=[UIApplication sharedApplication];
			[acc setUpdateInterval:0.0];
			[acc setDelegate:0];
			[app setIdleTimerDisabled:NO];
		}
		if( updateTimer ){
			[updateTimer invalidate];
			updateTimer=0;
		}else if( display_link ){
			[display_link invalidate];
			display_link=0;
		}
	}

	updateRate=hertz;

	if( updateRate ){
		//Enable acceler/timer
		//
		if( CFG_IOS_ACCELEROMETER_ENABLED ){
			UIAccelerometer *acc=[UIAccelerometer sharedAccelerometer];
			UIApplication *app=[UIApplication sharedApplication];
			[acc setUpdateInterval:1.0/updateRate];
			[acc setDelegate:appDelegate];
			[app setIdleTimerDisabled:YES];
		}
		updatePeriod=1.0/updateRate;
		nextUpdate=Time()+updatePeriod;
		
		if( CFG_IOS_DISPLAY_LINK_ENABLED ){
			if( updateRate==60 && display_link_supported ){
				display_link=[NSClassFromString(@"CADisplayLink") displayLinkWithTarget:appDelegate selector:@selector(updateTimerFired)];
	
				[display_link setFrameInterval:1];
				[display_link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			}
		}
		if( !display_link ){
			updateTimer=[NSTimer 
			scheduledTimerWithTimeInterval:(NSTimeInterval)(1.0/updateRate)
			target:appDelegate
			selector:@selector(updateTimerFired) userInfo:nil repeats:TRUE];
		}
	}
	return 0;
}

int gxtkApp::MilliSecs(){
	uint64_t nanos=mach_absolute_time()-startTime;
	nanos*=timeInfo.numer;
	nanos/=timeInfo.denom;
	return nanos/1000000L;
}

int gxtkApp::Loading(){
	return 0;
}

int gxtkApp::OnCreate(){
	return 0;
}

int gxtkApp::OnUpdate(){
	return 0;
}

int gxtkApp::OnSuspend(){
	return 0;
}

int gxtkApp::OnResume(){
	return 0;
}

int gxtkApp::OnRender(){
	return 0;
}

int gxtkApp::OnLoading(){
	return 0;
}

// ***** gxtkInput *****

gxtkInput::gxtkInput(){
	memset( keyStates,0,sizeof(keyStates) );
	memset( touches,0,sizeof(touches) );
	memset( touchX,0,sizeof(touchX) );
	memset( touchY,0,sizeof(touchY) );
	accelX=accelY=accelZ=0;
	charPut=charGet=0;
}

void gxtkInput::BeginUpdate(){
}

void gxtkInput::EndUpdate(){
	for( int i=0;i<512;++i ){
		keyStates[i]&=0x100;
	}
	charGet=0;
	charPut=0;
}

void gxtkInput::PutChar( int chr ){
	if( charPut<32 ) charQueue[charPut++]=chr;
}

void gxtkInput::OnEvent( UIEvent *event ){
	if( [event type]==UIEventTypeTouches ){
	
		UIView *view=app->appDelegate->view;

		float scaleFactor=1.0f;
		if( [view respondsToSelector:@selector(contentScaleFactor)] ){
			scaleFactor=[view contentScaleFactor];
		}
		
		for( int pid=0;pid<32;++pid ){
			if( touches[pid] && touches[pid].view!=view ) touches[pid]=0;
		}

		for( UITouch *touch in [event touchesForView:view] ){
		
			int pid;
			for( pid=0;pid<32 && touches[pid]!=touch;++pid ) {}

			switch( [touch phase] ){
			case UITouchPhaseBegan:
				if( pid!=32 ){ pid=32;break; }
				for( pid=0;pid<32 && touches[pid];++pid ){}
				if( pid==32 ) break;
				touches[pid]=touch;
				keyStates[KEY_TOUCH0+pid]=0x101;
				break;
			case UITouchPhaseEnded:
			case UITouchPhaseCancelled:
				if( pid==32 ) break;
				touches[pid]=0;
				keyStates[KEY_TOUCH0+pid]=0;
				break;
			case UITouchPhaseMoved:
			case UITouchPhaseStationary:
				break;
			}
			if( pid==32 ){
				printf( "***** GXTK Touch Error *****\n" );fflush( stdout );
				continue;
			}
			
			CGPoint p=[touch locationInView:view];
			p.x*=scaleFactor;
			p.y*=scaleFactor;
			
			touchX[pid]=p.x;
			touchY[pid]=p.y;
		}
	}
}

void gxtkInput::OnAcceleration( UIAcceleration *accel ){
	switch( [app->appDelegate viewController].interfaceOrientation ){
	case UIDeviceOrientationPortrait:
		accelX=+accel.x;
		accelY=-accel.y;
		break;
	case UIDeviceOrientationPortraitUpsideDown:
		accelX=-accel.x;
		accelY=+accel.y;
		break;
	case UIDeviceOrientationLandscapeLeft:
		accelX=-accel.y;
		accelY=-accel.x;
		break;
	case UIDeviceOrientationLandscapeRight:
		accelX=+accel.y;
		accelY=+accel.x;
		break;
	default:
		exit(0);
		return;
	}
	accelZ=-accel.z;
}

//***** GXTK API *****

int gxtkInput::SetKeyboardEnabled( int enabled ){
	if( enabled ){
		textFieldState=1;
		textField.text=@" ";
		[textField becomeFirstResponder];
	}else{
		textFieldState=0;
		[textField resignFirstResponder];
	}
	return 0;
}

int gxtkInput::KeyDown( int key ){
	if( key>0 && key<512 ){
		if( key==KEY_LMB ) key=KEY_TOUCH0;
		return keyStates[key] >> 8;
	}
	return 0;
}

int gxtkInput::KeyHit( int key ){
	if( key>0 && key<512 ){
		if( key==KEY_LMB ) key=KEY_TOUCH0;
		return keyStates[key] & 0xff;
	}
	return 0;
}

int gxtkInput::GetChar(){
	if( charGet<charPut ){
		return charQueue[charGet++];
	}
	return 0;
}
	
float gxtkInput::MouseX(){
	return touchX[0];
}

float gxtkInput::MouseY(){
	return touchY[0];
}

float gxtkInput::JoyX( int index ){
	return 0;
}

float gxtkInput::JoyY( int index ){
	return 0;
}

float gxtkInput::JoyZ( int index ){
	return 0;
}

float gxtkInput::TouchX( int index ){
	return touchX[index];
}

float gxtkInput::TouchY( int index ){
	return touchY[index];
}

float gxtkInput::AccelX(){
	return accelX;
}

float gxtkInput::AccelY(){
	return accelY;
}

float gxtkInput::AccelZ(){
	return accelZ;
}

//***** gxtkAudio *****
static std::vector<ALuint> discarded;

static void FlushDiscarded( gxtkAudio *audio ){
	if( !discarded.size() ) return;
	for( int i=0;i<33;++i ){
		gxtkChannel *chan=&audio->channels[i];
		if( chan->state ){
			int state=0;
			alGetSourcei( chan->source,AL_SOURCE_STATE,&state );
			if( state==AL_STOPPED ) alSourcei( chan->source,AL_BUFFER,0 );
		}
	}
	std::vector<ALuint> out;
	for( int i=0;i<discarded.size();++i ){
		ALuint buf=discarded[i];
		alDeleteBuffers( 1,&buf );
		ALenum err=alGetError();
		if( err==AL_NO_ERROR ){
//			printf( "alDeleteBuffers OK!\n" );fflush( stdout );
		}else{
//			printf( "alDeleteBuffers failed:%i\n" );fflush( stdout );
			out.push_back( buf );
		}
	}
	discarded=out;
}

static void CheckAL(){
	ALenum err=alGetError();
	if( err!=AL_NO_ERROR ){
		printf( "AL Error:%i\n",err );
		fflush( stdout );
	}
}

int gxtkChannel::AL_Source(){
	if( !source ) alGenSources( 1,&source );
	return source;
}

gxtkAudio::gxtkAudio():music(0),musicVolume(1),musicState(0){
	alDistanceModel( AL_NONE );
	memset( channels,0,sizeof(channels) );
}

void gxtkAudio::mark(){
	for( int i=0;i<33;++i ){
		gxtkChannel *chan=&channels[i];
		if( chan->state!=0 ){
			int state=0;
			alGetSourcei( chan->source,AL_SOURCE_STATE,&state );
			if( state!=AL_STOPPED ) gc_mark( chan->sample );
		}
	}
}

void gxtkAudio::OnSuspend(){
	for( int i=0;i<33;++i ){
		gxtkChannel *chan=&channels[i];
		if( chan->state==1 ){
			int state=0;
			alGetSourcei( chan->source,AL_SOURCE_STATE,&state );
			if( state==AL_PLAYING ) alSourcePause( chan->source );
		}
	}
}

void gxtkAudio::OnResume(){
	for( int i=0;i<33;++i ){
		gxtkChannel *chan=&channels[i];
		if( chan->state==1 ){
			int state=0;
			alGetSourcei( chan->source,AL_SOURCE_STATE,&state );
			if( state==AL_PAUSED ) alSourcePlay( chan->source );
		}
	}
}

gxtkSample *gxtkAudio::LoadSample( String path ){
	FlushDiscarded( this );
	return (new gxtkSample())->Load( path );
}

int gxtkAudio::PlaySample( gxtkSample *sample,int channel,int flags ){
	gxtkChannel *chan=&channels[channel];
	
	chan->AL_Source();
	
	alSourceStop( chan->source );
	alSourcei( chan->source,AL_BUFFER,sample->al_buffer );
	alSourcei( chan->source,AL_LOOPING,flags ? 1 : 0 );
	alSourcePlay( chan->source );
	
	gc_assign( chan->sample,sample );
	
	chan->flags=flags;
	chan->state=1;
	
	return 0;
}

int gxtkAudio::StopChannel( int channel ){
	gxtkChannel *chan=&channels[channel];

	if( chan->state!=0 ){
		alSourceStop( chan->source );
		chan->state=0;
	}
	return 0;
}

int gxtkAudio::PauseChannel( int channel ){
	gxtkChannel *chan=&channels[channel];

	if( chan->state==1 ){
		int state=0;
		alGetSourcei( chan->source,AL_SOURCE_STATE,&state );
		if( state==AL_STOPPED ){
			chan->state=0;
		}else{
			alSourcePause( chan->source );
			chan->state=2;
		}
	}
	return 0;
}

int gxtkAudio::ResumeChannel( int channel ){
	gxtkChannel *chan=&channels[channel];

	if( chan->state==2 ){
		alSourcePlay( chan->source );
		chan->state=1;
	}
	return 0;
}

int gxtkAudio::ChannelState( int channel ){
	gxtkChannel *chan=&channels[channel];
	
	if( chan->state==1 ){
		int state=0;
		alGetSourcei( chan->source,AL_SOURCE_STATE,&state );
		if( state==AL_STOPPED ){
			chan->state=0;
		}
	}
	return chan->state;
}

int gxtkAudio::SetVolume( int channel,float volume ){
	gxtkChannel *chan=&channels[channel];

	alSourcef( chan->AL_Source(),AL_GAIN,volume );
	return 0;
}

int gxtkAudio::SetPan( int channel,float pan ){
	gxtkChannel *chan=&channels[channel];

	alSource3f( chan->AL_Source(),AL_POSITION,pan,0,0 );
	return 0;
}

int gxtkAudio::SetRate( int channel,float rate ){
	gxtkChannel *chan=&channels[channel];

	alSourcef( chan->AL_Source(),AL_PITCH,rate );
	return 0;
}

int gxtkAudio::PlayMusic( String fpath,int flags ){
	StopMusic();
	
	NSString *path=pathForResource( fpath );
	if( !path ) return -1;

	NSURL *url=[NSURL fileURLWithPath:path];
	
	music=[[AVAudioPlayer alloc] initWithContentsOfURL:url error:0];

	music.volume=musicVolume;
	music.numberOfLoops=flags ? -1 : 0;

	[music play];

	musicState=1;

	return 0;
}

int gxtkAudio::StopMusic(){
	if( musicState!=0 ){
		[music stop];
		[music release];
		musicState=0;
		music=0;
	}
	return 0;
}

int gxtkAudio::PauseMusic(){
	if( musicState==1 ){
		if( music.playing ){
			[music pause];
			musicState=2;
		}
	}
	return 0;
}

int gxtkAudio::ResumeMusic(){
	if( musicState==2 ){
		[music play];
		musicState=1;
	}
	return 0;
}

int gxtkAudio::MusicState(){
	if( musicState==1 ){
		if( !music.playing ) musicState=0;
	}
	return musicState;
}

int gxtkAudio::SetMusicVolume( float volume ){
	if( musicState!=0 ) music.volume=volume;
	musicVolume=volume;
	return 0;
}

//***** gxtkSample *****

// Based on some very flaky sample code from Apple.
//
// Issues:
//
// * WAV loader appears to prefix a bit of noise - perhaps the WAV header? Anyway, don't use this for WAVs...
//
// * Loaded samples can be shorter than expected - initial sample code ignored this.
//
// * Why is dataSize scaled by 2? Seems unnecesary, but sample code does it and it's harmless I guess so leave it...
//
static void *MyGetOpenALAudioData( CFURLRef url,ALsizei *outDataSize,ALenum *outDataFormat,ALsizei *outSampleRate ){

	void *data=0;
    ExtAudioFileRef fileRef=0;

	if( !ExtAudioFileOpenURL( url,&fileRef ) ){

	    AudioStreamBasicDescription fileFormat;
		UInt32 propSize=sizeof( fileFormat );
		
		if( !ExtAudioFileGetProperty( fileRef,kExtAudioFileProperty_FileDataFormat,&propSize,&fileFormat ) ){

		    AudioStreamBasicDescription outputFormat;
		
			outputFormat.mSampleRate=fileFormat.mSampleRate;
			outputFormat.mChannelsPerFrame=fileFormat.mChannelsPerFrame;
			
			outputFormat.mFormatID=kAudioFormatLinearPCM;
			outputFormat.mBytesPerPacket=2*outputFormat.mChannelsPerFrame;
			outputFormat.mFramesPerPacket=1;
			outputFormat.mBytesPerFrame=2*outputFormat.mChannelsPerFrame;
			outputFormat.mBitsPerChannel=16;
			outputFormat.mFormatFlags=kAudioFormatFlagsNativeEndian|kAudioFormatFlagIsPacked|kAudioFormatFlagIsSignedInteger;
			
			if( !ExtAudioFileSetProperty( fileRef,kExtAudioFileProperty_ClientDataFormat,sizeof( outputFormat ),&outputFormat ) ){

				SInt64 fileLen=0;
				UInt32 propSize=sizeof( fileLen );
				
				if( !ExtAudioFileGetProperty( fileRef,kExtAudioFileProperty_FileLengthFrames,&propSize,&fileLen ) ){
				
					UInt32 dataSize=fileLen * outputFormat.mBytesPerFrame;

					//Why dataSize*2? Sample code does it, but it appears unecessary....
					//
					data=malloc( dataSize*2 );
					memset( data,0,dataSize*2 );	//just in case...

					AudioBufferList buf;
					buf.mNumberBuffers=1;
					buf.mBuffers[0].mData=data;
					buf.mBuffers[0].mDataByteSize=dataSize*2;
					buf.mBuffers[0].mNumberChannels=outputFormat.mChannelsPerFrame;
					
//					printf( "fileLen1=%i\n",fileLen );
        
					// Read the data into an AudioBufferList
					if( !ExtAudioFileRead( fileRef,(UInt32*)&fileLen,&buf ) ){
				
						//This *does* change
						//
						dataSize=fileLen * outputFormat.mBytesPerFrame;
					
//						printf( "fileLen2=%i\n",fileLen );fflush( stdout );
        
						*outDataSize = (ALsizei)dataSize;
						*outDataFormat = (outputFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
						*outSampleRate = (ALsizei)outputFormat.mSampleRate;

					}else{
						free( data );
						data=0;
					}
				}
			}
		}
	}
	if( fileRef ) ExtAudioFileDispose( fileRef );
	
	return data;
}

static const char *ReadTag( FILE *f ){
	static char buf[8];
	if( fread( buf,4,1,f )!=1 ) return "";
	buf[4]=0;
	return buf;
}

static int ReadInt( FILE *f ){
	unsigned char buf[4];
	if( fread( buf,4,1,f )!=1 ) return -1;
	return (buf[3]<<24) | (buf[2]<<16) | (buf[1]<<8) | buf[0];
}

static int ReadShort( FILE *f ){
	unsigned char buf[2];
	if( fread( buf,2,1,f )!=1 ) return -1;
	return (buf[1]<<8) | buf[0];
}

static void SkipBytes( int n,FILE *f ){
	char *p=(char*)malloc( n );
	fread( p,n,1,f );
	free(p);
}

gxtkSample::gxtkSample():al_buffer(0){
}

gxtkSample::~gxtkSample(){
	Discard();
}

int gxtkSample::Discard(){
	if( al_buffer ){
		discarded.push_back( al_buffer );
		al_buffer=0;
	}
	return 0;
}

gxtkSample *gxtkSample::Load( String fpath ){

	if( fpath.ToLower().EndsWith( ".wav" ) ) return LoadWAV( fpath );
	
	NSString *path=pathForResource( fpath );
	if( !path ) return 0;

	NSURL *url=[NSURL fileURLWithPath:path];
	
	ALsizei size=0;
	ALenum format=0;
	ALsizei rate=0;

	void *data=MyGetOpenALAudioData( (CFURLRef)url,&size,&format,&rate );
	if( !data ) return 0;
	
	alGenBuffers( 1,&al_buffer );
	alBufferData( al_buffer,format,data,size,rate );

	free( data );

	return this;
}

//Custom WAV loader as ExtAudioFileRead appears to prefix WAVs with noise - perhaps the WAV header?
//
gxtkSample *gxtkSample::LoadWAV( String path ){

	NSString *rpath=pathForResource( path );
	if( !rpath ) return 0;

	if( FILE *f=fopen([rpath cStringUsingEncoding:1],"rb" ) ){
		if( !strcmp( ReadTag( f ),"RIFF" ) ){
			ReadInt( f );	//int len=ReadInt( f )-8;
			if( !strcmp( ReadTag( f ),"WAVE" ) ){
				if( !strcmp( ReadTag( f ),"fmt " ) ){
					int len2=ReadInt( f );
					int comp=ReadShort( f );
					if( comp==1 ){
						int chans=ReadShort( f );
						int hertz=ReadInt( f );
						ReadInt( f );		//int bytespersec=ReadInt( f );
						ReadShort( f );	//int pad=ReadShort( f );
						int bits=ReadShort( f );
						int format=0;
						if( bits==8 && chans==1 ){
							format=AL_FORMAT_MONO8;
						}else if( bits==8 && chans==2 ){
							format=AL_FORMAT_STEREO8;
						}else if( bits==16 && chans==1 ){
							format=AL_FORMAT_MONO16;
						}else if( bits==16 && chans==2 ){
							format=AL_FORMAT_STEREO16;
						}
						if( format ){
							if( len2>16 ) SkipBytes( len2-16,f );
							for(;;){
								const char *p=ReadTag( f );
								if( feof( f ) ) break;
								int size=ReadInt( f );
								if( strcmp( p,"data" ) ){
									SkipBytes( size,f );
									continue;
								}
								char *data=(char*)malloc( size );
								if( fread( data,size,1,f )==1 ){
									alGenBuffers( 1,&al_buffer );
									alBufferData( al_buffer,format,data,size,hertz );
								}
								free( data );
								fclose( f );
								return this;
							}
						}
					}
				}
			}
		}
		fclose( f );
	}
	return 0;
}

// ***** Ok, we have to implement app delegate ourselves *****

@implementation MonkeyAppDelegate

@synthesize window;
@synthesize view;
@synthesize viewController;

-(void)drawView:(MonkeyView*)aview{
	if( !app ) return;
	
	app->InvokeOnRender();
}

-(void)onEvent:(UIEvent*)event{
	if( !app ) return;
	
	app->input->OnEvent( event );
}

-(void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration{
	if( !app ) return;
	
	app->input->OnAcceleration( acceleration );
}

-(BOOL)textFieldShouldEndEditing:(UITextField*)textField{
	if( !app ) return YES;
	
	if( textFieldState ){	//still active?
		app->input->PutChar( 27 );	//generate an ESC
		return NO;
	}
	return YES;
}

-(BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)str{
	if( !app ) return NO;
	
	int n=[str length];
	
	if( n==0 && range.length==1 ){
		app->input->PutChar( 8 );	//emulate backspace!
	}else if( n==1 && range.length==0 ){
		int chr=[str characterAtIndex:0];
		switch( chr ){
		case 10:chr=13;break;
		}
		app->input->PutChar( chr );
	}
	return NO;
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions{
    
	const char *err=0;
	
	//Note: this code needs to appear *before* view init code below for some weird reason...clean this up!
	try{
		bb_std_main( 0,0 );
		if( !app ) exit( 0 );
	}catch( const char *p ){
		err=p;
	}

	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
	
	CGRect appFrame=[[UIScreen mainScreen] applicationFrame];
	
	CGRect textFrame;
	textFrame.origin.x=0;//appFrame.origin.x;
	textFrame.origin.y=0;//appFrame.origin.y+appFrame.size.height;
	textFrame.size.width=0;//appFrame.size.width;
	textFrame.size.height=0;//1;
	textField=[[UITextField alloc] initWithFrame:textFrame];
	textField.delegate=(id)self;
	textField.autocorrectionType=UITextAutocorrectionTypeNo;
	
	[viewController.view setFrame:appFrame];

	[viewController.view addSubview:textField];

    [window addSubview:viewController.view];

    [window makeKeyAndVisible];

	if( err ){
		RuntimeError( err );
	}else{
		ALCdevice *alcDevice=alcOpenDevice( 0 );
		if( !alcDevice ) RuntimeError( "alcOpenDevice failed" );
	
		ALCcontext *alcContext=alcCreateContext( alcDevice,0 );
		if( !alcContext ) RuntimeError( "alcCreateContext failed" );
	
		if( !alcMakeContextCurrent( alcContext ) ) RuntimeError( "alcMakeContextCurrent failed" );
	}
	
	return YES;
}

-(void)applicationWillResignActive:(UIApplication *)application{
	if( !app ) return;
	
	app->InvokeOnSuspend();
//	gc_collect();
}

-(void)applicationDidBecomeActive:(UIApplication *)application{
	if( !app ) return;
	
	app->InvokeOnResume();
//	gc_collect();
}

-(void)applicationDidEnterBackground:(UIApplication *)application{
}

-(void)applicationWillTerminate:(UIApplication *)application{
}

-(void)updateTimerFired{
	if( !app ) return;
	
	int updates=0;
	for(;;){
		app->nextUpdate+=app->updatePeriod;
		
		app->InvokeOnUpdate();
		if( !app->updateRate ) break;
		
		if( app->Time()<app->nextUpdate ) break;
		
		if( ++updates==7 ){
			app->nextUpdate=app->Time();
			break;
		}		
		
//		gc_collect();
	}
	app->InvokeOnRender();
//	gc_collect();
}

-(void)dealloc{
	[window release];
	[view release];
	[super dealloc];
}

@end
