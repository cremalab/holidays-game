exports.config =
  # See http://brunch.io/#documentation for docs.
  paths: watched: ['app', 'test']
  files:
    javascripts:
      joinTo:
        'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^(bower_components|vendor)/

    stylesheets:
      joinTo:
        'stylesheets/app.css': /^/
      order:
        after: ['vendor/styles/helpers.css']

    templates:
      joinTo: 'javascripts/app.js'

  plugins:
    autoprefixer:
      browsers: ["last 2 versions"]
      cascade: false

  server:
    port: 4040
