Strict

Import animationable
Import animationablepool

Class Scene Implements Animationable Abstract
    Field name:String
    Field pool:AnimationablePool

    Method New()
        pool = New AnimationablePool()
        name = OnCreate()

        If name.Length() = 0
            Error("Scenes need to return a name in OnCreate()")
        End
    End

    Method OnCreate:String() Abstract

    Method OnLoading:Void()
    End

    Method OnUpdate:Void()
        pool.OnUpdate()
    End

    Method OnRender:Void()
        pool.OnRender()
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
