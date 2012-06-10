
// XNA mojo runtime.
//
// Copyright 2011 Mark Sibly, all rights reserved.
// No warranty implied; use at your own risk.

public class gxtkGame : Game{

	public gxtkApp app;
	
	public GraphicsDeviceManager deviceManager;
	
	public bool activated,autoSuspend;

	public gxtkGame(){
	
		gxtkApp.game=this;
	
		deviceManager=new GraphicsDeviceManager( this );
		
#if WINDOWS
		deviceManager.IsFullScreen=bool.Parse( MonkeyConfig.XNA_WINDOW_FULLSCREEN );
		deviceManager.PreferredBackBufferWidth=int.Parse( MonkeyConfig.XNA_WINDOW_WIDTH );
		deviceManager.PreferredBackBufferHeight=int.Parse( MonkeyConfig.XNA_WINDOW_HEIGHT );
		Window.AllowUserResizing=bool.Parse( MonkeyConfig.XNA_WINDOW_RESIZABLE );
#elif XBOX
		deviceManager.IsFullScreen=bool.Parse( MonkeyConfig.XNA_WINDOW_FULLSCREEN_XBOX );
		deviceManager.PreferredBackBufferWidth=int.Parse( MonkeyConfig.XNA_WINDOW_WIDTH_XBOX );
		deviceManager.PreferredBackBufferHeight=int.Parse( MonkeyConfig.XNA_WINDOW_HEIGHT_XBOX );
#elif WINDOWS_PHONE
		deviceManager.IsFullScreen=bool.Parse( MonkeyConfig.XNA_WINDOW_FULLSCREEN_PHONE );
		deviceManager.PreferredBackBufferWidth=int.Parse( MonkeyConfig.XNA_WINDOW_WIDTH_PHONE );
		deviceManager.PreferredBackBufferHeight=int.Parse( MonkeyConfig.XNA_WINDOW_HEIGHT_PHONE );
#endif
		IsMouseVisible=true;

		autoSuspend=bool.Parse( MonkeyConfig.MOJO_AUTO_SUSPEND_ENABLED );
	}
	
	void CheckActive(){
		//wait for first activation		
		if( !activated ){
			activated=IsActive;
			return;
		}
		
		if( autoSuspend ){
			if( IsActive ){
				app.InvokeOnResume();
			}else{
				app.InvokeOnSuspend();
			}
		}else{
			if( Window.ClientBounds.Width>0 && Window.ClientBounds.Height>0 ){
				app.InvokeOnResume();
			}else{
				app.InvokeOnSuspend();
			}
		}
	}

	protected override void LoadContent(){
		try{

			bb_.bbInit();

			bb_.bbMain();
			
			if( app!=null ) app.InvokeOnCreate();
		
		}catch( Exception ex ){

			Die( ex );
		}
	}
	
	protected override void Update( GameTime gameTime ){
		if( app==null ) return;
		
		CheckActive();
		
		app.Update( gameTime );

		base.Update( gameTime );
	}
	
	protected override bool BeginDraw(){
		return app!=null && !app.suspended && base.BeginDraw();
	}

	protected override void Draw( GameTime gameTime ){
		if( app==null ) return;
		
		CheckActive();
		
		app.Draw( gameTime );

		base.Draw( gameTime );
	}
	
#if !WINDOWS_PHONE
	public static void Main(){
		new gxtkGame().Run();
	}
#endif
	
	public void Die( Exception ex ){
		if( ex.Message.Length!=0 ){
			bb_std_lang.Print( "Monkey runtime error: "+ex.Message+"\n"+bb_std_lang.StackTrace() );
		}
		Exit();
	}
}

public class gxtkApp{

	public static gxtkGame game;

	public gxtkGraphics graphics;
	public gxtkInput input;
	public gxtkAudio audio;
	
	public int updateRate;
	public double nextUpdate;
	public double updatePeriod;
	
	public int startMillis;
	
	public bool suspended;
	
	public gxtkApp(){

		game.app=this;

		graphics=new gxtkGraphics();
		input=new gxtkInput();
		audio=new gxtkAudio();

		game.TargetElapsedTime=TimeSpan.FromSeconds( 1.0/10.0 );
		
		startMillis=System.Environment.TickCount;
	}

	public void Die( Exception ex ){
		game.Die( ex );
	}
	
	public void Update( GameTime gameTime ){
		int updates=0;
		for(;;){
			nextUpdate+=updatePeriod;
			InvokeOnUpdate();
			if( updateRate==0 ) break;
			
			if( nextUpdate>(double)System.Environment.TickCount ) break;
			
			if( ++updates==7 ){
				nextUpdate=(double)System.Environment.TickCount;
				break;
			}
		}
	}

	public void Draw( GameTime gameTime ){
		InvokeOnRender();
	}
	
	public void InvokeOnCreate(){
		try{
			OnCreate();
		}catch( Exception ex ){
			Die( ex );
		}
	}

