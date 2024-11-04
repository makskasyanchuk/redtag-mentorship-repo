public without sharing class OpportunityCreationFormController {
    @AuraEnabled
    public static void createOpportunityLineItems(String opportunityId, String productsJSON) {
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
        
        insert opportunityLineItems;
    }
}