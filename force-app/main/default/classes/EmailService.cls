public with sharing class EmailService {
    public List<Messaging.SendEmailResult> sendOpportunityEmailToOwner(List<Opportunity> opportunityList, Id templateId) {
        List<Messaging.SingleEmailMessage> preparedEmails = prepareEmail(opportunityList, templateId);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(preparedEmails);
        return results;
    } 

    private static List<Messaging.SingleEmailMessage> prepareEmail(List<Opportunity> opportunityList, Id templateId) {
        List<Messaging.SingleEmailMessage> emailsToPrepare = new List<Messaging.SingleEmailMessage>();
        List<String> recepientEmails = new List<String>();
        Map<Id, List<Id>> accountOppMap = new Map<Id, List<Id>>();
        Map<String, Id> contactNameByIdMap = new Map<String, Id>();

        List<Opportunity> oppsInAccts = [SELECT AccountId, Owner.Email, Related_Contact_Last_Name__c FROM Opportunity WHERE Id IN :opportunityList];

        for (Opportunity opp : oppsInAccts) {
            if (!accountOppMap.containsKey(opp.AccountId)) {
                accountOppMap.put(opp.AccountId, new List<Id> {opp.Id});
            }
            recepientEmails.add(opp.Owner.Email);
        }

        for (Contact con : [
            SELECT Id, LastName, AccountId FROM Contact WHERE AccountId IN :accountOppMap.keySet()
        ]) {
            if(!contactNameByIdMap.containsKey(con.LastName)) {
                contactNameByIdMap.put(con.LastName, con.Id);
            }
        }

        for(Opportunity opp : oppsInAccts) {
            Messaging.SingleEmailMessage emailToPrepare = new Messaging.SingleEmailMessage();
            emailToPrepare.setToAddresses(recepientEmails);
            emailToPrepare.setTemplateId(templateId);
            emailToPrepare.setTargetObjectId(contactNameByIdMap.get(opp.Related_Contact_Last_Name__c));
            emailToPrepare.setWhatId(opp.Id);
            emailToPrepare.setTreatTargetObjectAsRecipient(false);
            emailToPrepare.setSaveAsActivity(false);
            emailsToPrepare.add(emailToPrepare);
        }
        
        return emailsToPrepare;
    }

    public static List<Messaging.SendEmailResult> sendEmailWithPdf(String recepientEmail, Blob pdfBlob, String quoteName) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String> {recepientEmail});
        email.setSubject('PDF Attachment Email for ' + quoteName + ' Quote');
        email.setPlainTextBody('Open the attached PDF');
        
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName(quoteName + '.pdf');
        attachment.setBody(pdfBlob);
        attachment.setContentType('application/pdf');

        email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
        emails.add(email);

        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

        return results;
    }

    public static Blob getPDFContent(Id recordId, String visualforcePageName) {
        PageReference quotePage = new PageReference('/apex/' + visualforcePageName);
        quotePage.getParameters().put('Id', recordId);
        
        Blob quotePdf = quotePage.getContentAsPDF();
        
        return quotePdf;
    }

    @future
    public static void sendEmailWithSummary(String body) {
        Messaging.SingleEmailMessage email = prepareEmailWithSummary(body);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }

    private static Messaging.SingleEmailMessage prepareEmailWithSummary(String body) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String> {'kasyanchukmaks22@gmail.com'});
        email.setSubject('Opportunities Summary');
        email.setPlainTextBody(body);
        email.setSaveAsActivity(false);

        return email;
    }
}