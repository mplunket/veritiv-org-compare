(window._walkmeWebpackJP=window._walkmeWebpackJP||[]).push([[23],{961:function(a,e,o){(function(){var e=o(962),i={init:function n(){e.get("DataLibLoader").start()},services:[],types:[]};!function t(){o(963)}(),o(69).registerApi(i,e),a.exports=i}).call(window)},962:function(e,i,n){(function(){e.exports=n(69).create()}).call(window)},963:function(e,i,n){(function(){n(962).register("DataLibLoader").asCtor(function e(i,n,t,a,o){this.start=function r(){var e=i.getSettingsFile();n.addScriptWithCallback(e.Components.DataLib,"onDataLibReady",function(){return{wmDependencies:{settingsFile:i,siteConfigManager:t,auditSourceManager:a,libDestroyer:o}}},function(){o.removeWalkMe("Failed loading data lib")})}}).dependencies("SettingsFile, CommonUtils, SiteConfigManager, AuditSourceManager, LibDestroyer")}).call(window)}}]);