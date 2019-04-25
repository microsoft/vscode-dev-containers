//-------------------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
// ------------------------------------------------------------------------------------------------------------

open System

[<EntryPoint>]
let main argv =
    let from = "F# Container"
    let target = "Remote World"
    let message = "Hello " + target + " from the " + from + "!"
    printfn "%s" message
    
    0 // return an integer exit code
