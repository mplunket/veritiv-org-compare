({
    init : function (component) {
        //Find the component with aura:id "flowData"
        var flow = component.find("flowData");
        
        //Pass the input parameters
    	var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : component.get("v.recordId")
            }
        ];
        
        //Invoke flow in component and reference unique name
        flow.startFlow("Case_Create_Related_Team_Case", inputVariables);
	},
})