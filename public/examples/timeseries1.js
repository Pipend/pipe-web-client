_ => {
    // Data structure required by timeseries1
    // data :: [[Number, Number]]
    const data = d3.range(30).map(it =>
        [Date.now() + it * 86400000, it * it]
    )
    
    // Presentation snippet

    const func = plot(timeseries1)
  
    return [data, func]
}