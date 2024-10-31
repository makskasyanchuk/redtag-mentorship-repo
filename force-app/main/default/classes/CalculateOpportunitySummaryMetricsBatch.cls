public with sharing class CalculateOpportunitySummaryMetricsBatch implements Database.Batchable<sObject>, Database.Stateful {
    public Boolean skipFinish = false;

    @InvocableMethod
    public static void executeBatch() {
        Id jobId = Database.executeBatch(new CalculateOpportunitySummaryMetricsBatch());
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
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
        ]);
    }

    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        List<Opportunity_Statistics__c> statisticsList = new List<Opportunity_Statistics__c>();

        AggregateResult[] closedWonOppsCount = [
            SELECT COUNT(Id) FROM Opportunity WHERE StageName = 'Closed Won' AND CloseDate = THIS_QUARTER
        ];
        AggregateResult[] closedLostOppsCount = [
            SELECT COUNT(Id) FROM Opportunity WHERE StageName = 'Closed Lost' AND CloseDate = THIS_QUARTER
        ];

        Opportunity_Statistics__c statistics = new Opportunity_Statistics__c();
        statistics.Closed_Won_Opportunities__c = Integer.valueOf(closedWonOppsCount[0].get('expr0'));
        statistics.Closed_Lost_Opportunities__c = Integer.valueOf(closedLostOppsCount[0].get('expr0'));
        statisticsList.add(statistics);

        insert statisticsList;
    }

    public void finish(Database.BatchableContext BC) { 
        if(!skipFinish) {
            String body;
            Map<Id, Decimal> statisticsMapForClosedWonOpps = new Map<Id, Decimal>();
            Map<Id, Decimal> statisticsMapForClosedLostOpps = new Map<Id, Decimal>();
    
            List<Opportunity_Statistics__c> statistics = [SELECT Id, Closed_Won_Opportunities__c, Closed_Lost_Opportunities__c FROM Opportunity_Statistics__c];
    
            for (Opportunity_Statistics__c statistic : statistics) {
                if(!statisticsMapForClosedWonOpps.containsKey(statistic.Id)) {
                    statisticsMapForClosedWonOpps.put(statistic.Id, statistic.Closed_Won_Opportunities__c);
                }
                if(!statisticsMapForClosedLostOpps.containsKey(statistic.Id)) {
                    statisticsMapForClosedLostOpps.put(statistic.Id, statistic.Closed_Lost_Opportunities__c);
                }
    
                body = 'Closed Won Opportunities: ' + statisticsMapForClosedWonOpps.get(statistic.Id) + '\n' +
                'Closed Lost Opportunities: ' + statisticsMapForClosedLostOpps.get(statistic.Id);
            }    

            System.enqueueJob(new OpportunitySummaryEmail(body));
        }

    }
}