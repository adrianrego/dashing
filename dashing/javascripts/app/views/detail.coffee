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

    valueChart: ->
      yLabel = @model.get('name')
      m = @model

      d3Values = _.map @model.get('values'), (v)->
          data = {x: v.date, y: v.value}
          return data

      datum = [{key: yLabel, values: d3Values}]

      if @model.get('target')
        targets = []

        _.each @model.get('values'), (v)->
          targets.push({y:m.get('targetVal'), x:v.date})

        datum.push({key:'Target', values: targets})

      nv.addGraph ->
        chart = nv.models.lineChart()
        chart.xAxis.tickFormat((d) ->
            d3.time.format('%x')(new Date(d))
        )

        d3.select('#val-chart svg').datum(datum)
          .transition().duration(500).call(chart)

        return

    rateChart: ->
      yLabel = 'Rate'
      m = @model

      d3Values = []
      sum = 0

      _.times m.get('values').length, (i) ->
        val = m.get('values')[i].value
        total = m.get('rel_total').get('values')[i].value
        x = m.get('values')[i].date

        rate = Math.round(val/total * 100)
        sum += rate

        d3Values.push({x: x, y: rate})


      datum = [{key: yLabel, values: d3Values}]

      mean = []

      _.each m.get('values'), (v)->
          mean.push({y:Math.round(sum/d3Values.length), x:v.date})

      datum.push({key:'Avg. Rate', values: mean})

      nv.addGraph ->
        chart = nv.models.lineChart()
        chart.xAxis.tickFormat((d) ->
            d3.time.format('%x')(new Date(d))
        )

        d3.select('#rate-chart svg').datum(datum)
          .transition().duration(500).call(chart)

        return

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
        @valueChart()
        @rateChart()

      @$el.modal()

