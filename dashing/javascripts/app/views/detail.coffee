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

    splitData: (data)->
      pass = []
      fail = []
      warn = []

      m = @model

      _.times data.length, (i) ->
        val = data[i].value
        x = m.get('values')[i].date.getTime()

        if m.get('target')
          target = m.getCompareAndVal(m.get('target'))
        else
          pass.push([x, val])
          return

        if m.get('warning')
          warning = m.getCompareAndVal(m.get('warning'))

        if not m.compareVal(target, val)
          if warning and m.compareVal(warning, val)
            warn.push([x, val])
          else
            fail.push([x, val])
        else
          pass.push([x, val])

      return [pass, fail, warn]

    valueChart: ->
      if @model.get('display') == 'rate'
        data = @model.get('rates')
        display = "Rate (%)"
      else
        data = @model.get('values')
        display = "Volume"

      dataSeries = @splitData(data)

      container = $('#val-chart')[0]
      graphOpts =
        title: display
        colors: ['green', 'red', 'orange']
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
          trackFormatter: (o)->
            date = new Date(parseInt(o.x))
            return date.getMonth() + 1 + "/" + date.getDate() + "/" + date.getFullYear() + ", " + o.y
        markers:
          show: true

      graph = Flotr.draw(container, dataSeries, graphOpts)

    varianceChart: ->
      yLabel = 'Variance from Target'
      m = @model
      max = 100
      min = -100

      if m.get('display') == 'rate'
        data = m.get('rates')
      else
        data = m.get('values')

      dataSeries = @splitData(data)
      target = m.get('targetVal')

      dataSeries = _.map(dataSeries, (series, i)->
        _.map(series, (val)->
          if i == 0
            variance = Math.abs(target - val[1])
          else
            variance =  Math.abs(target - val[1]) * -1

          if variance > max
            max = variance

          if variance < min
            min = variance

          return [val[0], variance]
        )
      )

      aMin = Math.abs(min)

      if max > aMin
        min = max * -1
      else if aMin > max
        max = aMin

      container = $('#rate-chart')[0]
      graphOpts =
        title: "Variance"
        colors: ["green", "red", "orange"]
        bars:
          show: true
          barWidth: 1000 * 43000
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
          trackFormatter: (o)->
            date = new Date(parseInt(o.x))
            return date.getMonth() + 1 + "/" + date.getDate() + "/" + date.getFullYear() + ", " + o.y

      graph = Flotr.draw(container, dataSeries, graphOpts)

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

        if @model.get('target')
          @varianceChart()

      @$el.modal()
