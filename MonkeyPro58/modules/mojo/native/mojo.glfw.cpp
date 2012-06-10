
// GLFW mojo runtime.
//
// Copyright 2011 Mark Sibly, all rights reserved.
// No warranty implied; use at your own risk.

class gxtkApp;
class gxtkGraphics;
class gxtkSurface;
class gxtkInput;
class gxtkAudio;
class gxtkSample;

#define KEY_LMB 1
#define KEY_RMB 2
#define KEY_MMB 3
#define KEY_TOUCH0 0x180

//Forward refs to data functions.
unsigned char *loadImage( String path,int *width,int *height,int *depth );
void unloadImage( unsigned char *image );
FILE *fopenFile( String path,const char *mode );

//for reading WAV file...
const char *ReadTag( FILE *f ){
	static char buf[8];
	if( fread( buf,4,1,f )!=1 ) return "";
	buf[4]=0;
	return buf;
}

int ReadInt( FILE *f ){
	unsigned char buf[4];
	if( fread( buf,4,1,f )!=1 ) return -1;
	return (buf[3]<<24) | (buf[2]<<16) | (buf[1]<<8) | buf[0];
}

int ReadShort( FILE *f ){
	unsigned char buf[2];
	if( fread( buf,2,1,f )!=1 ) return -1;
	return (buf[1]<<8) | buf[0];
}

void SkipBytes( int n,FILE *f ){
	char *p=(char*)malloc( n );
	fread( p,n,1,f );
	free(p);
}

enum{
	VKEY_BACKSPACE=8,VKEY_TAB,
	VKEY_ENTER=13,
	VKEY_SHIFT=16,
	VKEY_CONTROL=17,
	VKEY_ESC=27,
	VKEY_SPACE=32,
	VKEY_PAGEUP=33,VKEY_PAGEDOWN,VKEY_END,VKEY_HOME,
	VKEY_LEFT=37,VKEY_UP,VKEY_RIGHT,VKEY_DOWN,
	VKEY_INSERT=45,VKEY_DELETE,
	VKEY_0=48,VKEY_1,VKEY_2,VKEY_3,VKEY_4,VKEY_5,VKEY_6,VKEY_7,VKEY_8,VKEY_9,
	VKEY_A=65,VKEY_B,VKEY_C,VKEY_D,VKEY_E,VKEY_F,VKEY_G,VKEY_H,VKEY_I,VKEY_J,
	VKEY_K,VKEY_L,VKEY_M,VKEY_N,VKEY_O,VKEY_P,VKEY_Q,VKEY_R,VKEY_S,VKEY_T,
	VKEY_U,VKEY_V,VKEY_W,VKEY_X,VKEY_Y,VKEY_Z,
	
	VKEY_LSYS=91,VKEY_RSYS,
	
	VKEY_NUM0=96,VKEY_NUM1,VKEY_NUM2,VKEY_NUM3,VKEY_NUM4,
	VKEY_NUM5,VKEY_NUM6,VKEY_NUM7,VKEY_NUM8,VKEY_NUM9,
	VKEY_NUMMULTIPLY=106,VKEY_NUMADD,VKEY_NUMSLASH,
	VKEY_NUMSUBTRACT,VKEY_NUMDECIMAL,VKEY_NUMDIVIDE,

	VKEY_F1=112,VKEY_F2,VKEY_F3,VKEY_F4,VKEY_F5,VKEY_F6,
	VKEY_F7,VKEY_F8,VKEY_F9,VKEY_F10,VKEY_F11,VKEY_F12,

	VKEY_LSHIFT=160,VKEY_RSHIFT,
	VKEY_LCONTROL=162,VKEY_RCONTROL,
	VKEY_LALT=164,VKEY_RALT,

	VKEY_TILDE=192,VKEY_MINUS=189,VKEY_EQUALS=187,
	VKEY_OPENBRACKET=219,VKEY_BACKSLASH=220,VKEY_CLOSEBRACKET=221,
	VKEY_SEMICOLON=186,VKEY_QUOTES=222,
	VKEY_COMMA=188,VKEY_PERIOD=190,VKEY_SLASH=191
};

