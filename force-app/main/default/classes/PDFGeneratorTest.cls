@isTest
private class PDFGeneratorTest {

    @TestSetup
    static void makeData(){
        Account account = TestDataFactory.createAccount();
        Contact contact = TestDataFactory.createContact(account.Id);
        Opportunity opportunity = TestDataFactory.createOpportunity(account.Id, contact.Id);
        Quote quote = TestDataFactory.createQuote(opportunity.Id, contact.Id);
    }

    @isTest
    static void testGenerator() {
        Quote quote = [SELECT Id, Name, AccountId, ContactId FROM Quote WHERE Name = 'TestQuote' LIMIT 1];
        Test.startTest();
        GenerateAndSendPDFEmailService.Request request = new GenerateAndSendPDFEmailService.Request();
        request.recordId = quote.Id;
        request.recepientEmail = 'test@google.com';
        request.visualforcePageName = 'QuotePDF';
        List<GenerateAndSendPDFEmailService.Result> results = GenerateAndSendPDFEmailService.sendEmailWithPdfAttachment(new List<GenerateAndSendPDFEmailService.Request> {request});
        Test.stopTest();

        Assert.isTrue(results[0].isSuccess);
    }
}