({
	doInit : function(component, event, helper) {
        helper.loadData(component);
    },
    
    handleContractCopy : function(component, event, helper) {
        helper.copyContract(component, event);
    },
    
    handleCancel : function(component, event, helper) {
        helper.cancelDialog(component);
    },
    
    stopNotification : function(component, event, helper) {
        console.log('component event received in controller');
        helper.stopNotifications(component, event);
    }
})