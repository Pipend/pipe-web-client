_ <- id

data =  [0 til 30] |> map -> x: Date.now! + (it * 86400000), y: it * it

/*
layoutHorizontal :: cell<Plottable>...
layoutVertical :: cell<Plottable>...
scell :: Number -> Plottable -> Plottable
cell :: Plottable -> Plottable
*/

# Presentation snippet

func = plot layout-horizontal do 
    scell 0.2, table `with-options` {
        cells: 
            # custom Plottable for x fields of the data
            x: plottable (view, result) ->
                d3.select view .text (d3.time.format '%y-%m-%d') new Date result
    }
    cell timeseries1 `with-options` {
        x: (.x) 
        y: (.y)
    }


[data, func]