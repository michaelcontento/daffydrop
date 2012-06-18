Strict

Import mojo
Import bono
Import chute

Class Shape Implements Animationable
    Global images:Image[]
    Field type:Int
    Field lane:Int
    Field chute:Chute
    Field pos:Vector2D

    Field speedSlow:Vector2D
    Field speedFast:Vector2D
    Field isFast:Bool = False

    Method New(type:Int, lane:Int, chute:Chute)
        Self.type = type
        Self.lane = lane
        Self.chute = chute

        LoadSharedImages()

        Local posX:Int = 46 + (chute.bg.Width() * lane)
        Local posY:Int = chute.height - images[type].Height()
        pos = New Vector2D(posX, posY)

        speedSlow = New Vector2D(0, 4)
        speedFast = New Vector2D(0, 12)
    End

    Method LoadSharedImages:Void()
        If images.Length() > 0 Then Return
        images = [LoadImage("circle_inside.png"), LoadImage("plus_inside.png"), LoadImage("star_inside.png"), LoadImage("tire_inside.png")]
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
