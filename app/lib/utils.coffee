utils = 

  getAllPropertyVersions: (object, property) ->
    result = []
    for proto in utils.getPrototypeChain object
      value = proto[property]
      if value and value not in result
        result.push value
    result

  # Simple duck-typing serializer for models and collections.
  serialize: (data) ->
    if typeof data.serialize is 'function'
      data.serialize()
    else if typeof data.toJSON is 'function'
      data.toJSON()
    else
      throw new TypeError 'utils.serialize: Unknown data was passed'

  # Get the whole chain of object prototypes.
  getPrototypeChain: (object) ->
    chain = [object.constructor.prototype]
    while object = object.constructor?.superclass?.prototype ? object.constructor?.__super__
      chain.push object
    chain.reverse()

module.exports = utils