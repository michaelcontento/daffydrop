Strict

Private

Import mojo
Import bono
Import severity

Public

Class MenuScene Extends BaseObject
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


    Method OnCreate:Void(director:Director)
        Local offset:Vector2D = New Vector2D(0, 140)
        easy = New Sprite("01_02-easy.png", New Vector2D(0, 270))
        normal = New Sprite("01_02-normal.png", easy.pos.Copy().Add(offset))
        normalActive = New Sprite("01_02-normal_active.png", normal.pos)
        advanced = New Sprite("01_02-advanced.png", normal.pos.Copy().Add(offset))
        advancedActive = New Sprite("01_02-advanced_active.png", advanced.pos)
        highscore = New Sprite("01_04button-highscore.png", advanced.pos.Copy().Add(offset))

        easy.CenterX(director)
        normal.CenterX(director)
        advanced.CenterX(director)
        highscore.CenterX(director)

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
    End

    Method OnTouchDown:Void(event:TouchEvent)
        Super.OnTouchDown(event)
        If easy.Collide(event.pos) Then PlayEasy()
        If normal.Collide(event.pos) Then PlayNormal()
        If advanced.Collide(event.pos) Then PlayAdvanced()
        If highscore.Collide(event.pos) Then Router(director.handler).Goto("highscore")
    End

    Method OnKeyDown:Void(event:KeyEvent)
        Super.OnKeyDown(event)
        Select event.code
        Case KEY_E
            PlayEasy()
        Case KEY_N
            PlayNormal()
        Case KEY_A
            PlayAdvanced()
        Case KEY_H
            Router(director.handler).Goto("highscore")
        Case KEY_L
            toggleLock()
        End
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
        Router(director.handler).Goto("game")
    End

    Method PlayNormal:Void()
        If isLocked Then Return
        CurrentSeverity().Set(NORMAL)
        Router(director.handler).Goto("game")
    End

    Method PlayAdvanced:Void()
        If isLocked Then Return
        CurrentSeverity().Set(ADVANCED)
        Router(director.handler).Goto("game")
    End
End
