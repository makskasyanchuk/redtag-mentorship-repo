({
    saveOpportunityLineItems : function(component, recordId) {
        let lineItems = component.find("opportunityProductsList").get("v.opportunityLineItems");
        let action = component.get("c.insertOpportunityLineItems");

        if (lineItems.length > 0) {
            action.setParams(
                {
                    opportunityId: recordId, 
                    productsJSON: JSON.stringify(lineItems)
                }
            );
            action.setCallback(this, function(response) {
                const state = response.getState();
                if (state === "SUCCESS") {
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
    validateLookupFields : function(component) {
        let accountId = component.find("accountField").get("v.value");
        let contactId = component.find("contactField").get("v.value");

        if (!accountId) {
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
    setAccountIdForSelectedContact : function(component) {
        let accountId = component.find("accountField").get("v.value");
        let contactId = component.get("v.opportunity.Contact__c");

        if (accountId && contactId) {
            console.log("Went into condition to check if ids are fetched");
            let action = component.get("c.updateContactsToSetAccountId");
            action.setParams({ accountId : accountId, contactId : contactId });
            action.setCallback(this, function(response) {
                const state = response.getState();
                if (state === "SUCCESS") {
                    console.log("Successfuly set the Account Id for Contact");
                } else {
                    console.error("Error setting the Account Id for Contact: " + response.getError());
                }
            });
            $A.enqueueAction(action);
        }
    },
    setContactIdForOpportunity : function(component, payloadId) {
        let accountId = component.find("accountField").get("v.value");
        let contactId = component.get("v.opportunity.Contact__c");
        let opportunityId = payloadId;

        if (accountId && contactId) {
            let action = component.get("c.updateOpportunitiesToSetContactId");
            action.setParams({ opportunityId : opportunityId, contactId : contactId, accountId : accountId });
            action.setCallback(this, function(response) {
                const state = response.getState();
                if (state === "SUCCESS") {
                    console.log("Successfuly set the Contact Id for Opportunity");
                } else {
                    console.error("Error setting the Contact Id for Opportunity: " + response.getError());
                }
            });
            $A.enqueueAction(action);
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
            opportunityName: component.find("opportunityName").get("v.value"),
            accountName: component.find("relatedAccountName").get("v.value"),
            contactName: component.find("relatedContactLastName").get("v.value")
        };
        console.log("Message Payload:", JSON.stringify(messagePayload));

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