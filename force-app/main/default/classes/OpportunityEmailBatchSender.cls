public with sharing class OpportunityEmailBatchSender implements Database.Batchable<sObject>, Database.Stateful {
    private List<Opportunity> opportunityList;
    private Id templateId;
    
    public OpportunityEmailBatchSender(List<Opportunity> opportunityList, Id templateId) {
        this.opportunityList = opportunityList;
        this.templateId = templateId;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, AccountId, Owner.Email, Related_Contact_Last_Name__c FROM Opportunity';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        EmailService service = new EmailService();
        List<Messaging.SendEmailResult> emailMessage = service.sendOpportunityEmailToOwner(scope, templateId);
    }

    public void finish(Database.BatchableContext BC) {}
}