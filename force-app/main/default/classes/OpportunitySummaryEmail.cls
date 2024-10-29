public with sharing class OpportunitySummaryEmail implements Queueable {
    public class CustomEmailSendingException extends Exception{}

    private String body;

    public OpportunitySummaryEmail(String body) {
        this.body = body;
    }

    public void execute(QueueableContext QC) {
        try {
            EmailService.sendEmailWithSummary(body);
        } catch (Exception e) {
            if (e instanceof EmailException) {
                throw new CustomEmailSendingException('Error sending email summary: ' + e.getMessage() + ' Caused by: ' + e.getCause());
            }
        }
    }
}