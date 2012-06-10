
// XNA mojo runtime.
//
// Copyright 2011 Mark Sibly, all rights reserved.
// No warranty implied; use at your own risk.

public class gxtkApp{

	public static gxtkApp _app;
	
	public Stopwatch _stopwatch;

	public gxtkGraphics _graphics;
	public gxtkInput _input;
	public gxtkAudio _audio;
	
	public int _updateRate;
	public bool _suspended;
	
	public float _updatePeriod;
	public float _nextUpdate;

	public static void Main( String[] args ){
		try{
			bb_.bbInit();
			bb_.bbMain();
			if( _app!=null ) _app.Run();
		}catch( Exception ex ){
		}
	}

	public gxtkApp(){
		_app=this;

		_stopwatch=new Stopwatch();
		_stopwatch.Start();
		
		_graphics=new gxtkGraphics();
		_input=new gxtkInput();
		_audio=new gxtkAudio();
	}
	
	public float GetTime(){
		return (float)_stopwatch.ElapsedMilliseconds/1000.0f;	
	}
	
	public void Run(){

		OnCreate();
		
		InvokeOnRender();
		
		for(;;){
		
			SystemEvents.CheckEvents();
	
			if( _updateRate==0 || _suspended || GetTime()<_nextUpdate ) continue;
			
			int updates=0;
			
			while( updates<8 ){
			
				_nextUpdate+=_updatePeriod;
				
				InvokeOnUpdate();
	
				if( _updateRate==0 || _suspended || GetTime()<_nextUpdate ) break;

				++updates;
			}

			InvokeOnRender();
			
			if( updates==8 ) _nextUpdate=GetTime();
		}
	}
	
	public void InvokeOnUpdate(){
		if( _suspended || _updateRate==0 ) return;
		
		_input.BeginUpdate();
		
		OnUpdate();
		
		_input.EndUpdate();
	}
	
	public void InvokeOnRender(){
		if( _suspended ) return;
	
		_graphics.BeginRender();
	
		OnRender();
	
		_graphics.EndRender();
	}
	
	//***** GXTK API *****
	
	public virtual gxtkGraphics GraphicsDevice(){
		return _graphics;
	}
	
	public virtual gxtkInput InputDevice(){
		return _input;
	}
	
	public virtual gxtkAudio AudioDevice(){
		return _audio;
	}

	public virtual String LoadState(){
		try{
			return File.ReadAllText( "/Documents/mojo_state.txt" );
		}catch( IOException ex ){
		}
		return "";
	}
	
	public virtual int SaveState( String state ){
		try{
			File.WriteAllText( "/Documents/mojo_state.txt",state );
			return 0;
		}catch( IOException ex ){
		}
		return -1;
	}
	
	public virtual String LoadString( String path ){
		return MonkeyData.LoadString( path );
	}
	
	public virtual int SetUpdateRate( int hertz ){
		_updateRate=hertz;
	
		if( _updateRate!=0 ){
			_updatePeriod=1.0f/(float)_updateRate;
			_nextUpdate=GetTime()+_updatePeriod;
		}
		return 0;
	}
	
	public virtual int MilliSecs(){
		return (int)_stopwatch.ElapsedMilliseconds;
	}

	public virtual int OnCreate(){
		return 0;
	}

	public virtual int OnSuspend(){
		return 0;
	}

	public virtual int OnResume(){
		return 0;
	}

	public virtual int OnUpdate(){
		return 0;
	}

	public virtual int OnRender(){
		return 0;
	}

	public virtual int OnLoading(){
		return 0;
	}
}

public class gxtkGraphics{

	public const int MAX_VERTS=1024;
	public const int MAX_LINES=MAX_VERTS/2;
	public const int MAX_QUADS=MAX_VERTS/4;

	public GraphicsContext _gc;
	
	public int _width,_height;
	
	public ShaderProgram _simpleShader,_textureShader;
	public int _texUnit;
	
	public VertexBuffer _vertBuf,_quadBuf;
	
	public int _primType,_vertCount;
	public gxtkSurface _primSurf;
	
	public float _red,_green,_blue,_alpha;
	public uint _color;
	public bool _tformed;
	public float _ix,_iy,_jx,_jy,_tx,_ty;
	
