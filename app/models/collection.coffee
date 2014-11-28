EventBroker = require 'lib/event_broker'

# Base class for all collections.
module.exports = class Collection extends Backbone.Collection
  Backbone.utils.extend @prototype, EventBroker
