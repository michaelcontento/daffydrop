Strict

Import mojo.app
Import mojo.graphics

Import scenemanager

Global globalGameInstance:Game

Function CurrentGame:Game()
    If Not globalGameInstance Then globalGameInstance = New Game()
    Return globalGameInstance
End

Function CurrentGameReset:Void()
    globalGameInstance = Null
End

Class Game Extends App
    Field scenes:SceneManager

    Field scaleFactorX:Float
    Field scaleFactorY:Float

    Field WIDTH:Int = 640
    Field WIDTH2:Int = 320
    Field HEIGHT:Int = 960
    Field HEIGHT2:Int = 480

    Method New()
        scenes = New SceneManager()
    End

    Method OnCreate:Int()
        SetUpdateRate(30)
        scaleFactorX = Float(DeviceWidth()) / WIDTH
        scaleFactorY = Float(DeviceHeight()) / HEIGHT
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
        Scale(scaleFactorX, scaleFactorY)
        If scenes.current Then scenes.current.OnRender()
        Return 0
    End

    Method Run:Void()
        If Not scenes.current Then Error("No scenes found!")
        scenes.current.OnEnter()
    End
End
