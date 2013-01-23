public with sharing class EditBookedDatesController {

    private Id bookingId {
        get {
            if (bookingId == null) {
                bookingId = ApexPages.currentPage().getParameters().get('bookingId');
            }
            return bookingId;
        }
        private set;
    }
    
    private String retURL {        
        get {
            return ApexPages.currentPage().getParameters().get('retURL');
        }
    }
    
    public Booking__c booking {
        get {
            if (booking == null) {
                booking = [
                        select Id, Name, Client__c, Class__c, Notes__c
                        from Booking__c
                        where Id = :bookingId
                        ];
            }
            return booking;
        }
        private set;
    }
    
    public List<SelectableAvailableDate> availables {
        get {
            if (availables == null) {
            
                Map<Id, Id> bookings = new Map<Id, Id>();
                for (BookedDate__c bd : [
                        select Id, AvailableDate__c
                        from BookedDate__c
                        where Booking__c = :bookingId]) {
                    bookings.put(bd.AvailableDate__c, bd.Id);
                }
                
                availables = new List<SelectableAvailableDate>();
                for (AvailableDate__c ad : [
                        select Id, Name, Date__c, DayOfWeek__c, WeekNumber__c
                        from AvailableDate__c
                        where Class__c in (select Class__c from Booking__c where Id = :bookingId)
                        order by Date__c
                        ]) {
                    availables.add(new SelectableAvailableDate(ad, bookings.get(ad.Id)));
                }
            }
            return availables;
        }
        private set;
    }
    
    public PageReference save() {
    
        // Work out changes needed
        List<BookedDate__c> inserts = new List<BookedDate__c>();
        List<BookedDate__c> deletes = new List<BookedDate__c>();
        for (SelectableAvailableDate available : availables) {
            if (available.selected && available.bookedDateId == null) {
                inserts.add(new BookedDate__c(AvailableDate__c = available.sob.Id, Booking__c = bookingId));
            }
            if (!available.selected && available.bookedDateId != null) {
                deletes.add(new BookedDate__c(Id = available.bookedDateId));
            }
        }
        
        if (inserts.size() > 0) {
            insert inserts;
        }
        if (deletes.size() > 0) {
            delete deletes;
        }
        
        return new PageReference(retURL != null ? retURL : '/' + bookingId);
    }
    
    public PageReference cancel() {
        return new PageReference(retURL != null ? retURL : '/' + bookingId);
    }
}