//glfw key to monkey key!
int TransKey( int key ){

	if( key>='0' && key<='9' ) return key;
	if( key>='A' && key<='Z' ) return key;

	switch( key ){

	case ' ':return VKEY_SPACE;
	case ';':return VKEY_SEMICOLON;
	case '=':return VKEY_EQUALS;
	case ',':return VKEY_COMMA;
	case '-':return VKEY_MINUS;
	case '.':return VKEY_PERIOD;
	case '/':return VKEY_SLASH;
	case '~':return VKEY_TILDE;
	case '[':return VKEY_OPENBRACKET;
	case ']':return VKEY_CLOSEBRACKET;
	case '\"':return VKEY_QUOTES;
	case '\\':return VKEY_BACKSLASH;
	
	case GLFW_KEY_LSHIFT:return VKEY_LSHIFT;
	case GLFW_KEY_RSHIFT:return VKEY_RSHIFT;
	case GLFW_KEY_LCTRL:return VKEY_LCONTROL;
	case GLFW_KEY_RCTRL:return VKEY_RCONTROL;
	
	case GLFW_KEY_BACKSPACE:return VKEY_BACKSPACE;
	case GLFW_KEY_TAB:return VKEY_TAB;
	case GLFW_KEY_ENTER:return VKEY_ENTER;
	case GLFW_KEY_ESC:return VKEY_ESC;
	case GLFW_KEY_INSERT:return VKEY_INSERT;
	case GLFW_KEY_DEL:return VKEY_DELETE;
	case GLFW_KEY_PAGEUP:return VKEY_PAGEUP;
	case GLFW_KEY_PAGEDOWN:return VKEY_PAGEDOWN;
	case GLFW_KEY_HOME:return VKEY_HOME;
	case GLFW_KEY_END:return VKEY_END;
	case GLFW_KEY_UP:return VKEY_UP;
	case GLFW_KEY_DOWN:return VKEY_DOWN;
	case GLFW_KEY_LEFT:return VKEY_LEFT;
	case GLFW_KEY_RIGHT:return VKEY_RIGHT;
	
	case GLFW_KEY_F1:return VKEY_F1;
	case GLFW_KEY_F2:return VKEY_F2;
	case GLFW_KEY_F3:return VKEY_F3;
	case GLFW_KEY_F4:return VKEY_F4;
	case GLFW_KEY_F5:return VKEY_F5;
	case GLFW_KEY_F6:return VKEY_F6;
	case GLFW_KEY_F7:return VKEY_F7;
	case GLFW_KEY_F8:return VKEY_F8;
	case GLFW_KEY_F9:return VKEY_F9;
	case GLFW_KEY_F10:return VKEY_F10;
	case GLFW_KEY_F11:return VKEY_F11;
	case GLFW_KEY_F12:return VKEY_F12;
	}
	return 0;
}

//monkey key to special monkey char
int KeyToChar( int key ){
	switch( key ){
	case VKEY_BACKSPACE:
	case VKEY_TAB:
	case VKEY_ENTER:
	case VKEY_ESC:
		return key;
	case VKEY_PAGEUP:
	case VKEY_PAGEDOWN:
	case VKEY_END:
	case VKEY_HOME:
	case VKEY_LEFT:
	case VKEY_UP:
	case VKEY_RIGHT:
	case VKEY_DOWN:
	case VKEY_INSERT:
		return key | 0x10000;
	case VKEY_DELETE:
		return 127;
	}
	return 0;
}

gxtkApp *app;

class gxtkObject : public Object{
public:
};

class gxtkApp : public gxtkObject{
public:
	gxtkGraphics *graphics;
	gxtkInput *input;
	gxtkAudio *audio;
	
	int updateRate;
	double nextUpdate;
	double updatePeriod;
	
	bool suspended;
	
	gxtkApp();
	
	void Run();
	
	static void GLFWCALL OnWindowRefresh();
	static void GLFWCALL OnWindowSize( int width,int height );
	static void GLFWCALL OnKey( int key,int action );
	static void GLFWCALL OnChar( int chr,int action );
	static void GLFWCALL OnMouseButton( int button,int action );
	