	public float[] _verts=new float[MAX_VERTS*2];
	public float[] _texcs=new float[MAX_VERTS*2];
	public uint[] _colors=new uint[MAX_VERTS];
	
	public gxtkGraphics(){
	
		_gc=new GraphicsContext();
		ImageRect r=_gc.GetViewport();
		_width=r.Width;
		_height=r.Height;

		//Shaders....
		//
		_simpleShader=new ShaderProgram( "/Application/shaders/Simple.cgx" );
		_textureShader=new ShaderProgram( "/Application/shaders/Texture.cgx" );

		float[] ortho=new float[]{
			2.0f/(float)_width,0.0f,0.0f,0.0f,
			0.0f,-2.0f/(float)_height,0.0f,0.0f,
			0.0f,0.0f,1.0f,0.0f,
			-1.0f,1.0f,0.0f,1.0f };
		
		_simpleShader.SetUniformValue( _simpleShader.FindUniform( "WorldViewProj" ),ortho );
		_textureShader.SetUniformValue( _textureShader.FindUniform( "WorldViewProj" ),ortho );
		_texUnit=_textureShader.GetUniformTexture( _textureShader.FindUniform( "Texture0" ) );

		//Vertex buffers...
		//
		_vertBuf=new VertexBuffer( MAX_VERTS,VertexFormat.Float2,VertexFormat.UByte4N );

		_quadBuf=new VertexBuffer( MAX_VERTS,MAX_QUADS*6,VertexFormat.Float2,VertexFormat.UByte4N,VertexFormat.Float2 );
		ushort[] idxs=new ushort[MAX_QUADS*6];
		for( int i=0;i<MAX_QUADS;++i ){
			idxs[i*6+0]=(ushort)(i*4);
			idxs[i*6+1]=(ushort)(i*4+1);
			idxs[i*6+2]=(ushort)(i*4+2);
			idxs[i*6+3]=(ushort)(i*4);
			idxs[i*6+4]=(ushort)(i*4+2);
			idxs[i*6+5]=(ushort)(i*4+3);
		}
		_quadBuf.SetIndices( idxs );
	}
	
	public void BeginRender(){
		_gc.Disable( EnableMode.All );
		_gc.Enable( EnableMode.Blend );
		_gc.SetBlendFunc( BlendFuncMode.Add,BlendFuncFactor.One,BlendFuncFactor.OneMinusSrcAlpha );
	}
	
	public void EndRender(){
		Flush();
		_gc.SwapBuffers();
	}
	
	public void Flush(){
		if( _vertCount==0 ) return;
		
		if( _primType==4 ){

			_quadBuf.SetVertices( 0,_verts,0,0,_vertCount );
			_quadBuf.SetVertices( 1,_colors,0,0,_vertCount );
		
			if( _primSurf!=null ){
				_quadBuf.SetVertices( 2,_texcs,0,0,_vertCount );
				_gc.SetShaderProgram( _textureShader );
				_gc.SetTexture( _texUnit,_primSurf._texture );
			}else{
				_gc.SetShaderProgram( _simpleShader );
			}
			_gc.SetVertexBuffer( 0,_quadBuf );
			_gc.DrawArrays( DrawMode.Triangles,0,_vertCount/4*6 );

		}else{

			_vertBuf.SetVertices( 0,_verts,0,0,_vertCount );
			_vertBuf.SetVertices( 1,_colors,0,0,_vertCount );
			
			_gc.SetShaderProgram( _simpleShader );
			_gc.SetVertexBuffer( 0,_vertBuf );
			
			switch( _primType ){
			case 1:_gc.DrawArrays( DrawMode.Points,0,_vertCount );break;
			case 2:_gc.DrawArrays( DrawMode.Lines,0,_vertCount );break;
			case 5:_gc.DrawArrays( DrawMode.TriangleFan,0,_vertCount );break;
			}
		}
		
		_vertCount=0;
	}
	
	//***** GXTK API *****
	
	public virtual int Mode(){
		return 1;
	}
	
	public virtual int Width(){
		return _width;
	}
	
	public virtual int Height(){
		return _height;
	}
	
