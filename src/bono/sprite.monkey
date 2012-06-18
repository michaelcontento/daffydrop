Strict

Private

Import mojo
Import animationable
Import game
Import vector2d

Public

Class Sprite Implements Animationable
    Private

    Field image:Image

    Public

    Field pos:Vector2D
    Field rotation:Float
    Field scale:Vector2D = New Vector2D(1, 1)
    Field size:Vector2D
    Field center:Vector2D
    Field frame:Int

    Method New(imageName:String, pos:Vector2D=Null)
        If pos = Null
            Self.pos = New Vector2D(0, 0)
        Else
            Self.pos = pos
        End

        image = LoadImage(imageName)
        size = New Vector2D(image.Width(), image.Height())
        center = size.Copy().Div(2)
    End

    Method OnRender:Void()
        DrawImage(image, pos.x, pos.y, rotation, scale.x, scale.y, frame)
    End

    Method OnUpdate:Void()
    End

    Method CenterGameX:Void()
        pos.x = CurrentGame().center.x - center.x
    End

    Method CenterGameY:Void()
        pos.y = CurrentGame().center.y - center.y
    End

    Method CenterGame:Void()
        pos = CurrentGame().center.Copy().Sub(center)
    End
End
