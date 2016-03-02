_ <- id
/* 
Data structure required by histogram:

data :: [{
    key :: String
    values :: [[Number, Number]]
}]
*/
data = 
    * key: \square
      values: [0 til 30] |> map -> 
        [it, it * it]
    * key: \line
      values: [0 til 30] |> map -> 
        [it, it * 20]
      color: \orange

## Presentation snippet
func = plot histogram `with-options` {
    margin:
        left: 80
        right: 40
    x-axis:
        label: \time
    y-axis:
        label: \growth
    rotate-labels: -30
    group-spacing: 0.3
    show-legend: true
    show-control: true
}

[data, func]