Strict

Private

Import bono

Public

Class GameHighscore Extends IntHighscore
    Private

    Global names:String[]
    Global scores:Int[]

    Public

    Method New()
        Super.New(10)
        LoadNamesAndScores()
        PrefillMissing()
    End

    Method FromString:Void(input:String)
        Super.FromString(input)
        PrefillMissing()
    End

    Private

    Method LoadNamesAndScores:Void()
        names = ["Michael", "Sena", "Joe", "Mouser", "Tinnet", "Horas-Ra", "Monkey", "Mike", "Angel", "Bono"]
        scores = [100, 90, 80, 70, 60, 50, 40, 30, 20, 10]
    End

    Method PrefillMissing:Void()
        If Count() >= maxCount() Then Return
        For Local i:Int = 0 Until maxCount()
            Add("easy " + names[i], scores[i])
        End
    End
End
