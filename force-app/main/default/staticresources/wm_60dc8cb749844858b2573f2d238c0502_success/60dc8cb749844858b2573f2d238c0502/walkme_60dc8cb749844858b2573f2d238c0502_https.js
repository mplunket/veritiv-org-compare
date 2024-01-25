﻿/*!
 * WalkMe
 * http://www.walkme.com/
 *
 * Copyright 2012, WalkMe ltd
 */
function WalkmeSnippet(){window._walkmeInternals=window._walkmeInternals||{},U("snippetStartInit");var l,i,f,g,_,p,t,h=this,e=!1,n="40",v={publish:0,preview:1},b=v.publish;try{t=window.localStorage}catch(D){}function S(e){p.snippetLog.push(e)}function k(){window["walkme_custom_settings_data"]?(S("lso"),r(walkme_custom_settings_data)):(S("lsp"),U("settingsFileStartLoad"),w(g,null,p.isSelfHosted,"fixedCallback",r))}function r(e){if(U("settingsFileEndLoad"),!E()&&window.document.dontLoadTriangle)return window["walkme_snippet_blocked"]=!0,p.blocked=!0,void(p.continueLoad=function(){a(e)});S("cls"),a(e)}function a(e){i=I(e);var n=window.walkme_settings_callback||window.walkme&&window.walkme.walkme_settings_callback||window._walkmeConfig&&window._walkmeConfig.walkme_settings_callback;n&&n(i);var t=A("walkme_is_enabled_override");if(t!==undefined){if("0"===t)return}else if(!e.IsEnabled)return;!function r(e){if(window.walkme_custom_jquery)window.mtjQuery=walkme_custom_jquery,o();else{var n=O("walkmeCustomjQueryUrl");if(0!=n&&(e=n),p.localjQueryUrlPath){var t=e.lastIndexOf("/"),i=e.substring(t+1);e=p.localjQueryUrlPath+i}w(e,o)}}(e.jQueryFile)}function o(){if(U("jQueryScriptLoaded"),window["mtjQuery"]==undefined)return;if(e)return;e=!0,window.walkme_custom_jquery||mtjQuery.noConflict(),i.WaitDocumentReady?(S("wdr"),mtjQuery(document).ready(function(){s(i)})):(S("ndr"),s(i))}function s(e){U("jQueryDocumentReady");try{!function t(e){var n=O("wm-prelibjs");n&&(e.PreLibJsFile=n);e.PreLibJsFile&&""!=e.PreLibJsFile?(window["walkme_pre_lib_loaded"]=function(){window["walkme_pre_lib_loaded"]=function(){try{console.log("walkme_pre_lib_loaded was called twice.")}catch(D){}},u(e)},U("preLibStartLoad"),w(e.PreLibJsFile)):u(e)}(e)}catch(n){}}function u(e){w(function t(){var e;p.localLibUrl&&(e=p.localLibUrl);var n=O("walkmeCustomeLibUrl");if(0!=n)return n;return e}()||e.LibFile)}function y(){return E()?"wmPreviewSnippet":"wmSnippet"}function E(){return b==v.preview}function L(){this.recorderServer="###RECORDER_SERVER_NAME###",this.cdnServerName="###AUTO_DETECT###",this.storage={"st":{"*":"proxy"},"ss":1},this.userGuids=["60dc8cb749844858b2573f2d238c0502"],window.walkme_custom_cdn_server&&(this.cdnServerName=walkme_custom_cdn_server),window.walkme_custom_app_server&&(this.recorderServer=walkme_custom_app_server),window.walkme_custom_data_url?this.triangleUrl=walkme_custom_data_url:this.triangleUrl=this.cdnServerName+"###SPECIAL_TRIANGLE_FILE###",window.walkme_custom_datafile_url?this.datafilesArray=walkme_custom_datafile_url:this.datafilesArray="###SPECIAL_DATA_FILE###",window.walkme_custom_widget_url?this.widgetUrl=walkme_custom_widget_url:this.widgetUrl="###SPECIAL_WIDGET_FILE###"}function I(e){if(_==undefined)return e;return function i(e,n){{if("string"==typeof e)return n(e);if("[object Array]"===Object.prototype.toString.call(e)){for(var t=0;t<e.length;t++)e[t]=i(e[t],n);return e}if("object"==typeof e){for(var t in e)Object.hasOwnProperty.call(e,t)&&(e[t]=i(e[t],n));return e}}return e}(e,function(e){return e.replace("###AUTO_DETECT###",_)})}function O(e){try{if(t){var n=t.getItem(e);if(null!=n)return n}}catch(D){}return!1}function T(e){return new RegExp(e,"i").test(navigator.userAgent||navigator.vendor||window.opera)}function w(e,n,t,i,r){var a=document.createElement("script");a.async=!0,window._walkmeConfig=window._walkmeConfig||{},t&&!0!==window._walkmeConfig.disableWMTS&&(e+=(-1==e.indexOf("?")?"?":"&")+"_wmts="+function o(){return(new Date).getTime()}()),a.src=e,a.id="mt_script",n&&(a.onload=n,a.onreadystatechange=n),function s(n,t){if(n&&t){var i=window[n];window[n]=function(e){window[n]=i,t(e)}}}(i,r),function u(){l=l||document.getElementsByTagName("head")[0];return l}().appendChild(a)}function C(e){return e.replace(/^\s+|\s+$/g,"")}function A(e,n){var t=n?O(e):function a(e){var n,t,i,r=document.cookie.split(";");for(n=0;n<r.length;n++)if(t=r[n].substr(0,r[n].indexOf("=")),i=r[n].substr(r[n].indexOf("=")+1),(t=t.replace(/^\s+|\s+$/g,""))==e)return i;return!1}(e);if(!1!==t)return t;var i=window[e]||window.walkme&&window.walkme[e]||window._walkmeConfig&&window._walkmeConfig[e];if(i!=undefined)return i;return undefined}function U(e){try{var n,t,i=(new Date).getTime();t=_walkmeInternals.timing?i-(n=_walkmeInternals.timing).list[n.list.length-1].time:((n=_walkmeInternals.timing={}).map={},n.list=[],n.delta=[],0),n.map[e]=i,n.list.push({name:e,time:i}),n.delta.push({name:e,delta:t})}catch(D){}}function x(e,n){try{S(e),console.log(n)}catch(D){}}if(this.getSnippetVersion=function(){return n},this.getSettingsFile=function(){return i},this.getServerSettings=function(){return f},this.fixAutoDetectPaths=I,!_walkmeInternals.__tti&&"PerformanceObserver"in window){var c=[];if("PerformanceResourceTiming"in window&&c.push("resource"),"PerformancePaintTiming"in window&&c.push("paint"),"PerformanceLongTaskTiming"in window&&c.push("longtask"),"LargestContentfulPaint"in window&&c.push("largest-contentful-paint"),0<c.length){var d=_walkmeInternals.__tti={e:[]};d.o=new PerformanceObserver(function(e){d.e=d.e.concat(e.getEntries())}),d.o.observe({entryTypes:c})}}setTimeout(function P(){var e;window._walkmeConfig=window._walkmeConfig||{},(p=_walkmeInternals).snippetLog=[],p.addTimeStamp=U,S("ish"),p.isSelfHosted="true"=="true",S("ssm"),function r(){"###IS_PREVIEW_MODE###"=="true"&&(b=v.preview)}(),f=new L,S("lsu");var n=false==1||false&&function a(){return function e(){return T("android|blackberry|iemobile|ip(ad|hone|od)|phone|symbian|windows (ce|phone)")}()}();if(n?(S("lsm"),e="###GET_MOBILE_SETTINGS_URL###",_walkmeConfig.platform=3):(S("lsw"),e="###AUTO_DETECT###/settings.txt"),-1<f.cdnServerName.indexOf("###AUTO_DETECT###")&&(S("lad"),_=function u(e,n){for(var t=document.getElementsByTagName("script"),i="###MOBILE_WEB_USER_GUID###",r="60dc8cb749844858b2573f2d238c0502",a=0;a<t.length;a++){var o=t[a].src;if(o&&0<o.indexOf("walkme_")){if(e){a=o.indexOf(e);var s=C(o.substr(0,a));S("dst")}else{a=o.indexOf("walkme_"),s=C(o.substr(0,a-1));S("dso")}return n&&p.isSelfHosted&&(s=s.split(r).join(i),S("dsm")),s}}return""}(f.cdnServerName.replace("###AUTO_DETECT###",""),n),f=I(f)),e=function o(e){var n=A("walkme_segmented_settings_"+"60dc8cb749844858b2573f2d238c0502"+"_"+"32",!0);if(n)return S("seg"),n;return e}(e),g=function s(e){var n="walkme_custom_user_settings_",t=A(n+"url",!0),i=A(n+"guid",!0),r=A(n+"env",!0),a=function o(){var e=O("walkMe_wm-settings-cache-bust");if(e){var n=/{"val":"(true|false)","exp":(\d+)}/.exec(e);if(n&&"true"==n[1]&&(new Date).getTime()<parseInt(n[2]))return!0}return window.walkme&&window.walkme.walkme_settings_cache_bust||window._walkmeConfig.walkme_settings_cache_bust||!1}();t&&(e=t);i&&(e=e.replace(/(users\/)([^\/]*)(\/)/,"$1"+i+"$3"));!r&&""!==r||(r&&(r+="/"),e=e.replace(/(users\/[^\/]*\/)(.*)(sett)/,"$1"+r+"$3"));e=I(e),p.settingsUrl=e,S(a?"cb":"ncb"),a&&(e+="?forceUpdate="+(new Date).getTime());return e}(e),f=function l(e){return e}(f),S("cli"),_walkmeConfig.smartLoad){if(top!=window&&!function w(){try{if(parent.location.href)return!1}catch(e){}return!0}()&&function c(){try{var e=window;do{if((e=e.parent.window)._walkmeConfig)return!0}while(e!=top)}catch(n){}return!1}())return}else if(1!=window["walkme_load_in_iframe"]&&top!=window)return;if(S("cuc"),!n&&!function d(){if("1"===A("walkme_dont_check_browser")||E())return!0;var e=function t(){var e={init:function(){this.browser=this.searchString(this.dataBrowser)||"An unknown browser",this.version=this.searchVersion(navigator.userAgent)||this.searchVersion(navigator.appVersion)||"an unknown version",this.OS=this.searchString(this.dataOS)||"an unknown OS"},searchString:function(e){for(var n=0;n<e.length;n++){var t=e[n].string,i=e[n].prop;if(this.versionSearchString=e[n].versionSearch||e[n].identity,t){if(-1!=t.indexOf(e[n].subString))return e[n].identity}else if(i)return e[n].identity}},searchVersion:function(e){var n=e.indexOf(this.versionSearchString);if(-1==n)return;return parseFloat(e.substring(n+this.versionSearchString.length+1))},dataBrowser:[{string:navigator.userAgent,subString:"Chrome",identity:"Chrome"},{string:navigator.userAgent,subString:"OmniWeb",versionSearch:"OmniWeb/",identity:"OmniWeb"},{string:navigator.vendor,subString:"Apple",identity:"Safari",versionSearch:"Version"},{prop:window.opera,identity:"Opera",versionSearch:"Version"},{string:navigator.vendor,subString:"iCab",identity:"iCab"},{string:navigator.vendor,subString:"KDE",identity:"Konqueror"},{string:navigator.userAgent,subString:"Firefox",identity:"Firefox"},{string:navigator.vendor,subString:"Camino",identity:"Camino"},{string:navigator.userAgent,subString:"Netscape",identity:"Netscape"},{string:navigator.userAgent,subString:"MSIE",identity:"Explorer",versionSearch:"MSIE"},{string:navigator.userAgent,subString:"Trident",identity:"Explorer",versionSearch:" rv"},{string:navigator.userAgent,subString:"Edge",identity:"Edge"},{string:navigator.userAgent,subString:"Gecko",identity:"Mozilla",versionSearch:"rv"},{string:navigator.userAgent,subString:"Mozilla",identity:"Netscape",versionSearch:"Mozilla"}],dataOS:[{string:navigator.platform,subString:"Win",identity:"Windows"},{string:navigator.platform,subString:"Mac",identity:"Mac"},{string:navigator.userAgent,subString:"iPhone",identity:"iPhone/iPod"},{string:navigator.platform,subString:"Linux",identity:"Linux"}]};if(e.init(),"Chrome"==e.browser||"Firefox"==e.browser||"Safari"==e.browser&&"Windows"!=e.OS)return!0;if("Explorer"==e.browser&&7<=e.version)return!0;return x("icb","WalkMe: Incompatible browser."),!1}(),n=function i(){return!function e(){return T("android.+mobile|blackberry|iemobile|ip(hone|od)|phone|symbian|windows (ce|phone)")}()&&!function t(){var e=Math.max(screen.width,screen.height),n=Math.min(screen.width,screen.height);return e<800||n<600}()}();return e&&n}()){try{S("bns"),walkme_browser_not_supported()}catch(D){}return}S("exl");var t=window[y()],i=p.blocked;if(S("lsl"),function m(){var e=y();window[e]=h}(),S("ipm"),!E()&&(S("clt"),window.document.dontLoadTriangle))return S("bsl"),window["walkme_snippet_blocked"]=!0,p.blocked=!0,void(p.continueLoad=k);S("slb"),t&&!i&&x("slt","WalkMe Snippet was loaded twice"),S("lss"),k(),S("eok")},0)}new WalkmeSnippet;