	public void InvokeOnUpdate(){
		if( suspended || updateRate==0 ) return;
		
		try{
			input.BeginUpdate();
			OnUpdate();
			input.EndUpdate();
		}catch( Exception ex ){
			Die( ex );
		}
	}

	public void InvokeOnRender(){
		if( suspended ) return;
		
		try{
			graphics.BeginRender();
			OnRender();
			graphics.EndRender();
		}catch( Exception ex ){
			Die( ex );
		}
	}

	public void InvokeOnSuspend(){
		if( suspended ) return;
		
		try{
			suspended=true;
			OnSuspend();
			audio.OnSuspend();
		}catch( Exception ex ){
			Die( ex );
		}
	}

	public void InvokeOnResume(){
		if( !suspended ) return;
		
		try{
			audio.OnResume();
			OnResume();
			suspended=false;
		}catch( Exception ex ){
			Die( ex );
		}
	}

	//***** GXTK API *****
	
	public virtual gxtkGraphics GraphicsDevice(){
		return graphics;
	}
	
	public virtual gxtkInput InputDevice(){
		return input;
	}
	
	public virtual gxtkAudio AudioDevice(){
		return audio;
	}

	public virtual String AppTitle(){
		return "gxtkApp";
	}
	
	public virtual String LoadState(){
#if WINDOWS
		IsolatedStorageFile file=IsolatedStorageFile.GetUserStoreForAssembly();
#else
		IsolatedStorageFile file=IsolatedStorageFile.GetUserStoreForApplication();
#endif
		if( file==null ) return "";
		
		IsolatedStorageFileStream stream=file.OpenFile( "MonkeyState",FileMode.OpenOrCreate );
		if( stream==null ){
			return "";
		}

		StreamReader reader=new StreamReader( stream );
		String state=reader.ReadToEnd();
		reader.Close();
		
		return state;
	}
	
	public virtual int SaveState( String state ){
#if WINDOWS
		IsolatedStorageFile file=IsolatedStorageFile.GetUserStoreForAssembly();
#else
		IsolatedStorageFile file=IsolatedStorageFile.GetUserStoreForApplication();
#endif
		if( file==null ) return -1;
		
		IsolatedStorageFileStream stream=file.OpenFile( "MonkeyState",FileMode.Create );
		if( stream==null ){
			return -1;
		}

		StreamWriter writer=new StreamWriter( stream );
		writer.Write( state );
		writer.Close();
		
		return 0;
	}
	
	public virtual String LoadString( String path ){
		return MonkeyData.LoadString( path );
	}
	
	public virtual int SetUpdateRate( int hertz ){
		updateRate=hertz;

		if( updateRate!=0 ){
			updatePeriod=1000.0/(double)hertz;
			nextUpdate=(double)System.Environment.TickCount+updatePeriod;
			
			game.TargetElapsedTime=TimeSpan.FromTicks( (long)(10000000.0/(double)hertz+.5) );

		}else{
		
			game.TargetElapsedTime=TimeSpan.FromSeconds( 1.0/10.0 );
			
		}
		return 0;
	}
	
	public virtual int MilliSecs(){
		return System.Environment.TickCount-startMillis;
	}

