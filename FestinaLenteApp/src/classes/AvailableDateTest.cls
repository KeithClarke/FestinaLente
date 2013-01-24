@isTest
private class AvailableDateTest {

    private class Fixture {
    
        Class__c clazz;
        AvailableDate__c ad;
        
        Fixture() {
        
            clazz = new Class__c(DayOfWeek__c = 'Friday');
            insert clazz;
  
            // Friday
            ad = new AvailableDate__c(Class__c = clazz.Id, Date__c = Date.newInstance(2013, 1, 11));
            insert ad;
        }
    }
    
    @isTest
    static void formulaFields() {
    
        Fixture f = new Fixture();
        
        AvailableDate__c actual = [
                select DayOfWeek__c, DayOfWeekNumber__c, WeekNumber__c
                from AvailableDate__c
                where Id = :f.ad.Id
                ];
        System.assertEquals('Friday', actual.DayOfWeek__c);
        System.assertEquals(5, actual.DayOfWeekNumber__c);
        System.assertEquals(3, actual.WeekNumber__c);
    }
}