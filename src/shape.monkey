Strict

Private

Import mojo
Import bono
Import chute

Public

Class Shape Implements Animationable
    Private

    Field chute:Chute
    Field speedSlow:Vector2D
    Field speedFast:Vector2D

    Public

    Global images:Image[]
    Field isFast:Bool = False
    Field pos:Vector2D
    Field type:Int
    Field lane:Int

    Method New(type:Int, lane:Int, chute:Chute)
        Self.type = type
        Self.lane = lane
        Self.chute = chute

        images = [LoadImage("circle_inside.png"), LoadImage("plus_inside.png"), LoadImage("star_inside.png"), LoadImage("tire_inside.png")]
        Local posX:Int = 46 + (chute.bg.Width() * lane)
        Local posY:Int = chute.height - images[type].Height()
        pos = New Vector2D(posX, posY)

        speedSlow = New Vector2D(0, 4)
        speedFast = New Vector2D(0, 12)
    End

    Method OnUpdate:Void()
        If isFast
            pos.Add(speedFast)
        Else
            pos.Add(speedSlow)
        End
    End

    Method OnRender:Void()
        DrawImage(images[type], pos.x, pos.y)
    End
End
