Strict

Import animationable
Import layer

Class Scene Implements Animationable Abstract
    Field name:String
    Field layer:Layer

    Method New()
        layer = New Layer()
        name = OnCreate()

        If name.Length() = 0
            Error("Scenes need to return a name in OnCreate()")
        End
    End

    Method OnCreate:String() Abstract

    Method OnLoading:Void()
    End

    Method OnUpdate:Void()
        layer.OnUpdate()
    End

    Method OnRender:Void()
        layer.OnRender()
    End

    Method OnResume:Void()
    End

    Method OnSuspend:Void()
    End

    Method OnEnter:Void()
    End

    Method OnLeave:Void()
    End
End