	void InvokeOnCreate();
	void InvokeOnSuspend();
	void InvokeOnResume();
	void InvokeOnUpdate();
	void InvokeOnRender();
	
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
	virtual int OnSuspend();
	virtual int OnResume();
	
	virtual int OnUpdate();
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
	glOrtho( 0,width,height,0,-1,1 );
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
	width=height=0;
	glfwGetWindowSize( &width,&height );
	return width>0 && height>0;
}

void gxtkGraphics::EndRender(){
	if( mode ) Flush();
	glfwSwapBuffers();
}

#ifndef GL_CLAMP_TO_EDGE
#define GL_CLAMP_TO_EDGE 0x812f
#endif

#ifndef GL_GENERATE_MIPMAP
#define GL_GENERATE_MIPMAP 0x8191
#endif

int Pow2Size( int n ){
	int i=1;
	while( i<n ) i*=2;
	return i;
}

gxtkSurface *gxtkGraphics::LoadSurface( String path ){

	int width,height,depth;
	unsigned char *data=loadImage( path,&width,&height,&depth );
	if( !data ) return 0;
	
	unsigned char *p=data;
	int n=width*height,fmt=0;
	
	switch( depth ){
	case 1:
		fmt=GL_LUMINANCE;
		break;
	case 2:
		while( n-- ){	//premultiply alpha
			p[0]=p[0]*p[1]/255;
			p+=2;
		}
		fmt=GL_LUMINANCE_ALPHA;
		break;
	case 3:
		fmt=GL_RGB;
		break;
	case 4:
		while( n-- ){	//premultiply alpha
			p[0]=p[0]*p[3]/255;
			p[1]=p[1]*p[3]/255;
			p[2]=p[2]*p[3]/255;
			p+=4;
		}
		fmt=GL_RGBA;
		break;
	default:
		unloadImage( data );
		return 0;
	}
	
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

	int texwidth=width,texheight=height;
	glTexImage2D( GL_TEXTURE_2D,0,fmt,texwidth,texheight,0,fmt,GL_UNSIGNED_BYTE,0 );
	if( glGetError()!=GL_NO_ERROR ){
		texwidth=Pow2Size( width );
		texheight=Pow2Size( height );
		glTexImage2D( GL_TEXTURE_2D,0,fmt,texwidth,texheight,0,fmt,GL_UNSIGNED_BYTE,0 );
		if( glGetError()!=GL_NO_ERROR ){
			glDeleteTextures( 1,&texture );
			unloadImage( data );
			return 0;
		}
	}
	
	glPixelStorei( GL_UNPACK_ALIGNMENT,1 );
	
	glTexSubImage2D( GL_TEXTURE_2D,0,0,0,width,height,fmt,GL_UNSIGNED_BYTE,data );
	
	unloadImage( data );

	return new gxtkSurface( texture,width,height,1.0f/texwidth,1.0f/texheight );
}

// ***** End of graphics ******

class gxtkInput : public gxtkObject{
public:
	int keyStates[512];
	int charQueue[32];
	int charPut,charGet;
	float mouseX,mouseY;
	
	float joyPos[6];
	int joyButton[32];
	
	gxtkInput();
	~gxtkInput(){
//		Print( "~gxtkInput" );
	}
	
	void BeginUpdate();
	void EndUpdate();
	
	void OnKeyDown( int key );
	void OnKeyUp( int key );
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
	gxtkChannel channels[33];

	gxtkAudio();

	void mark();
	void OnSuspend();
	void OnResume();

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

	gxtkSample(){}
	gxtkSample( ALuint buf );
	~gxtkSample();
	
	//***** GXTK API *****
	virtual int Discard();
};

//***** gxtkApp *****

int RunApp(){
	app->Run();
	return 0;
}

gxtkApp::gxtkApp(){
	app=this;

	graphics=new gxtkGraphics;
	input=new gxtkInput;
	audio=new gxtkAudio;

	updateRate=0;
	suspended=false;

	runner=RunApp;
}

