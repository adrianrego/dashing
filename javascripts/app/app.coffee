define [
  'jquery'
  'cs!collections/metrics'
  'cs!models/metric'
  'cs!views/dashboard'
], ($, MetricCollection, Metric, MetricDashboardView) ->
  $ ->
    metrics = new MetricCollection
    metrics.on 'add', (model) ->
       d = new MetricDashboardView(model: model)
       d.render()

    $.getJSON 'metrics.json', (data) ->
      $.each data.metrics, (i, m) ->
        if not m.host
          m.host = data.graphite

        model = new Metric(m)

        $.when(model.gValue()).done (md) ->
          metrics.add model
