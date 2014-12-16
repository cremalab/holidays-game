Modal     = require 'views/modal_view'
template = require './templates/intro'

module.exports = class IntroView extends Modal
  template: template
  autoRender: true
  className: 'modal sub-intro'

  render: ->
    super
    thing = @el.querySelector('.sub-bigRed')
    thing.addEventListener 'click', =>
      @dispose()

  dispose: ->
    @trigger 'dispose'
    super

