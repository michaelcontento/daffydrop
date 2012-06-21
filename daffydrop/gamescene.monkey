Strict

Private

Import mojo
Import bono
Import chute
Import shape
Import severity
Import slider

Public

Class GameScene Extends Scene
    Private

    Field severity:Severity
    Field chute:Chute
    Field slider:Slider
    Field upperShapes:Layer
    Field lowerShapes:Layer
    Field errorAnimations:Layer
    Field score:Int
    Field gameOver:Bool
    Field font:AngelFont = New AngelFont()

    Public

    Method New()
        name = "game"
        font.LoadFont("CoRa")
    End

    Method OnCreate:Void()
        chute = New Chute()
        lowerShapes = New Layer()
        severity = CurrentSeverity()
        slider = New Slider()
        upperShapes = New Layer()
        errorAnimations = New Layer()

        layer.Clear()
        layer.Add(New Sprite("bg_960x640.png"))
        layer.Add(lowerShapes)
        layer.Add(slider)
        layer.Add(upperShapes)
        layer.Add(errorAnimations)
        layer.Add(chute)
    End

    Method OnEnter:Void()
        score = 0
        gameOver = False

        lowerShapes.Clear()
        upperShapes.Clear()
        severity.Restart()
        chute.Restart()
    End

    Method OnUpdate:Void()
        Super.OnUpdate()

        If gameOver Then Return
        CheckForGameOver()

        severity.OnUpdate()
        RemoveLostShapes()
        RemoveFinishedErroAnimations()
        CheckShapeCollisions()
        DropNewShapeIfRequested()

        If KeyDown(KEY_B)
            CurrentDirector().scenes.Goto("menu")
        End
    End

    Method OnRender:Void()
        Super.OnRender()
        OnRenderScore()
        If gameOver Then OnRenderGameOver()
    End

    Private

    Method OnRenderScore:Void()
        font.DrawText("Score: " + score,
            CurrentDirector().center.x,
            CurrentDirector().size.y - 50,
            AngelFont.ALIGN_CENTER)
    End

    Method OnRenderGameOver:Void()
    End

    Method CheckForGameOver:Void()
        Local sliderHeight:Int = CurrentDirector().size.y - slider.images[0].Height() - 40
        gameOver = (chute.Height() >= sliderHeight)
    End

    Method RemoveLostShapes:Void()
        Local directoySizeY:Int = CurrentDirector().size.y
        Local shape:Shape

        For Local obj:Animationable = EachIn lowerShapes
            shape = Shape(obj)
            If shape.pos.y > directoySizeY Then lowerShapes.Remove(shape)
        End
    End

    Method RemoveFinishedErroAnimations:Void()
        Local sprite:Sprite
        For Local obj:Animationable = EachIn errorAnimations
            sprite = Sprite(obj)
            If sprite.AnimationIsDone() Then errorAnimations.Remove(sprite)
        End
    End

    Method DropNewShapeIfRequested:Void()
        If Not severity.ShapeShouldBeDropped() Then Return
        upperShapes.Add(New Shape(RandomType(), RandomLane(), chute))
        severity.ShapeDropped()
    End

    Method CheckShapeCollisions:Void()
        Local checkPosY:Int = CurrentDirector().size.y - (slider.images[0].Height() / 2) - 15
        Local shape:Shape
        Local match:Bool

        For Local obj:Animationable = EachIn upperShapes
            shape = Shape(obj)
            match = slider.Match(shape)

            If match And KeyDown(KEY_DOWN) Then shape.isFast = True
            If shape.pos.y + shape.images[0].Height() < checkPosY Then Continue

            upperShapes.Remove(shape)
            If Not match
                OnMissmatch(shape)
            Else
                lowerShapes.Add(shape)
                OnMatch(shape)
            End
        End
    End

    Method OnMatch:Void(shape:Shape)
        score += 10
    End

    Method OnMissmatch:Void(shape:Shape)
        errorAnimations.Add(New Sprite("false.png", 140, 88, 6, 100, shape.pos))
    End

    Method RandomType:Int()
        Return Int(Rnd() * 10) Mod 4
    End

    Method RandomLane:Int()
        Return Int(Rnd() * 10) Mod 4
    End
End
