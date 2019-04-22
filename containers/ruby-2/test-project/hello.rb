#-----------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE in the project root for license information.
#-----------------------------------------------------------------------------------------

def sayHello(name)
  result = "Hello, " + name + "!"
  return result
end
  
  
puts sayHello("Remote Extension Host")
puts sayHello("Local Extension Host")
