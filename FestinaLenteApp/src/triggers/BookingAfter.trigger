trigger BookingAfter on Booking__c (after insert, after update, after delete) {
    
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
    
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) {
    
        //
        // When a client has a booking made (or deleted), automatically change the status, waiting types and active types
        //
        
        Set<Id> clientIds = new Set<Id>();
        for (Booking__c b : Trigger.isDelete ? Trigger.old : Trigger.new) {
            if (b.Client__c != null) {
                clientIds.add(b.Client__c);
            }
        }
        
        Map<Id, Set<String>> clientToClassType = new Map<Id, Set<String>>();
        if (Trigger.isDelete) {
        	// Consider all deletes
        	for (Id clientId : clientIds) {
        		clientToClassType.put(clientId, new Set<String>());
        	}
        } else {
        	// Only consider bookings that vhave dates (as Bookins are created without dates)
	        for (Booking__c b : [
	                select Client__c, Class__r.Type__c
	                from Booking__c
	                where Client__c in :clientIds
	                and LatestBookedDate__c != null
	                and LatestBookedDate__c >= TODAY
	                and Class__r.Type__c != null
	                ]) {
	        	Set<String> s = clientToClassType.get(b.Client__c);
	        	if (s == null) {
	        		s = new Set<String>();
	        		clientToClassType.put(b.Client__c, s);
	        	}
	        	s.add(b.Class__r.Type__c);
	        }
        }
        
        if (clientToClassType.size() > 0) {
	        Map<Id, Contact> contacts = new Map<Id, Contact>([
	                select Status__c, ClassType__c, ActiveClassType__c
	                from Contact
	                where Id = :clientToClassType.keySet()
	                ]);
	        
	        List<Contact> updates = new List<Contact>();
	        for (Id clientId : clientToClassType.keySet()) {
	        	Contact c = contacts.get(clientId);
	        	
	        	// Similar logic in ContactStatusBatchable
	        	
	        	Set<String> currentActiveClassTypes = c.ActiveClassType__c != null ? new Set<String>(c.ActiveClassType__c.split(';')) : new Set<String>();
	        	Set<String> currentWaitingClassTypes = c.ClassType__c != null ? new Set<String>(c.ClassType__c.split(';')) : new Set<String>();
	        	String currentStatus = c.Status__c;
	        	
	        	Set<String> newActiveClassTypes = clientToClassType.get(clientId);
	        	Set<String> newWaitingClassTypes = new Set<String>(currentWaitingClassTypes);
	        	newWaitingClassTypes.removeAll(newActiveClassTypes);
	        	String newStatus = newActiveClassTypes.size() > 0 ? 'Active' : (newWaitingClassTypes.size() > 0 ? 'Waiting' : 'Inactive');
	        	
	        	if (currentStatus != newStatus || currentActiveClassTypes != newActiveClassTypes || currentWaitingClassTypes != newWaitingClassTypes) {
		        	updates.add(new Contact(
		        	       Id = clientId,
		        	       Status__c = newStatus,
		        	       ClassType__c = Strings.join(newWaitingClassTypes, ';'),
		        	       ActiveClassType__c = Strings.join(newActiveClassTypes, ';')
		        	       ));
	        	}
	        }
	        if (updates.size() > 0) {
	            update updates;
	        }
        }
    }
}