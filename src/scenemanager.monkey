Strict

Import scene

Class SceneManager
    Field scenes:StringMap<Scene>
    Field nextScene:Scene
    Field current:Scene

    Method New()
        scenes = New StringMap<Scene>
    End

    Method Add:Void(scene:Scene)
        If scenes.IsEmpty() Then current = scene
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
