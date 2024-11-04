({
    doInit : function(component, event, controller) {
        console.log("Init func");
    },
    handleSuccess : function(component, event, helper) {
        let payload = event.getParams().response;
        component.set("v.recordId", payload.id);

        helper.validateLookupFields(component);
        helper.saveOpportunityLineItems(component, payload.id);
        helper.successfulToast(component, payload);
        helper.publishToChannel(component);
    },
    handleError : function(component, event, helper) {
        helper.failureToast(component, event);   
    }
})