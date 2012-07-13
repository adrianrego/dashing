require.config({
  paths: {
    cs: "../libs/cs",
    CoffeeScript: "../libs/coffee-script",
    hbs: "../libs/hbs",
    Handlebars: "../libs/Handlebars",
    backbone: "../libs/backbone",
    underscore: "../libs/underscore",
    modal: "../libs/bootstrap/bootstrap-modal",
    transition: "../libs/bootstrap/bootstrap-transition",
    d3: "../libs/d3.v2",
    nvd3: "../libs/nv.d3",
    moment: "../libs/moment",
    jquery: "../libs/require-jquery"
  },
  hbs:{
    templateExtension : 'hbs',
    disableI18n: true
  },
  urlArgs: "bust=" + (new Date()).getTime(),
  shim: {
    nvd3: {
      deps: ["d3"],
      exports: "nv"
    },
    modal: ["jquery", "transition"],
    underscore: {
      exports: "_"
    },
    backbone: {
      deps: ["underscore", "jquery"],
      exports: "Backbone"
    }
  }
});

require(["cs!app"]);