	public virtual int Loading(){
		return 0;
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

	public GraphicsDevice device;
	
	RasterizerState rstateScissor;
	Rectangle scissorRect;
	
	BasicEffect effect;
	
	int primType;
	int primCount;
	gxtkSurface primSurf;

	VertexPositionColorTexture[] vertices;
	Int16[] quadIndices;
	Int16[] fanIndices;

	Color color;
	
	BlendState defaultBlend;
	BlendState additiveBlend;
	
	bool tformed=false;
	float ix,iy,jx,jy,tx,ty;
	
	public gxtkGraphics(){
	
		device=gxtkApp.game.GraphicsDevice;
		
		effect=new BasicEffect( device );
		effect.VertexColorEnabled=true;

		vertices=new VertexPositionColorTexture[ MAX_VERTS ];
		for( int i=0;i<MAX_VERTS;++i ){
			vertices[i]=new VertexPositionColorTexture();
		}
		
		quadIndices=new Int16[ MAX_QUADS * 6 ];
		for( int i=0;i<MAX_QUADS;++i ){
			quadIndices[i*6  ]=(short)(i*4);
			quadIndices[i*6+1]=(short)(i*4+1);
			quadIndices[i*6+2]=(short)(i*4+2);
			quadIndices[i*6+3]=(short)(i*4);
			quadIndices[i*6+4]=(short)(i*4+2);
			quadIndices[i*6+5]=(short)(i*4+3);
		}
		
		fanIndices=new Int16[ MAX_VERTS * 3 ];
		for( int i=0;i<MAX_VERTS;++i ){
			fanIndices[i*3  ]=(short)(0);
			fanIndices[i*3+1]=(short)(i+1);
			fanIndices[i*3+2]=(short)(i+2);
		}

		rstateScissor=new RasterizerState();
		rstateScissor.CullMode=CullMode.None;
		rstateScissor.ScissorTestEnable=true;
		
		defaultBlend=BlendState.NonPremultiplied;
		
		//note: ColorSourceBlend must == AlphaSourceBlend in Reach profile!
		additiveBlend=new BlendState();
		additiveBlend.ColorBlendFunction=BlendFunction.Add;
		additiveBlend.ColorSourceBlend=Blend.SourceAlpha;
		additiveBlend.AlphaSourceBlend=Blend.SourceAlpha;
		additiveBlend.ColorDestinationBlend=Blend.One;
		additiveBlend.AlphaDestinationBlend=Blend.One;
	}

	public void BeginRender(){
		device.RasterizerState=RasterizerState.CullNone;
		device.DepthStencilState=DepthStencilState.None;
		device.BlendState=BlendState.NonPremultiplied;
		if( bool.Parse( MonkeyConfig.MOJO_IMAGE_FILTERING_ENABLED ) ){
			device.SamplerStates[0]=SamplerState.LinearClamp;
		}else{
			device.SamplerStates[0]=SamplerState.PointClamp;
		}
		effect.Projection=Matrix.CreateOrthographicOffCenter( +.5f,Width()+.5f,Height()+.5f,+.5f,0,1 );
		primCount=0;
	}

	public void EndRender(){
		Flush();
	}
	
	public void Flush(){
		if( primCount==0 ) return;
		
		if( primSurf!=null ){
	        effect.TextureEnabled=true;
    	    effect.Texture=primSurf.texture;
		}else{
	        effect.TextureEnabled=false;
		}

        foreach( EffectPass pass in effect.CurrentTechnique.Passes ){
            pass.Apply();

            switch( primType ){
			case 2:	//lines
				device.DrawUserPrimitives<VertexPositionColorTexture>(
				PrimitiveType.LineList,
				vertices,0,primCount );
				break;
			case 4:	//quads
				device.DrawUserIndexedPrimitives<VertexPositionColorTexture>(
				PrimitiveType.TriangleList,
				vertices,0,primCount*4,
				quadIndices,0,primCount*2 );
				break;
			case 5:	//trifan
				device.DrawUserIndexedPrimitives<VertexPositionColorTexture>(
				PrimitiveType.TriangleList,
				vertices,0,primCount,
				fanIndices,0,primCount-2 );
				break;
            }
        }
		primCount=0;
	}
	
	//***** GXTK API *****
	
	public virtual int Mode(){
		return 1;
	}
	
	public virtual int Width(){
		return device.PresentationParameters.BackBufferWidth;
	}
	
	public virtual int Height(){
		return device.PresentationParameters.BackBufferHeight;
	}
	
	public virtual int Loaded(){
		return 1;
	}
	
	public virtual gxtkSurface LoadSurface( String path ){
		Texture2D texture=MonkeyData.LoadTexture2D( path,gxtkApp.game.Content );
		if( texture!=null ) return new gxtkSurface( texture,this );
		return null;
	}
	
	public virtual int SetAlpha( float alpha ){
		color.A=(byte)(alpha * 255);
		return 0;
	}

	public virtual int SetColor( float r,float g,float b ){
		color.R=(byte)r;
		color.G=(byte)g;
		color.B=(byte)b;
		return 0;
	}
	
	public virtual int SetBlend( int blend ){
		Flush();
	
		switch( blend ){
		case 1:
			device.BlendState=additiveBlend;
			break;
		default:
			device.BlendState=defaultBlend;
			break;
		}
		return 0;
	}
	
	public virtual int SetMatrix( float ix,float iy,float jx,float jy,float tx,float ty ){
	
		tformed=( ix!=1 || iy!=0 || jx!=0 || jy!=1 || tx!=0 || ty!=0 );
		
		this.ix=ix;this.iy=iy;
		this.jx=jx;this.jy=jy;
		this.tx=tx;this.ty=ty;

		return 0;
	}
	
	public virtual int SetScissor( int x,int y,int w,int h ){
		Flush();

		int r=Math.Min( x+w,Width() );
		int b=Math.Min( y+h,Height() );
		x=Math.Max( x,0 );
		y=Math.Max( y,0 );
		if( r>x && b>y ){
			w=r-x;
			h=b-y;
		}else{
			x=y=w=h=0;
		}
		
		if( x!=0 || y!=0 || w!=Width() || h!=Height() ){
			scissorRect.X=x;
			scissorRect.Y=y;
			scissorRect.Width=w;
			scissorRect.Height=h;
			device.RasterizerState=rstateScissor;
			device.ScissorRectangle=scissorRect;
		}else{
			device.RasterizerState=RasterizerState.CullNone;
		}
		
		return 0;
	}
	
	public virtual int Cls( float r,float g,float b ){

		if( device.RasterizerState.ScissorTestEnable ){

			Rectangle sr=device.ScissorRectangle;
			float x=sr.X,y=sr.Y,w=sr.Width,h=sr.Height;
			Color color=new Color( r/255.0f,g/255.0f,b/255.0f );
			
			primType=4;
			primCount=1;
			primSurf=null;

			vertices[0].Position.X=x  ;vertices[0].Position.Y=y  ;vertices[0].Color=color;
			vertices[1].Position.X=x+w;vertices[1].Position.Y=y  ;vertices[1].Color=color;
			vertices[2].Position.X=x+w;vertices[2].Position.Y=y+h;vertices[2].Color=color;
			vertices[3].Position.X=x  ;vertices[3].Position.Y=y+h;vertices[3].Color=color;
		}else{
			primCount=0;
			device.Clear( new Color( r/255.0f,g/255.0f,b/255.0f ) );
		}
		return 0;
	}

	public virtual int DrawPoint( float x,float y ){
		if( primType!=4 || primCount==MAX_QUADS || primSurf!=null ){
			Flush();
			primType=4;
			primSurf=null;
		}
		
		if( tformed ){
			float px=x;
			x=px * ix + y * jx + tx;
			y=px * iy + y * jy + ty;
		}

		int vp=primCount++*4;
				
		vertices[vp  ].Position.X=x;vertices[vp  ].Position.Y=y;
		vertices[vp  ].Color=color;
		vertices[vp+1].Position.X=x+1;vertices[vp+1].Position.Y=y;
		vertices[vp+1].Color=color;
		vertices[vp+2].Position.X=x+1;vertices[vp+2].Position.Y=y+1;
		vertices[vp+2].Color=color;
		vertices[vp+3].Position.X=x;vertices[vp+3].Position.Y=y+1;
		vertices[vp+3].Color=color;
		
		return 0;
	}
	
	public virtual int DrawRect( float x,float y,float w,float h ){
		if( primType!=4 || primCount==MAX_QUADS || primSurf!=null ){
			Flush();
			primType=4;
			primSurf=null;
		}
		
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

		int vp=primCount++*4;
				
		vertices[vp  ].Position.X=x0;vertices[vp  ].Position.Y=y0;
		vertices[vp  ].Color=color;
		vertices[vp+1].Position.X=x1;vertices[vp+1].Position.Y=y1;
		vertices[vp+1].Color=color;
		vertices[vp+2].Position.X=x2;vertices[vp+2].Position.Y=y2;
		vertices[vp+2].Color=color;
		vertices[vp+3].Position.X=x3;vertices[vp+3].Position.Y=y3;
		vertices[vp+3].Color=color;
		
		return 0;
	}

	public virtual int DrawLine( float x0,float y0,float x1,float y1 ){
		if( primType!=2 || primCount==MAX_LINES || primSurf!=null ){
			Flush();
			primType=2;
			primSurf=null;
		}
		
		if( tformed ){
			float tx0=x0,tx1=x1;
			x0=tx0 * ix + y0 * jx + tx;
			y0=tx0 * iy + y0 * jy + ty;
			x1=tx1 * ix + y1 * jx + tx;
			y1=tx1 * iy + y1 * jy + ty;
		}
		
		int vp=primCount++*2;
		
		vertices[vp  ].Position.X=x0;vertices[vp  ].Position.Y=y0;
		vertices[vp  ].Color=color;
		vertices[vp+1].Position.X=x1;vertices[vp+1].Position.Y=y1;
		vertices[vp+1].Color=color;
		
		return 0;
	}

	public virtual int DrawOval( float x,float y,float w,float h ){
		Flush();
		primType=5;
		primSurf=null;
		
		float xr=w/2.0f;
		float yr=h/2.0f;

		int segs;
		if( tformed ){
			float dx_x=xr * ix;
			float dx_y=xr * iy;
			float dx=(float)Math.Sqrt( dx_x*dx_x+dx_y*dx_y );
			float dy_x=yr * jx;
			float dy_y=yr * jy;
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
			
			if( tformed ){
				float ppx=px;
				px=ppx * ix + py * jx + tx;
				py=ppx * iy + py * jy + ty;
			}
			
			vertices[i].Position.X=px;vertices[i].Position.Y=py;
			vertices[i].Color=color;
		}
		
		primCount=segs;

		Flush();
		
		return 0;
	}
	
	public virtual int DrawPoly( float[] verts ){
		int n=verts.Length/2;
		if( n<3 || n>MAX_VERTS ) return 0;
		
		Flush();
		primType=5;
		primSurf=null;
		
		for( int i=0;i<n;++i ){
		
			float px=verts[i*2];
			float py=verts[i*2+1];
			
			if( tformed ){
				float ppx=px;
				px=ppx * ix + py * jx + tx;
				py=ppx * iy + py * jy + ty;
			}
			
			vertices[i].Position.X=px;vertices[i].Position.Y=py;
			vertices[i].Color=color;
		}

		primCount=n;
		
		Flush();
		
		return 0;
	}

	public virtual int DrawSurface( gxtkSurface surf,float x,float y ){
		if( primType!=4 || primCount==MAX_QUADS || surf!=primSurf ){
			Flush();
			primType=4;
			primSurf=surf;
		}
		
		float w=surf.Width();
		float h=surf.Height();
		float u0=0,u1=1,v0=0,v1=1;
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

		int vp=primCount++*4;
				
		vertices[vp  ].Position.X=x0;vertices[vp  ].Position.Y=y0;
		vertices[vp  ].TextureCoordinate.X=u0;vertices[vp  ].TextureCoordinate.Y=v0;
		vertices[vp  ].Color=color;
		vertices[vp+1].Position.X=x1;vertices[vp+1].Position.Y=y1;
		vertices[vp+1].TextureCoordinate.X=u1;vertices[vp+1].TextureCoordinate.Y=v0;
		vertices[vp+1 ].Color=color;
		vertices[vp+2].Position.X=x2;vertices[vp+2].Position.Y=y2;
		vertices[vp+2].TextureCoordinate.X=u1;vertices[vp+2].TextureCoordinate.Y=v1;
		vertices[vp+2].Color=color;
		vertices[vp+3].Position.X=x3;vertices[vp+3].Position.Y=y3;
		vertices[vp+3].TextureCoordinate.X=u0;vertices[vp+3].TextureCoordinate.Y=v1;
		vertices[vp+3].Color=color;
		
		return 0;
	}

	public virtual int DrawSurface2( gxtkSurface surf,float x,float y,int srcx,int srcy,int srcw,int srch ){
		if( primType!=4 || primCount==MAX_QUADS || surf!=primSurf ){
			Flush();
			primType=4;
			primSurf=surf;
		}
		
		float w=surf.Width();
		float h=surf.Height();
		float u0=srcx/w,u1=(srcx+srcw)/w;
		float v0=srcy/h,v1=(srcy+srch)/h;
		float x0=x,x1=x+srcw,x2=x+srcw,x3=x;
		float y0=y,y1=y,y2=y+srch,y3=y+srch;
		
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

		int vp=primCount++*4;
				
		vertices[vp  ].Position.X=x0;vertices[vp  ].Position.Y=y0;
		vertices[vp  ].TextureCoordinate.X=u0;vertices[vp  ].TextureCoordinate.Y=v0;
		vertices[vp  ].Color=color;
		vertices[vp+1].Position.X=x1;vertices[vp+1].Position.Y=y1;
		vertices[vp+1].TextureCoordinate.X=u1;vertices[vp+1].TextureCoordinate.Y=v0;
		vertices[vp+1 ].Color=color;
		vertices[vp+2].Position.X=x2;vertices[vp+2].Position.Y=y2;
		vertices[vp+2].TextureCoordinate.X=u1;vertices[vp+2].TextureCoordinate.Y=v1;
		vertices[vp+2].Color=color;
		vertices[vp+3].Position.X=x3;vertices[vp+3].Position.Y=y3;
		vertices[vp+3].TextureCoordinate.X=u0;vertices[vp+3].TextureCoordinate.Y=v1;
		vertices[vp+3].Color=color;
		
		return 0;
	}
}

//***** gxtkSurface *****

public class gxtkSurface{
	public Texture2D texture;
	public gxtkGraphics graphics;

