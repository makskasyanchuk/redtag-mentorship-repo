({
    saveOpportunityLineItems : function(component, recordId) {
        let lineItems = component.find("opportunityProductsList").get("v.opportunityLineItems");
        let action = component.get("c.createOpportunityLineItems");

        if(lineItems.length > 0) {
            action.setParams(
                {
                    opportunityId: recordId, 
                    productsJSON: JSON.stringify(lineItems)
                }
            );
            action.setCallback(this, function(response) {
                const state = response.getState();
                if(state === "SUCCESS") {
                    component.find('notifLib').showToast({
                        "title": "Line Items Created",
                        "message": "Opportunity Line Items were successfully created.",
                        "variant": 'success'
                    });
                    $A.get("e.force:refreshView").fire();
                } else {
                    const error = response.getError();
                    console.log(error[0].message);
                    component.find('notifLib').showToast({
                        "title": "Error Creating Line Items",
                        "message": error[0] ? error[0].message : "Unknown error",
                        "variant": 'error'
                    });
                }
            });

            $A.enqueueAction(action);
        } else {
            console.log("No opportunity line items to create");
        }
    },
    setAccountAndContactNames : function(component, event, payload) {
        let action = component.get("c.updateAccountAndContactNames");
        
        let getAccountName = component.get("c.getAccountNameById");
        let getContactLastName = component.get("c.getContactLastNameById");

        let accountId = component.find("accountField").get("v.value");
        let contactId = component.find("contactField").get("v.value");

        let getAccountNameById = new Promise(function(resolve, reject) {
            getAccountName.setParams({accountId : accountId});
            getAccountName.setCallback(this, function(response) {
                let state = response.getState();
                if(state === "SUCCESS") {
                    resolve(response.getReturnValue());
                } else {
                    reject("Failed to fetch account name");
                }
            });
            $A.enqueueAction(getAccountName);
        });

        let getContactLastNameById = new Promise(function(resolve, reject) {
            getContactLastName.setParams({contactId : contactId});
            getContactLastName.setCallback(this, function(response) {
                let state = response.getState();
                if(state === "SUCCESS") {
                    resolve(response.getReturnValue());
                } else {
                    reject("Failed to fetch contact last name");
                }
            });
            $A.enqueueAction(getContactLastName);
        });

        Promise.all([getAccountNameById, getContactLastNameById]).then(function(results) {
            action.setParams({accountName : results[0], contactLastName : results[1]});
            action.setCallback(this, function(response) {
                let state = response.getState();
                if(state === "SUCCESS") {
                    console.log("Names are set");
                }
            });
            $A.enqueueAction(action);
        }).catch(function(error) {
            console.error(error);
        });
    },
    validateLookupFields : function(component) {
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
    },
    publishToChannel : function(component) {
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
    successfulToast : function(component, payload) {
        component.find("notifLib").showToast({
            "title": "Opportunity created",
            "message": "Opportunity was successfuly created, Id: " + payload.id,
            "variant": 'success'
        });
    },
    failureToast : function(component, event) {
        component.find("notifLib").showToast({
            "title": "Failed to create an Opportunity",
            "message": event.getParam('message'),
            "variant": "error"
        });
    }
})