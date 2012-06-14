Strict

Class Vector2D
    Field x:Float
    Field y:Float

    Method New(x:Float=0, y:Float=0)
        Self.x = x
        Self.y = y
    End

    Method IsZero:Bool()
        Return (x = 0 And y = 0)
    End

    Method Magnitude:Float()
        Return Sqrt(x * x + y * y)
    End

    Method Normalize:Float()
        Local mag:Float = Magnitude()
        If Not mag = 00
            x /= mag
            y /= mag
        End
        Return mag
    End

    Method Rotate:Void(angle:Float)
        Local tmpX:Float = (x * Cos(angle)) - (y * Sin(angle))
        Local tmpY:Float = (y * Cos(angle)) - (x * Sin(angle))
        x = tmpX
        y = tmpY
    End

    Method DotProduct:Float(v2:Vector2D)
        Return (x * v2.x) + (y * v2.y)
    End

    Method CrossProduct:Float(v2:Vector2D)
        Return (x * v2.y) - (y * v2.x)
    End

    Method Distance:Float(v2:Vector2D)
        Return Sqrt((v2.x - x)) + Sqrt((v2.y - y))
    End

    Method Equal:Bool(v2:Vector2D)
        Return (x = v2.x And y = v2.y)
    End

    Method Add:Void(v2:Vector2D)
        x += v2.x
        y += v2.y
    End

    Method Sub:Void(v2:Vector2D)
        x -= v2.x
        y -= v2.y
    End

    Method Mul:Void(v2:Vector2D)
        x *= v2.x
        y *= v2.y
    End

    Method Div:Void(v2:Vector2D)
        x /= v2.x
        y /= v2.y
    End

    Function Add:Vector2D(v1:Vector2D, v2:Vector2D)
        Return New Vector2D(v1.x + v2.x, v1.y + v2.y)
    End

    Function Sub:Vector2D(v1:Vector2D, v2:Vector2D)
        Return New Vector2D(v1.x - v2.x, v1.y - v2.y)
    End

    Function Mul:Vector2D(v1:Vector2D, v2:Vector2D)
        Return New Vector2D(v1.x * v2.x, v1.y * v2.y)
    End

    Function Div:Vector2D(v1:Vector2D, v2:Vector2D)
        Return New Vector2D(v1.x / v2.x, v1.y / v2.y)
    End
End