void gxtkApp::Run(){

	glfwEnable( GLFW_KEY_REPEAT );
	glfwDisable( GLFW_AUTO_POLL_EVENTS );

	glfwSetKeyCallback( OnKey );
	glfwSetCharCallback( OnChar );
	glfwSetWindowSizeCallback( OnWindowSize );
	glfwSetWindowRefreshCallback( OnWindowRefresh );
	glfwSetMouseButtonCallback( OnMouseButton );

	InvokeOnCreate();
	InvokeOnRender();

	while( glfwGetWindowParam( GLFW_OPENED ) ){
	
		if( glfwGetWindowParam( GLFW_ICONIFIED ) ){
			if( !suspended ){
				InvokeOnSuspend();
				continue;
			}
		}else if( glfwGetWindowParam( GLFW_ACTIVE ) ){
			if( suspended ){
				InvokeOnResume();
				continue;
			}
		}else if( CFG_MOJO_AUTO_SUSPEND_ENABLED ){
			if( !suspended ){
				InvokeOnSuspend();
				continue;
			}
		}
	
		if( !updateRate || suspended ){
			InvokeOnRender();
			glfwWaitEvents();
			continue;
		}
		
		float time=glfwGetTime();
		if( time<nextUpdate ){
			glfwSleep( nextUpdate-time );
			continue;
		}

		glfwPollEvents();
				
		int updates=0;
		for(;;){
			nextUpdate+=updatePeriod;
			
			InvokeOnUpdate();
			if( !updateRate ) break;
			
			if( nextUpdate>glfwGetTime() ){
				break;
			}
			
			if( ++updates==7 ){
				nextUpdate=glfwGetTime();
				break;
			}
		}
		InvokeOnRender();
	}
}

void gxtkApp::OnWindowSize( int width,int height ){
//	Print( "OnWindowSize!" );
//	if( width>0 && height>0 ){
//		app->InvokeOnResume();
//	}else{
//		app->InvokeOnSuspend();
//	}
}

void gxtkApp::OnWindowRefresh(){
//	Print( "OnWindowRefresh!" );
//	app->InvokeOnRender();
}

void gxtkApp::OnMouseButton( int button,int action ){
	int key;
	switch( button ){
	case GLFW_MOUSE_BUTTON_LEFT:key=KEY_LMB;break;
	case GLFW_MOUSE_BUTTON_RIGHT:key=KEY_RMB;break;
	case GLFW_MOUSE_BUTTON_MIDDLE:key=KEY_MMB;break;
	default:return;
	}
	switch( action ){
	case GLFW_PRESS:
		app->input->OnKeyDown( key );
		break;
	case GLFW_RELEASE:
		app->input->OnKeyUp( key );
		break;
	}
}

void gxtkApp::OnKey( int key,int action ){

	key=TransKey( key );
	if( !key ) return;
	
	switch( action ){
	case GLFW_PRESS:
		app->input->OnKeyDown( key );
		
		if( int chr=KeyToChar( key ) ){
			app->input->PutChar( chr );
		}
		
		break;
	case GLFW_RELEASE:
		app->input->OnKeyUp( key );
		break;
	}
}

void gxtkApp::OnChar( int chr,int action ){

	switch( action ){
	case GLFW_PRESS:
		app->input->PutChar( chr );
		break;
	}
}

void gxtkApp::InvokeOnCreate(){
	if( !graphics->Validate() ) abort();
	
	OnCreate();
	
	gc_collect();
}

void gxtkApp::InvokeOnSuspend(){
	if( suspended ) return;
	
	suspended=true;
	OnSuspend();
	audio->OnSuspend();
	if( updateRate ){
		int upr=updateRate;
		SetUpdateRate( 0 );
		updateRate=upr;
	}
	
	gc_collect();
}

void gxtkApp::InvokeOnResume(){
	if( !suspended ) return;
	
	if( updateRate ){
		int upr=updateRate;
		updateRate=0;
		SetUpdateRate( upr );
	}
	audio->OnResume();
	OnResume();
	suspended=false;
	
	gc_collect();
}

