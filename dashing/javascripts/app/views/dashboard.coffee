define [
  'jquery'
  'underscore'
  'backbone'
  'hbs!templates/dashboard'
  'cs!views/detail'
], ($, _, Backbone, tmpl, MetricDetailView) ->
  class MetricDashboardView extends Backbone.View
    tagName: 'div'
    className: 'dash span3'
    template: tmpl

    events:
      "click":    "details"

    render: ->
      row = $('.row-fluid').last()

      if row.length == 0 or $(row).children().length >= 4
        $('div.container-fluid').append('<div class="row-fluid"></div>')
        return @render()

      @$el.html(@template(@model.attributes))
      $(row).append(@el)

    details: ->
      detail = new MetricDetailView(model: @model)
      detail.render()
