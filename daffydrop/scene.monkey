Strict

Private

Import bono

Public

Class Scene Extends Partial
    Private

    Field _layer:FanOut = New FanOut()

    Public

    Method OnCreate:Void(director:Director)
        Super.OnCreate(director)
        _layer.OnCreate(director)
    End

    Method OnLoading:Void()
        Super.OnLoading()
        _layer.OnLoading()
    End

    Method OnUpdate:Void(delta:Float, frameTime:Float)
        Super.OnUpdate(delta, frameTime)
        _layer.OnUpdate(delta, frameTime)
    End

    Method OnRender:Void()
        Super.OnRender()
        _layer.OnRender()
    End

    Method OnSuspend:Void()
        Super.OnSuspend()
        _layer.OnSuspend()
    End

    Method OnResume:Void(delta:Int)
        Super.OnResume(delta)
        _layer.OnResume(delta)
    End

    Method OnKeyDown:Void(event:KeyEvent)
        Super.OnKeyDown(event)
        _layer.OnKeyDown(event)
    End

    Method OnKeyPress:Void(event:KeyEvent)
        Super.OnKeyPress(event)
        _layer.OnKeyPress(event)
    End

    Method OnKeyUp:Void(event:KeyEvent)
        Super.OnKeyUp(event)
        _layer.OnKeyUp(event)
    End

    Method OnTouchDown:Void(event:TouchEvent)
        Super.OnTouchDown(event)
        _layer.OnTouchDown(event)
    End

    Method OnTouchMove:Void(event:TouchEvent)
        Super.OnTouchMove(event)
        _layer.OnTouchMove(event)
    End

    Method OnTouchUp:Void(event:TouchEvent)
        Super.OnTouchUp(event)
        _layer.OnTouchUp(event)
    End

    Method layer:FanOut() Property
        Return _layer
    End
End
