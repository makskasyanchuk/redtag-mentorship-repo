public with sharing class CalculateSummaryMetricsSchedule implements Schedulable {

    @AuraEnabled
    public static void callSchedule(){
        try {
            String cronExpression = '0 0 10 ? * MON,WED,FRI';
            System.schedule('Opportunity Summary Metrics Scheduler ' + String.valueOf(System.currentTimeMillis()), cronExpression, new CalculateSummaryMetricsSchedule());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public void execute(SchedulableContext SC) {
        CalculateOpportunitySummaryMetricsBatch batchJob = new CalculateOpportunitySummaryMetricsBatch();
        batchJob.skipFinish = true;
        Database.executeBatch(batchJob);
    }
}