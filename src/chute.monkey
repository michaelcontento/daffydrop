Strict

Import mojo
Import bono

Class Chute Implements Animationable
    Field bottom:Image
    Field bg:Image
    Field height:Int = 50

    Field nextTick:Int
    Field autoAdvanceTime:Int = 6000
    Field autoAdvanceStartDelay:Int = 6000
    Field autoAdvanceHeight:Int = 25

    Method New()
        bg = LoadImage("chute-bg.png")
        bottom = LoadImage("chute-bottom.png")
        nextTick = Millisecs() + autoAdvanceStartDelay
    End

    Method OnUpdate:Void()
        If Millisecs() > nextTick
            nextTick = Millisecs() + autoAdvanceTime
            height += autoAdvanceHeight
        End
    End

    Method OnRender:Void()
        For Local lane:Int = 0 To 3
            For Local posY:Int = 0 To height
                DrawImage(bg, bg.Width() * lane, posY)
            End

            DrawImage(bottom, bg.Width() * lane, height)
        End
    End
End
