open System

[<EntryPoint>]
let main argv =
    let from = "F# Container"
    let target = "World"
    let message = "Hello " + target + " from " + from + "!"
    printfn "%s" message
    
    0 // return an integer exit code
