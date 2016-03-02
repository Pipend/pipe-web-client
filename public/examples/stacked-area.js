_ => {
    /* 
    Data structure required by stacked-area

    data :: [{
        key :: String
        values :: [[Number, Number]]
    }]
    */
    const data = [
      {
        key: 'company1',
        values: d3.range(30).map(function(it){
          return [Date.now() + it * 86400000, it * 20];
        })
      }, {
        key: 'company2',
        values: d3.range(30).map(function(it){
          return [Date.now() + it * 86400000, it * it];
        }),
        color: 'orange'
      }
    ]

    // Presentation snippet

    const func = plot(withOptions(stackedArea, {
      useInteractiveGuideline: true,
      showControls: true,
      showLegend: true,
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
      }
    }))

    return [data, func]
}