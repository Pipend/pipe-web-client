_ => {
  // Data structure required by regression
  // data :: [{x :: Number, y :: Number, size :: Int}]
  const data = d3.range(15).map(d => ({
      x: Math.floor(Math.random() * 100),
      y: Math.floor(Math.random() * 100),
      size: d
    })
  )

  // Presentation snippet

  const func = plot(withOptions(regression, {
    margin: {
      top: 40,
      left: 80,
      right: 40
    },
    xAxis: {
      label: 'x axis'
    },
    yAxis: {
      label: 'y axis'
    },
    tooltip: ({x, y, size}) =>
      `x: ${x} , y: ${y} , size: ${size}`
  }))

  return [data, func]
}