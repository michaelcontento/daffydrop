Strict

Import mojo

Import gameobject

Class Sprite Extends GameObject
    Field x:Float
    Field y:Float
    Field image:Image

    Method New(imageName:String, x:Float=0, y:Float=0)
        image = LoadImage(imageName)
        Self.x = x
        Self.y = y
    End

    Method OnRender:Void()
        DrawImage(image, x, y)
    End

    Method Height:Int()
        Return image.Height()
    End

    Method Width:Int()
        Return image.Width()
    End

    Method Height2:Int()
        Return Height() / 2
    End

    Method Width2:Int()
        Return Width() / 2
    End
End
