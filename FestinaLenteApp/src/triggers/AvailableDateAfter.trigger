trigger AvailableDateAfter on AvailableDate__c (after insert, after update) {

    //
    // Check that day of week matches parent day of week and that date isn't already available
    //

    Set<Id> classIds = new Set<Id>();
    for (AvailableDate__c ad : Trigger.new) {
        classIds.add(ad.Class__c);
    }
    
    Map<Id, Class__c> classes = new Map<Id, Class__c>([
            select Id, DayOfWeek__c, (select Id, Name, Date__c, DayOfWeek__c from AvailableDates__r)
            from Class__c
            where Id in :classIds
            // A null here means the class is not tied to a specific day
            and DayOfWeekNumber__c != null
            ]);
            
    for (AvailableDate__c ad : Trigger.new) {
    
        Class__c clazz = classes.get(ad.Class__c);
        if (clazz != null) {
	        String requiredDayOfWeek = clazz.DayOfWeek__c;       
	        if (ad.DayOfWeek__c != requiredDayOfWeek) {
	            ad.Date__c.addError('This date is a ' + ad.DayOfWeek__c + '; enter a date that is a ' + requiredDayOfWeek + ' (as defined by the parent Class)');
	        }
	
	        for (AvailableDate__c child : clazz.AvailableDates__r) {
	            if (ad.Date__c == child.Date__c && ad.Id != child.Id) {
	                ad.Date__c.addError('Available Date ' + child.Name + ' already defines this date as available');
	            }
	        }
        }
    }
}