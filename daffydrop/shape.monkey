Strict

Private

Import mojo
Import bono
Import chute

Public

Class Shape Extends BaseObject
    Private

    Field chute:Chute
    Global SPEED_SLOW:Vector2D
    Global SPEED_FAST:Vector2D

    Public

    Global images:Image[]
    Field isFast:Bool = False
    Field type:Int
    Field lane:Int

    Method New(type:Int, lane:Int, chute:Chute)
        Self.type = type
        Self.lane = lane
        Self.chute = chute

        If images.Length() = 0
            images = [LoadImage("circle_inside.png"), LoadImage("plus_inside.png"), LoadImage("star_inside.png"), LoadImage("tire_inside.png")]
        End

        Local posX:Float = 46 + (images[0].Width() * lane)
        Local posY:Float = chute.Height() - images[type].Height()
        pos = New Vector2D(posX, posY)

        If Not SPEED_SLOW Then SPEED_SLOW = New Vector2D(0, 3)
        If Not SPEED_FAST Then SPEED_FAST = New Vector2D(0, 10)
    End

    Method OnUpdate:Void(delta:Float, frameTime:Float)
        If isFast
            pos.Add(SPEED_FAST.Copy().Mul(delta))
        Else
            pos.Add(SPEED_SLOW.Copy().Mul(delta))
        End
    End

    Method OnRender:Void()
        DrawImage(images[type], pos.x, pos.y)
    End
End
