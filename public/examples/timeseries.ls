_ <- id
/*
Data structure required by timeseries:

data :: [{
    key :: String
    values :: [[Number, Number]]
}]
*/
data = 
    * key: \square
      values: [0 til 30] |> map -> 
        [Date.now! + (it * 86400000), it * it]
    * key: \line
      values: [0 til 30] |> map -> 
        [Date.now! + (it * 86400000), it * 20]
      color: \orange

## Presentation snipppet

func = plot timeseries `with-options` {
    margin:
        left: 80
        right: 40
    x-axis:
        label: \time
        format: (timestamp) -> (d3.time.format '%a %b %d') new Date timestamp
    y-axis:
        label: \growth
    trend-line: ->
        sample-size: 20
        color: \green
}

[data, func]