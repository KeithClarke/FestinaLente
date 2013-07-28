@isTest
private class ClassCopyAllTest {

    @isTest
    static void basic() {
        
        Contact[] contacts = new Contact[] {
                new Contact(LastName = 'Last1'),
                new Contact(LastName = 'Last2'),
                new Contact(LastName = 'Last3')
                };
        insert contacts;
        
        Class__c weekly = new Class__c(DayOfWeek__c = 'Wednesday');
        Class__c consecutive = new Class__c(DayOfWeek__c = null);
        insert new Class__c[] {weekly, consecutive};
        
        List<AvailableDate__c> ads = new List<AvailableDate__c>();
        ads.add(new AvailableDate__c(Class__c = weekly.Id, Date__c = Date.newInstance(2013, 1, 2)));
        ads.add(new AvailableDate__c(Class__c = weekly.Id, Date__c = Date.newInstance(2013, 1, 9)));
        ads.add(new AvailableDate__c(Class__c = weekly.Id, Date__c = Date.newInstance(2013, 1, 16)));
        ads.add(new AvailableDate__c(Class__c = weekly.Id, Date__c = Date.newInstance(2013, 1, 23)));
        ads.add(new AvailableDate__c(Class__c = consecutive.Id, Date__c = Date.newInstance(2013, 1, 1)));
        ads.add(new AvailableDate__c(Class__c = consecutive.Id, Date__c = Date.newInstance(2013, 1, 2)));
        ads.add(new AvailableDate__c(Class__c = consecutive.Id, Date__c = Date.newInstance(2013, 1, 3)));
        insert ads;
        
        // This will cause a default BookedDate to be created for every AvailableDate
        Booking__c[] bookings = new Booking__c[] {
                new Booking__c(Class__c = weekly.Id, Client__c = contacts[0].Id),
                new Booking__c(Class__c = weekly.Id, Client__c = contacts[1].Id),
                new Booking__c(Class__c = consecutive.Id, Client__c = contacts[2].Id)
                };
        insert bookings;
        
        Set<Id> classIds = new Set<Id>();
        classIds.add(weekly.Id);
        classIds.add(consecutive.Id);
        
        Set<Date> newDates = new Set<Date>();
        for (AvailableDate__c ad : ads) {
            newDates.add(ad.Date__c.addDays(26 * 7));
        }
        
        // Do the copy
        List<Id> newClassIds = new ClassCopyAll(classIds, newDates).copy();
        
        List<Class__c> classesCopy = [
                select
                        DayOfWeek__c,
                        (select Id, Date__c from AvailableDates__r order by Date__c),
                        (select Id from Bookings__r order by Name)
                from Class__c
                where Id in :newClassIds
                order by Name
                ];
        System.assertEquals(2, classesCopy.size());
        
        Class__c weeklyCopy = classesCopy[0];
        System.assertEquals('Wednesday', weeklyCopy.DayOfWeek__c);
        System.assertEquals(4, weeklyCopy.AvailableDates__r.size());
        System.assertEquals(2, weeklyCopy.Bookings__r.size());
        
        Class__c consecutiveCopy = classesCopy[1];
        System.assertEquals(null, consecutiveCopy.DayOfWeek__c);
        System.assertEquals(3, consecutiveCopy.AvailableDates__r.size());
        System.assertEquals(1, consecutiveCopy.Bookings__r.size());
        
        Set<Date> actualDates = new Set<Date>();
        for (Class__c c: classesCopy) {
	        for (AvailableDate__c ad : c.AvailableDates__r) {
	            actualDates.add(ad.Date__c);
	        }
        }
        System.assertEquals(newDates, actualDates);

        BookedDate__c[] bdsCopy = [
                select Id, AvailableDate__r.Date__c
                from BookedDate__c
                where Booking__r.Class__r.Id in :newClassIds
        ];
        System.assertEquals(2 * 4 + 3, bdsCopy.size());
    }
    
    // TODO tests for weekly patterns
}