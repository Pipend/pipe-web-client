# the first require is used by browserify to import the prelude-ls module
# the second require is defined in the prelude-ls module and exports the object
require \prelude-ls
{Obj, Str, id, any, average, concat-map, drop, each, filter, find, foldr1, foldl, 
map, maximum, minimum, obj-to-pairs, pairs-to-obj, sort, sum, tail, take, unique} = require \prelude-ls

# nvd3 requires d3 to be in global space
d3 = window.d3 = require \d3
if typeof global != \undefined
    global.d3 = d3
nv = require \nvd3 

require! \d3-tip
d3-tip d3

{fill-intervals, rextend} = require \./plottables/_utils

$ = require \jquery-browserify

# Plottable is a monad, run it by plot funciton
class Plottable
    (@plotter, @options = {}, @continuations = ((..., callback) -> callback null), @projection = id) ->
    _plotter: (view, result, parameters) ~>
        options = 
            | typeof @options == \function => @options parameters
            | _ => @options
        @plotter view, (@projection result, options), options, @continuations

# Wraps f in a a Plottable
# plottable :: (View -> result -> {}:options -> IO ()) -> Plottable
plottable = (f) -> 
    new Plottable (view, result, options) !--> 
        f view, result, options

# Runs a Plottable
# plot :: Plottable -> DOMElement -> result -> parameters -> DOM()
plot = (p, view, result, parameters) -->
    p._plotter view, result, parameters

# Attaches options to a Plottable
# with-options :: Plottable -> Either object, (Parameters -> object) -> Plottable
with-options = (p, f) ->
    new-options = 
        | typeof f == \function =>
            (parameters) ->
                current-options = if typeof p.options == \function then p.options parameters else p.options
                ({} `rextend` current-options) `rextend` (f parameters)
        | _ => ({} `rextend` p.options) `rextend` f

    new Plottable do
        p.plotter
        new-options
        p.continuations
        p.projection
 
# more :: Plottable -> (... -> (Error? -> Void)) -> Plottable
more = (p, c) ->
  new Plottable do
    p.plotter
    {} `rextend` p.options
    (...init, callback) -> 
      try 
        c ...init
      catch ex
        return callback ex
      callback null
    p.projection
 
# projects the data of a Plottable with f
# project :: (result -> options -> result) -> Plottable -> Plottable
project = (f, p) -->
  new Plottable do
    p.plotter
    {} `rextend` p.options
    p.continuations
    (result, options) -> p.projection (f result, options), options

# json :: View -> result -> DOM()
json = (view, result) ->
    view.innerHTML = "<pre>#{JSON.stringify result, null, 4}</pre>"

# csv :: View -> result -> DOM()
csv = (view, result) ->
    columns = Obj.keys result.0
    (columns.join \,) + "\n" + do ->
        result
        |> foldl do
            (acc, row) ->
                acc.push do 
                    columns 
                    |> map (column) -> row[column]
                    |> Str.join \,
                acc
            []
        |> Str.join "\n"

    pre = $ "<pre/>"
        ..text json-to-csv result
    ($ view).append pre

# plot-chart :: View -> result -> Chart -> DOM()
plot-chart = (view, result, chart) !->
    d3.select view 
        .append \div .attr \style, "position: absolute; left: 0px; top: 0px; width: 100%; height: 100%" 
        .append \svg .datum result .call chart

plottables = {
    pjson: new Plottable do
        (view, result, {pretty, space}, continuation) !-->
            pre = $ "<pre/>"
                ..html if not pretty then JSON.stringify result else JSON.stringify result, null, space
            ($ view).append pre
        {pretty: true, space: 4}
    table: (require \./plottables/table) {Plottable, d3, nv, plot-chart, plot}
    histogram1: (require \./plottables/histogram1) {Plottable, d3, nv, plot-chart, plot}
    histogram: (require \./plottables/histogram) {Plottable, d3, nv, plot-chart, plot}
    stacked-area: (require \./plottables/stacked-area) {Plottable, nv, d3, plot-chart, plot}
    scatter1: (require \./plottables/scatter1) {Plottable, d3, nv, plot-chart, plot}
    scatter: (require \./plottables/scatter) {Plottable, d3, nv, plot-chart, plot}
    correlation-matrix: (require \./plottables/correlation-matrix) {Plottable, d3, nv, plot-chart, plot}
    regression: (require \./plottables/regression) {Plottable, d3, nv, plot-chart, plot}
    timeseries1: (require \./plottables/timeseries1) {Plottable, d3, nv, plot-chart, plot}
    timeseries: (require \./plottables/timeseries) {Plottable, d3, nv, plot-chart, plot}
    multi-bar-horizontal: (require \./plottables/multi-bar-horizontal) {Plottable, d3, nv, plot-chart, plot}
    heatmap: (require \./plottables/heatmap) {Plottable, d3, plot}
    multi-chart: (require \./plottables/multi-chart) {Plottable, d3, nv, plot-chart, plot}
    funnel: (require \./plottables/funnel) {Plottable, d3, nv, plot-chart, plot}
    funnel1: (require \./plottables/funnel1) {Plottable, d3}
    radar: (require \./plottables/radar) {Plottable, d3}
} 

{layout-horizontal, layout-vertical} = layout-plottables = (require \./plottables/layout) {Plottable, d3, nv, plot-chart, plot}
    ..layout-horizontal = -> (layout-horizontal ...) `with-options` id
    ..layout-vertical = -> (layout-vertical ...) `with-options` id

# all functions defined here are accessibly by the presentation code
module.exports = ->
    {} <<< plottables <<< layout-plottables <<< {
        Plottable
        plot
        plottable
        with-options
        more
        project
        json
        csv
        fill-intervals
        React: require \react
        ReactDOM: require \react-dom
    } <<< (require \prelude-ls)