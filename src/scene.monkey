Strict

Import gameobjectpool

Class Scene Abstract
    Field name:String
    Field pool:GameObjectPool

    Method New()
        pool = New GameObjectPool()
        name = OnCreate()
    End

    Method OnCreate:String() Abstract

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