void gxtkApp::InvokeOnUpdate(){
	if( suspended || !updateRate || !graphics->Validate() ) return;
	
	input->BeginUpdate();
	OnUpdate();
	input->EndUpdate();
	
	gc_collect();
}

void gxtkApp::InvokeOnRender(){
	if( suspended || !graphics->Validate() ) return;
	
	graphics->BeginRender();
	OnRender();
	graphics->EndRender();
	
	gc_collect();
}

//***** GXTK API *****

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
	if( FILE *fp=fopen( ".monkeystate","rb" ) ){
		String str=String::Load( fp );
		fclose( fp );
		return str;
	}
	return "";
}

int gxtkApp::SaveState( String state ){
	if( FILE *fp=fopen( ".monkeystate","wb" ) ){
		bool ok=state.Save( fp );
		fclose( fp );
		return ok ? 0 : -2;
	}
	return -1;
}

String gxtkApp::LoadString( String path ){
	if( FILE *fp=fopenFile( path,"rb" ) ){
		String str=String::Load( fp );
		fclose( fp );
		return str;
	}
	return "";
}

int gxtkApp::SetUpdateRate( int hertz ){
	updateRate=hertz;

	if( updateRate ){
		updatePeriod=1.0/updateRate;
		nextUpdate=glfwGetTime()+updatePeriod;
	}
	return 0;
}

int gxtkApp::MilliSecs(){
	return glfwGetTime()*1000.0;
}

int gxtkApp::Loading(){
	return 0;
}

int gxtkApp::OnCreate(){
	return 0;
}

int gxtkApp::OnSuspend(){
	return 0;
}

int gxtkApp::OnResume(){
	return 0;
}

int gxtkApp::OnUpdate(){
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
	memset( charQueue,0,sizeof(charQueue) );
	mouseX=mouseY=0;
	charPut=charGet=0;
	
}

void gxtkInput::BeginUpdate(){

	int x=0,y=0;
	glfwGetMousePos( &x,&y );
	mouseX=x;
	mouseY=y;
	
	int n_axes=glfwGetJoystickParam( GLFW_JOYSTICK_1,GLFW_AXES );
	int n_buttons=glfwGetJoystickParam( GLFW_JOYSTICK_1,GLFW_BUTTONS );

//	printf( "n_axes=%i, n_buttons=%i\n",n_axes,n_buttons );fflush( stdout );
	
	memset( joyPos,0,sizeof(joyPos) );	
	glfwGetJoystickPos( GLFW_JOYSTICK_1,joyPos,n_axes );
	
	unsigned char buttons[32];
	memset( buttons,0,sizeof(buttons) );
	glfwGetJoystickButtons( GLFW_JOYSTICK_1,buttons,n_buttons );

	float t;
	switch( n_axes ){
	case 4:	//my saitek...axes=4, buttons=14
		joyPos[4]=joyPos[2];
		joyPos[3]=joyPos[3];
		joyPos[2]=0;
		break;
	case 5:	//xbox360...axes=5, buttons=10
		t=joyPos[3];
		joyPos[3]=joyPos[4];
		joyPos[4]=t;
		break;
	}
	
	for( int i=0;i<n_buttons;++i ){
		if( buttons[i]==GLFW_PRESS ){
			OnKeyDown( 256+i );
		}else{
			OnKeyUp( 256+i );
		}
	}
}

void gxtkInput::EndUpdate(){
	for( int i=0;i<512;++i ){
		keyStates[i]&=0x100;
	}
	charGet=0;
	charPut=0;
}

void gxtkInput::OnKeyDown( int key ){
	if( keyStates[key] & 0x100 ) return;
	
	keyStates[key]|=0x100;
	++keyStates[key];
	
	switch( key ){
	case VKEY_LSHIFT:case VKEY_RSHIFT:
		if( (keyStates[VKEY_LSHIFT]&0x100) || (keyStates[VKEY_RSHIFT]&0x100) ) OnKeyDown( VKEY_SHIFT );
		break;
	case VKEY_LCONTROL:case VKEY_RCONTROL:
		if( (keyStates[VKEY_LCONTROL]&0x100) || (keyStates[VKEY_RCONTROL]&0x100) ) OnKeyDown( VKEY_CONTROL );
		break;
	}
}