	public virtual gxtkSurface LoadSurface( String path ){
		Texture2D texture=MonkeyData.LoadTexture2D( path );
		if( texture!=null ) return new gxtkSurface( texture );
		return null;
	}
	
	public virtual int SetAlpha( float alpha ){
		_alpha=alpha;
		_color=((uint)(_alpha*255.0f)<<24) | ((uint)(_blue*_alpha)<<16) | ((uint)(_green*_alpha)<<8) | (uint)(_red*_alpha);
//		Console.WriteLine( _color.ToString( "x" ) );
		return 0;
	}

	public virtual int SetColor( float r,float g,float b ){
		_red=r;
		_green=g;
		_blue=b;
		_color=((uint)(_alpha*255.0f)<<24) | ((uint)(_blue*_alpha)<<16) | ((uint)(_green*_alpha)<<8) | (uint)(_red*_alpha);
//		Console.WriteLine( _color.ToString( "x" ) );
		return 0;
	}
	
	public virtual int SetBlend( int blend ){
		Flush();

		switch( blend ){
		case 1:
			_gc.SetBlendFunc( BlendFuncMode.Add,BlendFuncFactor.One,BlendFuncFactor.One );
			break;
		default:
			_gc.SetBlendFunc( BlendFuncMode.Add,BlendFuncFactor.One,BlendFuncFactor.OneMinusSrcAlpha );
			break;
		}
		return 0;
	}
	
	public virtual int SetMatrix( float ix,float iy,float jx,float jy,float tx,float ty ){
		_tformed=(ix!=1.0f || iy!=0.0f || jx!=0.0f || jy!=1.0f || tx!=0.0f || ty!=0.0f);
		_ix=ix;_iy=iy;
		_jx=jx;_jy=jy;
		_tx=tx;_ty=ty;
		return 0;
	}
	
	public virtual int SetScissor( int x,int y,int w,int h ){
		Flush();
		
		if( x!=0 || y!=0 || w!=Width() || h!=Height() ){
			_gc.Enable( EnableMode.ScissorTest );
			y=Height()-y-h;
			_gc.SetScissor( x,y,w,h );
		}else{
			_gc.Disable( EnableMode.ScissorTest );
		}
		return 0;
	}
	
	public virtual int Cls( float r,float g,float b ){
		_gc.SetClearColor( r/255.0f,g/255.0f,b/255.0f,1.0f );
		_gc.Clear();
		return 0;
	}

	public virtual int DrawPoint( float x,float y ){
		if( _primType!=1 || _vertCount==MAX_VERTS || _primSurf!=null ){
			Flush();
			_primType=1;
			_primSurf=null;
		}
	
		if( _tformed ){
			float tx=x;
			x=tx * _ix + y * _jx + _tx;
			y=tx * _iy + y * _jy + _ty;
		}
		
		int i=_vertCount*2,j=_vertCount;
		
		_verts[i ]=x;_verts[i+1]=y;_colors[j]=_color;
		
		_vertCount+=1;
		
		return 0;
	}
	
	public virtual int DrawRect( float x,float y,float w,float h ){
		if( _primType!=4 || _vertCount==MAX_VERTS || _primSurf!=null ){
			Flush();
			_primType=4;
			_primSurf=null;
		}
	
		float x0=x,x1=x+w,x2=x+w,x3=x;
		float y0=y,y1=y,y2=y+h,y3=y+h;
	
		if( _tformed ){
			float tx0=x0,tx1=x1,tx2=x2,tx3=x3;
			x0=tx0 * _ix + y0 * _jx + _tx; y0=tx0 * _iy + y0 * _jy + _ty;
			x1=tx1 * _ix + y1 * _jx + _tx; y1=tx1 * _iy + y1 * _jy + _ty;
			x2=tx2 * _ix + y2 * _jx + _tx; y2=tx2 * _iy + y2 * _jy + _ty;
			x3=tx3 * _ix + y3 * _jx + _tx; y3=tx3 * _iy + y3 * _jy + _ty;
		}
		
		int i=_vertCount*2,j=_vertCount;
		
		_verts[i  ]=x0;_verts[i+1]=y0;_colors[j  ]=_color;
		_verts[i+2]=x1;_verts[i+3]=y1;_colors[j+1]=_color;
		_verts[i+4]=x2;_verts[i+5]=y2;_colors[j+2]=_color;
		_verts[i+6]=x3;_verts[i+7]=y3;_colors[j+3]=_color;
		
		_vertCount+=4;

		return 0;
	}

