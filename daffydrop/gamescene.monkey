Strict

Private

Import mojo
Import bono
Import bono.vendor.angelfont
Import chute
Import shape
Import severity
Import slider
Import newhighscorescene

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
    Field font:AngelFont
    Field lastMatchTime:Int[] = [0, 0, 0, 0]
    Field lastComboCounter:Int
    Field lastComboTime:Int
    Field backButton:Sprite
    Field isNewHighscoreRecord:Bool
    Field minHighscore:Int
    Field pauseTime:Int

    Public

    Method New()
        name = "game"
    End

    Method OnCreate:Void()
        chute = New Chute()
        lowerShapes = New Layer()
        severity = CurrentSeverity()
        slider = New Slider(director)
        upperShapes = New Layer()
        errorAnimations = New Layer()

        font = New AngelFont("CoRa")
        LoadHighscoreMinValue()

        layer.Add(New Sprite("bg_960x640.png"))
        layer.Add(lowerShapes)
        layer.Add(slider)
        layer.Add(upperShapes)
        layer.Add(errorAnimations)
        layer.Add(chute)

        backButton = New Sprite("back.png")
        backButton.pos = director.size.Copy().Sub(backButton.size)
        layer.Add(backButton)
    End

    Method OnEnter:Void()
        If pauseTime > 0
            OnEnterPaused()
            Return
        End

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

        If KeyDown(KEY_B) Then scenes.Goto("menu")
        If KeyDown(KEY_DOWN) Then FastDropMatchingShapes()
        If KeyDown(KEY_LEFT) Then slider.SlideLeft()
        If KeyDown(KEY_RIGHT) Then slider.SlideRight()
    End

    Method OnRender:Void()
        Super.OnRender()

        OnRenderScore()
        If gameOver Then OnRenderGameOver()
        OnRenderComboOverlay()
    End

    Method OnTouchDown:Void(event:TouchEvent)
        If backButton.Collide(event.pos) Then scenes.Goto("menu")
    End

    Method OnTouchUp:Void(event:TouchEvent)
        If event.startPos.y >= slider.pos.y
            HandleSliderSwipe(event)
        Else
            HandleBackgroundSwipe(event)
        End
    End

    Private

    Method OnEnterPaused:Void()
        Local diff:Int = Millisecs() - pauseTime
        pauseTime = 0

        lastComboTime += diff
        severity.WarpTime(diff)
    End

    Method HandleBackgroundSwipe:Void(event:TouchEvent)
        Local swipe:Vector2D = event.startDelta.Normalize()
        If swipe.y > 0.2 Then FastDropMatchingShapes()
    End

    Method HandleSliderSwipe:Void(event:TouchEvent)
        Local swipe:Vector2D = event.startDelta.Normalize()
        If Abs(swipe.x) <= 0.2 Then Return

        If swipe.x < 0
            slider.SlideLeft()
        Else
            slider.SlideRight()
        End
    End

    Method OnRenderScore:Void()
        font.DrawText("Score: " + score,
            director.center.x,
            director.size.y - 50,
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
            Translate(director.center.x, director.center.y)
            Scale(scale, scale)
            font.DrawText("COMBO x " + lastComboCounter, 0, 0, AngelFont.ALIGN_CENTER)
        PopMatrix()
    End

    Method OnRenderGameOver:Void()
        If isNewHighscoreRecord
            NewHighscoreScene(scenes.Get("newhighscore")).score = score
            scenes.Goto("newhighscore")
        Else
            scenes.Goto("gameover")
        End
    End

    Method CheckForGameOver:Void()
        Local sliderHeight:Int = director.size.y - slider.images[0].Height() - 40
        gameOver = (chute.Height() >= sliderHeight)
    End

    Method RemoveLostShapes:Void()
        Local directoySizeY:Int = director.size.y
        Local shape:Shape

        For Local obj:Renderable = EachIn lowerShapes
            shape = Shape(obj)
            If shape.pos.y > directoySizeY Then lowerShapes.Remove(shape)
        End
    End

    Method RemoveFinishedErroAnimations:Void()
        Local sprite:Sprite
        For Local obj:Renderable = EachIn errorAnimations
            sprite = Sprite(obj)
            If sprite.animationIsDone Then errorAnimations.Remove(sprite)
        End
    End

    Method DropNewShapeIfRequested:Void()
        If Not severity.ShapeShouldBeDropped() Then Return
        upperShapes.Add(New Shape(director, RandomType(), RandomLane(), chute))
        severity.ShapeDropped()
    End

    Method FastDropMatchingShapes:Void()
        Local shape:Shape

        For Local obj:Renderable = EachIn upperShapes
            shape = Shape(obj)
            If shape.isFast Then Continue
            If slider.Match(shape) Then shape.isFast = True
        End
    End

    Method CheckShapeCollisions:Void()
        Local checkPosY:Int = director.size.y - (slider.images[0].Height() / 2) - 15
        Local shape:Shape

        For Local obj:Renderable = EachIn upperShapes
            shape = Shape(obj)
            If shape.pos.y + shape.images[0].Height() < checkPosY Then Continue

            upperShapes.Remove(shape)
            If Not slider.Match(shape)
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
        IncrementScore(10 * lanesNotZero)
        lastComboTime = now
        lastComboCounter = lanesNotZero
    End

    Method OnMatch:Void(shape:Shape)
        lastMatchTime[shape.lane] = Millisecs()
        IncrementScore(10)
    End

    Method IncrementScore:Void(value:Int)
        score += value

        If Not isNewHighscoreRecord And score > minHighscore
            isNewHighscoreRecord = True
            OnNewHighscoreRecord()
        End
    End

    Method OnNewHighscoreRecord:Void()
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

    Method LoadHighscoreMinValue:Void()
        Local highscore:IntHighscore = New IntHighscore(10)
        StateStore.Load(highscore)
        minHighscore = highscore.Last().value
        isNewHighscoreRecord = False
    End
End
