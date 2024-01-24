({
    doInit: function(component, event, helper) {
        window.addEventListener("message", function(event) {
            const previewIframe = component.find("preview-iframe");
            
            if (previewIframe) {
                const iframe = previewIframe.getElement();

                if (isNaN(event.data)) return; 
                
                const height = parseInt(event.data);
                console.log("hhhhhhhhhhhh : " + height);
                iframe.height = height + "px";
            }
            
        }, false);  
    },
    
    updatePreview: function(component, event, helper) {
        const fields = component.get("v.fields");
		let iframeSrc = "/apex/CPLPreviewPage?";
            
        if (fields.Id) {
            delete fields.Id;
        }

		let urlParams = [];
		for (let field in fields) {
            if (fields[field]) {
                urlParams.push(encodeURI(field + "=" + fields[field]));
            }
		}
		
		iframeSrc += urlParams.join("&");
        
        console.log("iframeSrc : " + iframeSrc);
        console.log("urlParams : " + urlParams);
		
		const iframe = component.find('preview-iframe').getElement();
        if (iframe) {
            iframe.src = iframeSrc;
		}
    }
})