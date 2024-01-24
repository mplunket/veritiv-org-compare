({
    /*
	 fetchPickListVal: function(component, fieldName, elementId) {
        var action = component.get("c.getselectOptions1");
        // var qt  = component.get("v.qtObj");
        action.setParams({
            "objObject": component.get("v.objInfo"),
            "fld": fieldName
        });
        var opts = [];
         alert("test");
         
        action.setCallback(this, function(response) {
            alert(response.getState());
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
 alert("allValues"+JSON.stringify(allValues));
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                alert(elementId);
                alert(component.find(elementId));
                var ObjElement = component.find(elementId);
                ObjElement.set("v.options", opts);
                //.set("v.options", opts);
            }
        });
        $A.enqueueAction(action);
    },*/
    
    
    
    fetchCurrentRecData : function(component,recordId){
        var action = component.get("c.getCurAccData");
        // var qt  = component.get("v.qtObj");
        action.setParams({
            "recId": recordId
        });
       
         
        action.setCallback(this, function(response) {
          //  alert(response.getState());
            if (response.getState() == "SUCCESS") {
                var accRec = response.getReturnValue();
               // alert(response.getReturnValue()['Legacy_Division_Cd__c']);
                if(response.getReturnValue()['Legacy_Division_Cd__c'] != null){
                    var childCmp = component.find('childCmp');   
                    //alert(childCmp);
                    childCmp.sampleMethod(response.getReturnValue()['Legacy_Division_Cd__c'],
                                         response.getReturnValue()['Legacy_System_Cd__c']
                                         ); // Pass the parameters here
                }
                component.set("v.objInfo",accRec);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    
    getPriceHelper: function(component, event){
       // alert(JSON.stringify(component.get("v.objInfo")));
        //alert(component.get("v.selectedLookUpRecord"));
        var prod = component.get("v.selectedLookUpRecord");
        var qty = component.get("v.Quant");
        var quom = component.get("v.picklistSelected");
         var puom = component.get("v.picklistSelected1");
       // alert('quom'+quom);
       // alert('puom'+puom);
      //  alert('prod'+prod);
      //  alert('qty'+qty);
        if(prod == null ){
            alert('Please select Product');
            
        }else if(qty == ''){
        alert('Please select Quantity');
        }else{
              var action = component.get("c.getPriceFromWebService");
        // var qt  = component.get("v.qtObj");
        console.log('quom');
            console.log(quom);
        action.setParams({
            "accRec": component.get("v.objInfo"),
             "prodRec": component.get("v.selectedLookUpRecord"),
            "quom": quom,
            "qty":  qty,
            "puom": puom
        });
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('state'+state);
           // alert(state);
            if(state == 'SUCCESS'){
                // alert('hi'+JSON.stringify(response.getReturnValue()));
                console.log('97');
                console.log(response.getReturnValue());
                
                if(response.getReturnValue() != null){
                    component.set("v.myMap",response.getReturnValue());
                    
                    
                    var pckVal = component.get("v.myMap");
                   // alert(pckVal);
                     var pickArray = [];
                    if(pckVal != null){
                        //  alert(pckVal['QU']);
                        
                        
                        pickArray = pckVal['UOMPicklist'].split(",");
                    }
                    
                   
                    var inputsel = component.find("InputSelectDynamic");
                    var inputsel1 = component.find("InputSelectDynamic1");
                    
                   // alert(pickArray);
                    var opts=[];
                    var slctd = false;
                    for(var i=0;i< pickArray.length;i++){
                        if(pckVal != null){
                            if(pckVal['QU'] != null){
                                if(pickArray[i] == pckVal['QU']){
                                   // alert(pckVal['QU'] +'-->'+ true);
                                    slctd = true;
                                }
                            }
                        }
                        
                        //opts.push({"class": "optionClass", label: pickArray[i], value: pickArray[i], selected: slctd});
                        opts.push({"class": "optionClass", label: pickArray[i], value: pickArray[i]});
                        //options
                    }
                    
                    
                    //testing
					var opts1 = [];
                    var slctd1 = false;
                     for(var i=0;i< pickArray.length;i++){
                        if(pckVal != null){
                            if(pckVal['PU'] != null){
                               // alert(pickArray[i] +'--'+ pckVal['PU']);
                                if(pickArray[i] == pckVal['PU']){
                                   // alert('selected for PU'+ pickArray[i]);
                                    slctd1 = true;
                                  opts1.push({"class": "optionClass", label: pickArray[i], value: pickArray[i], selected: slctd1});
									console.log('1'+opts1);
                                }
                            }
                        }
                         opts1.push({"class": "optionClass", label: pickArray[i], value: pickArray[i]});
                         console.log('opts1'+opts1);
                     }
                    
                    

                    //end
                    
                    console.log('Line 121');
                    console.log(opts);
                     console.log(opts);
                    component.set('v.picklistOptions', opts);
                    component.set('v.picklistOptions1', opts1);
                    if(pckVal != null){
component.set("v.picklistSelected",pckVal['QU']);
component.set("v.picklistSelected1",pckVal['PU']);
                    }

                    
                    console.log(component.get("v.picklistSelected"));
                     console.log(component.get("v.picklistSelected1"));
                    // console.log(pckVal['QU']);
                   // inputsel.set("v.options", null);
                   // inputsel1.set("v.options", null	);
                    inputsel.set("v.options", opts1);
                    inputsel1.set("v.options", opts);
                    
                    
                    component.set("v.lstAccount",opts);
                }else{
                    var cmpTarget = component.find('childCmp');
                   // alert(cmpTarget);
                    $A.util.addClass(cmpTarget, 'childCmp');
                    
                }
                
            }   
            
            
        });
        $A.enqueueAction(action);
            
        }
        
       
    }
    
    
})