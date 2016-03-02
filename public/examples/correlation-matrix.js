_ => {
    // Data structure required by correlation-matrix
    // data :: [{a: Number}]
    const data = d3.range(30).map(_ => ({
        sepalLength: Math.random() * 30,
        sepalWidth: Math.random() * 30,
        petalLength: Math.random() * 30,
        petalWidth: Math.random() * 30
      })
    )

    // Presentation snippet
    const func = plot(withOptions(correlationMatrix, {
        traits: ['sepalLength', 'sepalWidth', 'petalLength', 'petalWidth']
    }))

    return [data, func]
}