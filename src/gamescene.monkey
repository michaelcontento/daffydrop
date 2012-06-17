Strict

Import bono
Import chute
Import slider
Import shapemaster

Class GameScene Extends Scene
    Field shapeMaster:ShapeMaster

    Method New()
        name = "game"
    End

    Method OnEnter:Void()
        Local chute:Chute = New Chute()
        Local slider:Slider = New Slider()
        shapeMaster = New ShapeMaster(chute, slider)

        layer.Add(New Sprite("bg_960x640.png"))
        layer.Add(shapeMaster)

        shapeMaster.Restart()
    End
End
