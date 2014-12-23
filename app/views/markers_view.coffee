CollectionView = require 'views/collection_view'
MarkerView     = require 'views/marker_view'

module.exports = class MarkersView extends CollectionView
  itemView: MarkerView
  render: ->
    super
    @listenTo @collection, 'chosen', (color) =>
      for view in @subviews
        view.el.classList.remove 'active'
        if view.model.get('color') is color
          view.el.classList.add 'active'
