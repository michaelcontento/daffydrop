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
    Field scaleFactorX:Float
    Field scaleFactorY:Float
    Field scenes:SceneManager

    Method New()
        scenes = New SceneManager()
    End

    Method Width:Int()
        Return 640
    End

    Method Height:Int()
        Return 960
    End

    Method Width2:Int()
        Return Width() / 2
    End

    Method Height2:Int()
        Return Height() / 2
    End

    Method OnCreate:Int()
        SetUpdateRate(30)
        scaleFactorX = Float(DeviceWidth()) / Float(Width())
        scaleFactorY = Float(DeviceHeight()) / Float(Height())
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
