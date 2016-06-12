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
source = require \vinyl-source-stream
require! \watchify

config = 
    minify: process.env.MINIFY == \true

gulp.task \build:examples:styles, ->
    gulp.src <[./public/components/App.styl]>
    .pipe gulp-stylus {use: nib!, import: <[nib]>, compress: config.minify, "include css": true}
    .pipe gulp.dest './public/components'
    .pipe gulp-connect.reload!

gulp.task \watch:examples:styles, -> 
    gulp.watch <[./public/components/*.styl]>, <[build:examples:styles]>

# create-bundler :: [String] -> Bundler
create-bundler = (entries) ->
    bundler = browserify {} <<< watchify.args <<< {debug: !config.minify, paths: <[./public/components]>}
        ..add entries
        ..transform \liveify
        ..transform \brfs
    watchify bundler

# bundler :: Bundler -> {file :: String, directory :: String} -> IO ()
bundle = (bundler, {file, directory}:output) ->
    bundler.bundle!
        .on \error, -> console.log arguments
        .pipe source file
        .pipe gulp-if config.minify, (gulp-streamify gulp-uglify!)
        .pipe gulp.dest directory
        .pipe gulp-connect.reload!

examples-bundler = create-bundler \./public/components/App.ls

# bundle-examples :: () -> IO ()
bundle-examples = -> bundle examples-bundler, {file: "App.js", directory: "./public/components/"}

gulp.task \build:examples:scripts, ->
    bundle-examples!

gulp.task \watch:examples:scripts, ->
    examples-bundler.on \update, -> bundle-examples!
    examples-bundler.on \time, (time) -> gulp-util.log "App.js built in #{time / 1000} seconds"

gulp.task \build:src:styles, ->
    gulp.src <[./index.styl]>
    .pipe gulp-stylus {use: nib!, import: <[nib]>, compress: config.minify, "include css": true}
    .pipe gulp.dest \./
    .pipe gulp-connect.reload!

gulp.task \watch:src:styles, -> 
    gulp.watch <[./index.styl]>, <[build:src:styles]>

gulp.task \build:src:scripts, ->
    gulp.src <[./index.ls ./exceptions.ls ./presentation-context.ls]>
    .pipe gulp-livescript!
    .pipe gulp.dest './'

    gulp.src <[./plottables/*.ls]>
    .pipe gulp-livescript!
    .pipe gulp.dest './plottables'

gulp.task \watch:src:scripts, ->
    gulp.watch <[./index.ls ./exceptions.ls ./presentation-context.ls ./plottables/*.ls]>, <[build:src:scripts]>

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
gulp.task \build:examples, <[build:examples:styles build:examples:scripts]>
gulp.task \watch:examples, <[watch:examples:styles watch:examples:scripts]>
gulp.task \default, <[dev:server build:src watch:src build:examples watch:examples]>
gulp.task \build, <[build:src]>