
' Module mojo.app
'
' Copyright 2011 Mark Sibly, all rights reserved.
' No warranty implied; use at your own risk.

Private

Import mojo.graphics
Import mojo.input
Import mojo.audio

Import "native/mojo.${TARGET}.${LANG}"

Extern Private

Class gxtkApp="gxtkApp"

	Method GraphicsDevice:GraphicsDevice()
	Method InputDevice:InputDevice()
	Method AudioDevice:AudioDevice()
	
	Method LoadState$()
	Method SaveState( state$ )
	
	Method LoadString$( path$ )
	
	Method SetUpdateRate( hertz )
	Method MilliSecs()

	Method OnCreate()
	Method OnUpdate()
	Method OnSuspend()
	Method OnResume()
	Method OnRender()
	Method OnLoading()

End

Private

Class AppDevice Extends gxtkApp

	Method New( app:App )
		Self.app=app
		SetGraphicsContext New GraphicsContext( GraphicsDevice() )
		SetInputDevice InputDevice()
		SetAudioDevice AudioDevice()
	End

	Method OnCreate()
		SetFont Null
		Return app.OnCreate()
	End

	Method OnUpdate()
		Return app.OnUpdate()
	End

	Method OnSuspend()
		Return app.OnSuspend()
	End
	
	Method OnResume()
		Return app.OnResume()
	End
	
	Method OnRender()
		BeginRender
		Local r=app.OnRender()
		EndRender
		Return r
	End

	Method OnLoading()
		BeginRender
		Local r=app.OnLoading()
		EndRender
		Return r
	End
	
	Method SetUpdateRate( hertz )
		Super.SetUpdateRate hertz
		updateRate=hertz
	End
	
	Method UpdateRate()
		Return updateRate
	End

Private

	Field app:App
	Field updateRate

End

Global device:AppDevice

Public

Class App

	Method New()
		device=New AppDevice( Self )
	End

	Method OnCreate()
	End

	Method OnUpdate()
	End
	
	Method OnSuspend()
	End
	
	Method OnResume()
	End

	Method OnRender()
	End

	Method OnLoading()
	End

End

Function LoadState$()
	Return device.LoadState()
End

Function SaveState( state$ )
	Return device.SaveState( state )
End

Function LoadString$( path$ )
	Return device.LoadString( path )
End

Function SetUpdateRate( hertz )
	Return device.SetUpdateRate( hertz )
End

Function UpdateRate()
	Return device.UpdateRate()
End

Function Millisecs()
	Return device.MilliSecs()
End
