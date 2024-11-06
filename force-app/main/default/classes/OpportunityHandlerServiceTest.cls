@isTest
private class OpportunityHandlerServiceTest {

    @TestSetup
    static void makeData(){
        Account account = TestDataFactory.createAccount();
        Contact contact = TestDataFactory.createContact(account.Id);
        Opportunity opportunity = TestDataFactory.createOpportunity(account.Id, contact.Id);
    }

    @isTest
    static void testPrepareRelatedAccount() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Redtag'];
        Opportunity opportunity = [
            SELECT Id, 
                   Name, 
                   Related_Account_Name__c
            FROM Opportunity 
            WHERE Related_Account_Name__c = :account.Name AND AccountId =: account.Id
        ];
       
        Opportunity oppNew = new Opportunity(
            Name = 'New Opportunity',
            Related_Account_Name__c = 'New Account',
            CloseDate = Date.today(),
            StageName = 'Prospecting',
            AccountId = null
        );
        insert oppNew;

       List<Opportunity> opportunityList = [
            SELECT Id, 
                   Name, 
                   Related_Account_Name__c 
            FROM Opportunity
            WHERE Related_Account_Name__c = :account.Name
            AND Id IN :new List<Id>{opportunity.Id, oppNew.Id}
       ];

       Test.startTest();
       OpportunityHandlerService.prepareRelatedAccount(opportunityList);
       Test.stopTest();

