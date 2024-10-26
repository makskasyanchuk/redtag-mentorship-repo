public without sharing class OpportunityCreationFormController {
    @AuraEnabled(cacheable=true)
    public static String getAccountNameById(Id accountId) {
        Account account = [SELECT Id, Name FROM Account WHERE Id = :accountId LIMIT 1];

        return account.Name;
    }

    @AuraEnabled(cacheable=true)
    public static String getContactLastNameById(Id contactId) {
        Contact contact = [SELECT Id, LastName FROM Contact WHERE Id = :contactId LIMIT 1];

        return contact.LastName;
    }

    @AuraEnabled
    public static void updateAccountAndContactNames(Id opportunityId, String accountName, String contactLastName) {
        Opportunity opp = [SELECT Id, Related_Account_Name__c, Related_Contact_Last_Name__c FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        opp.Name = accountName + ' from ' + Datetime.now().format('dd MMMM yyyy');
        opp.Related_Account_Name__c = accountName;
        opp.Related_Contact_Last_Name__c = contactLastName;
        // OpportunityHandlerService service = new OpportunityHandlerService(accountName, contactLastName);
        update opp;
    }

    @AuraEnabled
    public static void createOpportunityLineItems(String opportunityId, String productsJSON) {
        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        List<Object> productsList = (List<Object>) JSON.deserializeUntyped(productsJSON);

        for(Object product : productsList) {
            Map<String, Object> productMap = (Map<String, Object>) product;
            OpportunityLineItem newOpportunityLineItem = new OpportunityLineItem();
            newOpportunityLineItem.OpportunityId = opportunityId;
            newOpportunityLineItem.Product2Id = (String) productMap.get('Id');
            newOpportunityLineItem.Quantity = Integer.valueOf(productMap.get('Quantity'));
            newOpportunityLineItem.UnitPrice = Decimal.valueOf((String) productMap.get('UnitPrice'));

            opportunityLineItems.add(newOpportunityLineItem);
        }
        
        insert opportunityLineItems;
    }
}