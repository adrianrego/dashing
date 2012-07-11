define [
  'jquery'
  'underscore'
  'backbone'
  'hbs!templates/detail'
  'nvd3'
  'modal'
], ($, _, Backbone, tmpl, nv) ->
  class MetricDetailView extends Backbone.View
    tagName: 'div'
    className: 'modal hide fade'
    template: tmpl

    render: ->
      @$el.html(@template(@model.attributes))
      $('body').append(@el)

      @$el.on 'hidden', =>
        @remove()

      @$el.on 'show', ->
        modal = $(@)
        modal.css('margin-top', (modal.outerHeight() / 2) * -1)

        return @

      @$el.on 'shown', =>
        d3Values = _.map @model.get('values'), (v)->
          data = {x: v.seconds * 1000, y: v.value}
          return data

        nv.addGraph ->
          chart = nv.models.lineChart()
          chart.xAxis.axisLabel('Date').tickFormat((d) ->
            d3.time.format('%x')(new Date(d))
          )

          chart.yAxis.axisLabel('Value')


          d3.select('#chart svg').datum([
            {
              key: 'Values'
              values: d3Values
            }
          ]
          ).transition().duration(500).call(chart)

          return

      @$el.modal()

