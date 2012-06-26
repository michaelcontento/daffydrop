Strict

Private

Import mojo
Import bono
Import severity

Public

Class MenuScene Extends Scene
    Private

    Field easy:Sprite
    Field normal:Sprite
    Field normalActive:Sprite
    Field advanced:Sprite
    Field advancedActive:Sprite
    Field highscore:Sprite
    Field isLocked:Bool = True
    Field lock:Sprite

    Public

    Method New()
        name = "menu"
    End

    Method OnCreate:Void()
        Local offset:Vector2D = New Vector2D(0, 140)
        easy = New Sprite("01_02-easy.png", New Vector2D(0, 270))
        normal = New Sprite("01_02-normal.png", easy.pos.Copy().Add(offset))
        normalActive = New Sprite("01_02-normal_active.png", normal.pos)
        advanced = New Sprite("01_02-advanced.png", normal.pos.Copy().Add(offset))
        advancedActive = New Sprite("01_02-advanced_active.png", advanced.pos)
        highscore = New Sprite("01_04button-highscore.png", advanced.pos.Copy().Add(offset))

        director.CenterX(easy)
        director.CenterX(normal)
        director.CenterX(advanced)
        director.CenterX(highscore)

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
    End

    Method OnUpdate:Void()
        If KeyDown(KEY_E) Then PlayEasy()
        If KeyDown(KEY_N) Then PlayNormal()
        If KeyDown(KEY_A) Then PlayAdvanced()
        If KeyDown(KEY_H) Then scenes.Goto("highscore")
        If KeyDown(KEY_L) Then toggleLock()
    End

    Method OnTouchDown:Void(event:TouchEvent)
        If easy.Collide(event.pos) Then PlayEasy()
        If Not isLocked And normal.Collide(event.pos) Then PlayNormal()
        If Not isLocked And advanced.Collide(event.pos) Then PlayAdvanced()
        If highscore.Collide(event.pos) Then scenes.Goto("highscore")
    End

    Private

    Method toggleLock:Void()
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
        scenes.Goto("game")
    End

    Method PlayNormal:Void()
        CurrentSeverity().Set(NORMAL)
        scenes.Goto("game")
    End

    Method PlayAdvanced:Void()
        CurrentSeverity().Set(ADVANCED)
        scenes.Goto("game")
    End
End
