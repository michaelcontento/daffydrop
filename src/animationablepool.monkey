Strict

Import animationable

Class AnimationablePool Implements Animationable
    Field list:List<Animationable>

    Method New()
        list = New List<Animationable>
    End

    Method Add:Void(obj:Animationable)
        list.AddLast(obj)
    End

    Method Remove:Void(obj:Animationable)
        list.RemoveEach(obj)
    End

    Method OnRender:Void()
        If Not list Then Return
        For Local obj:Animationable = EachIn list
            obj.OnRender()
        End
    End

    Method OnUpdate:Void()
        If Not list Then Return
        For Local obj:Animationable = EachIn list
            obj.OnUpdate()
        End
    End
End
