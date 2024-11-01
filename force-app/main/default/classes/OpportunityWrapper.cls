public with sharing class OpportunityWrapper {
    public String wrapperAccountName;
    public String wrapperContactLastName;

    public OpportunityWrapper(String accountName, String contactLastName) {
        this.wrapperAccountName = accountName;
        this.wrapperContactLastName = contactLastName;
    }
}