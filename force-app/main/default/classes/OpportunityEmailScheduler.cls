public with sharing class OpportunityEmailScheduler implements Schedulable {
    private List<Opportunity> opportunityList;
    private Id templateId;
    
    public OpportunityEmailScheduler(List<Opportunity> opportunityList, Id templateId) {
        this.opportunityList = opportunityList;
        this.templateId = templateId;
    }

    public void execute(SchedulableContext sc) {
        EmailService emailService = new EmailService();
        emailService.sendOpportunityEmailToOwner(opportunityList, templateId);
    }
}