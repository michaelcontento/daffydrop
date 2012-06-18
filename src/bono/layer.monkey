Strict

Import animationable

Class Layer Implements Animationable
    Field objects:List<Animationable> = New List<Animationable>

    Method Add:Void(obj:Animationable)
        objects.AddLast(obj)
    End

    Method Clear:Void()
        objects.Clear()
    End

    Method Remove:Void(obj:Animationable)
        objects.RemoveEach(obj)
    End

    Method OnRender:Void()
        If Not objects Then Return
        For Local obj:Animationable = EachIn objects
            obj.OnRender()
        End
    End

    Method OnUpdate:Void()
        If Not objects Then Return
        For Local obj:Animationable = EachIn objects
            obj.OnUpdate()
        End
    End
End