	public gxtkSurface( Texture2D texture,gxtkGraphics graphics ){
		this.texture=texture;
		this.graphics=graphics;
	}
	
	//***** GXTK API *****
	
	public virtual int Discard(){
		texture=null;
		return 0;
	}
	
	public virtual int Width(){
		return texture.Width;
	}
	
	public virtual int Height(){
		return texture.Height;
	}
	
	public virtual int Loaded(){
		return 1;
	}
}

public class gxtkInput{

	public bool shift,control;
	
	public int[] keyStates=new int[512];
	
	public int charPut=0;
	public int charGet=0;
	public int[] charQueue=new int[32];
	
	public float mouseX;
	public float mouseY;
	
	public GamePadState gamepadState;
	
	public int[] touches=new int[32];
	public float[] touchX=new float[32];
	public float[] touchY=new float[32];
	
	public float accelX;
	public float accelY;
	public float accelZ;
	
#if WINDOWS_PHONE
	public Accelerometer accelerometer;
	public bool keyboardEnabled=true;
	public bool gamepadEnabled=true;	//for back button mainly!
	public bool mouseEnabled=false;
	public bool touchEnabled=true;
	public bool gamepadFound=true;
	public PlayerIndex gamepadIndex=PlayerIndex.One;
#else
	public bool keyboardEnabled=true;
	public bool gamepadEnabled=true;
	public bool mouseEnabled=true;
	public bool touchEnabled=false;
	public bool gamepadFound=false;
	public PlayerIndex gamepadIndex;
#endif
	
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
	
#if WINDOWS_PHONE
	public gxtkInput(){
		if( bool.Parse( MonkeyConfig.XNA_ACCELEROMETER_ENABLED ) ){
			accelerometer=new Accelerometer();
			if( accelerometer.State!=SensorState.NotSupported ){
				accelerometer.ReadingChanged+=OnAccelerometerReadingChanged;
				accelerometer.Start();
			}
        }
	}

