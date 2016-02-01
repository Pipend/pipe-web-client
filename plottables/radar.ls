RadarChart = require 'radar-chart-d3'
{id, map, fold, filter, replicate, zip, empty, reverse, concat-map} = require \prelude-ls

module.exports = ({Plottable, d3}) ->
    view, result, {margin}:options <- new Plottable _, {
        levels: levels ? 1
        axis-text: true
        axisLine: true
        circles: false
        color: d3.scale.category10!
        radians: Math.PI * 2
        tooltipFormatValue: id
        factorLegend: 1
        factor: 0.95
        background-color: 'white'
        transitionDuration: 300
    }
    
    width = view.client-width
    height = view.client-height
    
    d3.select view .select-all \.radar-chart .data [result]
        ..enter!.append \div .attr \class, \radar-chart .each ->
            @.style <<<
                background-color: options.background-color
                display: \-webkit-flex
                \-webkit-align-items : \center
                \-webkit-justify-content : \center
    
        ..each ->
            RadarChart.draw @, result, options <<< {v: width, h: height}
        
        ..exit!.remove \.radar-chart