@isTest
private class ClassDeepCloneControllerTest {

    private class Fixture {

        Class__c clazz;
        AvailableDate__c[] ads;
        
        Fixture(String dayOfWeek) {

            clazz = new Class__c(DayOfWeek__c = dayOfWeek);
            insert clazz;

            // These are Mondays
            ads = new AvailableDate__c[] {
                    new AvailableDate__c(Class__c = clazz.Id, Date__c = Date.newInstance(2013, 2, 18)),
                    new AvailableDate__c(Class__c = clazz.Id, Date__c = Date.newInstance(2013, 2, 25))
                    };
            insert ads;
        }
    }
    
    @isTest
    static void saveChangeDay() {
        save('Monday', 'Wednesday');
    }
    
    @isTest
    static void saveSameDay() {
        save('Monday', 'Monday');
    }
    
    @isTest
    static void saveToAny() {
    	// Dates are not changed
        save('Monday', 'Any');
    }
    
    @isTest
    static void saveFromAny() {
        // Dates are changed
        save('Any', 'Wednesday');
    }
    
    private static void save(String oldDayOfWeek, String newDayOfWeek) {
    
        Fixture f = new Fixture(oldDayOfWeek);
        
        ClassDeepCloneController c = new ClassDeepCloneController(new ApexPages.StandardController(f.clazz));
        c.clazz.DayOfWeek__c = newDayOfWeek;
        
        // Id follows the slash
        Id newClazzId = (Id) c.save().getUrl().substring(1);
        AvailableDate__c[] actuals = [
                select DayOfWeek__c
                from AvailableDate__c
                where Class__c = :newClazzId
                ];
        System.assertEquals(f.ads.size(), actuals.size());
        for (AvailableDate__c actual : actuals) {
        	if (newDayOfWeek != 'Any') {
                System.assertEquals(newDayOfWeek, actual.DayOfWeek__c);
        	}
        }
    }
    
    @isTest
    static void cancel() {
    
        Fixture f = new Fixture('Monday');
        
        ClassDeepCloneController c = new ClassDeepCloneController(new ApexPages.StandardController(f.clazz));
        
        Id cancelId = (Id) c.cancel().getUrl().substring(1);
        System.assertEquals(f.clazz.Id, cancelId);
    }
}