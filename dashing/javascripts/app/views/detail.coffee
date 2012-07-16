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
      m = @model

      if m.get('display') == 'rate'
        data = m.get('rates')
        display = "Rate (%)"
      else
        data = m.get('values')
        display = "Volume"

      values = _.map(data, (v, i)->
        return [v.date.getTime(), v.value])

      container = $('#val-chart')[0]
      graphOpts =
        title: display
        bars:
          show: true
          barWidth: 1000 * 43000
        xaxis:
          mode: 'time'
          labelsAngle: 45
          timeMode: 'local'
          noTicks: 10
        mouse:
          track: true
        markers:
          show: true

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

    varianceChart: ->
      yLabel = 'Variance from Target'
      m = @model
      max = 100
      min = -100

      values = []
      sum = 0

      if m.get('display') == 'rate'
        data = m.get('rates')
      else
        data = m.get('values')

      _.times data.length, (i) ->
        val = data[i].value
        target = m.getCompareAndVal(m.get('target'))

        if m.get('display') == 'rate'
          variance = m.get('targetVal') - val
        else
          variance = Math.round((val / m.get('targetVal')) * 100)

        if m.compareVal(target, val)
          variance = Math.abs(variance)

          if target[0][0] == '<'
            variance = 100 - variance
        else
          variance = Math.abs(variance)
          variance = Math.abs((100 - variance)) * - 1

        x = m.get('values')[i].date.getTime()
        values.push([x, variance])

        if variance > max
          max = variance

        if variance < min
          min = variance


      aMin = Math.abs(min)

      if max > aMin
        min = max * -1
      else if aMin > max
        max = aMin

      container = $('#rate-chart')[0]
      graphOpts =
        title: "% Variance from Target"
        xaxis:
          mode: 'time'
          labelsAngle: 45
          timeMode: 'local'
          noTicks: 10
        yaxis:
          min: min
          max: max
        mouse:
          track: true

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
        @varianceChart()

      @$el.modal()
