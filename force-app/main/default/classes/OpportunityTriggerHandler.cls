public with sharing class OpportunityTriggerHandler {
    public void onBeforeInsert(List<Opportunity> opportunityList) {
        OpportunityHandlerService.createRelatedAccountAndContact(opportunityList);
    }

    public void onBeforeUpdate(List<Opportunity> opportunityList, Map<Id, Opportunity> opportunityOldMap) {
        OpportunityHandlerService.updateAccountAndContactInfo(opportunityList, opportunityOldMap);
    }

    public void onBeforeDelete(List<Opportunity> opportunityList) {
        OpportunityHandlerService.deleteOpportunity(opportunityList);
    }
}