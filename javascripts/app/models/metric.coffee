define [
  'jquery'
  'backbone'
  'moment'
], ($, Backbone, moment) ->
  class Metric extends Backbone.Model
    defaults:
      "path":  "localhost"

    graphite_url: ->
      url = 'http://' + @get('host')
      url += '/render?target=' + @get('path')
      url += '&format=json&jsonp=?'

    graphite: (from, to, cb) ->
      url = @graphite_url()
      if from
        url += '&from=' + from

      if to
        url += '&until=' + to

      $.getJSON url, cb

    gValue: ->
      @graphite '-30d', '-1d', (data) =>
        values = []
        $(data[0].datapoints).each (i, d) ->
          date = moment.unix(d[1]).toDate()
          values.push({date: date, seconds: d[1], value: d[0]})

        @set 'values', values
