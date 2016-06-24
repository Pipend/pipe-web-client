require! \browserify
require! \fs
require! \gulp
require! \gulp-connect
require! \gulp-if
require! \gulp-livescript
{instrument, hook-require, write-reports} = (require \gulp-livescript-istanbul)!
require! \gulp-mocha
require! \gulp-streamify
require! \gulp-stylus
require! \gulp-uglify
require! \gulp-util
require! \nib
{basename, dirname, extname} = require \path
{each} = require \prelude-ls
{once} = require \underscore
source = require \vinyl-source-stream
require! \watchify

config = 
    minify: process.env.MINIFY == \true

gulp.task \build:examples:styles, ->
    gulp.src <[./public/index.styl]>
    .pipe gulp-stylus {use: nib!, import: <[nib]>, compress: config.minify, "include css": true}
    .pipe gulp.dest './public/'
    .pipe gulp-connect.reload!

gulp.task \watch:examples:styles, -> 
    gulp.watch <[./public/components/*.styl]>, <[build:examples:styles]>

# create a browserify Bundler
# create-bundler :: [String] -> object -> Bundler
create-bundler = (entries, extras) ->
    bundler = browserify {} <<< watchify.args <<< extras
        ..add entries
        ..transform \liveify
        ..transform \brfs

# outputs a single javascript file (which is bundled and minified - depending on env)
# bundler :: Bundler -> {file :: String, directory :: String} -> IO()
bundle = (minify, bundler, {file, directory}:output) ->
    bundler.bundle!
        .on \error, -> gulp-util.log arguments
        .pipe source file
        .pipe gulp-if minify, (gulp-streamify gulp-uglify!)
        .pipe gulp.dest directory

# build-and-watch :: Bundler -> {file :: String, directory :: String} -> Boolean -> (() -> ()) -> ()
build-and-watch = (minify, bundler, {file}:output, done) !->
    # must invoke done only once
    once-done = once done

    watchified-bundler = watchify bundler

    # build once
    bundle minify, watchified-bundler, output

    watchified-bundler
        .on \update, ->
            bundle minify, watchified-bundler, output
                .pipe gulp-connect.reload!

        .on \time, (time) ->
            once-done!
            gulp-util.log "#{file} built in #{time / 1000} seconds"

index-ls = create-bundler [\./public/index.ls], debug: !config.minify
index-js = file: \index.js, directory: \./public/

gulp.task \build:examples:scripts, ->
    bundle config.minify, index-ls, index-js

gulp.task \build-and-watch:examples:scripts, (done) ->
    build-and-watch config.minify, index-ls, index-js, done

gulp.task \build:src:styles, ->
    gulp.src <[./index.styl]>
    .pipe gulp-stylus {use: nib!, import: <[nib]>, compress: config.minify, "include css": true}
    .pipe gulp.dest \./
    .pipe gulp-connect.reload!

gulp.task \watch:src:styles, -> 
    gulp.watch <[./index.styl]>, <[build:src:styles]>

gulp.task \build:src:scripts, ->
    gulp.src <[
        ./index.ls 
        ./exceptions.ls 
        ./presentation-context.ls
    ]>
    .pipe gulp-livescript!
    .pipe gulp.dest './'

    gulp.src <[./plottables/*.ls]>
    .pipe gulp-livescript!
    .pipe gulp.dest './plottables'

gulp.task \watch:src:scripts, ->
    gulp.watch do 
        <[
            ./index.ls
            ./exceptions.ls 
            ./presentation-context.ls 
            ./plottables/*.ls
        ]>
        <[build:src:scripts]>

gulp.task \dist, <[build:src:scripts]>, ->
    browserify standalone: \pipeWebClient, debug: false
        .add "index.js"
        .exclude \prelude-ls
        .exclude \prelude-extension
        .exclude \jquery-browserify
        .exclude \transpilation
        .exclude \pipe-transformation
        .exclude \d3
        .exclude \nvd3
        .exclude \es6-promise
        .exclude \prelude-extension
        .exclude \react
        .exclude \react-dom
        .exclude \react-router
        .exclude \pipe-transformation/transformation-context
        .bundle!
        .pipe source "index.min.js"
        .pipe (gulp-streamify gulp-uglify!)
        .pipe gulp.dest \./dist

gulp.task \dev:server, ->
    gulp-connect.server do
        livereload: true
        port: 8001
        root: \./public/

gulp.task \coverage, ->
    gulp.src <[./index.ls]>
    .pipe instrument!
    .pipe hook-require!
    .on \finish, ->
        gulp.src <[./test/index.ls]>
        .pipe gulp-mocha!
        .pipe write-reports!
        .on \finish, -> process.exit!

gulp.task \build:src, <[build:src:styles build:src:scripts]>
gulp.task \watch:src, <[watch:src:styles watch:src:scripts]>
gulp.task \build, <[build:src]>
gulp.task \build:examples, <[build:examples:styles build:examples:scripts]>
gulp.task do 
    \default
    <[
        dev:server 
        build:src 
        watch:src 
        build:examples:styles 
        watch:examples:styles 
        build-and-watch:examples:scripts
    ]>