	public virtual int DrawLine( float x0,float y0,float x1,float y1 ){
		if( _primType!=2 || _vertCount==MAX_VERTS || _primSurf!=null ){
			Flush();
			_primType=2;
			_primSurf=null;
		}
	
		if( _tformed ){
			float tx0=x0,tx1=x1;
			x0=tx0 * _ix + y0 * _jx + _tx;y0=tx0 * _iy + y0 * _jy + _ty;
			x1=tx1 * _ix + y1 * _jx + _tx;y1=tx1 * _iy + y1 * _jy + _ty;
		}
		
		int i=_vertCount*2,j=_vertCount;
		
		_verts[i+0]=x0;_verts[i+1]=y0;_colors[j+0]=_color;
		_verts[i+2]=x1;_verts[i+3]=y1;_colors[j+1]=_color;

		_vertCount+=2;
		
		return 0;
	}

	public virtual int DrawOval( float x,float y,float w,float h ){
		Flush();
		
		float xr=w/2.0f;
		float yr=h/2.0f;

		int segs;
		if( _tformed ){
			float dx_x=xr * _ix;
			float dx_y=xr * _iy;
			float dx=(float)Math.Sqrt( dx_x*dx_x+dx_y*dx_y );
			float dy_x=yr * _jx;
			float dy_y=yr * _jy;
			float dy=(float)Math.Sqrt( dy_x*dy_x+dy_y*dy_y );
			segs=(int)( dx+dy );
		}else{
			segs=(int)( Math.Abs( xr )+Math.Abs( yr ) );
		}
		segs=Math.Max( segs,12 ) & ~3;
		segs=Math.Min( segs,MAX_VERTS );

		float x0=x+xr,y0=y+yr;

		for( int i=0;i<segs;++i ){
		
			float th=-(float)i * (float)(Math.PI*2.0) / (float)segs;

			float px=x0+(float)Math.Cos( th ) * xr;
			float py=y0-(float)Math.Sin( th ) * yr;
			
			if( _tformed ){
				float ppx=px;
				px=ppx * _ix + py * _jx + _tx;
				py=ppx * _iy + py * _jy + _ty;
			}
			
			_verts[i*2]=px;_verts[i*2+1]=py;_colors[i]=_color;
		}
		
		_primType=5;
		_primSurf=null;
		_vertCount=segs;

		Flush();
		
		return 0;
	}
	
	public virtual int DrawPoly( float[] verts ){
		int n=verts.Length/2;
		if( n<3 || n>MAX_VERTS ) return 0;
		
		Flush();
		
		for( int i=0;i<n;++i ){
		
			float px=verts[i*2];
			float py=verts[i*2+1];
			
			if( _tformed ){
				float ppx=px;
				px=ppx * _ix + py * _jx + _tx;
				py=ppx * _iy + py * _jy + _ty;
			}
			
			_verts[i*2]=px;_verts[i*2+1]=py;_colors[i]=_color;
		}

		_primType=5;
		_primSurf=null;
		_vertCount=n;
		
		Flush();
		
		return 0;
	}

