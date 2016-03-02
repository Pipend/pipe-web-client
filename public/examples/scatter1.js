_ => {
  const shapes = ['circle', 'cross', 'triangle-up', 'triangle-down', 'diamond', 'square']

  // Data structure required by scatter1
  // data :: [{x :: Number, y :: Number, size :: Int, shape :: String}]
  const data = d3.range(15).map(d => ({
      x: Math.floor(Math.random() * 100),
      y: Math.floor(Math.random() * 10),
      size: d,
      shape: shapes[d % (shapes.length - 1)]
    })
  )
  
  // Presentation snippet

  const func = plot(withOptions(scatter1, {
    margin: {
      left: 80,
      right: 40
    },
    xAxis: {
      label: 'x axis'
    },
    yAxis: {
      label: 'y axis'
    }
  }))

  return [data, func]
}