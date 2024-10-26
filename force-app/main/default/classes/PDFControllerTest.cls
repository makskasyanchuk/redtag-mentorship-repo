@isTest
private class PDFControllerTest {

    @TestSetup
    static void makeData(){
        Account account = TestDataFactory.createAccount();
        Contact contact = TestDataFactory.createContact(account.Id);
        Opportunity opportunity = TestDataFactory.createOpportunity(account.Id, contact.Id);
        Quote quote = TestDataFactory.createQuote(opportunity.Id, contact.Id);
    }
    
    @isTest
    static void testController() {
       Quote quote = [SELECT Id, Name, AccountId, ContactId FROM Quote WHERE Name = 'TestQuote' LIMIT 1];
       Test.setCurrentPage(Page.QuotePDF);
       ApexPages.currentPage().getParameters().put('Id', quote.Id);
       Test.startTest();
       PDFController controller = new PDFController();
       Test.stopTest();
    
       Assert.isTrue(quote.Id != null);
       Assert.isTrue(quote.Name != null);
       Assert.isTrue(quote.AccountId != null);
       Assert.isTrue(quote.ContactId != null);
    }

    @isTest
    static void testGetQuoteLineItems() {
       Quote quote = [SELECT Id, Name, AccountId, ContactId FROM Quote WHERE Name = 'TestQuote' LIMIT 1];
       
       Test.startTest();
       PDFController.getQuoteLineItems(quote.Id);
       Test.stopTest();

       Assert.isTrue(quote.Id != null);
       Assert.isTrue(quote.Name != null);
       Assert.isTrue(quote.AccountId != null);
       Assert.isTrue(quote.ContactId != null);
    }

    @isTest
    static void testGetQuote() {
       Quote quote = [SELECT Id, Name, AccountId, ContactId FROM Quote WHERE Name = 'TestQuote' LIMIT 1];
       
       Test.startTest();
       PDFController.getQuote(quote.Id);
       Test.stopTest();
    
       Assert.isTrue(quote.Id != null);
       Assert.isTrue(quote.Name != null);
       Assert.isTrue(quote.AccountId != null);
       Assert.isTrue(quote.ContactId != null);
    }
}