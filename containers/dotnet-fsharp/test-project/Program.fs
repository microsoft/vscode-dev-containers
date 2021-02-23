//----------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
// ----------------------------------------------------------------------------------------

[<EntryPoint>]
let main argv =
    let from = "F# Container"
    let target = "Remote World"
    printfn $"Hello {target} from the {from}!"
    0 // return an integer exit code
