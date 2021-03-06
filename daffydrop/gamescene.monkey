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
Import gamehighscore
Import soundmanager

Public

Class GameScene Extends Scene Implements RouterEvents
    Private

    Const COMBO_DETECT_DURATION:Int = 325
    Const COMBO_DISPLAY_DURATION:Int = 850
    Const NEW_HIGHSCORE_DISPLAY_DURATION:Int = 2500

    Field severity:Severity
    Field chute:Chute
    Field slider:Slider
    Field upperShapes:FanOut
    Field lowerShapes:FanOut
    Field errorAnimations:FanOut
    Field newHighscoreAnimation:Animation
    Field score:Int
    Field lastSlowUpdate:Float
    Field scoreFont:Font
    Field newHighscoreFont:Font
    Field comboFont:Font
    Field comboAnimation:Animation
    Field lastMatchTime:Int[] = [0, 0, 0, 0]
    Field isNewHighscoreRecord:Bool
    Field falseSpriteStrack:Stack<Sprite> = New Stack<Sprite>()
    Field pauseButton:Sprite
    Field minHighscore:Int
    Field ignoreFirstTouchUp:Bool
    Field pauseTime:Int
    Field comboPending:Bool
    Field comboPendingSince:Int
    Field checkPosY:Float
    Field collisionCheckedLastUpdate:Bool
    Global soundmanager:SoundManager

    Public

    Method OnCreate:Void(director:Director)
        chute = New Chute()
        lowerShapes = New FanOut()
        severity = CurrentSeverity()
        slider = New Slider()
        upperShapes = New FanOut()
        errorAnimations = New FanOut()

        pauseButton = New Sprite("buttons/pause-button.png")
        pauseButton.pos = director.size.Copy().Sub(pauseButton.size)
        pauseButton.pos.y = 0

        scoreFont = New Font("CoRa")
        scoreFont.pos = New Vector2D(director.center.x, director.size.y - 65)
        scoreFont.align = Font.CENTER
        scoreFont.color = New Color(3, 105, 187)

        comboFont = New Font("CoRa", director.center.Copy())
        comboFont.color = New Color(3, 105, 187)
        comboFont.text = "COMBO x 2"
        comboFont.pos.y -= 150
        ' FIXME: CENTER alignment is not handled properly :/
        comboFont.pos.x -= 130
        'comboFont.align = Font.CENTER

        comboAnimation = New Animation(1.8, 0, COMBO_DISPLAY_DURATION)
        comboAnimation.effect = New FaderScale()
        comboAnimation.transition = New TransitionInCubic()
        comboAnimation.Add(comboFont)
        comboAnimation.Pause()

        newHighscoreFont = New Font("CoRa", director.center.Copy())
        newHighscoreFont.color = New Color(209, 146, 31)
        newHighscoreFont.text = "NEW HIGHSCORE"
        newHighscoreFont.pos.y /= 2
        ' FIXME: CENTER alignment is not handled properly :/
        newHighscoreFont.pos.x -= 200
        'newHighscoreFont.align = Font.CENTER

        newHighscoreAnimation = New Animation(1.5, 0, NEW_HIGHSCORE_DISPLAY_DURATION)
        newHighscoreAnimation.effect = New FaderScale()
        newHighscoreAnimation.transition = New TransitionInCubic()
        newHighscoreAnimation.Add(newHighscoreFont)
        newHighscoreAnimation.Pause()

        layer.Add(New Sprite("bg_960x640.jpg"))
        layer.Add(lowerShapes)
        layer.Add(slider)
        layer.Add(upperShapes)
        layer.Add(errorAnimations)
        layer.Add(newHighscoreAnimation)
        layer.Add(comboAnimation)
        layer.Add(chute)
        layer.Add(scoreFont)
        layer.Add(pauseButton)

        Super.OnCreate(director)

        If Not soundmanager
            soundmanager = New SoundManager()
            soundmanager.Add("match", "sounds/shape-match")
            soundmanager.Add("mismatch", "sounds/shape-mismatch")
            soundmanager.Add("combo", "sounds/combo")
            soundmanager.Add("gameover", "sounds/gameover")
            soundmanager.Add("newhighscore", "sounds/newhighscore")
            soundmanager.PreloadAll()
        End

        checkPosY = director.size.y - (slider.images[0].Height() / 2) - 5
    End

    Method OnEnter:Void()
        If pauseTime > 0
            OnEnterPaused()
            Return
        End

        ignoreFirstTouchUp = True
        score = 0
        scoreFont.text = "Score: 0"
        lowerShapes.Clear()
        upperShapes.Clear()
        errorAnimations.Clear()
        severity.Restart()
        chute.Restart()
        slider.Restart()
        LoadHighscoreMinValue()
    End

    Method OnPauseLeaveGame:Void()
        pauseTime = 0
    End

    Method OnLeave:Void()
    End

    Method OnUpdate:Void(delta:Float, frameTime:Float)
        Super.OnUpdate(delta, frameTime)

        If HandleGameOver() Then Return

        If collisionCheckedLastUpdate
            collisionCheckedLastUpdate = False
        Else
            collisionCheckedLastUpdate = True
            CheckShapeCollisions()
        End

        DetectComboTrigger()
        severity.OnUpdate(delta, frameTime)
        DropNewShapeIfRequested()

        lastSlowUpdate += frameTime
        If lastSlowUpdate >= 1000
            lastSlowUpdate = 0
            RemoveLostShapes()
            RemoveFinishedErroAnimations()

            If Not comboAnimation.IsPlaying()
                layer.Remove(comboAnimation)
            End
            If Not newHighscoreAnimation.IsPlaying()
                layer.Remove(newHighscoreAnimation)
            End
        End
    End

    Method OnKeyDown:Void(event:KeyEvent)
        Select event.code
        Case KEY_P
            StartPause()
        Case KEY_DOWN, CHAR_DOWN
            FastDropMatchingShapes()
        Case KEY_LEFT, CHAR_LEFT
            slider.SlideLeft()
        Case KEY_RIGHT, CHAR_RIGHT
            slider.SlideRight()
        End
    End

    Method OnSuspend:Void()
        StartPause()
    End

    Method OnTouchDown:Void(event:TouchEvent)
        If pauseButton.Collide(event.pos) Then StartPause()
        If slider.arrowRight.Collide(event.pos) Then slider.SlideRight()
        If slider.arrowLeft.Collide(event.pos) Then slider.SlideLeft()
    End

    Method OnTouchUp:Void(event:TouchEvent)
        If ignoreFirstTouchUp
            ignoreFirstTouchUp = False
            Return
        End

        If event.startPos.y >= slider.pos.y
            HandleSliderSwipe(event)
        Else
            HandleBackgroundSwipe(event)
        End
    End

    Method OnTouchMove:Void(event:TouchEvent)
        ' PERFORMANCE OPTIMIZATION
        ' This prevents the event delegation to ALL object in the layer
    End

    Private

    Method StartPause:Void()
        pauseTime = Millisecs()
        router.Goto("pause")
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
        If Abs(swipe.x) <= 0.4 Then Return

        If swipe.x < 0
            slider.SlideLeft()
        Else
            slider.SlideRight()
        End
    End

    Method HandleGameOver:Bool()
        If (chute.Height() < slider.arrowLeft.pos.y + 50) Then Return False

        If isNewHighscoreRecord
