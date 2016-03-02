_ => {
  /*
  Data structure required by timeseries:

  data :: [{
      key :: String
      values :: [[Number, Number]]
  }]
  */
  const data = [
    {
      key: 'square',
      values: d3.range(30).map(it => [Date.now() + it * 86400000, it * it])
    }, {
      key: 'line',
      values: d3.range(30).map(it => [Date.now() + it * 86400000, it * 20]),
      color: 'orange'
    }
  ]

  // Presentation snippet

  const func = plot(withOptions(timeseries, {
    margin: {
      left: 80,
      right: 40
    },
    xAxis: {
      label: 'time',
      format: timestamp =>
        d3.time.format('%a %b %d')(new Date(timestamp))
    },
    yAxis: {
      label: 'growth'
    },
    trendLine: _ => ({
        sampleSize: 20,
        color: 'green'
      })
  }))

  return [data, func]
}