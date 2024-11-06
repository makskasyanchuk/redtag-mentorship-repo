public with sharing class OpportunityHandlerService {

    @TestVisible
    private static Map<String, String> parseFullName(String fullName) {
        Map<String, String> nameParts = new Map<String, String>();
        if (String.isNotBlank(fullName)) {
            List<String> splitName = fullName.trim().split('\\s+');
            nameParts.put('FirstName', splitName[0]);
            nameParts.put('LastName', splitName.size() > 1 ? splitName[1] : '');
        } else {
            nameParts.put('FirstName', '');
            nameParts.put('LastName', '');
        }
        return nameParts;
    }

    public static void createRelatedAccountAndContact(List<Opportunity> opportunityList) {
        List<Account> accountsList = prepareRelatedAccount(opportunityList);
        insert accountsList;
        
        List<Contact> contactsList = prepareRelatedContact(opportunityList);
        insert contactsList;

        List<Opportunity> updatedOpportunityList = prepareOpportunity(opportunityList, 'Prospecting', Date.today().addDays(90));
    }

    public static void updateAccountAndContactInfo(List<Opportunity> opportunityList, Map<Id, Opportunity> oldMap) {
        Map<String, Id> accountIdByNameMap = new Map<String, Id>();
        Map<String, Id> contactIdByNameMap = new Map<String, Id>();

        List<Account> accountsToUpsert = updateAccountInfo(opportunityList, oldMap);
        upsert accountsToUpsert;

        for (Account account : accountsToUpsert) {
            if (!accountIdByNameMap.containsKey(account.Name)) {
                accountIdByNameMap.put(account.Name, account.Id);
            }
        }

        List<Contact> contactsToUpsert = updateContactInfo(opportunityList, oldMap, accountIdByNameMap);
        upsert contactsToUpsert;

        for (Contact contact : contactsToUpsert) {
            if (!contactIdByNameMap.containsKey(contact.Name)) {
                contactIdByNameMap.put(contact.Name, contact.Id);
            }
        }

        List<Opportunity> opportunitiesToUpdate = updateOpportunityList(opportunityList, accountIdByNameMap, contactIdByNameMap);
    }

    public static void deleteOpportunity(List<Opportunity> opportunityList) {
        EmailTemplate template = [SELECT Id, Subject, Body, HtmlValue FROM EmailTemplate WHERE Name = 'Opportunity Notification'];
        OpportunityEmailSenderBatch emailBatch = new OpportunityEmailSenderBatch(opportunityList, template.Id);
        emailBatch.start(null);
        emailBatch.execute(null, opportunityList);
    }

    @TestVisible
    private static List<Opportunity> updateOpportunityList(List<Opportunity> opportunityList, Map<String, Id> accountIdByNameMap, Map<String, Id> contactIdByNameMap) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for (Opportunity opportunity : opportunityList) {
            opportunity.AccountId = accountIdByNameMap.get(opportunity.Related_Account_Name__c);
            opportunity.Contact__c = contactIdByNameMap.get(opportunity.Related_Contact_Last_Name__c);
            opportunitiesToUpdate.add(opportunity);
        }
        
        return opportunitiesToUpdate;
    }
    
    @TestVisible
    private static List<Account> updateAccountInfo(List<Opportunity> opportunityList, Map<Id, Opportunity> oldMap) {
        List<Account> accountsToUpsert = new List<Account>();

        Map<Id, Account> accountsMap = new Map<Id, Account>();
        Set<String> relatedAccountNames = new Set<String>();

        for (Opportunity opportunity : opportunityList) {
            relatedAccountNames.add(opportunity.Related_Account_Name__c);
            relatedAccountNames.add(oldMap.get(opportunity.Id).Related_Account_Name__c);
        }

        List<Account> existingAccountsWithRelatedAccountNames = [SELECT Id, Name FROM Account WHERE Name IN :relatedAccountNames];

        for (Account account : existingAccountsWithRelatedAccountNames) {
            if (!accountsMap.containsKey(account.Id)) {
                accountsMap.put(account.Id, account);
            }
        }

        for (Opportunity opportunity : opportunityList) {
            if (
                oldMap.get(opportunity.Id).Related_Account_Name__c.contains(opportunity.Related_Account_Name__c) ||
                opportunity.Related_Account_Name__c.contains(oldMap.get(opportunity.Id).Related_Account_Name__c)
            ) {
                Account accountToUpdate = accountsMap.containsKey(oldMap.get(opportunity.Id).AccountId)
                ? accountsMap.get(oldMap.get(opportunity.Id).AccountId)
                : accountsMap.get(opportunity.AccountId);

                accountToUpdate.Name = opportunity.Related_Account_Name__c;
                accountsToUpsert.add(accountToUpdate);
            } else {
                Account accountToInsert = new Account();
                accountToInsert.Name = opportunity.Related_Account_Name__c;
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

        for (Opportunity opportunity : opportunityList) {
            relatedContactNames.add(opportunity.Related_Contact_Last_Name__c);
            relatedContactNames.add(oldMap.get(opportunity.Id).Related_Contact_Last_Name__c);
        }

        List<Contact> existingContactsWithRelatedContactNames = [SELECT Id, Name, FirstName, LastName FROM Contact WHERE Name IN :relatedContactNames];

        for (Contact contact : existingContactsWithRelatedContactNames) {
            if (!contactsMap.containsKey(contact.Id)) {
                contactsMap.put(contact.Id, contact);
            }
        }

        for (Opportunity opportunity : opportunityList) {
            Map<String, String> nameParts = parseFullName(opportunity.Related_Contact_Last_Name__c);
            String firstName = nameParts.get('FirstName');
            String lastName = nameParts.get('LastName');

            if (
                oldMap.get(opportunity.Id).Related_Contact_Last_Name__c.contains(opportunity.Related_Contact_Last_Name__c) ||
                opportunity.Related_Contact_Last_Name__c.contains(oldMap.get(opportunity.Id).Related_Contact_Last_Name__c)
            ) {
                Contact contactToUpdate = contactsMap.containsKey(oldMap.get(opportunity.Id).Contact__c)
                ? contactsMap.get(oldMap.get(opportunity.Id).Contact__c)
                : contactsMap.get(opportunity.Contact__c);

                contactToUpdate.FirstName = firstName;
                contactToUpdate.LastName = lastName;
                contactToUpdate.AccountId = accountIdByNameMap.get(opportunity.Related_Account_Name__c);
                contactsToUpsert.add(contactToUpdate);
            } else {
                Contact contactToInsert = new Contact();
                contactToInsert.FirstName = firstName;
                contactToInsert.LastName = lastName;
                contactToInsert.AccountId = accountIdByNameMap.get(opportunity.Related_Account_Name__c);
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

        for (Opportunity opportunity : opportunityList) {
            if (String.isNotBlank(opportunity.Related_Account_Name__c)) {
                accountNameSet.add(opportunity.Related_Account_Name__c);
            }
        }

        List<Account> existingAccountsWithRelatedAccountNames = [SELECT Id, Name FROM Account WHERE Name IN :accountNameSet];

        for (Account existingAccount : existingAccountsWithRelatedAccountNames) {
            if (!accountsMap.containsKey(existingAccount.Name)) {
                accountsMap.put(existingAccount.Name, existingAccount.Id);
            }
        }

        for (Opportunity opportunity : opportunityList) {
            if (!accountsMap.containsKey(opportunity.Related_Account_Name__c)) {
                accountsList.add(new Account(
                    Name = opportunity.Related_Account_Name__c
                ));
                opportunity.AccountId = accountsMap.get(opportunity.Related_Account_Name__c);
            } else {
                opportunity.AccountId = accountsMap.get(opportunity.Related_Account_Name__c);
            }
        }

        return accountsList;
    }

    @TestVisible
    private static List<Contact> prepareRelatedContact(List<Opportunity> opportunityList) {
        List<Contact> contactList = new List<Contact>();
        Map<String, Account> accountsMap = new Map<String, Account>();
        Map<String, Contact> contactsMap = new Map<String, Contact>();
        Set<String> relatedRecordNames = new Set<String>();

        for (Opportunity opportunity : opportunityList) {
            if (String.isNotBlank(opportunity.Related_Account_Name__c) && String.isNotBlank(opportunity.Related_Contact_Last_Name__c)) {
                relatedRecordNames.add(opportunity.Related_Contact_Last_Name__c);
                relatedRecordNames.add(opportunity.Related_Account_Name__c);
            } 
        }

        List<Account> existingAccountsWithRelatedRecordNames = [SELECT Id, Name FROM Account WHERE Name IN :relatedRecordNames];

        for (Account existingAccount : existingAccountsWithRelatedRecordNames) {
            if (!accountsMap.containsKey(existingAccount.Name)) {
                accountsMap.put(existingAccount.Name, existingAccount);
            }
        }

        List<Contact> existingContactsWithRelatedRecordNames = [SELECT Id, Name, FirstName, LastName, AccountId FROM Contact WHERE Name IN :relatedRecordNames];

        for (Contact existingContact : existingContactsWithRelatedRecordNames) {
            if (!contactsMap.containsKey(existingContact.Name)) {
                contactsMap.put(existingContact.Name, existingContact);
            }
        }

        for (Opportunity opp : opportunityList) {
            Map<String, String> nameParts = parseFullName(opp.Related_Contact_Last_Name__c);
            String firstName = nameParts.get('FirstName');
            String lastName = nameParts.get('LastName');

            for (Account acct : accountsMap.values()) {
                if (!contactsMap.containsKey(opp.Related_Contact_Last_Name__c)) {
                    contactList.add(new Contact(
                        FirstName = firstName,
                        LastName = lastName,
                        AccountId = acct.Id
                    ));
                }
            }
        }

        return contactList;
    }   

    @TestVisible
    private static List<Opportunity> prepareOpportunity(List<Opportunity> opportunityList, String stageName, Date closeDate) {
        Map<String, Id> accountIdByNameMap = new Map<String, Id>();
        Map<String, Id> contactIdByNameMap = new Map<String, Id>();
        Set<String> relatedRecordNames = new Set<String>();

        for (Opportunity opportunity : opportunityList) {
            relatedRecordNames.add(opportunity.Related_Account_Name__c);
            relatedRecordNames.add(opportunity.Related_Contact_Last_Name__c);
        }     

        List<Account> existingAccountsWithRelatedRecordNames = [SELECT Id, Name FROM Account WHERE Name IN :relatedRecordNames];

        for (Account account : existingAccountsWithRelatedRecordNames) {
            if (!accountIdByNameMap.containsKey(account.Name)) {
                accountIdByNameMap.put(account.Name, account.Id);
            }
        }

        List<Contact> existingContactsWithRelatedRecordNames = [
            SELECT 
                Id,
                Name,
                FirstName,
                LastName 
            FROM Contact 
            WHERE AccountId IN :accountIdByNameMap.values() AND Name IN :relatedRecordNames
        ];

        for (Contact contact : existingContactsWithRelatedRecordNames) {
            if (!contactIdByNameMap.containsKey(contact.Name)) {
                contactIdByNameMap.put(contact.Name, contact.Id);
            }
        }

        for (Opportunity opportunity : opportunityList) {
            Map<String, String> nameParts = parseFullName(opportunity.Related_Contact_Last_Name__c);
            String firstName = nameParts.get('FirstName');
            String lastName = nameParts.get('LastName');
            String fullName = firstName + ' ' + lastName;

            opportunity.Name = opportunity.Related_Account_Name__c + ' from ' + Datetime.now().format('dd MMMM yyyy');
            opportunity.AccountId = accountIdByNameMap.get(opportunity.Related_Account_Name__c);
            opportunity.Contact__c = contactIdByNameMap.get(fullName);
            opportunity.PriceBook2Id = '01sQy000005wwwoIAA';
            opportunity.StageName = stageName;
            opportunity.CloseDate = closeDate;
        }

        return opportunityList;
    }
}