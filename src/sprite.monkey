Strict

Import mojo

Import gameobject

Class Sprite Extends GameObject
    Field x:Float
    Field y:Float
    Field image:Image

    Method New(imageName:String)
        image = LoadImage(imageName)
    End

    Method OnRender:Void()
        DrawImage(image, x, y)
    End
End