#If TARGET<>"glfw" And TARGET<>"html5"
            director.inputController.trackKeys = True
#End
            NewHighscoreScene(router.Get("newhighscore")).score = score
            router.Goto("newhighscore")
        Else
            soundmanager.Play("gameover")
            router.Goto("gameover")
        End

        Return True
    End

    Method RemoveLostShapes:Void()
        Local directoySizeY:Float = director.size.y
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
            If sprite.animationIsDone
                errorAnimations.Remove(sprite)
                falseSpriteStrack.Push(sprite)
            End
        End
    End

    Method DropNewShapeIfRequested:Void()
        If Not severity.ShapeShouldBeDropped() Then Return
        upperShapes.Add(New Shape(severity.RandomType(), severity.RandomLane(), chute))
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

        chute.height = Max(75, chute.height - (18 * lanesNotZero))
        IncrementScore(15 * lanesNotZero)
        comboFont.text = "COMBO x " + lanesNotZero

        soundmanager.Play("combo")
        comboAnimation.Restart()
        layer.Add(comboAnimation)
    End

    'Method OnRender:Void()
    '    Super.OnRender()
    '    DrawText("SLODOWN: " + CurrentSeverity().progress, 100, 100)
    'End

    Method OnMatch:Void(shape:Shape)
        lastMatchTime[shape.lane] = Millisecs()
        IncrementScore(10)
        soundmanager.Play("match")
    End

    Method IncrementScore:Void(value:Int)
        score += value
        scoreFont.text = "Score: " + score

        If Not isNewHighscoreRecord And score >= minHighscore
            isNewHighscoreRecord = True
            newHighscoreAnimation.Restart()
            layer.Add(newHighscoreAnimation)
            soundmanager.Play("newhighscore")
        End
    End

    Method OnMissmatch:Void(shape:Shape)
        Local sprite:Sprite
        If falseSpriteStrack.Length() > 0
            sprite = falseSpriteStrack.Pop()
        Else
            sprite = New Sprite("false.png", 140, 88, 6, 100)
        End
        sprite.pos = shape.pos
        sprite.Restart()
        chute.height += 15

        lastMatchTime = [0, 0, 0, 0]
        comboPending = False
        comboPendingSince = 0
        errorAnimations.Add(sprite)
        soundmanager.Play("mismatch")
    End

    Method LoadHighscoreMinValue:Void()
        Local highscore:GameHighscore = New GameHighscore()
        StateStore.Load(highscore)
        minHighscore = highscore.Last().value
        isNewHighscoreRecord = Not (highscore.Count() = highscore.maxCount)
    End
End
