Strict

Import src.game
Import src.introscene
Import src.menuscene

Function Main:Int()
    Local game:Game = Game.GetInstance()
    game.sceneManager.Add(New IntroScene())
    game.sceneManager.Add(New MenuScene())
    game.Run()
    Return 0
End
