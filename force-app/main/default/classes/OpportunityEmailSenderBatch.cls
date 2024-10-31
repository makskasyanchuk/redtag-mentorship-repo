public with sharing class OpportunityEmailSenderBatch implements Database.Batchable<sObject>, Database.Stateful {
    public List<Opportunity> opportunityList;
    public Id templateId;
    
    public OpportunityEmailSenderBatch(List<Opportunity> opportunityList, Id templateId) {
        this.opportunityList = opportunityList;
        this.templateId = templateId;
    }

    public Iterable<Opportunity> start(Database.BatchableContext BC) {
        return opportunityList;
    }

    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        EmailService service = new EmailService();
        List<Messaging.SendEmailResult> emailMessage = service.sendOpportunityEmailToOwner(scope, templateId);
    }

    public void finish(Database.BatchableContext BC) {}
}