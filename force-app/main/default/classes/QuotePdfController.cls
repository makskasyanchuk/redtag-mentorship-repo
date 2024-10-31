public with sharing class QuotePdfController {
    public List<QuoteLineItem> quoteLineItems {get;set;}
    public Quote quote {get;set;}
    public static String quoteId = ApexPages.currentPage().getParameters().get('Id');

    public QuotePdfController() {
        quote = getQuote(quoteId);
        quoteLineItems = getQuoteLineItems(quoteId);
    }

    @TestVisible
    private static List<QuoteLineItem> getQuoteLineItems(Id quoteId) {
        return  [
            SELECT Id,
                   Product2.Name, 
                   Quote_Line_Item_Image__c, 
                   QuoteId, 
                   UnitPrice, 
                   Quantity 
            FROM QuoteLineItem 
            WHERE QuoteId =: quoteId
        ];
    }

    @TestVisible
    private static Quote getQuote(Id quoteId) {
        return [SELECT Id, Name, AccountId, ContactId FROM Quote WHERE Id =: quoteId LIMIT 1];
    }
}