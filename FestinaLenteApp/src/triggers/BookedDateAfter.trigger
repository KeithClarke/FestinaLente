trigger BookedDateAfter on BookedDate__c (after insert, after update, after delete) {

    //
    // Validate: haven't found a way to filter lookups correctly yet; good to keep this logic in any case.
    //

    if (Trigger.isInsert || Trigger.isUpdate) {
        Set<Id> bookingIds = new Set<Id>();
        for (BookedDate__c bd : Trigger.new) {
            bookingIds.add(bd.Booking__c);
        }
        for (BookedDate__c bd : [
                select Id, AvailableDate__r.Class__c, AvailableDate__r.Class__r.Name, Booking__r.Class__c, Booking__r.Class__r.Name
                from BookedDate__c
                where Id in :Trigger.newMap.keySet()
                ]) {
            if (bd.AvailableDate__r.Class__c != bd.Booking__r.Class__c) {
                BookedDate__c triggerBd = Trigger.newMap.get(bd.Id);
                triggerBd.addError(''
                        + 'Booking object has parent Class "'
                        + bd.Booking__r.Class__r.Name
                        + '" but Available Date object has parent Class "'
                        + bd.AvailableDate__r.Class__r.Name
                        + '"; only objects with a common Class parent can be selected'
                        );
            }
        }
    }
    
    //
    // Uniqueness check
    //
    
    if (Trigger.isInsert || Trigger.isUpdate) {
        // The two foreign keys are combined in a formula field to simplify this logic
        Map<String, BookedDate__c> m = new Map<String, BookedDate__c>();
        for (BookedDate__c bd : Trigger.new) {
            m.put(bd.AvailableDateIdBookingId__c, bd);
        }
        for (BookedDate__c bd: [
                select Id, Name, AvailableDateIdBookingId__c, AvailableDate__r.Name, Booking__r.Name
                from BookedDate__c
                where Id not in :Trigger.newMap.keySet()
                and AvailableDateIdBookingId__c in :m.keySet()
                ]) {
            m.get(bd.AvailableDateIdBookingId__c).addError(''
                    + 'Booking "'
                    + bd.Booking__r.Name
                    + '" and Available Date "'
                    + bd.AvailableDate__r.Name
                    + '" already selected in Booked Date "'
                    + bd.Name
                    + '"; the pair can only be selected once'
                    );
        }
    }
    
    //
    // Update aggregate information on Booking
    //

    // Find bookings affected
    Set<Id> bookingIds = new Set<Id>();
    for (BookedDate__c bd : Trigger.isDelete ? Trigger.old : Trigger.new) {
        bookingIds.add(bd.Booking__c);
    }
    
    // Update booking according to new dates
    List<Booking__c> bs = [
            select Id, (select Date__c from BookedDates__r)
            from Booking__c
            where Id in :bookingIds
            ];

    for (Booking__c b : bs) {
        
        b.AvailableDatesBooked__c = b.BookedDates__r.size();
        
        b.EarliestBookedDate__c = null;
        b.LatestBookedDate__c = null;
        for (BookedDate__c bd : b.BookedDates__r) {
            if (bd.Date__c != null) {
                if (b.EarliestBookedDate__c == null || bd.Date__c < b.EarliestBookedDate__c) {
                    b.EarliestBookedDate__c = bd.Date__c;
                }
                if (b.LatestBookedDate__c == null || bd.Date__c > b.LatestBookedDate__c) {
                    b.LatestBookedDate__c = bd.Date__c;
                }
            }
        }
    }
    
    update bs;
}