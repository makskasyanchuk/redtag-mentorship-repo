({
    doInit : function(component, event, controller) {
        console.log("Init func");
    },
    handleSuccess : function(component, event, helper) {
        let payload = event.getParams().response;
        component.set("v.recordId", payload.id);

        helper.validateLookupFields(component);
        helper.setAccountIdForSelectedContact(component);
        helper.setContactIdForOpportunity(component, payload.id);
        helper.saveOpportunityLineItems(component, payload.id);
        helper.successfulToast(component, payload);
        helper.publishToChannel(component);
    },
    handleCheckboxChange : function(component, event, helper) {
        let checkbox = component.find("selectToAddProducts");
        let isChecked = checkbox.get("v.checked");

        component.set("v.visible", isChecked);
    },
    handleError : function(component, event, helper) {
        helper.failureToast(component, event);   
    }
})