_ <- id
## Data structure required by histogram1
## data :: [[Number, Number]]
data = [0 til 30] |> map -> 
    [it, it]

## Presentation snippet
func = plot histogram1

[data, func]