	public virtual int DrawSurface( gxtkSurface surf,float x,float y ){
		if( _primType!=4 || _vertCount==MAX_VERTS || _primSurf!=surf ){
			Flush();
			_primType=4;
			_primSurf=surf;
		}
		
		float w=surf.Width();
		float h=surf.Height();
		float u0=0,u1=1,v0=0,v1=1;
		float x0=x,x1=x+w,x2=x+w,x3=x;
		float y0=y,y1=y,y2=y+h,y3=y+h;
		
		if( _tformed ){
			float tx0=x0,tx1=x1,tx2=x2,tx3=x3;
			x0=tx0 * _ix + y0 * _jx + _tx; y0=tx0 * _iy + y0 * _jy + _ty;
			x1=tx1 * _ix + y1 * _jx + _tx; y1=tx1 * _iy + y1 * _jy + _ty;
			x2=tx2 * _ix + y2 * _jx + _tx; y2=tx2 * _iy + y2 * _jy + _ty;
			x3=tx3 * _ix + y3 * _jx + _tx; y3=tx3 * _iy + y3 * _jy + _ty;
		}

		int i=_vertCount*2,j=_vertCount;
		
		_verts[i+0]=x0;_verts[i+1]=y0;_texcs[i+0]=u0;_texcs[i+1]=v0;_colors[j+0]=_color;
		_verts[i+2]=x1;_verts[i+3]=y1;_texcs[i+2]=u1;_texcs[i+3]=v0;_colors[j+1]=_color;
		_verts[i+4]=x2;_verts[i+5]=y2;_texcs[i+4]=u1;_texcs[i+5]=v1;_colors[j+2]=_color;
		_verts[i+6]=x3;_verts[i+7]=y3;_texcs[i+6]=u0;_texcs[i+7]=v1;_colors[j+3]=_color;
		
		_vertCount+=4;
		
		return 0;
	}

	public virtual int DrawSurface2( gxtkSurface surf,float x,float y,int srcx,int srcy,int srcw,int srch ){
		if( _primType!=4 || _vertCount==MAX_VERTS || _primSurf!=surf ){
			Flush();
			_primType=4;
			_primSurf=surf;
		}
		
		float w=surf.Width();
		float h=surf.Height();
		float u0=srcx/w,u1=(srcx+srcw)/w;
		float v0=srcy/h,v1=(srcy+srch)/h;
		float x0=x,x1=x+srcw,x2=x+srcw,x3=x;
		float y0=y,y1=y,y2=y+srch,y3=y+srch;
		
		if( _tformed ){
			float tx0=x0,tx1=x1,tx2=x2,tx3=x3;
			x0=tx0 * _ix + y0 * _jx + _tx; y0=tx0 * _iy + y0 * _jy + _ty;
			x1=tx1 * _ix + y1 * _jx + _tx; y1=tx1 * _iy + y1 * _jy + _ty;
			x2=tx2 * _ix + y2 * _jx + _tx; y2=tx2 * _iy + y2 * _jy + _ty;
			x3=tx3 * _ix + y3 * _jx + _tx; y3=tx3 * _iy + y3 * _jy + _ty;
		}
	
		int i=_vertCount*2,j=_vertCount;
		
		_verts[i+0]=x0;_verts[i+1]=y0;_texcs[i+0]=u0;_texcs[i+1]=v0;_colors[j+0]=_color;
		_verts[i+2]=x1;_verts[i+3]=y1;_texcs[i+2]=u1;_texcs[i+3]=v0;_colors[j+1]=_color;
		_verts[i+4]=x2;_verts[i+5]=y2;_texcs[i+4]=u1;_texcs[i+5]=v1;_colors[j+2]=_color;
		_verts[i+6]=x3;_verts[i+7]=y3;_texcs[i+6]=u0;_texcs[i+7]=v1;_colors[j+3]=_color;
		
		_vertCount+=4;
		
		return 0;
	}
}

public class gxtkSurface{

	public Texture2D _texture;
	
	public gxtkSurface( Texture2D texture ){
		_texture=texture;
	}
	
	public virtual int Width(){
		return _texture.Width;
	}
	
	public virtual int Height(){
		return _texture.Height;
	}
	
}

public class gxtkChannel{
	public SoundPlayer player;
	public Sound sound;
	public float volume=1,pan=0,rate=1;
}

public class gxtkAudio{

	public gxtkChannel[] _channels=new gxtkChannel[32];

	public Bgm _music;
	public BgmPlayer _musicPlayer;
	public float _musicVolume=1;
	
	public gxtkAudio(){
		for( int i=0;i<32;++i ){
			_channels[i]=new gxtkChannel();
		}
	}
	
	//***** GXTK API *****

	public virtual gxtkSample LoadSample( String path ){
		Sound sound=MonkeyData.LoadSound( path );
		if( sound!=null ) return new gxtkSample( sound );
		return null;
	}
	
