
#import "main.h"

//${CONFIG_BEGIN}
#define CFG_ANDROID_APP_LABEL DaffyDrop
#define CFG_ANDROID_APP_PACKAGE com.coragames.daffydrop
#define CFG_ANDROID_NATIVE_GL_ENABLED true
#define CFG_CONFIG release
#define CFG_CPP_INCREMENTAL_GC 1
#define CFG_GLFW_WINDOW_HEIGHT 720
#define CFG_GLFW_WINDOW_WIDTH 480
#define CFG_HOST macos
#define CFG_IMAGE_FILES *.png|*.jpg
#define CFG_IOS_ACCELEROMETER_ENABLED false
#define CFG_IOS_DISPLAY_LINK_ENABLED true
#define CFG_IOS_RETINA_ENABLED true
#define CFG_LANG cpp
#define CFG_MOJO_IMAGE_FILTERING_ENABLED true
#define CFG_MUSIC_FILES *.wav|*.mp3|*.m4a
#define CFG_OPENGL_DEPTH_BUFFER_ENABLED false
#define CFG_OPENGL_GLES20_ENABLED false
#define CFG_PARSER_FUNC_ATTRS 0
#define CFG_SOUND_FILES *.wav|*.mp3|*.m4a
#define CFG_TARGET ios
#define CFG_TEXT_FILES *.txt|*.xml|*.json
//${CONFIG_END}

@implementation MonkeyView

+(Class)layerClass{
	return [CAEAGLLayer class];
}

-(id)initWithCoder:(NSCoder*)coder{

	defaultFramebuffer=0;
	colorRenderbuffer=0;
	depthRenderbuffer=0;

	if( self=[super initWithCoder:coder] ){
	
		// Enable retina display
		if( CFG_IOS_RETINA_ENABLED ){
			if( [self respondsToSelector:@selector(contentScaleFactor)] ){
				float scaleFactor=[[UIScreen mainScreen] scale];
				[self setContentScaleFactor:scaleFactor];
			}
		}
    
		// Get the layer
		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		      
		eaglLayer.opaque=TRUE;
		eaglLayer.drawableProperties=[NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool:FALSE],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat,nil];
		
		if( CFG_OPENGL_GLES20_ENABLED ){
			context=[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
			if( !context || ![EAGLContext setCurrentContext:context] ) exit(-1);
			
			glGenFramebuffers( 1,&defaultFramebuffer );
			glBindFramebuffer( GL_FRAMEBUFFER,defaultFramebuffer );
			glGenRenderbuffers( 1,&colorRenderbuffer );
			glBindRenderbuffer( GL_RENDERBUFFER,colorRenderbuffer );
			glFramebufferRenderbuffer( GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_RENDERBUFFER,colorRenderbuffer );
			if( CFG_OPENGL_DEPTH_BUFFER_ENABLED ){
				glGenRenderbuffers( 1,&depthRenderbuffer );
				glBindRenderbuffer( GL_RENDERBUFFER,depthRenderbuffer );
				glFramebufferRenderbuffer( GL_FRAMEBUFFER,GL_DEPTH_ATTACHMENT,GL_RENDERBUFFER,depthRenderbuffer );
				glBindRenderbuffer( GL_RENDERBUFFER,colorRenderbuffer );
			}
		}else{
			context=[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
			if( !context || ![EAGLContext setCurrentContext:context] ) exit(-1);

			glGenFramebuffersOES( 1,&defaultFramebuffer );
			glBindFramebufferOES( GL_FRAMEBUFFER_OES,defaultFramebuffer );
			glGenRenderbuffersOES( 1,&colorRenderbuffer );
			glBindRenderbufferOES( GL_RENDERBUFFER_OES,colorRenderbuffer );
			glFramebufferRenderbufferOES( GL_FRAMEBUFFER_OES,GL_COLOR_ATTACHMENT0_OES,GL_RENDERBUFFER_OES,colorRenderbuffer );
			if( CFG_OPENGL_DEPTH_BUFFER_ENABLED ){
				glGenRenderbuffersOES( 1,&depthRenderbuffer );
				glBindRenderbufferOES( GL_RENDERBUFFER_OES,depthRenderbuffer );
				glFramebufferRenderbufferOES( GL_FRAMEBUFFER_OES,GL_DEPTH_ATTACHMENT_OES,GL_RENDERBUFFER_OES,depthRenderbuffer );
				glBindRenderbufferOES( GL_RENDERBUFFER_OES,colorRenderbuffer );
			}
		}
	}
	return self;
}

-(void)drawView:(id)sender{
	MonkeyAppDelegate *delegate=(MonkeyAppDelegate*) [[UIApplication sharedApplication] delegate];
	[delegate drawView:self];
}

-(void)presentRenderbuffer{
	if( CFG_OPENGL_GLES20_ENABLED ){
		[context presentRenderbuffer:GL_RENDERBUFFER];
	}else{
		[context presentRenderbuffer:GL_RENDERBUFFER_OES];
	}
}

-(BOOL)resizeFromLayer:(CAEAGLLayer *)layer{

	// Allocate color buffer backing based on the current layer size
	if( CFG_OPENGL_GLES20_ENABLED ){
	
		glBindRenderbuffer( GL_RENDERBUFFER,colorRenderbuffer );
		[context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
		glGetRenderbufferParameteriv( GL_RENDERBUFFER,GL_RENDERBUFFER_WIDTH,&backingWidth );
		glGetRenderbufferParameteriv( GL_RENDERBUFFER,GL_RENDERBUFFER_HEIGHT,&backingHeight );
		if( CFG_OPENGL_DEPTH_BUFFER_ENABLED ){
			glBindRenderbuffer( GL_RENDERBUFFER,depthRenderbuffer );
			glRenderbufferStorage( GL_RENDERBUFFER,GL_DEPTH_COMPONENT16,backingWidth,backingHeight );
			glBindRenderbuffer( GL_RENDERBUFFER,colorRenderbuffer );
		}
		if( glCheckFramebufferStatus( GL_FRAMEBUFFER )!=GL_FRAMEBUFFER_COMPLETE ) exit(-1);
		
	}else{
	
		glBindRenderbufferOES( GL_RENDERBUFFER_OES,colorRenderbuffer );
		[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
		glGetRenderbufferParameterivOES( GL_RENDERBUFFER_OES,GL_RENDERBUFFER_WIDTH_OES,&backingWidth );
		glGetRenderbufferParameterivOES( GL_RENDERBUFFER_OES,GL_RENDERBUFFER_HEIGHT_OES,&backingHeight );
		if( CFG_OPENGL_DEPTH_BUFFER_ENABLED ){
			glBindRenderbufferOES( GL_RENDERBUFFER_OES,depthRenderbuffer );
			glRenderbufferStorageOES( GL_RENDERBUFFER_OES,GL_DEPTH_COMPONENT16_OES,backingWidth,backingHeight );
			glBindRenderbufferOES( GL_RENDERBUFFER_OES,colorRenderbuffer );
		}
		if( glCheckFramebufferStatusOES( GL_FRAMEBUFFER_OES )!=GL_FRAMEBUFFER_COMPLETE_OES ) exit(-1);
		
	}
    
	return YES;
}

-(void)layoutSubviews{
	[self resizeFromLayer:(CAEAGLLayer*)self.layer];
	
	[self drawView:nil];
}

-(void)dealloc{
	if( CFG_OPENGL_GLES20_ENABLED ){
		glDeleteFramebuffers( 1,&defaultFramebuffer );
		glDeleteRenderbuffers( 1,&colorRenderbuffer );
		if( depthRenderbuffer ) glDeleteRenderbuffers( 1,&depthRenderbuffer );
		if( [EAGLContext currentContext]==context ) [EAGLContext setCurrentContext:nil];
		[context release];
	}else{
		glDeleteFramebuffersOES( 1,&defaultFramebuffer );
		glDeleteRenderbuffersOES( 1,&colorRenderbuffer );
		if( depthRenderbuffer ) glDeleteRenderbuffersOES( 1,&depthRenderbuffer );
		if( [EAGLContext currentContext]==context ) [EAGLContext setCurrentContext:nil];
		[context release];
	}
	[super dealloc];
}

@end

@implementation MonkeyWindow

/*
-(void)sendEvent:(UIEvent*)event{
	[super sendEvent:event];
	MonkeyAppDelegate *delegate=(MonkeyAppDelegate*)[[UIApplication sharedApplication] delegate];
	[delegate onEvent:event];
}
*/

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
	MonkeyAppDelegate *delegate=(MonkeyAppDelegate*)[[UIApplication sharedApplication] delegate];
	[delegate onEvent:event];
}

-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event{
	MonkeyAppDelegate *delegate=(MonkeyAppDelegate*)[[UIApplication sharedApplication] delegate];
	[delegate onEvent:event];
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event{
	MonkeyAppDelegate *delegate=(MonkeyAppDelegate*)[[UIApplication sharedApplication] delegate];
	[delegate onEvent:event];
}

-(void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event{
	MonkeyAppDelegate *delegate=(MonkeyAppDelegate*)[[UIApplication sharedApplication] delegate];
	[delegate onEvent:event];
}

@end

@implementation MonkeyViewController

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{

	CFArrayRef array=(CFArrayRef)CFBundleGetValueForInfoDictionaryKey( CFBundleGetMainBundle(),CFSTR("UISupportedInterfaceOrientations") );
	if( !array ) return NO;
	
	CFRange range={ 0,CFArrayGetCount( array ) };

	switch( interfaceOrientation ){
	case UIInterfaceOrientationPortrait:
		return CFArrayContainsValue( array,range,CFSTR("UIInterfaceOrientationPortrait") );
	case UIInterfaceOrientationPortraitUpsideDown:
		return CFArrayContainsValue( array,range,CFSTR("UIInterfaceOrientationPortraitUpsideDown") );
	case UIInterfaceOrientationLandscapeLeft:
		return CFArrayContainsValue( array,range,CFSTR("UIInterfaceOrientationLandscapeLeft") );
	case UIInterfaceOrientationLandscapeRight:
		return CFArrayContainsValue( array,range,CFSTR("UIInterfaceOrientationLandscapeRight") );
	}
	return NO;
}

@end


//***** MONKEY CODE GOES HERE! *****

//${TRANSCODE_BEGIN}

// C++ Monkey runtime.
//
// Placed into the public domain 24/02/2011.
// No warranty implied; use at your own risk.

//***** Monkey Types *****

typedef wchar_t Char;
template<class T> class Array;
class String;
class Object;

#if CFG_CPP_DOUBLE_PRECISION_FLOATS
typedef double Float;
#define FLOAT(X) X
#else
typedef float Float;
#define FLOAT(X) X##f
#endif

//***** GC Config *****

#if CFG_CPP_DEBUG_GC
#define DEBUG_GC 1
#if __APPLE__
#define DEBUG_GC_MAC 1
#elif defined( __glfw_h_ )
#define DEBUG_GC_GLFW 1
#else
#undef DEBUG_GC
#endif
#endif

// ***** GC *****

#if DEBUG_GC_MAC
#include <mach/mach_time.h>
int gcMicros(){
	static uint64_t startTime;
	static mach_timebase_info_data_t timeInfo;
	if( !startTime ){
		startTime=mach_absolute_time();
		mach_timebase_info( &timeInfo );
	}
	uint64_t nanos=mach_absolute_time()-startTime;
	nanos*=timeInfo.numer;
	nanos/=timeInfo.denom;
	return nanos/1000L;
}
#endif

#if DEBUG_GC_GLFW
int gcMicros(){
	return glfwGetTime()*1000000;
}
#endif

struct gc_object;

gc_object *gc_malloc( int size );
void gc_free( gc_object *p );

struct gc_object{
	gc_object *succ;
	int flags;
	
	virtual ~gc_object(){
	}
	
	virtual void mark(){
	}

	void *operator new( size_t size ){
		return gc_malloc( size );
	}
	
	void operator delete( void *p ){
		gc_free( (gc_object*)p );
	}
};

//alloced objs
gc_object *gc_objs;

//fast alloc cache
gc_object *gc_cache[8];

//objects allocated
int gc_total;

//objects marked
int gc_marked;

//is object marked flag
int gc_markbit=1;	//toggles 1,2,1,2...

//how much mem alloced
int gc_alloced;
int gc_maxalloced;

//queue of objects to mark
std::vector<gc_object*> gc_mark_queue;

//generated by translator
void gc_mark();
#define gc_mark_roots gc_mark

//void gc_mark_roots();

gc_object *gc_malloc( int size ){
	size=(size+7)&~7;
	
	gc_object *p;
	if( size<64 ){
		if( (p=gc_cache[size>>3]) ){
			gc_cache[size>>3]=p->succ;
		}else{
			p=(gc_object*)malloc( size );
		}
	}else{
		p=(gc_object*)malloc( size );
	}
	
	p->flags=size | (gc_markbit^3);
	p->succ=gc_objs;
	gc_objs=p;

	++gc_total;
	
	gc_alloced+=size;
	if( gc_alloced>gc_maxalloced ) gc_maxalloced=gc_alloced;
	
	return p;
}

void gc_free( gc_object *p ){
	int size=p->flags & ~7;
	if( size<64 ){
		p->succ=gc_cache[size>>3];
		gc_cache[size>>3]=p;
	}else{
		free( p );
	}
	--gc_total;
	gc_alloced-=size;
}

template<class T> void gc_mark( T *t ){

	gc_object *p=dynamic_cast<gc_object*>(t);
	
	if( !p || (p->flags & gc_markbit) ) return;

	p->flags^=3;
	++gc_marked;
	p->mark();
}

template<class T> void gc_mark_q( T *t ){

	gc_object *p=dynamic_cast<gc_object*>(t);
	
	if( !p || (p->flags & gc_markbit) ) return;

	p->flags^=3;
	++gc_marked;
	gc_mark_queue.push_back( p );
}

#if CFG_CPP_INCREMENTAL_GC

template<class T,class V> void gc_assign( T *&lhs,V *rhs ){

	gc_object *p=dynamic_cast<gc_object*>(rhs);

	if( p && !(p->flags & gc_markbit) ){
		p->flags^=3;
		++gc_marked;
		gc_mark_queue.push_back( p );
	}
	lhs=rhs;
}

void gc_collect(){

#if DEBUG_GC
	int us=gcMicros();
#endif

	static int maxalloced;

	int swept=0,c=0;
	
	if( gc_maxalloced>maxalloced ){
		maxalloced=gc_maxalloced;
		c=gc_total;
	}else{
		c=gc_total/10;
	}
	
	int term=gc_marked+c;
	
	while( gc_marked<term ){
	
		if( gc_mark_queue.empty() ){
		
			gc_object **q=&gc_objs;
			
			swept=gc_total;
			
			while( gc_marked!=gc_total ){
				gc_object *p=*q;
				
				while( (p->flags & gc_markbit) ){
					q=&p->succ;
					p=*q;
				}

				*q=p->succ;
				delete p;
			}
			
			swept-=gc_total;
			
			gc_marked=0;

			gc_markbit^=3;
	
			gc_mark_roots();
			
			break;
		}
		
		gc_object *p=gc_mark_queue.back();
		gc_mark_queue.pop_back();
		p->mark();
	}

#if DEBUG_GC
	us=gcMicros()-us;
	printf( "us=%i, swept=%i, objects=%i, memalloced=%i, maxalloced=%i\n",us,swept,gc_total,gc_alloced,gc_maxalloced );
	fflush( stdout );
#endif
}

#else

#define gc_assign( X,Y ) X=Y

void gc_collect(){

#if DEBUG_GC
	int us=gcMicros();
#endif
	
	//mark...

	gc_mark_roots();
	
	while( !gc_mark_queue.empty() ){
		gc_object *p=gc_mark_queue.back();
		gc_mark_queue.pop_back();
		p->mark();
	}
	
	//sweep...
	
	gc_object **q=&gc_objs;
	
	int swept=gc_total;

	while( gc_marked!=gc_total ){
		gc_object *p=*q;
		
		while( (p->flags & gc_markbit) ){
			q=&p->succ;
			p=*q;
		}
		
		*q=p->succ;
		delete p;
	}
	
	swept-=gc_total;
	
	gc_marked=0;
	
	gc_markbit^=3;

#if DEBUG_GC
	us=gcMicros()-us;
	printf( "us=%i, swept=%i, objects=%i, memalloced=%i, maxalloced=%i\n",us,swept,gc_total,gc_alloced,gc_maxalloced );fflush( stdout );
#endif
}

#endif

// ***** Array *****

template<class T> T *t_memcpy( T *dst,const T *src,int n ){
	memcpy( dst,src,n*sizeof(T) );
	return dst+n;
}

template<class T> T *t_memset( T *dst,int val,int n ){
	memset( dst,val,n*sizeof(T) );
	return dst+n;
}

template<class T> int t_memcmp( const T *x,const T *y,int n ){
	return memcmp( x,y,n*sizeof(T) );
}

template<class T> int t_strlen( const T *p ){
	const T *q=p++;
	while( *q++ ){}
	return q-p;
}

template<class T> T *t_create( int n,T *p ){
	t_memset( p,0,n );
	return p+n;
}

template<class T> T *t_create( int n,T *p,const T *q ){
	t_memcpy( p,q,n );
	return p+n;
}

template<class T> void t_destroy( int n,T *p ){
}

//for int, float etc arrays...needs to go before Array<> decl to shut xcode 4.0.2 up.
template<class T> void gc_mark_array( int n,T *p ){
}

template<class T> class Array{
public:
	Array():rep( Rep::alloc(0) ){
	}

	//Use default...
//	Array( const Array<T> &t )...
	
	Array( int length ):rep( Rep::alloc( length ) ){
		t_create( rep->length,rep->data );
	}
	
	Array( const T *p,int length ):rep( Rep::alloc(length) ){
		t_create( rep->length,rep->data,p );
	}
	
	~Array(){
	}

	//Use default...
//	Array &operator=( const Array &t )...
	
	int Length()const{ 
		return rep->length; 
	}
	
	T &At( int index ){
		if( index<0 || index>=rep->length ) throw "Array index out of range";
		return rep->data[index]; 
	}
	
	const T &At( int index )const{
		if( index<0 || index>=rep->length ) throw "Array index out of range";
		return rep->data[index]; 
	}
	
	T &operator[]( int index ){
		return rep->data[index]; 
	}

	const T &operator[]( int index )const{
		return rep->data[index]; 
	}
	
	Array Slice( int from,int term )const{
		int len=rep->length;
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
		if( term<=from ) return Array();
		return Array( rep->data+from,term-from );
	}

	Array Slice( int from )const{
		return Slice( from,rep->length );
	}
	
	Array Resize( int newlen )const{
		if( newlen<=0 ) return Array();
		int n=rep->length;
		if( newlen<n ) n=newlen;
		Rep *p=Rep::alloc( newlen );
		T *q=p->data;
		q=t_create( n,q,rep->data );
		q=t_create( (newlen-n),q );
		return Array( p );
	}

private:
	struct Rep : public gc_object{
		int length;
		T data[0];
		
		Rep():length(0){
			flags=3;
		}
		
		Rep( int length ):length(length){
		}
		
		~Rep(){
			t_destroy( length,data );
		}
		
		void mark(){
			gc_mark_array( length,data );
		}
		
		static Rep *alloc( int length ){
			if( !length ){
				static Rep null;
				return &null;
			}
			void *p=gc_malloc( sizeof(Rep)+length*sizeof(T) );
			return ::new(p) Rep( length );
		}
	};
	Rep *rep;

	template<class C> friend void gc_mark( Array<C> &t );
	template<class C> friend void gc_mark_q( Array<C> &t );

#if CFG_CPP_INCREMENTAL_GC

	template<class C> friend void gc_assign( Array<C> &lhs,Array<C> rhs );
	
#endif

	Array( Rep *rep ):rep(rep){
	}
};

template<class T> void gc_mark( Array<T> &t ){
	gc_mark( t.rep );
}

template<class T> void gc_mark_q( Array<T> &t ){
	gc_mark_q( t.rep );
}

//for object arrays....
template<class T> void gc_mark_array( int n,T **p ){
	for( int i=0;i<n;++i ) gc_mark( p[i] );
}

//for array arrays...
template<class T> void gc_mark_array( int n,Array<T> *p ){
	for( int i=0;i<n;++i ) gc_mark( p[i] );
}

#if CFG_CPP_INCREMENTAL_GC

template<class T> void gc_assign( Array<T> &lhs,Array<T> rhs ){
	gc_mark( rhs.rep );
	lhs=rhs;
}

#endif
		
// ***** String *****

class String{
public:
	String():rep( Rep::alloc(0) ){
	}
	
	String( const String &t ):rep( t.rep ){
		rep->retain();
	}

	String( int n ){
		char buf[256];
		sprintf( buf,"%i",n );
		rep=Rep::alloc( t_strlen(buf) );
		for( int i=0;i<rep->length;++i ) rep->data[i]=buf[i];
	}

	String( Float n ){
		char buf[256];
		
		//would rather use snprintf, but it's doing weird things in MingW.
		//
		sprintf( buf,"%.17lg",n );
		//
		char *p;
		for( p=buf;*p;++p ){
			if( *p=='.' || *p=='e' ) break;
		}
		if( !*p ){
			*p++='.';
			*p++='0';
			*p=0;
		}

		rep=Rep::alloc( t_strlen(buf) );
		for( int i=0;i<rep->length;++i ) rep->data[i]=buf[i];
	}

	String( Char ch,int length ):rep( Rep::alloc(length) ){
		for( int i=0;i<length;++i ) rep->data[i]=ch;
	}

	String( const Char *p ):rep( Rep::alloc(t_strlen(p)) ){
		t_memcpy( rep->data,p,rep->length );
	}

	String( const Char *p,int length ):rep( Rep::alloc(length) ){
		t_memcpy( rep->data,p,rep->length );
	}
	
#if __OBJC__	
	String( NSString *nsstr ):rep( Rep::alloc([nsstr length]) ){
		unichar *buf=(unichar*)malloc( rep->length * sizeof(unichar) );
		[nsstr getCharacters:buf range:NSMakeRange(0,rep->length)];
		for( int i=0;i<rep->length;++i ) rep->data[i]=buf[i];
		free( buf );
	}
#endif

	~String(){
		rep->release();
	}
	
	template<class C> String( const C *p ):rep( Rep::alloc(t_strlen(p)) ){
		for( int i=0;i<rep->length;++i ) rep->data[i]=p[i];
	}
	
	template<class C> String( const C *p,int length ):rep( Rep::alloc(length) ){
		for( int i=0;i<rep->length;++i ) rep->data[i]=p[i];
	}
	
	int Length()const{
		return rep->length;
	}
	
	const Char *Data()const{
		return rep->data;
	}
	
	Char operator[]( int index )const{
		return rep->data[index];
	}
	
	String &operator=( const String &t ){
		t.rep->retain();
		rep->release();
		rep=t.rep;
		return *this;
	}
	
	String &operator+=( const String &t ){
		return operator=( *this+t );
	}
	
	int Compare( const String &t )const{
		int n=rep->length<t.rep->length ? rep->length : t.rep->length;
		for( int i=0;i<n;++i ){
			if( int q=(int)(rep->data[i])-(int)(t.rep->data[i]) ) return q;
		}
		return rep->length-t.rep->length;
	}
	
	bool operator==( const String &t )const{
		return rep->length==t.rep->length && t_memcmp( rep->data,t.rep->data,rep->length )==0;
	}
	
	bool operator!=( const String &t )const{
		return rep->length!=t.rep->length || t_memcmp( rep->data,t.rep->data,rep->length )!=0;
	}
	
	bool operator<( const String &t )const{
		return Compare( t )<0;
	}
	
	bool operator<=( const String &t )const{
		return Compare( t )<=0;
	}
	
	bool operator>( const String &t )const{
		return Compare( t )>0;
	}
	
	bool operator>=( const String &t )const{
		return Compare( t )>=0;
	}
	
	String operator+( const String &t )const{
		if( !rep->length ) return t;
		if( !t.rep->length ) return *this;
		Rep *p=Rep::alloc( rep->length+t.rep->length );
		Char *q=p->data;
		q=t_memcpy( q,rep->data,rep->length );
		q=t_memcpy( q,t.rep->data,t.rep->length );
		return String( p );
	}
	
	int Find( String find,int start=0 )const{
		if( start<0 ) start=0;
		while( start+find.rep->length<=rep->length ){
			if( !t_memcmp( rep->data+start,find.rep->data,find.rep->length ) ) return start;
			++start;
		}
		return -1;
	}
	
	int FindLast( String find )const{
		int start=rep->length-find.rep->length;
		while( start>=0 ){
			if( !t_memcmp( rep->data+start,find.rep->data,find.rep->length ) ) return start;
			--start;
		}
		return -1;
	}
	
	int FindLast( String find,int start )const{
		if( start>rep->length-find.rep->length ) start=rep->length-find.rep->length;
		while( start>=0 ){
			if( !t_memcmp( rep->data+start,find.rep->data,find.rep->length ) ) return start;
			--start;
		}
		return -1;
	}
	
	String Trim()const{
		int i=0,i2=rep->length;
		while( i<i2 && rep->data[i]<=32 ) ++i;
		while( i2>i && rep->data[i2-1]<=32 ) --i2;
		if( i==0 && i2==rep->length ) return *this;
		return String( rep->data+i,i2-i );
	}

	Array<String> Split( String sep )const{
	
		if( !sep.rep->length ){
			Array<String> bits( rep->length );
			for( int i=0;i<rep->length;++i ){
				bits[i]=String( (Char)(*this)[i],1 );
			}
			return bits;
		}
		
		int i=0,i2,n=1;
		while( (i2=Find( sep,i ))!=-1 ){
			++n;
			i=i2+sep.rep->length;
		}
		Array<String> bits( n );
		if( n==1 ){
			bits[0]=*this;
			return bits;
		}
		i=0;n=0;
		while( (i2=Find( sep,i ))!=-1 ){
			bits[n++]=Slice( i,i2 );
			i=i2+sep.rep->length;
		}
		bits[n]=Slice( i );
		return bits;
	}

	String Join( Array<String> bits )const{
		if( bits.Length()==0 ) return String();
		if( bits.Length()==1 ) return bits[0];
		int newlen=rep->length * (bits.Length()-1);
		for( int i=0;i<bits.Length();++i ){
			newlen+=bits[i].rep->length;
		}
		Rep *p=Rep::alloc( newlen );
		Char *q=p->data;
		q=t_memcpy( q,bits[0].rep->data,bits[0].rep->length );
		for( int i=1;i<bits.Length();++i ){
			q=t_memcpy( q,rep->data,rep->length );
			q=t_memcpy( q,bits[i].rep->data,bits[i].rep->length );
		}
		return String( p );
	}

	String Replace( String find,String repl )const{
		int i=0,i2,newlen=0;
		while( (i2=Find( find,i ))!=-1 ){
			newlen+=(i2-i)+repl.rep->length;
			i=i2+find.rep->length;
		}
		if( !i ) return *this;
		newlen+=rep->length-i;
		Rep *p=Rep::alloc( newlen );
		Char *q=p->data;
		i=0;
		while( (i2=Find( find,i ))!=-1 ){
			q=t_memcpy( q,rep->data+i,i2-i );
			q=t_memcpy( q,repl.rep->data,repl.rep->length );
			i=i2+find.rep->length;
		}
		q=t_memcpy( q,rep->data+i,rep->length-i );
		return String( p );
	}

	String ToLower()const{
		for( int i=0;i<rep->length;++i ){
			Char t=tolower( rep->data[i] );
			if( t==rep->data[i] ) continue;
			Rep *p=Rep::alloc( rep->length );
			Char *q=p->data;
			t_memcpy( q,rep->data,i );
			for( q[i++]=t;i<rep->length;++i ){
				q[i]=tolower( rep->data[i] );
			}
			return String( p );
		}
		return *this;
	}

	String ToUpper()const{
		for( int i=0;i<rep->length;++i ){
			Char t=toupper( rep->data[i] );
			if( t==rep->data[i] ) continue;
			Rep *p=Rep::alloc( rep->length );
			Char *q=p->data;
			t_memcpy( q,rep->data,i );
			for( q[i++]=t;i<rep->length;++i ){
				q[i]=toupper( rep->data[i] );
			}
			return String( p );
		}
		return *this;
	}
	
	bool Contains( String sub )const{
		return Find( sub )!=-1;
	}

	bool StartsWith( String sub )const{
		return sub.rep->length<=rep->length && !t_memcmp( rep->data,sub.rep->data,sub.rep->length );
	}

	bool EndsWith( String sub )const{
		return sub.rep->length<=rep->length && !t_memcmp( rep->data+rep->length-sub.rep->length,sub.rep->data,sub.rep->length );
	}
	
	String Slice( int from,int term )const{
		int len=rep->length;
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
		if( term<from ) return String();
		if( from==0 && term==len ) return *this;
		return String( rep->data+from,term-from );
	}

	String Slice( int from )const{
		return Slice( from,rep->length );
	}
	
	int ToInt()const{
		return atoi( ToCString<char>() );
	}
	
	Float ToFloat()const{
		return atof( ToCString<char>() );
	}
	
	template<class C> C *ToCString()const{

		C *p=&Array<C>( rep->length+1 )[0];
		
		for( int i=0;i<rep->length;++i ) p[i]=rep->data[i];
		p[rep->length]=0;
		return p;
	}

#if __OBJC__	
	NSString *ToNSString()const{
		return [NSString stringWithCharacters:ToCString<unichar>() length:rep->length];
	}
#endif

	bool Save( FILE *fp ){
		std::vector<unsigned char> buf;
		Save( buf );
		return fwrite( &buf[0],1,buf.size(),fp )==buf.size();
	}
	
	void Save( std::vector<unsigned char> &buf ){
	
		bool uni=false;
		
		for( int i=0;i<rep->length;++i ){
			if( rep->data[i]>=0xfe ){
				uni=true;
				break;
			}
		}
		
		if( uni ){
			Char c;
			unsigned char *p=(unsigned char*)&c;
			c=0xfeff;
			buf.push_back( p[0] );
			buf.push_back( p[1] );
			for( int i=0;i<rep->length;++i ){
				c=rep->data[i];
				buf.push_back( p[0] );
				buf.push_back( p[1] );
			}
		}else{
			for( int i=0;i<rep->length;++i ){
				buf.push_back( rep->data[i] );
			}
		}
	}
	
	static String FromChars( Array<int> chars ){
		int n=chars.Length();
		Rep *p=Rep::alloc( n );
		for( int i=0;i<n;++i ){
			p->data[i]=chars[i];
		}
		return String( p );
	}

	static String Load( FILE *fp ){
		unsigned char tmp[4096];
		std::vector<unsigned char> buf;
		for(;;){
			int n=fread( tmp,1,4096,fp );
			if( n>0 ) buf.insert( buf.end(),tmp,tmp+n );
			if( n!=4096 ) break;
		}
		return String::Load( &buf[0],buf.size() );
	}
	
	static String Load( unsigned char *p,int n ){
	
		if( n<3 ) return String( p,n );
		
		unsigned char *term=p+n;
		std::vector<Char> chars;

		int c=*p++;
		int d=*p++;
		
		if( c==0xfe && d==0xff ){
			while( p<term-1 ){
				int c=*p++;
				chars.push_back( (c<<8)|*p++ );
			}
		}else if( c==0xff && d==0xfe ){
			while( p<term-1 ){
				int c=*p++;
				chars.push_back( (*p++<<8)|c );
			}
		}else{
			int e=*p++;
			if( c!=0xef || d!=0xbb || e!=0xbf ) return String( p-3,n );
			while( p<term ){
				int c=*p++;
				if( c>=128 && p<term ){
					int d=*p++;
					if( c>=224 && p<term ){
						int e=*p++;
						if( c>=240 ) break;	//Illegal UTF8!
						c=(c-224)*4096+(d-128)*64+(e-128);
					}else{
						c=(c-192)*64+(d-128);
					}
				}
				chars.push_back( c );
			}
		}
		return String( &chars[0],chars.size() );
	}
	
private:
	struct Rep{
		int refs;
		int length;
		Char data[0];
		
		Rep( int length ):refs(1),length(length){
		}
		
		void retain(){
			++refs;
		}
		
		void release(){
			if( --refs || !length ) return;
			free( this );
		}

		static Rep *alloc( int length ){
			if( !length ){
				static Rep null(0);
				return &null;
			}
			void *p=malloc( sizeof(Rep)+length*sizeof(Char) );
			return new(p) Rep( length );
		}
	};
	Rep *rep;
	
	String( Rep *rep ):rep(rep){
	}
};

String *t_create( int n,String *p ){
	for( int i=0;i<n;++i ) new( &p[i] ) String();
	return p+n;
}

String *t_create( int n,String *p,const String *q ){
	for( int i=0;i<n;++i ) new( &p[i] ) String( q[i] );
	return p+n;
}

void t_destroy( int n,String *p ){
	for( int i=0;i<n;++i ) p[i].~String();
}

String T( const char *p ){
	return String( p );
}

String T( const wchar_t *p ){
	return String( p );
}

// ***** Object *****

class Object : public gc_object{
public:
	virtual bool Equals( Object *obj ){
		return this==obj;
	}
	
	virtual int Compare( Object *obj ){
		return (char*)this-(char*)obj;
	}
};

struct gc_interface{
	virtual ~gc_interface(){}
};

//**** main ****

int argc;
const char **argv;
const char *errInfo="";
std::vector<const char*> errStack;

Float D2R=0.017453292519943295f;
Float R2D=57.29577951308232f;

void pushErr(){
	errStack.push_back( errInfo );
}

void popErr(){
	errInfo=errStack.back();
	errStack.pop_back();
}

String StackTrace(){
	String str;
	pushErr();
	for( int i=errStack.size()-1;i>=0;--i ){
		str+=String( errStack[i] )+"\n";
	}
	popErr();
	return str;
}

int Print( String t ){
	puts( t.ToCString<char>() );
	fflush( stdout );
	return 0;
}

int Error( String err ){
	throw err.ToCString<char>();
	return 0;
}

int Compare( int x,int y ){
	return x-y;
}

int Compare( Float x,Float y ){
	return x<y ? -1 : x>y;
}

int Compare( String x,String y ){
	return x.Compare( y );
}

int bbInit();
int bbMain();

#if _MSC_VER

//Ok, this is butt ugly stuff, but MSVC's SEH seems to be the only
//way you can catch int divide by zero...let's use it for null objects too...
//
const char *FilterException( int type ){
	switch( type ){
	case STATUS_ACCESS_VIOLATION:return "Memory access violation";
	case STATUS_INTEGER_DIVIDE_BY_ZERO:return "Integer divide by zero";
	}
	return 0;
}

int seh_call( int(*f)() ){
	const char *p;
	__try{
		return f();
	}__except( (p=FilterException(GetExceptionCode()))!=0 ){
		puts( p );
		throw p;
	}
}

#else

int seh_call( int(*f)() ){
	return f();
}

void sighandler( int sig  ){
	switch( sig ){
	case SIGILL:throw "Illegal instruction";
	case SIGFPE:throw "Floating point exception";
#if !_WIN32
	case SIGBUS:throw "Bus error";
#endif
	case SIGSEGV:throw "Segmentation violation";
	}
	throw "Unknown exception";
}

#endif

//entry point call by target main()...
//
int bb_std_main( int argc,const char **argv ){
	
	::argc=argc;
	::argv=argv;
	
#if !_MSC_VER
	signal( SIGILL,sighandler );
	signal( SIGFPE,sighandler );
#if !_WIN32
	signal( SIGBUS,sighandler );
#endif
	signal( SIGSEGV,sighandler );
#endif

	seh_call( bbInit );
	
#if CFG_CPP_INCREMENTAL_GC
	gc_mark_roots();
#endif
	
	seh_call( bbMain );
	
	return 0;
}

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
class util {
public:
    int static GetTimestamp() {
        time_t unixTime = (time_t) [[NSDate date] timeIntervalSince1970];
        return static_cast<int>(unixTime);
    }
};
/*
This file is based on MKStoreKit by Mugunth Kumar. MKStoreKit files were merged for Monkey needs.
Some of them were modified for our needs. 

MKStoreKit function wrappers by Roman Budzowski (c) 21.07.2011

*/


//
//  MKStoreObserver.m
//  MKStoreKit
//
//  Created by Mugunth Kumar on 17-Nov-2010.
//  Copyright 2010 Steinlogic. All rights reserved.
//	File created using Singleton XCode Template by Mugunth Kumar (http://mugunthkumar.com
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above

//  As a side note on using this code, you might consider giving some credit to me by
//	1) linking my website from your app's website 
//	2) or crediting me inside the app's credits page 
//	3) or a tweet mentioning @mugunthkumar
//	4) A paypal donation to mugunth.kumar@gmail.com
//
//  A note on redistribution
//	While I'm ok with modifications to this source code, 
//	if you are re-publishing after editing, please retain the above copyright notices



#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>



@interface MKStoreObserver : NSObject<SKPaymentTransactionObserver> {

	
}
	
- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;

@end


////////// MKStoreManager.h starts here
/////////
///////
/////

// CONFIGURATION STARTS -- Change this in your app
//#define kConsumableBaseFeatureId @"com.mycompany.myapp."
//#define kFeatureAId @"com.mycompany.myapp.featureA"
//#define kConsumableFeatureBId @"com.mycompany.myapp.005"
// consumable features should have only number as the last part of the product name
// MKStoreKit automatically keeps track of the count of your consumable product



#define SERVER_PRODUCT_MODEL 0
// CONFIGURATION ENDS -- Change this in your app

@protocol MKStoreKitDelegate <NSObject>
@optional
- (void)productFetchComplete;
- (void)productPurchased:(NSString *)productId;
- (void)transactionCanceled;
// as a matter of UX, don't show a "User Canceled transaction" alert view here
// use this only to "enable/disable your UI or hide your activity indicator view etc.,
@end

@interface MKStoreManager : NSObject<SKProductsRequestDelegate> {

	NSMutableArray *_purchasableObjects;
	MKStoreObserver *_storeObserver;
	
	NSMutableSet *productsList;
	NSString *bundleID;
	
	BOOL isProductsAvailable;
	BOOL isPurchaseInProgress;
	int purchaseResult;
}

@property (nonatomic, retain) NSMutableArray *purchasableObjects;
@property (nonatomic, retain) MKStoreObserver *storeObserver;
@property (nonatomic, retain) NSString *bundleID;
@property (readwrite, assign) BOOL isPurchaseInProgress;
@property (readwrite, assign) int purchaseResult;
@property (copy) NSSet *productsList;

// These are the methods you will be using in your app
+ (MKStoreManager*)sharedManager;

// this is a static method, since it doesn't require the store manager to be initialized prior to calling
+ (BOOL) isFeaturePurchased:(NSString*) featureId; 

// these three are not static methods, since you have to initialize the store with your product ids before calling this function
- (void) buyFeature:(NSString*) featureId;
- (NSMutableArray*) purchasableObjectsDescription;
- (void) restorePreviousTransactions;
- (void) setProductsList:(NSSet*) value;

- (BOOL) canConsumeProduct:(NSString*) productIdentifier quantity:(int) quantity;
- (BOOL) consumeProduct:(NSString*) productIdentifier quantity:(int) quantity;


//DELEGATES
+(id)delegate;	
+(void)setDelegate:(id)newDelegate;

@end

/////// implementations
///////
/////  MKStoreObsersver.cpp
///
//


@implementation MKStoreObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	for (SKPaymentTransaction *transaction in transactions)
	{
		switch (transaction.transactionState)
		{
			case SKPaymentTransactionStatePurchasing:
//				NSLog(@"order start");
				[[MKStoreManager sharedManager] setIsPurchaseInProgress: YES];
				break;
				
			case SKPaymentTransactionStatePurchased:	
//				NSLog(@"state purchased");
				[[MKStoreManager sharedManager] setIsPurchaseInProgress: NO];
				[[MKStoreManager sharedManager] setPurchaseResult: 2];
                [self completeTransaction:transaction];
                break;
				
            case SKPaymentTransactionStateFailed:
//				NSLog(@"state failed");
				[[MKStoreManager sharedManager] setIsPurchaseInProgress: NO]; 
				[[MKStoreManager sharedManager] setPurchaseResult: 3];
                [self failedTransaction:transaction];
                break;
				
            case SKPaymentTransactionStateRestored:
//				NSLog(@"State restored");
				[[MKStoreManager sharedManager] setIsPurchaseInProgress: NO];
				[[MKStoreManager sharedManager] setPurchaseResult: 4];
                [self restoreTransaction:transaction];
				
            default:
                break;
		}			
	}
}


- (void) failedTransaction: (SKPaymentTransaction *)transaction
{	
	bool b_retry=false;
	switch (transaction.error.code) 
	{
		case SKErrorPaymentCancelled:
			NSLog(@"SKErrorPaymentCancelled");
		break;
		
		case SKErrorUnknown:
			NSLog(@"SKErrorUnknown");
		break;
			
		case SKErrorClientInvalid:
			NSLog(@"SKErrorClientInvalid");
		break;
			
		case SKErrorPaymentInvalid:
			NSLog(@"SKErrorPaymentInvalid");
		break;
			
		case SKErrorPaymentNotAllowed:
			NSLog(@"SKErrorPaymentNotAllowed");
		break;
			
		default:
			NSLog(@"## MISSING ERROR CODE TRANSCATION");
			b_retry=true;
			break;
	}
	
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	

	if (b_retry)
	{
//		BuyItem(0);
	}
}


- (void) completeTransaction: (SKPaymentTransaction *)transaction
{		
	[[MKStoreManager sharedManager] provideContent:transaction.payment.productIdentifier 
									   forReceipt:transaction.transactionReceipt];	

	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];	

	#ifndef NDEBUG
	NSLog(@"IAP Purchase completed");
	#endif
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{	
    [[MKStoreManager sharedManager] provideContent: transaction.originalTransaction.payment.productIdentifier
									   forReceipt:transaction.transactionReceipt];
	
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	

	#ifndef NDEBUG
	NSLog(@"IAP Restore Purchases completed");
	#endif

}

@end


/////// implementations
///////
///// MKStoreManager.cpp
///
//

@implementation MKStoreManager

@synthesize purchasableObjects = _purchasableObjects;
@synthesize storeObserver = _storeObserver;
@synthesize bundleID;
@synthesize purchaseResult;
@synthesize isPurchaseInProgress;

static NSString *ownServer = nil;

static __weak id<MKStoreKitDelegate> _delegate;
static MKStoreManager* _sharedStoreManager;


- (void)dealloc {
	
	[_purchasableObjects release];
	[_storeObserver release];

	[bundleID release];
//	[_productsList release];

	[_sharedStoreManager release];
	[super dealloc];
}

#pragma mark Delegates

+ (id)delegate {
	
    return _delegate;
}

+ (void)setDelegate:(id)newDelegate {
	
    _delegate = newDelegate;	
}

#pragma mark Singleton Methods

+ (MKStoreManager*)sharedManager
{
	@synchronized(self) {
		
        if (_sharedStoreManager == nil) {
						
#if TARGET_IPHONE_SIMULATOR
			NSLog(@"You are running in Simulator MKStoreKit runs only on devices");
#else
            _sharedStoreManager = [[self alloc] init];					
#endif
        }
    }
    return _sharedStoreManager;
}


+ (void)startManager 
{
	#if TARGET_IPHONE_SIMULATOR
		NSLog(@"IAP doesn't run on simulator");
	#else
//NSLog(@"start manager");
		_sharedStoreManager.purchasableObjects = [[NSMutableArray alloc] init];
		[_sharedStoreManager requestProductData];						
		_sharedStoreManager.storeObserver = [[MKStoreObserver alloc] init];
		[[SKPaymentQueue defaultQueue] addTransactionObserver:_sharedStoreManager.storeObserver];			
	#endif
}

+ (id)allocWithZone:(NSZone *)zone

{	
    @synchronized(self) {
		
        if (_sharedStoreManager == nil) {
			
            _sharedStoreManager = [super allocWithZone:zone];			
            return _sharedStoreManager;  // assignment and return on first allocation
        }
    }
	
    return nil; //on subsequent allocation attempts return nil	
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;	
}

- (id)retain
{	
    return self;	
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;	
}

#pragma mark Internal MKStoreKit functions

//- (NSSet *) productsList {
//	return [NSSet setWithSet:_productsList];
//}

- (void) setProductsList:(NSSet *) value {
	
	if (productsList == nil) {
		productsList = [[NSMutableSet alloc] init];
	}

	[productsList setSet:value];
}


- (void) restorePreviousTransactions
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

-(void) requestProductData
{
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:productsList];

	request.delegate = self;
	[request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	[self.purchasableObjects addObjectsFromArray:response.products];

#ifndef NDEBUG	
	for(int i=0;i<[self.purchasableObjects count];i++)
	{		
		SKProduct *product = [self.purchasableObjects objectAtIndex:i];
		NSLog(@"Feature: %@, Cost: %f, ID: %@",[product localizedTitle],
			  [[product price] doubleValue], [product productIdentifier]);
	}
	
	for(NSString *invalidProduct in response.invalidProductIdentifiers)
		NSLog(@"Problem in iTunes connect configuration for product: %@", invalidProduct);
#endif
	
	[request autorelease];
	
	isProductsAvailable = YES;
	
	if([_delegate respondsToSelector:@selector(productFetchComplete)])
		[_delegate productFetchComplete];	
}


// call this function to check if the user has already purchased your feature
+ (BOOL) isFeaturePurchased:(NSString*) featureId
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:featureId];
}

// Call this function to populate your UI
// this function automatically formats the currency based on the user's locale

- (NSMutableArray*) purchasableObjectsDescription
{
	NSMutableArray *productDescriptions = [[NSMutableArray alloc] initWithCapacity:[self.purchasableObjects count]];
	for(int i=0;i<[self.purchasableObjects count];i++)
	{
		SKProduct *product = [self.purchasableObjects objectAtIndex:i];
		
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[numberFormatter setLocale:product.priceLocale];
		NSString *formattedString = [numberFormatter stringFromNumber:product.price];
		[numberFormatter release];
		
		// you might probably need to change this line to suit your UI needs
		NSString *description = [NSString stringWithFormat:@"%@ (%@)",[product localizedTitle], formattedString];
		
#ifndef NDEBUG
		NSLog(@"Product %d - %@", i, description);
#endif
		[productDescriptions addObject: description];
	}
	
	[productDescriptions autorelease];
	return productDescriptions;
}


- (void) buyFeature:(NSString*) featureId
{
	if([self canCurrentDeviceUseFeature: featureId])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Review request approved", @"")
														message:NSLocalizedString(@"You can use this feature for reviewing the app.", @"")
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[self enableContentForThisSession:featureId];
		return;
	}
	
	if ([SKPaymentQueue canMakePayments])
	{
//		NSLog(@"Trying to buy %@", featureId);
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:featureId];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"In-App Purchasing disabled", @"")
														message:NSLocalizedString(@"Check your parental control settings and try again later", @"")
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}

- (BOOL) canConsumeProduct:(NSString*) productIdentifier
{
	int count = [[NSUserDefaults standardUserDefaults] integerForKey:productIdentifier];
	
	return (count > 0);
	
}

- (BOOL) canConsumeProduct:(NSString*) productIdentifier quantity:(int) quantity
{
	int count = [[NSUserDefaults standardUserDefaults] integerForKey:productIdentifier];
	return (count >= quantity);
}

- (BOOL) consumeProduct:(NSString*) productIdentifier quantity:(int) quantity
{
	int count = [[NSUserDefaults standardUserDefaults] integerForKey:productIdentifier];
	if(count < quantity)
	{
		return NO;
	}
	else 
	{
		count -= quantity;
		[[NSUserDefaults standardUserDefaults] setInteger:count forKey:productIdentifier];
		return YES;
	}
	
}

-(void) enableContentForThisSession: (NSString*) productIdentifier
{
	if([_delegate respondsToSelector:@selector(productPurchased:)])
		[_delegate productPurchased:productIdentifier];
}

							 
#pragma mark In-App purchases callbacks
// In most cases you don't have to touch these methods
-(void) provideContent: (NSString*) productIdentifier 
		   forReceipt:(NSData*) receiptData
{
	if(ownServer != nil && SERVER_PRODUCT_MODEL)
	{
		// ping server and get response before serializing the product
		// this is a blocking call to post receipt data to your server
		// it should normally take a couple of seconds on a good 3G connection
		if(![self verifyReceipt:receiptData]) return;
	}

	NSRange range = [productIdentifier rangeOfString: @"." options: NSBackwardsSearch];
	if (range.location == NSNotFound) NSLog(@"invalid product id");

	NSString *countText = [productIdentifier substringFromIndex:range.location+1];

	int quantityPurchased = [countText intValue];
	if(quantityPurchased != 0)
	{
		countText = [productIdentifier substringToIndex:range.location];
		int oldCount = [[NSUserDefaults standardUserDefaults] integerForKey:countText];
		oldCount += quantityPurchased;	
		
		[[NSUserDefaults standardUserDefaults] setInteger:oldCount forKey:countText];		
	}
	else 
	{
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];		
	}

	[[NSUserDefaults standardUserDefaults] synchronize];

	if([_delegate respondsToSelector:@selector(productPurchased:)])
		[_delegate productPurchased:productIdentifier];	
}

- (void) transactionCanceled: (SKPaymentTransaction *)transaction
{

#ifndef NDEBUG
	NSLog(@"User cancelled transaction: %@", [transaction description]);

   if (transaction.error.code != SKErrorPaymentCancelled)
    {
		if(transaction.error.code == SKErrorUnknown) {
			NSLog(@"Unknown Error (%d), product: %@", (int)transaction.error.code, transaction.payment.productIdentifier);
			UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle :@"In-App-Purchase Error:"
																	message: @"There was an error purchasing this item please try again."
																  delegate : self cancelButtonTitle:@"OK"otherButtonTitles:nil];
			[failureAlert show];
			[failureAlert release];
		}
		
		if(transaction.error.code == SKErrorClientInvalid) {
			NSLog(@"Client invalid (%d), product: %@", (int)transaction.error.code, transaction.payment.productIdentifier);
			UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle :@"In-App-Purchase Error:"
																	message: @"There was an error purchasing this item please try again."
																  delegate : self cancelButtonTitle:@"OK"otherButtonTitles:nil];
			[failureAlert show];
			[failureAlert release];
		}
		
		if(transaction.error.code == SKErrorPaymentInvalid) {
			NSLog(@"Payment invalid (%d), product: %@", (int)transaction.error.code, transaction.payment.productIdentifier);
			UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle :@"In-App-Purchase Error:"
																	message: @"There was an error purchasing this item please try again."
																  delegate : self cancelButtonTitle:@"OK"otherButtonTitles:nil];
			[failureAlert show];
			[failureAlert release];
		}
		
		if(transaction.error.code == SKErrorPaymentNotAllowed) {
			NSLog(@"Payment not allowed (%d), product: %@", (int)transaction.error.code, transaction.payment.productIdentifier);
			UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle :@"In-App-Purchase Error:"
																	message: @"There was an error purchasing this item please try again."
																  delegate : self cancelButtonTitle:@"OK"otherButtonTitles:nil];
			[failureAlert show];
			[failureAlert release];
		}
    }
#endif
	
	if([_delegate respondsToSelector:@selector(transactionCanceled)])
		[_delegate transactionCanceled];
}



- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[transaction.error localizedFailureReason] 
													message:[transaction.error localizedRecoverySuggestion]
												   delegate:self 
										  cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
}


#pragma mark In-App purchases promo codes support
// This function is only used if you want to enable in-app purchases for free for reviewers
// Read my blog post http://mk.sg/31
- (BOOL) canCurrentDeviceUseFeature: (NSString*) featureID
{
	NSString *uniqueID = [[UIDevice currentDevice] uniqueIdentifier];
	// check udid and featureid with developer's server
	
	if(ownServer == nil) return NO; // sanity check
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", ownServer, @"featureCheck.php"]];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url 
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                          timeoutInterval:60];
	
	[theRequest setHTTPMethod:@"POST"];		
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	NSString *postData = [NSString stringWithFormat:@"productid=%@&udid=%@", featureID, uniqueID];
	
	NSString *length = [NSString stringWithFormat:@"%d", [postData length]];	
	[theRequest setValue:length forHTTPHeaderField:@"Content-Length"];	
	
	[theRequest setHTTPBody:[postData dataUsingEncoding:NSASCIIStringEncoding]];
	
	NSHTTPURLResponse* urlResponse = nil;
	NSError *error = [[[NSError alloc] init] autorelease];  
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:theRequest
												 returningResponse:&urlResponse 
															 error:&error];  
	
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
	
	BOOL retVal = NO;
	if([responseString isEqualToString:@"YES"])		
	{
		retVal = YES;
	}
	
	[responseString release];
	return retVal;
}

// This function is only used if you want to enable in-app purchases for free for reviewers
// Read my blog post http://mk.sg/

-(BOOL) verifyReceipt:(NSData*) receiptData
{
	if(ownServer == nil) return NO; // sanity check
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", ownServer, @"verifyProduct.php"]];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url 
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                          timeoutInterval:60];
	
	[theRequest setHTTPMethod:@"POST"];		
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	NSString *receiptDataString = [[NSString alloc] initWithData:receiptData encoding:NSASCIIStringEncoding];
	NSString *postData = [NSString stringWithFormat:@"receiptdata=%@", receiptDataString];
	[receiptDataString release];
	
	NSString *length = [NSString stringWithFormat:@"%d", [postData length]];	
	[theRequest setValue:length forHTTPHeaderField:@"Content-Length"];	
	
	[theRequest setHTTPBody:[postData dataUsingEncoding:NSASCIIStringEncoding]];
	
	NSHTTPURLResponse* urlResponse = nil;
	NSError *error = [[[NSError alloc] init] autorelease];  
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:theRequest
												 returningResponse:&urlResponse 
															 error:&error];  
	
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
	
	BOOL retVal = NO;
	if([responseString isEqualToString:@"YES"])		
	{
		retVal = YES;
	}
	
	[responseString release];
	return retVal;
}
@end





///////////////////////////////////////////////
///////////////////////////////////////////////
///////////////////////////////////////////////
///////////////////////////////////////////////
///////////////////////////////////////////////
///////////////////////////////////////////////
///////////////////////////////////////////////








//------ IS PRODUCT PURCHASED ------
int isProductPurchased(String product) {
	NSString *kFeatureID = product.ToNSString();

	if([MKStoreManager isFeaturePurchased:kFeatureID])
	{
		return true;
	}
	
	return false;
}



//------ BUY PRODUCT ------
void buyProduct(String product) {
	NSString *kProductID = product.ToNSString();

	#ifndef NDEBUG
	NSLog(@"Trying to purchase: %@", kProductID);
	#endif

	[[MKStoreManager sharedManager] buyFeature:kProductID];
}



/* ------ GET PRODUCTS DESCRIPTION ------

String *getProductsDescription() {
	NSMutableArray *productDescriptions;
	productDescriptions = [[MKStoreManager sharedManager] purchasableObjectsDescription];
	
	NSString *item;

	unsigned count = [productDescriptions count];
	unsigned count2 = 0;

//	String *descriptions = malloc(count*sizeof(String));
	String descriptions[count];
	
	while (count--) {
	    item = [productDescriptions objectAtIndex:count];
		descriptions[count2++] = String(item);
	}
	
	return descriptions;
}
*/


//------ CAN CONSUME PRODUCT -----
bool canConsumeProduct(String product) {
	NSString *kFeatureID = product.ToNSString();

	#ifndef NDEBUG
	NSLog(@"can consume product?: %@", kFeatureID);
	#endif

	return [[MKStoreManager sharedManager] canConsumeProduct:kFeatureID];
}

//------ CONSUME PRODUCT -----
bool consumeProduct(String product) {
	NSString *kFeatureID = product.ToNSString(); 
	
	return [[MKStoreManager sharedManager] consumeProduct:kFeatureID quantity: 1];
}





//------ INIT IAP ------
void InitInAppPurchases(String bundleID, Array<String> prodList) {

	[MKStoreManager sharedManager];

	[[MKStoreManager sharedManager] setBundleID:bundleID.ToNSString()];

	NSMutableArray *nsaProdList = [[NSMutableArray alloc] init];
	NSString *prodID;
	for (int i=0; i < prodList.Length(); i++) {
		prodID = prodList[i].ToNSString();
		[nsaProdList addObject: prodID];
	}

	[[MKStoreManager sharedManager] setProductsList:[NSSet setWithArray:nsaProdList]];

	[MKStoreManager startManager];
}


void restorePurchasedProducts() {
//	NSLog(@"trying to restore");
	[[MKStoreManager sharedManager] restorePreviousTransactions];
}


bool isPurchaseInProgress() {
	return [[MKStoreManager sharedManager] isPurchaseInProgress];
}

int getPurchaseResult() {
	return [[MKStoreManager sharedManager] purchaseResult];
}

void resetPurchaseResult() {
	[[MKStoreManager sharedManager] setPurchaseResult: 0];
}
class bb_directorevents_DirectorEvents;
class bb_router_Router;
class bb_partial_Partial;
class bb_routerevents_RouterEvents;
class bb_scene_Scene;
class bb_introscene_IntroScene;
class bb_map_Map;
class bb_map_StringMap;
class bb_map_Node;
class bb_map_Map2;
class bb_map_StringMap2;
class bb_map_Node2;
class bb_menuscene_MenuScene;
class bb_highscorescene_HighscoreScene;
class bb_gamescene_GameScene;
class bb_gameoverscene_GameOverScene;
class bb_pausescene_PauseScene;
class bb_newhighscorescene_NewHighscoreScene;
class bb_app_App;
class bb_sizeable_Sizeable;
class bb_director_Director;
class bb_list_List;
class bb_list_Node;
class bb_list_HeadNode;
class bb_app_AppDevice;
class bb_graphics_GraphicsContext;
class bb_vector2d_Vector2D;
class bb_inputcontroller_InputController;
class bb_fanout_FanOut;
class bb_list_List2;
class bb_list_Node2;
class bb_list_HeadNode2;
class bb_list_Enumerator;
class bb_graphics_Image;
class bb_graphics_Frame;
class bb_positionable_Positionable;
class bb_baseobject_BaseObject;
class bb_sprite_Sprite;
class bb_angelfont2_AngelFont;
class bb_kernpair_KernPair;
class bb_map_Map3;
class bb_map_StringMap3;
class bb_map_Node3;
class bb_char_Char;
class bb_map_Map4;
class bb_map_StringMap4;
class bb_map_Node4;
class bb_persistable_Persistable;
class bb_highscore_Highscore;
class bb_highscore_IntHighscore;
class bb_gamehighscore_GameHighscore;
class bb_score_Score;
class bb_list_List3;
class bb_list_Node3;
class bb_list_HeadNode3;
class bb_list_Enumerator2;
class bb_statestore_StateStore;
class bb_chute_Chute;
class bb_severity_Severity;
class bb_slider_Slider;
class bb_font_Font;
class bb_angelfont_AngelFont;
class bb_map_Map5;
class bb_map_StringMap5;
class bb_map_Node5;
class bb_animation_Animation;
class bb_fader_Fader;
class bb_fader_FaderScale;
class bb_transition_Transition;
class bb_transition_TransitionInCubic;
class bb_transition_TransitionLinear;
class bb_stack_Stack;
class bb_stack_IntStack;
class bb_list_List4;
class bb_list_IntList;
class bb_list_Node4;
class bb_list_HeadNode4;
class bb_set_Set;
class bb_set_IntSet;
class bb_map_Map6;
class bb_map_IntMap;
class bb_map_Node6;
class bb_list_Enumerator3;
class bb_textinput_TextInput;
class bb_deltatimer_DeltaTimer;
class bb_touchevent_TouchEvent;
class bb_list_List5;
class bb_list_Node5;
class bb_list_HeadNode5;
class bb_keyevent_KeyEvent;
class bb_map_Map7;
class bb_map_IntMap2;
class bb_map_Node7;
class bb_map_MapValues;
class bb_map_ValueEnumerator;
class bb_color_Color;
class bb_shape_Shape;
class bb_stack_Stack2;
class bb_directorevents_DirectorEvents : public virtual gc_interface{
	public:
	virtual void m_OnCreate(bb_director_Director*)=0;
	virtual void m_OnLoading()=0;
	virtual void m_OnUpdate(Float,Float)=0;
	virtual void m_OnTouchDown(bb_touchevent_TouchEvent*)=0;
	virtual void m_OnTouchUp(bb_touchevent_TouchEvent*)=0;
	virtual void m_OnTouchMove(bb_touchevent_TouchEvent*)=0;
	virtual void m_OnKeyDown(bb_keyevent_KeyEvent*)=0;
	virtual void m_OnKeyUp(bb_keyevent_KeyEvent*)=0;
	virtual void m_OnKeyPress(bb_keyevent_KeyEvent*)=0;
	virtual void m_OnResume(int)=0;
	virtual void m_OnSuspend()=0;
	virtual void m_OnRender()=0;
};
class bb_router_Router : public Object,public virtual bb_directorevents_DirectorEvents{
	public:
	bb_map_StringMap* f_handlers;
	bb_map_StringMap2* f_routers;
	String f__currentName;
	bb_directorevents_DirectorEvents* f__current;
	bb_directorevents_DirectorEvents* f__previous;
	String f__previousName;
	bb_director_Director* f_director;
	bb_list_List* f_created;
	bb_router_Router();
	bb_router_Router* g_new();
	virtual void m_Add(String,bb_directorevents_DirectorEvents*);
	virtual bb_directorevents_DirectorEvents* m_Get(String);
	virtual void m_DispatchOnCreate();
	virtual void m_Goto(String);
	virtual void m_OnCreate(bb_director_Director*);
	virtual void m_OnLoading();
	virtual void m_OnUpdate(Float,Float);
	virtual void m_OnRender();
	virtual void m_OnSuspend();
	virtual void m_OnResume(int);
	virtual void m_OnKeyDown(bb_keyevent_KeyEvent*);
	virtual void m_OnKeyPress(bb_keyevent_KeyEvent*);
	virtual void m_OnKeyUp(bb_keyevent_KeyEvent*);
	virtual void m_OnTouchDown(bb_touchevent_TouchEvent*);
	virtual void m_OnTouchMove(bb_touchevent_TouchEvent*);
	virtual void m_OnTouchUp(bb_touchevent_TouchEvent*);
	virtual bb_directorevents_DirectorEvents* m_previous();
	virtual String m_previousName();
	void mark();
};
class bb_partial_Partial : public Object,public virtual bb_directorevents_DirectorEvents{
	public:
	bb_director_Director* f__director;
	bb_partial_Partial();
	bb_partial_Partial* g_new();
	virtual void m_OnCreate(bb_director_Director*);
	virtual bb_director_Director* m_director();
	virtual void m_OnRender();
	virtual void m_OnUpdate(Float,Float);
	virtual void m_OnKeyUp(bb_keyevent_KeyEvent*);
	virtual void m_OnLoading();
	virtual void m_OnSuspend();
	virtual void m_OnResume(int);
	virtual void m_OnKeyDown(bb_keyevent_KeyEvent*);
	virtual void m_OnKeyPress(bb_keyevent_KeyEvent*);
	virtual void m_OnTouchDown(bb_touchevent_TouchEvent*);
	virtual void m_OnTouchMove(bb_touchevent_TouchEvent*);
	virtual void m_OnTouchUp(bb_touchevent_TouchEvent*);
	void mark();
};
class bb_routerevents_RouterEvents : public virtual gc_interface{
	public:
	virtual void m_OnLeave()=0;
	virtual void m_OnEnter()=0;
};
class bb_scene_Scene : public bb_partial_Partial,public virtual bb_routerevents_RouterEvents{
	public:
	bb_fanout_FanOut* f__layer;
	bb_router_Router* f__router;
	bb_scene_Scene();
	bb_scene_Scene* g_new();
	virtual void m_OnEnter();
	virtual void m_OnLeave();
	static bb_graphics_Image* g_blend;
	virtual void m_OnCreate(bb_director_Director*);
	virtual bb_fanout_FanOut* m_layer();
	virtual void m_OnLoading();
	virtual void m_OnUpdate(Float,Float);
	virtual void m_OnRender();
	virtual void m_OnSuspend();
	virtual void m_OnResume(int);
	virtual void m_OnKeyDown(bb_keyevent_KeyEvent*);
	virtual void m_OnKeyPress(bb_keyevent_KeyEvent*);
	virtual void m_OnKeyUp(bb_keyevent_KeyEvent*);
	virtual void m_OnTouchDown(bb_touchevent_TouchEvent*);
	virtual void m_OnTouchMove(bb_touchevent_TouchEvent*);
	virtual void m_OnTouchUp(bb_touchevent_TouchEvent*);
	virtual bb_router_Router* m_router();
	virtual void m_RenderBlend();
	void mark();
};
class bb_introscene_IntroScene : public bb_scene_Scene{
	public:
	bb_introscene_IntroScene();
	bb_introscene_IntroScene* g_new();
	virtual void m_OnCreate(bb_director_Director*);
	virtual void m_OnUpdate(Float,Float);
	virtual void m_OnRender();
	void mark();
};
class bb_map_Map : public Object{
	public:
	bb_map_Node* f_root;
	bb_map_Map();
	bb_map_Map* g_new();
	virtual int m_Compare(String,String)=0;
	virtual bb_map_Node* m_FindNode(String);
	virtual bool m_Contains(String);
	virtual int m_RotateLeft(bb_map_Node*);
	virtual int m_RotateRight(bb_map_Node*);
	virtual int m_InsertFixup(bb_map_Node*);
	virtual bool m_Set(String,bb_directorevents_DirectorEvents*);
	virtual bb_directorevents_DirectorEvents* m_Get(String);
	void mark();
};
class bb_map_StringMap : public bb_map_Map{
	public:
	bb_map_StringMap();
	bb_map_StringMap* g_new();
	virtual int m_Compare(String,String);
	void mark();
};
class bb_map_Node : public Object{
	public:
	String f_key;
	bb_map_Node* f_right;
	bb_map_Node* f_left;
	bb_directorevents_DirectorEvents* f_value;
	int f_color;
	bb_map_Node* f_parent;
	bb_map_Node();
	bb_map_Node* g_new(String,bb_directorevents_DirectorEvents*,int,bb_map_Node*);
	bb_map_Node* g_new2();
	void mark();
};
class bb_map_Map2 : public Object{
	public:
	bb_map_Node2* f_root;
	bb_map_Map2();
	bb_map_Map2* g_new();
	virtual int m_Compare(String,String)=0;
	virtual int m_RotateLeft2(bb_map_Node2*);
	virtual int m_RotateRight2(bb_map_Node2*);
	virtual int m_InsertFixup2(bb_map_Node2*);
	virtual bool m_Set2(String,bb_routerevents_RouterEvents*);
	virtual bb_map_Node2* m_FindNode(String);
	virtual bb_routerevents_RouterEvents* m_Get(String);
	void mark();
};
class bb_map_StringMap2 : public bb_map_Map2{
	public:
	bb_map_StringMap2();
	bb_map_StringMap2* g_new();
	virtual int m_Compare(String,String);
	void mark();
};
class bb_map_Node2 : public Object{
	public:
	String f_key;
	bb_map_Node2* f_right;
	bb_map_Node2* f_left;
	bb_routerevents_RouterEvents* f_value;
	int f_color;
	bb_map_Node2* f_parent;
	bb_map_Node2();
	bb_map_Node2* g_new(String,bb_routerevents_RouterEvents*,int,bb_map_Node2*);
	bb_map_Node2* g_new2();
	void mark();
};
class bb_menuscene_MenuScene : public bb_scene_Scene{
	public:
	bb_sprite_Sprite* f_easy;
	bb_sprite_Sprite* f_normal;
	bb_sprite_Sprite* f_normalActive;
	bb_sprite_Sprite* f_advanced;
	bb_sprite_Sprite* f_advancedActive;
	bb_sprite_Sprite* f_highscore;
	bb_sprite_Sprite* f_lock;
	bool f_isLocked;
	bool f_paymentProcessing;
	bb_font_Font* f_waitingText;
	bb_sprite_Sprite* f_waitingImage;
	bb_menuscene_MenuScene();
	bb_menuscene_MenuScene* g_new();
	virtual void m_ToggleLock();
	virtual void m_OnCreate(bb_director_Director*);
	virtual void m_PlayEasy();
	virtual void m_InitializeWaitingImages();
	virtual void m_HandleLocked();
	virtual void m_PlayNormal();
	virtual void m_PlayAdvanced();
	virtual void m_OnTouchDown(bb_touchevent_TouchEvent*);
	virtual void m_OnKeyDown(bb_keyevent_KeyEvent*);
	virtual void m_OnUpdate(Float,Float);
	virtual void m_OnRender();
	void mark();
};
class bb_highscorescene_HighscoreScene : public bb_scene_Scene,public virtual bb_routerevents_RouterEvents{
	public:
	bb_angelfont2_AngelFont* f_font;
	bb_sprite_Sprite* f_background;
	bb_gamehighscore_GameHighscore* f_highscore;
	int f_lastScoreValue;
	String f_lastScoreKey;
	Float f_disableTimer;
	bb_highscorescene_HighscoreScene();
	bb_highscorescene_HighscoreScene* g_new();
	virtual void m_OnCreate(bb_director_Director*);
	virtual void m_OnEnter();
	virtual void m_OnLeave();
	virtual void m_OnUpdate(Float,Float);
	virtual void m_DrawEntries();
	virtual void m_OnRender();
	virtual void m_OnKeyDown(bb_keyevent_KeyEvent*);
	virtual void m_OnTouchDown(bb_touchevent_TouchEvent*);
	void mark();
};
class bb_gamescene_GameScene : public bb_scene_Scene,public virtual bb_routerevents_RouterEvents{
	public:
	bb_chute_Chute* f_chute;
	bb_fanout_FanOut* f_lowerShapes;
	bb_severity_Severity* f_severity;
	bb_slider_Slider* f_slider;
	bb_fanout_FanOut* f_upperShapes;
	bb_fanout_FanOut* f_errorAnimations;
	bb_sprite_Sprite* f_pauseButton;
	bb_font_Font* f_scoreFont;
	bb_font_Font* f_comboFont;
	bb_animation_Animation* f_comboAnimation;
	bb_font_Font* f_newHighscoreFont;
	bb_animation_Animation* f_newHighscoreAnimation;
	Float f_checkPosY;
	int f_pauseTime;
	bool f_ignoreFirstTouchUp;
	int f_score;
	int f_minHighscore;
	bool f_isNewHighscoreRecord;
	bool f_collisionCheckedLastUpdate;
	bb_stack_Stack2* f_falseSpriteStrack;
	Array<int > f_lastMatchTime;
	bool f_comboPending;
	int f_comboPendingSince;
	Float f_lastSlowUpdate;
	bb_gamescene_GameScene();
	bb_gamescene_GameScene* g_new();
	virtual void m_OnCreate(bb_director_Director*);
	virtual void m_OnEnterPaused();
	virtual void m_LoadHighscoreMinValue();
	virtual void m_OnEnter();
	virtual void m_OnLeave();
	virtual bool m_HandleGameOver();
	virtual void m_OnMissmatch(bb_shape_Shape*);
	virtual void m_IncrementScore(int);
	virtual void m_OnMatch(bb_shape_Shape*);
	virtual void m_CheckShapeCollisions();
	virtual void m_DetectComboTrigger();
	virtual void m_DropNewShapeIfRequested();
	virtual void m_RemoveLostShapes();
	virtual void m_RemoveFinishedErroAnimations();
	virtual void m_OnUpdate(Float,Float);
	virtual void m_StartPause();
	virtual void m_FastDropMatchingShapes();
	virtual void m_OnKeyDown(bb_keyevent_KeyEvent*);
	virtual void m_OnTouchDown(bb_touchevent_TouchEvent*);
	virtual void m_HandleSliderSwipe(bb_touchevent_TouchEvent*);
	virtual void m_HandleBackgroundSwipe(bb_touchevent_TouchEvent*);
	virtual void m_OnTouchUp(bb_touchevent_TouchEvent*);
	virtual void m_OnTouchMove(bb_touchevent_TouchEvent*);
	virtual void m_OnPauseLeaveGame();
	void mark();
};
class bb_gameoverscene_GameOverScene : public bb_scene_Scene{
	public:
	bb_sprite_Sprite* f_main;
	bb_sprite_Sprite* f_small;
	bb_gameoverscene_GameOverScene();
	bb_gameoverscene_GameOverScene* g_new();
	virtual void m_OnCreate(bb_director_Director*);
	virtual void m_OnRender();
	virtual void m_OnTouchDown(bb_touchevent_TouchEvent*);
	virtual void m_OnKeyDown(bb_keyevent_KeyEvent*);
	void mark();
};
class bb_pausescene_PauseScene : public bb_scene_Scene{
	public:
	bb_sprite_Sprite* f_overlay;
	bb_sprite_Sprite* f_continueBtn;
	bb_sprite_Sprite* f_quitBtn;
	bb_pausescene_PauseScene();
	bb_pausescene_PauseScene* g_new();
	virtual void m_OnCreate(bb_director_Director*);
	virtual void m_OnEnter();
	virtual void m_OnRender();
	virtual void m_OnKeyDown(bb_keyevent_KeyEvent*);
	virtual void m_OnTouchDown(bb_touchevent_TouchEvent*);
	void mark();
};
class bb_newhighscorescene_NewHighscoreScene : public bb_scene_Scene{
	public:
	bb_textinput_TextInput* f_input;
	int f_score;
	bb_gamehighscore_GameHighscore* f_highscore;
	bb_newhighscorescene_NewHighscoreScene();
	bb_newhighscorescene_NewHighscoreScene* g_new();
	virtual void m_OnCreate(bb_director_Director*);
	virtual void m_OnRender();
	virtual void m_SaveAndContinue();
	virtual void m_OnKeyDown(bb_keyevent_KeyEvent*);
	void mark();
};
class bb_app_App : public Object{
	public:
	bb_app_App();
	bb_app_App* g_new();
	virtual int m_OnCreate2();
	virtual int m_OnUpdate2();
	virtual int m_OnSuspend();
	virtual int m_OnResume2();
	virtual int m_OnRender();
	virtual int m_OnLoading();
	void mark();
};
class bb_sizeable_Sizeable : public virtual gc_interface{
	public:
	virtual bb_vector2d_Vector2D* m_center()=0;
};
class bb_director_Director : public bb_app_App,public virtual bb_sizeable_Sizeable{
	public:
	bb_vector2d_Vector2D* f__size;
	bb_vector2d_Vector2D* f__center;
	bb_vector2d_Vector2D* f__device;
	bb_vector2d_Vector2D* f__scale;
	bb_inputcontroller_InputController* f__inputController;
	bb_directorevents_DirectorEvents* f__handler;
	bool f_onCreateDispatched;
	bool f_appOnCreateCatched;
	bb_deltatimer_DeltaTimer* f_deltaTimer;
	bb_director_Director();
	virtual bb_vector2d_Vector2D* m_size();
	virtual void m_RecalculateScale();
	virtual void m_size2(bb_vector2d_Vector2D*);
	bb_director_Director* g_new(int,int);
	bb_director_Director* g_new2();
	virtual bb_inputcontroller_InputController* m_inputController();
	virtual void m_DispatchOnCreate();
	virtual void m_Run(bb_directorevents_DirectorEvents*);
	virtual bb_directorevents_DirectorEvents* m_handler();
	virtual bb_vector2d_Vector2D* m_center();
	virtual bb_vector2d_Vector2D* m_scale();
	virtual int m_OnCreate2();
	virtual int m_OnLoading();
	virtual int m_OnUpdate2();
	virtual int m_OnResume2();
	virtual int m_OnSuspend();
	virtual int m_OnRender();
	void mark();
};
class bb_list_List : public Object{
	public:
	bb_list_Node* f__head;
	bb_list_List();
	bb_list_List* g_new();
	virtual bb_list_Node* m_AddLast(String);
	bb_list_List* g_new2(Array<String >);
	virtual bool m_Equals(String,String);
	virtual bool m_Contains(String);
	void mark();
};
class bb_list_Node : public Object{
	public:
	bb_list_Node* f__succ;
	bb_list_Node* f__pred;
	String f__data;
	bb_list_Node();
	bb_list_Node* g_new(bb_list_Node*,bb_list_Node*,String);
	bb_list_Node* g_new2();
	void mark();
};
class bb_list_HeadNode : public bb_list_Node{
	public:
	bb_list_HeadNode();
	bb_list_HeadNode* g_new();
	void mark();
};
class bb_app_AppDevice : public gxtkApp{
	public:
	bb_app_App* f_app;
	int f_updateRate;
	bb_app_AppDevice();
	bb_app_AppDevice* g_new(bb_app_App*);
	bb_app_AppDevice* g_new2();
	virtual int OnCreate();
	virtual int OnUpdate();
	virtual int OnSuspend();
	virtual int OnResume();
	virtual int OnRender();
	virtual int OnLoading();
	virtual int SetUpdateRate(int);
	void mark();
};
class bb_graphics_GraphicsContext : public Object{
	public:
	gxtkGraphics* f_device;
	bb_graphics_Image* f_defaultFont;
	bb_graphics_Image* f_font;
	int f_firstChar;
	int f_matrixSp;
	Float f_ix;
	Float f_iy;
	Float f_jx;
	Float f_jy;
	Float f_tx;
	Float f_ty;
	int f_tformed;
	int f_matDirty;
	Float f_color_r;
	Float f_color_g;
	Float f_color_b;
	Float f_alpha;
	int f_blend;
	Float f_scissor_x;
	Float f_scissor_y;
	Float f_scissor_width;
	Float f_scissor_height;
	Array<Float > f_matrixStack;
	bb_graphics_GraphicsContext();
	bb_graphics_GraphicsContext* g_new(gxtkGraphics*);
	bb_graphics_GraphicsContext* g_new2();
	void mark();
};
extern bb_graphics_GraphicsContext* bb_graphics_context;
int bb_graphics_SetGraphicsContext(bb_graphics_GraphicsContext*);
extern gxtkInput* bb_input_device;
int bb_input_SetInputDevice(gxtkInput*);
extern gxtkAudio* bb_audio_device;
int bb_audio_SetAudioDevice(gxtkAudio*);
extern bb_app_AppDevice* bb_app_device;
class bb_vector2d_Vector2D : public Object{
	public:
	Float f_x;
	Float f_y;
	bb_vector2d_Vector2D();
	bb_vector2d_Vector2D* g_new(Float,Float);
	virtual bb_vector2d_Vector2D* m_Copy();
	virtual bb_vector2d_Vector2D* m_Div(bb_vector2d_Vector2D*);
	virtual bb_vector2d_Vector2D* m_Div2(Float);
	virtual bb_vector2d_Vector2D* m_Add2(bb_vector2d_Vector2D*);
	virtual bb_vector2d_Vector2D* m_Add3(Float);
	virtual bb_vector2d_Vector2D* m_Sub(bb_vector2d_Vector2D*);
	virtual bb_vector2d_Vector2D* m_Sub2(Float);
	virtual Float m_Length();
	virtual bb_vector2d_Vector2D* m_Normalize();
	virtual bb_vector2d_Vector2D* m_Mul(bb_vector2d_Vector2D*);
	virtual bb_vector2d_Vector2D* m_Mul2(Float);
	void mark();
};
class bb_inputcontroller_InputController : public Object{
	public:
	bool f_trackTouch;
	int f__touchFingers;
	int f_touchRetainSize;
	bb_vector2d_Vector2D* f_scale;
	Array<bool > f_isTouchDown;
	Array<bb_touchevent_TouchEvent* > f_touchEvents;
	Array<bool > f_touchDownDispatched;
	Float f_touchMinDistance;
	bool f_trackKeys;
	bool f_keyboardEnabled;
	bb_set_IntSet* f_keysActive;
	bb_map_IntMap2* f_keyEvents;
	bb_set_IntSet* f_dispatchedKeyEvents;
	bb_inputcontroller_InputController();
	bb_inputcontroller_InputController* g_new();
	virtual void m_touchFingers(int);
	virtual void m_ReadTouch();
	virtual void m_ProcessTouch(bb_directorevents_DirectorEvents*);
	virtual void m_ReadKeys();
	virtual void m_ProcessKeys(bb_directorevents_DirectorEvents*);
	virtual void m_OnUpdate3(bb_directorevents_DirectorEvents*);
	void mark();
};
int bbMain();
class bb_fanout_FanOut : public Object,public virtual bb_directorevents_DirectorEvents{
	public:
	bb_list_List2* f_objects;
	bb_fanout_FanOut();
	bb_fanout_FanOut* g_new();
	virtual void m_OnCreate(bb_director_Director*);
	virtual void m_Add4(bb_directorevents_DirectorEvents*);
	virtual void m_Remove(bb_directorevents_DirectorEvents*);
	virtual void m_Clear();
	virtual void m_OnLoading();
	virtual void m_OnUpdate(Float,Float);
	virtual void m_OnRender();
	virtual void m_OnSuspend();
	virtual void m_OnResume(int);
	virtual void m_OnKeyDown(bb_keyevent_KeyEvent*);
	virtual void m_OnKeyPress(bb_keyevent_KeyEvent*);
	virtual void m_OnKeyUp(bb_keyevent_KeyEvent*);
	virtual void m_OnTouchDown(bb_touchevent_TouchEvent*);
	virtual void m_OnTouchMove(bb_touchevent_TouchEvent*);
	virtual void m_OnTouchUp(bb_touchevent_TouchEvent*);
	virtual int m_Count();
	virtual bb_list_Enumerator* m_ObjectEnumerator();
	void mark();
};
class bb_list_List2 : public Object{
	public:
	bb_list_Node2* f__head;
	bb_list_List2();
	bb_list_List2* g_new();
	virtual bb_list_Node2* m_AddLast2(bb_directorevents_DirectorEvents*);
	bb_list_List2* g_new2(Array<bb_directorevents_DirectorEvents* >);
	virtual bb_list_Enumerator* m_ObjectEnumerator();
	virtual bool m_Equals2(bb_directorevents_DirectorEvents*,bb_directorevents_DirectorEvents*);
	virtual int m_RemoveEach(bb_directorevents_DirectorEvents*);
	virtual int m_Clear();
	virtual int m_Count();
	void mark();
};
class bb_list_Node2 : public Object{
	public:
	bb_list_Node2* f__succ;
	bb_list_Node2* f__pred;
	bb_directorevents_DirectorEvents* f__data;
	bb_list_Node2();
	bb_list_Node2* g_new(bb_list_Node2*,bb_list_Node2*,bb_directorevents_DirectorEvents*);
	bb_list_Node2* g_new2();
	virtual int m_Remove2();
	void mark();
};
class bb_list_HeadNode2 : public bb_list_Node2{
	public:
	bb_list_HeadNode2();
	bb_list_HeadNode2* g_new();
	void mark();
};
class bb_list_Enumerator : public Object{
	public:
	bb_list_List2* f__list;
	bb_list_Node2* f__curr;
	bb_list_Enumerator();
	bb_list_Enumerator* g_new(bb_list_List2*);
	bb_list_Enumerator* g_new2();
	virtual bool m_HasNext();
	virtual bb_directorevents_DirectorEvents* m_NextObject();
	void mark();
};
class bb_graphics_Image : public Object{
	public:
	gxtkSurface* f_surface;
	int f_width;
	int f_height;
	Array<bb_graphics_Frame* > f_frames;
	int f_flags;
	Float f_tx;
	Float f_ty;
	bb_graphics_Image* f_source;
	bb_graphics_Image();
	static int g_DefaultFlags;
	bb_graphics_Image* g_new();
	virtual int m_SetHandle(Float,Float);
	virtual int m_ApplyFlags(int);
	virtual bb_graphics_Image* m_Load(String,int,int);
	virtual bb_graphics_Image* m_Grab(int,int,int,int,int,int,bb_graphics_Image*);
	virtual bb_graphics_Image* m_GrabImage(int,int,int,int,int,int);
	virtual int m_Width();
	virtual int m_Height();
	void mark();
};
class bb_graphics_Frame : public Object{
	public:
	int f_x;
	int f_y;
	bb_graphics_Frame();
	bb_graphics_Frame* g_new(int,int);
	bb_graphics_Frame* g_new2();
	void mark();
};
bb_graphics_Image* bb_graphics_LoadImage(String,int,int);
bb_graphics_Image* bb_graphics_LoadImage2(String,int,int,int,int);
class bb_positionable_Positionable : public virtual gc_interface{
	public:
	virtual bb_vector2d_Vector2D* m_pos()=0;
	virtual void m_pos2(bb_vector2d_Vector2D*)=0;
};
class bb_baseobject_BaseObject : public bb_partial_Partial,public virtual bb_positionable_Positionable,public virtual bb_sizeable_Sizeable{
	public:
	bb_vector2d_Vector2D* f__pos;
	bb_vector2d_Vector2D* f__size;
	bb_vector2d_Vector2D* f__center;
	bb_baseobject_BaseObject();
	bb_baseobject_BaseObject* g_new();
	virtual bb_vector2d_Vector2D* m_pos();
	virtual void m_pos2(bb_vector2d_Vector2D*);
	virtual bb_vector2d_Vector2D* m_size();
	virtual void m_size2(bb_vector2d_Vector2D*);
	virtual bb_vector2d_Vector2D* m_center();
	virtual void m_CenterX(bb_sizeable_Sizeable*);
	virtual void m_Center(bb_sizeable_Sizeable*);
	void mark();
};
class bb_sprite_Sprite : public bb_baseobject_BaseObject{
	public:
	bb_graphics_Image* f_image;
	int f_frameCount;
	int f_frameSpeed;
	Float f_rotation;
	bb_vector2d_Vector2D* f_scale;
	int f_currentFrame;
	bool f_loopAnimation;
	int f_frameTimer;
	bb_sprite_Sprite();
	virtual void m_InitVectors(int,int,bb_vector2d_Vector2D*);
	bb_sprite_Sprite* g_new(String,bb_vector2d_Vector2D*);
	bb_sprite_Sprite* g_new2(String,int,int,int,int,bb_vector2d_Vector2D*);
	bb_sprite_Sprite* g_new3();
	virtual void m_OnRender();
	virtual bool m_animationIsDone();
	virtual void m_OnUpdate(Float,Float);
	virtual bool m_Collide(bb_vector2d_Vector2D*);
	virtual void m_Restart();
	void mark();
};
class bb_angelfont2_AngelFont : public Object{
	public:
	String f_iniText;
	bb_map_StringMap3* f_kernPairs;
	Array<bb_char_Char* > f_chars;
	int f_height;
	int f_heightOffset;
	bb_graphics_Image* f_image;
	String f_name;
	int f_xOffset;
	bool f_useKerning;
	bb_angelfont2_AngelFont();
	static String g_error;
	static bb_angelfont2_AngelFont* g_current;
	virtual void m_LoadFont(String);
	static bb_map_StringMap4* g__list;
	bb_angelfont2_AngelFont* g_new(String);
	virtual void m_DrawText(String,int,int);
	virtual int m_TextWidth(String);
	virtual void m_DrawText2(String,int,int,int);
	void mark();
};
String bb_app_LoadString(String);
class bb_kernpair_KernPair : public Object{
	public:
	String f_first;
	String f_second;
	int f_amount;
	bb_kernpair_KernPair();
	bb_kernpair_KernPair* g_new(int,int,int);
	bb_kernpair_KernPair* g_new2();
	void mark();
};
class bb_map_Map3 : public Object{
	public:
	bb_map_Node3* f_root;
	bb_map_Map3();
	bb_map_Map3* g_new();
	virtual int m_Compare(String,String)=0;
	virtual int m_RotateLeft3(bb_map_Node3*);
	virtual int m_RotateRight3(bb_map_Node3*);
	virtual int m_InsertFixup3(bb_map_Node3*);
	virtual bool m_Set3(String,bb_kernpair_KernPair*);
	virtual bool m_Insert(String,bb_kernpair_KernPair*);
	virtual bb_map_Node3* m_FindNode(String);
	virtual bool m_Contains(String);
	virtual bb_kernpair_KernPair* m_Get(String);
	void mark();
};
class bb_map_StringMap3 : public bb_map_Map3{
	public:
	bb_map_StringMap3();
	bb_map_StringMap3* g_new();
	virtual int m_Compare(String,String);
	void mark();
};
class bb_map_Node3 : public Object{
	public:
	String f_key;
	bb_map_Node3* f_right;
	bb_map_Node3* f_left;
	bb_kernpair_KernPair* f_value;
	int f_color;
	bb_map_Node3* f_parent;
	bb_map_Node3();
	bb_map_Node3* g_new(String,bb_kernpair_KernPair*,int,bb_map_Node3*);
	bb_map_Node3* g_new2();
	void mark();
};
class bb_char_Char : public Object{
	public:
	int f_x;
	int f_y;
	int f_width;
	int f_height;
	int f_xOffset;
	int f_yOffset;
	int f_xAdvance;
	bb_char_Char();
	bb_char_Char* g_new(int,int,int,int,int,int,int);
	bb_char_Char* g_new2();
	virtual int m_Draw(bb_graphics_Image*,int,int);
	void mark();
};
class bb_map_Map4 : public Object{
	public:
	bb_map_Node4* f_root;
	bb_map_Map4();
	bb_map_Map4* g_new();
	virtual int m_Compare(String,String)=0;
	virtual int m_RotateLeft4(bb_map_Node4*);
	virtual int m_RotateRight4(bb_map_Node4*);
	virtual int m_InsertFixup4(bb_map_Node4*);
	virtual bool m_Set4(String,bb_angelfont2_AngelFont*);
	virtual bool m_Insert2(String,bb_angelfont2_AngelFont*);
	void mark();
};
class bb_map_StringMap4 : public bb_map_Map4{
	public:
	bb_map_StringMap4();
	bb_map_StringMap4* g_new();
	virtual int m_Compare(String,String);
	void mark();
};
class bb_map_Node4 : public Object{
	public:
	String f_key;
	bb_map_Node4* f_right;
	bb_map_Node4* f_left;
	bb_angelfont2_AngelFont* f_value;
	int f_color;
	bb_map_Node4* f_parent;
	bb_map_Node4();
	bb_map_Node4* g_new(String,bb_angelfont2_AngelFont*,int,bb_map_Node4*);
	bb_map_Node4* g_new2();
	void mark();
};
class bb_persistable_Persistable : public virtual gc_interface{
	public:
	virtual void m_FromString(String)=0;
	virtual String m_ToString()=0;
};
class bb_highscore_Highscore : public Object,public virtual bb_persistable_Persistable{
	public:
	int f__maxCount;
	bb_list_List3* f_objects;
	bb_highscore_Highscore();
	bb_highscore_Highscore* g_new(int);
	bb_highscore_Highscore* g_new2();
	virtual int m_Count();
	virtual int m_maxCount();
	virtual void m_Sort();
	virtual void m_SizeTrim();
	virtual void m_Add5(String,int);
	virtual bb_score_Score* m_Last();
	virtual void m_FromString(String);
	virtual bb_list_Enumerator2* m_ObjectEnumerator();
	virtual String m_ToString();
	void mark();
};
class bb_highscore_IntHighscore : public bb_highscore_Highscore{
	public:
	bb_highscore_IntHighscore();
	bb_highscore_IntHighscore* g_new(int);
	bb_highscore_IntHighscore* g_new2();
	void mark();
};
class bb_gamehighscore_GameHighscore : public bb_highscore_IntHighscore{
	public:
	bb_gamehighscore_GameHighscore();
	static Array<String > g_names;
	static Array<int > g_scores;
	virtual void m_LoadNamesAndScores();
	virtual void m_PrefillMissing();
	bb_gamehighscore_GameHighscore* g_new();
	virtual void m_FromString(String);
	void mark();
};
class bb_score_Score : public Object{
	public:
	String f_key;
	int f_value;
	bb_score_Score();
	bb_score_Score* g_new(String,int);
	bb_score_Score* g_new2();
	void mark();
};
class bb_list_List3 : public Object{
	public:
	bb_list_Node3* f__head;
	bb_list_List3();
	bb_list_List3* g_new();
	virtual bb_list_Node3* m_AddLast3(bb_score_Score*);
	bb_list_List3* g_new2(Array<bb_score_Score* >);
	virtual int m_Count();
	virtual bb_score_Score* m_First();
	virtual bb_list_Enumerator2* m_ObjectEnumerator();
	virtual bb_list_Node3* m_AddFirst(bb_score_Score*);
	virtual bool m_Equals3(bb_score_Score*,bb_score_Score*);
	virtual int m_RemoveEach2(bb_score_Score*);
	virtual int m_Remove3(bb_score_Score*);
	virtual int m_Clear();
	virtual bb_score_Score* m_RemoveLast();
	virtual bb_score_Score* m_Last();
	void mark();
};
class bb_list_Node3 : public Object{
	public:
	bb_list_Node3* f__succ;
	bb_list_Node3* f__pred;
	bb_score_Score* f__data;
	bb_list_Node3();
	bb_list_Node3* g_new(bb_list_Node3*,bb_list_Node3*,bb_score_Score*);
	bb_list_Node3* g_new2();
	virtual bb_list_Node3* m_GetNode();
	virtual bb_list_Node3* m_NextNode();
	virtual int m_Remove2();
	virtual bb_list_Node3* m_PrevNode();
	void mark();
};
class bb_list_HeadNode3 : public bb_list_Node3{
	public:
	bb_list_HeadNode3();
	bb_list_HeadNode3* g_new();
	virtual bb_list_Node3* m_GetNode();
	void mark();
};
class bb_list_Enumerator2 : public Object{
	public:
	bb_list_List3* f__list;
	bb_list_Node3* f__curr;
	bb_list_Enumerator2();
	bb_list_Enumerator2* g_new(bb_list_List3*);
	bb_list_Enumerator2* g_new2();
	virtual bool m_HasNext();
	virtual bb_score_Score* m_NextObject();
	void mark();
};
class bb_statestore_StateStore : public Object{
	public:
	bb_statestore_StateStore();
	static void g_Load(bb_persistable_Persistable*);
	static void g_Save(bb_persistable_Persistable*);
	void mark();
};
String bb_app_LoadState();
class bb_chute_Chute : public bb_baseobject_BaseObject{
	public:
	int f_height;
	bb_graphics_Image* f_bg;
	int f_width;
	bb_graphics_Image* f_bottom;
	bb_severity_Severity* f_severity;
	bb_chute_Chute();
	bb_chute_Chute* g_new();
	virtual void m_Restart();
	virtual void m_OnCreate(bb_director_Director*);
	virtual void m_OnUpdate(Float,Float);
	virtual void m_OnRender();
	virtual int m_Height();
	void mark();
};
class bb_severity_Severity : public Object{
	public:
	int f_nextChuteAdvanceTime;
	int f_nextShapeDropTime;
	int f_lastTime;
	int f_level;
	int f_activatedShapes;
	int f_slowDownDuration;
	bb_stack_IntStack* f_lastTypes;
	Float f_progress;
	Array<int > f_shapeTypes;
	int f_startTime;
	Array<int > f_laneTimes;
	bb_severity_Severity();
	bb_severity_Severity* g_new();
	virtual void m_WarpTime(int);
	virtual void m_ChuteMarkAsAdvanced();
	virtual void m_ShapeDropped();
	virtual void m_RandomizeShapeTypes();
	virtual void m_Restart();
	virtual int m_MinSliderTypes();
	virtual void m_ConfigureSlider(bb_list_IntList*);
	virtual bool m_ChuteShouldAdvance();
	virtual int m_ChuteAdvanceHeight();
	virtual void m_Set5(int);
	virtual void m_OnUpdate(Float,Float);
	virtual bool m_ShapeShouldBeDropped();
	virtual int m_RandomType();
	virtual int m_RandomLane();
	virtual String m_ToString();
	void mark();
};
extern bb_severity_Severity* bb_severity_globalSeverityInstance;
bb_severity_Severity* bb_severity_CurrentSeverity();
class bb_slider_Slider : public bb_baseobject_BaseObject{
	public:
	Array<bb_graphics_Image* > f_images;
	bb_list_IntList* f_config;
	Array<int > f_configArray;
	bool f_movementActive;
	int f_movementStart;
	bb_sprite_Sprite* f_arrowLeft;
	bb_sprite_Sprite* f_arrowRight;
	Float f_posY;
	int f_direction;
	bb_slider_Slider();
	bb_slider_Slider* g_new();
	virtual void m_InitializeConfig();
	virtual void m_Restart();
	virtual void m_OnCreate(bb_director_Director*);
	virtual bb_vector2d_Vector2D* m_pos();
	virtual Float m_GetMovementOffset();
	virtual void m_OnRender();
	virtual bool m_Match(bb_shape_Shape*);
	virtual void m_SlideLeft();
	virtual void m_SlideRight();
	void mark();
};
class bb_font_Font : public bb_baseobject_BaseObject{
	public:
	String f_name;
	int f__align;
	String f__text;
	bb_map_StringMap5* f_fontStore;
	bool f_recalculateSize;
	bb_color_Color* f_color;
	bb_font_Font();
	bb_font_Font* g_new(String,bb_vector2d_Vector2D*);
	bb_font_Font* g_new2();
	virtual void m_align(int);
	virtual int m_align2();
	virtual bb_angelfont_AngelFont* m_font();
	virtual void m_text(String);
	virtual String m_text2();
	virtual void m_OnCreate(bb_director_Director*);
	virtual void m_OnRender();
	void mark();
};
class bb_angelfont_AngelFont : public Object{
	public:
	Array<bb_char_Char* > f_chars;
	bool f_useKerning;
	bb_map_StringMap3* f_kernPairs;
	String f_iniText;
	int f_height;
	int f_heightOffset;
	bb_graphics_Image* f_image;
	String f_name;
	int f_xOffset;
	bb_angelfont_AngelFont();
	virtual int m_TextWidth(String);
	virtual int m_TextHeight(String);
	static String g_error;
	static bb_angelfont_AngelFont* g_current;
	virtual void m_LoadFont(String);
	static bb_map_StringMap5* g__list;
	bb_angelfont_AngelFont* g_new(String);
	virtual void m_DrawText(String,int,int);
	virtual void m_DrawText2(String,int,int,int);
	void mark();
};
class bb_map_Map5 : public Object{
	public:
	bb_map_Node5* f_root;
	bb_map_Map5();
	bb_map_Map5* g_new();
	virtual int m_Compare(String,String)=0;
	virtual bb_map_Node5* m_FindNode(String);
	virtual bb_angelfont_AngelFont* m_Get(String);
	virtual bool m_Contains(String);
	virtual int m_RotateLeft5(bb_map_Node5*);
	virtual int m_RotateRight5(bb_map_Node5*);
	virtual int m_InsertFixup5(bb_map_Node5*);
	virtual bool m_Set6(String,bb_angelfont_AngelFont*);
	virtual bool m_Insert3(String,bb_angelfont_AngelFont*);
	void mark();
};
class bb_map_StringMap5 : public bb_map_Map5{
	public:
	bb_map_StringMap5();
	bb_map_StringMap5* g_new();
	virtual int m_Compare(String,String);
	void mark();
};
class bb_map_Node5 : public Object{
	public:
	String f_key;
	bb_map_Node5* f_right;
	bb_map_Node5* f_left;
	bb_angelfont_AngelFont* f_value;
	int f_color;
	bb_map_Node5* f_parent;
	bb_map_Node5();
	bb_map_Node5* g_new(String,bb_angelfont_AngelFont*,int,bb_map_Node5*);
	bb_map_Node5* g_new2();
	void mark();
};
class bb_animation_Animation : public bb_fanout_FanOut{
	public:
	Float f_startValue;
	Float f_endValue;
	Float f_duration;
	bb_fader_Fader* f_effect;
	bb_transition_Transition* f_transition;
	bool f_finished;
	Float f_animationTime;
	Float f__value;
	bb_animation_Animation();
	bb_animation_Animation* g_new(Float,Float,Float);
	bb_animation_Animation* g_new2();
	virtual void m_Pause();
	virtual void m_OnUpdate(Float,Float);
	virtual void m_OnRender();
	virtual void m_Play();
	virtual void m_Restart();
	virtual bool m_IsPlaying();
	void mark();
};
class bb_fader_Fader : public virtual gc_interface{
	public:
	virtual void m_PreRender(Float)=0;
	virtual void m_PreNode(Float,bb_directorevents_DirectorEvents*)=0;
	virtual void m_PostNode(Float,bb_directorevents_DirectorEvents*)=0;
	virtual void m_PostRender(Float)=0;
};
class bb_fader_FaderScale : public Object,public virtual bb_fader_Fader{
	public:
	bb_sizeable_Sizeable* f_sizeNode;
	Float f_offsetX;
	Float f_offsetY;
	bb_positionable_Positionable* f_posNode;
	bb_fader_FaderScale();
	bb_fader_FaderScale* g_new();
	virtual void m_PreRender(Float);
	virtual void m_PostRender(Float);
	virtual void m_PreNode(Float,bb_directorevents_DirectorEvents*);
	virtual void m_PostNode(Float,bb_directorevents_DirectorEvents*);
	void mark();
};
class bb_transition_Transition : public virtual gc_interface{
	public:
	virtual Float m_Calculate(Float)=0;
};
class bb_transition_TransitionInCubic : public Object,public virtual bb_transition_Transition{
	public:
	bb_transition_TransitionInCubic();
	bb_transition_TransitionInCubic* g_new();
	virtual Float m_Calculate(Float);
	void mark();
};
class bb_transition_TransitionLinear : public Object,public virtual bb_transition_Transition{
	public:
	bb_transition_TransitionLinear();
	bb_transition_TransitionLinear* g_new();
	virtual Float m_Calculate(Float);
	void mark();
};
int bb_app_Millisecs();
class bb_stack_Stack : public Object{
	public:
	Array<int > f_data;
	int f_length;
	bb_stack_Stack();
	bb_stack_Stack* g_new();
	bb_stack_Stack* g_new2(Array<int >);
	virtual int m_Clear();
	virtual int m_Length();
	virtual int m_Get2(int);
	virtual int m_Remove4(int);
	virtual int m_Push(int);
	void mark();
};
class bb_stack_IntStack : public bb_stack_Stack{
	public:
	bb_stack_IntStack();
	bb_stack_IntStack* g_new();
	void mark();
};
extern int bb_random_Seed;
Float bb_random_Rnd();
Float bb_random_Rnd2(Float,Float);
Float bb_random_Rnd3(Float);
class bb_list_List4 : public Object{
	public:
	bb_list_Node4* f__head;
	bb_list_List4();
	bb_list_List4* g_new();
	virtual bb_list_Node4* m_AddLast4(int);
	bb_list_List4* g_new2(Array<int >);
	virtual int m_Clear();
	virtual int m_Count();
	virtual bb_list_Enumerator3* m_ObjectEnumerator();
	virtual Array<int > m_ToArray();
	virtual int m_First();
	virtual int m_RemoveFirst();
	virtual int m_Last();
	virtual int m_RemoveLast();
	virtual bb_list_Node4* m_AddFirst2(int);
	void mark();
};
class bb_list_IntList : public bb_list_List4{
	public:
	bb_list_IntList();
	bb_list_IntList* g_new();
	void mark();
};
class bb_list_Node4 : public Object{
	public:
	bb_list_Node4* f__succ;
	bb_list_Node4* f__pred;
	int f__data;
	bb_list_Node4();
	bb_list_Node4* g_new(bb_list_Node4*,bb_list_Node4*,int);
	bb_list_Node4* g_new2();
	virtual bb_list_Node4* m_GetNode();
	virtual bb_list_Node4* m_NextNode();
	virtual int m_Remove2();
	virtual bb_list_Node4* m_PrevNode();
	void mark();
};
class bb_list_HeadNode4 : public bb_list_Node4{
	public:
	bb_list_HeadNode4();
	bb_list_HeadNode4* g_new();
	virtual bb_list_Node4* m_GetNode();
	void mark();
};
class bb_set_Set : public Object{
	public:
	bb_map_Map6* f_map;
	bb_set_Set();
	bb_set_Set* g_new(bb_map_Map6*);
	bb_set_Set* g_new2();
	virtual int m_Insert4(int);
	virtual int m_Count();
	virtual int m_Clear();
	virtual int m_Remove4(int);
	virtual bool m_Contains2(int);
	void mark();
};
class bb_set_IntSet : public bb_set_Set{
	public:
	bb_set_IntSet();
	bb_set_IntSet* g_new();
	void mark();
};
class bb_map_Map6 : public Object{
	public:
	bb_map_Node6* f_root;
	bb_map_Map6();
	bb_map_Map6* g_new();
	virtual int m_Compare2(int,int)=0;
	virtual int m_RotateLeft6(bb_map_Node6*);
	virtual int m_RotateRight6(bb_map_Node6*);
	virtual int m_InsertFixup6(bb_map_Node6*);
	virtual bool m_Set7(int,Object*);
	virtual bool m_Insert5(int,Object*);
	virtual int m_Count();
	virtual int m_Clear();
	virtual bb_map_Node6* m_FindNode2(int);
	virtual int m_DeleteFixup(bb_map_Node6*,bb_map_Node6*);
	virtual int m_RemoveNode(bb_map_Node6*);
	virtual int m_Remove4(int);
	virtual bool m_Contains2(int);
	void mark();
};
class bb_map_IntMap : public bb_map_Map6{
	public:
	bb_map_IntMap();
	bb_map_IntMap* g_new();
	virtual int m_Compare2(int,int);
	void mark();
};
class bb_map_Node6 : public Object{
	public:
	int f_key;
	bb_map_Node6* f_right;
	bb_map_Node6* f_left;
	Object* f_value;
	int f_color;
	bb_map_Node6* f_parent;
	bb_map_Node6();
	bb_map_Node6* g_new(int,Object*,int,bb_map_Node6*);
	bb_map_Node6* g_new2();
	virtual int m_Count2(int);
	void mark();
};
class bb_list_Enumerator3 : public Object{
	public:
	bb_list_List4* f__list;
	bb_list_Node4* f__curr;
	bb_list_Enumerator3();
	bb_list_Enumerator3* g_new(bb_list_List4*);
	bb_list_Enumerator3* g_new2();
	virtual bool m_HasNext();
	virtual int m_NextObject();
	void mark();
};
class bb_textinput_TextInput : public bb_font_Font{
	public:
	int f_cursorPos;
	bb_textinput_TextInput();
	bb_textinput_TextInput* g_new(String,bb_vector2d_Vector2D*);
	bb_textinput_TextInput* g_new2();
	virtual void m_MoveCursorRight();
	virtual void m_InsertChar(String);
	virtual void m_MoveCursorLeft();
	virtual void m_RemoveChar();
	virtual void m_OnKeyUp(bb_keyevent_KeyEvent*);
	void mark();
};
int bb_graphics_SetFont(bb_graphics_Image*,int);
extern gxtkGraphics* bb_graphics_renderDevice;
int bb_graphics_SetMatrix(Float,Float,Float,Float,Float,Float);
int bb_graphics_SetMatrix2(Array<Float >);
int bb_graphics_SetColor(Float,Float,Float);
int bb_graphics_SetAlpha(Float);
int bb_graphics_SetBlend(int);
int bb_graphics_DeviceWidth();
int bb_graphics_DeviceHeight();
int bb_graphics_SetScissor(Float,Float,Float,Float);
int bb_graphics_BeginRender();
int bb_graphics_EndRender();
class bb_deltatimer_DeltaTimer : public Object{
	public:
	Float f_targetFps;
	Float f_lastTicks;
	Float f_currentTicks;
	Float f__frameTime;
	Float f__delta;
	bb_deltatimer_DeltaTimer();
	bb_deltatimer_DeltaTimer* g_new(Float);
	bb_deltatimer_DeltaTimer* g_new2();
	virtual Float m_frameTime();
	virtual void m_OnUpdate2();
	virtual Float m_delta();
	void mark();
};
int bb_app_SetUpdateRate(int);
int bb_input_TouchDown(int);
class bb_touchevent_TouchEvent : public Object{
	public:
	int f__finger;
	int f__startTime;
	bb_list_List5* f_positions;
	int f__endTime;
	bb_touchevent_TouchEvent();
	bb_touchevent_TouchEvent* g_new(int);
	bb_touchevent_TouchEvent* g_new2();
	virtual bb_vector2d_Vector2D* m_startPos();
	virtual bb_vector2d_Vector2D* m_prevPos();
	virtual void m_Add2(bb_vector2d_Vector2D*);
	virtual void m_Trim(int);
	virtual bb_vector2d_Vector2D* m_pos();
	virtual bb_touchevent_TouchEvent* m_Copy();
	virtual bb_vector2d_Vector2D* m_startDelta();
	void mark();
};
Float bb_input_TouchX(int);
Float bb_input_TouchY(int);
class bb_list_List5 : public Object{
	public:
	bb_list_Node5* f__head;
	bb_list_List5();
	bb_list_List5* g_new();
	virtual bb_list_Node5* m_AddLast5(bb_vector2d_Vector2D*);
	bb_list_List5* g_new2(Array<bb_vector2d_Vector2D* >);
	virtual int m_Count();
	virtual bb_vector2d_Vector2D* m_First();
	virtual bb_list_Node5* m_LastNode();
	virtual int m_Clear();
	virtual bb_vector2d_Vector2D* m_RemoveFirst();
	virtual bb_vector2d_Vector2D* m_Last();
	void mark();
};
class bb_list_Node5 : public Object{
	public:
	bb_list_Node5* f__succ;
	bb_list_Node5* f__pred;
	bb_vector2d_Vector2D* f__data;
	bb_list_Node5();
	bb_list_Node5* g_new(bb_list_Node5*,bb_list_Node5*,bb_vector2d_Vector2D*);
	bb_list_Node5* g_new2();
	virtual bb_list_Node5* m_GetNode();
	virtual bb_list_Node5* m_NextNode();
	virtual bb_list_Node5* m_PrevNode();
	virtual bb_vector2d_Vector2D* m_Value();
	virtual int m_Remove2();
	void mark();
};
class bb_list_HeadNode5 : public bb_list_Node5{
	public:
	bb_list_HeadNode5();
	bb_list_HeadNode5* g_new();
	virtual bb_list_Node5* m_GetNode();
	void mark();
};
int bb_input_EnableKeyboard();
int bb_input_GetChar();
class bb_keyevent_KeyEvent : public Object{
	public:
	int f__code;
	String f__char;
	bb_keyevent_KeyEvent();
	bb_keyevent_KeyEvent* g_new(int);
	bb_keyevent_KeyEvent* g_new2();
	virtual int m_code();
	virtual String m_char();
	void mark();
};
class bb_map_Map7 : public Object{
	public:
	bb_map_Node7* f_root;
	bb_map_Map7();
	bb_map_Map7* g_new();
	virtual int m_Compare2(int,int)=0;
	virtual bb_map_Node7* m_FindNode2(int);
	virtual bool m_Contains2(int);
	virtual int m_RotateLeft7(bb_map_Node7*);
	virtual int m_RotateRight7(bb_map_Node7*);
	virtual int m_InsertFixup7(bb_map_Node7*);
	virtual bool m_Add6(int,bb_keyevent_KeyEvent*);
	virtual bb_map_MapValues* m_Values();
	virtual bb_map_Node7* m_FirstNode();
	virtual int m_DeleteFixup2(bb_map_Node7*,bb_map_Node7*);
	virtual int m_RemoveNode2(bb_map_Node7*);
	virtual int m_Remove4(int);
	virtual int m_Clear();
	void mark();
};
class bb_map_IntMap2 : public bb_map_Map7{
	public:
	bb_map_IntMap2();
	bb_map_IntMap2* g_new();
	virtual int m_Compare2(int,int);
	void mark();
};
class bb_map_Node7 : public Object{
	public:
	int f_key;
	bb_map_Node7* f_right;
	bb_map_Node7* f_left;
	bb_keyevent_KeyEvent* f_value;
	int f_color;
	bb_map_Node7* f_parent;
	bb_map_Node7();
	bb_map_Node7* g_new(int,bb_keyevent_KeyEvent*,int,bb_map_Node7*);
	bb_map_Node7* g_new2();
	virtual bb_map_Node7* m_NextNode();
	void mark();
};
class bb_map_MapValues : public Object{
	public:
	bb_map_Map7* f_map;
	bb_map_MapValues();
	bb_map_MapValues* g_new(bb_map_Map7*);
	bb_map_MapValues* g_new2();
	virtual bb_map_ValueEnumerator* m_ObjectEnumerator();
	void mark();
};
class bb_map_ValueEnumerator : public Object{
	public:
	bb_map_Node7* f_node;
	bb_map_ValueEnumerator();
	bb_map_ValueEnumerator* g_new(bb_map_Node7*);
	bb_map_ValueEnumerator* g_new2();
	virtual bool m_HasNext();
	virtual bb_keyevent_KeyEvent* m_NextObject();
	void mark();
};
int bb_input_DisableKeyboard();
int bb_graphics_PushMatrix();
int bb_graphics_Transform(Float,Float,Float,Float,Float,Float);
int bb_graphics_Transform2(Array<Float >);
int bb_graphics_Scale(Float,Float);
int bb_graphics_Cls(Float,Float,Float);
int bb_graphics_PopMatrix();
int bb_graphics_Translate(Float,Float);
int bb_graphics_ValidateMatrix();
int bb_graphics_DrawImage(bb_graphics_Image*,Float,Float,int);
int bb_graphics_Rotate(Float);
int bb_graphics_DrawImage2(bb_graphics_Image*,Float,Float,Float,Float,Float,int);
int bb_graphics_DrawRect(Float,Float,Float,Float);
class bb_color_Color : public Object{
	public:
	bb_color_Color* f_oldColor;
	Float f_red;
	Float f_green;
	Float f_blue;
	Float f_alpha;
	bb_color_Color();
	bb_color_Color* g_new(Float,Float,Float,Float);
	bb_color_Color* g_new2();
	virtual void m_Set8(bb_color_Color*);
	virtual void m_Activate();
	virtual void m_Deactivate();
	void mark();
};
Array<Float > bb_graphics_GetColor();
Float bb_graphics_GetAlpha();
int bb_graphics_DrawImageRect(bb_graphics_Image*,Float,Float,int,int,int,int,int);
int bb_graphics_DrawImageRect2(bb_graphics_Image*,Float,Float,int,int,int,int,Float,Float,Float,int);
int bb_math_Min(int,int);
Float bb_math_Min2(Float,Float);
class bb_shape_Shape : public bb_baseobject_BaseObject{
	public:
	int f_type;
	int f_lane;
	bb_chute_Chute* f_chute;
	bool f_isFast;
	bb_shape_Shape();
	static Array<bb_graphics_Image* > g_images;
	static bb_vector2d_Vector2D* g_SPEED_SLOW;
	static bb_vector2d_Vector2D* g_SPEED_FAST;
	bb_shape_Shape* g_new(int,int,bb_chute_Chute*);
	bb_shape_Shape* g_new2();
	virtual void m_OnUpdate(Float,Float);
	virtual void m_OnRender();
	void mark();
};
class bb_stack_Stack2 : public Object{
	public:
	Array<bb_sprite_Sprite* > f_data;
	int f_length;
	bb_stack_Stack2();
	bb_stack_Stack2* g_new();
	bb_stack_Stack2* g_new2(Array<bb_sprite_Sprite* >);
	virtual int m_Length();
	virtual bb_sprite_Sprite* m_Pop();
	virtual int m_Push2(bb_sprite_Sprite*);
	void mark();
};
int bb_math_Max(int,int);
Float bb_math_Max2(Float,Float);
int bb_math_Abs(int);
Float bb_math_Abs2(Float);
int bb_app_SaveState(String);
bb_router_Router::bb_router_Router(){
	f_handlers=(new bb_map_StringMap)->g_new();
	f_routers=(new bb_map_StringMap2)->g_new();
	f__currentName=String();
	f__current=0;
	f__previous=0;
	f__previousName=String();
	f_director=0;
	f_created=(new bb_list_List)->g_new();
}
bb_router_Router* bb_router_Router::g_new(){
	return this;
}
void bb_router_Router::m_Add(String t_name,bb_directorevents_DirectorEvents* t_handler){
	if(f_handlers->m_Contains(t_name)){
		Error(String(L"Router already contains a handler named ")+t_name);
	}
	f_handlers->m_Set(t_name,t_handler);
	f_routers->m_Set2(t_name,dynamic_cast<bb_routerevents_RouterEvents*>(t_handler));
}
bb_directorevents_DirectorEvents* bb_router_Router::m_Get(String t_name){
	if(!f_handlers->m_Contains(t_name)){
		Error(String(L"Router has no handler named ")+t_name);
	}
	return f_handlers->m_Get(t_name);
}
void bb_router_Router::m_DispatchOnCreate(){
	if(!((f_director)!=0)){
		return;
	}
	if(!((f__current)!=0)){
		return;
	}
	if(f_created->m_Contains(f__currentName)){
		return;
	}
	f__current->m_OnCreate(f_director);
	f_created->m_AddLast(f__currentName);
}
void bb_router_Router::m_Goto(String t_name){
	if(t_name==f__currentName){
		return;
	}
	gc_assign(f__previous,f__current);
	f__previousName=f__currentName;
	gc_assign(f__current,m_Get(t_name));
	f__currentName=t_name;
	m_DispatchOnCreate();
	bb_routerevents_RouterEvents* t_tmpRouter=f_routers->m_Get(f__previousName);
	if((t_tmpRouter)!=0){
		t_tmpRouter->m_OnLeave();
	}
	t_tmpRouter=f_routers->m_Get(f__currentName);
	if((t_tmpRouter)!=0){
		t_tmpRouter->m_OnEnter();
	}
}
void bb_router_Router::m_OnCreate(bb_director_Director* t_director){
	gc_assign(this->f_director,t_director);
	m_DispatchOnCreate();
}
void bb_router_Router::m_OnLoading(){
	if((f__current)!=0){
		f__current->m_OnLoading();
	}
}
void bb_router_Router::m_OnUpdate(Float t_delta,Float t_frameTime){
	if((f__current)!=0){
		f__current->m_OnUpdate(t_delta,t_frameTime);
	}
}
void bb_router_Router::m_OnRender(){
	if((f__current)!=0){
		f__current->m_OnRender();
	}
}
void bb_router_Router::m_OnSuspend(){
	if((f__current)!=0){
		f__current->m_OnSuspend();
	}
}
void bb_router_Router::m_OnResume(int t_delta){
	if((f__current)!=0){
		f__current->m_OnResume(t_delta);
	}
}
void bb_router_Router::m_OnKeyDown(bb_keyevent_KeyEvent* t_event){
	if((f__current)!=0){
		f__current->m_OnKeyDown(t_event);
	}
}
void bb_router_Router::m_OnKeyPress(bb_keyevent_KeyEvent* t_event){
	if((f__current)!=0){
		f__current->m_OnKeyPress(t_event);
	}
}
void bb_router_Router::m_OnKeyUp(bb_keyevent_KeyEvent* t_event){
	if((f__current)!=0){
		f__current->m_OnKeyUp(t_event);
	}
}
void bb_router_Router::m_OnTouchDown(bb_touchevent_TouchEvent* t_event){
	if((f__current)!=0){
		f__current->m_OnTouchDown(t_event);
	}
}
void bb_router_Router::m_OnTouchMove(bb_touchevent_TouchEvent* t_event){
	if((f__current)!=0){
		f__current->m_OnTouchMove(t_event);
	}
}
void bb_router_Router::m_OnTouchUp(bb_touchevent_TouchEvent* t_event){
	if((f__current)!=0){
		f__current->m_OnTouchUp(t_event);
	}
}
bb_directorevents_DirectorEvents* bb_router_Router::m_previous(){
	return f__previous;
}
String bb_router_Router::m_previousName(){
	return f__previousName;
}
void bb_router_Router::mark(){
	Object::mark();
	gc_mark_q(f_handlers);
	gc_mark_q(f_routers);
	gc_mark_q(f__current);
	gc_mark_q(f__previous);
	gc_mark_q(f_director);
	gc_mark_q(f_created);
}
bb_partial_Partial::bb_partial_Partial(){
	f__director=0;
}
bb_partial_Partial* bb_partial_Partial::g_new(){
	return this;
}
void bb_partial_Partial::m_OnCreate(bb_director_Director* t_director){
	gc_assign(f__director,t_director);
}
bb_director_Director* bb_partial_Partial::m_director(){
	return f__director;
}
void bb_partial_Partial::m_OnRender(){
}
void bb_partial_Partial::m_OnUpdate(Float t_delta,Float t_frameTime){
}
void bb_partial_Partial::m_OnKeyUp(bb_keyevent_KeyEvent* t_event){
}
void bb_partial_Partial::m_OnLoading(){
}
void bb_partial_Partial::m_OnSuspend(){
}
void bb_partial_Partial::m_OnResume(int t_delta){
}
void bb_partial_Partial::m_OnKeyDown(bb_keyevent_KeyEvent* t_event){
}
void bb_partial_Partial::m_OnKeyPress(bb_keyevent_KeyEvent* t_event){
}
void bb_partial_Partial::m_OnTouchDown(bb_touchevent_TouchEvent* t_event){
}
void bb_partial_Partial::m_OnTouchMove(bb_touchevent_TouchEvent* t_event){
}
void bb_partial_Partial::m_OnTouchUp(bb_touchevent_TouchEvent* t_event){
}
void bb_partial_Partial::mark(){
	Object::mark();
	gc_mark_q(f__director);
}
bb_scene_Scene::bb_scene_Scene(){
	f__layer=(new bb_fanout_FanOut)->g_new();
	f__router=0;
}
bb_scene_Scene* bb_scene_Scene::g_new(){
	bb_partial_Partial::g_new();
	return this;
}
void bb_scene_Scene::m_OnEnter(){
}
void bb_scene_Scene::m_OnLeave(){
}
bb_graphics_Image* bb_scene_Scene::g_blend;
void bb_scene_Scene::m_OnCreate(bb_director_Director* t_director){
	bb_partial_Partial::m_OnCreate(t_director);
	f__layer->m_OnCreate(t_director);
	gc_assign(f__router,dynamic_cast<bb_router_Router*>(t_director->m_handler()));
	if(!((g_blend)!=0)){
		gc_assign(g_blend,bb_graphics_LoadImage(String(L"blend.png"),1,bb_graphics_Image::g_DefaultFlags));
	}
}
bb_fanout_FanOut* bb_scene_Scene::m_layer(){
	return f__layer;
}
void bb_scene_Scene::m_OnLoading(){
	f__layer->m_OnLoading();
}
void bb_scene_Scene::m_OnUpdate(Float t_delta,Float t_frameTime){
	f__layer->m_OnUpdate(t_delta,t_frameTime);
}
void bb_scene_Scene::m_OnRender(){
	f__layer->m_OnRender();
}
void bb_scene_Scene::m_OnSuspend(){
	f__layer->m_OnSuspend();
}
void bb_scene_Scene::m_OnResume(int t_delta){
	f__layer->m_OnResume(t_delta);
}
void bb_scene_Scene::m_OnKeyDown(bb_keyevent_KeyEvent* t_event){
	f__layer->m_OnKeyDown(t_event);
}
void bb_scene_Scene::m_OnKeyPress(bb_keyevent_KeyEvent* t_event){
	f__layer->m_OnKeyPress(t_event);
}
void bb_scene_Scene::m_OnKeyUp(bb_keyevent_KeyEvent* t_event){
	f__layer->m_OnKeyUp(t_event);
}
void bb_scene_Scene::m_OnTouchDown(bb_touchevent_TouchEvent* t_event){
	f__layer->m_OnTouchDown(t_event);
}
void bb_scene_Scene::m_OnTouchMove(bb_touchevent_TouchEvent* t_event){
	f__layer->m_OnTouchMove(t_event);
}
void bb_scene_Scene::m_OnTouchUp(bb_touchevent_TouchEvent* t_event){
	f__layer->m_OnTouchUp(t_event);
}
bb_router_Router* bb_scene_Scene::m_router(){
	return f__router;
}
void bb_scene_Scene::m_RenderBlend(){
	for(int t_posY=0;Float(t_posY)<m_director()->m_size()->f_y;t_posY=t_posY+8){
		bb_graphics_DrawImage(g_blend,FLOAT(0.0),Float(t_posY),0);
	}
}
void bb_scene_Scene::mark(){
	bb_partial_Partial::mark();
	gc_mark_q(f__layer);
	gc_mark_q(f__router);
}
bb_introscene_IntroScene::bb_introscene_IntroScene(){
}
bb_introscene_IntroScene* bb_introscene_IntroScene::g_new(){
	bb_scene_Scene::g_new();
	return this;
}
void bb_introscene_IntroScene::m_OnCreate(bb_director_Director* t_director){
	bb_scene_Scene::m_OnCreate(t_director);
}
void bb_introscene_IntroScene::m_OnUpdate(Float t_delta,Float t_frameTime){
	m_router()->m_Goto(String(L"menu"));
}
void bb_introscene_IntroScene::m_OnRender(){
	bb_graphics_Cls(FLOAT(255.0),FLOAT(255.0),FLOAT(255.0));
	bb_scene_Scene::m_OnRender();
}
void bb_introscene_IntroScene::mark(){
	bb_scene_Scene::mark();
}
bb_map_Map::bb_map_Map(){
	f_root=0;
}
bb_map_Map* bb_map_Map::g_new(){
	return this;
}
bb_map_Node* bb_map_Map::m_FindNode(String t_key){
	bb_map_Node* t_node=f_root;
	while((t_node)!=0){
		int t_cmp=m_Compare(t_key,t_node->f_key);
		if(t_cmp>0){
			t_node=t_node->f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node->f_left;
			}else{
				return t_node;
			}
		}
	}
	return t_node;
}
bool bb_map_Map::m_Contains(String t_key){
	return m_FindNode(t_key)!=0;
}
int bb_map_Map::m_RotateLeft(bb_map_Node* t_node){
	bb_map_Node* t_child=t_node->f_right;
	gc_assign(t_node->f_right,t_child->f_left);
	if((t_child->f_left)!=0){
		gc_assign(t_child->f_left->f_parent,t_node);
	}
	gc_assign(t_child->f_parent,t_node->f_parent);
	if((t_node->f_parent)!=0){
		if(t_node==t_node->f_parent->f_left){
			gc_assign(t_node->f_parent->f_left,t_child);
		}else{
			gc_assign(t_node->f_parent->f_right,t_child);
		}
	}else{
		gc_assign(f_root,t_child);
	}
	gc_assign(t_child->f_left,t_node);
	gc_assign(t_node->f_parent,t_child);
	return 0;
}
int bb_map_Map::m_RotateRight(bb_map_Node* t_node){
	bb_map_Node* t_child=t_node->f_left;
	gc_assign(t_node->f_left,t_child->f_right);
	if((t_child->f_right)!=0){
		gc_assign(t_child->f_right->f_parent,t_node);
	}
	gc_assign(t_child->f_parent,t_node->f_parent);
	if((t_node->f_parent)!=0){
		if(t_node==t_node->f_parent->f_right){
			gc_assign(t_node->f_parent->f_right,t_child);
		}else{
			gc_assign(t_node->f_parent->f_left,t_child);
		}
	}else{
		gc_assign(f_root,t_child);
	}
	gc_assign(t_child->f_right,t_node);
	gc_assign(t_node->f_parent,t_child);
	return 0;
}
int bb_map_Map::m_InsertFixup(bb_map_Node* t_node){
	while(((t_node->f_parent)!=0) && t_node->f_parent->f_color==-1 && ((t_node->f_parent->f_parent)!=0)){
		if(t_node->f_parent==t_node->f_parent->f_parent->f_left){
			bb_map_Node* t_uncle=t_node->f_parent->f_parent->f_right;
			if(((t_uncle)!=0) && t_uncle->f_color==-1){
				t_node->f_parent->f_color=1;
				t_uncle->f_color=1;
				t_uncle->f_parent->f_color=-1;
				t_node=t_uncle->f_parent;
			}else{
				if(t_node==t_node->f_parent->f_right){
					t_node=t_node->f_parent;
					m_RotateLeft(t_node);
				}
				t_node->f_parent->f_color=1;
				t_node->f_parent->f_parent->f_color=-1;
				m_RotateRight(t_node->f_parent->f_parent);
			}
		}else{
			bb_map_Node* t_uncle2=t_node->f_parent->f_parent->f_left;
			if(((t_uncle2)!=0) && t_uncle2->f_color==-1){
				t_node->f_parent->f_color=1;
				t_uncle2->f_color=1;
				t_uncle2->f_parent->f_color=-1;
				t_node=t_uncle2->f_parent;
			}else{
				if(t_node==t_node->f_parent->f_left){
					t_node=t_node->f_parent;
					m_RotateRight(t_node);
				}
				t_node->f_parent->f_color=1;
				t_node->f_parent->f_parent->f_color=-1;
				m_RotateLeft(t_node->f_parent->f_parent);
			}
		}
	}
	f_root->f_color=1;
	return 0;
}
bool bb_map_Map::m_Set(String t_key,bb_directorevents_DirectorEvents* t_value){
	bb_map_Node* t_node=f_root;
	bb_map_Node* t_parent=0;
	int t_cmp=0;
	while((t_node)!=0){
		t_parent=t_node;
		t_cmp=m_Compare(t_key,t_node->f_key);
		if(t_cmp>0){
			t_node=t_node->f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node->f_left;
			}else{
				gc_assign(t_node->f_value,t_value);
				return false;
			}
		}
	}
	t_node=(new bb_map_Node)->g_new(t_key,t_value,-1,t_parent);
	if((t_parent)!=0){
		if(t_cmp>0){
			gc_assign(t_parent->f_right,t_node);
		}else{
			gc_assign(t_parent->f_left,t_node);
		}
		m_InsertFixup(t_node);
	}else{
		gc_assign(f_root,t_node);
	}
	return true;
}
bb_directorevents_DirectorEvents* bb_map_Map::m_Get(String t_key){
	bb_map_Node* t_node=m_FindNode(t_key);
	if((t_node)!=0){
		return t_node->f_value;
	}
	return 0;
}
void bb_map_Map::mark(){
	Object::mark();
	gc_mark_q(f_root);
}
bb_map_StringMap::bb_map_StringMap(){
}
bb_map_StringMap* bb_map_StringMap::g_new(){
	bb_map_Map::g_new();
	return this;
}
int bb_map_StringMap::m_Compare(String t_lhs,String t_rhs){
	return t_lhs.Compare(t_rhs);
}
void bb_map_StringMap::mark(){
	bb_map_Map::mark();
}
bb_map_Node::bb_map_Node(){
	f_key=String();
	f_right=0;
	f_left=0;
	f_value=0;
	f_color=0;
	f_parent=0;
}
bb_map_Node* bb_map_Node::g_new(String t_key,bb_directorevents_DirectorEvents* t_value,int t_color,bb_map_Node* t_parent){
	this->f_key=t_key;
	gc_assign(this->f_value,t_value);
	this->f_color=t_color;
	gc_assign(this->f_parent,t_parent);
	return this;
}
bb_map_Node* bb_map_Node::g_new2(){
	return this;
}
void bb_map_Node::mark(){
	Object::mark();
	gc_mark_q(f_right);
	gc_mark_q(f_left);
	gc_mark_q(f_value);
	gc_mark_q(f_parent);
}
bb_map_Map2::bb_map_Map2(){
	f_root=0;
}
bb_map_Map2* bb_map_Map2::g_new(){
	return this;
}
int bb_map_Map2::m_RotateLeft2(bb_map_Node2* t_node){
	bb_map_Node2* t_child=t_node->f_right;
	gc_assign(t_node->f_right,t_child->f_left);
	if((t_child->f_left)!=0){
		gc_assign(t_child->f_left->f_parent,t_node);
	}
	gc_assign(t_child->f_parent,t_node->f_parent);
	if((t_node->f_parent)!=0){
		if(t_node==t_node->f_parent->f_left){
			gc_assign(t_node->f_parent->f_left,t_child);
		}else{
			gc_assign(t_node->f_parent->f_right,t_child);
		}
	}else{
		gc_assign(f_root,t_child);
	}
	gc_assign(t_child->f_left,t_node);
	gc_assign(t_node->f_parent,t_child);
	return 0;
}
int bb_map_Map2::m_RotateRight2(bb_map_Node2* t_node){
	bb_map_Node2* t_child=t_node->f_left;
	gc_assign(t_node->f_left,t_child->f_right);
	if((t_child->f_right)!=0){
		gc_assign(t_child->f_right->f_parent,t_node);
	}
	gc_assign(t_child->f_parent,t_node->f_parent);
	if((t_node->f_parent)!=0){
		if(t_node==t_node->f_parent->f_right){
			gc_assign(t_node->f_parent->f_right,t_child);
		}else{
			gc_assign(t_node->f_parent->f_left,t_child);
		}
	}else{
		gc_assign(f_root,t_child);
	}
	gc_assign(t_child->f_right,t_node);
	gc_assign(t_node->f_parent,t_child);
	return 0;
}
int bb_map_Map2::m_InsertFixup2(bb_map_Node2* t_node){
	while(((t_node->f_parent)!=0) && t_node->f_parent->f_color==-1 && ((t_node->f_parent->f_parent)!=0)){
		if(t_node->f_parent==t_node->f_parent->f_parent->f_left){
			bb_map_Node2* t_uncle=t_node->f_parent->f_parent->f_right;
			if(((t_uncle)!=0) && t_uncle->f_color==-1){
				t_node->f_parent->f_color=1;
				t_uncle->f_color=1;
				t_uncle->f_parent->f_color=-1;
				t_node=t_uncle->f_parent;
			}else{
				if(t_node==t_node->f_parent->f_right){
					t_node=t_node->f_parent;
					m_RotateLeft2(t_node);
				}
				t_node->f_parent->f_color=1;
				t_node->f_parent->f_parent->f_color=-1;
				m_RotateRight2(t_node->f_parent->f_parent);
			}
		}else{
			bb_map_Node2* t_uncle2=t_node->f_parent->f_parent->f_left;
			if(((t_uncle2)!=0) && t_uncle2->f_color==-1){
				t_node->f_parent->f_color=1;
				t_uncle2->f_color=1;
				t_uncle2->f_parent->f_color=-1;
				t_node=t_uncle2->f_parent;
			}else{
				if(t_node==t_node->f_parent->f_left){
					t_node=t_node->f_parent;
					m_RotateRight2(t_node);
				}
				t_node->f_parent->f_color=1;
				t_node->f_parent->f_parent->f_color=-1;
				m_RotateLeft2(t_node->f_parent->f_parent);
			}
		}
	}
	f_root->f_color=1;
	return 0;
}
bool bb_map_Map2::m_Set2(String t_key,bb_routerevents_RouterEvents* t_value){
	bb_map_Node2* t_node=f_root;
	bb_map_Node2* t_parent=0;
	int t_cmp=0;
	while((t_node)!=0){
		t_parent=t_node;
		t_cmp=m_Compare(t_key,t_node->f_key);
		if(t_cmp>0){
			t_node=t_node->f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node->f_left;
			}else{
				gc_assign(t_node->f_value,t_value);
				return false;
			}
		}
	}
	t_node=(new bb_map_Node2)->g_new(t_key,t_value,-1,t_parent);
	if((t_parent)!=0){
		if(t_cmp>0){
			gc_assign(t_parent->f_right,t_node);
		}else{
			gc_assign(t_parent->f_left,t_node);
		}
		m_InsertFixup2(t_node);
	}else{
		gc_assign(f_root,t_node);
	}
	return true;
}
bb_map_Node2* bb_map_Map2::m_FindNode(String t_key){
	bb_map_Node2* t_node=f_root;
	while((t_node)!=0){
		int t_cmp=m_Compare(t_key,t_node->f_key);
		if(t_cmp>0){
			t_node=t_node->f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node->f_left;
			}else{
				return t_node;
			}
		}
	}
	return t_node;
}
bb_routerevents_RouterEvents* bb_map_Map2::m_Get(String t_key){
	bb_map_Node2* t_node=m_FindNode(t_key);
	if((t_node)!=0){
		return t_node->f_value;
	}
	return 0;
}
void bb_map_Map2::mark(){
	Object::mark();
	gc_mark_q(f_root);
}
bb_map_StringMap2::bb_map_StringMap2(){
}
bb_map_StringMap2* bb_map_StringMap2::g_new(){
	bb_map_Map2::g_new();
	return this;
}
int bb_map_StringMap2::m_Compare(String t_lhs,String t_rhs){
	return t_lhs.Compare(t_rhs);
}
void bb_map_StringMap2::mark(){
	bb_map_Map2::mark();
}
bb_map_Node2::bb_map_Node2(){
	f_key=String();
	f_right=0;
	f_left=0;
	f_value=0;
	f_color=0;
	f_parent=0;
}
bb_map_Node2* bb_map_Node2::g_new(String t_key,bb_routerevents_RouterEvents* t_value,int t_color,bb_map_Node2* t_parent){
	this->f_key=t_key;
	gc_assign(this->f_value,t_value);
	this->f_color=t_color;
	gc_assign(this->f_parent,t_parent);
	return this;
}
bb_map_Node2* bb_map_Node2::g_new2(){
	return this;
}
void bb_map_Node2::mark(){
	Object::mark();
	gc_mark_q(f_right);
	gc_mark_q(f_left);
	gc_mark_q(f_value);
	gc_mark_q(f_parent);
}
bb_menuscene_MenuScene::bb_menuscene_MenuScene(){
	f_easy=0;
	f_normal=0;
	f_normalActive=0;
	f_advanced=0;
	f_advancedActive=0;
	f_highscore=0;
	f_lock=0;
	f_isLocked=true;
	f_paymentProcessing=false;
	f_waitingText=0;
	f_waitingImage=0;
}
bb_menuscene_MenuScene* bb_menuscene_MenuScene::g_new(){
	bb_scene_Scene::g_new();
	return this;
}
void bb_menuscene_MenuScene::m_ToggleLock(){
	if(f_isLocked){
		f_isLocked=false;
		m_layer()->m_Remove(f_lock);
		m_layer()->m_Remove(f_normal);
		m_layer()->m_Remove(f_advanced);
		m_layer()->m_Add4(f_normalActive);
		m_layer()->m_Add4(f_advancedActive);
	}else{
		f_isLocked=true;
		m_layer()->m_Remove(f_normalActive);
		m_layer()->m_Remove(f_advancedActive);
		m_layer()->m_Add4(f_normal);
		m_layer()->m_Add4(f_advanced);
		m_layer()->m_Add4(f_lock);
	}
}
void bb_menuscene_MenuScene::m_OnCreate(bb_director_Director* t_director){
	bb_vector2d_Vector2D* t_offset=(new bb_vector2d_Vector2D)->g_new(FLOAT(0.0),FLOAT(150.0));
	gc_assign(f_easy,(new bb_sprite_Sprite)->g_new(String(L"01_02-easy.png"),(new bb_vector2d_Vector2D)->g_new(FLOAT(0.0),FLOAT(290.0))));
	gc_assign(f_normal,(new bb_sprite_Sprite)->g_new(String(L"01_02-normal.png"),f_easy->m_pos()->m_Copy()->m_Add2(t_offset)));
	gc_assign(f_normalActive,(new bb_sprite_Sprite)->g_new(String(L"01_02-normal_active.png"),f_normal->m_pos()));
	gc_assign(f_advanced,(new bb_sprite_Sprite)->g_new(String(L"01_02-advanced.png"),f_normal->m_pos()->m_Copy()->m_Add2(t_offset)));
	gc_assign(f_advancedActive,(new bb_sprite_Sprite)->g_new(String(L"01_02-advanced_active.png"),f_advanced->m_pos()));
	gc_assign(f_highscore,(new bb_sprite_Sprite)->g_new(String(L"01_04button-highscore.png"),f_advanced->m_pos()->m_Copy()->m_Add2(t_offset)));
	bb_vector2d_Vector2D* t_pos=f_advanced->m_pos()->m_Copy()->m_Add2(f_advanced->m_size())->m_Sub(f_normal->m_pos())->m_Div2(FLOAT(2.0));
	t_pos->f_y+=f_normal->m_pos()->f_y;
	gc_assign(f_lock,(new bb_sprite_Sprite)->g_new(String(L"locked.png"),t_pos));
	f_lock->m_pos()->f_y-=f_lock->m_center()->f_y;
	m_layer()->m_Add4((new bb_sprite_Sprite)->g_new(String(L"01_main.jpg"),0));
	m_layer()->m_Add4(f_easy);
	m_layer()->m_Add4(f_normal);
	m_layer()->m_Add4(f_advanced);
	m_layer()->m_Add4(f_highscore);
	m_layer()->m_Add4(f_lock);
	bb_scene_Scene::m_OnCreate(t_director);
	f_easy->m_CenterX(t_director);
	f_normal->m_CenterX(t_director);
	f_advanced->m_CenterX(t_director);
	f_highscore->m_CenterX(t_director);
	String t_[]={String(L"com.coragames.daffydrop.fullversion")};
	InitInAppPurchases(String(L"com.coragames.daffydrop"),Array<String >(t_,1));
	if((isProductPurchased(String(L"com.coragames.daffydrop.fullversion")))!=0){
		m_ToggleLock();
	}
}
void bb_menuscene_MenuScene::m_PlayEasy(){
	bb_severity_CurrentSeverity()->m_Set5(0);
	m_router()->m_Goto(String(L"game"));
}
void bb_menuscene_MenuScene::m_InitializeWaitingImages(){
	gc_assign(f_waitingText,(new bb_font_Font)->g_new(String(L"CoRa"),0));
	f_waitingText->m_OnCreate(m_director());
	f_waitingText->m_text(String(L"Loading ..."));
	f_waitingText->m_align(1);
	f_waitingText->m_pos2(m_director()->m_center()->m_Copy());
	gc_assign(f_waitingImage,(new bb_sprite_Sprite)->g_new(String(L"star_inside.png"),0));
	f_waitingImage->m_OnCreate(m_director());
	f_waitingImage->m_Center(m_director());
	bb_vector2d_Vector2D* t_=f_waitingImage->m_pos();
	t_->f_y=t_->f_y-FLOAT(50.0);
}
void bb_menuscene_MenuScene::m_HandleLocked(){
	if(f_paymentProcessing){
		return;
	}
	if(!f_isLocked){
		return;
	}
	m_InitializeWaitingImages();
	f_paymentProcessing=true;
	buyProduct(String(L"com.coragames.daffydrop.fullversion"));
}
void bb_menuscene_MenuScene::m_PlayNormal(){
	if(f_isLocked){
		m_HandleLocked();
		return;
	}
	bb_severity_CurrentSeverity()->m_Set5(1);
	m_router()->m_Goto(String(L"game"));
}
void bb_menuscene_MenuScene::m_PlayAdvanced(){
	if(f_isLocked){
		m_HandleLocked();
		return;
	}
	bb_severity_CurrentSeverity()->m_Set5(2);
	m_router()->m_Goto(String(L"game"));
}
void bb_menuscene_MenuScene::m_OnTouchDown(bb_touchevent_TouchEvent* t_event){
	if(f_paymentProcessing){
		return;
	}
	if(f_easy->m_Collide(t_event->m_pos())){
		m_PlayEasy();
	}
	if(f_normal->m_Collide(t_event->m_pos())){
		m_PlayNormal();
	}
	if(f_advanced->m_Collide(t_event->m_pos())){
		m_PlayAdvanced();
	}
	if(f_highscore->m_Collide(t_event->m_pos())){
		m_router()->m_Goto(String(L"highscore"));
	}
	if(f_lock->m_Collide(t_event->m_pos())){
		m_HandleLocked();
	}
}
void bb_menuscene_MenuScene::m_OnKeyDown(bb_keyevent_KeyEvent* t_event){
	if(f_paymentProcessing){
		return;
	}
	int t_1=t_event->m_code();
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
					m_router()->m_Goto(String(L"highscore"));
				}
			}
		}
	}
}
void bb_menuscene_MenuScene::m_OnUpdate(Float t_delta,Float t_frameTime){
	bb_scene_Scene::m_OnUpdate(t_delta,t_frameTime);
	if(!f_isLocked){
		return;
	}
	if(!f_paymentProcessing){
		return;
	}
	if((isPurchaseInProgress())!=0){
		return;
	}
	f_paymentProcessing=false;
	if(!((isProductPurchased(String(L"com.coragames.daffydrop.fullversion")))!=0)){
		return;
	}
	m_ToggleLock();
}
void bb_menuscene_MenuScene::m_OnRender(){
	bb_scene_Scene::m_OnRender();
	if(f_paymentProcessing){
		m_RenderBlend();
		bb_graphics_PushMatrix();
		bb_graphics_Translate(-m_director()->m_center()->f_x,-m_director()->m_center()->f_y);
		bb_graphics_Scale(FLOAT(2.0),FLOAT(2.0));
		f_waitingImage->m_OnRender();
		f_waitingText->m_OnRender();
		bb_graphics_PopMatrix();
	}
}
void bb_menuscene_MenuScene::mark(){
	bb_scene_Scene::mark();
	gc_mark_q(f_easy);
	gc_mark_q(f_normal);
	gc_mark_q(f_normalActive);
	gc_mark_q(f_advanced);
	gc_mark_q(f_advancedActive);
	gc_mark_q(f_highscore);
	gc_mark_q(f_lock);
	gc_mark_q(f_waitingText);
	gc_mark_q(f_waitingImage);
}
bb_highscorescene_HighscoreScene::bb_highscorescene_HighscoreScene(){
	f_font=0;
	f_background=0;
	f_highscore=(new bb_gamehighscore_GameHighscore)->g_new();
	f_lastScoreValue=0;
	f_lastScoreKey=String();
	f_disableTimer=FLOAT(.0);
}
bb_highscorescene_HighscoreScene* bb_highscorescene_HighscoreScene::g_new(){
	bb_scene_Scene::g_new();
	return this;
}
void bb_highscorescene_HighscoreScene::m_OnCreate(bb_director_Director* t_director){
	gc_assign(f_font,(new bb_angelfont2_AngelFont)->g_new(String(L"CoRa")));
	gc_assign(f_background,(new bb_sprite_Sprite)->g_new(String(L"highscore_bg.jpg"),0));
	f_background->m_OnCreate(t_director);
	bb_scene_Scene::m_OnCreate(t_director);
}
void bb_highscorescene_HighscoreScene::m_OnEnter(){
	bb_statestore_StateStore::g_Load(f_highscore);
}
void bb_highscorescene_HighscoreScene::m_OnLeave(){
	f_lastScoreValue=0;
	f_lastScoreKey=String();
}
void bb_highscorescene_HighscoreScene::m_OnUpdate(Float t_delta,Float t_frameTime){
	f_disableTimer+=t_frameTime;
	if(f_disableTimer>=FLOAT(500.0)){
		m_director()->m_inputController()->f_trackKeys=false;
	}
}
void bb_highscorescene_HighscoreScene::m_DrawEntries(){
	int t_posY=190;
	bool t_found=false;
	bb_list_Enumerator2* t_=f_highscore->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_score_Score* t_score=t_->m_NextObject();
		if(!t_found && t_score->f_value==f_lastScoreValue && t_score->f_key==f_lastScoreKey){
			bb_graphics_SetColor(FLOAT(255.0),FLOAT(255.0),FLOAT(255.0));
		}
		f_font->m_DrawText2(String(t_score->f_value),100,t_posY,2);
		f_font->m_DrawText(t_score->f_key,110,t_posY);
		t_posY+=35;
		if(!t_found && t_score->f_value==f_lastScoreValue && t_score->f_key==f_lastScoreKey){
			bb_graphics_SetColor(FLOAT(255.0),FLOAT(133.0),FLOAT(0.0));
			t_found=true;
		}
	}
}
void bb_highscorescene_HighscoreScene::m_OnRender(){
	f_background->m_OnRender();
	bb_graphics_PushMatrix();
	bb_graphics_SetColor(FLOAT(255.0),FLOAT(133.0),FLOAT(0.0));
	bb_graphics_Scale(FLOAT(1.5),FLOAT(1.5));
	m_DrawEntries();
	bb_graphics_PopMatrix();
}
void bb_highscorescene_HighscoreScene::m_OnKeyDown(bb_keyevent_KeyEvent* t_event){
	m_router()->m_Goto(String(L"menu"));
}
void bb_highscorescene_HighscoreScene::m_OnTouchDown(bb_touchevent_TouchEvent* t_event){
	m_router()->m_Goto(String(L"menu"));
}
void bb_highscorescene_HighscoreScene::mark(){
	bb_scene_Scene::mark();
	gc_mark_q(f_font);
	gc_mark_q(f_background);
	gc_mark_q(f_highscore);
}
bb_gamescene_GameScene::bb_gamescene_GameScene(){
	f_chute=0;
	f_lowerShapes=0;
	f_severity=0;
	f_slider=0;
	f_upperShapes=0;
	f_errorAnimations=0;
	f_pauseButton=0;
	f_scoreFont=0;
	f_comboFont=0;
	f_comboAnimation=0;
	f_newHighscoreFont=0;
	f_newHighscoreAnimation=0;
	f_checkPosY=FLOAT(.0);
	f_pauseTime=0;
	f_ignoreFirstTouchUp=false;
	f_score=0;
	f_minHighscore=0;
	f_isNewHighscoreRecord=false;
	f_collisionCheckedLastUpdate=false;
	f_falseSpriteStrack=(new bb_stack_Stack2)->g_new();
	int t_[]={0,0,0,0};
	f_lastMatchTime=Array<int >(t_,4);
	f_comboPending=false;
	f_comboPendingSince=0;
	f_lastSlowUpdate=FLOAT(.0);
}
bb_gamescene_GameScene* bb_gamescene_GameScene::g_new(){
	bb_scene_Scene::g_new();
	return this;
}
void bb_gamescene_GameScene::m_OnCreate(bb_director_Director* t_director){
	gc_assign(f_chute,(new bb_chute_Chute)->g_new());
	gc_assign(f_lowerShapes,(new bb_fanout_FanOut)->g_new());
	gc_assign(f_severity,bb_severity_CurrentSeverity());
	gc_assign(f_slider,(new bb_slider_Slider)->g_new());
	gc_assign(f_upperShapes,(new bb_fanout_FanOut)->g_new());
	gc_assign(f_errorAnimations,(new bb_fanout_FanOut)->g_new());
	gc_assign(f_pauseButton,(new bb_sprite_Sprite)->g_new(String(L"pause-button.png"),0));
	f_pauseButton->m_pos2(t_director->m_size()->m_Copy()->m_Sub(f_pauseButton->m_size()));
	f_pauseButton->m_pos()->f_y=FLOAT(0.0);
	gc_assign(f_scoreFont,(new bb_font_Font)->g_new(String(L"CoRa"),0));
	f_scoreFont->m_pos2((new bb_vector2d_Vector2D)->g_new(t_director->m_center()->f_x,t_director->m_size()->f_y-FLOAT(50.0)));
	f_scoreFont->m_align(1);
	gc_assign(f_comboFont,(new bb_font_Font)->g_new(String(L"CoRa"),t_director->m_center()->m_Copy()));
	f_comboFont->m_text(String(L"COMBO x 2"));
	bb_vector2d_Vector2D* t_=f_comboFont->m_pos();
	t_->f_y=t_->f_y-FLOAT(150.0);
	bb_vector2d_Vector2D* t_2=f_comboFont->m_pos();
	t_2->f_x=t_2->f_x-FLOAT(70.0);
	gc_assign(f_comboAnimation,(new bb_animation_Animation)->g_new(FLOAT(2.0),FLOAT(0.0),FLOAT(750.0)));
	gc_assign(f_comboAnimation->f_effect,((new bb_fader_FaderScale)->g_new()));
	gc_assign(f_comboAnimation->f_transition,((new bb_transition_TransitionInCubic)->g_new()));
	f_comboAnimation->m_Add4(f_comboFont);
	f_comboAnimation->m_Pause();
	gc_assign(f_newHighscoreFont,(new bb_font_Font)->g_new(String(L"CoRa"),t_director->m_center()->m_Copy()));
	f_newHighscoreFont->m_text(String(L"NEW HIGHSCORE"));
	bb_vector2d_Vector2D* t_3=f_newHighscoreFont->m_pos();
	t_3->f_y=t_3->f_y/FLOAT(2.0);
	bb_vector2d_Vector2D* t_4=f_newHighscoreFont->m_pos();
	t_4->f_x=t_4->f_x-FLOAT(120.0);
	gc_assign(f_newHighscoreAnimation,(new bb_animation_Animation)->g_new(FLOAT(2.0),FLOAT(0.0),FLOAT(2000.0)));
	gc_assign(f_newHighscoreAnimation->f_effect,((new bb_fader_FaderScale)->g_new()));
	gc_assign(f_newHighscoreAnimation->f_transition,((new bb_transition_TransitionInCubic)->g_new()));
	f_newHighscoreAnimation->m_Add4(f_newHighscoreFont);
	f_newHighscoreAnimation->m_Pause();
	m_layer()->m_Add4((new bb_sprite_Sprite)->g_new(String(L"bg_960x640.jpg"),0));
	m_layer()->m_Add4(f_lowerShapes);
	m_layer()->m_Add4(f_slider);
	m_layer()->m_Add4(f_upperShapes);
	m_layer()->m_Add4(f_errorAnimations);
	m_layer()->m_Add4(f_newHighscoreAnimation);
	m_layer()->m_Add4(f_comboAnimation);
	m_layer()->m_Add4(f_chute);
	m_layer()->m_Add4(f_scoreFont);
	m_layer()->m_Add4(f_pauseButton);
	bb_scene_Scene::m_OnCreate(t_director);
	f_checkPosY=t_director->m_size()->f_y-Float(f_slider->f_images[0]->m_Height()/2)-FLOAT(5.0);
}
void bb_gamescene_GameScene::m_OnEnterPaused(){
	int t_diff=bb_app_Millisecs()-f_pauseTime;
	f_pauseTime=0;
	f_severity->m_WarpTime(t_diff);
}
void bb_gamescene_GameScene::m_LoadHighscoreMinValue(){
	bb_gamehighscore_GameHighscore* t_highscore=(new bb_gamehighscore_GameHighscore)->g_new();
	bb_statestore_StateStore::g_Load(t_highscore);
	f_minHighscore=t_highscore->m_Last()->f_value;
	f_isNewHighscoreRecord=!(t_highscore->m_Count()==t_highscore->m_maxCount());
}
void bb_gamescene_GameScene::m_OnEnter(){
	if(f_pauseTime>0){
		m_OnEnterPaused();
		return;
	}
	f_ignoreFirstTouchUp=true;
	f_score=0;
	f_scoreFont->m_text(String(L"Score: 0"));
	f_lowerShapes->m_Clear();
	f_upperShapes->m_Clear();
	f_errorAnimations->m_Clear();
	f_severity->m_Restart();
	f_chute->m_Restart();
	f_slider->m_Restart();
	m_LoadHighscoreMinValue();
}
void bb_gamescene_GameScene::m_OnLeave(){
}
bool bb_gamescene_GameScene::m_HandleGameOver(){
	if(Float(f_chute->m_Height())<f_slider->f_arrowLeft->m_pos()->f_y+FLOAT(40.0)){
		return false;
	}
	if(f_isNewHighscoreRecord){
		m_director()->m_inputController()->f_trackKeys=true;
		dynamic_cast<bb_newhighscorescene_NewHighscoreScene*>(m_router()->m_Get(String(L"newhighscore")))->f_score=f_score;
		m_router()->m_Goto(String(L"newhighscore"));
	}else{
		m_router()->m_Goto(String(L"gameover"));
	}
	return true;
}
void bb_gamescene_GameScene::m_OnMissmatch(bb_shape_Shape* t_shape){
	bb_sprite_Sprite* t_sprite=0;
	if(f_falseSpriteStrack->m_Length()>0){
		t_sprite=f_falseSpriteStrack->m_Pop();
	}else{
		t_sprite=(new bb_sprite_Sprite)->g_new2(String(L"false.png"),140,88,6,100,0);
	}
	t_sprite->m_pos2(t_shape->m_pos());
	t_sprite->m_Restart();
	f_chute->f_height+=15;
	int t_[]={0,0,0,0};
	gc_assign(f_lastMatchTime,Array<int >(t_,4));
	f_errorAnimations->m_Add4(t_sprite);
}
void bb_gamescene_GameScene::m_IncrementScore(int t_value){
	f_score+=t_value;
	f_scoreFont->m_text(String(L"Score: ")+String(f_score));
	if(!f_isNewHighscoreRecord && f_score>=f_minHighscore){
		f_isNewHighscoreRecord=true;
		f_newHighscoreAnimation->m_Restart();
		m_layer()->m_Add4(f_newHighscoreAnimation);
	}
}
void bb_gamescene_GameScene::m_OnMatch(bb_shape_Shape* t_shape){
	f_lastMatchTime[t_shape->f_lane]=bb_app_Millisecs();
	m_IncrementScore(10);
}
void bb_gamescene_GameScene::m_CheckShapeCollisions(){
	bb_shape_Shape* t_shape=0;
	bb_list_Enumerator* t_=f_upperShapes->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_directorevents_DirectorEvents* t_obj=t_->m_NextObject();
		t_shape=dynamic_cast<bb_shape_Shape*>(t_obj);
		if(t_shape->m_pos()->f_y+Float(bb_shape_Shape::g_images[0]->m_Height())<f_checkPosY){
			continue;
		}
		f_upperShapes->m_Remove(t_shape);
		if(!f_slider->m_Match(t_shape)){
			m_OnMissmatch(t_shape);
		}else{
			f_lowerShapes->m_Add4(t_shape);
			m_OnMatch(t_shape);
		}
	}
}
void bb_gamescene_GameScene::m_DetectComboTrigger(){
	int t_lanesNotZero=0;
	int t_hotLanes=0;
	int t_now=bb_app_Millisecs();
	for(int t_lane=0;t_lane<f_lastMatchTime.Length();t_lane=t_lane+1){
		if(f_lastMatchTime[t_lane]==0){
			continue;
		}
		t_lanesNotZero+=1;
		if(f_lastMatchTime[t_lane]+300>=t_now){
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
	if(f_comboPendingSince+300>t_now){
		return;
	}
	int t_[]={0,0,0,0};
	gc_assign(f_lastMatchTime,Array<int >(t_,4));
	f_comboPending=false;
	f_chute->f_height=bb_math_Max(75,f_chute->f_height-18*t_lanesNotZero);
	m_IncrementScore(15*t_lanesNotZero);
	f_comboFont->m_text(String(L"COMBO x ")+String(t_lanesNotZero));
	f_comboAnimation->m_Restart();
	m_layer()->m_Add4(f_comboAnimation);
}
void bb_gamescene_GameScene::m_DropNewShapeIfRequested(){
	if(!f_severity->m_ShapeShouldBeDropped()){
		return;
	}
	f_upperShapes->m_Add4((new bb_shape_Shape)->g_new(f_severity->m_RandomType(),f_severity->m_RandomLane(),f_chute));
	f_severity->m_ShapeDropped();
}
void bb_gamescene_GameScene::m_RemoveLostShapes(){
	Float t_directoySizeY=m_director()->m_size()->f_y;
	bb_shape_Shape* t_shape=0;
	bb_list_Enumerator* t_=f_lowerShapes->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_directorevents_DirectorEvents* t_obj=t_->m_NextObject();
		t_shape=dynamic_cast<bb_shape_Shape*>(t_obj);
		if(t_shape->m_pos()->f_y>t_directoySizeY){
			f_lowerShapes->m_Remove(t_shape);
		}
	}
}
void bb_gamescene_GameScene::m_RemoveFinishedErroAnimations(){
	bb_sprite_Sprite* t_sprite=0;
	bb_list_Enumerator* t_=f_errorAnimations->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_directorevents_DirectorEvents* t_obj=t_->m_NextObject();
		t_sprite=dynamic_cast<bb_sprite_Sprite*>(t_obj);
		if(t_sprite->m_animationIsDone()){
			f_errorAnimations->m_Remove(t_sprite);
			f_falseSpriteStrack->m_Push2(t_sprite);
		}
	}
}
void bb_gamescene_GameScene::m_OnUpdate(Float t_delta,Float t_frameTime){
	bb_scene_Scene::m_OnUpdate(t_delta,t_frameTime);
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
	f_severity->m_OnUpdate(t_delta,t_frameTime);
	m_DropNewShapeIfRequested();
	f_lastSlowUpdate+=t_frameTime;
	if(f_lastSlowUpdate>=FLOAT(1000.0)){
		f_lastSlowUpdate=FLOAT(0.0);
		m_RemoveLostShapes();
		m_RemoveFinishedErroAnimations();
		if(!f_comboAnimation->m_IsPlaying()){
			m_layer()->m_Remove(f_comboAnimation);
		}
		if(!f_newHighscoreAnimation->m_IsPlaying()){
			m_layer()->m_Remove(f_newHighscoreAnimation);
		}
	}
}
void bb_gamescene_GameScene::m_StartPause(){
	f_pauseTime=bb_app_Millisecs();
	m_router()->m_Goto(String(L"pause"));
}
void bb_gamescene_GameScene::m_FastDropMatchingShapes(){
	bb_shape_Shape* t_shape=0;
	bb_list_Enumerator* t_=f_upperShapes->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_directorevents_DirectorEvents* t_obj=t_->m_NextObject();
		t_shape=dynamic_cast<bb_shape_Shape*>(t_obj);
		if(t_shape->f_isFast){
			continue;
		}
		if(f_slider->m_Match(t_shape)){
			t_shape->f_isFast=true;
		}
	}
}
void bb_gamescene_GameScene::m_OnKeyDown(bb_keyevent_KeyEvent* t_event){
	int t_1=t_event->m_code();
	if(t_1==80){
		m_StartPause();
	}else{
		if(t_1==40 || t_1==65576){
			m_FastDropMatchingShapes();
		}else{
			if(t_1==37 || t_1==65573){
				f_slider->m_SlideLeft();
			}else{
				if(t_1==39 || t_1==65575){
					f_slider->m_SlideRight();
				}
			}
		}
	}
}
void bb_gamescene_GameScene::m_OnTouchDown(bb_touchevent_TouchEvent* t_event){
	if(f_pauseButton->m_Collide(t_event->m_pos())){
		m_StartPause();
	}
	if(f_slider->f_arrowRight->m_Collide(t_event->m_pos())){
		f_slider->m_SlideRight();
	}
	if(f_slider->f_arrowLeft->m_Collide(t_event->m_pos())){
		f_slider->m_SlideLeft();
	}
}
void bb_gamescene_GameScene::m_HandleSliderSwipe(bb_touchevent_TouchEvent* t_event){
	bb_vector2d_Vector2D* t_swipe=t_event->m_startDelta()->m_Normalize();
	if(bb_math_Abs2(t_swipe->f_x)<=FLOAT(0.4)){
		return;
	}
	if(t_swipe->f_x<FLOAT(0.0)){
		f_slider->m_SlideLeft();
	}else{
		f_slider->m_SlideRight();
	}
}
void bb_gamescene_GameScene::m_HandleBackgroundSwipe(bb_touchevent_TouchEvent* t_event){
	bb_vector2d_Vector2D* t_swipe=t_event->m_startDelta()->m_Normalize();
	if(t_swipe->f_y>FLOAT(0.2)){
		m_FastDropMatchingShapes();
	}
}
void bb_gamescene_GameScene::m_OnTouchUp(bb_touchevent_TouchEvent* t_event){
	if(f_ignoreFirstTouchUp){
		f_ignoreFirstTouchUp=false;
		return;
	}
	if(t_event->m_startPos()->f_y>=f_slider->m_pos()->f_y){
		m_HandleSliderSwipe(t_event);
	}else{
		m_HandleBackgroundSwipe(t_event);
	}
}
void bb_gamescene_GameScene::m_OnTouchMove(bb_touchevent_TouchEvent* t_event){
}
void bb_gamescene_GameScene::m_OnPauseLeaveGame(){
	f_pauseTime=0;
}
void bb_gamescene_GameScene::mark(){
	bb_scene_Scene::mark();
	gc_mark_q(f_chute);
	gc_mark_q(f_lowerShapes);
	gc_mark_q(f_severity);
	gc_mark_q(f_slider);
	gc_mark_q(f_upperShapes);
	gc_mark_q(f_errorAnimations);
	gc_mark_q(f_pauseButton);
	gc_mark_q(f_scoreFont);
	gc_mark_q(f_comboFont);
	gc_mark_q(f_comboAnimation);
	gc_mark_q(f_newHighscoreFont);
	gc_mark_q(f_newHighscoreAnimation);
	gc_mark_q(f_falseSpriteStrack);
	gc_mark_q(f_lastMatchTime);
}
bb_gameoverscene_GameOverScene::bb_gameoverscene_GameOverScene(){
	f_main=0;
	f_small=0;
}
bb_gameoverscene_GameOverScene* bb_gameoverscene_GameOverScene::g_new(){
	bb_scene_Scene::g_new();
	return this;
}
void bb_gameoverscene_GameOverScene::m_OnCreate(bb_director_Director* t_director){
	bb_scene_Scene::m_OnCreate(t_director);
	gc_assign(f_main,(new bb_sprite_Sprite)->g_new(String(L"gameover_main.png"),0));
	f_main->m_OnCreate(t_director);
	f_main->m_Center(t_director);
	gc_assign(f_small,(new bb_sprite_Sprite)->g_new(String(L"gameover_small.png"),0));
	f_small->m_OnCreate(t_director);
	f_small->m_pos()->f_x=t_director->m_size()->f_x-f_small->m_size()->f_x;
}
void bb_gameoverscene_GameOverScene::m_OnRender(){
	m_router()->m_previous()->m_OnRender();
	m_RenderBlend();
	f_small->m_OnRender();
	f_main->m_OnRender();
}
void bb_gameoverscene_GameOverScene::m_OnTouchDown(bb_touchevent_TouchEvent* t_event){
	m_router()->m_Goto(String(L"menu"));
}
void bb_gameoverscene_GameOverScene::m_OnKeyDown(bb_keyevent_KeyEvent* t_event){
	m_router()->m_Goto(String(L"menu"));
}
void bb_gameoverscene_GameOverScene::mark(){
	bb_scene_Scene::mark();
	gc_mark_q(f_main);
	gc_mark_q(f_small);
}
bb_pausescene_PauseScene::bb_pausescene_PauseScene(){
	f_overlay=0;
	f_continueBtn=0;
	f_quitBtn=0;
}
bb_pausescene_PauseScene* bb_pausescene_PauseScene::g_new(){
	bb_scene_Scene::g_new();
	return this;
}
void bb_pausescene_PauseScene::m_OnCreate(bb_director_Director* t_director){
	gc_assign(f_overlay,(new bb_sprite_Sprite)->g_new(String(L"pause.png"),0));
	m_layer()->m_Add4(f_overlay);
	gc_assign(f_continueBtn,(new bb_sprite_Sprite)->g_new(String(L"01_06-continue.png"),0));
	m_layer()->m_Add4(f_continueBtn);
	gc_assign(f_quitBtn,(new bb_sprite_Sprite)->g_new(String(L"01_07-quit.png"),0));
	m_layer()->m_Add4(f_quitBtn);
	bb_scene_Scene::m_OnCreate(t_director);
}
void bb_pausescene_PauseScene::m_OnEnter(){
	f_overlay->m_Center(m_director());
	f_overlay->m_pos()->f_y-=f_overlay->m_size()->f_y;
	bb_vector2d_Vector2D* t_=f_overlay->m_pos();
	t_->f_y=t_->f_y-FLOAT(50.0);
	f_continueBtn->m_Center(m_director());
	f_quitBtn->m_pos2(f_continueBtn->m_pos()->m_Copy());
	f_quitBtn->m_pos()->f_y+=f_continueBtn->m_size()->f_y+FLOAT(40.0);
}
void bb_pausescene_PauseScene::m_OnRender(){
	m_router()->m_previous()->m_OnRender();
	m_RenderBlend();
	bb_scene_Scene::m_OnRender();
}
void bb_pausescene_PauseScene::m_OnKeyDown(bb_keyevent_KeyEvent* t_event){
	int t_1=t_event->m_code();
	if(t_1==27 || t_1==81){
		dynamic_cast<bb_gamescene_GameScene*>(m_router()->m_previous())->m_OnPauseLeaveGame();
		m_router()->m_Goto(String(L"menu"));
	}else{
		m_router()->m_Goto(m_router()->m_previousName());
	}
}
void bb_pausescene_PauseScene::m_OnTouchDown(bb_touchevent_TouchEvent* t_event){
	if(f_continueBtn->m_Collide(t_event->m_pos())){
		m_router()->m_Goto(m_router()->m_previousName());
	}
	if(f_quitBtn->m_Collide(t_event->m_pos())){
		dynamic_cast<bb_gamescene_GameScene*>(m_router()->m_previous())->m_OnPauseLeaveGame();
		m_router()->m_Goto(String(L"menu"));
	}
}
void bb_pausescene_PauseScene::mark(){
	bb_scene_Scene::mark();
	gc_mark_q(f_overlay);
	gc_mark_q(f_continueBtn);
	gc_mark_q(f_quitBtn);
}
bb_newhighscorescene_NewHighscoreScene::bb_newhighscorescene_NewHighscoreScene(){
	f_input=0;
	f_score=0;
	f_highscore=(new bb_gamehighscore_GameHighscore)->g_new();
}
bb_newhighscorescene_NewHighscoreScene* bb_newhighscorescene_NewHighscoreScene::g_new(){
	bb_scene_Scene::g_new();
	return this;
}
void bb_newhighscorescene_NewHighscoreScene::m_OnCreate(bb_director_Director* t_director){
	bb_sprite_Sprite* t_background=(new bb_sprite_Sprite)->g_new(String(L"newhighscore.png"),0);
	t_background->m_pos()->f_y=FLOAT(40.0);
	m_layer()->m_Add4(t_background);
	gc_assign(f_input,(new bb_textinput_TextInput)->g_new(String(L"CoRa"),(new bb_vector2d_Vector2D)->g_new(FLOAT(90.0),FLOAT(430.0))));
	m_layer()->m_Add4(f_input);
	bb_scene_Scene::m_OnCreate(t_director);
}
void bb_newhighscorescene_NewHighscoreScene::m_OnRender(){
	m_router()->m_previous()->m_OnRender();
	m_RenderBlend();
	bb_scene_Scene::m_OnRender();
}
void bb_newhighscorescene_NewHighscoreScene::m_SaveAndContinue(){
	String t_level=bb_severity_CurrentSeverity()->m_ToString()+String(L" ");
	bb_statestore_StateStore::g_Load(f_highscore);
	f_highscore->m_Add5(t_level+f_input->m_text2(),f_score);
	bb_statestore_StateStore::g_Save(f_highscore);
	dynamic_cast<bb_highscorescene_HighscoreScene*>(m_router()->m_Get(String(L"highscore")))->f_lastScoreKey=t_level+f_input->m_text2();
	dynamic_cast<bb_highscorescene_HighscoreScene*>(m_router()->m_Get(String(L"highscore")))->f_lastScoreValue=f_score;
	m_router()->m_Goto(String(L"highscore"));
}
void bb_newhighscorescene_NewHighscoreScene::m_OnKeyDown(bb_keyevent_KeyEvent* t_event){
	bb_scene_Scene::m_OnKeyDown(t_event);
	if(t_event->m_code()==13){
		m_SaveAndContinue();
	}
}
void bb_newhighscorescene_NewHighscoreScene::mark(){
	bb_scene_Scene::mark();
	gc_mark_q(f_input);
	gc_mark_q(f_highscore);
}
bb_app_App::bb_app_App(){
}
bb_app_App* bb_app_App::g_new(){
	gc_assign(bb_app_device,(new bb_app_AppDevice)->g_new(this));
	return this;
}
int bb_app_App::m_OnCreate2(){
	return 0;
}
int bb_app_App::m_OnUpdate2(){
	return 0;
}
int bb_app_App::m_OnSuspend(){
	return 0;
}
int bb_app_App::m_OnResume2(){
	return 0;
}
int bb_app_App::m_OnRender(){
	return 0;
}
int bb_app_App::m_OnLoading(){
	return 0;
}
void bb_app_App::mark(){
	Object::mark();
}
bb_director_Director::bb_director_Director(){
	f__size=0;
	f__center=0;
	f__device=(new bb_vector2d_Vector2D)->g_new(FLOAT(0.0),FLOAT(0.0));
	f__scale=0;
	f__inputController=(new bb_inputcontroller_InputController)->g_new();
	f__handler=0;
	f_onCreateDispatched=false;
	f_appOnCreateCatched=false;
	f_deltaTimer=0;
}
bb_vector2d_Vector2D* bb_director_Director::m_size(){
	return f__size;
}
void bb_director_Director::m_RecalculateScale(){
	gc_assign(f__scale,f__device->m_Copy()->m_Div(f__size));
}
void bb_director_Director::m_size2(bb_vector2d_Vector2D* t_newSize){
	gc_assign(f__size,t_newSize);
	gc_assign(f__center,f__size->m_Copy()->m_Div2(FLOAT(2.0)));
	m_RecalculateScale();
}
bb_director_Director* bb_director_Director::g_new(int t_width,int t_height){
	bb_app_App::g_new();
	m_size2((new bb_vector2d_Vector2D)->g_new(Float(t_width),Float(t_height)));
	return this;
}
bb_director_Director* bb_director_Director::g_new2(){
	bb_app_App::g_new();
	return this;
}
bb_inputcontroller_InputController* bb_director_Director::m_inputController(){
	return f__inputController;
}
void bb_director_Director::m_DispatchOnCreate(){
	if(f_onCreateDispatched){
		return;
	}
	if(!((f__handler)!=0)){
		return;
	}
	if(!f_appOnCreateCatched){
		return;
	}
	f__handler->m_OnCreate(this);
	f_onCreateDispatched=true;
}
void bb_director_Director::m_Run(bb_directorevents_DirectorEvents* t__handler){
	gc_assign(this->f__handler,t__handler);
	m_DispatchOnCreate();
}
bb_directorevents_DirectorEvents* bb_director_Director::m_handler(){
	return f__handler;
}
bb_vector2d_Vector2D* bb_director_Director::m_center(){
	return f__center;
}
bb_vector2d_Vector2D* bb_director_Director::m_scale(){
	return f__scale;
}
int bb_director_Director::m_OnCreate2(){
	gc_assign(f__device,(new bb_vector2d_Vector2D)->g_new(Float(bb_graphics_DeviceWidth()),Float(bb_graphics_DeviceHeight())));
	if(!((m_size())!=0)){
		m_size2(f__device->m_Copy());
	}
	m_RecalculateScale();
	gc_assign(m_inputController()->f_scale,m_scale());
	bb_random_Seed=util::GetTimestamp();
	gc_assign(f_deltaTimer,(new bb_deltatimer_DeltaTimer)->g_new(FLOAT(30.0)));
	bb_app_SetUpdateRate(60);
	f_appOnCreateCatched=true;
	m_DispatchOnCreate();
	return 0;
}
int bb_director_Director::m_OnLoading(){
	if((f__handler)!=0){
		f__handler->m_OnLoading();
	}
	return 0;
}
int bb_director_Director::m_OnUpdate2(){
	f_deltaTimer->m_OnUpdate2();
	if((f__handler)!=0){
		f__handler->m_OnUpdate(f_deltaTimer->m_delta(),f_deltaTimer->m_frameTime());
		m_inputController()->m_OnUpdate3(f__handler);
	}
	return 0;
}
int bb_director_Director::m_OnResume2(){
	if((f__handler)!=0){
		f__handler->m_OnResume(0);
	}
	return 0;
}
int bb_director_Director::m_OnSuspend(){
	if((f__handler)!=0){
		f__handler->m_OnSuspend();
	}
	return 0;
}
int bb_director_Director::m_OnRender(){
	bb_graphics_PushMatrix();
	bb_graphics_Scale(f__scale->f_x,f__scale->f_y);
	bb_graphics_SetScissor(FLOAT(0.0),FLOAT(0.0),f__device->f_x,f__device->f_y);
	bb_graphics_Cls(FLOAT(0.0),FLOAT(0.0),FLOAT(0.0));
	bb_graphics_PushMatrix();
	if((f__handler)!=0){
		f__handler->m_OnRender();
	}
	bb_graphics_PopMatrix();
	bb_graphics_PopMatrix();
	return 0;
}
void bb_director_Director::mark(){
	bb_app_App::mark();
	gc_mark_q(f__size);
	gc_mark_q(f__center);
	gc_mark_q(f__device);
	gc_mark_q(f__scale);
	gc_mark_q(f__inputController);
	gc_mark_q(f__handler);
	gc_mark_q(f_deltaTimer);
}
bb_list_List::bb_list_List(){
	f__head=((new bb_list_HeadNode)->g_new());
}
bb_list_List* bb_list_List::g_new(){
	return this;
}
bb_list_Node* bb_list_List::m_AddLast(String t_data){
	return (new bb_list_Node)->g_new(f__head,f__head->f__pred,t_data);
}
bb_list_List* bb_list_List::g_new2(Array<String > t_data){
	Array<String > t_=t_data;
	int t_2=0;
	while(t_2<t_.Length()){
		String t_t=t_[t_2];
		t_2=t_2+1;
		m_AddLast(t_t);
	}
	return this;
}
bool bb_list_List::m_Equals(String t_lhs,String t_rhs){
	return t_lhs==t_rhs;
}
bool bb_list_List::m_Contains(String t_value){
	bb_list_Node* t_node=f__head->f__succ;
	while(t_node!=f__head){
		if(m_Equals(t_node->f__data,t_value)){
			return true;
		}
		t_node=t_node->f__succ;
	}
	return false;
}
void bb_list_List::mark(){
	Object::mark();
	gc_mark_q(f__head);
}
bb_list_Node::bb_list_Node(){
	f__succ=0;
	f__pred=0;
	f__data=String();
}
bb_list_Node* bb_list_Node::g_new(bb_list_Node* t_succ,bb_list_Node* t_pred,String t_data){
	gc_assign(f__succ,t_succ);
	gc_assign(f__pred,t_pred);
	gc_assign(f__succ->f__pred,this);
	gc_assign(f__pred->f__succ,this);
	f__data=t_data;
	return this;
}
bb_list_Node* bb_list_Node::g_new2(){
	return this;
}
void bb_list_Node::mark(){
	Object::mark();
	gc_mark_q(f__succ);
	gc_mark_q(f__pred);
}
bb_list_HeadNode::bb_list_HeadNode(){
}
bb_list_HeadNode* bb_list_HeadNode::g_new(){
	bb_list_Node::g_new2();
	gc_assign(f__succ,(this));
	gc_assign(f__pred,(this));
	return this;
}
void bb_list_HeadNode::mark(){
	bb_list_Node::mark();
}
bb_app_AppDevice::bb_app_AppDevice(){
	f_app=0;
	f_updateRate=0;
}
bb_app_AppDevice* bb_app_AppDevice::g_new(bb_app_App* t_app){
	gc_assign(this->f_app,t_app);
	bb_graphics_SetGraphicsContext((new bb_graphics_GraphicsContext)->g_new(GraphicsDevice()));
	bb_input_SetInputDevice(InputDevice());
	bb_audio_SetAudioDevice(AudioDevice());
	return this;
}
bb_app_AppDevice* bb_app_AppDevice::g_new2(){
	return this;
}
int bb_app_AppDevice::OnCreate(){
	bb_graphics_SetFont(0,32);
	return f_app->m_OnCreate2();
}
int bb_app_AppDevice::OnUpdate(){
	return f_app->m_OnUpdate2();
}
int bb_app_AppDevice::OnSuspend(){
	return f_app->m_OnSuspend();
}
int bb_app_AppDevice::OnResume(){
	return f_app->m_OnResume2();
}
int bb_app_AppDevice::OnRender(){
	bb_graphics_BeginRender();
	int t_r=f_app->m_OnRender();
	bb_graphics_EndRender();
	return t_r;
}
int bb_app_AppDevice::OnLoading(){
	bb_graphics_BeginRender();
	int t_r=f_app->m_OnLoading();
	bb_graphics_EndRender();
	return t_r;
}
int bb_app_AppDevice::SetUpdateRate(int t_hertz){
	gxtkApp::SetUpdateRate(t_hertz);
	f_updateRate=t_hertz;
	return 0;
}
void bb_app_AppDevice::mark(){
	gxtkApp::mark();
	gc_mark_q(f_app);
}
bb_graphics_GraphicsContext::bb_graphics_GraphicsContext(){
	f_device=0;
	f_defaultFont=0;
	f_font=0;
	f_firstChar=0;
	f_matrixSp=0;
	f_ix=FLOAT(1.0);
	f_iy=FLOAT(.0);
	f_jx=FLOAT(.0);
	f_jy=FLOAT(1.0);
	f_tx=FLOAT(.0);
	f_ty=FLOAT(.0);
	f_tformed=0;
	f_matDirty=0;
	f_color_r=FLOAT(.0);
	f_color_g=FLOAT(.0);
	f_color_b=FLOAT(.0);
	f_alpha=FLOAT(.0);
	f_blend=0;
	f_scissor_x=FLOAT(.0);
	f_scissor_y=FLOAT(.0);
	f_scissor_width=FLOAT(.0);
	f_scissor_height=FLOAT(.0);
	f_matrixStack=Array<Float >(192);
}
bb_graphics_GraphicsContext* bb_graphics_GraphicsContext::g_new(gxtkGraphics* t_device){
	gc_assign(this->f_device,t_device);
	return this;
}
bb_graphics_GraphicsContext* bb_graphics_GraphicsContext::g_new2(){
	return this;
}
void bb_graphics_GraphicsContext::mark(){
	Object::mark();
	gc_mark_q(f_device);
	gc_mark_q(f_defaultFont);
	gc_mark_q(f_font);
	gc_mark_q(f_matrixStack);
}
bb_graphics_GraphicsContext* bb_graphics_context;
int bb_graphics_SetGraphicsContext(bb_graphics_GraphicsContext* t_gc){
	gc_assign(bb_graphics_context,t_gc);
	return 0;
}
gxtkInput* bb_input_device;
int bb_input_SetInputDevice(gxtkInput* t_dev){
	gc_assign(bb_input_device,t_dev);
	return 0;
}
gxtkAudio* bb_audio_device;
int bb_audio_SetAudioDevice(gxtkAudio* t_dev){
	gc_assign(bb_audio_device,t_dev);
	return 0;
}
bb_app_AppDevice* bb_app_device;
bb_vector2d_Vector2D::bb_vector2d_Vector2D(){
	f_x=FLOAT(.0);
	f_y=FLOAT(.0);
}
bb_vector2d_Vector2D* bb_vector2d_Vector2D::g_new(Float t_x,Float t_y){
	this->f_x=t_x;
	this->f_y=t_y;
	return this;
}
bb_vector2d_Vector2D* bb_vector2d_Vector2D::m_Copy(){
	return (new bb_vector2d_Vector2D)->g_new(f_x,f_y);
}
bb_vector2d_Vector2D* bb_vector2d_Vector2D::m_Div(bb_vector2d_Vector2D* t_v2){
	f_x/=t_v2->f_x;
	f_y/=t_v2->f_y;
	return this;
}
bb_vector2d_Vector2D* bb_vector2d_Vector2D::m_Div2(Float t_factor){
	f_y/=t_factor;
	f_x/=t_factor;
	return this;
}
bb_vector2d_Vector2D* bb_vector2d_Vector2D::m_Add2(bb_vector2d_Vector2D* t_v2){
	f_x+=t_v2->f_x;
	f_y+=t_v2->f_y;
	return this;
}
bb_vector2d_Vector2D* bb_vector2d_Vector2D::m_Add3(Float t_factor){
	f_x+=t_factor;
	f_y+=t_factor;
	return this;
}
bb_vector2d_Vector2D* bb_vector2d_Vector2D::m_Sub(bb_vector2d_Vector2D* t_v2){
	f_x-=t_v2->f_x;
	f_y-=t_v2->f_y;
	return this;
}
bb_vector2d_Vector2D* bb_vector2d_Vector2D::m_Sub2(Float t_factor){
	f_x-=t_factor;
	f_y-=t_factor;
	return this;
}
Float bb_vector2d_Vector2D::m_Length(){
	return (Float)sqrt(f_x*f_x+f_y*f_y);
}
bb_vector2d_Vector2D* bb_vector2d_Vector2D::m_Normalize(){
	Float t_length=m_Length();
	if(t_length==FLOAT(0.0)){
		return this;
	}
	f_x/=t_length;
	f_y/=t_length;
	return this;
}
bb_vector2d_Vector2D* bb_vector2d_Vector2D::m_Mul(bb_vector2d_Vector2D* t_v2){
	f_x*=t_v2->f_x;
	f_y*=t_v2->f_y;
	return this;
}
bb_vector2d_Vector2D* bb_vector2d_Vector2D::m_Mul2(Float t_factor){
	f_x*=t_factor;
	f_y*=t_factor;
	return this;
}
void bb_vector2d_Vector2D::mark(){
	Object::mark();
}
bb_inputcontroller_InputController::bb_inputcontroller_InputController(){
	f_trackTouch=false;
	f__touchFingers=1;
	f_touchRetainSize=5;
	f_scale=(new bb_vector2d_Vector2D)->g_new(FLOAT(0.0),FLOAT(0.0));
	f_isTouchDown=Array<bool >(31);
	f_touchEvents=Array<bb_touchevent_TouchEvent* >(31);
	f_touchDownDispatched=Array<bool >(31);
	f_touchMinDistance=FLOAT(5.0);
	f_trackKeys=false;
	f_keyboardEnabled=false;
	f_keysActive=(new bb_set_IntSet)->g_new();
	f_keyEvents=(new bb_map_IntMap2)->g_new();
	f_dispatchedKeyEvents=(new bb_set_IntSet)->g_new();
}
bb_inputcontroller_InputController* bb_inputcontroller_InputController::g_new(){
	return this;
}
void bb_inputcontroller_InputController::m_touchFingers(int t_number){
	if(t_number>31){
		Error(String(L"Only 31 can be tracked."));
	}
	if(((!((t_number)!=0))?1:0)>0){
		Error(String(L"Number of fingers must be greater than 0."));
	}
	f__touchFingers=t_number;
}
void bb_inputcontroller_InputController::m_ReadTouch(){
	bb_vector2d_Vector2D* t_scaledVector=0;
	bb_vector2d_Vector2D* t_diffVector=0;
	bool t_lastTouchDown=false;
	for(int t_i=0;t_i<f__touchFingers;t_i=t_i+1){
		t_lastTouchDown=f_isTouchDown[t_i];
		f_isTouchDown[t_i]=((bb_input_TouchDown(t_i))!=0);
		if(!f_isTouchDown[t_i] && !t_lastTouchDown){
			continue;
		}
		if(f_touchEvents[t_i]==0){
			f_touchDownDispatched[t_i]=false;
			gc_assign(f_touchEvents[t_i],(new bb_touchevent_TouchEvent)->g_new(t_i));
		}
		t_scaledVector=((new bb_vector2d_Vector2D)->g_new(bb_input_TouchX(t_i),bb_input_TouchY(t_i)))->m_Div(f_scale);
		t_diffVector=t_scaledVector->m_Copy()->m_Sub(f_touchEvents[t_i]->m_prevPos());
		if(t_diffVector->m_Length()>=f_touchMinDistance){
			f_touchEvents[t_i]->m_Add2(t_scaledVector);
			if(f_touchRetainSize>-1){
				f_touchEvents[t_i]->m_Trim(f_touchRetainSize);
			}
		}
	}
}
void bb_inputcontroller_InputController::m_ProcessTouch(bb_directorevents_DirectorEvents* t_handler){
	for(int t_i=0;t_i<f__touchFingers;t_i=t_i+1){
		if(f_touchEvents[t_i]==0){
			continue;
		}
		if(!f_touchDownDispatched[t_i]){
			t_handler->m_OnTouchDown(f_touchEvents[t_i]->m_Copy());
			f_touchDownDispatched[t_i]=true;
		}else{
			if(!f_isTouchDown[t_i]){
				t_handler->m_OnTouchUp(f_touchEvents[t_i]);
				f_touchEvents[t_i]=0;
			}else{
				t_handler->m_OnTouchMove(f_touchEvents[t_i]);
			}
		}
	}
}
void bb_inputcontroller_InputController::m_ReadKeys(){
	f_keysActive->m_Clear();
	int t_charCode=0;
	do{
		t_charCode=bb_input_GetChar();
		if(!((t_charCode)!=0)){
			return;
		}
		f_keysActive->m_Insert4(t_charCode);
		if(!f_keyEvents->m_Contains2(t_charCode)){
			f_keyEvents->m_Add6(t_charCode,(new bb_keyevent_KeyEvent)->g_new(t_charCode));
			f_dispatchedKeyEvents->m_Remove4(t_charCode);
		}
	}while(!(false));
}
void bb_inputcontroller_InputController::m_ProcessKeys(bb_directorevents_DirectorEvents* t_handler){
	bb_map_ValueEnumerator* t_=f_keyEvents->m_Values()->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_keyevent_KeyEvent* t_event=t_->m_NextObject();
		if(!f_dispatchedKeyEvents->m_Contains2(t_event->m_code())){
			t_handler->m_OnKeyDown(t_event);
			f_dispatchedKeyEvents->m_Insert4(t_event->m_code());
			continue;
		}
		if(!f_keysActive->m_Contains2(t_event->m_code())){
			t_handler->m_OnKeyUp(t_event);
			f_dispatchedKeyEvents->m_Remove4(t_event->m_code());
			f_keyEvents->m_Remove4(t_event->m_code());
		}else{
			t_handler->m_OnKeyPress(t_event);
		}
	}
}
void bb_inputcontroller_InputController::m_OnUpdate3(bb_directorevents_DirectorEvents* t_handler){
	if(f_trackTouch){
		m_ReadTouch();
		m_ProcessTouch(t_handler);
	}
	if(f_trackKeys){
		if(!f_keyboardEnabled){
			f_keyboardEnabled=true;
			bb_input_EnableKeyboard();
		}
		m_ReadKeys();
		m_ProcessKeys(t_handler);
	}else{
		if(f_keyboardEnabled){
			f_keyboardEnabled=false;
			bb_input_DisableKeyboard();
			f_keysActive->m_Clear();
			f_keyEvents->m_Clear();
			f_dispatchedKeyEvents->m_Clear();
		}
	}
}
void bb_inputcontroller_InputController::mark(){
	Object::mark();
	gc_mark_q(f_scale);
	gc_mark_q(f_isTouchDown);
	gc_mark_q(f_touchEvents);
	gc_mark_q(f_touchDownDispatched);
	gc_mark_q(f_keysActive);
	gc_mark_q(f_keyEvents);
	gc_mark_q(f_dispatchedKeyEvents);
}
int bbMain(){
	bb_router_Router* t_router=(new bb_router_Router)->g_new();
	t_router->m_Add(String(L"intro"),((new bb_introscene_IntroScene)->g_new()));
	t_router->m_Add(String(L"menu"),((new bb_menuscene_MenuScene)->g_new()));
	t_router->m_Add(String(L"highscore"),((new bb_highscorescene_HighscoreScene)->g_new()));
	t_router->m_Add(String(L"game"),((new bb_gamescene_GameScene)->g_new()));
	t_router->m_Add(String(L"gameover"),((new bb_gameoverscene_GameOverScene)->g_new()));
	t_router->m_Add(String(L"pause"),((new bb_pausescene_PauseScene)->g_new()));
	t_router->m_Add(String(L"newhighscore"),((new bb_newhighscorescene_NewHighscoreScene)->g_new()));
	t_router->m_Goto(String(L"intro"));
	bb_director_Director* t_director=(new bb_director_Director)->g_new(640,960);
	t_director->m_inputController()->f_trackTouch=true;
	t_director->m_inputController()->m_touchFingers(1);
	t_director->m_inputController()->f_touchRetainSize=25;
	t_director->m_Run(t_router);
	return 0;
}
bb_fanout_FanOut::bb_fanout_FanOut(){
	f_objects=(new bb_list_List2)->g_new();
}
bb_fanout_FanOut* bb_fanout_FanOut::g_new(){
	return this;
}
void bb_fanout_FanOut::m_OnCreate(bb_director_Director* t_director){
	if(!((f_objects)!=0)){
		return;
	}
	bb_list_Enumerator* t_=f_objects->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_directorevents_DirectorEvents* t_obj=t_->m_NextObject();
		t_obj->m_OnCreate(t_director);
	}
}
void bb_fanout_FanOut::m_Add4(bb_directorevents_DirectorEvents* t_obj){
	f_objects->m_AddLast2(t_obj);
}
void bb_fanout_FanOut::m_Remove(bb_directorevents_DirectorEvents* t_obj){
	f_objects->m_RemoveEach(t_obj);
}
void bb_fanout_FanOut::m_Clear(){
	f_objects->m_Clear();
}
void bb_fanout_FanOut::m_OnLoading(){
	if(!((f_objects)!=0)){
		return;
	}
	bb_list_Enumerator* t_=f_objects->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_directorevents_DirectorEvents* t_obj=t_->m_NextObject();
		t_obj->m_OnLoading();
	}
}
void bb_fanout_FanOut::m_OnUpdate(Float t_delta,Float t_frameTime){
	if(!((f_objects)!=0)){
		return;
	}
	bb_list_Enumerator* t_=f_objects->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_directorevents_DirectorEvents* t_obj=t_->m_NextObject();
		t_obj->m_OnUpdate(t_delta,t_frameTime);
	}
}
void bb_fanout_FanOut::m_OnRender(){
	if(!((f_objects)!=0)){
		return;
	}
	bb_list_Enumerator* t_=f_objects->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_directorevents_DirectorEvents* t_obj=t_->m_NextObject();
		t_obj->m_OnRender();
	}
}
void bb_fanout_FanOut::m_OnSuspend(){
	if(!((f_objects)!=0)){
		return;
	}
	bb_list_Enumerator* t_=f_objects->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_directorevents_DirectorEvents* t_obj=t_->m_NextObject();
		t_obj->m_OnSuspend();
	}
}
void bb_fanout_FanOut::m_OnResume(int t_delta){
	if(!((f_objects)!=0)){
		return;
	}
	bb_list_Enumerator* t_=f_objects->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_directorevents_DirectorEvents* t_obj=t_->m_NextObject();
		t_obj->m_OnResume(t_delta);
	}
}
void bb_fanout_FanOut::m_OnKeyDown(bb_keyevent_KeyEvent* t_event){
	if(!((f_objects)!=0)){
		return;
	}
	bb_list_Enumerator* t_=f_objects->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_directorevents_DirectorEvents* t_obj=t_->m_NextObject();
		t_obj->m_OnKeyDown(t_event);
	}
}
void bb_fanout_FanOut::m_OnKeyPress(bb_keyevent_KeyEvent* t_event){
	if(!((f_objects)!=0)){
		return;
	}
	bb_list_Enumerator* t_=f_objects->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_directorevents_DirectorEvents* t_obj=t_->m_NextObject();
		t_obj->m_OnKeyPress(t_event);
	}
}
void bb_fanout_FanOut::m_OnKeyUp(bb_keyevent_KeyEvent* t_event){
	if(!((f_objects)!=0)){
		return;
	}
	bb_list_Enumerator* t_=f_objects->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_directorevents_DirectorEvents* t_obj=t_->m_NextObject();
		t_obj->m_OnKeyUp(t_event);
	}
}
void bb_fanout_FanOut::m_OnTouchDown(bb_touchevent_TouchEvent* t_event){
	if(!((f_objects)!=0)){
		return;
	}
	bb_list_Enumerator* t_=f_objects->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_directorevents_DirectorEvents* t_obj=t_->m_NextObject();
		t_obj->m_OnTouchDown(t_event);
	}
}
void bb_fanout_FanOut::m_OnTouchMove(bb_touchevent_TouchEvent* t_event){
	if(!((f_objects)!=0)){
		return;
	}
	bb_list_Enumerator* t_=f_objects->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_directorevents_DirectorEvents* t_obj=t_->m_NextObject();
		t_obj->m_OnTouchMove(t_event);
	}
}
void bb_fanout_FanOut::m_OnTouchUp(bb_touchevent_TouchEvent* t_event){
	if(!((f_objects)!=0)){
		return;
	}
	bb_list_Enumerator* t_=f_objects->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_directorevents_DirectorEvents* t_obj=t_->m_NextObject();
		t_obj->m_OnTouchUp(t_event);
	}
}
int bb_fanout_FanOut::m_Count(){
	return f_objects->m_Count();
}
bb_list_Enumerator* bb_fanout_FanOut::m_ObjectEnumerator(){
	return f_objects->m_ObjectEnumerator();
}
void bb_fanout_FanOut::mark(){
	Object::mark();
	gc_mark_q(f_objects);
}
bb_list_List2::bb_list_List2(){
	f__head=((new bb_list_HeadNode2)->g_new());
}
bb_list_List2* bb_list_List2::g_new(){
	return this;
}
bb_list_Node2* bb_list_List2::m_AddLast2(bb_directorevents_DirectorEvents* t_data){
	return (new bb_list_Node2)->g_new(f__head,f__head->f__pred,t_data);
}
bb_list_List2* bb_list_List2::g_new2(Array<bb_directorevents_DirectorEvents* > t_data){
	Array<bb_directorevents_DirectorEvents* > t_=t_data;
	int t_2=0;
	while(t_2<t_.Length()){
		bb_directorevents_DirectorEvents* t_t=t_[t_2];
		t_2=t_2+1;
		m_AddLast2(t_t);
	}
	return this;
}
bb_list_Enumerator* bb_list_List2::m_ObjectEnumerator(){
	return (new bb_list_Enumerator)->g_new(this);
}
bool bb_list_List2::m_Equals2(bb_directorevents_DirectorEvents* t_lhs,bb_directorevents_DirectorEvents* t_rhs){
	return t_lhs==t_rhs;
}
int bb_list_List2::m_RemoveEach(bb_directorevents_DirectorEvents* t_value){
	bb_list_Node2* t_node=f__head->f__succ;
	while(t_node!=f__head){
		bb_list_Node2* t_succ=t_node->f__succ;
		if(m_Equals2(t_node->f__data,t_value)){
			t_node->m_Remove2();
		}
		t_node=t_succ;
	}
	return 0;
}
int bb_list_List2::m_Clear(){
	gc_assign(f__head->f__succ,f__head);
	gc_assign(f__head->f__pred,f__head);
	return 0;
}
int bb_list_List2::m_Count(){
	int t_n=0;
	bb_list_Node2* t_node=f__head->f__succ;
	while(t_node!=f__head){
		t_node=t_node->f__succ;
		t_n+=1;
	}
	return t_n;
}
void bb_list_List2::mark(){
	Object::mark();
	gc_mark_q(f__head);
}
bb_list_Node2::bb_list_Node2(){
	f__succ=0;
	f__pred=0;
	f__data=0;
}
bb_list_Node2* bb_list_Node2::g_new(bb_list_Node2* t_succ,bb_list_Node2* t_pred,bb_directorevents_DirectorEvents* t_data){
	gc_assign(f__succ,t_succ);
	gc_assign(f__pred,t_pred);
	gc_assign(f__succ->f__pred,this);
	gc_assign(f__pred->f__succ,this);
	gc_assign(f__data,t_data);
	return this;
}
bb_list_Node2* bb_list_Node2::g_new2(){
	return this;
}
int bb_list_Node2::m_Remove2(){
	gc_assign(f__succ->f__pred,f__pred);
	gc_assign(f__pred->f__succ,f__succ);
	return 0;
}
void bb_list_Node2::mark(){
	Object::mark();
	gc_mark_q(f__succ);
	gc_mark_q(f__pred);
	gc_mark_q(f__data);
}
bb_list_HeadNode2::bb_list_HeadNode2(){
}
bb_list_HeadNode2* bb_list_HeadNode2::g_new(){
	bb_list_Node2::g_new2();
	gc_assign(f__succ,(this));
	gc_assign(f__pred,(this));
	return this;
}
void bb_list_HeadNode2::mark(){
	bb_list_Node2::mark();
}
bb_list_Enumerator::bb_list_Enumerator(){
	f__list=0;
	f__curr=0;
}
bb_list_Enumerator* bb_list_Enumerator::g_new(bb_list_List2* t_list){
	gc_assign(f__list,t_list);
	gc_assign(f__curr,t_list->f__head->f__succ);
	return this;
}
bb_list_Enumerator* bb_list_Enumerator::g_new2(){
	return this;
}
bool bb_list_Enumerator::m_HasNext(){
	while(f__curr->f__succ->f__pred!=f__curr){
		gc_assign(f__curr,f__curr->f__succ);
	}
	return f__curr!=f__list->f__head;
}
bb_directorevents_DirectorEvents* bb_list_Enumerator::m_NextObject(){
	bb_directorevents_DirectorEvents* t_data=f__curr->f__data;
	gc_assign(f__curr,f__curr->f__succ);
	return t_data;
}
void bb_list_Enumerator::mark(){
	Object::mark();
	gc_mark_q(f__list);
	gc_mark_q(f__curr);
}
bb_graphics_Image::bb_graphics_Image(){
	f_surface=0;
	f_width=0;
	f_height=0;
	f_frames=Array<bb_graphics_Frame* >();
	f_flags=0;
	f_tx=FLOAT(.0);
	f_ty=FLOAT(.0);
	f_source=0;
}
int bb_graphics_Image::g_DefaultFlags;
bb_graphics_Image* bb_graphics_Image::g_new(){
	return this;
}
int bb_graphics_Image::m_SetHandle(Float t_tx,Float t_ty){
	this->f_tx=t_tx;
	this->f_ty=t_ty;
	this->f_flags=this->f_flags&-2;
	return 0;
}
int bb_graphics_Image::m_ApplyFlags(int t_iflags){
	f_flags=t_iflags;
	if((f_flags&2)!=0){
		Array<bb_graphics_Frame* > t_=f_frames;
		int t_2=0;
		while(t_2<t_.Length()){
			bb_graphics_Frame* t_f=t_[t_2];
			t_2=t_2+1;
			t_f->f_x+=1;
		}
		f_width-=2;
	}
	if((f_flags&4)!=0){
		Array<bb_graphics_Frame* > t_3=f_frames;
		int t_4=0;
		while(t_4<t_3.Length()){
			bb_graphics_Frame* t_f2=t_3[t_4];
			t_4=t_4+1;
			t_f2->f_y+=1;
		}
		f_height-=2;
	}
	if((f_flags&1)!=0){
		m_SetHandle(Float(f_width)/FLOAT(2.0),Float(f_height)/FLOAT(2.0));
	}
	if(f_frames.Length()==1 && f_frames[0]->f_x==0 && f_frames[0]->f_y==0 && f_width==f_surface->Width() && f_height==f_surface->Height()){
		f_flags|=65536;
	}
	return 0;
}
bb_graphics_Image* bb_graphics_Image::m_Load(String t_path,int t_nframes,int t_iflags){
	gc_assign(f_surface,bb_graphics_context->f_device->LoadSurface(t_path));
	if(!((f_surface)!=0)){
		return 0;
	}
	f_width=f_surface->Width()/t_nframes;
	f_height=f_surface->Height();
	gc_assign(f_frames,Array<bb_graphics_Frame* >(t_nframes));
	for(int t_i=0;t_i<t_nframes;t_i=t_i+1){
		gc_assign(f_frames[t_i],(new bb_graphics_Frame)->g_new(t_i*f_width,0));
	}
	m_ApplyFlags(t_iflags);
	return this;
}
bb_graphics_Image* bb_graphics_Image::m_Grab(int t_x,int t_y,int t_iwidth,int t_iheight,int t_nframes,int t_iflags,bb_graphics_Image* t_source){
	gc_assign(this->f_source,t_source);
	gc_assign(f_surface,t_source->f_surface);
	f_width=t_iwidth;
	f_height=t_iheight;
	gc_assign(f_frames,Array<bb_graphics_Frame* >(t_nframes));
	int t_ix=t_x;
	int t_iy=t_y;
	for(int t_i=0;t_i<t_nframes;t_i=t_i+1){
		if(t_ix+f_width>t_source->f_width){
			t_ix=0;
			t_iy+=f_height;
		}
		if(t_ix+f_width>t_source->f_width || t_iy+f_height>t_source->f_height){
			Error(String(L"Image frame outside surface"));
		}
		gc_assign(f_frames[t_i],(new bb_graphics_Frame)->g_new(t_ix+t_source->f_frames[0]->f_x,t_iy+t_source->f_frames[0]->f_y));
		t_ix+=f_width;
	}
	m_ApplyFlags(t_iflags);
	return this;
}
bb_graphics_Image* bb_graphics_Image::m_GrabImage(int t_x,int t_y,int t_width,int t_height,int t_frames,int t_flags){
	if(this->f_frames.Length()!=1){
		return 0;
	}
	return ((new bb_graphics_Image)->g_new())->m_Grab(t_x,t_y,t_width,t_height,t_frames,t_flags,this);
}
int bb_graphics_Image::m_Width(){
	return f_width;
}
int bb_graphics_Image::m_Height(){
	return f_height;
}
void bb_graphics_Image::mark(){
	Object::mark();
	gc_mark_q(f_surface);
	gc_mark_q(f_frames);
	gc_mark_q(f_source);
}
bb_graphics_Frame::bb_graphics_Frame(){
	f_x=0;
	f_y=0;
}
bb_graphics_Frame* bb_graphics_Frame::g_new(int t_x,int t_y){
	this->f_x=t_x;
	this->f_y=t_y;
	return this;
}
bb_graphics_Frame* bb_graphics_Frame::g_new2(){
	return this;
}
void bb_graphics_Frame::mark(){
	Object::mark();
}
bb_graphics_Image* bb_graphics_LoadImage(String t_path,int t_frameCount,int t_flags){
	return ((new bb_graphics_Image)->g_new())->m_Load(t_path,t_frameCount,t_flags);
}
bb_graphics_Image* bb_graphics_LoadImage2(String t_path,int t_frameWidth,int t_frameHeight,int t_frameCount,int t_flags){
	bb_graphics_Image* t_atlas=((new bb_graphics_Image)->g_new())->m_Load(t_path,1,0);
	if((t_atlas)!=0){
		return t_atlas->m_GrabImage(0,0,t_frameWidth,t_frameHeight,t_frameCount,t_flags);
	}
	return 0;
}
bb_baseobject_BaseObject::bb_baseobject_BaseObject(){
	f__pos=0;
	f__size=0;
	f__center=0;
}
bb_baseobject_BaseObject* bb_baseobject_BaseObject::g_new(){
	bb_partial_Partial::g_new();
	return this;
}
bb_vector2d_Vector2D* bb_baseobject_BaseObject::m_pos(){
	if(f__pos==0){
		Error(String(L"Position not set yet."));
	}
	return f__pos;
}
void bb_baseobject_BaseObject::m_pos2(bb_vector2d_Vector2D* t_newPos){
	gc_assign(f__pos,t_newPos);
}
bb_vector2d_Vector2D* bb_baseobject_BaseObject::m_size(){
	if(f__size==0){
		Error(String(L"Size not set yet."));
	}
	return f__size;
}
void bb_baseobject_BaseObject::m_size2(bb_vector2d_Vector2D* t_newSize){
	gc_assign(f__size,t_newSize);
	gc_assign(f__center,t_newSize->m_Copy()->m_Div2(FLOAT(2.0)));
}
bb_vector2d_Vector2D* bb_baseobject_BaseObject::m_center(){
	if(f__center==0){
		Error(String(L"No size set and center therefore unset."));
	}
	return f__center;
}
void bb_baseobject_BaseObject::m_CenterX(bb_sizeable_Sizeable* t_entity){
	m_pos()->f_x=t_entity->m_center()->f_x-m_center()->f_x;
}
void bb_baseobject_BaseObject::m_Center(bb_sizeable_Sizeable* t_entity){
	m_pos2(t_entity->m_center()->m_Copy()->m_Sub(m_center()));
}
void bb_baseobject_BaseObject::mark(){
	bb_partial_Partial::mark();
	gc_mark_q(f__pos);
	gc_mark_q(f__size);
	gc_mark_q(f__center);
}
bb_sprite_Sprite::bb_sprite_Sprite(){
	f_image=0;
	f_frameCount=0;
	f_frameSpeed=0;
	f_rotation=FLOAT(.0);
	f_scale=(new bb_vector2d_Vector2D)->g_new(FLOAT(1.0),FLOAT(1.0));
	f_currentFrame=0;
	f_loopAnimation=false;
	f_frameTimer=0;
}
void bb_sprite_Sprite::m_InitVectors(int t_width,int t_height,bb_vector2d_Vector2D* t_pos){
	if(t_pos==0){
		this->m_pos2((new bb_vector2d_Vector2D)->g_new(FLOAT(0.0),FLOAT(0.0)));
	}else{
		this->m_pos2(t_pos);
	}
	m_size2((new bb_vector2d_Vector2D)->g_new(Float(t_width),Float(t_height)));
}
bb_sprite_Sprite* bb_sprite_Sprite::g_new(String t_imageName,bb_vector2d_Vector2D* t_pos){
	bb_baseobject_BaseObject::g_new();
	gc_assign(f_image,bb_graphics_LoadImage(t_imageName,1,bb_graphics_Image::g_DefaultFlags));
	m_InitVectors(f_image->m_Width(),f_image->m_Height(),t_pos);
	return this;
}
bb_sprite_Sprite* bb_sprite_Sprite::g_new2(String t_imageName,int t_frameWidth,int t_frameHeight,int t_frameCount,int t_frameSpeed,bb_vector2d_Vector2D* t_pos){
	bb_baseobject_BaseObject::g_new();
	this->f_frameCount=t_frameCount-1;
	this->f_frameSpeed=t_frameSpeed;
	gc_assign(f_image,bb_graphics_LoadImage2(t_imageName,t_frameWidth,t_frameHeight,t_frameCount,bb_graphics_Image::g_DefaultFlags));
	m_InitVectors(t_frameWidth,t_frameHeight,t_pos);
	return this;
}
bb_sprite_Sprite* bb_sprite_Sprite::g_new3(){
	bb_baseobject_BaseObject::g_new();
	return this;
}
void bb_sprite_Sprite::m_OnRender(){
	bb_partial_Partial::m_OnRender();
	bb_graphics_DrawImage2(f_image,m_pos()->f_x,m_pos()->f_y,f_rotation,f_scale->f_x,f_scale->f_y,f_currentFrame);
}
bool bb_sprite_Sprite::m_animationIsDone(){
	if(f_loopAnimation){
		return false;
	}
	return f_currentFrame==f_frameCount;
}
void bb_sprite_Sprite::m_OnUpdate(Float t_delta,Float t_frameTime){
	bb_partial_Partial::m_OnUpdate(t_delta,t_frameTime);
	if(f_frameCount<=0){
		return;
	}
	if(m_animationIsDone()){
		return;
	}
	if(f_frameTimer<f_frameSpeed){
		f_frameTimer=int(Float(f_frameTimer)+t_frameTime);
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
bool bb_sprite_Sprite::m_Collide(bb_vector2d_Vector2D* t_checkPos){
	if(t_checkPos->f_x<m_pos()->f_x || t_checkPos->f_x>m_pos()->f_x+m_size()->f_x){
		return false;
	}
	if(t_checkPos->f_y<m_pos()->f_y || t_checkPos->f_y>m_pos()->f_y+m_size()->f_y){
		return false;
	}
	return true;
}
void bb_sprite_Sprite::m_Restart(){
	f_currentFrame=0;
}
void bb_sprite_Sprite::mark(){
	bb_baseobject_BaseObject::mark();
	gc_mark_q(f_image);
	gc_mark_q(f_scale);
}
bb_angelfont2_AngelFont::bb_angelfont2_AngelFont(){
	f_iniText=String();
	f_kernPairs=(new bb_map_StringMap3)->g_new();
	f_chars=Array<bb_char_Char* >(256);
	f_height=0;
	f_heightOffset=9999;
	f_image=0;
	f_name=String();
	f_xOffset=0;
	f_useKerning=true;
}
String bb_angelfont2_AngelFont::g_error;
bb_angelfont2_AngelFont* bb_angelfont2_AngelFont::g_current;
void bb_angelfont2_AngelFont::m_LoadFont(String t_url){
	g_error=String();
	gc_assign(g_current,this);
	f_iniText=bb_app_LoadString(t_url+String(L".txt"));
	Array<String > t_lines=f_iniText.Split(String((Char)(10),1));
	Array<String > t_=t_lines;
	int t_2=0;
	while(t_2<t_.Length()){
		String t_line=t_[t_2];
		t_2=t_2+1;
		t_line=t_line.Trim();
		if(t_line.StartsWith(String(L"id,")) || t_line==String()){
			continue;
		}
		if(t_line.StartsWith(String(L"first,"))){
			continue;
		}
		Array<String > t_data=t_line.Split(String(L","));
		for(int t_i=0;t_i<t_data.Length();t_i=t_i+1){
			t_data[t_i]=t_data[t_i].Trim();
		}
		g_error=g_error+(String(t_data.Length())+String(L","));
		if(t_data.Length()>0){
			if(t_data.Length()==3){
				f_kernPairs->m_Insert(String((Char)((t_data[0]).ToInt()),1)+String(L"_")+String((Char)((t_data[1]).ToInt()),1),(new bb_kernpair_KernPair)->g_new((t_data[0]).ToInt(),(t_data[1]).ToInt(),(t_data[2]).ToInt()));
			}else{
				if(t_data.Length()>=8){
					gc_assign(f_chars[(t_data[0]).ToInt()],(new bb_char_Char)->g_new((t_data[1]).ToInt(),(t_data[2]).ToInt(),(t_data[3]).ToInt(),(t_data[4]).ToInt(),(t_data[5]).ToInt(),(t_data[6]).ToInt(),(t_data[7]).ToInt()));
					bb_char_Char* t_ch=f_chars[(t_data[0]).ToInt()];
					if(t_ch->f_height>this->f_height){
						this->f_height=t_ch->f_height;
					}
					if(t_ch->f_yOffset<this->f_heightOffset){
						this->f_heightOffset=t_ch->f_yOffset;
					}
				}
			}
		}
	}
	gc_assign(f_image,bb_graphics_LoadImage(t_url+String(L".png"),1,bb_graphics_Image::g_DefaultFlags));
}
bb_map_StringMap4* bb_angelfont2_AngelFont::g__list;
bb_angelfont2_AngelFont* bb_angelfont2_AngelFont::g_new(String t_url){
	if(t_url!=String()){
		this->m_LoadFont(t_url);
		this->f_name=t_url;
		g__list->m_Insert2(t_url,this);
	}
	return this;
}
void bb_angelfont2_AngelFont::m_DrawText(String t_txt,int t_x,int t_y){
	String t_prevChar=String();
	f_xOffset=0;
	for(int t_i=0;t_i<t_txt.Length();t_i=t_i+1){
		int t_asc=(int)t_txt[t_i];
		bb_char_Char* t_ac=f_chars[t_asc];
		String t_thisChar=String((Char)(t_asc),1);
		if(t_ac!=0){
			if(f_useKerning){
				String t_key=t_prevChar+String(L"_")+t_thisChar;
				if(f_kernPairs->m_Contains(t_key)){
					f_xOffset+=f_kernPairs->m_Get(t_key)->f_amount;
				}
			}
			t_ac->m_Draw(f_image,t_x+f_xOffset,t_y);
			f_xOffset+=t_ac->f_xAdvance;
			t_prevChar=t_thisChar;
		}
	}
}
int bb_angelfont2_AngelFont::m_TextWidth(String t_txt){
	String t_prevChar=String();
	int t_width=0;
	for(int t_i=0;t_i<t_txt.Length();t_i=t_i+1){
		int t_asc=(int)t_txt[t_i];
		bb_char_Char* t_ac=f_chars[t_asc];
		String t_thisChar=String((Char)(t_asc),1);
		if(t_ac!=0){
			if(f_useKerning){
				String t_key=t_prevChar+String(L"_")+t_thisChar;
				if(f_kernPairs->m_Contains(t_key)){
					t_width+=f_kernPairs->m_Get(t_key)->f_amount;
				}
			}
			t_width+=t_ac->f_xAdvance;
			t_prevChar=t_thisChar;
		}
	}
	return t_width;
}
void bb_angelfont2_AngelFont::m_DrawText2(String t_txt,int t_x,int t_y,int t_align){
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
void bb_angelfont2_AngelFont::mark(){
	Object::mark();
	gc_mark_q(f_kernPairs);
	gc_mark_q(f_chars);
	gc_mark_q(f_image);
}
String bb_app_LoadString(String t_path){
	return bb_app_device->LoadString(t_path);
}
bb_kernpair_KernPair::bb_kernpair_KernPair(){
	f_first=String();
	f_second=String();
	f_amount=0;
}
bb_kernpair_KernPair* bb_kernpair_KernPair::g_new(int t_first,int t_second,int t_amount){
	this->f_first=String(t_first);
	this->f_second=String(t_second);
	this->f_amount=t_amount;
	return this;
}
bb_kernpair_KernPair* bb_kernpair_KernPair::g_new2(){
	return this;
}
void bb_kernpair_KernPair::mark(){
	Object::mark();
}
bb_map_Map3::bb_map_Map3(){
	f_root=0;
}
bb_map_Map3* bb_map_Map3::g_new(){
	return this;
}
int bb_map_Map3::m_RotateLeft3(bb_map_Node3* t_node){
	bb_map_Node3* t_child=t_node->f_right;
	gc_assign(t_node->f_right,t_child->f_left);
	if((t_child->f_left)!=0){
		gc_assign(t_child->f_left->f_parent,t_node);
	}
	gc_assign(t_child->f_parent,t_node->f_parent);
	if((t_node->f_parent)!=0){
		if(t_node==t_node->f_parent->f_left){
			gc_assign(t_node->f_parent->f_left,t_child);
		}else{
			gc_assign(t_node->f_parent->f_right,t_child);
		}
	}else{
		gc_assign(f_root,t_child);
	}
	gc_assign(t_child->f_left,t_node);
	gc_assign(t_node->f_parent,t_child);
	return 0;
}
int bb_map_Map3::m_RotateRight3(bb_map_Node3* t_node){
	bb_map_Node3* t_child=t_node->f_left;
	gc_assign(t_node->f_left,t_child->f_right);
	if((t_child->f_right)!=0){
		gc_assign(t_child->f_right->f_parent,t_node);
	}
	gc_assign(t_child->f_parent,t_node->f_parent);
	if((t_node->f_parent)!=0){
		if(t_node==t_node->f_parent->f_right){
			gc_assign(t_node->f_parent->f_right,t_child);
		}else{
			gc_assign(t_node->f_parent->f_left,t_child);
		}
	}else{
		gc_assign(f_root,t_child);
	}
	gc_assign(t_child->f_right,t_node);
	gc_assign(t_node->f_parent,t_child);
	return 0;
}
int bb_map_Map3::m_InsertFixup3(bb_map_Node3* t_node){
	while(((t_node->f_parent)!=0) && t_node->f_parent->f_color==-1 && ((t_node->f_parent->f_parent)!=0)){
		if(t_node->f_parent==t_node->f_parent->f_parent->f_left){
			bb_map_Node3* t_uncle=t_node->f_parent->f_parent->f_right;
			if(((t_uncle)!=0) && t_uncle->f_color==-1){
				t_node->f_parent->f_color=1;
				t_uncle->f_color=1;
				t_uncle->f_parent->f_color=-1;
				t_node=t_uncle->f_parent;
			}else{
				if(t_node==t_node->f_parent->f_right){
					t_node=t_node->f_parent;
					m_RotateLeft3(t_node);
				}
				t_node->f_parent->f_color=1;
				t_node->f_parent->f_parent->f_color=-1;
				m_RotateRight3(t_node->f_parent->f_parent);
			}
		}else{
			bb_map_Node3* t_uncle2=t_node->f_parent->f_parent->f_left;
			if(((t_uncle2)!=0) && t_uncle2->f_color==-1){
				t_node->f_parent->f_color=1;
				t_uncle2->f_color=1;
				t_uncle2->f_parent->f_color=-1;
				t_node=t_uncle2->f_parent;
			}else{
				if(t_node==t_node->f_parent->f_left){
					t_node=t_node->f_parent;
					m_RotateRight3(t_node);
				}
				t_node->f_parent->f_color=1;
				t_node->f_parent->f_parent->f_color=-1;
				m_RotateLeft3(t_node->f_parent->f_parent);
			}
		}
	}
	f_root->f_color=1;
	return 0;
}
bool bb_map_Map3::m_Set3(String t_key,bb_kernpair_KernPair* t_value){
	bb_map_Node3* t_node=f_root;
	bb_map_Node3* t_parent=0;
	int t_cmp=0;
	while((t_node)!=0){
		t_parent=t_node;
		t_cmp=m_Compare(t_key,t_node->f_key);
		if(t_cmp>0){
			t_node=t_node->f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node->f_left;
			}else{
				gc_assign(t_node->f_value,t_value);
				return false;
			}
		}
	}
	t_node=(new bb_map_Node3)->g_new(t_key,t_value,-1,t_parent);
	if((t_parent)!=0){
		if(t_cmp>0){
			gc_assign(t_parent->f_right,t_node);
		}else{
			gc_assign(t_parent->f_left,t_node);
		}
		m_InsertFixup3(t_node);
	}else{
		gc_assign(f_root,t_node);
	}
	return true;
}
bool bb_map_Map3::m_Insert(String t_key,bb_kernpair_KernPair* t_value){
	return m_Set3(t_key,t_value);
}
bb_map_Node3* bb_map_Map3::m_FindNode(String t_key){
	bb_map_Node3* t_node=f_root;
	while((t_node)!=0){
		int t_cmp=m_Compare(t_key,t_node->f_key);
		if(t_cmp>0){
			t_node=t_node->f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node->f_left;
			}else{
				return t_node;
			}
		}
	}
	return t_node;
}
bool bb_map_Map3::m_Contains(String t_key){
	return m_FindNode(t_key)!=0;
}
bb_kernpair_KernPair* bb_map_Map3::m_Get(String t_key){
	bb_map_Node3* t_node=m_FindNode(t_key);
	if((t_node)!=0){
		return t_node->f_value;
	}
	return 0;
}
void bb_map_Map3::mark(){
	Object::mark();
	gc_mark_q(f_root);
}
bb_map_StringMap3::bb_map_StringMap3(){
}
bb_map_StringMap3* bb_map_StringMap3::g_new(){
	bb_map_Map3::g_new();
	return this;
}
int bb_map_StringMap3::m_Compare(String t_lhs,String t_rhs){
	return t_lhs.Compare(t_rhs);
}
void bb_map_StringMap3::mark(){
	bb_map_Map3::mark();
}
bb_map_Node3::bb_map_Node3(){
	f_key=String();
	f_right=0;
	f_left=0;
	f_value=0;
	f_color=0;
	f_parent=0;
}
bb_map_Node3* bb_map_Node3::g_new(String t_key,bb_kernpair_KernPair* t_value,int t_color,bb_map_Node3* t_parent){
	this->f_key=t_key;
	gc_assign(this->f_value,t_value);
	this->f_color=t_color;
	gc_assign(this->f_parent,t_parent);
	return this;
}
bb_map_Node3* bb_map_Node3::g_new2(){
	return this;
}
void bb_map_Node3::mark(){
	Object::mark();
	gc_mark_q(f_right);
	gc_mark_q(f_left);
	gc_mark_q(f_value);
	gc_mark_q(f_parent);
}
bb_char_Char::bb_char_Char(){
	f_x=0;
	f_y=0;
	f_width=0;
	f_height=0;
	f_xOffset=0;
	f_yOffset=0;
	f_xAdvance=0;
}
bb_char_Char* bb_char_Char::g_new(int t_x,int t_y,int t_w,int t_h,int t_xoff,int t_yoff,int t_xadv){
	this->f_x=t_x;
	this->f_y=t_y;
	this->f_width=t_w;
	this->f_height=t_h;
	this->f_xOffset=t_xoff;
	this->f_yOffset=t_yoff;
	this->f_xAdvance=t_xadv;
	return this;
}
bb_char_Char* bb_char_Char::g_new2(){
	return this;
}
int bb_char_Char::m_Draw(bb_graphics_Image* t_fontImage,int t_linex,int t_liney){
	bb_graphics_DrawImageRect(t_fontImage,Float(t_linex+f_xOffset),Float(t_liney+f_yOffset),f_x,f_y,f_width,f_height,0);
	return 0;
}
void bb_char_Char::mark(){
	Object::mark();
}
bb_map_Map4::bb_map_Map4(){
	f_root=0;
}
bb_map_Map4* bb_map_Map4::g_new(){
	return this;
}
int bb_map_Map4::m_RotateLeft4(bb_map_Node4* t_node){
	bb_map_Node4* t_child=t_node->f_right;
	gc_assign(t_node->f_right,t_child->f_left);
	if((t_child->f_left)!=0){
		gc_assign(t_child->f_left->f_parent,t_node);
	}
	gc_assign(t_child->f_parent,t_node->f_parent);
	if((t_node->f_parent)!=0){
		if(t_node==t_node->f_parent->f_left){
			gc_assign(t_node->f_parent->f_left,t_child);
		}else{
			gc_assign(t_node->f_parent->f_right,t_child);
		}
	}else{
		gc_assign(f_root,t_child);
	}
	gc_assign(t_child->f_left,t_node);
	gc_assign(t_node->f_parent,t_child);
	return 0;
}
int bb_map_Map4::m_RotateRight4(bb_map_Node4* t_node){
	bb_map_Node4* t_child=t_node->f_left;
	gc_assign(t_node->f_left,t_child->f_right);
	if((t_child->f_right)!=0){
		gc_assign(t_child->f_right->f_parent,t_node);
	}
	gc_assign(t_child->f_parent,t_node->f_parent);
	if((t_node->f_parent)!=0){
		if(t_node==t_node->f_parent->f_right){
			gc_assign(t_node->f_parent->f_right,t_child);
		}else{
			gc_assign(t_node->f_parent->f_left,t_child);
		}
	}else{
		gc_assign(f_root,t_child);
	}
	gc_assign(t_child->f_right,t_node);
	gc_assign(t_node->f_parent,t_child);
	return 0;
}
int bb_map_Map4::m_InsertFixup4(bb_map_Node4* t_node){
	while(((t_node->f_parent)!=0) && t_node->f_parent->f_color==-1 && ((t_node->f_parent->f_parent)!=0)){
		if(t_node->f_parent==t_node->f_parent->f_parent->f_left){
			bb_map_Node4* t_uncle=t_node->f_parent->f_parent->f_right;
			if(((t_uncle)!=0) && t_uncle->f_color==-1){
				t_node->f_parent->f_color=1;
				t_uncle->f_color=1;
				t_uncle->f_parent->f_color=-1;
				t_node=t_uncle->f_parent;
			}else{
				if(t_node==t_node->f_parent->f_right){
					t_node=t_node->f_parent;
					m_RotateLeft4(t_node);
				}
				t_node->f_parent->f_color=1;
				t_node->f_parent->f_parent->f_color=-1;
				m_RotateRight4(t_node->f_parent->f_parent);
			}
		}else{
			bb_map_Node4* t_uncle2=t_node->f_parent->f_parent->f_left;
			if(((t_uncle2)!=0) && t_uncle2->f_color==-1){
				t_node->f_parent->f_color=1;
				t_uncle2->f_color=1;
				t_uncle2->f_parent->f_color=-1;
				t_node=t_uncle2->f_parent;
			}else{
				if(t_node==t_node->f_parent->f_left){
					t_node=t_node->f_parent;
					m_RotateRight4(t_node);
				}
				t_node->f_parent->f_color=1;
				t_node->f_parent->f_parent->f_color=-1;
				m_RotateLeft4(t_node->f_parent->f_parent);
			}
		}
	}
	f_root->f_color=1;
	return 0;
}
bool bb_map_Map4::m_Set4(String t_key,bb_angelfont2_AngelFont* t_value){
	bb_map_Node4* t_node=f_root;
	bb_map_Node4* t_parent=0;
	int t_cmp=0;
	while((t_node)!=0){
		t_parent=t_node;
		t_cmp=m_Compare(t_key,t_node->f_key);
		if(t_cmp>0){
			t_node=t_node->f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node->f_left;
			}else{
				gc_assign(t_node->f_value,t_value);
				return false;
			}
		}
	}
	t_node=(new bb_map_Node4)->g_new(t_key,t_value,-1,t_parent);
	if((t_parent)!=0){
		if(t_cmp>0){
			gc_assign(t_parent->f_right,t_node);
		}else{
			gc_assign(t_parent->f_left,t_node);
		}
		m_InsertFixup4(t_node);
	}else{
		gc_assign(f_root,t_node);
	}
	return true;
}
bool bb_map_Map4::m_Insert2(String t_key,bb_angelfont2_AngelFont* t_value){
	return m_Set4(t_key,t_value);
}
void bb_map_Map4::mark(){
	Object::mark();
	gc_mark_q(f_root);
}
bb_map_StringMap4::bb_map_StringMap4(){
}
bb_map_StringMap4* bb_map_StringMap4::g_new(){
	bb_map_Map4::g_new();
	return this;
}
int bb_map_StringMap4::m_Compare(String t_lhs,String t_rhs){
	return t_lhs.Compare(t_rhs);
}
void bb_map_StringMap4::mark(){
	bb_map_Map4::mark();
}
bb_map_Node4::bb_map_Node4(){
	f_key=String();
	f_right=0;
	f_left=0;
	f_value=0;
	f_color=0;
	f_parent=0;
}
bb_map_Node4* bb_map_Node4::g_new(String t_key,bb_angelfont2_AngelFont* t_value,int t_color,bb_map_Node4* t_parent){
	this->f_key=t_key;
	gc_assign(this->f_value,t_value);
	this->f_color=t_color;
	gc_assign(this->f_parent,t_parent);
	return this;
}
bb_map_Node4* bb_map_Node4::g_new2(){
	return this;
}
void bb_map_Node4::mark(){
	Object::mark();
	gc_mark_q(f_right);
	gc_mark_q(f_left);
	gc_mark_q(f_value);
	gc_mark_q(f_parent);
}
bb_highscore_Highscore::bb_highscore_Highscore(){
	f__maxCount=0;
	f_objects=(new bb_list_List3)->g_new();
}
bb_highscore_Highscore* bb_highscore_Highscore::g_new(int t_maxCount){
	f__maxCount=t_maxCount;
	return this;
}
bb_highscore_Highscore* bb_highscore_Highscore::g_new2(){
	return this;
}
int bb_highscore_Highscore::m_Count(){
	return f_objects->m_Count();
}
int bb_highscore_Highscore::m_maxCount(){
	return f__maxCount;
}
void bb_highscore_Highscore::m_Sort(){
	if(f_objects->m_Count()<2){
		return;
	}
	bb_list_List3* t_newList=(new bb_list_List3)->g_new();
	bb_score_Score* t_current=0;
	while(f_objects->m_Count()>0){
		t_current=f_objects->m_First();
		bb_list_Enumerator2* t_=f_objects->m_ObjectEnumerator();
		while(t_->m_HasNext()){
			bb_score_Score* t_check=t_->m_NextObject();
			if(t_check->f_value<t_current->f_value){
				t_current=t_check;
			}
		}
		t_newList->m_AddFirst(t_current);
		f_objects->m_Remove3(t_current);
	}
	f_objects->m_Clear();
	gc_assign(f_objects,t_newList);
}
void bb_highscore_Highscore::m_SizeTrim(){
	while(f_objects->m_Count()>f__maxCount){
		f_objects->m_RemoveLast();
	}
}
void bb_highscore_Highscore::m_Add5(String t_key,int t_value){
	f_objects->m_AddLast3((new bb_score_Score)->g_new(t_key,t_value));
	m_Sort();
	m_SizeTrim();
}
bb_score_Score* bb_highscore_Highscore::m_Last(){
	if(f_objects->m_Count()==0){
		return (new bb_score_Score)->g_new(String(),0);
	}
	return f_objects->m_Last();
}
void bb_highscore_Highscore::m_FromString(String t_input){
	f_objects->m_Clear();
	String t_key=String();
	int t_value=0;
	Array<String > t_splitted=t_input.Split(String(L","));
	for(int t_count=0;t_count<=t_splitted.Length()-2;t_count=t_count+2){
		t_key=t_splitted[t_count].Replace(String(L"[COMMA]"),String(L","));
		t_value=(t_splitted[t_count+1]).ToInt();
		f_objects->m_AddLast3((new bb_score_Score)->g_new(t_key,t_value));
	}
	m_Sort();
}
bb_list_Enumerator2* bb_highscore_Highscore::m_ObjectEnumerator(){
	return f_objects->m_ObjectEnumerator();
}
String bb_highscore_Highscore::m_ToString(){
	String t_result=String();
	bb_list_Enumerator2* t_=this->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_score_Score* t_score=t_->m_NextObject();
		t_result=t_result+(t_score->f_key.Replace(String(L","),String(L"[COMMA]"))+String(L",")+String(t_score->f_value)+String(L","));
	}
	return t_result;
}
void bb_highscore_Highscore::mark(){
	Object::mark();
	gc_mark_q(f_objects);
}
bb_highscore_IntHighscore::bb_highscore_IntHighscore(){
}
bb_highscore_IntHighscore* bb_highscore_IntHighscore::g_new(int t_maxCount){
	bb_highscore_Highscore::g_new(t_maxCount);
	return this;
}
bb_highscore_IntHighscore* bb_highscore_IntHighscore::g_new2(){
	bb_highscore_Highscore::g_new2();
	return this;
}
void bb_highscore_IntHighscore::mark(){
	bb_highscore_Highscore::mark();
}
bb_gamehighscore_GameHighscore::bb_gamehighscore_GameHighscore(){
}
Array<String > bb_gamehighscore_GameHighscore::g_names;
Array<int > bb_gamehighscore_GameHighscore::g_scores;
void bb_gamehighscore_GameHighscore::m_LoadNamesAndScores(){
	String t_[]={String(L"Michael"),String(L"Sena"),String(L"Joe"),String(L"Mouser"),String(L"Tinnet"),String(L"Horas-Ra"),String(L"Monkey"),String(L"Mike"),String(L"Bono"),String(L"Angel")};
	gc_assign(g_names,Array<String >(t_,10));
	int t_2[]={1000,900,800,700,600,500,400,300,200,100};
	gc_assign(g_scores,Array<int >(t_2,10));
}
void bb_gamehighscore_GameHighscore::m_PrefillMissing(){
	if(m_Count()>=m_maxCount()){
		return;
	}
	for(int t_i=0;t_i<m_maxCount();t_i=t_i+1){
		m_Add5(String(L"easy ")+g_names[t_i],g_scores[t_i]);
	}
}
bb_gamehighscore_GameHighscore* bb_gamehighscore_GameHighscore::g_new(){
	bb_highscore_IntHighscore::g_new(10);
	m_LoadNamesAndScores();
	m_PrefillMissing();
	return this;
}
void bb_gamehighscore_GameHighscore::m_FromString(String t_input){
	bb_highscore_Highscore::m_FromString(t_input);
	m_PrefillMissing();
}
void bb_gamehighscore_GameHighscore::mark(){
	bb_highscore_IntHighscore::mark();
}
bb_score_Score::bb_score_Score(){
	f_key=String();
	f_value=0;
}
bb_score_Score* bb_score_Score::g_new(String t_key,int t_value){
	this->f_key=t_key;
	this->f_value=t_value;
	return this;
}
bb_score_Score* bb_score_Score::g_new2(){
	return this;
}
void bb_score_Score::mark(){
	Object::mark();
}
bb_list_List3::bb_list_List3(){
	f__head=((new bb_list_HeadNode3)->g_new());
}
bb_list_List3* bb_list_List3::g_new(){
	return this;
}
bb_list_Node3* bb_list_List3::m_AddLast3(bb_score_Score* t_data){
	return (new bb_list_Node3)->g_new(f__head,f__head->f__pred,t_data);
}
bb_list_List3* bb_list_List3::g_new2(Array<bb_score_Score* > t_data){
	Array<bb_score_Score* > t_=t_data;
	int t_2=0;
	while(t_2<t_.Length()){
		bb_score_Score* t_t=t_[t_2];
		t_2=t_2+1;
		m_AddLast3(t_t);
	}
	return this;
}
int bb_list_List3::m_Count(){
	int t_n=0;
	bb_list_Node3* t_node=f__head->f__succ;
	while(t_node!=f__head){
		t_node=t_node->f__succ;
		t_n+=1;
	}
	return t_n;
}
bb_score_Score* bb_list_List3::m_First(){
	return f__head->m_NextNode()->f__data;
}
bb_list_Enumerator2* bb_list_List3::m_ObjectEnumerator(){
	return (new bb_list_Enumerator2)->g_new(this);
}
bb_list_Node3* bb_list_List3::m_AddFirst(bb_score_Score* t_data){
	return (new bb_list_Node3)->g_new(f__head->f__succ,f__head,t_data);
}
bool bb_list_List3::m_Equals3(bb_score_Score* t_lhs,bb_score_Score* t_rhs){
	return t_lhs==t_rhs;
}
int bb_list_List3::m_RemoveEach2(bb_score_Score* t_value){
	bb_list_Node3* t_node=f__head->f__succ;
	while(t_node!=f__head){
		bb_list_Node3* t_succ=t_node->f__succ;
		if(m_Equals3(t_node->f__data,t_value)){
			t_node->m_Remove2();
		}
		t_node=t_succ;
	}
	return 0;
}
int bb_list_List3::m_Remove3(bb_score_Score* t_value){
	m_RemoveEach2(t_value);
	return 0;
}
int bb_list_List3::m_Clear(){
	gc_assign(f__head->f__succ,f__head);
	gc_assign(f__head->f__pred,f__head);
	return 0;
}
bb_score_Score* bb_list_List3::m_RemoveLast(){
	bb_score_Score* t_data=f__head->m_PrevNode()->f__data;
	f__head->f__pred->m_Remove2();
	return t_data;
}
bb_score_Score* bb_list_List3::m_Last(){
	return f__head->m_PrevNode()->f__data;
}
void bb_list_List3::mark(){
	Object::mark();
	gc_mark_q(f__head);
}
bb_list_Node3::bb_list_Node3(){
	f__succ=0;
	f__pred=0;
	f__data=0;
}
bb_list_Node3* bb_list_Node3::g_new(bb_list_Node3* t_succ,bb_list_Node3* t_pred,bb_score_Score* t_data){
	gc_assign(f__succ,t_succ);
	gc_assign(f__pred,t_pred);
	gc_assign(f__succ->f__pred,this);
	gc_assign(f__pred->f__succ,this);
	gc_assign(f__data,t_data);
	return this;
}
bb_list_Node3* bb_list_Node3::g_new2(){
	return this;
}
bb_list_Node3* bb_list_Node3::m_GetNode(){
	return this;
}
bb_list_Node3* bb_list_Node3::m_NextNode(){
	return f__succ->m_GetNode();
}
int bb_list_Node3::m_Remove2(){
	gc_assign(f__succ->f__pred,f__pred);
	gc_assign(f__pred->f__succ,f__succ);
	return 0;
}
bb_list_Node3* bb_list_Node3::m_PrevNode(){
	return f__pred->m_GetNode();
}
void bb_list_Node3::mark(){
	Object::mark();
	gc_mark_q(f__succ);
	gc_mark_q(f__pred);
	gc_mark_q(f__data);
}
bb_list_HeadNode3::bb_list_HeadNode3(){
}
bb_list_HeadNode3* bb_list_HeadNode3::g_new(){
	bb_list_Node3::g_new2();
	gc_assign(f__succ,(this));
	gc_assign(f__pred,(this));
	return this;
}
bb_list_Node3* bb_list_HeadNode3::m_GetNode(){
	return 0;
}
void bb_list_HeadNode3::mark(){
	bb_list_Node3::mark();
}
bb_list_Enumerator2::bb_list_Enumerator2(){
	f__list=0;
	f__curr=0;
}
bb_list_Enumerator2* bb_list_Enumerator2::g_new(bb_list_List3* t_list){
	gc_assign(f__list,t_list);
	gc_assign(f__curr,t_list->f__head->f__succ);
	return this;
}
bb_list_Enumerator2* bb_list_Enumerator2::g_new2(){
	return this;
}
bool bb_list_Enumerator2::m_HasNext(){
	while(f__curr->f__succ->f__pred!=f__curr){
		gc_assign(f__curr,f__curr->f__succ);
	}
	return f__curr!=f__list->f__head;
}
bb_score_Score* bb_list_Enumerator2::m_NextObject(){
	bb_score_Score* t_data=f__curr->f__data;
	gc_assign(f__curr,f__curr->f__succ);
	return t_data;
}
void bb_list_Enumerator2::mark(){
	Object::mark();
	gc_mark_q(f__list);
	gc_mark_q(f__curr);
}
bb_statestore_StateStore::bb_statestore_StateStore(){
}
void bb_statestore_StateStore::g_Load(bb_persistable_Persistable* t_obj){
	t_obj->m_FromString(bb_app_LoadState());
}
void bb_statestore_StateStore::g_Save(bb_persistable_Persistable* t_obj){
	bb_app_SaveState(t_obj->m_ToString());
}
void bb_statestore_StateStore::mark(){
	Object::mark();
}
String bb_app_LoadState(){
	return bb_app_device->LoadState();
}
bb_chute_Chute::bb_chute_Chute(){
	f_height=0;
	f_bg=0;
	f_width=0;
	f_bottom=0;
	f_severity=0;
}
bb_chute_Chute* bb_chute_Chute::g_new(){
	bb_baseobject_BaseObject::g_new();
	return this;
}
void bb_chute_Chute::m_Restart(){
	f_height=75;
}
void bb_chute_Chute::m_OnCreate(bb_director_Director* t_director){
	gc_assign(f_bg,bb_graphics_LoadImage(String(L"chute-bg.png"),1,bb_graphics_Image::g_DefaultFlags));
	f_width=f_bg->m_Width()+4;
	gc_assign(f_bottom,bb_graphics_LoadImage(String(L"chute-bottom.png"),1,bb_graphics_Image::g_DefaultFlags));
	gc_assign(f_severity,bb_severity_CurrentSeverity());
	m_Restart();
	bb_partial_Partial::m_OnCreate(t_director);
}
void bb_chute_Chute::m_OnUpdate(Float t_delta,Float t_frameTime){
	if(f_severity->m_ChuteShouldAdvance()){
		f_height+=f_severity->m_ChuteAdvanceHeight();
		f_severity->m_ChuteMarkAsAdvanced();
	}
}
void bb_chute_Chute::m_OnRender(){
	for(Float t_posY=FLOAT(0.0);t_posY<=Float(f_height);t_posY=t_posY+FLOAT(6.0)){
		bb_graphics_DrawImage(f_bg,Float(44+f_width*0),t_posY,0);
		bb_graphics_DrawImage(f_bg,Float(44+f_width*1),t_posY,0);
		bb_graphics_DrawImage(f_bg,Float(44+f_width*2),t_posY,0);
		bb_graphics_DrawImage(f_bg,Float(44+f_width*3),t_posY,0);
	}
	bb_graphics_DrawImage(f_bottom,Float(42+f_width*0),Float(f_height),0);
	bb_graphics_DrawImage(f_bottom,Float(42+f_width*1),Float(f_height),0);
	bb_graphics_DrawImage(f_bottom,Float(42+f_width*2),Float(f_height),0);
	bb_graphics_DrawImage(f_bottom,Float(42+f_width*3),Float(f_height),0);
}
int bb_chute_Chute::m_Height(){
	return f_height;
}
void bb_chute_Chute::mark(){
	bb_baseobject_BaseObject::mark();
	gc_mark_q(f_bg);
	gc_mark_q(f_bottom);
	gc_mark_q(f_severity);
}
bb_severity_Severity::bb_severity_Severity(){
	f_nextChuteAdvanceTime=0;
	f_nextShapeDropTime=0;
	f_lastTime=0;
	f_level=0;
	f_activatedShapes=0;
	f_slowDownDuration=0;
	f_lastTypes=(new bb_stack_IntStack)->g_new();
	f_progress=FLOAT(1.0);
	int t_[]={0,1,2,3};
	f_shapeTypes=Array<int >(t_,4);
	f_startTime=0;
	int t_2[]={0,0,0,0};
	f_laneTimes=Array<int >(t_2,4);
}
bb_severity_Severity* bb_severity_Severity::g_new(){
	return this;
}
void bb_severity_Severity::m_WarpTime(int t_diff){
	f_nextChuteAdvanceTime+=t_diff;
	f_nextShapeDropTime+=t_diff;
	f_lastTime+=t_diff;
}
void bb_severity_Severity::m_ChuteMarkAsAdvanced(){
	f_nextChuteAdvanceTime=int(bb_random_Rnd2(FLOAT(2000.0),FLOAT(4000.0)));
	int t_2=f_level;
	if(t_2==0){
		f_nextChuteAdvanceTime=int(Float(f_nextChuteAdvanceTime)+FLOAT(5000.0)*f_progress);
	}else{
		if(t_2==1){
			f_nextChuteAdvanceTime=int(Float(f_nextChuteAdvanceTime)+FLOAT(4000.0)*f_progress);
		}else{
			if(t_2==2){
				f_nextChuteAdvanceTime=int(Float(f_nextChuteAdvanceTime)+FLOAT(3000.0)*f_progress);
			}
		}
	}
	f_nextChuteAdvanceTime*=2;
	f_nextChuteAdvanceTime+=f_lastTime;
}
void bb_severity_Severity::m_ShapeDropped(){
	int t_3=f_level;
	if(t_3==0){
		f_nextShapeDropTime=int(Float(f_lastTime)+bb_random_Rnd2(FLOAT(450.0),FLOAT(1800.0)+FLOAT(2500.0)*f_progress));
	}else{
		if(t_3==1){
			f_nextShapeDropTime=int(Float(f_lastTime)+bb_random_Rnd2(FLOAT(350.0),FLOAT(1700.0)+FLOAT(2100.0)*f_progress));
		}else{
			if(t_3==2){
				f_nextShapeDropTime=int(Float(f_lastTime)+bb_random_Rnd2(FLOAT(250.0),FLOAT(1600.0)+FLOAT(1700.0)*f_progress));
			}
		}
	}
}
void bb_severity_Severity::m_RandomizeShapeTypes(){
	int t_swapIndex=0;
	int t_tmpType=0;
	for(int t_i=0;t_i<f_shapeTypes.Length();t_i=t_i+1){
		do{
			t_swapIndex=int(bb_random_Rnd2(FLOAT(0.0),Float(f_shapeTypes.Length())));
		}while(!(t_swapIndex!=t_i));
		t_tmpType=f_shapeTypes[t_i];
		f_shapeTypes[t_i]=f_shapeTypes[t_swapIndex];
		f_shapeTypes[t_swapIndex]=t_tmpType;
	}
}
void bb_severity_Severity::m_Restart(){
	int t_1=f_level;
	if(t_1==0){
		f_activatedShapes=2;
		f_slowDownDuration=120000;
	}else{
		if(t_1==1){
			f_activatedShapes=3;
			f_slowDownDuration=100000;
		}else{
			if(t_1==2){
				f_activatedShapes=4;
				f_slowDownDuration=80000;
			}
		}
	}
	f_lastTypes->m_Clear();
	m_ChuteMarkAsAdvanced();
	m_ShapeDropped();
	m_RandomizeShapeTypes();
	f_progress=FLOAT(1.0);
	f_startTime=bb_app_Millisecs();
}
int bb_severity_Severity::m_MinSliderTypes(){
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
void bb_severity_Severity::m_ConfigureSlider(bb_list_IntList* t_config){
	bb_set_IntSet* t_usedTypes=(new bb_set_IntSet)->g_new();
	t_config->m_Clear();
	for(int t_i=0;t_i<m_MinSliderTypes();t_i=t_i+1){
		t_usedTypes->m_Insert4(f_shapeTypes[t_i]);
		t_config->m_AddLast4(f_shapeTypes[t_i]);
	}
	while(t_config->m_Count()<4){
		if(t_usedTypes->m_Count()>=f_activatedShapes || bb_random_Rnd()<FLOAT(0.5)){
			t_config->m_AddLast4(f_shapeTypes[int(bb_random_Rnd2(FLOAT(0.0),Float(t_usedTypes->m_Count())))]);
		}else{
			t_config->m_AddLast4(f_shapeTypes[t_usedTypes->m_Count()]);
			t_usedTypes->m_Insert4(f_shapeTypes[t_usedTypes->m_Count()]);
		}
	}
	f_activatedShapes=t_usedTypes->m_Count();
}
bool bb_severity_Severity::m_ChuteShouldAdvance(){
	return f_lastTime>=f_nextChuteAdvanceTime;
}
int bb_severity_Severity::m_ChuteAdvanceHeight(){
	return 40;
}
void bb_severity_Severity::m_Set5(int t_level){
	this->f_level=t_level;
	m_Restart();
}
void bb_severity_Severity::m_OnUpdate(Float t_delta,Float t_frameTime){
	f_lastTime=bb_app_Millisecs();
	if(f_progress>FLOAT(0.0)){
		f_progress=FLOAT(1.0)-FLOAT(1.0)/Float(f_slowDownDuration)*Float(f_lastTime-f_startTime);
		f_progress=bb_math_Max2(FLOAT(0.0),f_progress);
	}
}
bool bb_severity_Severity::m_ShapeShouldBeDropped(){
	return f_lastTime>=f_nextShapeDropTime;
}
int bb_severity_Severity::m_RandomType(){
	int t_newType=0;
	bool t_finished=false;
	do{
		t_finished=true;
		t_newType=int(bb_random_Rnd2(FLOAT(0.0),Float(f_activatedShapes)));
		if(f_lastTypes->m_Length()>=2){
			if(f_lastTypes->m_Get2(0)==t_newType){
				if(f_lastTypes->m_Get2(1)==t_newType){
					t_finished=false;
				}
			}
		}
	}while(!(t_finished==true));
	if(f_lastTypes->m_Length()>=2){
		f_lastTypes->m_Remove4(0);
	}
	f_lastTypes->m_Push(t_newType);
	return f_shapeTypes[t_newType];
}
int bb_severity_Severity::m_RandomLane(){
	int t_newLane=0;
	int t_now=bb_app_Millisecs();
	do{
		t_newLane=int(bb_random_Rnd2(FLOAT(0.0),FLOAT(4.0)));
	}while(!(f_laneTimes[t_newLane]<t_now));
	f_laneTimes[t_newLane]=t_now+1400;
	return t_newLane;
}
String bb_severity_Severity::m_ToString(){
	if(f_level==0){
		return String(L"easy");
	}else{
		if(f_level==1){
			return String(L"norm");
		}else{
			return String(L"adv.");
		}
	}
}
void bb_severity_Severity::mark(){
	Object::mark();
	gc_mark_q(f_lastTypes);
	gc_mark_q(f_shapeTypes);
	gc_mark_q(f_laneTimes);
}
bb_severity_Severity* bb_severity_globalSeverityInstance;
bb_severity_Severity* bb_severity_CurrentSeverity(){
	if(!((bb_severity_globalSeverityInstance)!=0)){
		gc_assign(bb_severity_globalSeverityInstance,(new bb_severity_Severity)->g_new());
	}
	return bb_severity_globalSeverityInstance;
}
bb_slider_Slider::bb_slider_Slider(){
	f_images=Array<bb_graphics_Image* >();
	f_config=(new bb_list_IntList)->g_new();
	f_configArray=Array<int >();
	f_movementActive=false;
	f_movementStart=0;
	f_arrowLeft=0;
	f_arrowRight=0;
	f_posY=FLOAT(.0);
	f_direction=0;
}
bb_slider_Slider* bb_slider_Slider::g_new(){
	bb_baseobject_BaseObject::g_new();
	return this;
}
void bb_slider_Slider::m_InitializeConfig(){
	bb_severity_CurrentSeverity()->m_ConfigureSlider(f_config);
	gc_assign(f_configArray,f_config->m_ToArray());
}
void bb_slider_Slider::m_Restart(){
	m_InitializeConfig();
	f_movementActive=false;
	f_movementStart=0;
}
void bb_slider_Slider::m_OnCreate(bb_director_Director* t_director){
	bb_graphics_Image* t_[]={bb_graphics_LoadImage(String(L"circle_outside.png"),1,bb_graphics_Image::g_DefaultFlags),bb_graphics_LoadImage(String(L"plus_outside.png"),1,bb_graphics_Image::g_DefaultFlags),bb_graphics_LoadImage(String(L"star_outside.png"),1,bb_graphics_Image::g_DefaultFlags),bb_graphics_LoadImage(String(L"tire_outside.png"),1,bb_graphics_Image::g_DefaultFlags)};
	gc_assign(f_images,Array<bb_graphics_Image* >(t_,4));
	gc_assign(f_arrowLeft,(new bb_sprite_Sprite)->g_new(String(L"arrow_ingame.png"),0));
	f_arrowLeft->m_pos()->f_y=t_director->m_size()->f_y-f_arrowLeft->m_size()->f_y;
	bb_vector2d_Vector2D* t_2=f_arrowLeft->m_pos();
	t_2->f_x=t_2->f_x-FLOAT(4.0);
	gc_assign(f_arrowRight,(new bb_sprite_Sprite)->g_new(String(L"arrow_ingame2.png"),0));
	f_arrowRight->m_pos2(t_director->m_size()->m_Copy()->m_Sub(f_arrowRight->m_size()));
	bb_vector2d_Vector2D* t_3=f_arrowRight->m_pos();
	t_3->f_x=t_3->f_x+FLOAT(4.0);
	bb_partial_Partial::m_OnCreate(t_director);
	f_posY=t_director->m_size()->f_y-Float(f_images[0]->m_Height())-FLOAT(60.0);
}
bb_vector2d_Vector2D* bb_slider_Slider::m_pos(){
	return f_arrowLeft->m_pos();
}
Float bb_slider_Slider::m_GetMovementOffset(){
	if(!f_movementActive){
		return FLOAT(0.0);
	}
	int t_now=bb_app_Millisecs();
	Float t_percent=FLOAT(100.0);
	Float t_movementOffset=FLOAT(0.0);
	if(f_movementStart+300>=t_now){
		t_percent=(Float)ceil(FLOAT(0.33333333333333331)*Float(t_now-f_movementStart));
		t_movementOffset=(Float)ceil(Float(f_images[0]->m_Width())/FLOAT(100.0)*t_percent);
	}
	if(f_direction==1){
		t_movementOffset=t_movementOffset*FLOAT(-1.0);
	}
	if(f_movementStart+300<t_now){
		f_movementActive=false;
		if(f_direction==1){
			int t_tmpType=f_config->m_First();
			f_config->m_RemoveFirst();
			f_config->m_AddLast4(t_tmpType);
			gc_assign(f_configArray,f_config->m_ToArray());
		}else{
			int t_tmpType2=f_config->m_Last();
			f_config->m_RemoveLast();
			f_config->m_AddFirst2(t_tmpType2);
			gc_assign(f_configArray,f_config->m_ToArray());
		}
	}
	return t_movementOffset;
}
void bb_slider_Slider::m_OnRender(){
	Float t_posX=FLOAT(44.0)+m_GetMovementOffset();
	bb_graphics_Image* t_img=0;
	bb_graphics_PushMatrix();
	bb_graphics_SetColor(FLOAT(255.0),FLOAT(255.0),FLOAT(255.0));
	bb_graphics_DrawRect(FLOAT(0.0),f_posY+Float(f_images[f_config->m_First()]->m_Height()),m_director()->m_size()->f_x,m_director()->m_size()->f_y);
	bb_graphics_PopMatrix();
	if(t_posX>FLOAT(44.0)){
		t_img=f_images[f_config->m_Last()];
		bb_graphics_DrawImage(t_img,Float(t_img->m_Width()*-1)+t_posX,f_posY,0);
	}
	if(t_posX<FLOAT(44.0)){
		t_img=f_images[f_config->m_First()];
		bb_graphics_DrawImage(t_img,Float(t_img->m_Width()*4)+t_posX,f_posY,0);
	}
	bb_list_Enumerator3* t_=f_config->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		int t_type=t_->m_NextObject();
		bb_graphics_DrawImage(f_images[t_type],t_posX,f_posY,0);
		t_posX=t_posX+Float(f_images[t_type]->m_Width());
	}
	f_arrowRight->m_OnRender();
	f_arrowLeft->m_OnRender();
}
bool bb_slider_Slider::m_Match(bb_shape_Shape* t_shape){
	if(f_movementActive){
		return false;
	}
	if(t_shape->f_type==f_configArray[t_shape->f_lane]){
		return true;
	}
	return false;
}
void bb_slider_Slider::m_SlideLeft(){
	if(f_movementActive){
		return;
	}
	f_direction=1;
	f_movementStart=bb_app_Millisecs();
	f_movementActive=true;
}
void bb_slider_Slider::m_SlideRight(){
	if(f_movementActive){
		return;
	}
	f_direction=2;
	f_movementStart=bb_app_Millisecs();
	f_movementActive=true;
}
void bb_slider_Slider::mark(){
	bb_baseobject_BaseObject::mark();
	gc_mark_q(f_images);
	gc_mark_q(f_config);
	gc_mark_q(f_configArray);
	gc_mark_q(f_arrowLeft);
	gc_mark_q(f_arrowRight);
}
bb_font_Font::bb_font_Font(){
	f_name=String();
	f__align=0;
	f__text=String();
	f_fontStore=(new bb_map_StringMap5)->g_new();
	f_recalculateSize=false;
	f_color=0;
}
bb_font_Font* bb_font_Font::g_new(String t_fontName,bb_vector2d_Vector2D* t_pos){
	bb_baseobject_BaseObject::g_new();
	if(t_pos==0){
		t_pos=(new bb_vector2d_Vector2D)->g_new(FLOAT(0.0),FLOAT(0.0));
	}
	this->f_name=t_fontName;
	this->m_pos2(t_pos);
	return this;
}
bb_font_Font* bb_font_Font::g_new2(){
	bb_baseobject_BaseObject::g_new();
	return this;
}
void bb_font_Font::m_align(int t_newAlign){
	int t_1=t_newAlign;
	if(t_1==0 || t_1==1 || t_1==2){
		f__align=t_newAlign;
	}else{
		Error(String(L"Invalid align value specified."));
	}
}
int bb_font_Font::m_align2(){
	return f__align;
}
bb_angelfont_AngelFont* bb_font_Font::m_font(){
	return f_fontStore->m_Get(f_name);
}
void bb_font_Font::m_text(String t_newText){
	f__text=t_newText;
	if(!((m_font())!=0)){
		f_recalculateSize=true;
		return;
	}
	Float t_width=Float(m_font()->m_TextWidth(t_newText));
	Float t_height=Float(m_font()->m_TextHeight(t_newText));
	m_size2((new bb_vector2d_Vector2D)->g_new(t_width,t_height));
}
String bb_font_Font::m_text2(){
	return f__text;
}
void bb_font_Font::m_OnCreate(bb_director_Director* t_director){
	bb_partial_Partial::m_OnCreate(t_director);
	if(!f_fontStore->m_Contains(f_name)){
		f_fontStore->m_Set6(f_name,(new bb_angelfont_AngelFont)->g_new(String()));
		f_fontStore->m_Get(f_name)->m_LoadFont(f_name);
	}
	if(f_recalculateSize){
		f_recalculateSize=false;
		m_text(f__text);
	}
}
void bb_font_Font::m_OnRender(){
	if((f_color)!=0){
		f_color->m_Activate();
	}
	m_font()->m_DrawText2(f__text,int(m_pos()->f_x),int(m_pos()->f_y),f__align);
	if((f_color)!=0){
		f_color->m_Deactivate();
	}
}
void bb_font_Font::mark(){
	bb_baseobject_BaseObject::mark();
	gc_mark_q(f_fontStore);
	gc_mark_q(f_color);
}
bb_angelfont_AngelFont::bb_angelfont_AngelFont(){
	f_chars=Array<bb_char_Char* >(256);
	f_useKerning=true;
	f_kernPairs=(new bb_map_StringMap3)->g_new();
	f_iniText=String();
	f_height=0;
	f_heightOffset=9999;
	f_image=0;
	f_name=String();
	f_xOffset=0;
}
int bb_angelfont_AngelFont::m_TextWidth(String t_txt){
	String t_prevChar=String();
	int t_width=0;
	for(int t_i=0;t_i<t_txt.Length();t_i=t_i+1){
		int t_asc=(int)t_txt[t_i];
		bb_char_Char* t_ac=f_chars[t_asc];
		String t_thisChar=String((Char)(t_asc),1);
		if(t_ac!=0){
			if(f_useKerning){
				String t_key=t_prevChar+String(L"_")+t_thisChar;
				if(f_kernPairs->m_Contains(t_key)){
					t_width+=f_kernPairs->m_Get(t_key)->f_amount;
				}
			}
			t_width+=t_ac->f_xAdvance;
			t_prevChar=t_thisChar;
		}
	}
	return t_width;
}
int bb_angelfont_AngelFont::m_TextHeight(String t_txt){
	int t_h=0;
	for(int t_i=0;t_i<t_txt.Length();t_i=t_i+1){
		int t_asc=(int)t_txt[t_i];
		bb_char_Char* t_ac=f_chars[t_asc];
		if(t_ac->f_height>t_h){
			t_h=t_ac->f_height;
		}
	}
	return t_h;
}
String bb_angelfont_AngelFont::g_error;
bb_angelfont_AngelFont* bb_angelfont_AngelFont::g_current;
void bb_angelfont_AngelFont::m_LoadFont(String t_url){
	g_error=String();
	gc_assign(g_current,this);
	f_iniText=bb_app_LoadString(t_url+String(L".txt"));
	Array<String > t_lines=f_iniText.Split(String((Char)(10),1));
	Array<String > t_=t_lines;
	int t_2=0;
	while(t_2<t_.Length()){
		String t_line=t_[t_2];
		t_2=t_2+1;
		t_line=t_line.Trim();
		if(t_line.StartsWith(String(L"id,")) || t_line==String()){
			continue;
		}
		if(t_line.StartsWith(String(L"first,"))){
			continue;
		}
		Array<String > t_data=t_line.Split(String(L","));
		for(int t_i=0;t_i<t_data.Length();t_i=t_i+1){
			t_data[t_i]=t_data[t_i].Trim();
		}
		g_error=g_error+(String(t_data.Length())+String(L","));
		if(t_data.Length()>0){
			if(t_data.Length()==3){
				f_kernPairs->m_Insert(String((Char)((t_data[0]).ToInt()),1)+String(L"_")+String((Char)((t_data[1]).ToInt()),1),(new bb_kernpair_KernPair)->g_new((t_data[0]).ToInt(),(t_data[1]).ToInt(),(t_data[2]).ToInt()));
			}else{
				if(t_data.Length()>=8){
					gc_assign(f_chars[(t_data[0]).ToInt()],(new bb_char_Char)->g_new((t_data[1]).ToInt(),(t_data[2]).ToInt(),(t_data[3]).ToInt(),(t_data[4]).ToInt(),(t_data[5]).ToInt(),(t_data[6]).ToInt(),(t_data[7]).ToInt()));
					bb_char_Char* t_ch=f_chars[(t_data[0]).ToInt()];
					if(t_ch->f_height>this->f_height){
						this->f_height=t_ch->f_height;
					}
					if(t_ch->f_yOffset<this->f_heightOffset){
						this->f_heightOffset=t_ch->f_yOffset;
					}
				}
			}
		}
	}
	gc_assign(f_image,bb_graphics_LoadImage(t_url+String(L".png"),1,bb_graphics_Image::g_DefaultFlags));
}
bb_map_StringMap5* bb_angelfont_AngelFont::g__list;
bb_angelfont_AngelFont* bb_angelfont_AngelFont::g_new(String t_url){
	if(t_url!=String()){
		this->m_LoadFont(t_url);
		this->f_name=t_url;
		g__list->m_Insert3(t_url,this);
	}
	return this;
}
void bb_angelfont_AngelFont::m_DrawText(String t_txt,int t_x,int t_y){
	String t_prevChar=String();
	f_xOffset=0;
	for(int t_i=0;t_i<t_txt.Length();t_i=t_i+1){
		int t_asc=(int)t_txt[t_i];
		bb_char_Char* t_ac=f_chars[t_asc];
		String t_thisChar=String((Char)(t_asc),1);
		if(t_ac!=0){
			if(f_useKerning){
				String t_key=t_prevChar+String(L"_")+t_thisChar;
				if(f_kernPairs->m_Contains(t_key)){
					f_xOffset+=f_kernPairs->m_Get(t_key)->f_amount;
				}
			}
			t_ac->m_Draw(f_image,t_x+f_xOffset,t_y);
			f_xOffset+=t_ac->f_xAdvance;
			t_prevChar=t_thisChar;
		}
	}
}
void bb_angelfont_AngelFont::m_DrawText2(String t_txt,int t_x,int t_y,int t_align){
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
void bb_angelfont_AngelFont::mark(){
	Object::mark();
	gc_mark_q(f_chars);
	gc_mark_q(f_kernPairs);
	gc_mark_q(f_image);
}
bb_map_Map5::bb_map_Map5(){
	f_root=0;
}
bb_map_Map5* bb_map_Map5::g_new(){
	return this;
}
bb_map_Node5* bb_map_Map5::m_FindNode(String t_key){
	bb_map_Node5* t_node=f_root;
	while((t_node)!=0){
		int t_cmp=m_Compare(t_key,t_node->f_key);
		if(t_cmp>0){
			t_node=t_node->f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node->f_left;
			}else{
				return t_node;
			}
		}
	}
	return t_node;
}
bb_angelfont_AngelFont* bb_map_Map5::m_Get(String t_key){
	bb_map_Node5* t_node=m_FindNode(t_key);
	if((t_node)!=0){
		return t_node->f_value;
	}
	return 0;
}
bool bb_map_Map5::m_Contains(String t_key){
	return m_FindNode(t_key)!=0;
}
int bb_map_Map5::m_RotateLeft5(bb_map_Node5* t_node){
	bb_map_Node5* t_child=t_node->f_right;
	gc_assign(t_node->f_right,t_child->f_left);
	if((t_child->f_left)!=0){
		gc_assign(t_child->f_left->f_parent,t_node);
	}
	gc_assign(t_child->f_parent,t_node->f_parent);
	if((t_node->f_parent)!=0){
		if(t_node==t_node->f_parent->f_left){
			gc_assign(t_node->f_parent->f_left,t_child);
		}else{
			gc_assign(t_node->f_parent->f_right,t_child);
		}
	}else{
		gc_assign(f_root,t_child);
	}
	gc_assign(t_child->f_left,t_node);
	gc_assign(t_node->f_parent,t_child);
	return 0;
}
int bb_map_Map5::m_RotateRight5(bb_map_Node5* t_node){
	bb_map_Node5* t_child=t_node->f_left;
	gc_assign(t_node->f_left,t_child->f_right);
	if((t_child->f_right)!=0){
		gc_assign(t_child->f_right->f_parent,t_node);
	}
	gc_assign(t_child->f_parent,t_node->f_parent);
	if((t_node->f_parent)!=0){
		if(t_node==t_node->f_parent->f_right){
			gc_assign(t_node->f_parent->f_right,t_child);
		}else{
			gc_assign(t_node->f_parent->f_left,t_child);
		}
	}else{
		gc_assign(f_root,t_child);
	}
	gc_assign(t_child->f_right,t_node);
	gc_assign(t_node->f_parent,t_child);
	return 0;
}
int bb_map_Map5::m_InsertFixup5(bb_map_Node5* t_node){
	while(((t_node->f_parent)!=0) && t_node->f_parent->f_color==-1 && ((t_node->f_parent->f_parent)!=0)){
		if(t_node->f_parent==t_node->f_parent->f_parent->f_left){
			bb_map_Node5* t_uncle=t_node->f_parent->f_parent->f_right;
			if(((t_uncle)!=0) && t_uncle->f_color==-1){
				t_node->f_parent->f_color=1;
				t_uncle->f_color=1;
				t_uncle->f_parent->f_color=-1;
				t_node=t_uncle->f_parent;
			}else{
				if(t_node==t_node->f_parent->f_right){
					t_node=t_node->f_parent;
					m_RotateLeft5(t_node);
				}
				t_node->f_parent->f_color=1;
				t_node->f_parent->f_parent->f_color=-1;
				m_RotateRight5(t_node->f_parent->f_parent);
			}
		}else{
			bb_map_Node5* t_uncle2=t_node->f_parent->f_parent->f_left;
			if(((t_uncle2)!=0) && t_uncle2->f_color==-1){
				t_node->f_parent->f_color=1;
				t_uncle2->f_color=1;
				t_uncle2->f_parent->f_color=-1;
				t_node=t_uncle2->f_parent;
			}else{
				if(t_node==t_node->f_parent->f_left){
					t_node=t_node->f_parent;
					m_RotateRight5(t_node);
				}
				t_node->f_parent->f_color=1;
				t_node->f_parent->f_parent->f_color=-1;
				m_RotateLeft5(t_node->f_parent->f_parent);
			}
		}
	}
	f_root->f_color=1;
	return 0;
}
bool bb_map_Map5::m_Set6(String t_key,bb_angelfont_AngelFont* t_value){
	bb_map_Node5* t_node=f_root;
	bb_map_Node5* t_parent=0;
	int t_cmp=0;
	while((t_node)!=0){
		t_parent=t_node;
		t_cmp=m_Compare(t_key,t_node->f_key);
		if(t_cmp>0){
			t_node=t_node->f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node->f_left;
			}else{
				gc_assign(t_node->f_value,t_value);
				return false;
			}
		}
	}
	t_node=(new bb_map_Node5)->g_new(t_key,t_value,-1,t_parent);
	if((t_parent)!=0){
		if(t_cmp>0){
			gc_assign(t_parent->f_right,t_node);
		}else{
			gc_assign(t_parent->f_left,t_node);
		}
		m_InsertFixup5(t_node);
	}else{
		gc_assign(f_root,t_node);
	}
	return true;
}
bool bb_map_Map5::m_Insert3(String t_key,bb_angelfont_AngelFont* t_value){
	return m_Set6(t_key,t_value);
}
void bb_map_Map5::mark(){
	Object::mark();
	gc_mark_q(f_root);
}
bb_map_StringMap5::bb_map_StringMap5(){
}
bb_map_StringMap5* bb_map_StringMap5::g_new(){
	bb_map_Map5::g_new();
	return this;
}
int bb_map_StringMap5::m_Compare(String t_lhs,String t_rhs){
	return t_lhs.Compare(t_rhs);
}
void bb_map_StringMap5::mark(){
	bb_map_Map5::mark();
}
bb_map_Node5::bb_map_Node5(){
	f_key=String();
	f_right=0;
	f_left=0;
	f_value=0;
	f_color=0;
	f_parent=0;
}
bb_map_Node5* bb_map_Node5::g_new(String t_key,bb_angelfont_AngelFont* t_value,int t_color,bb_map_Node5* t_parent){
	this->f_key=t_key;
	gc_assign(this->f_value,t_value);
	this->f_color=t_color;
	gc_assign(this->f_parent,t_parent);
	return this;
}
bb_map_Node5* bb_map_Node5::g_new2(){
	return this;
}
void bb_map_Node5::mark(){
	Object::mark();
	gc_mark_q(f_right);
	gc_mark_q(f_left);
	gc_mark_q(f_value);
	gc_mark_q(f_parent);
}
bb_animation_Animation::bb_animation_Animation(){
	f_startValue=FLOAT(.0);
	f_endValue=FLOAT(.0);
	f_duration=FLOAT(.0);
	f_effect=0;
	f_transition=((new bb_transition_TransitionLinear)->g_new());
	f_finished=false;
	f_animationTime=FLOAT(.0);
	f__value=FLOAT(.0);
}
bb_animation_Animation* bb_animation_Animation::g_new(Float t_startValue,Float t_endValue,Float t_duration){
	bb_fanout_FanOut::g_new();
	this->f_startValue=t_startValue;
	this->f_endValue=t_endValue;
	this->f_duration=t_duration;
	return this;
}
bb_animation_Animation* bb_animation_Animation::g_new2(){
	bb_fanout_FanOut::g_new();
	return this;
}
void bb_animation_Animation::m_Pause(){
	f_finished=true;
}
void bb_animation_Animation::m_OnUpdate(Float t_delta,Float t_frameTime){
	bb_fanout_FanOut::m_OnUpdate(t_delta,t_frameTime);
	if(f_finished){
		return;
	}
	f_animationTime+=t_frameTime;
	Float t_progress=bb_math_Min2(FLOAT(1.0),f_animationTime/f_duration);
	Float t_t=f_transition->m_Calculate(t_progress);
	f__value=f_startValue*(FLOAT(1.0)-t_t)+f_endValue*t_t;
	if(f_animationTime>=f_duration){
		f_animationTime=f_duration;
		f_finished=true;
	}
}
void bb_animation_Animation::m_OnRender(){
	if(!((f_effect)!=0)){
		bb_fanout_FanOut::m_OnRender();
		return;
	}
	if(m_Count()==0){
		return;
	}
	f_effect->m_PreRender(f__value);
	bb_list_Enumerator* t_=this->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		bb_directorevents_DirectorEvents* t_obj=t_->m_NextObject();
		f_effect->m_PreNode(f__value,t_obj);
		t_obj->m_OnRender();
		f_effect->m_PostNode(f__value,t_obj);
	}
	f_effect->m_PostRender(f__value);
}
void bb_animation_Animation::m_Play(){
	f_finished=false;
}
void bb_animation_Animation::m_Restart(){
	f_animationTime=FLOAT(0.0);
	m_Play();
}
bool bb_animation_Animation::m_IsPlaying(){
	return !f_finished;
}
void bb_animation_Animation::mark(){
	bb_fanout_FanOut::mark();
	gc_mark_q(f_effect);
	gc_mark_q(f_transition);
}
bb_fader_FaderScale::bb_fader_FaderScale(){
	f_sizeNode=0;
	f_offsetX=FLOAT(.0);
	f_offsetY=FLOAT(.0);
	f_posNode=0;
}
bb_fader_FaderScale* bb_fader_FaderScale::g_new(){
	return this;
}
void bb_fader_FaderScale::m_PreRender(Float t_value){
}
void bb_fader_FaderScale::m_PostRender(Float t_value){
}
void bb_fader_FaderScale::m_PreNode(Float t_value,bb_directorevents_DirectorEvents* t_node){
	if(t_value==FLOAT(1.0)){
		return;
	}
	bb_graphics_PushMatrix();
	gc_assign(f_sizeNode,dynamic_cast<bb_sizeable_Sizeable*>(t_node));
	if((f_sizeNode)!=0){
		f_offsetX=f_sizeNode->m_center()->f_x*(t_value-FLOAT(1.0));
		f_offsetY=f_sizeNode->m_center()->f_y*(t_value-FLOAT(1.0));
		bb_graphics_Translate(-f_offsetX,-f_offsetY);
	}
	gc_assign(f_posNode,dynamic_cast<bb_positionable_Positionable*>(t_node));
	if((f_posNode)!=0){
		f_offsetX=f_posNode->m_pos()->f_x*(t_value-FLOAT(1.0));
		f_offsetY=f_posNode->m_pos()->f_y*(t_value-FLOAT(1.0));
		bb_graphics_Translate(-f_offsetX,-f_offsetY);
	}
	bb_graphics_Scale(t_value,t_value);
}
void bb_fader_FaderScale::m_PostNode(Float t_value,bb_directorevents_DirectorEvents* t_node){
	if(t_value==FLOAT(1.0)){
		return;
	}
	bb_graphics_PopMatrix();
}
void bb_fader_FaderScale::mark(){
	Object::mark();
	gc_mark_q(f_sizeNode);
	gc_mark_q(f_posNode);
}
bb_transition_TransitionInCubic::bb_transition_TransitionInCubic(){
}
bb_transition_TransitionInCubic* bb_transition_TransitionInCubic::g_new(){
	return this;
}
Float bb_transition_TransitionInCubic::m_Calculate(Float t_progress){
	return (Float)pow(t_progress,FLOAT(3.0));
}
void bb_transition_TransitionInCubic::mark(){
	Object::mark();
}
bb_transition_TransitionLinear::bb_transition_TransitionLinear(){
}
bb_transition_TransitionLinear* bb_transition_TransitionLinear::g_new(){
	return this;
}
Float bb_transition_TransitionLinear::m_Calculate(Float t_progress){
	return t_progress;
}
void bb_transition_TransitionLinear::mark(){
	Object::mark();
}
int bb_app_Millisecs(){
	return bb_app_device->MilliSecs();
}
bb_stack_Stack::bb_stack_Stack(){
	f_data=Array<int >();
	f_length=0;
}
bb_stack_Stack* bb_stack_Stack::g_new(){
	return this;
}
bb_stack_Stack* bb_stack_Stack::g_new2(Array<int > t_data){
	gc_assign(this->f_data,t_data.Slice(0));
	this->f_length=t_data.Length();
	return this;
}
int bb_stack_Stack::m_Clear(){
	f_length=0;
	return 0;
}
int bb_stack_Stack::m_Length(){
	return f_length;
}
int bb_stack_Stack::m_Get2(int t_index){
	return f_data[t_index];
}
int bb_stack_Stack::m_Remove4(int t_index){
	for(int t_i=t_index;t_i<f_length-1;t_i=t_i+1){
		f_data[t_i]=f_data[t_i+1];
	}
	f_length-=1;
	return 0;
}
int bb_stack_Stack::m_Push(int t_value){
	if(f_length==f_data.Length()){
		gc_assign(f_data,f_data.Resize(f_length*2+10));
	}
	f_data[f_length]=t_value;
	f_length+=1;
	return 0;
}
void bb_stack_Stack::mark(){
	Object::mark();
	gc_mark_q(f_data);
}
bb_stack_IntStack::bb_stack_IntStack(){
}
bb_stack_IntStack* bb_stack_IntStack::g_new(){
	bb_stack_Stack::g_new();
	return this;
}
void bb_stack_IntStack::mark(){
	bb_stack_Stack::mark();
}
int bb_random_Seed;
Float bb_random_Rnd(){
	bb_random_Seed=bb_random_Seed*1664525+1013904223|0;
	return Float(bb_random_Seed>>8&16777215)/FLOAT(16777216.0);
}
Float bb_random_Rnd2(Float t_low,Float t_high){
	return bb_random_Rnd3(t_high-t_low)+t_low;
}
Float bb_random_Rnd3(Float t_range){
	return bb_random_Rnd()*t_range;
}
bb_list_List4::bb_list_List4(){
	f__head=((new bb_list_HeadNode4)->g_new());
}
bb_list_List4* bb_list_List4::g_new(){
	return this;
}
bb_list_Node4* bb_list_List4::m_AddLast4(int t_data){
	return (new bb_list_Node4)->g_new(f__head,f__head->f__pred,t_data);
}
bb_list_List4* bb_list_List4::g_new2(Array<int > t_data){
	Array<int > t_=t_data;
	int t_2=0;
	while(t_2<t_.Length()){
		int t_t=t_[t_2];
		t_2=t_2+1;
		m_AddLast4(t_t);
	}
	return this;
}
int bb_list_List4::m_Clear(){
	gc_assign(f__head->f__succ,f__head);
	gc_assign(f__head->f__pred,f__head);
	return 0;
}
int bb_list_List4::m_Count(){
	int t_n=0;
	bb_list_Node4* t_node=f__head->f__succ;
	while(t_node!=f__head){
		t_node=t_node->f__succ;
		t_n+=1;
	}
	return t_n;
}
bb_list_Enumerator3* bb_list_List4::m_ObjectEnumerator(){
	return (new bb_list_Enumerator3)->g_new(this);
}
Array<int > bb_list_List4::m_ToArray(){
	Array<int > t_arr=Array<int >(m_Count());
	int t_i=0;
	bb_list_Enumerator3* t_=this->m_ObjectEnumerator();
	while(t_->m_HasNext()){
		int t_t=t_->m_NextObject();
		t_arr[t_i]=t_t;
		t_i+=1;
	}
	return t_arr;
}
int bb_list_List4::m_First(){
	return f__head->m_NextNode()->f__data;
}
int bb_list_List4::m_RemoveFirst(){
	int t_data=f__head->m_NextNode()->f__data;
	f__head->f__succ->m_Remove2();
	return t_data;
}
int bb_list_List4::m_Last(){
	return f__head->m_PrevNode()->f__data;
}
int bb_list_List4::m_RemoveLast(){
	int t_data=f__head->m_PrevNode()->f__data;
	f__head->f__pred->m_Remove2();
	return t_data;
}
bb_list_Node4* bb_list_List4::m_AddFirst2(int t_data){
	return (new bb_list_Node4)->g_new(f__head->f__succ,f__head,t_data);
}
void bb_list_List4::mark(){
	Object::mark();
	gc_mark_q(f__head);
}
bb_list_IntList::bb_list_IntList(){
}
bb_list_IntList* bb_list_IntList::g_new(){
	bb_list_List4::g_new();
	return this;
}
void bb_list_IntList::mark(){
	bb_list_List4::mark();
}
bb_list_Node4::bb_list_Node4(){
	f__succ=0;
	f__pred=0;
	f__data=0;
}
bb_list_Node4* bb_list_Node4::g_new(bb_list_Node4* t_succ,bb_list_Node4* t_pred,int t_data){
	gc_assign(f__succ,t_succ);
	gc_assign(f__pred,t_pred);
	gc_assign(f__succ->f__pred,this);
	gc_assign(f__pred->f__succ,this);
	f__data=t_data;
	return this;
}
bb_list_Node4* bb_list_Node4::g_new2(){
	return this;
}
bb_list_Node4* bb_list_Node4::m_GetNode(){
	return this;
}
bb_list_Node4* bb_list_Node4::m_NextNode(){
	return f__succ->m_GetNode();
}
int bb_list_Node4::m_Remove2(){
	gc_assign(f__succ->f__pred,f__pred);
	gc_assign(f__pred->f__succ,f__succ);
	return 0;
}
bb_list_Node4* bb_list_Node4::m_PrevNode(){
	return f__pred->m_GetNode();
}
void bb_list_Node4::mark(){
	Object::mark();
	gc_mark_q(f__succ);
	gc_mark_q(f__pred);
}
bb_list_HeadNode4::bb_list_HeadNode4(){
}
bb_list_HeadNode4* bb_list_HeadNode4::g_new(){
	bb_list_Node4::g_new2();
	gc_assign(f__succ,(this));
	gc_assign(f__pred,(this));
	return this;
}
bb_list_Node4* bb_list_HeadNode4::m_GetNode(){
	return 0;
}
void bb_list_HeadNode4::mark(){
	bb_list_Node4::mark();
}
bb_set_Set::bb_set_Set(){
	f_map=0;
}
bb_set_Set* bb_set_Set::g_new(bb_map_Map6* t_map){
	gc_assign(this->f_map,t_map);
	return this;
}
bb_set_Set* bb_set_Set::g_new2(){
	return this;
}
int bb_set_Set::m_Insert4(int t_value){
	f_map->m_Insert5(t_value,0);
	return 0;
}
int bb_set_Set::m_Count(){
	return f_map->m_Count();
}
int bb_set_Set::m_Clear(){
	f_map->m_Clear();
	return 0;
}
int bb_set_Set::m_Remove4(int t_value){
	f_map->m_Remove4(t_value);
	return 0;
}
bool bb_set_Set::m_Contains2(int t_value){
	return f_map->m_Contains2(t_value);
}
void bb_set_Set::mark(){
	Object::mark();
	gc_mark_q(f_map);
}
bb_set_IntSet::bb_set_IntSet(){
}
bb_set_IntSet* bb_set_IntSet::g_new(){
	bb_set_Set::g_new((new bb_map_IntMap)->g_new());
	return this;
}
void bb_set_IntSet::mark(){
	bb_set_Set::mark();
}
bb_map_Map6::bb_map_Map6(){
	f_root=0;
}
bb_map_Map6* bb_map_Map6::g_new(){
	return this;
}
int bb_map_Map6::m_RotateLeft6(bb_map_Node6* t_node){
	bb_map_Node6* t_child=t_node->f_right;
	gc_assign(t_node->f_right,t_child->f_left);
	if((t_child->f_left)!=0){
		gc_assign(t_child->f_left->f_parent,t_node);
	}
	gc_assign(t_child->f_parent,t_node->f_parent);
	if((t_node->f_parent)!=0){
		if(t_node==t_node->f_parent->f_left){
			gc_assign(t_node->f_parent->f_left,t_child);
		}else{
			gc_assign(t_node->f_parent->f_right,t_child);
		}
	}else{
		gc_assign(f_root,t_child);
	}
	gc_assign(t_child->f_left,t_node);
	gc_assign(t_node->f_parent,t_child);
	return 0;
}
int bb_map_Map6::m_RotateRight6(bb_map_Node6* t_node){
	bb_map_Node6* t_child=t_node->f_left;
	gc_assign(t_node->f_left,t_child->f_right);
	if((t_child->f_right)!=0){
		gc_assign(t_child->f_right->f_parent,t_node);
	}
	gc_assign(t_child->f_parent,t_node->f_parent);
	if((t_node->f_parent)!=0){
		if(t_node==t_node->f_parent->f_right){
			gc_assign(t_node->f_parent->f_right,t_child);
		}else{
			gc_assign(t_node->f_parent->f_left,t_child);
		}
	}else{
		gc_assign(f_root,t_child);
	}
	gc_assign(t_child->f_right,t_node);
	gc_assign(t_node->f_parent,t_child);
	return 0;
}
int bb_map_Map6::m_InsertFixup6(bb_map_Node6* t_node){
	while(((t_node->f_parent)!=0) && t_node->f_parent->f_color==-1 && ((t_node->f_parent->f_parent)!=0)){
		if(t_node->f_parent==t_node->f_parent->f_parent->f_left){
			bb_map_Node6* t_uncle=t_node->f_parent->f_parent->f_right;
			if(((t_uncle)!=0) && t_uncle->f_color==-1){
				t_node->f_parent->f_color=1;
				t_uncle->f_color=1;
				t_uncle->f_parent->f_color=-1;
				t_node=t_uncle->f_parent;
			}else{
				if(t_node==t_node->f_parent->f_right){
					t_node=t_node->f_parent;
					m_RotateLeft6(t_node);
				}
				t_node->f_parent->f_color=1;
				t_node->f_parent->f_parent->f_color=-1;
				m_RotateRight6(t_node->f_parent->f_parent);
			}
		}else{
			bb_map_Node6* t_uncle2=t_node->f_parent->f_parent->f_left;
			if(((t_uncle2)!=0) && t_uncle2->f_color==-1){
				t_node->f_parent->f_color=1;
				t_uncle2->f_color=1;
				t_uncle2->f_parent->f_color=-1;
				t_node=t_uncle2->f_parent;
			}else{
				if(t_node==t_node->f_parent->f_left){
					t_node=t_node->f_parent;
					m_RotateRight6(t_node);
				}
				t_node->f_parent->f_color=1;
				t_node->f_parent->f_parent->f_color=-1;
				m_RotateLeft6(t_node->f_parent->f_parent);
			}
		}
	}
	f_root->f_color=1;
	return 0;
}
bool bb_map_Map6::m_Set7(int t_key,Object* t_value){
	bb_map_Node6* t_node=f_root;
	bb_map_Node6* t_parent=0;
	int t_cmp=0;
	while((t_node)!=0){
		t_parent=t_node;
		t_cmp=m_Compare2(t_key,t_node->f_key);
		if(t_cmp>0){
			t_node=t_node->f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node->f_left;
			}else{
				gc_assign(t_node->f_value,t_value);
				return false;
			}
		}
	}
	t_node=(new bb_map_Node6)->g_new(t_key,t_value,-1,t_parent);
	if((t_parent)!=0){
		if(t_cmp>0){
			gc_assign(t_parent->f_right,t_node);
		}else{
			gc_assign(t_parent->f_left,t_node);
		}
		m_InsertFixup6(t_node);
	}else{
		gc_assign(f_root,t_node);
	}
	return true;
}
bool bb_map_Map6::m_Insert5(int t_key,Object* t_value){
	return m_Set7(t_key,t_value);
}
int bb_map_Map6::m_Count(){
	if((f_root)!=0){
		return f_root->m_Count2(0);
	}
	return 0;
}
int bb_map_Map6::m_Clear(){
	f_root=0;
	return 0;
}
bb_map_Node6* bb_map_Map6::m_FindNode2(int t_key){
	bb_map_Node6* t_node=f_root;
	while((t_node)!=0){
		int t_cmp=m_Compare2(t_key,t_node->f_key);
		if(t_cmp>0){
			t_node=t_node->f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node->f_left;
			}else{
				return t_node;
			}
		}
	}
	return t_node;
}
int bb_map_Map6::m_DeleteFixup(bb_map_Node6* t_node,bb_map_Node6* t_parent){
	while(t_node!=f_root && (!((t_node)!=0) || t_node->f_color==1)){
		if(t_node==t_parent->f_left){
			bb_map_Node6* t_sib=t_parent->f_right;
			if(t_sib->f_color==-1){
				t_sib->f_color=1;
				t_parent->f_color=-1;
				m_RotateLeft6(t_parent);
				t_sib=t_parent->f_right;
			}
			if((!((t_sib->f_left)!=0) || t_sib->f_left->f_color==1) && (!((t_sib->f_right)!=0) || t_sib->f_right->f_color==1)){
				t_sib->f_color=-1;
				t_node=t_parent;
				t_parent=t_parent->f_parent;
			}else{
				if(!((t_sib->f_right)!=0) || t_sib->f_right->f_color==1){
					t_sib->f_left->f_color=1;
					t_sib->f_color=-1;
					m_RotateRight6(t_sib);
					t_sib=t_parent->f_right;
				}
				t_sib->f_color=t_parent->f_color;
				t_parent->f_color=1;
				t_sib->f_right->f_color=1;
				m_RotateLeft6(t_parent);
				t_node=f_root;
			}
		}else{
			bb_map_Node6* t_sib2=t_parent->f_left;
			if(t_sib2->f_color==-1){
				t_sib2->f_color=1;
				t_parent->f_color=-1;
				m_RotateRight6(t_parent);
				t_sib2=t_parent->f_left;
			}
			if((!((t_sib2->f_right)!=0) || t_sib2->f_right->f_color==1) && (!((t_sib2->f_left)!=0) || t_sib2->f_left->f_color==1)){
				t_sib2->f_color=-1;
				t_node=t_parent;
				t_parent=t_parent->f_parent;
			}else{
				if(!((t_sib2->f_left)!=0) || t_sib2->f_left->f_color==1){
					t_sib2->f_right->f_color=1;
					t_sib2->f_color=-1;
					m_RotateLeft6(t_sib2);
					t_sib2=t_parent->f_left;
				}
				t_sib2->f_color=t_parent->f_color;
				t_parent->f_color=1;
				t_sib2->f_left->f_color=1;
				m_RotateRight6(t_parent);
				t_node=f_root;
			}
		}
	}
	if((t_node)!=0){
		t_node->f_color=1;
	}
	return 0;
}
int bb_map_Map6::m_RemoveNode(bb_map_Node6* t_node){
	bb_map_Node6* t_splice=0;
	bb_map_Node6* t_child=0;
	if(!((t_node->f_left)!=0)){
		t_splice=t_node;
		t_child=t_node->f_right;
	}else{
		if(!((t_node->f_right)!=0)){
			t_splice=t_node;
			t_child=t_node->f_left;
		}else{
			t_splice=t_node->f_left;
			while((t_splice->f_right)!=0){
				t_splice=t_splice->f_right;
			}
			t_child=t_splice->f_left;
			t_node->f_key=t_splice->f_key;
			gc_assign(t_node->f_value,t_splice->f_value);
		}
	}
	bb_map_Node6* t_parent=t_splice->f_parent;
	if((t_child)!=0){
		gc_assign(t_child->f_parent,t_parent);
	}
	if(!((t_parent)!=0)){
		gc_assign(f_root,t_child);
		return 0;
	}
	if(t_splice==t_parent->f_left){
		gc_assign(t_parent->f_left,t_child);
	}else{
		gc_assign(t_parent->f_right,t_child);
	}
	if(t_splice->f_color==1){
		m_DeleteFixup(t_child,t_parent);
	}
	return 0;
}
int bb_map_Map6::m_Remove4(int t_key){
	bb_map_Node6* t_node=m_FindNode2(t_key);
	if(!((t_node)!=0)){
		return 0;
	}
	m_RemoveNode(t_node);
	return 1;
}
bool bb_map_Map6::m_Contains2(int t_key){
	return m_FindNode2(t_key)!=0;
}
void bb_map_Map6::mark(){
	Object::mark();
	gc_mark_q(f_root);
}
bb_map_IntMap::bb_map_IntMap(){
}
bb_map_IntMap* bb_map_IntMap::g_new(){
	bb_map_Map6::g_new();
	return this;
}
int bb_map_IntMap::m_Compare2(int t_lhs,int t_rhs){
	return t_lhs-t_rhs;
}
void bb_map_IntMap::mark(){
	bb_map_Map6::mark();
}
bb_map_Node6::bb_map_Node6(){
	f_key=0;
	f_right=0;
	f_left=0;
	f_value=0;
	f_color=0;
	f_parent=0;
}
bb_map_Node6* bb_map_Node6::g_new(int t_key,Object* t_value,int t_color,bb_map_Node6* t_parent){
	this->f_key=t_key;
	gc_assign(this->f_value,t_value);
	this->f_color=t_color;
	gc_assign(this->f_parent,t_parent);
	return this;
}
bb_map_Node6* bb_map_Node6::g_new2(){
	return this;
}
int bb_map_Node6::m_Count2(int t_n){
	if((f_left)!=0){
		t_n=f_left->m_Count2(t_n);
	}
	if((f_right)!=0){
		t_n=f_right->m_Count2(t_n);
	}
	return t_n+1;
}
void bb_map_Node6::mark(){
	Object::mark();
	gc_mark_q(f_right);
	gc_mark_q(f_left);
	gc_mark_q(f_value);
	gc_mark_q(f_parent);
}
bb_list_Enumerator3::bb_list_Enumerator3(){
	f__list=0;
	f__curr=0;
}
bb_list_Enumerator3* bb_list_Enumerator3::g_new(bb_list_List4* t_list){
	gc_assign(f__list,t_list);
	gc_assign(f__curr,t_list->f__head->f__succ);
	return this;
}
bb_list_Enumerator3* bb_list_Enumerator3::g_new2(){
	return this;
}
bool bb_list_Enumerator3::m_HasNext(){
	while(f__curr->f__succ->f__pred!=f__curr){
		gc_assign(f__curr,f__curr->f__succ);
	}
	return f__curr!=f__list->f__head;
}
int bb_list_Enumerator3::m_NextObject(){
	int t_data=f__curr->f__data;
	gc_assign(f__curr,f__curr->f__succ);
	return t_data;
}
void bb_list_Enumerator3::mark(){
	Object::mark();
	gc_mark_q(f__list);
	gc_mark_q(f__curr);
}
bb_textinput_TextInput::bb_textinput_TextInput(){
	f_cursorPos=0;
}
bb_textinput_TextInput* bb_textinput_TextInput::g_new(String t_fontName,bb_vector2d_Vector2D* t_pos){
	bb_font_Font::g_new(t_fontName,t_pos);
	return this;
}
bb_textinput_TextInput* bb_textinput_TextInput::g_new2(){
	bb_font_Font::g_new2();
	return this;
}
void bb_textinput_TextInput::m_MoveCursorRight(){
	if(f_cursorPos>=m_text2().Length()){
		return;
	}
	f_cursorPos+=1;
}
void bb_textinput_TextInput::m_InsertChar(String t_char){
	m_text(m_text2().Slice(0,f_cursorPos)+t_char+m_text2().Slice(f_cursorPos,m_text2().Length()));
	m_MoveCursorRight();
}
void bb_textinput_TextInput::m_MoveCursorLeft(){
	if(f_cursorPos<=0){
		return;
	}
	f_cursorPos-=1;
}
void bb_textinput_TextInput::m_RemoveChar(){
	if(m_text2().Length()==0 || f_cursorPos==0){
		return;
	}
	m_text(m_text2().Slice(0,f_cursorPos-1)+m_text2().Slice(f_cursorPos,m_text2().Length()));
	m_MoveCursorLeft();
}
void bb_textinput_TextInput::m_OnKeyUp(bb_keyevent_KeyEvent* t_event){
	if(t_event->m_code()>31 && t_event->m_code()<127){
		m_InsertChar(t_event->m_char());
	}else{
		int t_1=t_event->m_code();
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
void bb_textinput_TextInput::mark(){
	bb_font_Font::mark();
}
int bb_graphics_SetFont(bb_graphics_Image* t_font,int t_firstChar){
	if(!((t_font)!=0)){
		if(!((bb_graphics_context->f_defaultFont)!=0)){
			gc_assign(bb_graphics_context->f_defaultFont,bb_graphics_LoadImage(String(L"mojo_font.png"),96,2));
		}
		t_font=bb_graphics_context->f_defaultFont;
		t_firstChar=32;
	}
	gc_assign(bb_graphics_context->f_font,t_font);
	bb_graphics_context->f_firstChar=t_firstChar;
	return 0;
}
gxtkGraphics* bb_graphics_renderDevice;
int bb_graphics_SetMatrix(Float t_ix,Float t_iy,Float t_jx,Float t_jy,Float t_tx,Float t_ty){
	bb_graphics_context->f_ix=t_ix;
	bb_graphics_context->f_iy=t_iy;
	bb_graphics_context->f_jx=t_jx;
	bb_graphics_context->f_jy=t_jy;
	bb_graphics_context->f_tx=t_tx;
	bb_graphics_context->f_ty=t_ty;
	bb_graphics_context->f_tformed=((t_ix!=FLOAT(1.0) || t_iy!=FLOAT(0.0) || t_jx!=FLOAT(0.0) || t_jy!=FLOAT(1.0) || t_tx!=FLOAT(0.0) || t_ty!=FLOAT(0.0))?1:0);
	bb_graphics_context->f_matDirty=1;
	return 0;
}
int bb_graphics_SetMatrix2(Array<Float > t_m){
	bb_graphics_SetMatrix(t_m[0],t_m[1],t_m[2],t_m[3],t_m[4],t_m[5]);
	return 0;
}
int bb_graphics_SetColor(Float t_r,Float t_g,Float t_b){
	bb_graphics_context->f_color_r=t_r;
	bb_graphics_context->f_color_g=t_g;
	bb_graphics_context->f_color_b=t_b;
	bb_graphics_context->f_device->SetColor(t_r,t_g,t_b);
	return 0;
}
int bb_graphics_SetAlpha(Float t_alpha){
	bb_graphics_context->f_alpha=t_alpha;
	bb_graphics_context->f_device->SetAlpha(t_alpha);
	return 0;
}
int bb_graphics_SetBlend(int t_blend){
	bb_graphics_context->f_blend=t_blend;
	bb_graphics_context->f_device->SetBlend(t_blend);
	return 0;
}
int bb_graphics_DeviceWidth(){
	return bb_graphics_context->f_device->Width();
}
int bb_graphics_DeviceHeight(){
	return bb_graphics_context->f_device->Height();
}
int bb_graphics_SetScissor(Float t_x,Float t_y,Float t_width,Float t_height){
	bb_graphics_context->f_scissor_x=t_x;
	bb_graphics_context->f_scissor_y=t_y;
	bb_graphics_context->f_scissor_width=t_width;
	bb_graphics_context->f_scissor_height=t_height;
	bb_graphics_context->f_device->SetScissor(int(t_x),int(t_y),int(t_width),int(t_height));
	return 0;
}
int bb_graphics_BeginRender(){
	if(!((bb_graphics_context->f_device->Mode())!=0)){
		return 0;
	}
	gc_assign(bb_graphics_renderDevice,bb_graphics_context->f_device);
	bb_graphics_context->f_matrixSp=0;
	bb_graphics_SetMatrix(FLOAT(1.0),FLOAT(0.0),FLOAT(0.0),FLOAT(1.0),FLOAT(0.0),FLOAT(0.0));
	bb_graphics_SetColor(FLOAT(255.0),FLOAT(255.0),FLOAT(255.0));
	bb_graphics_SetAlpha(FLOAT(1.0));
	bb_graphics_SetBlend(0);
	bb_graphics_SetScissor(FLOAT(0.0),FLOAT(0.0),Float(bb_graphics_DeviceWidth()),Float(bb_graphics_DeviceHeight()));
	return 0;
}
int bb_graphics_EndRender(){
	bb_graphics_renderDevice=0;
	return 0;
}
bb_deltatimer_DeltaTimer::bb_deltatimer_DeltaTimer(){
	f_targetFps=FLOAT(.0);
	f_lastTicks=FLOAT(.0);
	f_currentTicks=FLOAT(.0);
	f__frameTime=FLOAT(.0);
	f__delta=FLOAT(.0);
}
bb_deltatimer_DeltaTimer* bb_deltatimer_DeltaTimer::g_new(Float t_fps){
	f_targetFps=t_fps;
	f_lastTicks=Float(bb_app_Millisecs());
	return this;
}
bb_deltatimer_DeltaTimer* bb_deltatimer_DeltaTimer::g_new2(){
	return this;
}
Float bb_deltatimer_DeltaTimer::m_frameTime(){
	return f__frameTime;
}
void bb_deltatimer_DeltaTimer::m_OnUpdate2(){
	f_currentTicks=Float(bb_app_Millisecs());
	f__frameTime=f_currentTicks-f_lastTicks;
	f__delta=m_frameTime()/(FLOAT(1000.0)/f_targetFps);
	f_lastTicks=f_currentTicks;
}
Float bb_deltatimer_DeltaTimer::m_delta(){
	return f__delta;
}
void bb_deltatimer_DeltaTimer::mark(){
	Object::mark();
}
int bb_app_SetUpdateRate(int t_hertz){
	return bb_app_device->SetUpdateRate(t_hertz);
}
int bb_input_TouchDown(int t_index){
	return bb_input_device->KeyDown(384+t_index);
}
bb_touchevent_TouchEvent::bb_touchevent_TouchEvent(){
	f__finger=0;
	f__startTime=0;
	f_positions=(new bb_list_List5)->g_new();
	f__endTime=0;
}
bb_touchevent_TouchEvent* bb_touchevent_TouchEvent::g_new(int t_finger){
	f__finger=t_finger;
	f__startTime=bb_app_Millisecs();
	return this;
}
bb_touchevent_TouchEvent* bb_touchevent_TouchEvent::g_new2(){
	return this;
}
bb_vector2d_Vector2D* bb_touchevent_TouchEvent::m_startPos(){
	if(f_positions->m_Count()==0){
		return (new bb_vector2d_Vector2D)->g_new(FLOAT(0.0),FLOAT(0.0));
	}
	return f_positions->m_First();
}
bb_vector2d_Vector2D* bb_touchevent_TouchEvent::m_prevPos(){
	if(f_positions->m_Count()==0){
		return (new bb_vector2d_Vector2D)->g_new(FLOAT(0.0),FLOAT(0.0));
	}
	if(f_positions->m_Count()==1){
		return m_startPos();
	}
	return f_positions->m_LastNode()->m_PrevNode()->m_Value();
}
void bb_touchevent_TouchEvent::m_Add2(bb_vector2d_Vector2D* t_pos){
	f__endTime=bb_app_Millisecs();
	if(m_prevPos()->f_x==t_pos->f_x && m_prevPos()->f_y==t_pos->f_y){
		return;
	}
	f_positions->m_AddLast5(t_pos);
}
void bb_touchevent_TouchEvent::m_Trim(int t_size){
	if(t_size==0){
		f_positions->m_Clear();
		return;
	}
	while(f_positions->m_Count()>t_size){
		f_positions->m_RemoveFirst();
	}
}
bb_vector2d_Vector2D* bb_touchevent_TouchEvent::m_pos(){
	if(f_positions->m_Count()==0){
		return (new bb_vector2d_Vector2D)->g_new(FLOAT(0.0),FLOAT(0.0));
	}
	return f_positions->m_Last();
}
bb_touchevent_TouchEvent* bb_touchevent_TouchEvent::m_Copy(){
	bb_touchevent_TouchEvent* t_obj=(new bb_touchevent_TouchEvent)->g_new(f__finger);
	t_obj->m_Add2(m_pos());
	return t_obj;
}
bb_vector2d_Vector2D* bb_touchevent_TouchEvent::m_startDelta(){
	return m_pos()->m_Copy()->m_Sub(m_startPos());
}
void bb_touchevent_TouchEvent::mark(){
	Object::mark();
	gc_mark_q(f_positions);
}
Float bb_input_TouchX(int t_index){
	return bb_input_device->TouchX(t_index);
}
Float bb_input_TouchY(int t_index){
	return bb_input_device->TouchY(t_index);
}
bb_list_List5::bb_list_List5(){
	f__head=((new bb_list_HeadNode5)->g_new());
}
bb_list_List5* bb_list_List5::g_new(){
	return this;
}
bb_list_Node5* bb_list_List5::m_AddLast5(bb_vector2d_Vector2D* t_data){
	return (new bb_list_Node5)->g_new(f__head,f__head->f__pred,t_data);
}
bb_list_List5* bb_list_List5::g_new2(Array<bb_vector2d_Vector2D* > t_data){
	Array<bb_vector2d_Vector2D* > t_=t_data;
	int t_2=0;
	while(t_2<t_.Length()){
		bb_vector2d_Vector2D* t_t=t_[t_2];
		t_2=t_2+1;
		m_AddLast5(t_t);
	}
	return this;
}
int bb_list_List5::m_Count(){
	int t_n=0;
	bb_list_Node5* t_node=f__head->f__succ;
	while(t_node!=f__head){
		t_node=t_node->f__succ;
		t_n+=1;
	}
	return t_n;
}
bb_vector2d_Vector2D* bb_list_List5::m_First(){
	return f__head->m_NextNode()->f__data;
}
bb_list_Node5* bb_list_List5::m_LastNode(){
	return f__head->m_PrevNode();
}
int bb_list_List5::m_Clear(){
	gc_assign(f__head->f__succ,f__head);
	gc_assign(f__head->f__pred,f__head);
	return 0;
}
bb_vector2d_Vector2D* bb_list_List5::m_RemoveFirst(){
	bb_vector2d_Vector2D* t_data=f__head->m_NextNode()->f__data;
	f__head->f__succ->m_Remove2();
	return t_data;
}
bb_vector2d_Vector2D* bb_list_List5::m_Last(){
	return f__head->m_PrevNode()->f__data;
}
void bb_list_List5::mark(){
	Object::mark();
	gc_mark_q(f__head);
}
bb_list_Node5::bb_list_Node5(){
	f__succ=0;
	f__pred=0;
	f__data=0;
}
bb_list_Node5* bb_list_Node5::g_new(bb_list_Node5* t_succ,bb_list_Node5* t_pred,bb_vector2d_Vector2D* t_data){
	gc_assign(f__succ,t_succ);
	gc_assign(f__pred,t_pred);
	gc_assign(f__succ->f__pred,this);
	gc_assign(f__pred->f__succ,this);
	gc_assign(f__data,t_data);
	return this;
}
bb_list_Node5* bb_list_Node5::g_new2(){
	return this;
}
bb_list_Node5* bb_list_Node5::m_GetNode(){
	return this;
}
bb_list_Node5* bb_list_Node5::m_NextNode(){
	return f__succ->m_GetNode();
}
bb_list_Node5* bb_list_Node5::m_PrevNode(){
	return f__pred->m_GetNode();
}
bb_vector2d_Vector2D* bb_list_Node5::m_Value(){
	return f__data;
}
int bb_list_Node5::m_Remove2(){
	gc_assign(f__succ->f__pred,f__pred);
	gc_assign(f__pred->f__succ,f__succ);
	return 0;
}
void bb_list_Node5::mark(){
	Object::mark();
	gc_mark_q(f__succ);
	gc_mark_q(f__pred);
	gc_mark_q(f__data);
}
bb_list_HeadNode5::bb_list_HeadNode5(){
}
bb_list_HeadNode5* bb_list_HeadNode5::g_new(){
	bb_list_Node5::g_new2();
	gc_assign(f__succ,(this));
	gc_assign(f__pred,(this));
	return this;
}
bb_list_Node5* bb_list_HeadNode5::m_GetNode(){
	return 0;
}
void bb_list_HeadNode5::mark(){
	bb_list_Node5::mark();
}
int bb_input_EnableKeyboard(){
	return bb_input_device->SetKeyboardEnabled(1);
}
int bb_input_GetChar(){
	return bb_input_device->GetChar();
}
bb_keyevent_KeyEvent::bb_keyevent_KeyEvent(){
	f__code=0;
	f__char=String();
}
bb_keyevent_KeyEvent* bb_keyevent_KeyEvent::g_new(int t_code){
	f__code=t_code;
	f__char=String((Char)(f__code),1);
	return this;
}
bb_keyevent_KeyEvent* bb_keyevent_KeyEvent::g_new2(){
	return this;
}
int bb_keyevent_KeyEvent::m_code(){
	return f__code;
}
String bb_keyevent_KeyEvent::m_char(){
	return f__char;
}
void bb_keyevent_KeyEvent::mark(){
	Object::mark();
}
bb_map_Map7::bb_map_Map7(){
	f_root=0;
}
bb_map_Map7* bb_map_Map7::g_new(){
	return this;
}
bb_map_Node7* bb_map_Map7::m_FindNode2(int t_key){
	bb_map_Node7* t_node=f_root;
	while((t_node)!=0){
		int t_cmp=m_Compare2(t_key,t_node->f_key);
		if(t_cmp>0){
			t_node=t_node->f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node->f_left;
			}else{
				return t_node;
			}
		}
	}
	return t_node;
}
bool bb_map_Map7::m_Contains2(int t_key){
	return m_FindNode2(t_key)!=0;
}
int bb_map_Map7::m_RotateLeft7(bb_map_Node7* t_node){
	bb_map_Node7* t_child=t_node->f_right;
	gc_assign(t_node->f_right,t_child->f_left);
	if((t_child->f_left)!=0){
		gc_assign(t_child->f_left->f_parent,t_node);
	}
	gc_assign(t_child->f_parent,t_node->f_parent);
	if((t_node->f_parent)!=0){
		if(t_node==t_node->f_parent->f_left){
			gc_assign(t_node->f_parent->f_left,t_child);
		}else{
			gc_assign(t_node->f_parent->f_right,t_child);
		}
	}else{
		gc_assign(f_root,t_child);
	}
	gc_assign(t_child->f_left,t_node);
	gc_assign(t_node->f_parent,t_child);
	return 0;
}
int bb_map_Map7::m_RotateRight7(bb_map_Node7* t_node){
	bb_map_Node7* t_child=t_node->f_left;
	gc_assign(t_node->f_left,t_child->f_right);
	if((t_child->f_right)!=0){
		gc_assign(t_child->f_right->f_parent,t_node);
	}
	gc_assign(t_child->f_parent,t_node->f_parent);
	if((t_node->f_parent)!=0){
		if(t_node==t_node->f_parent->f_right){
			gc_assign(t_node->f_parent->f_right,t_child);
		}else{
			gc_assign(t_node->f_parent->f_left,t_child);
		}
	}else{
		gc_assign(f_root,t_child);
	}
	gc_assign(t_child->f_right,t_node);
	gc_assign(t_node->f_parent,t_child);
	return 0;
}
int bb_map_Map7::m_InsertFixup7(bb_map_Node7* t_node){
	while(((t_node->f_parent)!=0) && t_node->f_parent->f_color==-1 && ((t_node->f_parent->f_parent)!=0)){
		if(t_node->f_parent==t_node->f_parent->f_parent->f_left){
			bb_map_Node7* t_uncle=t_node->f_parent->f_parent->f_right;
			if(((t_uncle)!=0) && t_uncle->f_color==-1){
				t_node->f_parent->f_color=1;
				t_uncle->f_color=1;
				t_uncle->f_parent->f_color=-1;
				t_node=t_uncle->f_parent;
			}else{
				if(t_node==t_node->f_parent->f_right){
					t_node=t_node->f_parent;
					m_RotateLeft7(t_node);
				}
				t_node->f_parent->f_color=1;
				t_node->f_parent->f_parent->f_color=-1;
				m_RotateRight7(t_node->f_parent->f_parent);
			}
		}else{
			bb_map_Node7* t_uncle2=t_node->f_parent->f_parent->f_left;
			if(((t_uncle2)!=0) && t_uncle2->f_color==-1){
				t_node->f_parent->f_color=1;
				t_uncle2->f_color=1;
				t_uncle2->f_parent->f_color=-1;
				t_node=t_uncle2->f_parent;
			}else{
				if(t_node==t_node->f_parent->f_left){
					t_node=t_node->f_parent;
					m_RotateRight7(t_node);
				}
				t_node->f_parent->f_color=1;
				t_node->f_parent->f_parent->f_color=-1;
				m_RotateLeft7(t_node->f_parent->f_parent);
			}
		}
	}
	f_root->f_color=1;
	return 0;
}
bool bb_map_Map7::m_Add6(int t_key,bb_keyevent_KeyEvent* t_value){
	bb_map_Node7* t_node=f_root;
	bb_map_Node7* t_parent=0;
	int t_cmp=0;
	while((t_node)!=0){
		t_parent=t_node;
		t_cmp=m_Compare2(t_key,t_node->f_key);
		if(t_cmp>0){
			t_node=t_node->f_right;
		}else{
			if(t_cmp<0){
				t_node=t_node->f_left;
			}else{
				return false;
			}
		}
	}
	t_node=(new bb_map_Node7)->g_new(t_key,t_value,-1,t_parent);
	if((t_parent)!=0){
		if(t_cmp>0){
			gc_assign(t_parent->f_right,t_node);
		}else{
			gc_assign(t_parent->f_left,t_node);
		}
		m_InsertFixup7(t_node);
	}else{
		gc_assign(f_root,t_node);
	}
	return true;
}
bb_map_MapValues* bb_map_Map7::m_Values(){
	return (new bb_map_MapValues)->g_new(this);
}
bb_map_Node7* bb_map_Map7::m_FirstNode(){
	if(!((f_root)!=0)){
		return 0;
	}
	bb_map_Node7* t_node=f_root;
	while((t_node->f_left)!=0){
		t_node=t_node->f_left;
	}
	return t_node;
}
int bb_map_Map7::m_DeleteFixup2(bb_map_Node7* t_node,bb_map_Node7* t_parent){
	while(t_node!=f_root && (!((t_node)!=0) || t_node->f_color==1)){
		if(t_node==t_parent->f_left){
			bb_map_Node7* t_sib=t_parent->f_right;
			if(t_sib->f_color==-1){
				t_sib->f_color=1;
				t_parent->f_color=-1;
				m_RotateLeft7(t_parent);
				t_sib=t_parent->f_right;
			}
			if((!((t_sib->f_left)!=0) || t_sib->f_left->f_color==1) && (!((t_sib->f_right)!=0) || t_sib->f_right->f_color==1)){
				t_sib->f_color=-1;
				t_node=t_parent;
				t_parent=t_parent->f_parent;
			}else{
				if(!((t_sib->f_right)!=0) || t_sib->f_right->f_color==1){
					t_sib->f_left->f_color=1;
					t_sib->f_color=-1;
					m_RotateRight7(t_sib);
					t_sib=t_parent->f_right;
				}
				t_sib->f_color=t_parent->f_color;
				t_parent->f_color=1;
				t_sib->f_right->f_color=1;
				m_RotateLeft7(t_parent);
				t_node=f_root;
			}
		}else{
			bb_map_Node7* t_sib2=t_parent->f_left;
			if(t_sib2->f_color==-1){
				t_sib2->f_color=1;
				t_parent->f_color=-1;
				m_RotateRight7(t_parent);
				t_sib2=t_parent->f_left;
			}
			if((!((t_sib2->f_right)!=0) || t_sib2->f_right->f_color==1) && (!((t_sib2->f_left)!=0) || t_sib2->f_left->f_color==1)){
				t_sib2->f_color=-1;
				t_node=t_parent;
				t_parent=t_parent->f_parent;
			}else{
				if(!((t_sib2->f_left)!=0) || t_sib2->f_left->f_color==1){
					t_sib2->f_right->f_color=1;
					t_sib2->f_color=-1;
					m_RotateLeft7(t_sib2);
					t_sib2=t_parent->f_left;
				}
				t_sib2->f_color=t_parent->f_color;
				t_parent->f_color=1;
				t_sib2->f_left->f_color=1;
				m_RotateRight7(t_parent);
				t_node=f_root;
			}
		}
	}
	if((t_node)!=0){
		t_node->f_color=1;
	}
	return 0;
}
int bb_map_Map7::m_RemoveNode2(bb_map_Node7* t_node){
	bb_map_Node7* t_splice=0;
	bb_map_Node7* t_child=0;
	if(!((t_node->f_left)!=0)){
		t_splice=t_node;
		t_child=t_node->f_right;
	}else{
		if(!((t_node->f_right)!=0)){
			t_splice=t_node;
			t_child=t_node->f_left;
		}else{
			t_splice=t_node->f_left;
			while((t_splice->f_right)!=0){
				t_splice=t_splice->f_right;
			}
			t_child=t_splice->f_left;
			t_node->f_key=t_splice->f_key;
			gc_assign(t_node->f_value,t_splice->f_value);
		}
	}
	bb_map_Node7* t_parent=t_splice->f_parent;
	if((t_child)!=0){
		gc_assign(t_child->f_parent,t_parent);
	}
	if(!((t_parent)!=0)){
		gc_assign(f_root,t_child);
		return 0;
	}
	if(t_splice==t_parent->f_left){
		gc_assign(t_parent->f_left,t_child);
	}else{
		gc_assign(t_parent->f_right,t_child);
	}
	if(t_splice->f_color==1){
		m_DeleteFixup2(t_child,t_parent);
	}
	return 0;
}
int bb_map_Map7::m_Remove4(int t_key){
	bb_map_Node7* t_node=m_FindNode2(t_key);
	if(!((t_node)!=0)){
		return 0;
	}
	m_RemoveNode2(t_node);
	return 1;
}
int bb_map_Map7::m_Clear(){
	f_root=0;
	return 0;
}
void bb_map_Map7::mark(){
	Object::mark();
	gc_mark_q(f_root);
}
bb_map_IntMap2::bb_map_IntMap2(){
}
bb_map_IntMap2* bb_map_IntMap2::g_new(){
	bb_map_Map7::g_new();
	return this;
}
int bb_map_IntMap2::m_Compare2(int t_lhs,int t_rhs){
	return t_lhs-t_rhs;
}
void bb_map_IntMap2::mark(){
	bb_map_Map7::mark();
}
bb_map_Node7::bb_map_Node7(){
	f_key=0;
	f_right=0;
	f_left=0;
	f_value=0;
	f_color=0;
	f_parent=0;
}
bb_map_Node7* bb_map_Node7::g_new(int t_key,bb_keyevent_KeyEvent* t_value,int t_color,bb_map_Node7* t_parent){
	this->f_key=t_key;
	gc_assign(this->f_value,t_value);
	this->f_color=t_color;
	gc_assign(this->f_parent,t_parent);
	return this;
}
bb_map_Node7* bb_map_Node7::g_new2(){
	return this;
}
bb_map_Node7* bb_map_Node7::m_NextNode(){
	bb_map_Node7* t_node=0;
	if((f_right)!=0){
		t_node=f_right;
		while((t_node->f_left)!=0){
			t_node=t_node->f_left;
		}
		return t_node;
	}
	t_node=this;
	bb_map_Node7* t_parent=this->f_parent;
	while(((t_parent)!=0) && t_node==t_parent->f_right){
		t_node=t_parent;
		t_parent=t_parent->f_parent;
	}
	return t_parent;
}
void bb_map_Node7::mark(){
	Object::mark();
	gc_mark_q(f_right);
	gc_mark_q(f_left);
	gc_mark_q(f_value);
	gc_mark_q(f_parent);
}
bb_map_MapValues::bb_map_MapValues(){
	f_map=0;
}
bb_map_MapValues* bb_map_MapValues::g_new(bb_map_Map7* t_map){
	gc_assign(this->f_map,t_map);
	return this;
}
bb_map_MapValues* bb_map_MapValues::g_new2(){
	return this;
}
bb_map_ValueEnumerator* bb_map_MapValues::m_ObjectEnumerator(){
	return (new bb_map_ValueEnumerator)->g_new(f_map->m_FirstNode());
}
void bb_map_MapValues::mark(){
	Object::mark();
	gc_mark_q(f_map);
}
bb_map_ValueEnumerator::bb_map_ValueEnumerator(){
	f_node=0;
}
bb_map_ValueEnumerator* bb_map_ValueEnumerator::g_new(bb_map_Node7* t_node){
	gc_assign(this->f_node,t_node);
	return this;
}
bb_map_ValueEnumerator* bb_map_ValueEnumerator::g_new2(){
	return this;
}
bool bb_map_ValueEnumerator::m_HasNext(){
	return f_node!=0;
}
bb_keyevent_KeyEvent* bb_map_ValueEnumerator::m_NextObject(){
	bb_map_Node7* t_t=f_node;
	gc_assign(f_node,f_node->m_NextNode());
	return t_t->f_value;
}
void bb_map_ValueEnumerator::mark(){
	Object::mark();
	gc_mark_q(f_node);
}
int bb_input_DisableKeyboard(){
	return bb_input_device->SetKeyboardEnabled(0);
}
int bb_graphics_PushMatrix(){
	int t_sp=bb_graphics_context->f_matrixSp;
	bb_graphics_context->f_matrixStack[t_sp+0]=bb_graphics_context->f_ix;
	bb_graphics_context->f_matrixStack[t_sp+1]=bb_graphics_context->f_iy;
	bb_graphics_context->f_matrixStack[t_sp+2]=bb_graphics_context->f_jx;
	bb_graphics_context->f_matrixStack[t_sp+3]=bb_graphics_context->f_jy;
	bb_graphics_context->f_matrixStack[t_sp+4]=bb_graphics_context->f_tx;
	bb_graphics_context->f_matrixStack[t_sp+5]=bb_graphics_context->f_ty;
	bb_graphics_context->f_matrixSp=t_sp+6;
	return 0;
}
int bb_graphics_Transform(Float t_ix,Float t_iy,Float t_jx,Float t_jy,Float t_tx,Float t_ty){
	Float t_ix2=t_ix*bb_graphics_context->f_ix+t_iy*bb_graphics_context->f_jx;
	Float t_iy2=t_ix*bb_graphics_context->f_iy+t_iy*bb_graphics_context->f_jy;
	Float t_jx2=t_jx*bb_graphics_context->f_ix+t_jy*bb_graphics_context->f_jx;
	Float t_jy2=t_jx*bb_graphics_context->f_iy+t_jy*bb_graphics_context->f_jy;
	Float t_tx2=t_tx*bb_graphics_context->f_ix+t_ty*bb_graphics_context->f_jx+bb_graphics_context->f_tx;
	Float t_ty2=t_tx*bb_graphics_context->f_iy+t_ty*bb_graphics_context->f_jy+bb_graphics_context->f_ty;
	bb_graphics_SetMatrix(t_ix2,t_iy2,t_jx2,t_jy2,t_tx2,t_ty2);
	return 0;
}
int bb_graphics_Transform2(Array<Float > t_m){
	bb_graphics_Transform(t_m[0],t_m[1],t_m[2],t_m[3],t_m[4],t_m[5]);
	return 0;
}
int bb_graphics_Scale(Float t_x,Float t_y){
	bb_graphics_Transform(t_x,FLOAT(0.0),FLOAT(0.0),t_y,FLOAT(0.0),FLOAT(0.0));
	return 0;
}
int bb_graphics_Cls(Float t_r,Float t_g,Float t_b){
	bb_graphics_renderDevice->Cls(t_r,t_g,t_b);
	return 0;
}
int bb_graphics_PopMatrix(){
	int t_sp=bb_graphics_context->f_matrixSp-6;
	bb_graphics_SetMatrix(bb_graphics_context->f_matrixStack[t_sp+0],bb_graphics_context->f_matrixStack[t_sp+1],bb_graphics_context->f_matrixStack[t_sp+2],bb_graphics_context->f_matrixStack[t_sp+3],bb_graphics_context->f_matrixStack[t_sp+4],bb_graphics_context->f_matrixStack[t_sp+5]);
	bb_graphics_context->f_matrixSp=t_sp;
	return 0;
}
int bb_graphics_Translate(Float t_x,Float t_y){
	bb_graphics_Transform(FLOAT(1.0),FLOAT(0.0),FLOAT(0.0),FLOAT(1.0),t_x,t_y);
	return 0;
}
int bb_graphics_ValidateMatrix(){
	if((bb_graphics_context->f_matDirty)!=0){
		bb_graphics_context->f_device->SetMatrix(bb_graphics_context->f_ix,bb_graphics_context->f_iy,bb_graphics_context->f_jx,bb_graphics_context->f_jy,bb_graphics_context->f_tx,bb_graphics_context->f_ty);
		bb_graphics_context->f_matDirty=0;
	}
	return 0;
}
int bb_graphics_DrawImage(bb_graphics_Image* t_image,Float t_x,Float t_y,int t_frame){
	bb_graphics_Frame* t_f=t_image->f_frames[t_frame];
	if((bb_graphics_context->f_tformed)!=0){
		bb_graphics_PushMatrix();
		bb_graphics_Translate(t_x-t_image->f_tx,t_y-t_image->f_ty);
		bb_graphics_ValidateMatrix();
		if((t_image->f_flags&65536)!=0){
			bb_graphics_context->f_device->DrawSurface(t_image->f_surface,FLOAT(0.0),FLOAT(0.0));
		}else{
			bb_graphics_context->f_device->DrawSurface2(t_image->f_surface,FLOAT(0.0),FLOAT(0.0),t_f->f_x,t_f->f_y,t_image->f_width,t_image->f_height);
		}
		bb_graphics_PopMatrix();
	}else{
		bb_graphics_ValidateMatrix();
		if((t_image->f_flags&65536)!=0){
			bb_graphics_context->f_device->DrawSurface(t_image->f_surface,t_x-t_image->f_tx,t_y-t_image->f_ty);
		}else{
			bb_graphics_context->f_device->DrawSurface2(t_image->f_surface,t_x-t_image->f_tx,t_y-t_image->f_ty,t_f->f_x,t_f->f_y,t_image->f_width,t_image->f_height);
		}
	}
	return 0;
}
int bb_graphics_Rotate(Float t_angle){
	bb_graphics_Transform((Float)cos((t_angle)*D2R),-(Float)sin((t_angle)*D2R),(Float)sin((t_angle)*D2R),(Float)cos((t_angle)*D2R),FLOAT(0.0),FLOAT(0.0));
	return 0;
}
int bb_graphics_DrawImage2(bb_graphics_Image* t_image,Float t_x,Float t_y,Float t_rotation,Float t_scaleX,Float t_scaleY,int t_frame){
	bb_graphics_Frame* t_f=t_image->f_frames[t_frame];
	bb_graphics_PushMatrix();
	bb_graphics_Translate(t_x,t_y);
	bb_graphics_Rotate(t_rotation);
	bb_graphics_Scale(t_scaleX,t_scaleY);
	bb_graphics_Translate(-t_image->f_tx,-t_image->f_ty);
	bb_graphics_ValidateMatrix();
	if((t_image->f_flags&65536)!=0){
		bb_graphics_context->f_device->DrawSurface(t_image->f_surface,FLOAT(0.0),FLOAT(0.0));
	}else{
		bb_graphics_context->f_device->DrawSurface2(t_image->f_surface,FLOAT(0.0),FLOAT(0.0),t_f->f_x,t_f->f_y,t_image->f_width,t_image->f_height);
	}
	bb_graphics_PopMatrix();
	return 0;
}
int bb_graphics_DrawRect(Float t_x,Float t_y,Float t_w,Float t_h){
	bb_graphics_ValidateMatrix();
	bb_graphics_renderDevice->DrawRect(t_x,t_y,t_w,t_h);
	return 0;
}
bb_color_Color::bb_color_Color(){
	f_oldColor=0;
	f_red=FLOAT(.0);
	f_green=FLOAT(.0);
	f_blue=FLOAT(.0);
	f_alpha=FLOAT(.0);
}
bb_color_Color* bb_color_Color::g_new(Float t_red,Float t_green,Float t_blue,Float t_alpha){
	this->f_red=t_red;
	this->f_green=t_green;
	this->f_blue=t_blue;
	this->f_alpha=t_alpha;
	return this;
}
bb_color_Color* bb_color_Color::g_new2(){
	return this;
}
void bb_color_Color::m_Set8(bb_color_Color* t_color){
	bb_graphics_SetColor(t_color->f_red,t_color->f_green,t_color->f_blue);
	bb_graphics_SetAlpha(t_color->f_alpha);
}
void bb_color_Color::m_Activate(){
	if(!((f_oldColor)!=0)){
		gc_assign(f_oldColor,(new bb_color_Color)->g_new(FLOAT(0.0),FLOAT(0.0),FLOAT(0.0),FLOAT(0.0)));
	}
	Array<Float > t_colorStack=bb_graphics_GetColor();
	f_oldColor->f_red=t_colorStack[0];
	f_oldColor->f_green=t_colorStack[1];
	f_oldColor->f_blue=t_colorStack[2];
	f_oldColor->f_alpha=bb_graphics_GetAlpha();
	m_Set8(this);
}
void bb_color_Color::m_Deactivate(){
	if((f_oldColor)!=0){
		m_Set8(f_oldColor);
	}
}
void bb_color_Color::mark(){
	Object::mark();
	gc_mark_q(f_oldColor);
}
Array<Float > bb_graphics_GetColor(){
	Float t_[]={bb_graphics_context->f_color_r,bb_graphics_context->f_color_g,bb_graphics_context->f_color_b};
	return Array<Float >(t_,3);
}
Float bb_graphics_GetAlpha(){
	return bb_graphics_context->f_alpha;
}
int bb_graphics_DrawImageRect(bb_graphics_Image* t_image,Float t_x,Float t_y,int t_srcX,int t_srcY,int t_srcWidth,int t_srcHeight,int t_frame){
	bb_graphics_Frame* t_f=t_image->f_frames[t_frame];
	if((bb_graphics_context->f_tformed)!=0){
		bb_graphics_PushMatrix();
		bb_graphics_Translate(-t_image->f_tx+t_x,-t_image->f_ty+t_y);
		bb_graphics_ValidateMatrix();
		bb_graphics_context->f_device->DrawSurface2(t_image->f_surface,FLOAT(0.0),FLOAT(0.0),t_srcX+t_f->f_x,t_srcY+t_f->f_y,t_srcWidth,t_srcHeight);
		bb_graphics_PopMatrix();
	}else{
		bb_graphics_ValidateMatrix();
		bb_graphics_context->f_device->DrawSurface2(t_image->f_surface,-t_image->f_tx+t_x,-t_image->f_ty+t_y,t_srcX+t_f->f_x,t_srcY+t_f->f_y,t_srcWidth,t_srcHeight);
	}
	return 0;
}
int bb_graphics_DrawImageRect2(bb_graphics_Image* t_image,Float t_x,Float t_y,int t_srcX,int t_srcY,int t_srcWidth,int t_srcHeight,Float t_rotation,Float t_scaleX,Float t_scaleY,int t_frame){
	bb_graphics_Frame* t_f=t_image->f_frames[t_frame];
	bb_graphics_PushMatrix();
	bb_graphics_Translate(t_x,t_y);
	bb_graphics_Rotate(t_rotation);
	bb_graphics_Scale(t_scaleX,t_scaleY);
	bb_graphics_Translate(-t_image->f_tx,-t_image->f_ty);
	bb_graphics_ValidateMatrix();
	bb_graphics_context->f_device->DrawSurface2(t_image->f_surface,FLOAT(0.0),FLOAT(0.0),t_srcX+t_f->f_x,t_srcY+t_f->f_y,t_srcWidth,t_srcHeight);
	bb_graphics_PopMatrix();
	return 0;
}
int bb_math_Min(int t_x,int t_y){
	if(t_x<t_y){
		return t_x;
	}
	return t_y;
}
Float bb_math_Min2(Float t_x,Float t_y){
	if(t_x<t_y){
		return t_x;
	}
	return t_y;
}
bb_shape_Shape::bb_shape_Shape(){
	f_type=0;
	f_lane=0;
	f_chute=0;
	f_isFast=false;
}
Array<bb_graphics_Image* > bb_shape_Shape::g_images;
bb_vector2d_Vector2D* bb_shape_Shape::g_SPEED_SLOW;
bb_vector2d_Vector2D* bb_shape_Shape::g_SPEED_FAST;
bb_shape_Shape* bb_shape_Shape::g_new(int t_type,int t_lane,bb_chute_Chute* t_chute){
	bb_baseobject_BaseObject::g_new();
	this->f_type=t_type;
	this->f_lane=t_lane;
	gc_assign(this->f_chute,t_chute);
	if(g_images.Length()==0){
		bb_graphics_Image* t_[]={bb_graphics_LoadImage(String(L"circle_inside.png"),1,bb_graphics_Image::g_DefaultFlags),bb_graphics_LoadImage(String(L"plus_inside.png"),1,bb_graphics_Image::g_DefaultFlags),bb_graphics_LoadImage(String(L"star_inside.png"),1,bb_graphics_Image::g_DefaultFlags),bb_graphics_LoadImage(String(L"tire_inside.png"),1,bb_graphics_Image::g_DefaultFlags)};
		gc_assign(g_images,Array<bb_graphics_Image* >(t_,4));
	}
	Float t_posX=Float(44+g_images[0]->m_Width()*t_lane);
	Float t_posY=Float(t_chute->m_Height()-g_images[t_type]->m_Height());
	m_pos2((new bb_vector2d_Vector2D)->g_new(t_posX,t_posY));
	if(!((g_SPEED_SLOW)!=0)){
		gc_assign(g_SPEED_SLOW,(new bb_vector2d_Vector2D)->g_new(FLOAT(0.0),FLOAT(3.0)));
	}
	if(!((g_SPEED_FAST)!=0)){
		gc_assign(g_SPEED_FAST,(new bb_vector2d_Vector2D)->g_new(FLOAT(0.0),FLOAT(10.0)));
	}
	return this;
}
bb_shape_Shape* bb_shape_Shape::g_new2(){
	bb_baseobject_BaseObject::g_new();
	return this;
}
void bb_shape_Shape::m_OnUpdate(Float t_delta,Float t_frameTime){
	if(f_isFast){
		m_pos()->m_Add2(g_SPEED_FAST->m_Copy()->m_Mul2(t_delta));
	}else{
		m_pos()->m_Add2(g_SPEED_SLOW->m_Copy()->m_Mul2(t_delta));
	}
}
void bb_shape_Shape::m_OnRender(){
	bb_graphics_DrawImage(g_images[f_type],m_pos()->f_x,m_pos()->f_y,0);
}
void bb_shape_Shape::mark(){
	bb_baseobject_BaseObject::mark();
	gc_mark_q(f_chute);
}
bb_stack_Stack2::bb_stack_Stack2(){
	f_data=Array<bb_sprite_Sprite* >();
	f_length=0;
}
bb_stack_Stack2* bb_stack_Stack2::g_new(){
	return this;
}
bb_stack_Stack2* bb_stack_Stack2::g_new2(Array<bb_sprite_Sprite* > t_data){
	gc_assign(this->f_data,t_data.Slice(0));
	this->f_length=t_data.Length();
	return this;
}
int bb_stack_Stack2::m_Length(){
	return f_length;
}
bb_sprite_Sprite* bb_stack_Stack2::m_Pop(){
	f_length-=1;
	return f_data[f_length];
}
int bb_stack_Stack2::m_Push2(bb_sprite_Sprite* t_value){
	if(f_length==f_data.Length()){
		gc_assign(f_data,f_data.Resize(f_length*2+10));
	}
	gc_assign(f_data[f_length],t_value);
	f_length+=1;
	return 0;
}
void bb_stack_Stack2::mark(){
	Object::mark();
	gc_mark_q(f_data);
}
int bb_math_Max(int t_x,int t_y){
	if(t_x>t_y){
		return t_x;
	}
	return t_y;
}
Float bb_math_Max2(Float t_x,Float t_y){
	if(t_x>t_y){
		return t_x;
	}
	return t_y;
}
int bb_math_Abs(int t_x){
	if(t_x>=0){
		return t_x;
	}
	return -t_x;
}
Float bb_math_Abs2(Float t_x){
	if(t_x>=FLOAT(0.0)){
		return t_x;
	}
	return -t_x;
}
int bb_app_SaveState(String t_state){
	return bb_app_device->SaveState(t_state);
}
int bbInit(){
	bb_graphics_context=0;
	bb_input_device=0;
	bb_audio_device=0;
	bb_app_device=0;
	bb_scene_Scene::g_blend=0;
	bb_graphics_Image::g_DefaultFlags=256;
	bb_angelfont2_AngelFont::g_error=String();
	bb_angelfont2_AngelFont::g_current=0;
	bb_angelfont2_AngelFont::g__list=(new bb_map_StringMap4)->g_new();
	bb_gamehighscore_GameHighscore::g_names=Array<String >();
	bb_gamehighscore_GameHighscore::g_scores=Array<int >();
	bb_severity_globalSeverityInstance=0;
	bb_random_Seed=1234;
	bb_graphics_renderDevice=0;
	bb_angelfont_AngelFont::g_error=String();
	bb_angelfont_AngelFont::g_current=0;
	bb_angelfont_AngelFont::g__list=(new bb_map_StringMap5)->g_new();
	bb_shape_Shape::g_images=Array<bb_graphics_Image* >();
	bb_shape_Shape::g_SPEED_SLOW=0;
	bb_shape_Shape::g_SPEED_FAST=0;
	return 0;
}
void gc_mark(){
	gc_mark_q(bb_graphics_context);
	gc_mark_q(bb_input_device);
	gc_mark_q(bb_audio_device);
	gc_mark_q(bb_app_device);
	gc_mark_q(bb_scene_Scene::g_blend);
	gc_mark_q(bb_angelfont2_AngelFont::g_current);
	gc_mark_q(bb_angelfont2_AngelFont::g__list);
	gc_mark_q(bb_gamehighscore_GameHighscore::g_names);
	gc_mark_q(bb_gamehighscore_GameHighscore::g_scores);
	gc_mark_q(bb_severity_globalSeverityInstance);
	gc_mark_q(bb_graphics_renderDevice);
	gc_mark_q(bb_angelfont_AngelFont::g_current);
	gc_mark_q(bb_angelfont_AngelFont::g__list);
	gc_mark_q(bb_shape_Shape::g_images);
	gc_mark_q(bb_shape_Shape::g_SPEED_SLOW);
	gc_mark_q(bb_shape_Shape::g_SPEED_FAST);
}
//${TRANSCODE_END}

//***** main.m *****

int main(int argc, char *argv[]) {

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    UIApplicationMain( argc,argv,nil,nil );
    
    [pool release];
	
	return 0;
}
