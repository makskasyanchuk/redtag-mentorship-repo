public with sharing class OpportunityHandlerService {
    public static void createRelatedAccountAndContact(List<Opportunity> opportunityList) {
        List<Account> accountsList = prepareRelatedAccount(opportunityList);
        List<Contact> contactsList = prepareRelatedContact(opportunityList);
        List<Opportunity> updatedOpportunityList = prepareOpportunity(opportunityList, 'Prospecting', Date.today().addDays(90));

        insert accountsList;
        insert contactsList;
    }

    public static void updateAccountAndContactInfo(List<Opportunity> opportunityList, Map<Id, Opportunity> oldMap) {
        Map<String, Id> accountIdByNameMap = new Map<String, Id>();
        Map<String, Id> contactIdByNameMap = new Map<String, Id>();

        List<Account> accountsToUpsert = updateAccountInfo(opportunityList, oldMap);
        upsert accountsToUpsert;

        for(Account acct : accountsToUpsert) {
            if(!accountIdByNameMap.containsKey(acct.Name)) {
                accountIdByNameMap.put(acct.Name, acct.Id);
            }
        }

        List<Contact> contactsToUpsert = updateContactInfo(opportunityList, oldMap, accountIdByNameMap);
        upsert contactsToUpsert;

        for(Contact con : contactsToUpsert) {
            if(!contactIdByNameMap.containsKey(con.LastName)) {
                contactIdByNameMap.put(con.LastName, con.Id);
            }
        }

        List<Opportunity> opportunitiesToUpdate = updateOpportunityList(opportunityList, accountIdByNameMap, contactIdByNameMap);
    }

    public static void deleteOpportunity(List<Opportunity> opportunityList) {
        EmailTemplate template = [SELECT Id, Subject, Body, HtmlValue FROM EmailTemplate WHERE Name = 'Opportunity Notification'];
        EmailService emailService = new EmailService();
        List<Messaging.SendEmailResult> results = emailService.sendOpportunityEmailToOwner(opportunityList, template.Id);
    }

    @TestVisible
    private static List<Opportunity> updateOpportunityList(List<Opportunity> opportunityList, Map<String, Id> accountIdByNameMap, Map<String, Id> contactIdByNameMap) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for (Opportunity opp : opportunityList) {
            opp.AccountId = accountIdByNameMap.get(opp.Related_Account_Name__c);
            opp.Contact__c = contactIdByNameMap.get(opp.Related_Contact_Last_Name__c);
            opportunitiesToUpdate.add(opp);
        }
        
        return opportunitiesToUpdate;
    }
    
    @TestVisible
    private static List<Account> updateAccountInfo(List<Opportunity> opportunityList, Map<Id, Opportunity> oldMap) {
        List<Account> accountsToUpsert = new List<Account>();
        Map<Id, Account> accountsMap = new Map<Id, Account>();
        Set<String> relatedAccountNames = new Set<String>();

        for(Opportunity opp : opportunityList) {
            relatedAccountNames.add(opp.Related_Account_Name__c);
            relatedAccountNames.add(oldMap.get(opp.Id).Related_Account_Name__c);
        }

        for (Account acct : [
            SELECT Id, Name FROM Account WHERE Name IN :relatedAccountNames
        ]) {
            if(!accountsMap.containsKey(acct.Id)) {
                accountsMap.put(acct.Id, acct);
            }
        }

        for(Opportunity opp : opportunityList) {
            if(
                oldMap.get(opp.Id).Related_Account_Name__c.contains(opp.Related_Account_Name__c) ||
                opp.Related_Account_Name__c.contains(oldMap.get(opp.Id).Related_Account_Name__c)
            ) {
                Account accountToUpdate = accountsMap.containsKey(oldMap.get(opp.Id).AccountId)
                ? accountsMap.get(oldMap.get(opp.Id).AccountId)
                : accountsMap.get(opp.AccountId);

                accountToUpdate.Name = opp.Related_Account_Name__c;
                accountsToUpsert.add(accountToUpdate);
            } else {
                Account accountToInsert = new Account();
                accountToInsert.Name = opp.Related_Account_Name__c;
                accountsToUpsert.add(accountToInsert);
            }
        }

        return accountsToUpsert;
    }

    @TestVisible
    private static List<Contact> updateContactInfo(List<Opportunity> opportunityList, Map<Id, Opportunity> oldMap, Map<String, Id> accountIdByNameMap) {
        List<Contact> contactsToUpsert = new List<Contact>();
        Map<Id, Contact> contactsMap = new Map<Id, Contact>();
        Set<String> relatedContactNames = new Set<String>();

        for(Opportunity opp : opportunityList) {
            relatedContactNames.add(opp.Related_Contact_Last_Name__c);
            relatedContactNames.add(oldMap.get(opp.Id).Related_Contact_Last_Name__c);
        }

        for (Contact con : [
            SELECT Id, LastName FROM Contact WHERE LastName IN :relatedContactNames
        ]) {
            if(!contactsMap.containsKey(con.Id)) {
                contactsMap.put(con.Id, con);
            }
        }

        for(Opportunity opp : opportunityList) {
            if(
                oldMap.get(opp.Id).Related_Contact_Last_Name__c.contains(opp.Related_Contact_Last_Name__c) ||
                opp.Related_Contact_Last_Name__c.contains(oldMap.get(opp.Id).Related_Contact_Last_Name__c)
            ) {
                Contact contactToUpdate = contactsMap.containsKey(oldMap.get(opp.Id).Contact__c)
                ? contactsMap.get(oldMap.get(opp.Id).Contact__c)
                : contactsMap.get(opp.Contact__c);

                contactToUpdate.LastName = opp.Related_Contact_Last_Name__c;
                contactToUpdate.AccountId = accountIdByNameMap.get(opp.Related_Account_Name__c);
                contactsToUpsert.add(contactToUpdate);
            } else {
                Contact contactToInsert = new Contact();
                contactToInsert.LastName = opp.Related_Contact_Last_Name__c;
                contactToInsert.AccountId = accountIdByNameMap.get(opp.Related_Account_Name__c);
                contactsToUpsert.add(contactToInsert);
            }
        }

        return contactsToUpsert;
    }

    @TestVisible
    private static List<Account> prepareRelatedAccount(List<Opportunity> opportunityList) {
        List<Account> accountsList = new List<Account>();
        Map<String, Id> accountsMap = new Map<String, Id>();
        Set<String> accountNameSet = new Set<String>();

        for (Opportunity opp : opportunityList) {
            accountNameSet.add(opp.Related_Account_Name__c);
        }

        for (Account existingAccount : [
            SELECT Id, Name FROM Account WHERE Name IN :accountNameSet WITH SECURITY_ENFORCED
        ]) {
            if (!accountsMap.containsKey(existingAccount.Name)) {
                accountsMap.put(existingAccount.Name, existingAccount.Id);
            }
        }

        for (Opportunity opp : opportunityList) {
            if (!accountsMap.containsKey(opp.Related_Account_Name__c)) {
                accountsList.add(new Account(
                    Name = opp.Related_Account_Name__c
                ));
                opp.AccountId = accountsMap.get(opp.Related_Account_Name__c);
            } else {
                opp.AccountId = accountsMap.get(opp.Related_Account_Name__c);
            }
        }

        return accountsList;
    }

    @TestVisible
    private static List<Contact> prepareRelatedContact(List<Opportunity> opportunityList) {
        Map<String, Account> accountsMap = new Map<String, Account>();
        Map<String, Contact> contactsMap = new Map<String, Contact>();
        List<Contact> contactList = new List<Contact>();
        Set<String> relatedRecordNames = new Set<String>();

        for (Opportunity opp : opportunityList) {
            relatedRecordNames.add(opp.Related_Contact_Last_Name__c);
            relatedRecordNames.add(opp.Related_Account_Name__c);
        }

        for (Account existingAccount : [
            SELECT Id, Name FROM Account WHERE Name IN :relatedRecordNames WITH SECURITY_ENFORCED
        ]) {
            if(!accountsMap.containsKey(existingAccount.Name)) {
                accountsMap.put(existingAccount.Name, existingAccount);
            }
        }

        for (Contact existingContact : [
            SELECT Id, LastName, AccountId FROM Contact WHERE LastName IN :relatedRecordNames
        ]) {
            if (!contactsMap.containsKey(existingContact.LastName)) {
                contactsMap.put(existingContact.LastName, existingContact);
            }
        }

        for (Opportunity opp : opportunityList) {
            for (Account acct : accountsMap.values()) {
                if (!contactsMap.containsKey(opp.Related_Contact_Last_Name__c)) {
                    contactList.add(new Contact(
                        LastName = opp.Related_Contact_Last_Name__c,
                        AccountId = acct.Id
                    ));
                }
            }
        }

        return contactList;
    }

    @TestVisible
    private static List<Opportunity> prepareOpportunity(List<Opportunity> opportunityList, String stageName, Date closeDate) {
        Set<String> relatedRecordNames = new Set<String>();

        Map<String, Id> accountIdByNameMap = new Map<String, Id>();
        Map<String, Id> contactIdByNameMap = new Map<String, Id>();
        
        for (Opportunity opp : opportunityList) {
            relatedRecordNames.add(opp.Related_Account_Name__c);
            relatedRecordNames.add(opp.Related_Contact_Last_Name__c);
        }     

        for(Account acct : [
            SELECT Id, Name FROM Account WHERE Name IN :relatedRecordNames WITH SECURITY_ENFORCED
        ]) {
            if(!accountIdByNameMap.containsKey(acct.Name)) {
                accountIdByNameMap.put(acct.Name, acct.Id);
            }
        }

        for(Contact con : [
            SELECT Id, LastName FROM Contact WHERE AccountId IN :accountIdByNameMap.values() AND LastName IN :relatedRecordNames
        ]) {
            if(!contactIdByNameMap.containsKey(con.LastName)) {
                contactIdByNameMap.put(con.LastName, con.Id);
            }
        }

        for (Opportunity opp : opportunityList) {
                opp.Name = opp.Related_Account_Name__c + ' from ' + Datetime.now().format('dd MMMM yyyy');
                opp.AccountId = accountIdByNameMap.get(opp.Related_Account_Name__c);
                opp.Contact__c = contactIdByNameMap.get(opp.Related_Contact_Last_Name__c);
                opp.StageName = stageName;
                opp.CloseDate = closeDate;
        }

        return opportunityList;
    }
}