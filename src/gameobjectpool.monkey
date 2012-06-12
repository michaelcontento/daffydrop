Strict

Import gameobject

Class GameObjectPool Extends GameObject
    Field list:List<GameObject>

    Method New()
        list = New List<GameObject>
    End

    Method Add:Void(obj:GameObject)
        list.AddLast(obj)
    End

    Method Remove:Void(obj:GameObject)
        list.RemoveEach(obj)
    End

    Method OnRender:Void()
        If Not list Then Return
        For Local obj:GameObject = EachIn list
            obj.OnRender()
        End
    End

    Method OnUpdate:Void()
        If Not list Then Return
        For Local obj := EachIn list
            obj.OnUpdate()
        End
    End
End
