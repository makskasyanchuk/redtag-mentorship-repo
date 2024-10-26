({
    doInit : function(component, event, controller) {
        console.log("Init");
    },

    handleSuccess : function(component, event, helper) {
        let lineItems = component.find("opportunityProductsList").get("v.opportunityLineItems");
        let payload = event.getParams().response;
        component.set("v.recordId", payload.id);

        let accountId = component.find("accountField").get("v.value");
        let contactId = component.find("contactField").get("v.value");


        if(!accountId) {
            component.find("notifLib").showToast({
                "title": "Creation failed",
                "message": "Please, choose an Account for Opportunity",
                "variant": 'error'
            });
            return;
        } 
        if (!contactId) {
            component.find("notifLib").showToast({
                "title": "Creation failed",
                "message": "Please, choose a Contact for Opportunity",
                "variant": 'error'
            });
            return;
        }

        component.find("notifLib").showToast({
            "title": "Opportunity created",
            "message": "Opportunity was successfuly created, Id: " + payload.id,
            "variant": 'success'
        });
        
        helper.setAccountAndContactNames(component, event, payload);
        helper.saveOpportunityLineItems(component, lineItems, component.get("v.recordId"));

        let messageService = component.find("messageService");

        if (!messageService) {
            console.error("Message service not found!");
        } else {
            console.log("Message service found.");
        }

        let messagePayload = {
            recordId: component.get("v.recordId"),
            opportunityName: component.find("opportunityName").get("v.value")
        };

        messageService.publish({
            channelName: "OpportunityCreatedChannel__c",
            message: messagePayload
        });
    },

    handleError : function(component, event, helper) {
        component.find("notifLib").showToast({
            "title": "Failed to create an Opportunity",
            "message": event.getParam('message'),
            "variant": "error"
        });   
    }
})