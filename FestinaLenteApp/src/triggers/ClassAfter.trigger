trigger ClassAfter on Class__c (after update) {

    //
    // Update Available Dates when day of week changes on class
    //

    Map<Id, Class__c> changedClasses = new Map<Id, Class__c>();
    for (Id id :Trigger.newMap.keySet()) {
        Decimal oldDayOfWeekNumber = Trigger.oldMap.get(id).DayOfWeekNumber__c;
        Decimal newDayOfWeekNumber = Trigger.newMap.get(id).DayOfWeekNumber__c;
        
        // A null here means the class is not tied to a specific day
        if  (newDayOfWeekNumber != null) {
	        if (newDayOfWeekNumber != oldDayOfWeekNumber) {
	            changedClasses.put(id, Trigger.newMap.get(id));
	        }
        }
    }
    
    if (changedClasses.size() > 0) {
	    List<AvailableDate__c> ads = [
	            select Class__c, Date__c, DayOfWeekNumber__c
	            from AvailableDate__c
	            where Class__c in :changedClasses.keySet()
	            ];
	            
	    List<AvailableDate__c> updates = new List<AvailableDate__c> ();
	    for (AvailableDate__c ad :ads) {
	        Decimal classDayOfWeekNumber = changedClasses.get(ad.Class__c).DayOfWeekNumber__c;
	        // Similar logic in ClassDeepCloneController
	        if (ad.DayOfWeekNumber__c != classDayOfWeekNumber) {
	            ad.Date__c = ad.Date__c.addDays(classDayOfWeekNumber.intValue() - ad.DayOfWeekNumber__c.intValue());
	            updates.add(ad);
	        }
	    }
	    if (updates.size() > 0) {
	        update updates;
	    }
    }
}