	private void OnAccelerometerReadingChanged( object sender,AccelerometerReadingEventArgs e ){
		accelX=(float)e.X;
		accelY=(float)e.Y;
		accelZ=(float)e.Z;
    }		
#endif
	
	public int KeyToChar( int key ){
		if( key==8 || key==9 || key==13 || key==27 || key==32 ){
			return key;
		}else if( key==46 ){
			return 127;
		}else if( key>=48 && key<=57 && !shift ){
			return key;
		}else if( key>=65 && key<=90 && !shift ){
			return key+32;
		}else if( key>=65 && key<=90 && shift ){
			return key;
		}else if( key>=33 && key<=40 || key==45 ){
			return key | 0x10000;
		}
		return 0;
	}
	
	public void BeginUpdate(){

	
		//***** Update keyboard *****
		//
		if( keyboardEnabled ){

			KeyboardState keyboardState=Keyboard.GetState();
			
			shift=keyboardState.IsKeyDown( Keys.LeftShift ) || keyboardState.IsKeyDown( Keys.RightShift );
			control=keyboardState.IsKeyDown( Keys.LeftControl ) || keyboardState.IsKeyDown( Keys.RightControl );
			
			OnKey( KEY_SHIFT,shift );
			OnKey( KEY_CONTROL,control );

			for( int i=8;i<256;++i ){
				if( i==KEY_SHIFT || i==KEY_CONTROL ) continue;
				OnKey( i,keyboardState.IsKeyDown( (Keys)i ) );
			}
		}
		
		//***** Update gamepad *****
		//
		if( gamepadEnabled ){
			if( gamepadFound ){
				gamepadState=GamePad.GetState( gamepadIndex );
				PollGamepadState();
			}else{
				for( PlayerIndex i=PlayerIndex.One;i<=PlayerIndex.Four;++i ){
					GamePadState g=GamePad.GetState( i );
					if( !g.IsConnected ) continue;
					ButtonState p=ButtonState.Pressed;
					if( 
					g.Buttons.A==p ||
					g.Buttons.B==p ||
					g.Buttons.X==p ||
					g.Buttons.Y==p ||
					g.Buttons.LeftShoulder==p ||
					g.Buttons.RightShoulder==p ||
					g.Buttons.Back==p ||
					g.Buttons.Start==p ||
					g.DPad.Left==p ||
					g.DPad.Up==p ||
					g.DPad.Right==p ||
					g.DPad.Down==p ){
						gamepadFound=true;
						gamepadIndex=i;
						gamepadState=g;
						PollGamepadState();
						break;
					}
				}
			}
		}

		//***** Update mouse *****
		//
		if( mouseEnabled ){

			MouseState mouseState=Mouse.GetState();
			
			OnKey( KEY_LMB,mouseState.LeftButton==ButtonState.Pressed );
			OnKey( KEY_RMB,mouseState.RightButton==ButtonState.Pressed );
			OnKey( KEY_MMB,mouseState.MiddleButton==ButtonState.Pressed );
			
			mouseX=mouseState.X;
			mouseY=mouseState.Y;
			if( !touchEnabled ){
				touchX[0]=mouseX;
				touchY[0]=mouseY;
			}
		}
		
		//***** Update touch *****
		//
		if( touchEnabled ){
#if WINDOWS_PHONE
			TouchCollection touchCollection=TouchPanel.GetState();
			foreach( TouchLocation tl in touchCollection ){
			
				if( tl.State==TouchLocationState.Invalid ) continue;
			
				int touch=tl.Id;
				
				int pid;
				for( pid=0;pid<32 && touches[pid]!=touch;++pid ){}
	
				switch( tl.State ){
				case TouchLocationState.Pressed:
					if( pid!=32 ){ pid=32;break; }
					for( pid=0;pid<32 && touches[pid]!=0;++pid ){}
					if( pid==32 ) break;
					touches[pid]=touch;
					OnKeyDown( KEY_TOUCH0+pid );
//					keyStates[KEY_TOUCH0+pid]=0x101;
					break;
				case TouchLocationState.Moved:
					break;
				case TouchLocationState.Released:
					if( pid==32 ) break;
					touches[pid]=0;
					OnKeyUp( KEY_TOUCH0+pid );
//					keyStates[KEY_TOUCH0+pid]=0;
					break;
				}
				if( pid==32 ){
					//ERROR!
					continue;
				}
				Vector2 p=tl.Position;
				touchX[pid]=p.X;
				touchY[pid]=p.Y;
				if( pid==0 && !mouseEnabled ){
					mouseX=p.X;
					mouseY=p.Y;
				}
			}
#endif			
		}
	}
	
