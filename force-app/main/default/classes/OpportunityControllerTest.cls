@isTest
private class OpportunityControllerTest {

    @TestSetup
    static void makeData(){
        Account account = TestDataFactory.createAccount();
        Contact contact = TestDataFactory.createContact(account.Id);
        Opportunity opportunity = TestDataFactory.createOpportunity(account.Id, contact.Id);
    }

    @isTest
    static void testGetAccountNameById() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Redtag'];
        
        Test.startTest();
        String accountName = OpportunityCreationFormController.getAccountNameById(account.Id);
        Test.stopTest();

        Assert.isTrue(account.Id != null);
        Assert.isTrue(accountName != null);
    }

    @isTest
    static void testGetContactLastNameById() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Redtag'];
        Contact contact = [SELECT Id, LastName FROM Contact WHERE AccountId = :account.Id];

        Test.startTest();
        String contactLastName = OpportunityCreationFormController.getContactLastNameById(contact.Id);
        Test.stopTest();

        Assert.isTrue(account.Id != null);
        Assert.isTrue(contact.Id != null);
        Assert.isTrue(contactLastName != null);
    }

    @isTest
    static void testUpdateAccountAndContactNames() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Redtag'];
        Contact contact = [SELECT Id, LastName FROM Contact WHERE AccountId = :account.Id];
        Opportunity opportunity = [
            SELECT Id, Name, AccountId, Contact__c FROM Opportunity
            WHERE AccountId = :account.Id AND Contact__c = :contact.Id
        ];

        Test.startTest();
        OpportunityCreationFormController.updateAccountAndContactNames(opportunity.Id, account.Name, contact.LastName);
        Test.stopTest();

        Assert.isTrue(account.Id != null);
        Assert.isTrue(contact.Id != null);
        Assert.isTrue(opportunity.Id != null);
        Assert.isTrue(opportunity.AccountId != null);
        Assert.isTrue(opportunity.Contact__c != null);
        Assert.isTrue(account.Name != null);
        Assert.isTrue(contact.LastName != null);
    }

    @isTest
    static void testCreateOpportunityLineItems() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Redtag'];
        Contact contact = [SELECT Id, LastName FROM Contact WHERE AccountId = :account.Id];
        Opportunity opportunity = [
            SELECT Id, Name, AccountId, Contact__c FROM Opportunity
            WHERE AccountId = :account.Id AND Contact__c = :contact.Id
        ];

        Map<String, Object> product2 = new Map<String, Object>{
            'Id' => '01tQy00000AVLyTIAX', 
            'Quantity' => 5,
            'UnitPrice' => '100.00'
        };
        
        List<Map<String, Object>> productsList = new List<Map<String, Object>>{product2};
        String productsJSON = JSON.serialize(productsList);

        Test.startTest();
        OpportunityCreationFormController.createOpportunityLineItems(opportunity.Id, productsJSON);
        Test.stopTest();

        Assert.isTrue(account.Id != null);
        Assert.isTrue(contact.Id != null);
        Assert.isTrue(opportunity.Id != null);
        Assert.isTrue(opportunity.AccountId != null);
        Assert.isTrue(opportunity.Contact__c != null);
        Assert.isTrue(account.Name != null);
        Assert.isTrue(contact.LastName != null);
    }
}