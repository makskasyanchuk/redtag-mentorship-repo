@isTest
private class OpportunitySummaryMetricsTest {
    @TestSetup
    static void makeData(){
        Opportunity_Statistics__c stats = TestDataFactory.createStats();
    }

    @isTest
    static void testBatch() {
        AggregateResult[] closedWon = [
            SELECT COUNT(Id) FROM Opportunity WHERE
            StageName = 'Closed Won' AND CloseDate = THIS_QUARTER
        ];
        AggregateResult[] closedLost = [
            SELECT COUNT(Id) FROM Opportunity WHERE
            StageName = 'Closed Lost' AND CloseDate = THIS_QUARTER
        ];

        Test.startTest();
        OpportunitySummaryMetrics batchApex = new OpportunitySummaryMetrics();
        Id jobId = Database.executeBatch(batchApex);
        Test.stopTest();

        List<Opportunity_Statistics__c> statistics = [SELECT Closed_Won_Opportunities__c, Closed_Lost_Opportunities__c FROM Opportunity_Statistics__c];

        Assert.isNotNull(statistics, 'Statistics record should have been created.');
        Assert.areEqual(1, statistics.size(), 'There should be one statistics record.');
        Assert.areEqual(1, statistics[0].Closed_Won_Opportunities__c, 'There should be one Closed Won opportunity.');
        Assert.areEqual(1, statistics[0].Closed_Lost_Opportunities__c, 'There should be one Closed Lost opportunity.');
        Assert.isFalse(jobId == null);
    }
}