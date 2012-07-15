define [
  'jquery'
  'backbone'
  'cs!views/dashboard'
], ($, Backbone, MetricDashboardView) ->
  class RowView extends Backbone.View
    tagName: 'div'
    className: 'row-fluid'
    sizes:
      large: 6
      medium: 4
      small: 3

    initialize: ->
      @span = 0

    render: ->
      $('div.container-fluid').append(@el)

    add: (model) ->
      addedSize = @sizes[model.get('size')]

      if (12 - @span) >= addedSize
        @span += addedSize
        dash = new MetricDashboardView(model: model, row: @, span: addedSize)
        dash.render()

        return true
      else
        return false
