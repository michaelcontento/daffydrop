Strict

Private

Import mojo
Import bono
Import severity
Import scene
Import appirater
Import utilbackport

Public

Class MenuScene Extends Scene
    Private

    Field easy:Sprite
    Field normal:Sprite
    Field advanced:Sprite
    Field highscore:Sprite
    Field moreGames:Sprite

    Public

    Method OnCreate:Void(director:Director)
        Local offset:Vector2D = New Vector2D(0, 150)
        easy = New Sprite("buttons/01_02-easy.png", New Vector2D(0, 290))
        normal = New Sprite("buttons/01_02-normal_active.png", easy.pos.Copy().Add(offset))
        advanced = New Sprite("buttons/01_02-advanced_active.png", normal.pos.Copy().Add(offset))
        highscore = New Sprite("buttons/01_04button-highscore.png", advanced.pos.Copy().Add(offset))

        PlayMusic("sounds/background.mp3", 1)

        layer.Add(New Sprite("01_main.jpg"))
        layer.Add(easy)
        layer.Add(normal)
        layer.Add(advanced)
        layer.Add(highscore)

        Super.OnCreate(director)

#If TARGET="ios" Or TARGET="android"
        moreGames = New Sprite("moregames.png")
        moreGames.OnCreate(director)
        moreGames.pos = director.size.Copy().Sub(moreGames.size)
        moreGames.pos.y = 0
        layer.Add(moreGames)
#End

        easy.CenterX(director)
        normal.CenterX(director)
        advanced.CenterX(director)
        highscore.CenterX(director)

        Appirater.Launched()
    End

    Method OnResume:Void(delta:Int)
        Appirater.Launched()
    End

    Method OnTouchDown:Void(event:TouchEvent)
#If TARGET="ios" Or TARGET="android"
        If HandleMoreGames(event) Then Return
#End
        If easy.Collide(event.pos) Then PlayEasy()
        If normal.Collide(event.pos) Then PlayNormal()
        If advanced.Collide(event.pos) Then PlayAdvanced()
        If highscore.Collide(event.pos) Then router.Goto("highscore")
    End

    Method OnKeyDown:Void(event:KeyEvent)
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

    Private

    Method HandleMoreGames:Bool(touch:TouchEvent)
        If Not moreGames.Collide(touch.pos) Then Return False

        Local touchLength:Float = touch.pos.Length() - moreGames.pos.Length()
        Local moreGamesHalfLength:Float = moreGames.size.Length() / 2

        ' User clicked on the "restore purchases" button but only on the left
        ' (transparent) side of it. Yes, this check is NOT 100% accurate (we're
        ' only testing with a circle around restore.pos where r=restore.size / 2)
        ' but this is fast and sufficient for our requirements.
        If touchLength < moreGamesHalfLength Then Return False

#If TARGET="ios"
        UtilBackport.OpenUrl("itms://itunes.com/apps/coragames")
#ElseIf TARGET="android"
        UtilBackport.OpenUrl("market://search?q=pub:CoRa++Games")
#End
        Return True
    End

    Method PlayEasy:Void()
        CurrentSeverity().Set(EASY)
        router.Goto("game")
    End

    Method PlayNormal:Void()
        CurrentSeverity().Set(NORMAL)
        router.Goto("game")
    End

    Method PlayAdvanced:Void()
        CurrentSeverity().Set(ADVANCED)
        router.Goto("game")
    End
End
