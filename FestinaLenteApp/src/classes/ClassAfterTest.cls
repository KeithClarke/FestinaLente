@isTest
private class ClassAfterTest {

    private class Fixture {
    
        Class__c clazz;
        AvailableDate__c ad;

        Fixture() {
            
            clazz = new Class__c(DayOfWeek__c = 'Monday');
            insert clazz;
            
            // Monday
            ad = new AvailableDate__c(Class__c = clazz.Id, Date__c = Date.newInstance(2013, 2, 18));
            insert ad;
        }
    }
    
    @isTest
    static void changeDayOfWeek() {
    
        Fixture f = new Fixture();
        f.clazz.DayOfWeek__c = 'Thursday';
        update f.clazz;
        
        System.assertEquals('Thursday', [select DayOfWeek__c from AvailableDate__c where Id =:f.ad.Id].DayOfWeek__c);
    }
}