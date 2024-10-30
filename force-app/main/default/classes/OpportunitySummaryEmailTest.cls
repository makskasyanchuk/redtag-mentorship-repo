@isTest
private with sharing class OpportunitySummaryEmailTest {
    @isTest
    static void testQueueablePositive() {
        String body = 'test body';

        Test.startTest();
        OpportunitySummaryEmail queueableApex = new OpportunitySummaryEmail(body);
        System.enqueueJob(queueableApex);
        Test.stopTest();
    }
}