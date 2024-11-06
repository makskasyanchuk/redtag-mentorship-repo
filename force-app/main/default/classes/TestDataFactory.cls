@isTest
public class TestDataFactory {
    public static Account createAccount() {
        Account acct = new Account(
            Name = 'Redtag'
        );
        insert acct;
        
        return acct;
    }

    public static Contact createContact(Id acctId) {
        Contact cont = new Contact(
            LastName = 'Maksym Kasyanchuk',
            AccountId = acctId
        );
        insert cont;

        return cont;
    }

    public static Opportunity createOpportunity(Id acctId, Id contId) {
        Opportunity opp = new Opportunity(
            Name = 'Redtag' + ' from ' + Datetime.now().format('dd MMMM yyyy'),
            Related_Account_Name__c = 'Redtag',
            Related_Contact_Last_Name__c = 'Maksym Kasyanchuk',
            AccountId = acctId,
            Contact__c = contId
        );
        insert opp;

        return opp;
    }

    public static Product2 createProduct() {
        Product2 product = new Product2(Name = 'Test Product', IsActive = true);
        insert product;

        return product;
    }

    public static Pricebook2 createPricebook() {
        Pricebook2 customPricebook = new Pricebook2(Name = 'Custom Pricebook', IsActive = true);
        insert customPricebook;

        return customPricebook;
    }

    public static PricebookEntry createPricebookEntry(Id productId, Id pricebookId) {
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = productId,
            UnitPrice = 100,
            IsActive = true
        );
        insert pricebookEntry;

        return pricebookEntry;
    }

    public static OpportunityLineItem createOpportunityLineItem(Id opportunityId, Id peId) {
        OpportunityLineItem lineItem = new OpportunityLineItem(
            OpportunityId = opportunityId,
            PricebookEntryId = peId,
            Quantity = 1,
            TotalPrice = 100
        );
        insert lineItem;

        return lineItem;
    }

    public static List<Opportunity> createWonOpportunities(Id accountId, Id contactId) {
        Integer currentMonth = Date.today().month();
        Integer currentQuarter = ((currentMonth - 1) / 3) + 1;

        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
        if (currentQuarter == 4) {
            for (Integer i = 0; i < 5; i++) {
                Opportunity wonOpportunity = new Opportunity();
                wonOpportunity.Name = 'Closed Won Opp ' + i;
                wonOpportunity.StageName = 'Closed Won';
                wonOpportunity.CloseDate = Date.newInstance(Date.today().year(), 10, 15);
                wonOpportunity.AccountId = accountId;
                wonOpportunity.Contact__c = contactId;
                wonOpportunity.Related_Account_Name__c = 'Test AccountQ41';
                wonOpportunity.Related_Contact_Last_Name__c = 'Test ContactQ41';
    
                opportunitiesToInsert.add(wonOpportunity);
            }
        }

        insert opportunitiesToInsert;

        return opportunitiesToInsert;
    }

    public static List<Opportunity> createLostOpportunities(Id accountId, Id contactId) {
        Integer currentMonth = Date.today().month();
        Integer currentQuarter = ((currentMonth - 1) / 3) + 1;

        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
        if (currentQuarter == 4) {
            for (Integer i = 0; i < 5; i++) {
                Opportunity lostOpportunity = new Opportunity();
                lostOpportunity.Name = 'Closed Lost Opp ' + i;
                lostOpportunity.StageName = 'Closed Lost';
                lostOpportunity.CloseDate = Date.newInstance(Date.today().year(), 10, 15);
                lostOpportunity.AccountId = accountId;
                lostOpportunity.Contact__c = contactId;
                lostOpportunity.Related_Account_Name__c = 'Test AccountQ42';
                lostOpportunity.Related_Contact_Last_Name__c = 'Test ContactQ42';
    
                opportunitiesToInsert.add(lostOpportunity);
            }
        }

        insert opportunitiesToInsert;

        return opportunitiesToInsert;
    } 

    public static Quote createQuote(Id opportunityId, Id contactId) {
        Quote quote = new Quote(
            Name = 'TestQuote',
            OpportunityId = opportunityId,
            ContactId = contactId
        );
        insert quote;

        return quote;
    }

    public static Opportunity_Statistics__c createStats(List<Opportunity> wonOpps, List<Opportunity> lostOpps) {
        Opportunity_Statistics__c stats = new Opportunity_Statistics__c(
            Closed_Won_Opportunities__c = (Integer) wonOpps.size(),
            Closed_Lost_Opportunities__c = (Integer) lostOpps.size()
        );
        insert stats;
        
        return stats;
    }
}