@isTest
private class EmailServiceTest {
    @TestSetup
    static void makeData(){
        Account account = TestDataFactory.createAccount();
        Contact contact = TestDataFactory.createContact(account.Id);
        Opportunity opportunity = TestDataFactory.createOpportunity(account.Id, contact.Id);
    }

    @isTest
    static void testEmailService() {
        Account account = [SELECT Id, Name FROM Account WHERE Name = 'Redtag'];
        Contact contact = [
            SELECT Id, LastName, AccountId FROM Contact WHERE AccountId =: account.Id
            AND LastName = 'Maksym Kasyanchuk'
        ];
        List<Opportunity> opportunityList = [
            SELECT Id, Name, Related_Account_Name__c, Related_Contact_Last_Name__c, AccountId, Contact__c
            FROM Opportunity WHERE Related_Account_Name__c = :account.Name AND Related_Contact_Last_Name__c =: contact.LastName
        ];

        EmailTemplate et = new EmailTemplate();
        et.isActive = true;
        et.Name = 'testTemplate';
        et.DeveloperName = 'testTemplate' + System.now().getTime();
        et.TemplateType = 'text';
        et.FolderId = UserInfo.getUserId();
        et.Body = '';
        insert et;

        Test.startTest();
        EmailService es = new EmailService();
        List<Messaging.SendEmailResult> results = es.sendOpportunityEmailToOwner(opportunityList, et.Id);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        Assert.areEqual(1, invocations, 'Email is sent');
    }
}