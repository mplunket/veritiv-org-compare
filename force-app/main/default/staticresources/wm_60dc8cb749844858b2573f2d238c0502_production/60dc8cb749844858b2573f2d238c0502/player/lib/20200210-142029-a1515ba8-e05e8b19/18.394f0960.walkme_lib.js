window._walkmeWebpackJP&&(window._walkmeWebpackJP=window._walkmeWebpackJP||[]).push([[18],{1307:function(n,e,t){(function(t,e){(function(){t.register("IntegrationCenterWebhooksInitializer").asCtor(function(g,u,d,w,p,b,k,m,S,h,f,C){this.start=function(c){return new e(function(e,t){try{var n=w.getSettingsFile(),r=w.getCdnServerName();if(k.isSelfHosted){if(!f.isFeatureEnabled(I))return e();r=n.PlayerApiServer&&n.PlayerApiServer.replace("papi","cdn")}var i=(l=r,C&&C.getItem("wm-integration-center-webhooks-public-path")||l+"/ic/webhooks/1/"),a=(s=w.getSettingsFile(),C&&C.getItem("wm-integration-center-webhooks-api-base-url")||s.PlayerApiServer),o=i+"main.js";g.addScriptWithCallback(o,"onIntegrationCenterWebhooksReadyCb",function(){return{resolve:e,reject:t,wmDependencies:{publicPath:i,apiBaseUrl:a,dataFile:c,wmInternals:k,consts:d,userGuidContainer:b,wmjQuery:p,wmLogger:u,clientStorageManager:m,settingsFile:w,classWalkMeAPI:S,eventSender:h}}},function(){t(new Error("Failed to addScriptWithCallback for: "+o))})}catch(e){t(e)}var s,l})}}).dependencies("CommonUtils, Logger, Consts, SettingsFile, wmjQuery, UserGuidContainer, WmInternals, ClientStorageManager, ClassWalkMeAPI, EventSender, FeaturesManager, LocalStorageService");var I="IntegrationCenterWebhooksAllowedInSelfHosted";n.exports={init:function(e){return t.get("IntegrationCenterWebhooksInitializer").start(e).catch(function(e){t.get("Logger").error(e)})}}}).call(window)}).call(this,t(3),t(2))}}]);