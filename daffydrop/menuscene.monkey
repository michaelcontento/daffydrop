Strict

Private

Import mojo
Import bono
Import severity
Import scene
Import appirater
Import payment

Public

Class FullVersion Extends PaymentProduct
    Method GetAppleId$()
        Return "com.coragames.daffydrop.fullversion"
    End

    Method GetAndroidId$()
        Return "android.test.purchased"
    End
End

Class MenuScene Extends Scene
    Private

    Field easy:Sprite
    Field fullVersion:FullVersion
    Field paymentService:PaymentService
    Field normal:Sprite
    Field normalActive:Sprite
    Field advanced:Sprite
    Field advancedActive:Sprite
    Field highscore:Sprite
    Field isLocked:Bool = True
    Field lock:Sprite
    Field paymentProcessing:Bool
    Field waitingText:Font
    Field waitingImage:Sprite

    Public

    Method OnCreate:Void(director:Director)
        Local offset:Vector2D = New Vector2D(0, 150)
        easy = New Sprite("01_02-easy.png", New Vector2D(0, 290))
        normal = New Sprite("01_02-normal.png", easy.pos.Copy().Add(offset))
        normalActive = New Sprite("01_02-normal_active.png", normal.pos)
        advanced = New Sprite("01_02-advanced.png", normal.pos.Copy().Add(offset))
        advancedActive = New Sprite("01_02-advanced_active.png", advanced.pos)
        highscore = New Sprite("01_04button-highscore.png", advanced.pos.Copy().Add(offset))

        ' The fuck! Ugly but it works ;)
        Local pos:Vector2D = advanced.pos.Copy().Add(advanced.size).Sub(normal.pos).Div(2)
        pos.y += normal.pos.y
        lock = New Sprite("locked.png", pos)
        lock.pos.y -= lock.center.y

        layer.Add(New Sprite("01_main.jpg"))
        layer.Add(easy)
        layer.Add(normal)
        layer.Add(advanced)
        layer.Add(highscore)
        layer.Add(lock)

        Super.OnCreate(director)

        easy.CenterX(director)
        normal.CenterX(director)
        advanced.CenterX(director)
        highscore.CenterX(director)

        fullVersion = New FullVersion()
        paymentService = New PaymentService()
        paymentService.SetBundleId("com.coragames.daffydrop")
        paymentService.SetPublicKey("")
        paymentService.AddProduct(fullVersion)
        paymentService.StartService()

        fullVersion.UpdatePurchasedState()
        If fullVersion.IsProductPurchased() Then ToggleLock()

        Appirater.Launched()
    End

    Method OnResume:Void(delta:Int)
        Appirater.Launched()
    End

    Method OnTouchDown:Void(event:TouchEvent)
        If paymentProcessing Then Return
        If easy.Collide(event.pos) Then PlayEasy()
        If normal.Collide(event.pos) Then PlayNormal()
        If advanced.Collide(event.pos) Then PlayAdvanced()
        If highscore.Collide(event.pos) Then router.Goto("highscore")
        If lock.Collide(event.pos) Then HandleLocked()
    End

    Method OnKeyDown:Void(event:KeyEvent)
        If paymentProcessing Then Return
        Select event.code
        Case KEY_E
            PlayEasy()
        Case KEY_N
            PlayNormal()
        Case KEY_A
            PlayAdvanced()
        Case KEY_H
            router.Goto("highscore")
        End
    End

    Method OnUpdate:Void(delta:Float, frameTime:Float)
        Super.OnUpdate(delta, frameTime)

        If Not isLocked Then Return
        If Not paymentProcessing Then Return
        If paymentService.IsPurchaseInProgress() Then Return
        paymentProcessing = False

        If Not fullVersion.IsProductPurchased() Then Return
        ToggleLock()
    End

    Method OnRender:Void()
        Super.OnRender()

        If paymentProcessing
            RenderBlend()
            PushMatrix()
                Translate(-director.center.x, -director.center.y)
                Scale(2, 2)

                waitingImage.OnRender()

                PushMatrix()
                    Translate(-2, 1)
                    SetColor(47, 85, 98)
                    waitingText.OnRender()
                PopMatrix()

                PushMatrix()
                    SetColor(255, 255, 255)
                    waitingText.OnRender()
                PopMatrix()
            PopMatrix()
        End
    End

    Private

    Method InitializeWaitingImages:Void()
        waitingText = New Font("CoRa")
        waitingText.OnCreate(director)
        waitingText.text = "Loading"
        waitingText.align = Font.CENTER
        waitingText.pos = director.center.Copy()

        waitingImage = New Sprite("star_inside.png")
        waitingImage.OnCreate(director)
        waitingImage.Center(director)
        waitingImage.pos.y -= 50
    End

    Method ToggleLock:Void()
        If isLocked
            isLocked = False
            layer.Remove(lock)
            layer.Remove(normal)
            layer.Remove(advanced)
            layer.Add(normalActive)
            layer.Add(advancedActive)
        Else
            isLocked = True
            layer.Remove(normalActive)
            layer.Remove(advancedActive)
            layer.Add(normal)
            layer.Add(advanced)
            layer.Add(lock)
        End
    End

    Method PlayEasy:Void()
        CurrentSeverity().Set(EASY)
        router.Goto("game")
    End

    Method PlayNormal:Void()
        If isLocked Then
            HandleLocked()
            Return
        End
        CurrentSeverity().Set(NORMAL)
        router.Goto("game")
    End

    Method PlayAdvanced:Void()
        If isLocked Then
            HandleLocked()
            Return
        End
        CurrentSeverity().Set(ADVANCED)
        router.Goto("game")
    End

    Method HandleLocked:Void()
        If paymentProcessing Then Return
        If Not isLocked Then Return

        InitializeWaitingImages()
        paymentProcessing = True
        fullVersion.Buy()
    End
End
