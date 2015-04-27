'use strict';

var gulp = require('gulp');

var $ = require('gulp-load-plugins')({
  pattern: ['gulp-*', 'main-bower-files', 'uglify-save-license', 'del']
});

var gutil = require('gulp-util');
var coffee = require('gulp-coffee');
var replace = require('gulp-replace-task');

function handleError(err) {
  console.error(err.toString());
  this.emit('end');
}

gulp.task('styles',  function () {
  return gulp.src('app/styles/*.scss')
    .pipe($.rubySass({style: 'expanded', container: '~/tmp/test'}))
    .on('error', handleError)
    .pipe($.autoprefixer('last 1 version'))
    .pipe(gulp.dest('app/styles'))
    .pipe($.size());
});

gulp.task('coffee', function() {
  gulp.src('app/scripts/**/*.coffee')
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('app/scripts'))
});

gulp.task('scripts', function () {
  return gulp.src('app/scripts/**/*.js')
    .pipe($.jshint())
    .pipe($.jshint.reporter('jshint-stylish'))
    .pipe($.size());
});

gulp.task('views', function () {
  return gulp.src('app/views/**/*.html')
    .pipe($.minifyHtml({
      empty: true,
      spare: true,
      quotes: true
    }))
    .pipe(gulp.dest('dist/views'))
    .pipe($.size());
});
gulp.task('partials', function () {
  return gulp.src('app/partial/**/*.html')
    .pipe($.minifyHtml({
      empty: true,
      spare: true,
      quotes: true
    }))
    .pipe(gulp.dest('dist/partial'))
    .pipe($.size());
});

gulp.task('php', function () {
  return gulp.src('app/php/**/*.*')
    .pipe(gulp.dest('dist/php'))
    .pipe($.size());
});

gulp.task('html', ['styles', 'coffee', 'scripts', 'views', 'partials', 'php'], function () {
  var htmlFilter = $.filter('*.html');
  var jsFilter = $.filter('**/*.js');
  var cssFilter = $.filter('**/*.css');
  var assets;

  return gulp.src('app/*.html')
    .pipe(assets = $.useref.assets())
    //.pipe($.rev())
    .pipe(jsFilter)
    .pipe($.ngAnnotate())
    .pipe($.uglify({preserveComments: $.uglifySaveLicense}))
    .pipe(jsFilter.restore())
    .pipe(cssFilter)
    .pipe($.csso())
    .pipe(cssFilter.restore())
    .pipe(assets.restore())
    .pipe($.useref())
    .pipe($.revReplace())
    .pipe(htmlFilter)
    .pipe($.minifyHtml({
      empty: true,
      spare: true,
      quotes: true
    }))
    .pipe(htmlFilter.restore())
    .pipe(gulp.dest('dist'))
    .pipe($.size())
});

gulp.task('images', function () {
  return gulp.src('app/images/**/*')
    .pipe($.cache($.imagemin({
      optimizationLevel: 3,
      progressive: true,
      interlaced: true
    })))
    .pipe(gulp.dest('dist/images'))
    .pipe($.size());
});

gulp.task('fonts', function () {
  return gulp.src('app/fonts/')
    .pipe($.filter('**/*.{eot,svg,ttf,woff}'))
    .pipe($.flatten())
    .pipe(gulp.dest('dist/fonts'))
    .pipe($.size());
});

gulp.task('my-assets', function () {
  gulp.src('app/bower_components/rem-unit-polyfill/js/*.*')
    .pipe(gulp.dest('dist/bower_components/rem-unit-polyfill/js'))
    .pipe($.size());

  gulp.task('fonts', function () {
    return gulp.src('app/fonts/**/*.*')
      .pipe(gulp.dest('dist/fonts'))
      .pipe($.size());
  });

  gulp.src('app/favicon.ico')
    .pipe(gulp.dest('dist'))
    .pipe($.size());

  gulp.src('app/*.png')
    .pipe(gulp.dest('dist'))
    .pipe($.size());

  gulp.src('app/*.txt')
    .pipe(gulp.dest('dist'))
    .pipe($.size());

  return gulp.src('app/*.xml')
    .pipe(gulp.dest('dist'))
    .pipe($.size());
});

gulp.task('clean', function (done) {
  $.del(['.tmp', 'dist'], done);
});

gulp.task('build', ['html', 'views', 'partials', 'images', 'fonts', 'my-assets']);
