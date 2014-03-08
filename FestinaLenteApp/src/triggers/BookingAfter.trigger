trigger BookingAfter on Booking__c (after insert, after update) {
    
    if (Trigger.isInsert) {
    
        //
        // Create a BookedDate for every AvailableDate
        //
    
        // May be multiple bookins created for one class
        Map<Id, Set<Id>> classToBookings = new Map<Id, Set<Id>>();
        for (Booking__c b : Trigger.new) {
            Set<Id> bookings = classToBookings.get(b.Class__c);
            if (bookings == null) {
                bookings = new Set<Id>();
                classToBookings.put(b.Class__c, bookings);
            }
            bookings.add(b.Id);
        }
        
        List<BookedDate__c> bds = new List<BookedDate__c>();
        for (AvailableDate__c ad : [
                select Id, Class__c
                from AvailableDate__c
                where Class__c in :classToBookings.keySet()
                ]) {
            for (Id bookingId : classToBookings.get(ad.Class__c)) {
                bds.add(new BookedDate__c(AvailableDate__c = ad.Id, Booking__c = bookingId));
            }
        }
        
        if (bds.size() > 0) {
            insert bds;
        }
    }
}