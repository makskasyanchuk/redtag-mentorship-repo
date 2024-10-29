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

    public static Quote createQuote(Id opportunityId, Id contactId) {
        Quote quote = new Quote(
            Name = 'TestQuote',
            OpportunityId = opportunityId,
            ContactId = contactId
        );
        insert quote;
        return quote;
    }

    public static Opportunity_Statistics__c createStats() {
        Opportunity_Statistics__c stats = new Opportunity_Statistics__c(
            Closed_Won_Opportunities__c = 1,
            Closed_Lost_Opportunities__c = 1
        );
        insert stats;
        return stats;
    }
}