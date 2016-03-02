_ => {
  /*
  Data structure required by timeseries
  
  data :: [{
      type :: String
      y-axis :: Int
      key :: String
      values :: [[Number, Number]]
  }]
  */
  const data = [
    {
      type: 'bar',
      yAxis: 1,
      key: 'square',
      values: d3.range(30).map(it =>
        [Date.now() + it * 86400000, it * it]
      )
    }, {
      type: 'line',
      yAxis: 2,
      key: 'line',
      values: d3.range(30).map(it =>
        [Date.now() + it * 86400000, it * 20]
      ),
      color: 'orange'
    }
  ]

  // Presentation snippet

  const func = plot(withOptions(multiChart, {
    margin: {
      left: 80,
      right: 80
    },
    xAxis: {
      label: 'time',
      format: timestamp =>
        d3.time.format('%a %b %d')(new Date(timestamp))
    },
    yAxis1: {
      label: 'growth'
    },
    yAxis2: {
      label: 'growth'
    }
  }))

  return [data, func]
}