Strict

Private

Import mojo.input
Import bono.scene
Import bono.sprite
Import bono.game
Import chute
Import severity
Import shapemaster
Import slider

Public

Class GameScene Extends Scene
    Field shapeMaster:ShapeMaster
    Field severity:Severity

    Method New()
        name = "game"
        severity = CurrentSeverity()
    End

    Method OnCreate:Void()
        shapeMaster = New ShapeMaster(New Chute(), New Slider())

        layer.Clear()
        layer.Add(New Sprite("bg_960x640.png"))
        layer.Add(shapeMaster)
    End

    Method OnEnter:Void()
        shapeMaster.Restart()
        severity.Restart()
    End

    Method OnUpdate:Void()
        Super.OnUpdate()
        severity.OnUpdate()

        If KeyDown(KEY_B)
            CurrentGame().scenes.Goto("menu")
        End
    End
End
