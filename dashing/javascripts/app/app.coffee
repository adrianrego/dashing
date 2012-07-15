define [
  'jquery'
  'underscore'
  'cs!collections/metrics'
  'cs!models/metric'
  'cs!views/row'
], ($, _, MetricCollection, Metric, RowView) ->
  $ ->
    renderMetrics = (collection) ->
      row = new RowView()
      row.render()

      _.each collection.models, (m)->
        added = row.add(m)

        if not added
          row = new RowView()
          row.render()

          row.add(m)

    metrics = new MetricCollection()
    metrics.on 'finishedLoading', ->
      sizes =
        large: []
        medium: []
        small: []

      _.each @models, (m)->
        sizes[m.get('size')].push(m)

      @models = _.union(sizes.large, sizes.medium, sizes.small)
      @relate()

      renderMetrics(@)

    modelsNotLoaded = 0
    $.getJSON 'metrics.json', (data) ->
      modelsNotLoaded = data.metrics.length
      $.each data.metrics, (i, m) ->
        if not m.host
          m.host = data.graphite

        model = new Metric(m)
        $.when(model.gValue()).done (md) ->
          metrics.add model
          modelsNotLoaded = modelsNotLoaded - 1

          if modelsNotLoaded == 0
            metrics.trigger 'finishedLoading'
