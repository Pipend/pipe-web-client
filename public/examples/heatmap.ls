_ <- id

points = [0 til 100]
    |> map ->
        x: Math.random! * 850
        y: Math.random! * 300
        value: Math.random! * 30

## Data structure required by heatmap
'''
data :: {
    max :: Number
    data :: [{
        x :: Number,
        y :: Number,
        value :: Number
    }]
}
'''
data =
    max: points 
        |> map (.value) 
        |> maximum
    data: points

# Presentation snippet
func = plot heatmap `with-options` {
    width: 850
    height: 300
    background-color: 'black'
}

[data, func]