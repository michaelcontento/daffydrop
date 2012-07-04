Strict

Private

Import mojo
Import bono
Import bono.vendor.angelfont
Import chute
Import shape
Import severity
Import slider
Import scene
Import newhighscorescene

Public

Class GameScene Extends Scene Implements RouterEvents
    Private

    Const COMBO_DETECT_DURATION:Int = 300
    Const COMBO_DISPLAY_DURATION:Int = 750

    Field severity:Severity
    Field chute:Chute
    Field slider:Slider
    Field upperShapes:FanOut
    Field lowerShapes:FanOut
    Field errorAnimations:FanOut
    Field score:Int
    Field gameOver:Bool
    Field scoreFont:Font
    Field comboFont:Font
    Field comboAnimation:Animation
    Field lastMatchTime:Int[] = [0, 0, 0, 0]
    Field isNewHighscoreRecord:Bool
    Field pauseButton:Sprite
    Field minHighscore:Int
    Field pauseTime:Int
    Field comboPending:Bool
    Field comboPendingSince:Int

    Public

    Method OnCreate:Void(director:Director)
        chute = New Chute()
        lowerShapes = New FanOut()
        severity = CurrentSeverity()
        slider = New Slider()
        upperShapes = New FanOut()
        errorAnimations = New FanOut()

        scoreFont = New Font("CoRa")
        scoreFont.pos = New Vector2D(director.center.x, director.size.y - 50)
        scoreFont.text = "Score: 0"
        scoreFont.align = Font.CENTER

        comboFont = New Font("CoRa", director.center)
        comboFont.text = "COMBO x 2"
        comboFont.pos.x -= 70

        ' FIXME: CENTER alignment is not handled properly :/
        comboFont.pos.y -= 150
        'comboFont.align = Font.CENTER

        comboAnimation = New Animation(2, 0, COMBO_DISPLAY_DURATION)
        comboAnimation.effect = New FaderScale()
        comboAnimation.transition = New TransitionInCubic()
        comboAnimation.Add(comboFont)
        comboAnimation.Pause()

        LoadHighscoreMinValue()

        layer.Add(New Sprite("bg_960x640.png"))
        layer.Add(lowerShapes)
        layer.Add(slider)
        layer.Add(upperShapes)
        layer.Add(errorAnimations)
        layer.Add(chute)
        layer.Add(scoreFont)
        layer.Add(comboAnimation)

        pauseButton = New Sprite("pause-button.png")
        pauseButton.pos = director.size.Copy().Sub(pauseButton.size)
        pauseButton.pos.y = 0
        layer.Add(pauseButton)

        Super.OnCreate(director)
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

    Method OnPauseLeaveGame:Void()
        pauseTime = 0
    End

    Method OnLeave:Void()
    End

    Method OnUpdate:Void(delta:Float, frameTime:Float)
        Super.OnUpdate(delta, frameTime)

        CheckForGameOver()
        If gameOver Then HandleGameOver()

        severity.OnUpdate(delta, frameTime)
        RemoveLostShapes()
        RemoveFinishedErroAnimations()
        CheckShapeCollisions()
        DetectComboTrigger()
        DropNewShapeIfRequested()
    End

    Method OnKeyDown:Void(event:KeyEvent)
        Super.OnKeyDown(event)
        Select event.code
        Case KEY_P
            StartPause()
        Case KEY_DOWN
            FastDropMatchingShapes()
        Case KEY_H
            Router(director.handler).Goto("gameover")
        Case KEY_LEFT
            slider.SlideLeft()
        Case KEY_RIGHT
            slider.SlideRight()
        End
    End

    Method OnTouchDown:Void(event:TouchEvent)
        Super.OnTouchDown(event)
        If pauseButton.Collide(event.pos) Then StartPause()
    End

    Method OnTouchUp:Void(event:TouchEvent)
        Super.OnTouchUp(event)
        If event.startPos.y >= slider.pos.y
            HandleSliderSwipe(event)
        Else
            HandleBackgroundSwipe(event)
        End
    End

    Private

    Method StartPause:Void()
        pauseTime = Millisecs()
        Router(director.handler).Goto("pause")
    End

    Method OnEnterPaused:Void()
        Local diff:Int = Millisecs() - pauseTime
        pauseTime = 0

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

    Method HandleGameOver:Void()
        If isNewHighscoreRecord
            NewHighscoreScene(Router(director.handler).Get("newhighscore")).score = score
            Router(director.handler).Goto("newhighscore")
        Else
            Router(director.handler).Goto("gameover")
        End
    End

    Method CheckForGameOver:Void()
        Local sliderHeight:Int = director.size.y - slider.images[0].Height() - 40
        gameOver = (chute.Height() >= sliderHeight)
    End

    Method RemoveLostShapes:Void()
        Local directoySizeY:Int = director.size.y
        Local shape:Shape

        For Local obj:DirectorEvents = EachIn lowerShapes
            shape = Shape(obj)
            If shape.pos.y > directoySizeY Then lowerShapes.Remove(shape)
        End
    End

    Method RemoveFinishedErroAnimations:Void()
        Local sprite:Sprite
        For Local obj:DirectorEvents = EachIn errorAnimations
            sprite = Sprite(obj)
            If sprite.animationIsDone Then errorAnimations.Remove(sprite)
        End
    End

    Method DropNewShapeIfRequested:Void()
        If Not severity.ShapeShouldBeDropped() Then Return
        upperShapes.Add(New Shape(RandomType(), RandomLane(), chute))
        severity.ShapeDropped()
    End

    Method FastDropMatchingShapes:Void()
        Local shape:Shape

        For Local obj:DirectorEvents = EachIn upperShapes
            shape = Shape(obj)
            If shape.isFast Then Continue
            If slider.Match(shape) Then shape.isFast = True
        End
    End

    Method CheckShapeCollisions:Void()
        Local checkPosY:Int = director.size.y - (slider.images[0].Height() / 2) - 15
        Local shape:Shape

        For Local obj:DirectorEvents = EachIn upperShapes
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
        Local hotLanes:Int
        Local now:Int = Millisecs()

        For Local lane:Int = 0 Until lastMatchTime.Length()
            If lastMatchTime[lane] = 0 Then Continue

            lanesNotZero += 1
            If lastMatchTime[lane] + COMBO_DETECT_DURATION >= now
                hotLanes += 1

                If hotLanes >= 2 And Not comboPending
                    comboPending = True
                    comboPendingSince = now
                End
            Else
                ' Reset cold lanes
                If Not comboPending Then lastMatchTime[lane] = 0
            End
        End

        If Not comboPending Then Return
        If comboPendingSince + COMBO_DETECT_DURATION > now Then Return

        lastMatchTime = [0, 0, 0, 0]
        comboPending = False

        IncrementScore(10 * lanesNotZero)
        comboFont.text = "COMBO x " + lanesNotZero
        comboAnimation.Restart()
    End

    Method OnMatch:Void(shape:Shape)
        lastMatchTime[shape.lane] = Millisecs()
        IncrementScore(10)
    End

    Method IncrementScore:Void(value:Int)
        score += value
        scoreFont.text = "Score: " + score

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
        isNewHighscoreRecord = Not (highscore.Count() = highscore.maxCount)
    End
End
