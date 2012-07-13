define [
  'jquery'
  'underscore'
  'backbone'
  'moment'
], ($, _, Backbone, moment) ->
  class Metric extends Backbone.Model
    defaults:
      "path":  "localhost"

    initialize: (attributes) ->
      @on 'change:values', @updateLastValue
      @on 'change:value', @updateStatusClass

    updateLastValue: ->
      validValues = _.filter(@get('values'), (v) ->
        return v.value != null)

      @set 'value', _.last(validValues).value

    updateStatusClass: ->
      target = @getCompareAndVal(@get('target'))
      warning = @getCompareAndVal(@get('warning'))

      if @compareVal(target)
        @set('status', 'btn-success')
      else
        @set('status', 'btn-danger')

      if @compareVal(warning)
        @set('status', 'btn-warning')
      
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
        until: '-1d', 
        success: (data) =>
          values = []
          $(data[0].datapoints).each (i, d) ->
            date = moment.unix(d[1]).toDate()
            values.push({date: date, seconds: d[1], value: d[0]})
        
          @set 'values', values
