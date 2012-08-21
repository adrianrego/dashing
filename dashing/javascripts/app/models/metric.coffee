define [
  'jquery'
  'underscore'
  'backbone'
  'moment'
], ($, _, Backbone, moment) ->
  class Metric extends Backbone.Model
    defaults:
      "size":  "small"
      "display": "raw"

    initialize: (attributes) ->
      @on 'change:values', @updateStats

    updateStats: ->
      if @get('display') == 'rate' and @get('rates')
        data = @get('rates')
      else
        data = @get('values')
        
      @set 'value', 0
      @set 'mean', 0
      @set 'variance', 0
      @set 'stddev', 0

      if data.length > 0
        @set 'value', _.last(data).value
        @updateStatus()

        sum = _.reduce(data, ((memo, val) ->
          memo + val.value), 0)

        @set('mean',  Math.round(sum / data.length))

        sq_diff = (val) ->
          diff = val.value - @get('mean')
          return diff * diff

        diffs = _.map(data, sq_diff, @)
        dsum = _.reduce(diffs, ((memo, num) ->
          memo + num), 0)

        @set('variance',  dsum / diffs.length)
        @set('stddev', Math.round(Math.sqrt(@get('variance'))))

    relatedMetrics: ->
      if @get('display') == 'rate'
        volume = @get('values')
        totals = @get('rel_total').get('values')

        rates = []

        _.times(volume.length, (i) ->
          if volume[i].seconds == totals[i].seconds and totals[i].value > 0
            rate = Math.round((volume[i].value / totals[i].value) * 100)
          else
            rate = 0
          rates.push({value: rate, date: volume[i].date, seconds: volume[i].seconds})
        )

        @set('rates', rates)

      @updateStats()

    updateStatus: ->
      if @get('target')
        target = @getCompareAndVal(@get('target'))
        @set 'targetVal', target[1]

        if @compareVal(target, @get('value'))
          @set('status', 1)
        else
          @set('status', -1)

      if @get('warning')
        warning = @getCompareAndVal(@get('warning'))

        if @get('status') < 0 and @compareVal(warning, @get('value'))
          @set('status', 0)

    compareVal: (comparable, val)->
      if comparable[0] == '<'
        res = val < comparable[1]
      else if comparable[0] == '<='
        res = val <= comparable[1]
      else if comparable[0] == '>'
        res = val > comparable[1]
      else if comparable[0] == '>='
        res = val >= comparable[1]
      else if comparable[0] == '='
        res = val == comparable[1]

      return res

    getCompareAndVal: (arg)->
      if parseInt(arg) >= 0
        val = arg
        comp = '>='
      else if parseInt(arg[1]) >=0
        comp = arg[0]
        val = arg.slice(1)
      else
        comp = arg.slice(0,2)
        val = arg.slice(2)

      return [comp, parseInt(val)]

    graphite_url: (format)->
      url = 'http://' + @get('host')
      url += '/render?target=' + @get('path')

      if format == undefined
        format = 'json'

      if format == 'json'
        url += '&format=json&jsonp=?'
      else
        url += '&format=' + format

    graphite: (options) ->
      url = @graphite_url()
      if options.from
        url += '&from=' + options.from

      if options.until
        url += '&until=' + options.until

      $.getJSON url, options.success if options.success

    gValue: (from, gUntil)->
      @graphite
        from: from,
        until: gUntil,
        success: (data) =>
          values = []
          
          if data.length > 0 and data[0].datapoints
            $(data[0].datapoints).each (i, d) ->
              date = new Date(0)
              offset = date.getTimezoneOffset() * 60
              date.setTime((d[1] + offset )*1000)

              if d[0] == null
                val = 0
              else
                val = d[0]

              tmpVal = val + ""
              if tmpVal.indexOf('.') > 0
                val = parseFloat(val.toFixed(2))

              values.push({date: date, seconds: d[1], value: val})

          @set 'values', values
