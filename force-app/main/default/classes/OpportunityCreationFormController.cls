public without sharing class OpportunityCreationFormController {

    public static String instanceAccountName;
    public static String instanceContactLastName;

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
    public static void updateAccountAndContactNames(String accountName, String contactLastName) {
        OpportunityWrapper wrapper = new OpportunityWrapper(accountName, contactLastName);
        instanceAccountName = wrapper.wrapperAccountName;
        instanceContactLastName = wrapper.wrapperContactLastName;
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