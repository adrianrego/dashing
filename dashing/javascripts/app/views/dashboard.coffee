define [
  'jquery'
  'underscore'
  'backbone'
  'hbs!templates/dashboard'
  'cs!views/detail'
], ($, _, Backbone, tmpl, MetricDetailView) ->
  class MetricDashboardView extends Backbone.View
    tagName: 'div'
    className: 'dash'
    template: tmpl

    events:
      "click":    "details"

    initialize: (attributes)->
      @row = attributes.row
      @span = "span" + attributes.span

    render: ->
      data = @model.attributes

      if data.format == '%'
        data.formatted_value = data.value + '%'
      else
        data.formatted_value = @formatNumber(data.value)

      if data.status > 0
        data.status_class = 'btn-success'
      else if data.status == 0
        data.status_class = 'btn-warning'
      else if data.status < 0
        data.status_class = 'btn-danger'
      else
        data.status_class = 'btn-inverse'

      @$el.addClass(@span)
      @$el.html(@template(@model.attributes))
      @row.$el.append(@el)

    formatNumber: (num) ->
      parts = num.toString().split(".")
      parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")

      return parts.join(".")


    details: ->
      detail = new MetricDetailView(model: @model)
      detail.render()
