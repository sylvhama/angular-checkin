'use strict';

var gulp = require('gulp');

gulp.task('watch', ['styles', 'coffee'] ,function () {
  gulp.watch('app/styles/**/*.scss', ['styles']);
  gulp.watch('app/scripts/**/*.coffee', ['coffee']);
  gulp.watch('app/scripts/**/*.js', ['scripts']);
  gulp.watch('app/images/**/*', ['images']);
});
