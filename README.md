Pipe web client
===========================

[![Build Status](https://travis-ci.org/Pipend/pipe-web-client.svg?branch=0.0.3)](https://travis-ci.org/Pipend/pipe-web-client)
[![Coverage Status](https://coveralls.io/repos/Pipend/pipe-web-client/badge.svg?branch=master&service=github)](https://coveralls.io/github/Pipend/pipe-web-client?branch=master)

## Installation
`npm install pipe-web-client --save`

## Usage
```
{compile-query} = (require \pipe-web-client) end-point: "pipe-api-server-url"

{execute, transformation-function, presentation-function} <- compile-query \your-query-id .then

# execute :: (Promise p) => Boolean -> Parameters -> p result
query-result <- execute false, {} .then

# transformation-function :: result -> Parameters -> result
transformed-result = transformation-function query-result, {}

# presentation-function :: DOMElement -> result -> Parameters -> DOM()
presentation-function view, transformed-result, {}
```

## Plottables
[Demo / Test bed](http://pipend.github.io/pipe-web-client)

* [correlation-matrix](http://pipend.github.io/pipe-web-client#/?example=correlation-matrix)
* [funnel](http://pipend.github.io/pipe-web-client#/?example=funnel)
* [heatmap](http://pipend.github.io/pipe-web-client#/?example=heatmap)
* [histogram](http://pipend.github.io/pipe-web-client#/?example=histogram)
* [histogram1](http://pipend.github.io/pipe-web-client#/?example=histogram1)
* [multi-bar-horizontal](http://pipend.github.io/pipe-web-client#/?example=multi-bar-horizontal)
* [multi-chart](http://pipend.github.io/pipe-web-client#/?example=multi-chart)
* [regression](http://pipend.github.io/pipe-web-client#/?example=regression)
* [scatter](http://pipend.github.io/pipe-web-client#/?example=scatter)
* [scatter1](http://pipend.github.io/pipe-web-client#/?example=scatter1)
* [stacked-area](http://pipend.github.io/pipe-web-client#/?example=stacked-area)
* [table](http://pipend.github.io/pipe-web-client#/?example=table)
* [timeseries](http://pipend.github.io/pipe-web-client#/?example=timeseries)
* [timeseries1](http://pipend.github.io/pipe-web-client#/?example=timeseries1)

## Development

* run `gulp`
* visit `http://localhost:8001`
* for unit tests, run `npm test`
* for code coverage, run `gulp coverage`
