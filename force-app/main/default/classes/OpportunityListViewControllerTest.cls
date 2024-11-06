@isTest
private class OpportunityListViewControllerTest {

    @TestSetup
    static void makeData(){
        Account account = TestDataFactory.createAccount();
        Contact contact = TestDataFactory.createContact(account.Id);
        Opportunity opportunity = TestDataFactory.createOpportunity(account.Id, contact.Id);
    }

    @isTest
    static void testGetOpportunitiesWithProducts() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Redtag'];

        Contact contact = [SELECT Id, Name, FirstName, LastName FROM Contact WHERE AccountId = :account.Id];

        Opportunity opportunity = [
            SELECT Id, 
                   Name, 
                   AccountId, 
                   Contact__c,
                   StageName,
                   CloseDate,
                   Contact__r.Name,
                   Account.Name 
            FROM Opportunity
            WHERE AccountId = :account.Id AND Contact__c = :contact.Id
        ];

        OpportunityListViewController.OpportunityWrapper wrapper = new OpportunityListViewController.OpportunityWrapper();
        wrapper.opportunityId = opportunity.Id;
        wrapper.accountName = opportunity.Account.Name;
        wrapper.accountUrl = '/' + opportunity.AccountId;
        wrapper.contactUrl = '/' + opportunity.Contact__c;
        wrapper.closeDate = Date.today();
        wrapper.contactName = opportunity.Contact__r.Name;
        wrapper.opportunityName = opportunity.Name;
        wrapper.stageName = opportunity.StageName;

        Test.startTest();
        List<OpportunityListViewController.OpportunityWrapper> wrapperList = OpportunityListViewController.getOpportunitiesWithProducts();
        Test.stopTest();

        Assert.isTrue(wrapperList.size() > 0);
    }

    @isTest
    static void testMassDelete() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Redtag'];

        Contact contact = [SELECT Id, Name, FirstName, LastName FROM Contact WHERE AccountId = :account.Id];

        Opportunity opportunity = [
            SELECT Id, 
                   Name, 
                   AccountId, 
                   Contact__c,
                   StageName,
                   CloseDate,
                   Contact__r.Name,
                   Account.Name 
            FROM Opportunity
            WHERE AccountId = :account.Id AND Contact__c = :contact.Id
        ];

        List<Id> opportunityIds = new List<Id> {opportunity.Id};

        Test.startTest();
        OpportunityListViewController.massDeleteOpportunities(opportunityIds);
        Test.stopTest();

        Assert.isTrue(!opportunityIds.isEmpty());
    }
}