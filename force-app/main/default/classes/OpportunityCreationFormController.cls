public without sharing class OpportunityCreationFormController {
    @AuraEnabled
    public static void updateContactsToSetAccountId(Id accountId, Id contactId) {
        List<Contact> contactsToUpdate = setAccountIdForContact(accountId, contactId);
        update contactsToUpdate;
    }

    @AuraEnabled 
    public static void updateOpportunitiesToSetContactId(Id opportunityId, Id contactId, Id accountId) {
        List<Opportunity> opportunitiesToUpdate = setContactIdForOpportunity(opportunityId, contactId, accountId);
        update opportunitiesToUpdate;
    }

    @AuraEnabled
    public static void insertOpportunityLineItems(String opportunityId, String productsJSON) {
        List<OpportunityLineItem> opportunityLineItemsToInsert = createOpportunityLineItems(opportunityId, productsJSON);
        insert opportunityLineItemsToInsert;
    }

    private static List<OpportunityLineItem> createOpportunityLineItems(String opportunityId, String productsJSON) {
        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        List<Object> productsList = (List<Object>) JSON.deserializeUntyped(productsJSON);

        for (Object product : productsList) {
            Map<String, Object> productMap = (Map<String, Object>) product;
            OpportunityLineItem newOpportunityLineItem = new OpportunityLineItem();
            newOpportunityLineItem.OpportunityId = opportunityId;
            newOpportunityLineItem.Product2Id = (String) productMap.get('Id');
            newOpportunityLineItem.Quantity = Integer.valueOf(productMap.get('Quantity'));
            newOpportunityLineItem.UnitPrice = Decimal.valueOf((String) productMap.get('UnitPrice'));

            opportunityLineItems.add(newOpportunityLineItem);
        }

        return opportunityLineItems;
    }

    private static List<Contact> setAccountIdForContact(Id accountId, Id contactId) {
        List<Contact> contactsToUpdate = new List<Contact>();
        Contact contactToUpdate = [
            SELECT Id,
                   AccountId,
                   Name,
                   FirstName,
                   LastName
            FROM Contact
            WHERE Id =: contactId
            LIMIT 1
        ];
        contactToUpdate.AccountId = accountId;
        contactsToUpdate.add(contactToUpdate);

        return contactsToUpdate;
    }

    private static List<Opportunity> setContactIdForOpportunity(Id opportunityId, Id contactId, Id accountId) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        Opportunity opportunityToUpdate = [
            SELECT Id,
                   Name,
                   Contact__c,
                   AccountId
            FROM Opportunity
            WHERE Id =: opportunityId AND AccountId =: accountId
        ];
        opportunityToUpdate.Contact__c = contactId;
        opportunitiesToUpdate.add(opportunityToUpdate);

        return opportunitiesToUpdate;
    }
}