	public virtual int PlaySample( gxtkSample sample,int channel,int flags ){
		gxtkChannel chan=_channels[channel];
	
		for( int i=0;i<32;++i ){
			gxtkChannel chan2=_channels[i];
			if( chan2.sound==sample._sound && chan2.player.Status==SoundStatus.Stopped ){
				chan2.player.Dispose();
				chan2.player=null;
				chan2.sound=null;
			}
		}
		
		SoundPlayer player=sample._sound.CreatePlayer();
		if( player==null ) return -1;
		
		if( chan.player!=null ){
			chan.player.Stop();
			chan.player.Dispose();
		}
		
		player.Volume=chan.volume;
		player.Pan=chan.pan;
		player.PlaybackRate=chan.rate;
		player.Loop=(flags&1)!=0 ? true : false;
		player.Play();
		
		chan.player=player;
		chan.sound=sample._sound;
		
		return 0;
	}
	
	public virtual int StopChannel( int channel ){
		gxtkChannel chan=_channels[channel];
		
		if( chan.player!=null ){
			chan.player.Stop();
			chan.player.Dispose();
			chan.player=null;
			chan.sound=null;
		}
	
		return 0;
	}
	
	public virtual int PauseChannel( int channel ){
		gxtkChannel chan=_channels[channel];
		
		return -1;
	}
	
	public virtual int ResumeChannel( int channel ){
		gxtkChannel chan=_channels[channel];
		
		return -1;
	}
	
	public virtual int ChannelState( int channel ){
		gxtkChannel chan=_channels[channel];
		
		if( chan.player!=null && chan.player.Status==SoundStatus.Playing ) return 1;

		return 0;
	}
	
	public virtual int SetVolume( int channel,float volume ){
		gxtkChannel chan=_channels[channel];
		
		if( chan.player!=null ) chan.player.Volume=volume;
		chan.volume=volume;
		
		return 0;
	}
	
	public virtual int SetPan( int channel,float pan ){
		gxtkChannel chan=_channels[channel];

		if( chan.player!=null ) chan.player.Pan=pan;
		chan.pan=pan;

		return 0;
	}
	
	public virtual int SetRate( int channel,float rate ){
		gxtkChannel chan=_channels[channel];

		if( chan.player!=null ) chan.player.PlaybackRate=rate;
		chan.rate=rate;

		return 0;
	}
	
	public virtual int PlayMusic( String path,int flags ){
		StopMusic();
		
		_music=MonkeyData.LoadBgm( path );
		if( _music==null ) return -1;
		
		_musicPlayer=_music.CreatePlayer();
		if( _musicPlayer==null ){
			_music=null;
			return -1;
		}
		
		_musicPlayer.Loop=(flags & 1)!=0;
		_musicPlayer.Volume=_musicVolume;
		_musicPlayer.Play();
		
		return -1;
	}
	
	public virtual int StopMusic(){
		if( _musicPlayer!=null ){
			_musicPlayer.Stop();
			_musicPlayer.Dispose();
			_musicPlayer=null;
			_music=null;
		}
		return 0;
	}
	
	public virtual int PauseMusic(){
		if( _musicPlayer!=null ) _musicPlayer.Pause();
		return 0;
	}
	
	public virtual int ResumeMusic(){
		if( _musicPlayer!=null ) _musicPlayer.Resume();
		return 0;
	}
	
	public virtual int MusicState(){
		if( _musicPlayer!=null ){
			if( _musicPlayer.Status==BgmStatus.Playing ) return 1;
			if( _musicPlayer.Status==BgmStatus.Paused ) return 2;
		}
		return 0;
	}
	
	public virtual int SetMusicVolume( float volume ){
		_musicVolume=volume;
		if( _musicPlayer!=null ) _musicPlayer.Volume=volume;
		return 0;
	}
}

public class gxtkSample{

	public Sound _sound;
	
	public gxtkSample( Sound sound ){
		_sound=sound;
	}

	//***** GXTK API *****

	public virtual int Discard(){
		if( _sound!=null ){
			_sound.Dispose();
			_sound=null;
		}
		return 0;
	}	
}

public class gxtkInput{

	public const int KEY_LMB=1;
	public const int KEY_RMB=2;
	public const int KEY_MMB=3;
	
