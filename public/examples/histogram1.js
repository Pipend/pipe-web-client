_ => {
    // Data structure required by histogram1
    // data :: [[Number, Number]]
    const data = d3.range(30).map(d => [d, d])

    // Presentation snippet
    const func = plot(histogram1)

    return [data, func]
}