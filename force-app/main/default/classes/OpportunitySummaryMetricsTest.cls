@isTest
private class OpportunitySummaryMetricsTest {
    @TestSetup
    static void makeData(){
        Account account = TestDataFactory.createAccount();
        Contact contact = TestDataFactory.createContact(account.Id);
        List<Opportunity> wonOpportunities = TestDataFactory.createWonOpportunities(account.Id, contact.Id);
        List<Opportunity> lostOpportunities = TestDataFactory.createLostOpportunities(account.Id, contact.Id);
        Opportunity_Statistics__c stats = TestDataFactory.createStats(wonOpportunities, lostOpportunities);
    }

    @isTest
    static void testExecute() {
        List<Opportunity> opportunityList = [
            SELECT Id,
                   Name, 
                   Related_Account_Name__c, 
                   Related_Contact_Last_Name__c,
                   AccountId, 
                   Contact__c, 
                   CloseDate, 
                   StageName 
            FROM Opportunity 
            WHERE CloseDate = THIS_QUARTER
        ];

        Test.startTest();
        // Execute batch directly, to cover the invocable method
        CalculateOpportunitySummaryMetricsBatch.executeBatch();
        // Instantiate batch to call each method separately
        CalculateOpportunitySummaryMetricsBatch batchApex = new CalculateOpportunitySummaryMetricsBatch();
        
        Database.QueryLocator ql = batchApex.start(null);
        batchApex.execute(null, opportunityList);
        batchApex.finish(null);

        Test.stopTest();

        List<Opportunity_Statistics__c> statistics = [SELECT Id, Closed_Won_Opportunities__c, Closed_Lost_Opportunities__c FROM Opportunity_Statistics__c];

        Assert.isNotNull(statistics, 'Statistics record should have been created.');
        Assert.areEqual(1, statistics.size(), 'There should be one statistics record.');
        Assert.areEqual(5, statistics[0].Closed_Won_Opportunities__c, 'Should be five');
        Assert.areEqual(5, statistics[0].Closed_Lost_Opportunities__c, 'Should be five');
    }

    @isTest
    static void testFinish() {
        CalculateOpportunitySummaryMetricsBatch batchApex = new CalculateOpportunitySummaryMetricsBatch();
        batchApex.skipFinish = false;

        Test.startTest();
        Id jobId = Database.executeBatch(batchApex);
        Test.stopTest();

        Assert.isFalse(jobId == null);
    }
}