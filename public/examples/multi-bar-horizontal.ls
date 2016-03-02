_ <- id
/*
Data structure required by timeseries

data :: [{
    key :: String
    values :: [[Number, Number]]
}]
*/
data = 
    * key: 'square'
      values: [0 til 10] |> map -> 
        [it, it * it]
    * key: 'line'
      values: [0 til 10] |> map -> 
        [it, -it]
      color: 'orange'

## Presentation snippet

func = plot multi-bar-horizontal `with-options` {
    margin:
        left: 80
        right: 40
    x-axis:
        label: 'x-axis'
    y-axis:
        label: 'y-axis'
    show-values: true
    stacked: false
}

[data, func]