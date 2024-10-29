public with sharing class OpportunitySummaryMetricsSchedule implements Schedulable {

    @AuraEnabled
    public static void callSchedule(){
        try {
            String cronExpression = '0 0 10 ? * MON,WED,FRI';
            System.schedule('Opportunity Summary Metrics Scheduler ' + String.valueOf(System.currentTimeMillis()), cronExpression, new OpportunitySummaryMetricsSchedule());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public void execute(SchedulableContext SC) {
        OpportunitySummaryMetrics batchJob = new OpportunitySummaryMetrics();
        batchJob.skipFinish = true;
        Database.executeBatch(batchJob);
    }
}