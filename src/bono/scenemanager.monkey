Strict

Import bono

Class SceneManager
    Field scenes:StringMap<Scene> = New StringMap<Scene>
    Field nextScene:Scene
    Field current:Scene

    Method Add:Void(scene:Scene)
        If scenes.IsEmpty()
            current = scene
        ElseIf scenes.Contains(scene.name)
            Error("Scenemanager already contains a scene name " + scene.name)
        End

        scenes.Set(scene.name, scene)
    End

    Method Goto:Void(name:String)
        If nextScene And nextScene.name = name Then Return
        nextScene = scenes.Get(name)

        If current Then current.OnLeave()
        nextScene.OnEnter()

        current = nextScene
    End
End