({
	doInit: function(component, event, helper) {
       // helper.fetchPickListVal(component, 'shipment_method__c', 'shipMethod');
        var RecID=  component.get("v.recordId");
        helper.fetchCurrentRecData(component,RecID );
    },
    
    getPrice: function(component,event,helper){
        helper.getPriceHelper(component,event);
    },
   
    clearAll:  function(component,event,helper){
        component.set("v.myMap",{"fPrice":"","PCode":"","TPrice":"","PPU":"","PU":"","QU":"","SP":"","UOMPicklist":null});
        component.set("v.Quant","");
        component.set("v.picklistSelected","");
        component.set("v.picklistSelected1","");
        component.set("v.selectedLookUpRecord",null);
         var childCmp = component.find("childCmp");
 childCmp.clearAll();
        
    },
    close : function(cmp,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    }
   /* onPicklistChange: function(component, event, helper) { 
        // get the value of select option
        alert(event.getSource().get("v.value"));
    },*/
})