void gxtkInput::OnKeyUp( int key ){
	if( !(keyStates[key] & 0x100) ) return;

	keyStates[key]&=0xff;
	
	switch( key ){
	case VKEY_LSHIFT:case VKEY_RSHIFT:
		if( !(keyStates[VKEY_LSHIFT]&0x100) && !(keyStates[VKEY_RSHIFT]&0x100) ) OnKeyUp( VKEY_SHIFT );
		break;
	case VKEY_LCONTROL:case VKEY_RCONTROL:
		if( !(keyStates[VKEY_LCONTROL]&0x100) && !(keyStates[VKEY_RCONTROL]&0x100) ) OnKeyUp( VKEY_CONTROL );
		break;
	}
}

void gxtkInput::PutChar( int chr ){
	if( charPut<32 ) charQueue[charPut++]=chr;
}

//***** GXTK API *****

int gxtkInput::SetKeyboardEnabled( int enabled ){
	return 0;
}

int gxtkInput::KeyDown( int key ){
	if( key>0 && key<512 ){
		if( key==KEY_TOUCH0 ) key=KEY_LMB;
		return keyStates[key] >> 8;
	}
	return 0;
}

int gxtkInput::KeyHit( int key ){
	if( key>0 && key<512 ){
		if( key==KEY_TOUCH0 ) key=KEY_LMB;
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
	return mouseX;
}

float gxtkInput::MouseY(){
	return mouseY;
}

float gxtkInput::JoyX( int index ){
	switch( index ){
	case 0:return joyPos[0];
	case 1:return joyPos[3];
	}
	return 0;
}

float gxtkInput::JoyY( int index ){
	switch( index ){
	case 0:return joyPos[1];
	case 1:return -joyPos[4];
	}
	return 0;
}

float gxtkInput::JoyZ( int index ){
	switch( index ){
	case 0:return joyPos[2];
	case 1:return joyPos[5];
	}
	return 0;
}

float gxtkInput::TouchX( int index ){
	return mouseX;
}

float gxtkInput::TouchY( int index ){
	return mouseY;
}

float gxtkInput::AccelX(){
	return 0;
}

float gxtkInput::AccelY(){
	return 0;
}

float gxtkInput::AccelZ(){
	return 0;
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

gxtkAudio::gxtkAudio(){
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
	
	if( FILE *f=fopenFile( path,"rb" ) ){
		if( !strcmp( ReadTag( f ),"RIFF" ) ){
			int len=ReadInt( f )-8;len=len;
			if( !strcmp( ReadTag( f ),"WAVE" ) ){
				if( !strcmp( ReadTag( f ),"fmt " ) ){
					int len2=ReadInt( f );
					int comp=ReadShort( f );
					if( comp==1 ){
						int chans=ReadShort( f );
						int hertz=ReadInt( f );
						int bytespersec=ReadInt( f );bytespersec=bytespersec;
						int pad=ReadShort( f );pad=pad;
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
									ALuint al_buffer;
									alGenBuffers( 1,&al_buffer );
									alBufferData( al_buffer,format,data,size,hertz );
									free( data );
									return new gxtkSample( al_buffer );
								}
								free( data );
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
		if( state==AL_STOPPED ) chan->state=0;
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

int gxtkAudio::PlayMusic( String path,int flags ){
	StopMusic();
	
	gxtkSample *music=LoadSample( path );
	if( !music ) return -1;
	
	PlaySample( music,32,flags );
	return 0;
}

int gxtkAudio::StopMusic(){
	StopChannel( 32 );
	return 0;
}

int gxtkAudio::PauseMusic(){
	PauseChannel( 32 );
	return 0;
}

int gxtkAudio::ResumeMusic(){
	ResumeChannel( 32 );
	return 0;
}

int gxtkAudio::MusicState(){
	return ChannelState( 32 );
}

int gxtkAudio::SetMusicVolume( float volume ){
	SetVolume( 32,volume );
	return 0;
}

//***** gxtkSample *****

gxtkSample::gxtkSample( ALuint buf ):al_buffer(buf){
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
