public with sharing class OpportunityEmailBatchSender implements Database.Batchable<sObject>, Database.Stateful {
    public List<Opportunity> opportunityList;
    public Id templateId;
    
    public OpportunityEmailBatchSender(List<Opportunity> opportunityList, Id templateId) {
        this.opportunityList = opportunityList;
        this.templateId = templateId;
    }

    public List<Opportunity> start(Database.BatchableContext BC) {
        return opportunityList;
    }

    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        EmailService service = new EmailService();
        List<Messaging.SendEmailResult> emailMessage = service.sendOpportunityEmailToOwner(scope, templateId);
    }

    public void finish(Database.BatchableContext BC) {}
}