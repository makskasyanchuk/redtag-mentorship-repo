@isTest
private class OpportunityProductListViewControllerTest {

    @TestSetup
    static void makeData(){
        Account account = TestDataFactory.createAccount();
        Contact contact = TestDataFactory.createContact(account.Id);
        Opportunity opportunity = TestDataFactory.createOpportunity(account.Id, contact.Id);
        Product2 product = TestDataFactory.createProduct();
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPricebookEntry = TestDataFactory.createStandardPricebookEntry(pricebookId, product.Id);
        Pricebook2 customPricebook = TestDataFactory.createCustomPricebook();
        PricebookEntry customPricebookEntry = TestDataFactory.createCustomPricebookEntry(customPricebook.Id, product.Id);
        OpportunityLineItem opportunityLineItem = TestDataFactory.createOpportunityLineItem(opportunity.Id, standardPricebookEntry.Id);
    }

    @isTest
    static void testGetOpportunityProducts() {
        List<Id> opportunityIds = new List<Id>();

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

        opportunityIds.add(opportunity.Id);

        Test.startTest();
        List<OpportunityProductListViewController.OpportunityProductWrapper> wrapperList = OpportunityProductListViewController.getOpportunityProducts(opportunityIds);
        Test.stopTest();

        Assert.isTrue(wrapperList.size() > 0);
    }
}