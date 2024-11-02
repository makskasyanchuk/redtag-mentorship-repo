public with sharing class OpportunityProductListViewController {
    public class OpportunityProductWrapper {
        @AuraEnabled
        public String opportunityName {get;set;}
        @AuraEnabled
        public String opportunityUrl {get;set;}
        @AuraEnabled
        public String productName {get;set;}
        @AuraEnabled
        public Integer quantity {get;set;}
        @AuraEnabled
        public Decimal unitPrice {get;set;}
        @AuraEnabled
        public Decimal discountPrice {get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static List<OpportunityProductWrapper> getOpportunityProducts(List<Id> opportunityIds){
        List<OpportunityLineItem> opportunityProducts = [
            SELECT Id,
                   Product2.Name,
                   Quantity,
                   UnitPrice,
                   Discount_Calculation__c,
                   Opportunity.Name,
                   OpportunityId
            FROM OpportunityLineItem
            WHERE OpportunityId IN :opportunityIds
        ];
        List<OpportunityProductWrapper> opportunityProductWrapperList = new List<OpportunityProductWrapper>();

        for (OpportunityLineItem opportunityProduct : opportunityProducts) {
            OpportunityProductWrapper opportunityProductWrapper = new OpportunityProductWrapper();
            opportunityProductWrapper.opportunityName = opportunityProduct.Opportunity.Name;
            opportunityProductWrapper.productName = opportunityProduct.Product2.Name;
            opportunityProductWrapper.opportunityUrl = '/' + opportunityProduct.OpportunityId;
            opportunityProductWrapper.quantity = (Integer) opportunityProduct.Quantity;
            opportunityProductWrapper.unitPrice = opportunityProduct.UnitPrice;
            opportunityProductWrapper.discountPrice = opportunityProduct.Discount_Calculation__c;
            opportunityProductWrapperList.add(opportunityProductWrapper);
        }

        return opportunityProductWrapperList;
    }
}