_ => {
    const data = d3.range(30).map(d => ({
        x: Date.now() + d * 86400000,
        y: d * d
      })
    )

    /*
    layoutHorizontal :: cell<Plottable>...
    layoutVertical :: cell<Plottable>...
    scell :: Number -> Plottable -> Plottable
    cell :: Plottable -> Plottable
    */

    // Presentation snippet

    const func = plot(layoutHorizontal(
        scell(0.2, withOptions(table, {
            cells: {
                x: plottable((view, result) =>
                    d3.select(view).text(d3.time.format('%y-%m-%d')(new Date(result))))
            }
        })), 

        cell(withOptions(timeseries1, {
            x: d => d.x,
            y: d => d.y
        }))
    ))

    return [data, func]
}