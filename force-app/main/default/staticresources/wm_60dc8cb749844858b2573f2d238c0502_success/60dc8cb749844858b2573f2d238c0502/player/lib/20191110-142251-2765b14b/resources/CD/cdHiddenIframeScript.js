try{window.send=function(e,t){"object"==typeof window.targetWindow.postMessage?setTimeout(function(){window.targetWindow.postMessage(e,t)},0):window.targetWindow.postMessage(e,t)},window.parent._walkmeInternals.hiddenIframeCallback()}catch(err){}