define [
  'jquery'
  'underscore'
  'backbone'
  'cs!models/metric'
], ($, _, Backbone, Metric) ->
  class MetricCollection extends Backbone.Collection
    model: Metric

    findByPath: (path)->
      @where(path: path)[0]

    relate: ->
      findRelations = (model) ->
        if model.get('total')
          model.set('rel_total', @findByPath(model.get('total')))

      _.each(@models, findRelations, @)


