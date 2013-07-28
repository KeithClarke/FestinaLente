public class ClassCopyAll {
	
	private enum Week {
		Odd,
		Even,
		Every,
		None
	}
    
    private Set<Id> classIds;
    private List<Date> includedDates;
    
    private List<Class__c> classes;
    private List<Booking__c> bookings;
    private Map<Id, List<Date>> classIdToAvailableDates;
    private Map<Id, List<Date>> bookingIdToBookedDates;
    private Map<Id, Class__c> bookingIdToClass;
    
    public ClassCopyAll(Set<Id> classIds, Set<Date> includedDates) {
    	
        this.classIds = classIds;
        this.includedDates = new List<date>(includedDates);
        this.includedDates.sort();
    }

    public List<Id> copy() {
    	
    	read();
    	return toIds(write());
    }
    
    private List<Id> toIds(List<SObject> sobs) {
    	
    	List<Id> ids = new List<Id>();
    	for (SObject sob : sobs) {
    		ids.add(sob.Id);
    	}
    	return ids;
    }
    
    private List<Class__c> write() {

        // Copy classes
        Map<Id, Id> m = new Map<Id, Id>();
    	List<Class__c> newClasses = classes.deepClone();
    	insert newClasses;
    	for (Integer i = 0; i < classes.size(); i++) {
    		m.put(classes[i].Id, newClasses[i].Id);
    	}

        // Copy bookings
    	List<Booking__c> newBookings = bookings.deepClone();
    	for (Booking__c booking : newBookings) {
    		// Fix parent object reference
    		booking.Class__c = m.get(booking.Class__c);
    	}
    	insert newBookings;
        
        // Group included dates by day
        Map<Integer, List<Date>> dayToDates = new Map<Integer, List<Date>>();
        for (Integer day = 0; day < 7; day++) {
        	dayToDates.put(day, new List<Date>());
        }
    	for (Date d : includedDates) {
    	    dayToDates.get(Dates.dayOfWeek(d)).add(d);
    	}

        // Generate new available dates
        Map<Id, List<AvailableDate__c>> classAds = new Map<Id, List<AvailableDate__c>>();
        List<AvailableDate__c> newAds = new List<AvailableDate__c>();
        for (Integer i = 0; i < newClasses.size(); i++) {
        	Class__c c = newClasses.get(i);
        	
        	List<AvailableDate__c> l = new List<AvailableDate__c>();
        	classAds.put(c.Id, l);
        	
        	// DayOfWeekNumber is a formula field so take from the existing class
        	Decimal dayOfWeekNumber = classes.get(i).DayOfWeekNumber__c;
        	if (dayOfWeekNumber != null) {
        		// Weekly
        		for (Date d : dayToDates.get(dayOfWeekNumber.intValue())) {
        			AvailableDate__c ad = new AvailableDate__c(Class__c = c.Id, Date__c = d);
                    newAds.add(ad);
                    l.add(ad);
        		}
        	} else {
        		// Consecutive days
        		Integer days = classIdToAvailableDates.get(classes.get(i).Id).size();
        		for (Integer j = 0; j < Math.min(days, includedDates.size()); j++) {
        			AvailableDate__c ad = new AvailableDate__c(Class__c = c.Id, Date__c = includedDates.get(j));
                    newAds.add(ad);
                    l.add(ad);
        		}
        	}
        }
        insert newAds;
        
        // Generate new booked dates
        List<BookedDate__c> newBds = new List<BookedDate__c>();
        for (Integer i = 0; i < newBookings.size(); i++) {
        	
        	Booking__c booking = bookings.get(i);
        	Class__c clazz = booking.Class__r;
        	Decimal dayOfWeekNumber = clazz.DayOfWeekNumber__c;
        	if (dayOfWeekNumber != null) {
        		// Weekly
        	
	        	// Get the week pattern from the existing booking
	        	Week w = bestGuessWeeklyPattern(booking);

                // Book according to the pattern
	            Booking__c b = newBookings.get(i);
	        	for (AvailableDate__c ad : classAds.get(b.Class__c)) {
	        		if (book(w, ad.Date__c)) {
	        		    newBds.add(new BookedDate__c(Booking__c = b.Id, AvailableDate__c = ad.Id));
	        		}
	        	}
        	} else {
        		// Consecutive days
        		
        		// See if an existing booking
        		Integer booked = bookingIdToBookedDates.get(booking.Id).size();
        		
        		// If any days booked before, book all this time
        		if (booked > 0) {
	        		Booking__c b = newBookings.get(i);
	                for (AvailableDate__c ad : classAds.get(b.Class__c)) {
	                    newBds.add(new BookedDate__c(Booking__c = b.Id, AvailableDate__c = ad.Id));
	                }
        		}
        	}
        }
        insert newBds;
        
        return newClasses;
    }
    
    private Boolean book(Week w, Date d) {
    	
    	if (w == Week.Every) {
    		return true;
    	} else if (w == Week.None) {
    		return false;
    	}
    	
    	if (Dates.isEvenWeekNumber(d)) {
    		return w == Week.Even;
    	} else {
    		return w == Week.Odd;
    	}
    }
    
    private Week bestGuessWeeklyPattern(Booking__c b) {
    	
    	List<Date> bookedDates = bookingIdToBookedDates.get(b.Id);
    	if (bookedDates.size() == 0) {
    		return Week.None;
    	}
    	
    	Boolean isEven = false;
    	Boolean isOdd = false;
    	for (Date d : bookedDates) {
            if (Dates.isEvenWeekNumber(d)) {
            	isEven = true;
            } else {
            	isOdd = true;
            }
            if (isOdd && isEven) {
            	return Week.Every;
            }
        }

    	if (isEven) {
    		return Week.Even;
    	} else if (isOdd) {
    		return Week.Odd;
    	} else {
    	    return Week.None;
    	}
    }
    
    private void read() {
    	
        classes = [
                select
                        Id,
                        Name,
                        AgeGroup__c,
                        Coach__c,
                        DayOfWeek__c,
                        Detail__c,
                        Length__c,
                        Level__c,
                        Notes__c,
                        Price__c,
                        Time__c,
                        Type__c,
                        DayOfWeekNumber__c,
                        (select Id, Name, Date__c, Class__c from AvailableDates__r order by Date__c),
                        (select Id, Name, Client__c, Class__c, Notes__c, Class__r.DayOfWeekNumber__c from Bookings__r order by Name)
                from Class__c
                where Id in :classIds
                order by Name
                ];
        
        classIdToAvailableDates = new Map<Id, List<Date>>();
        for (Class__c c : classes) {
            classIdToAvailableDates.put(c.Id, new List<Date>());
            for (AvailableDate__c ad : c.AvailableDates__r) {
                classIdToAvailableDates.get(ad.Class__c).add(ad.Date__c);
            }
        }
        
        bookingIdToBookedDates = new Map<Id, List<Date>>();
        bookings = new List<Booking__c>();    
        for (Class__c c : classes) {
            for (Booking__c b : c.Bookings__r) {
                bookings.add(b);
                bookingIdToBookedDates.put(b.Id, new List<Date>());
            }
        }
        for (BookedDate__c bd : [
                select Booking__c, AvailableDate__r.Date__c
                from BookedDate__c
                where Booking__c in :bookingIdToBookedDates.keySet()
                order by AvailableDate__r.Date__c
                ]) {
        	bookingIdToBookedDates.get(bd.Booking__c).add(bd.AvailableDate__r.Date__c);
        }
    }
}