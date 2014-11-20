EventBroker = require 'lib/event_broker'

# Base class for all models.
module.exports = class Model extends Backbone.Model
  Backbone.utils.extend @prototype, EventBroker