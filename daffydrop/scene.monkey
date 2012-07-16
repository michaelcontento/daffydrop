Strict

Private

Import bono
Import mojo

Public

Class Scene Extends Partial Implements RouterEvents
    Private

    Field _layer:FanOut = New FanOut()
    Field _router:Router
    Global blend:Image

    Public

    Method RenderBlend:Void()
        For Local posY:Int = 0 Until director.size.y Step 8
            DrawImage(blend, 0, posY)
        End
    End

    Method OnEnter:Void()
    End

    Method OnLeave:Void()
    End

    Method OnCreate:Void(director:Director)
        Super.OnCreate(director)
        _layer.OnCreate(director)
        _router = Router(director.handler)

        If Not blend Then blend = LoadImage("blend.png")
    End

    Method OnLoading:Void()
        _layer.OnLoading()
    End

    Method OnUpdate:Void(delta:Float, frameTime:Float)
        _layer.OnUpdate(delta, frameTime)
    End

    Method OnRender:Void()
        _layer.OnRender()
    End

    Method OnSuspend:Void()
        _layer.OnSuspend()
    End

    Method OnResume:Void(delta:Int)
        _layer.OnResume(delta)
    End

    Method OnKeyDown:Void(event:KeyEvent)
        _layer.OnKeyDown(event)
    End

    Method OnKeyPress:Void(event:KeyEvent)
        _layer.OnKeyPress(event)
    End

    Method OnKeyUp:Void(event:KeyEvent)
        _layer.OnKeyUp(event)
    End

    Method OnTouchDown:Void(event:TouchEvent)
        _layer.OnTouchDown(event)
    End

    Method OnTouchMove:Void(event:TouchEvent)
        _layer.OnTouchMove(event)
    End

    Method OnTouchUp:Void(event:TouchEvent)
        _layer.OnTouchUp(event)
    End

    Method layer:FanOut() Property
        Return _layer
    End

    Method router:Router() Property
        Return _router
    End
End
