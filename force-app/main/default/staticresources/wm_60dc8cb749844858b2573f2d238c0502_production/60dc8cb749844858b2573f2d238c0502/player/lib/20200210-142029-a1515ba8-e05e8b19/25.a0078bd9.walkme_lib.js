window._walkmeWebpackJP&&(window._walkmeWebpackJP=window._walkmeWebpackJP||[]).push([[25],{1398:function(t,s,u){"use strict";u.r(s),function(r){u.d(s,"Aggregator",function(){return c});var t=u(1),e=u(328),n=u(1399),a=u(500),o=u(1400),c=(i.prototype.add=function(t,r){var e=this;this._durations.push(t),r.forEach(function(t){return e._contributors.add(t)})},i.prototype.flush=function(t){void 0===t&&(t=!1);var r=Object(a.a)();n.a.get("PerformanceDataSender").send(Object(o.a)(r-this._lastFlush,this._durations),t),this.resetData(r)},i.prototype.resetData=function(t){this._lastFlush=t,this._contributors=new r,this._durations=[]},i=Object(t.__decorate)([Object(e.c)("Aggregator",{ctx:n.a,dependencies:"Config,TimerManager,WindowBeforeUnloadHandler"})],i));function i(t,r,e){var n=this;this.resetData(Object(a.a)()),r.playSetInterval(function(){return n.flush()},t.interval||1e4),e.register(function(){return n.flush(!0)})}}.call(this,u(380))},1399:function(t,r,e){"use strict";e.d(r,"a",function(){return a});var n=e(325),a=Object(n.create)()},1400:function(t,r,e){"use strict";e.d(r,"a",function(){return n});var o=e(1),c=e(1401);function n(t,r){t=Math.round(t);var e=Math.round(r.reduce(function(t,r){return t+r},0)),n=Math.round(r.reduce(function(t,r){return t+r*r},0)),a=Math.round(Math.max.apply(Math,Object(o.__spreadArrays)(r,[0])));return{type:c.a.score,amount:a,sum:e,total:n,count:r.length,duration:t}}},1401:function(t,r,e){"use strict";var n,a;e.d(r,"a",function(){return n}),(a=n=n||{})[a.score=1]="score"},1402:function(t,s,u){"use strict";u.r(s),function(t){u.d(s,"AsapDataCollector",function(){return c});var r=u(1),e=u(500),n=u(1403),a=u(328),o=u(1399),c=(i.prototype.collect=function(t){var r=this;this.contributors.add(t),this.start||(this.start=Object(e.a)(),Object(n.a)(function(){return r.process()}))},i.prototype.process=function(){var t=Object(e.a)()-this.start;17<t&&this.aggregator.add(t,this.contributors),this.resetData()},i.prototype.resetData=function(){this.contributors=new t,this.start=null},i=Object(r.__decorate)([Object(a.c)("Collector",{ctx:o.a,dependencies:"Aggregator"})],i));function i(t){this.aggregator=t,this.resetData()}}.call(this,u(380))},1403:function(t,e,n){"use strict";(function(r){function t(t){r.resolve().then(t)}n.d(e,"a",function(){return t})}).call(this,n(2))},1404:function(t,c,i){"use strict";i.r(c),function(r){i.d(c,"init",function(){return t});var e=i(1399),n=i(374),a=i(386),o=i(75);function t(){e.a.register("Config").asInstance(Object(n.getExperiment)(n.Experiments.DataCollector).config||{});var t=e.a.get("Collector");r.get("Instrumenter").getStream().pipe(Object(a.c)(function(t){return t.__stage==o.a.Start})).subscribe(function(){return t.collect()})}}.call(this,i(3))}}]);