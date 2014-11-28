Model = require 'models/model'

module.exports = class ChatMessage extends Model
  save: ->
    @publishEvent 'messages:saved', @attributes