Strict

Private

Import mojo
Import scenemanager
Import vector2d

Global globalGameInstance:Game

Public

Function CurrentGame:Game()
    If Not globalGameInstance Then globalGameInstance = New Game()
    Return globalGameInstance
End

Function CurrentGameReset:Void()
    globalGameInstance = Null
End

Class Game Extends App
    Field scenes:SceneManager = New SceneManager()
    Field center:Vector2D
    Field device:Vector2D
    Field scale:Vector2D
    Field size:Vector2D

    Method New()
        size = New Vector2D(640, 960)
        center = size.Copy().Div(2)
    End

    Method OnCreate:Int()
        SetUpdateRate(30)
        device = New Vector2D(DeviceWidth(), DeviceHeight())
        scale = device.Copy().Div(size)
        Return 0
    End

    Method OnLoading:Int()
        If scenes.current Then scenes.current.OnLoading()
        Return 0
    End

    Method OnUpdate:Int()
        If scenes.current Then scenes.current.OnUpdate()
        Return 0
    End

    Method OnResume:Int()
        If scenes.current Then scenes.current.OnResume()
        Return 0
    End

    Method OnSuspend:Int()
        If scenes.current Then scenes.current.OnSuspend()
        Return 0
    End

    Method OnRender:Int()
        Scale(scale.x, scale.y)
        If scenes.current Then scenes.current.OnRender()
        Return 0
    End

    Method Run:Void()
        If Not scenes.current Then Error("No scenes found!")
        scenes.Goto(scenes.current.name)
    End
End
