_ <- id
## Data structure required by timeseries1
## data :: [[Number, Number]]
data = [0 til 30] |> map -> 
    [Date.now! + (it * 86400000), it * it]

## Presentation snippet

func = plot timeseries1

[data, func]