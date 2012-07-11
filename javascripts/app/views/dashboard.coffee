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

      data = @model.attributes
      data.value = _.last(data.values).value

      if @model.get('value') >= @model.get('target')
        data.status = 'btn-success'
      else if @model.get('value') >= @model.get('warning')
        data.status = 'btn-warning'
      else
        data.status = 'btn-danger'

      @$el.html(@template(data))
      $(row).append(@el)

    details: ->
      detail = new MetricDetailView(model: @model)
      detail.render()
