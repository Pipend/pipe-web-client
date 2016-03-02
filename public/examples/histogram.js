_ => {
  /* 
  Data structure required by histogram: 
  
  data :: [{
      key :: String
      values :: [[Number, Number]]
  }]
  */
  const data = [
    {
      key: 'square',
      values: d3.range(30).map(x => [x, x * x])
    }, {
      key: 'line',
      values: d3.range(30).map(x => [x, x * 20]),
      color: 'orange'
    }
  ]

  // Presentation snippet
  const func = plot(withOptions(histogram, {
    margin: {
      left: 80,
      right: 40
    },
    xAxis: {
      label: 'time'
    },
    yAxis: {
      label: 'growth'
    },
    rotateLabels: -30,
    groupSpacing: 0.3,
    showLegend: true,
    showControl: true
  }))

  return [data, func];
}