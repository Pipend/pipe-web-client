## this is the data structure required by histogram1
## data :: [[Number, Number]]
data = [0 til 30] |> map -> 
    [it, it]

## the right hand side is what goes in the presentation layer
func = plot histogram1

[data, func]