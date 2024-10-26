public with sharing class OpportunityListViewController {

    public class OpportunityWrapper {
        @AuraEnabled
        public Id opportunityId {get;set;}
        @AuraEnabled
        public String opportunityName {get;set;}
        @AuraEnabled
        public String stageName {get;set;}
        @AuraEnabled
        public Date closeDate {get;set;}
        @AuraEnabled
        public String accountUrl {get;set;}
        @AuraEnabled
        public String contactUrl {get;set;}
        @AuraEnabled
        public String accountName {get;set;}
        @AuraEnabled
        public String contactName {get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static List<OpportunityWrapper> getOpportunitiesWithProducts(){
        List<Opportunity> opportunityList =
        [
            SELECT Id, Name, StageName, CloseDate, Account.Name, Contact__r.Name, AccountId, Contact__c FROM Opportunity
            WHERE Id IN (SELECT OpportunityId FROM OpportunityLineItem)
        ];
        List<OpportunityWrapper> opportunityWrapperList = new List<OpportunityWrapper>();

        for(Opportunity opportunity : opportunityList) {
            OpportunityWrapper opportunityWrapper = new OpportunityWrapper();
            opportunityWrapper.opportunityId = opportunity.Id;
            opportunityWrapper.opportunityName = opportunity.Name;
            opportunityWrapper.accountUrl = opportunity.AccountId != null ? '/' +  opportunity.AccountId : null;
            opportunityWrapper.contactUrl = opportunity.Contact__c != null ? '/' + opportunity.Contact__c : null;
            opportunityWrapper.stageName = opportunity.StageName;
            opportunityWrapper.closeDate = opportunity.CloseDate;
            opportunityWrapper.accountName = opportunity.Account.Name;
            opportunityWrapper.contactName = opportunity.Contact__r.Name;
            opportunityWrapperList.add(opportunityWrapper);
        }

        return opportunityWrapperList;
    }

    @AuraEnabled
    public static void massDeleteOpportunities(List<Id> opportunityIds) {
        Database.delete(opportunityIds);
    }
}