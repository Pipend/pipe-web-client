_ => {
  // Data structure required by funnel
  // data :: [{name :: String, size :: Number}]
  data = [
    {
      axes: [
        {
          axis: "Fast",
          value: 5628
        }, {
          axis: "Quick",
          value: 5757
        }, {
          axis: "Rapid",
          value: 4905
        }, {
          axis: "Swift",
          value: 5573
        }, {
          axis: "Speedy",
          value: 4811
        }
      ]
    }, {
      axes: [
        {
          axis: "Fast",
          value: 2341
        }, {
          axis: "Quick",
          value: 1253
        }, {
          axis: "Rapid",
          value: 2181
        }, {
          axis: "Swift",
          value: 5294
        }, {
          axis: "Speedy",
          value: 3048
        }
      ]
    }
  ]

  // Presentation snipet
  
  const func = plot(radar)

  return [data, func]
}