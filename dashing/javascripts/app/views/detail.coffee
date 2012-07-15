define [
  'jquery'
  'underscore'
  'backbone'
  'hbs!templates/detail'
  'flotr2'
  'modal'
], ($, _, Backbone, tmpl, Flotr) ->
  class MetricDetailView extends Backbone.View
    tagName: 'div'
    className: 'modal hide'
    template: tmpl

    initialize: ->
      @id = @model.cid

    valueChart: ->
      values = _.map @.model.get('values'), (v, i)->
        return [v.date.getTime(), v.value]

      container = $('#val-chart')[0]
      graphOpts =
        title: "Volume"
        bars:
          show: true
          barWidth: 1000 * 43000
        xaxis:
          mode: 'time'
          labelsAngle: 45
          timeMode: 'local'
          noTicks: 10

      graph = Flotr.draw(container, [values], graphOpts)

    rateChart: ->
      yLabel = 'Rate'
      m = @model

      values = []
      sum = 0

      _.times m.get('values').length, (i) ->
        val = m.get('values')[i].value
        total = m.get('rel_total').get('values')[i].value
        x = m.get('values')[i].date.getTime()

        rate = Math.round(val/total * 100)
        sum += rate

        values.push([x, rate])

      mean = []

      _.each m.get('values'), (v)->
          mean.push([v.date.getTime(), Math.round(sum/values.length)])

      container = $('#rate-chart')[0]
      graphOpts =
        title: "% of Total"
        lines:
          fill: true
        xaxis:
          mode: 'time'
          labelsAngle: 45
          timeMode: 'local'
          noTicks: 10
        yaxis:
          min: 0
          max: 100

      graph = Flotr.draw(container, [values], graphOpts)

    render: ->
      @$el.attr('id', @id)
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
