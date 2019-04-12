//----------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See LICENSE in the project root for license information.
// ----------------------------------------------------------------------------------------

open System

[<EntryPoint>]
let main argv =
    let from = "F# Container"
    let target = "World"
    let message = "Hello " + target + " from " + from + "!"
    printfn "%s" message
    
    0 // return an integer exit code
