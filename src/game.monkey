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
    Field sceneManager:SceneManager

    Method New()
        sceneManager = New SceneManager()
    End

    Method Width:Int()
        Return 640
    End

    Method Height:Int()
        Return 960
    End

    Method OnCreate:Int()
        SetUpdateRate(30)
        scaleFactorX = Float(DeviceWidth()) / Float(Width())
        scaleFactorY = Float(DeviceHeight()) / Float(Height())
        Return 0
    End

    Method OnUpdate:Int()
        If sceneManager.current Then sceneManager.current.OnUpdate()
        Return 0
    End

    Method OnResume:Int()
        If sceneManager.current Then sceneManager.current.OnResume()
        Return 0
    End

    Method OnSuspend:Int()
        If sceneManager.current Then sceneManager.current.OnSuspend()
        Return 0
    End

    Method OnRender:Int()
        Scale(scaleFactorX, scaleFactorY)
        If sceneManager.current Then sceneManager.current.OnRender()
        Return 0
    End

    Method Run:Void()
        If Not sceneManager.current Then Error("No scenes found!")
        sceneManager.current.OnEnter()
    End
End
