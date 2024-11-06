public with sharing class OpportunitySummaryEmailQueueable implements Queueable {
    public class CustomEmailSendingException extends Exception{}

    private String body;

    public OpportunitySummaryEmailQueueable(String body) {
        this.body = body;
    }

    public void execute(QueueableContext QC) {
        EmailService.sendEmailWithSummary(body);
    }
}