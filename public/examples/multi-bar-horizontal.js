_ => {
  /*
  Data structure required by timeseries
  
  data :: [{
      key :: String
      values :: [[Number, Number]]
  }]
  */
  const data = [
    {
      key: 'square',
      values: d3.range(10).map(it =>
        [it, it * it]
      )
    }, {
      key: 'line',
      values: d3.range(10).map(it =>
        [it, -it]
      ),
      color: 'orange'
    }
  ]
  
  // Presentation snippet

  const func = plot(withOptions(multiBarHorizontal, {
    margin: {
      left: 80,
      right: 40
    },
    xAxis: {
      label: 'x-axis'
    },
    yAxis: {
      label: 'y-axis'
    },
    showValues: true,
    stacked: false
  }))

  return [data, func]
}