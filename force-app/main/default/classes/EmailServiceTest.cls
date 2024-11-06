@isTest
private class EmailServiceTest {
    @TestSetup
    static void makeData(){
        Account account = TestDataFactory.createAccount();
        Contact contact = TestDataFactory.createContact(account.Id);
        Opportunity opportunity = TestDataFactory.createOpportunity(account.Id, contact.Id);
        Quote quote = TestDataFactory.createQuote(opportunity.Id, contact.Id);
    }

    @isTest
    static void testEmailService() {
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

    @isTest
    static void testSendEmailWithPdf() {
        Quote quote = [SELECT Id, Name, AccountId, ContactId FROM Quote WHERE Name = 'TestQuote' LIMIT 1];

        String recepientEmail = 'test@google.com';
        Blob pdfBlob = Blob.valueOf('Test PDF');

        Test.startTest();
        List<Messaging.SendEmailResult> emailMessage = EmailService.sendEmailWithPdf(recepientEmail, pdfBlob, quote.Name);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        Assert.areEqual(1, invocations, 'Email should be sent');
        Assert.isFalse(pdfBlob == null);
    }

    @isTest
    static void testSendEmailWithSummary() {
        String body = 'test body';

        Test.startTest();
        EmailService.sendEmailWithSummary(body);
        Integer invocations = Limits.getEmailInvocations(); 
        Test.stopTest();

        Assert.areEqual(1, invocations);
    }

    @isTest
    static void testGetPdfContent() {
        Quote quote = [SELECT Id, Name, AccountId, ContactId FROM Quote WHERE Name = 'TestQuote' LIMIT 1];
        String vfPageName = 'QuotePDF';

        Test.startTest();
        Blob quotePdf = EmailService.getPDFContent(quote.Id, vfPageName);
        Test.stopTest();

        Assert.isTrue(quotePdf != null);
        Assert.isTrue(quote.Id != null);
    }
}