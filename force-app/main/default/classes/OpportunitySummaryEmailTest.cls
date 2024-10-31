@isTest
private with sharing class OpportunitySummaryEmailTest {
    @isTest
    static void testQueueablePositive() {
        String body = 'test body';

        Test.startTest();
        OpportunitySummaryEmailQueueable queueableApex = new OpportunitySummaryEmailQueueable(body);
        System.enqueueJob(queueableApex);
        Test.stopTest();
    }
}