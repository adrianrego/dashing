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
    moment: "../libs/moment",
    flotr2: "../libs/flotr2-amd",
    bean: "../libs/bean",
    jquery: "../libs/require-jquery"
  },
  hbs:{
    templateExtension : 'hbs',
    disableI18n: true
  },
  urlArgs: "bust=" + (new Date()).getTime(),
  shim: {
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
