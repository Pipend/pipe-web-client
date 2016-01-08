## this is the data structure required by timeseries1
## data :: [[Number, Number]]
data = [0 til 30] |> map -> 
    [Date.now! + (it * 86400000), it * it]

## the right hand side is what goes in the presentation layer
func = plot timeseries1

[data, func]