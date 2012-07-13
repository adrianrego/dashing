define [
  'jquery'
  'backbone'
  'cs!models/metric'
], ($, Backbone, Metric) ->
  class MetricCollection extends Backbone.Collection
    model: Metric