	public void PollGamepadState(){
		OnKey( KEY_JOY0_A,gamepadState.Buttons.A==ButtonState.Pressed );
		OnKey( KEY_JOY0_B,gamepadState.Buttons.B==ButtonState.Pressed );
		OnKey( KEY_JOY0_X,gamepadState.Buttons.X==ButtonState.Pressed );
		OnKey( KEY_JOY0_Y,gamepadState.Buttons.Y==ButtonState.Pressed );
		OnKey( KEY_JOY0_LB,gamepadState.Buttons.LeftShoulder==ButtonState.Pressed );
		OnKey( KEY_JOY0_RB,gamepadState.Buttons.RightShoulder==ButtonState.Pressed );
		OnKey( KEY_JOY0_BACK,gamepadState.Buttons.Back==ButtonState.Pressed );
		OnKey( KEY_JOY0_START,gamepadState.Buttons.Start==ButtonState.Pressed );
		OnKey( KEY_JOY0_LEFT,gamepadState.DPad.Left==ButtonState.Pressed );
		OnKey( KEY_JOY0_UP,gamepadState.DPad.Up==ButtonState.Pressed );
		OnKey( KEY_JOY0_RIGHT,gamepadState.DPad.Right==ButtonState.Pressed );
		OnKey( KEY_JOY0_DOWN,gamepadState.DPad.Down==ButtonState.Pressed );
	}
	
