EventBroker = require 'lib/event_broker'

# Base class for all models.
module.exports = class Model extends Backbone.Model
  Backbone.utils.extend @prototype, EventBroker

  disposed: false

  dispose: ->
    return if @disposed

    # Fire an event to notify associated collections and views.
    @trigger 'dispose', this

    # Unbind all global event handlers.
    @unsubscribeAllEvents()

    # Unbind all referenced handlers.
    @stopListening()

    # Remove all event handlers on this module.
    @off()

    # Remove the collection reference, internal attribute hashes
    # and event handlers.
    properties = [
      'collection',
      'attributes', 'changed', 'defaults',
      '_escapedAttributes', '_previousAttributes',
      '_silent', '_pending',
      '_callbacks'
    ]
    delete this[prop] for prop in properties

    # Finished.
    @disposed = true