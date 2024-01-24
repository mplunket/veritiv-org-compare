({
	getInput : function(component, event, helper) {
        let params = event.getParams();
        console.log('params ' + JSON.stringify(params));
        
        let fieldsOut = component.get("v.fields");
        let fields = [];    
        fields.push(component.find('inputField'));
        fields.forEach((f)=>{
            let v = f.get("v.value");            
            let n = f.get("v.fieldName");            
            let fieldOut = fieldsOut.find(obj =>{
             return obj.apiFieldName === f.get("v.fieldName");
        	});
        	fieldOut["defaultValue"]=f.get("v.value");
        });
        
        return fieldsOut;
	}
    

})