	public const int KEY_ESC=27;
	
	public const int KEY_JOY0_A=0x100;
	public const int KEY_JOY0_B=0x101;
	public const int KEY_JOY0_X=0x102;
	public const int KEY_JOY0_Y=0x103;
	public const int KEY_JOY0_LB=0x104;
	public const int KEY_JOY0_RB=0x105;
	public const int KEY_JOY0_BACK=0x106;
	public const int KEY_JOY0_START=0x107;
	public const int KEY_JOY0_LEFT=0x108;
	public const int KEY_JOY0_UP=0x109;
	public const int KEY_JOY0_RIGHT=0x10a;
	public const int KEY_JOY0_DOWN=0x10b;
	
	public const int KEY_TOUCH0=0x180;
	
	public const int KEY_SHIFT=0x10;
	public const int KEY_CONTROL=0x11;
	
	public const int VKEY_SHIFT=0x10;
	public const int VKEY_CONTROL=0x11;
	
	public const int VKEY_LSHIFT=0xa0;
	public const int VKEY_RSHIFT=0xa1;
	public const int VKEY_LCONTROL=0xa2;
	public const int VKEY_RCONTROL=0xa3;

	public bool _gamePadEnabled=true;
	public bool _touchEnabled=true;
	public bool _motionEnabled=true;
	public bool _mouseEnabled=false;
	
	public int[] _keyStates=new int[512];
	
	public int _charGet,_charPut;
	public int[] _charQueue=new int[32];
	
	public float _mouseX,_mouseY;
	
	public int[] _touches=new int[32];
	public float[] _touchX=new float[32];
	public float[] _touchY=new float[32];
	
	public float[] _joyx=new float[2];
	public float[] _joyy=new float[2];
	
	public float _accelX,_accelY,_accelZ;

	public gxtkInput(){
		for( int i=0;i<32;++i ){
			_touches[i]=-1;
		}
	}
	
	public void PutChar( int chr ){
		if( _charPut!=_charQueue.Length ){
			_charQueue[_charPut++]=chr;
		}
	}

	public void OnKeyDown( int key ){
		if( (_keyStates[key] & 0x100)!=0 ) return;
		
		_keyStates[key]|=0x100;
		++_keyStates[key];
		
		//int chr=KeyToChar( key );
		//if( chr!=0 ) PutChar( chr );

		if( key==KEY_LMB && !_touchEnabled ){
			_keyStates[KEY_TOUCH0]|=0x100;
			++_keyStates[KEY_TOUCH0];
		}else if( key==KEY_TOUCH0 && !_mouseEnabled ){
			_keyStates[KEY_LMB]|=0x100;
			++_keyStates[KEY_LMB];
		}
	}
	
	public void OnKeyUp( int key ){
		if( (_keyStates[key] & 0x100)==0 ) return;
		
		_keyStates[key]&=0xff;

		if( key==KEY_LMB && !_touchEnabled ){
			this._keyStates[KEY_TOUCH0]&=0xff;
		}else if( key==KEY_TOUCH0 && !_mouseEnabled ){
			this._keyStates[KEY_LMB]&=0xff;
		}
	}
	
	public void OnButton( int key,GamePadButtons mask,GamePadButtons down,GamePadButtons up ){
		if( (down & mask)!=0 ){
			OnKeyDown( key );
		}else if( (up & mask)!=0 ){
			OnKeyUp( key );
		}
	}
	
