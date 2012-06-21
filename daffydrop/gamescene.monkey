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

    Const COMBO_DETECT_DURATION:Int = 250
    Const COMBO_DISPLAY_DURATION:Int = 750
    Const COMBO_SCALE:Float = 150.0

    Field severity:Severity
    Field chute:Chute
    Field slider:Slider
    Field upperShapes:Layer
    Field lowerShapes:Layer
    Field errorAnimations:Layer
    Field score:Int
    Field gameOver:Bool
    Field font:AngelFont = New AngelFont()
    Field lastMatchTime:Int[] = [0, 0, 0, 0]
    Field lastComboCounter:Int
    Field lastComboTime:Int

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
        errorAnimations.Clear()
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
        DetectComboTrigger()
        DropNewShapeIfRequested()

        If KeyDown(KEY_B)
            CurrentDirector().scenes.Goto("menu")
        End
    End

    Method OnRender:Void()
        Super.OnRender()
        OnRenderScore()
        If gameOver Then OnRenderGameOver()
        OnRenderComboOverlay()
    End

    Private

    Method OnRenderScore:Void()
        font.DrawText("Score: " + score,
            CurrentDirector().center.x,
            CurrentDirector().size.y - 50,
            AngelFont.ALIGN_CENTER)
    End

    Method OnRenderComboOverlay:Void()
        If lastComboTime = 0 Then Return

        Local delta:Int = (lastComboTime + COMBO_DISPLAY_DURATION) - Millisecs()
        If delta < 0 Then
            lastComboTime = 0
            Return
        End

        Local scale:Float = COMBO_SCALE / COMBO_DISPLAY_DURATION * delta / 100.0
        PushMatrix()
            Translate(CurrentDirector().center.x, CurrentDirector().center.y)
            Scale(scale, scale)
            font.DrawText("COMBO x " + lastComboCounter, 0, 0, AngelFont.ALIGN_CENTER)
        PopMatrix()
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

    Method DetectComboTrigger:Void()
        Local lanesNotZero:Int
        Local charge:Bool
        Local now:Int = Millisecs()

        For Local lane:Int = 0 To lastMatchTime.Length() - 1
            If lastMatchTime[lane] = 0 Then Continue

            lanesNotZero += 1
            If lastMatchTime[lane] + COMBO_DETECT_DURATION < now
                charge = True
            End
        End

        If Not charge Then Return
        lastMatchTime = [0, 0, 0, 0]

        If lanesNotZero < 2 Then Return
        score += 10 * lanesNotZero
        lastComboTime = now
        lastComboCounter = lanesNotZero
    End

    Method OnMatch:Void(shape:Shape)
        lastMatchTime[shape.lane] = Millisecs()
        score += 10
    End

    Method OnMissmatch:Void(shape:Shape)
        lastMatchTime = [0, 0, 0, 0]
        errorAnimations.Add(New Sprite("false.png", 140, 88, 6, 100, shape.pos))
    End

    Method RandomType:Int()
        Return Int(Rnd() * 10) Mod 4
    End

    Method RandomLane:Int()
        Return Int(Rnd() * 10) Mod 4
    End
End