	public void EndUpdate(){
		for( int i=0;i<512;++i ){
			keyStates[i]&=0x100;
		}
		charGet=0;
		charPut=0;
	}
	
	public virtual void OnKey( int key,bool down ){
		if( down ){
			OnKeyDown( key );
		}else{
			OnKeyUp( key );
		}
	}
	
	public virtual void OnKeyDown( int key ){
		if( (keyStates[key] & 0x100)!=0 ) return;
		
		keyStates[key]|=0x100;
		++keyStates[key];
		
		int chr=KeyToChar( key );
		if( chr!=0 ) PutChar( chr );

		if( key==KEY_LMB && !touchEnabled ){
			this.keyStates[KEY_TOUCH0]|=0x100;
			++this.keyStates[KEY_TOUCH0];
		}else if( key==KEY_TOUCH0 && !mouseEnabled ){
			this.keyStates[KEY_LMB]|=0x100;
			++this.keyStates[KEY_LMB];
		}
	}
	
	public virtual void OnKeyUp( int key ){
		if( (keyStates[key] & 0x100)==0 ) return;
		
		keyStates[key]&=0xff;

		if( key==KEY_LMB && !touchEnabled ){
			this.keyStates[KEY_TOUCH0]&=0xff;
		}else if( key==KEY_TOUCH0 && !mouseEnabled ){
			this.keyStates[KEY_LMB]&=0xff;
		}
	}
	
	public virtual void PutChar( int chr ){
		if( charPut!=32 ){
			charQueue[charPut++]=chr;
		}
	}

	//***** GXTK API *****
	
	public virtual int SetKeyboardEnabled( int enabled ){
#if WINDOWS
		return 0;	//keyboard present on windows
#else
		return -1;	//no keyboard support on XBOX/PHONE
#endif
	}
	
	public virtual int KeyDown( int key ){
		if( key>0 && key<512 ){
			return keyStates[key]>>8;
		}
		return 0;
	}
	
	public virtual int KeyHit( int key ){
		if( key>0 && key<512 ){
			return keyStates[key] & 0xff;
		}
		return 0;
	}
	
	public virtual int GetChar(){
		if( charGet!=charPut ){
			return charQueue[charGet++];
		}
		return 0;
	}
	
	public virtual float MouseX(){
		return mouseX;
	}
	
	public virtual float MouseY(){
		return mouseY;
	}

	public virtual float JoyX( int index ){
		switch( index ){
		case 0:return gamepadState.ThumbSticks.Left.X;
		case 1:return gamepadState.ThumbSticks.Right.X;
		}
		return 0;
	}
	
	public virtual float JoyY( int index ){
		switch( index ){
		case 0:return gamepadState.ThumbSticks.Left.Y;
		case 1:return gamepadState.ThumbSticks.Right.Y;
		}
		return 0;
	}
	
	public virtual float JoyZ( int index ){
		switch( index ){
		case 0:return gamepadState.Triggers.Left;
		case 1:return gamepadState.Triggers.Right;
		}
		return 0;
	}
	
	public virtual float TouchX( int index ){
		return touchX[index];
	}

	public virtual float TouchY( int index ){
		return touchY[index];
	}
	
	public virtual float AccelX(){
		return accelX;
	}

	public virtual float AccelY(){
		return accelY;
	}

	public virtual float AccelZ(){
		return accelZ;
	}
}

public class gxtkChannel{
	public gxtkSample sample;
	public SoundEffectInstance inst;
	public float volume=1;
	public float pan=0;
	public float rate=1;
	public int state=0;
};

public class gxtkAudio{

	public bool musicEnabled;

	public gxtkChannel[] channels=new gxtkChannel[33];
	
	public void OnSuspend(){
		for( int i=0;i<33;++i ){
			if( channels[i].state==1 ) channels[i].inst.Pause();
		}
	}
	
	public void OnResume(){
		for( int i=0;i<33;++i ){
			if( channels[i].state==1 ) channels[i].inst.Resume();
		}
	}

	//***** GXTK API *****
	//
	public gxtkAudio(){
		musicEnabled=MediaPlayer.GameHasControl;
		
		for( int i=0;i<33;++i ){
			channels[i]=new gxtkChannel();
		}
	}
	
