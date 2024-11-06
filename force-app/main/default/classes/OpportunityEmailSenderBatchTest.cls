@isTest
private class OpportunityEmailSenderBatchTest {
    @isTest
    static void testOpportunitySenderBatch() {
        List<Opportunity> opportunityList = new List<Opportunity>();

        EmailTemplate et = new EmailTemplate();
        et.isActive = true;
        et.Name = 'testTemplate';
        et.DeveloperName = 'testTemplate' + System.now().getTime();
        et.TemplateType = 'text';
        et.FolderId = UserInfo.getUserId();
        et.Body = '';
        insert et;

        Test.startTest();
        OpportunityEmailSenderBatch batch = new OpportunityEmailSenderBatch(opportunityList, et.Id);
        Iterable<Opportunity> ql = batch.start(null);
        batch.execute(null, opportunityList);
        batch.finish(null);
        Test.stopTest();

        Assert.isFalse(et.Id == null);
    }
}