       Assert.isTrue(!opportunityList.isEmpty());
       Assert.isTrue(account.Id != null);
       Assert.isTrue(oppNew.Id != null);
    }

    @isTest 
    static void testPrepareRelatedContact() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Redtag'];

        Contact contact = [
            SELECT Id,
                   Name,
                   FirstName,
                   LastName, 
                   AccountId 
            FROM Contact 
            WHERE AccountId =: account.Id AND Name = 'Maksym Kasyanchuk'
        ];

        Opportunity opportunity = [
            SELECT Id, 
                   Name, 
                   Related_Account_Name__c, 
                   Related_Contact_Last_Name__c, 
                   Contact__c 
            FROM Opportunity 
            WHERE Related_Contact_Last_Name__c =: contact.Name AND Contact__c =: contact.Id
        ];

        Opportunity opportunityWithNewContact = new Opportunity(
            Name = 'New Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Related_Account_Name__c = account.Name,
            Related_Contact_Last_Name__c = 'New Contact',
            AccountId = account.Id
        );
        insert opportunityWithNewContact;

        List<Opportunity> opportunityList = [
            SELECT Id, 
                   Name, 
                   Related_Account_Name__c, 
                   Related_Contact_Last_Name__c 
            FROM Opportunity
            WHERE Related_Account_Name__c =: account.Name AND Related_Contact_Last_Name__c =: contact.Name
        ];

        List<Opportunity> newOpportunityList = new List<Opportunity> {
            opportunity,
            opportunityWithNewContact
        };

        Test.startTest();
        OpportunityHandlerService.prepareRelatedContact(newOpportunityList);
        Test.stopTest();

        Assert.isTrue(!opportunityList.isEmpty());
        Assert.isTrue(account.Id != null);
        Assert.isTrue(contact.Id != null);
        Assert.isTrue(contact.AccountId != null);
        Assert.isTrue(opportunity.Id != null);
        Assert.isTrue(opportunity.Contact__c != null);
        Assert.isTrue(account.Name == opportunity.Related_Account_Name__c);
        Assert.isTrue(contact.Name == opportunity.Related_Contact_Last_Name__c);
    }

    @isTest
    static void testUpdateRelatedAccountPositive() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Redtag'];

        Contact contact = [
            SELECT Id,
                   Name, 
                   FirstName, 
                   LastName, 
                   AccountId 
            FROM Contact 
            WHERE AccountId =: account.Id
        ];

        Opportunity opportunity = [
            SELECT Id, 
                   Name, 
                   Related_Account_Name__c, 
                   Related_Contact_Last_Name__c 
            FROM Opportunity 
            WHERE Related_Account_Name__c = :account.Name AND AccountId =: account.Id
        ];

        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();
        oldMap.put(opportunity.Id, opportunity);

        opportunity.Related_Account_Name__c = 'Redtag Inc.';
        opportunity.AccountId = null;
        
        List<Opportunity> opportunityList = [
            SELECT Id, 
                   Name, 
                   AccountId, 
                   Related_Account_Name__c 
            FROM Opportunity
            WHERE Related_Account_Name__c = :account.Name
        ];

        Test.startTest();
        OpportunityHandlerService.updateAccountInfo(opportunityList, oldMap);
        Test.stopTest();

        Assert.isTrue(!opportunityList.isEmpty());
        Assert.isTrue(account.Id != null);
        Assert.isTrue(contact.Id != null);
        Assert.isTrue(opportunity.Id != null);
        Assert.isTrue(account.Name != opportunity.Related_Account_Name__c);
        Assert.isTrue(contact.AccountId != null);
    }

    @isTest
    static void testUpdateRelatedAccountNegative() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Redtag'];

        Contact contact = [
            SELECT Id,
                   Name, 
                   FirstName, 
                   LastName, 
                   AccountId 
            FROM Contact 
            WHERE AccountId =: account.Id
        ];

        Opportunity opportunity = [
            SELECT Id, 
                   Name, 
                   Related_Account_Name__c, 
                   Related_Contact_Last_Name__c 
            FROM Opportunity 
            WHERE Related_Account_Name__c = :account.Name AND AccountId =: account.Id
        ];

        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();
        oldMap.put(opportunity.Id, opportunity);

        opportunity.Related_Account_Name__c = 'Amazon';
        
        List<Opportunity> opportunityList = [
            SELECT Id, 
                   Name, 
                   Related_Account_Name__c 
            FROM Opportunity
            WHERE Related_Account_Name__c = :account.Name
        ];

        Test.startTest();
        OpportunityHandlerService.updateAccountInfo(opportunityList, oldMap);
        Test.stopTest();

        Assert.isTrue(!opportunityList.isEmpty());
        Assert.isTrue(account.Id != null);
        Assert.isTrue(contact.Id != null);
        Assert.isTrue(opportunity.Id != null);
        Assert.isTrue(account.Name != opportunity.Related_Account_Name__c);
        Assert.isTrue(contact.AccountId != null);
    }

    @isTest
    static void testUpdateRelatedContactPositive() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Redtag'];

        Contact contact = [
            SELECT Id,
                   Name, 
                   FirstName, 
                   LastName, 
                   AccountId 
            FROM Contact 
            WHERE AccountId =: account.Id
        ];

        Opportunity opportunity = [
            SELECT Id, 
                   Name, 
                   Related_Account_Name__c, 
                   Related_Contact_Last_Name__c 
            FROM Opportunity 
            WHERE Related_Account_Name__c = :account.Name AND AccountId =: account.Id
        ];

        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();
        oldMap.put(opportunity.Id, opportunity);

        Map<String, Id> accountNameByIdMap = new Map<String, Id>();
        accountNameByIdMap.put(account.Name, account.Id);

        opportunity.Related_Contact_Last_Name__c = 'Maksym Kasyanchuk1';
        opportunity.Contact__c = null;
        
        List<Opportunity> opportunityList = [
            SELECT Id, 
                   Name, 
                   Related_Contact_Last_Name__c, 
                   Contact__c, 
                   Related_Account_Name__c 
            FROM Opportunity
            WHERE Related_Contact_Last_Name__c =: contact.Name
        ];

        Test.startTest();
        OpportunityHandlerService.updateContactInfo(opportunityList, oldMap, accountNameByIdMap);
        Test.stopTest();

        Assert.isTrue(!opportunityList.isEmpty());
        Assert.isTrue(account.Id != null);
        Assert.isTrue(contact.Id != null);
        Assert.isTrue(opportunity.Id != null);
        Assert.isTrue(contact.Name != opportunity.Related_Contact_Last_Name__c);
        Assert.isTrue(contact.AccountId != null);
    }

    @isTest
    static void testUpdateRelatedContactNegative() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Redtag'];

        Contact contact = [
            SELECT Id,
                   Name, 
                   FirstName, 
                   LastName, 
                   AccountId 
            FROM Contact 
            WHERE AccountId =: account.Id
        ];

        Opportunity opportunity = [
            SELECT Id, 
                   Name, 
                   Related_Account_Name__c, 
                   Related_Contact_Last_Name__c 
            FROM Opportunity 
            WHERE Related_Account_Name__c = :account.Name AND AccountId =: account.Id
        ];

        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();
        oldMap.put(opportunity.Id, opportunity);

        Map<String, Id> accountNameByIdMap = new Map<String, Id>();
        accountNameByIdMap.put(account.Name, account.Id);

        opportunity.Related_Contact_Last_Name__c = 'Nonexistant Record';
        
        List<Opportunity> opportunityList = [
            SELECT Id, 
                   Name, 
                   Related_Contact_Last_Name__c, 
                   Related_Account_Name__c 
            FROM Opportunity
            WHERE Related_Contact_Last_Name__c =: contact.Name
        ];

        Test.startTest();
        OpportunityHandlerService.updateContactInfo(opportunityList, oldMap, accountNameByIdMap);
        Test.stopTest();

        Assert.isTrue(!opportunityList.isEmpty());
        Assert.isTrue(account.Id != null);
        Assert.isTrue(contact.Id != null);
        Assert.isTrue(opportunity.Id != null);
        Assert.isTrue(contact.Name != opportunity.Related_Contact_Last_Name__c);
        Assert.isTrue(contact.AccountId != null);
    }

    @isTest
    static void testUpdateRelatedContactAndAccountInfo() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Redtag'];

        Contact contact = [
            SELECT Id,
                   Name, 
                   FirstName, 
                   LastName, 
                   AccountId 
            FROM Contact 
            WHERE AccountId =: account.Id
        ];

        Opportunity opportunity = [
            SELECT Id, 
                   Name, 
                   Related_Account_Name__c, 
                   Related_Contact_Last_Name__c, 
                   AccountId, 
                   Contact__c 
            FROM Opportunity 
            WHERE Related_Account_Name__c = :account.Name AND AccountId =: account.Id
        ];

        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();
        oldMap.put(opportunity.Id, opportunity);
        
        List<Opportunity> opportunityList = [
            SELECT Id, 
                   Name, 
                   Related_Account_Name__c, 
                   Related_Contact_Last_Name__c, 
                   AccountId, 
                   Contact__c 
            FROM Opportunity
            WHERE Related_Account_Name__c = :account.Name AND Related_Contact_Last_Name__c =: contact.Name
        ];

        Test.startTest();
        OpportunityHandlerService.updateAccountAndContactInfo(opportunityList, oldMap);
        Test.stopTest();

        Assert.isTrue(!opportunityList.isEmpty());
        Assert.isTrue(account.Id != null);
        Assert.isTrue(contact.Id != null);
        Assert.isTrue(opportunity.Id != null);
        Assert.isTrue(contact.Name == opportunity.Related_Contact_Last_Name__c);
        Assert.isTrue(account.Name == opportunity.Related_Account_Name__c);
        Assert.isTrue(contact.AccountId != null);
        Assert.isTrue(opportunity.AccountId != null);
    }

    @isTest
    static void testDeleteOpportunity() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Redtag'];

        Contact contact = [
            SELECT Id,
                   Name, 
                   FirstName, 
                   LastName, 
                   AccountId 
            FROM Contact 
            WHERE AccountId =: account.Id
        ];

        List<Opportunity> opportunityList = [
            SELECT Id, 
                   Name, 
                   Related_Account_Name__c, 
                   Related_Contact_Last_Name__c 
            FROM Opportunity
            WHERE Related_Account_Name__c = :account.Name AND Related_Contact_Last_Name__c =: contact.Name
        ];

        Test.startTest();
        OpportunityHandlerService.deleteOpportunity(opportunityList);
        Test.stopTest();

        Assert.isTrue(!opportunityList.isEmpty());
        Assert.isTrue(account.Id != null);
        Assert.isTrue(contact.Id != null);
        Assert.isTrue(opportunity.Id != null);
    }
}