	public void BeginUpdate(){	
	
		SystemEvents.CheckEvents();
		
		if( _gamePadEnabled ){
			
			GamePadData gd=GamePad.GetData( 0 );
			
			GamePadButtons down=gd.ButtonsDown;
			GamePadButtons up=gd.ButtonsUp;
			
			OnButton( KEY_JOY0_LEFT,GamePadButtons.Left,down,up );
			OnButton( KEY_JOY0_UP,GamePadButtons.Up,down,up );
			OnButton( KEY_JOY0_RIGHT,GamePadButtons.Right,down,up );
			OnButton( KEY_JOY0_DOWN,GamePadButtons.Down,down,up );
			OnButton( KEY_JOY0_X,GamePadButtons.Square,down,up );
			OnButton( KEY_JOY0_Y,GamePadButtons.Triangle,down,up );
			OnButton( KEY_JOY0_B,GamePadButtons.Circle,down,up );
			OnButton( KEY_JOY0_A,GamePadButtons.Cross,down,up );
			OnButton( KEY_JOY0_START,GamePadButtons.Start,down,up );
//			OnButton( KEY_JOY0_SELECT,GamePadButtons.Select,down,up );
			OnButton( KEY_JOY0_LB,GamePadButtons.L,down,up );
			OnButton( KEY_JOY0_RB,GamePadButtons.R,down,up );
//			OnButton( KEY_JOY0_BACK,GamePadButtons.Back,down,up );	//Mapped to O on Vita!
			
			_joyx[0]=gd.AnalogLeftX;
			_joyy[0]=-gd.AnalogLeftY;

			_joyx[1]=gd.AnalogRightX;
			_joyy[1]=-gd.AnalogRightY;
		}
		
		if( _motionEnabled ){
			MotionData md=Motion.GetData( 0 );
			
			_accelX=md.Acceleration.X;
			_accelY=-md.Acceleration.Y;
			_accelZ=md.Acceleration.Z;
		}
		
		if( _touchEnabled ){
		
			float gw=gxtkApp._app._graphics._width;
			float gh=gxtkApp._app._graphics._height;
		
			List<TouchData> touchData=Touch.GetData( 0 );
			
			foreach( TouchData td in touchData ){
					
				if( td.Status==TouchStatus.None ) continue;
			
				int pid;
				for( pid=0;pid<32 && _touches[pid]!=td.ID;++pid ){}
			
				switch( td.Status ){
				case TouchStatus.Down:
					if( pid!=32 ){ pid=32;break; }
					for( pid=0;pid<32 && _touches[pid]!=-1;++pid ){}
					if( pid==32 ) break;
					_touches[pid]=td.ID;
					OnKeyDown( KEY_TOUCH0+pid );
					break;
				case TouchStatus.Move:
					break;
				case TouchStatus.Up:case TouchStatus.Canceled:
					if( pid==32 ) break;
					_touches[pid]=-1;
					OnKeyUp( KEY_TOUCH0+pid );
					break;
				}
				
				if( pid==32 ) continue;

				//touch coords are -.5...+.5
				//				
				float tx=(td.X+0.5f)*gw;
				float ty=(td.Y+0.5f)*gh;

				_touchX[pid]=tx;
				_touchY[pid]=ty;
				
				if( pid==0 && !_mouseEnabled ){
					_mouseX=tx;
					_mouseY=ty;
				}
			}
		}
	}		
	
	public void EndUpdate(){
		for( int i=0;i<512;++i ){
			_keyStates[i]&=0x100;
		}
		_charGet=0;
		_charPut=0;
	}
	
	//***** GXTK API *****
	
	public virtual int SetKeyboardEnabled( int enabled ){
		return 0;
	}

	public virtual int KeyDown( int key ){
		if( key>0 && key<512 ){
			return _keyStates[key]>>8;
		}
		return 0;
	}
	
	public virtual int KeyHit( int key ){
		if( key>0 && key<512 ){
			return _keyStates[key] & 0xff;
		}
		return 0;
	}
	
	public virtual int GetChar(){
		if( _charGet!=_charPut ){
			return _charQueue[_charGet++];
		}
		return 0;
	}
	
	public virtual float MouseX(){
		return _mouseX;
	}
	
	public virtual float MouseY(){
		return _mouseY;
	}

	public virtual float JoyX( int index ){
		if( index>=0 && index<2 ) return _joyx[index];
		return 0;
	}
	
	public virtual float JoyY( int index ){
		if( index>=0 && index<2 ) return _joyy[index];
		return 0;
	}
	
	public virtual float JoyZ( int index ){
		return 0;
	}
	
	public virtual float TouchX( int index ){
		return _touchX[index];
	}

	public virtual float TouchY( int index ){
		return _touchY[index];
	}
	
	public virtual float AccelX(){
		return _accelX;
	}

	public virtual float AccelY(){
		return _accelY;
	}

	public virtual float AccelZ(){
		return _accelZ;
	}
}
