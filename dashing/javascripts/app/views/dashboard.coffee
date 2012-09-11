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
        data.formatted_value = @formatNumber(data.value, true)
        data.formatted_mean = @formatNumber(data.mean, true)
        data.formatted_stddev = @formatNumber(data.stddev, true)
        
        if data.targetVal
          data.formatted_target = @formatNumber(data.targetVal / 100, true)
      else
        data.formatted_value = @formatNumber(data.value, false, 2)
        data.formatted_mean = @formatNumber(data.mean, false)
        data.formatted_stddev = @formatNumber(data.stddev, false)
        
        if data.targetVal
          data.formatted_target = @formatNumber(data.targetVal, false)

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

    formatNumber: (num, percent, digits) ->
      if not digits
        digits = 1
        
      val = Math.round(num * 10 * digits) / (10 * digits)
      parts = val.toString().split(".")

      parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
      val = parts.join(".")
      
      if percent
        val = val + '%'

      return val

    details: ->
      detail = new MetricDetailView(model: @model)
      detail.render()