	public virtual gxtkSample LoadSample( String path ){
		SoundEffect sound=MonkeyData.LoadSoundEffect( path,gxtkApp.game.Content );
		if( sound!=null ) return new gxtkSample( sound );
		return null;
	}
	
	public virtual int PlaySample( gxtkSample sample,int channel,int flags ){
		gxtkChannel chan=channels[channel];

		SoundEffectInstance inst=null;
		
		if( chan.state!=0 ){
			chan.inst.Stop();
			chan.state=0;
		}
		inst=sample.AllocInstance( (flags&1)!=0 );
		if( inst==null ) return -1;
		
		for( int i=0;i<33;++i ){
			gxtkChannel chan2=channels[i];
			if( chan2.inst==inst ){
				chan2.sample=null;
				chan2.inst=null;
				chan2.state=0;
				break;
			}
		}
		
		inst.Volume=chan.volume;
		inst.Pan=chan.pan;
		inst.Pitch=(float)( Math.Log(chan.rate)/Math.Log(2) );
		inst.Play();

		chan.sample=sample;
		chan.inst=inst;
		chan.state=1;
		return 0;
	}
	
	public virtual int StopChannel( int channel ){
		gxtkChannel chan=channels[channel];
		
		if( chan.state!=0 ){
			chan.inst.Stop();
			chan.state=0;
		}
		return 0;
	}
	
	public virtual int PauseChannel( int channel ){
		gxtkChannel chan=channels[channel];
		
		if( chan.state==1 ){
			chan.inst.Pause();
			chan.state=2;
		}
		return 0;
	}
	
	public virtual int ResumeChannel( int channel ){
		gxtkChannel chan=channels[channel];
		
		if( chan.state==2 ){
			chan.inst.Resume();
			chan.state=1;
		}
		return 0;
	}
	
	public virtual int ChannelState( int channel ){
		gxtkChannel chan=channels[channel];
		
		if( chan.state==1 ){
			if( chan.inst.State!=SoundState.Playing ) chan.state=0;
		}
		
		return chan.state;
	}
	
	public virtual int SetVolume( int channel,float volume ){
		gxtkChannel chan=channels[channel];
		
		if( chan.state!=0 ) chan.inst.Volume=volume;
		
		chan.volume=volume;
		return 0;
	}
	
	public virtual int SetPan( int channel,float pan ){
		gxtkChannel chan=channels[channel];
		
		if( chan.state!=0 ) chan.inst.Pan=pan;
		
		chan.pan=pan;
		return 0;
	}
	
	public virtual int SetRate( int channel,float rate ){
		gxtkChannel chan=channels[channel];
		
		if( chan.state!=0 ) chan.inst.Pitch=(float)( Math.Log(rate)/Math.Log(2) );
		
		chan.rate=rate;
		return 0;
	}
	
	public virtual int PlayMusic( String path,int flags ){
		if( !musicEnabled ) return -1;
		
		MediaPlayer.Stop();
		
		Song song=MonkeyData.LoadSong( path,gxtkApp.game.Content );
		if( song==null ) return -1;
		
		if( (flags&1)!=0 ) MediaPlayer.IsRepeating=true;
		
		MediaPlayer.Play( song );
		return 0;
	}
	
	public virtual int StopMusic(){
		if( !musicEnabled ) return -1;
		
		MediaPlayer.Stop();
		return 0;
	}
	
	public virtual int PauseMusic(){
		if( !musicEnabled ) return -1;
		
		MediaPlayer.Pause();
		return 0;
	}
	
	public virtual int ResumeMusic(){
		if( !musicEnabled ) return -1;
		
		MediaPlayer.Resume();
		return 0;
	}
	
	public virtual int MusicState(){
		if( !musicEnabled ) return -1;
		
		return MediaPlayer.State==MediaState.Playing ? 1 : 0;
	}
	
	public virtual int SetMusicVolume( float volume ){
		if( !musicEnabled ) return -1;
		
		MediaPlayer.Volume=volume;
		return 0;
	}
}

public class gxtkSample{

	public SoundEffect sound;
	
	//first 8 non-looped, second 8 looped.
	public SoundEffectInstance[] insts=new SoundEffectInstance[16];	
	
	public gxtkSample( SoundEffect sound ){
		this.sound=sound;
	}

	public SoundEffectInstance AllocInstance( bool looped ){
		int st=looped ? 8 : 0;
		for( int i=st;i<st+8;++i ){
			SoundEffectInstance inst=insts[i];
			if( inst!=null ){
				if( inst.State!=SoundState.Playing ) return inst;
			}else{
				inst=sound.CreateInstance();
				inst.IsLooped=looped;
				insts[i]=inst;
				return inst;
			}
		}
		return null;
	}

	public virtual int Discard(){	
		if( sound!=null ){
			sound=null;
			for( int i=0;i<16;++i ){
				insts[i]=null;
			}
		}
		return 0;
	}	
}
