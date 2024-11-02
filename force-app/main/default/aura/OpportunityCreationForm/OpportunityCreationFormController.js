({
    doInit : function(component, event, controller) {
        console.log("Init");
    },

    handleSuccess : function(component, event, helper) {
        let payload = event.getParams().response;

        helper.validateLookupFields(component);
        helper.setAccountAndContactNames(component, event, payload);
        helper.saveOpportunityLineItems(component, payload.id);
        helper.successfulToast(component, payload);
        helper.publishToChannel(component);
        
    },

    handleError : function(component, event, helper) {
        helper.failureToast(component, event);   
    }
})