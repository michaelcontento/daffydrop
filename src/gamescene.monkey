Strict

Import bono
Import chute
Import slider
Import shapemaster
Import severity

Class GameScene Extends Scene
    Field shapeMaster:ShapeMaster
    Field severity:Severity

    Method New()
        name = "game"
        severity = CurrentSeverity()
    End

    Method OnEnter:Void()
        Local chute:Chute = New Chute()
        Local slider:Slider = New Slider()
        shapeMaster = New ShapeMaster(chute, slider)

        layer.Add(New Sprite("bg_960x640.png"))
        layer.Add(shapeMaster)

        shapeMaster.Restart()
    End

    Method OnUpdate:Void()
        Super.OnUpdate()
        severity.OnUpdate()
    End
End
