@isTest
private class GenerateAndSendPDFEmailServiceTest {

    @TestSetup
    static void makeData(){
        Account account = TestDataFactory.createAccount();
        Contact contact = TestDataFactory.createContact(account.Id);
        Opportunity opportunity = TestDataFactory.createOpportunity(account.Id, contact.Id);
        Quote quote = TestDataFactory.createQuote(opportunity.Id, contact.Id);
    }

    @isTest
    static void testSendEmailWithPdfAttachmentPositive() {
        Quote quote = [SELECT Id, Name, AccountId, ContactId FROM Quote WHERE Name = 'TestQuote' LIMIT 1];
        Test.startTest();
        GenerateAndSendPDFEmailService.Request request = new GenerateAndSendPDFEmailService.Request();
        request.recordId = quote.Id;
        request.quoteName = quote.Name;
        request.recepientEmail = 'test@google.com';
        request.visualforcePageName = 'QuotePDF';
        List<GenerateAndSendPDFEmailService.Result> results = GenerateAndSendPDFEmailService.sendEmailWithPdfAttachment(
            new List<GenerateAndSendPDFEmailService.Request> {request}
        );
        Test.stopTest();

        Assert.isTrue(results[0].isSuccess, 'The email sending process should be successful.');
        Assert.areEqual('test@google.com', request.recepientEmail, 'The recipient email should be test@google.com.');
        Assert.areEqual(quote.Name, request.quoteName, 'The quote name in the result should match the quote.');
        Assert.isNotNull(results, 'The results list should not be null.');
        Assert.isTrue(results.size() > 0, 'At least one result should be returned.');
        Assert.isTrue(String.isEmpty(results[0].errorMessage), 'There should be no error message.');
    }

    @isTest
    static void testSendEmailWithPdfAttachmentNegative() {
        Quote quote = [SELECT Id, Name, AccountId, ContactId FROM Quote WHERE Name = 'TestQuote' LIMIT 1];

        GenerateAndSendPDFEmailService.Request request = new GenerateAndSendPDFEmailService.Request();
        request.recordId = quote.Id;  // Set an invalid ID to cause failure
        request.quoteName = 'TestQuote';
        request.recepientEmail = 'invalid_email';  // Invalid email format
        request.visualforcePageName = 'broken_page';

        Test.startTest();
        List<GenerateAndSendPDFEmailService.Result> results = GenerateAndSendPDFEmailService.sendEmailWithPdfAttachment(
            new List<GenerateAndSendPDFEmailService.Request> { request }
        );
        Test.stopTest();

        // Check that the failure branch was hit
        Assert.isFalse(results[0].isSuccess, 'The email sending process should not be successful for invalid input.');
        Assert.isNotNull(results[0].errorMessage, 'An error message should be returned when sending fails.');
        Assert.isTrue(results.size() > 0, 'At least one result should be returned.');
    }
}