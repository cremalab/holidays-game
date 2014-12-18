Modal     = require 'views/modal_view'
template = require './templates/intro'

module.exports = class IntroView extends Modal
  template: template
  autoRender: true
  className: 'modal sub-intro'
  triggerVolume: true

  initialize: (options) ->
    if options.triggerVolume is false
      @triggerVolume = false
    super

  render: ->
    super
    thing = @el.querySelector('button')
    thing.addEventListener 'click', =>
      @dispose()

  dispose: ->
    @trigger 'dispose'
    if @triggerVolume
      @publishEvent('togglePlayback')
    super

