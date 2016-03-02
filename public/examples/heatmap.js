_ => {
    const points = d3.range(100).map(_ => ({
        x: Math.random() * 850,
        y: Math.random() * 300,
        value: Math.random() * 30
      })
    )

    // Data structure required by heatmap
    /*
    data :: {
        max :: Number
        data :: [{
            x :: Number,
            y :: Number,
            value :: Number
        }]
    }
    */
    const data = {
      max: d3.max(points, (x => x.value)),
      data: points
    }

    // Presentation snippet
    func = plot(withOptions(heatmap, {
      width: 850,
      height: 300,
      backgroundColor: 'black'
    }))

    return [data, func]
}