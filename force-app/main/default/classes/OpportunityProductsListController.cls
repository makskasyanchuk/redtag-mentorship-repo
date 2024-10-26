public with sharing class OpportunityProductsListController {
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(){
        return [SELECT Id, Name, Product_Image__c FROM Product2];
    }

    @AuraEnabled
    public static List<Product2> updateProducts(List<Product2> products) {
        update products;
        
        return products;
    }
}