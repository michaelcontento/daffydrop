Strict

Private

Import mojo
Import bono
Import chute

Public

Class Shape Extends DisplayObject
    Private

    Field chute:Chute
    Field director:Director
    Global SPEED_SLOW:Vector2D
    Global SPEED_FAST:Vector2D

    Public

    Global images:Image[]
    Field isFast:Bool = False
    Field type:Int
    Field lane:Int

    Method New(director:Director, type:Int, lane:Int, chute:Chute)
        Self.director = director
        Self.type = type
        Self.lane = lane
        Self.chute = chute

        If images.Length() = 0
            images = [LoadImage("circle_inside.png"), LoadImage("plus_inside.png"), LoadImage("star_inside.png"), LoadImage("tire_inside.png")]
        End

        Local posX:Int = 46 + (chute.bg.Width() * lane)
        Local posY:Int = chute.Height() - images[type].Height()
        pos = New Vector2D(posX, posY)

        If Not SPEED_SLOW Then SPEED_SLOW = New Vector2D(0, 4)
        If Not SPEED_FAST Then SPEED_FAST = New Vector2D(0, 12)
    End

    Method OnUpdate:Void()
        If isFast
            pos.Add(SPEED_FAST.Copy().Mul(director.delta))
        Else
            pos.Add(SPEED_SLOW.Copy().Mul(director.delta))
        End
    End

    Method OnRender:Void()
        DrawImage(images[type], pos.x, pos.y)
    End
End
