window._walkmeWebpackJP&&(window._walkmeWebpackJP=window._walkmeWebpackJP||[]).push([[20],{886:function(t,e,n){(function(){var e=n(887),i=n(888),o={init:function(){window.customElements.get("visual-design-drawable")||window.customElements.define("visual-design-drawable",i);var t=e.get("WebComponentDrawableCreator");o.create=t.create},services:["WebComponentDrawableCreator"],types:[]};n(889),n(69).registerApi(o,e),t.exports=o}).call(window)},887:function(t,e,n){(function(){t.exports=n(69).create()}).call(window)},888:function(t,e,n){(function(){const e=n(887),i=e.get("VisualDesignDrawableDrawer"),o=e.get("Consts"),a=e.get("wmjQuery"),s=e.get("ImagesLoadedListener");t.exports=class extends HTMLElement{constructor(){super(),this._shadowRoot=this.attachShadow({mode:"open"});const t=o.EVENTS.Drawables;this._actionClickedEventName=t.ActionClicked,this._xButtonClickedEventName=t.XButtonClicked}init(t,e){e.width="100%",e.height="100%",t.RootVisualElement.Style=e,this._wrapper=i.draw(t),this._shadowRoot.appendChild(this._wrapper);const n=a(this._wrapper);n.on(this._actionClickedEventName,this.onActionClicked.bind(this)),n.on(this._xButtonClickedEventName,this.onXButtonClicked.bind(this)),(new s).waitForAll(this._wrapper).then(()=>{this.dispatchEvent(new CustomEvent("all-images-loaded"))})}onActionClicked(t,e){const n=new CustomEvent(this._actionClickedEventName,{detail:e});this.dispatchEvent(n)}onXButtonClicked(){const t=new CustomEvent(this._xButtonClickedEventName);this.dispatchEvent(t)}}}).call(window)},889:function(t,e,n){(function(){n(887).register("WebComponentDrawableCreator").asCtor(function(t,e,n,i,o,a){let s;this.create=function(n){const r=document.createElement("visual-design-drawable"),l=function(t){const n=i.splitRootStyle(t),o=a.get(t),s=e.extend({},o.innerStyle,n.innerStyle),r=e.extend({},o.outerStyle,{border:"solid transparent"},n.outerStyle);return{innerStyle:s,outerStyle:r}}(n.RootVisualElement.Style);return o.setDefaultAttributes(r,n),t.set(r,l.outerStyle),r.init(n,l.innerStyle),function(t){const n=e(t);t.addEventListener(s,t=>{n.trigger(s,t.detail),t.stopImmediatePropagation()})}(r),r},s=n.EVENTS.Drawables.ActionClicked}).dependencies("CssAttributeSetter, wmjQuery, Consts, RootStyleSplitter, WrapperAttributesSetter, DefaultWrapperStyleProvider")}).call(window)}}]);