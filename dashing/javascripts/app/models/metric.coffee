define [
  'jquery'
  'underscore'
  'backbone'
  'moment'
], ($, _, Backbone, moment) ->
  class Metric extends Backbone.Model
    defaults:
      "size":  "small"

    initialize: (attributes) ->
      @on 'change:values', @updateStats

    updateStats: ->
      @set 'value', _.last(@get('values')).value
      @updateStatus()

      sum = _.reduce(@get('values'), ((memo, val) ->
        memo + val.value), 0)

      @set('mean',  Math.round(sum / @get('values').length))

      sq_diff = (val) ->
        diff = val.value - @get('mean')
        return diff * diff

      diffs = _.map(@get('values'), sq_diff, @)
      dsum = _.reduce(diffs, ((memo, num) ->
        memo + num), 0)

      @set('variance',  dsum / diffs.length)
      @set('stddev', Math.round(Math.sqrt(@get('variance'))))

    updateStatus: ->
      if @get('target')
        target = @getCompareAndVal(@get('target'))
        @set 'targetVal', target[1]

        if @compareVal(target)
          @set('status', 1)
        else
          @set('status', -1)

      if @get('warning')
        warning = @getCompareAndVal(@get('warning'))

        if @get('status') < 0 and @compareVal(warning)
          @set('status', 0)

    compareVal: (comparable)->
      val = @get('value')

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

    graphite_url: ->
      url = 'http://' + @get('host')
      url += '/render?target=' + @get('path')
      url += '&format=json&jsonp=?'

    graphite: (options) ->
      url = @graphite_url()
      if options.from
        url += '&from=' + options.from

      if options.until
        url += '&until=' + options.until

      $.getJSON url, options.success if options.success

    gValue: ->
      @graphite
        from:'-30d',
        until:'-1d',
        success: (data) =>
          values = []
          $(data[0].datapoints).each (i, d) ->
            date = new Date(0)
            offset = date.getTimezoneOffset() * 60
            date.setTime((d[1] + offset )*1000)

            if d[0] == null
              val = 0
            else
              val = d[0]

            values.push({date: date, seconds: d[1], value: val})

          @set 'values', values
