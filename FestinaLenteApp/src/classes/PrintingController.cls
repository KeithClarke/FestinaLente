public with sharing class PrintingController {

    public Printing__c printing {
        get {
            if (printing == null) {
                // Start on next Monday
                Date defaultFrom = Date.today().addDays(-Dates.dayOfWeek(Date.today()) + 1);
                printing = new Printing__c(From__c = defaultFrom);
            }
            return printing;
        }
        private set;
    }
}