### **Class Documentation: `OpportunityHandlerService`**

**Purpose**  
The `OpportunityHandlerService` class is responsible for managing and automating the creation, updating, and deletion of related `Account` and `Contact` records when an `Opportunity` record is created, updated, or deleted. The class also ensures that related records are correctly linked to `Opportunity` records and provides mechanisms to notify Opportunity owners via email when certain conditions are met. This class helps scale business automation, streamlining processes and reducing manual data entry.

**Access Level**  
`public with sharing` \- This ensures that the class respects the user’s sharing permissions when accessing data in Salesforce.

---

### **Method: `createRelatedAccountAndContact`**

`public static void createRelatedAccountAndContact(List<Opportunity> opportunityList)`

**Purpose**  
This method creates related `Account` and `Contact` records for each `Opportunity` in the list. It also prepares opportunities by setting their stage to "Prospecting" and adjusting the close date to 90 days from today.

**Parameters**

* `opportunityList` (List\<Opportunity\>): A list of `Opportunity` records to process for creating related `Account` and `Contact` records.

**Return**

* No return. This method performs DML operations (`insert`).

**Actions**

1. Prepares a list of `Account` records based on the `Opportunity` records.  
2. Prepares a list of `Contact` records.  
3. Updates the stage and close date of the opportunities.  
4. Inserts the new `Account` and `Contact` records into the database.

---

### **Method: `updateAccountAndContactInfo`**

`public static void updateAccountAndContactInfo(List<Opportunity> opportunityList, Map<Id, Opportunity> oldMap)`

**Purpose**  
Updates the information for related `Account` and `Contact` records when an `Opportunity` is updated. It manages the upsert of `Account` and `Contact` records and ensures that the related opportunities are properly linked to the updated records.

**Parameters**

* `opportunityList` (List\<Opportunity\>): A list of new `Opportunity` records being updated.  
* `oldMap` (Map\<Id, Opportunity\>): A map of old `Opportunity` records (before update) indexed by `Opportunity` ID.

**Return**

* No return. This method performs DML operations (`upsert`).

**Actions**

1. Updates or inserts the related `Account` records using `upsert`.  
2. Updates or inserts the related `Contact` records using `upsert`.  
3. Prepares and updates the related `Opportunity` records to link them to the correct `Account` and `Contact` records.

---

### **Method: `deleteOpportunity`**

`public static void deleteOpportunity(List<Opportunity> opportunityList)`

**Purpose**  
Sends a notification email to the `Opportunity` owner when certain opportunities are deleted, using a predefined email template.

**Parameters**

* `opportunityList` (List\<Opportunity\>): A list of `Opportunity` records to process for deletion.

**Return**

* No return. This method sends emails via `Messaging.SendEmailResult`.

**Actions**

1. Retrieves an email template named "Opportunity Notification".  
2. Uses an email service to send notifications to the `Opportunity` owners.

---

### **Method: `updateOpportunityList`**

`@TestVisible private static List<Opportunity> updateOpportunityList(List<Opportunity> opportunityList, Map<String, Id> accountIdByNameMap, Map<String, Id> contactIdByNameMap)`

**Purpose**  
Updates the `Opportunity` records by linking them to the correct `Account` and `Contact` records based on the provided maps of account and contact IDs.

**Parameters**

* `opportunityList` (List\<Opportunity\>): A list of `Opportunity` records to update.  
* `accountIdByNameMap` (Map\<String, Id\>): A map of `Account` names to IDs.  
* `contactIdByNameMap` (Map\<String, Id\>): A map of `Contact` last names to IDs.

**Return**

* Returns a list of updated `Opportunity` records.

---

### **Method: `updateAccountInfo`**

`@TestVisible private static List<Account> updateAccountInfo(List<Opportunity> opportunityList, Map<Id, Opportunity> oldMap)`

**Purpose**  
Prepares and updates the related `Account` records based on changes to the `Opportunity` records, ensuring that the account information is kept in sync.

**Parameters**

* `opportunityList` (List\<Opportunity\>): A list of new `Opportunity` records being updated.  
* `oldMap` (Map\<Id, Opportunity\>): A map of old `Opportunity` records (before update).

**Return**

* Returns a list of `Account` records to be upserted.

---

### **Method: `updateContactInfo`**

`@TestVisible private static List<Contact> updateContactInfo(List<Opportunity> opportunityList, Map<Id, Opportunity> oldMap, Map<String, Id> accountIdByNameMap)`

**Purpose**  
Prepares and updates the related `Contact` records based on changes to the `Opportunity` records, ensuring that contact information is kept in sync.

**Parameters**

* `opportunityList` (List\<Opportunity\>): A list of new `Opportunity` records being updated.  
* `oldMap` (Map\<Id, Opportunity\>): A map of old `Opportunity` records (before update).  
* `accountIdByNameMap` (Map\<String, Id\>): A map of `Account` names to IDs.

**Return**

* Returns a list of `Contact` records to be upserted.

---

### **Method: `prepareRelatedAccount`**

`@TestVisible private static List<Account> prepareRelatedAccount(List<Opportunity> opportunityList)`

**Purpose**  
Prepares a list of `Account` records to be created based on the related `Account` names provided in the `Opportunity` records.

**Parameters**

* `opportunityList` (List\<Opportunity\>): A list of `Opportunity` records for which related `Account` records will be prepared.

**Return**

* Returns a list of `Account` records to be created.

---

### **Method: `prepareRelatedContact`**

**`@TestVisible private static List<Contact> prepareRelatedContact(List<Opportunity> opportunityList)`**

**Purpose**  
**Prepares a list of `Contact` records to be created based on the related `Contact` names provided in the `Opportunity` records.**

**Parameters**

* **`opportunityList` (List\<Opportunity\>): A list of `Opportunity` records for which related `Contact` records will be prepared.**

**Return**

* **Returns a list of `Contact` records to be created.**

* Returns a list of `Contact` records to be created.

---

### **Method: `prepareOpportunity`**

`@TestVisible private static List<Opportunity> prepareOpportunity(List<Opportunity> opportunityList, String stageName, Date closeDate)`

**Purpose**  
Prepares and updates the `Opportunity` records, setting the stage name and close date, and linking them to the appropriate `Account` and `Contact` records.

**Parameters**

* `opportunityList` (List\<Opportunity\>): A list of `Opportunity` records to update.  
* `stageName` (String): The stage name to assign to the `Opportunity` records.  
* `closeDate` (Date): The new close date to set for the `Opportunity` records.

**Return**

* Returns the updated `Opportunity` records.

