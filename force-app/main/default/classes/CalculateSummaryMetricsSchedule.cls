public with sharing class CalculateSummaryMetricsSchedule implements Schedulable {

    private final static String CRON_EXPRESSION = '0 0 10 ? * MON,WED,FRI';

    @AuraEnabled
    public static void callSchedule(){
        try {
            System.schedule('Opportunity Summary Metrics Scheduler ' + String.valueOf(System.currentTimeMillis()), CRON_EXPRESSION, new CalculateSummaryMetricsSchedule());
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