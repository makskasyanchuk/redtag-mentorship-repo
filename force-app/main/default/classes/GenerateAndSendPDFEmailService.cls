public with sharing class GenerateAndSendPDFEmailService {
    @InvocableMethod
    public static List<Result> sendEmailWithPdfAttachment(List<Request> requests) {
        Result result = new Result();
        for (Request req : requests) {
            Blob pdfBlob = EmailService.getPDFContent(req.recordId, req.visualforcePageName);
            List<Messaging.SendEmailResult> emailMessage = EmailService.sendEmailWithPdf(req.recepientEmail, pdfBlob, req.quoteName);

            if (!emailMessage.isEmpty() && emailMessage[0].isSuccess()) {
                result.isSuccess = true;
            } else {
                result.isSuccess = false;
                result.errorMessage = emailMessage[0].getErrors()[0].getMessage();
            }
        }
        List<Result> resultsWrapper = new List<Result>{result};
        
        return resultsWrapper;
    }

    public class Request {
        @InvocableVariable(label='Record Id' required=true)
        public String recordId;
        @InvocableVariable(label='Quote Name' required=true)
        public String quoteName;
        @InvocableVariable(label='Recepient Email' required=true)
        public String recepientEmail;
        @InvocableVariable(label='Visualforce Page Name' required=true)
        public String visualforcePageName;
    }

    public class Result {
        @InvocableVariable(label='Success')
        public Boolean isSuccess;
        @InvocableVariable(Label='Error message')
        public String errorMessage;
    }
}