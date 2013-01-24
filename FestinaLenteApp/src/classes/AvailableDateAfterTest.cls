@isTest
private class AvailableDateAfterTest {

    private class Fixture {
    
        Class__c clazz;
        AvailableDate__c ad1;
        AvailableDate__c ad2;

        Fixture() {
            
            clazz = new Class__c(DayOfWeek__c = 'Monday');
            insert clazz;
            
            // Monday
            ad1 = new AvailableDate__c(Class__c = clazz.Id, Date__c = Date.newInstance(2013, 2, 18));
            ad2 = new AvailableDate__c(Class__c = clazz.Id, Date__c = Date.newInstance(2013, 2, 25));
            insert new AvailableDate__c[] {ad1, ad2};
        }
    }
    
    @isTest
    static void okChange() {
    
        Fixture f = new Fixture();
        f.ad1.Date__c = Date.newInstance(2013, 2, 11);
        update f.ad1;
    }
    
    @isTest
    static void wrongDayOfWeekChange() {
    
        Fixture f = new Fixture();
        f.ad1.Date__c = Date.newInstance(2013, 2, 20);
        try {
            update f.ad1;
            System.assert(false, 'exception expected');
        } catch (Exception e) {
            System.debug('>>> message=' + e.getMessage());
        }
    }
    
    @isTest
    static void dateAlreadyDefinedChange() {
    
        Fixture f = new Fixture();
        f.ad1.Date__c = f.ad2.Date__c;
        try {
            update f.ad1;
            System.assert(false, 'exception expected');
        } catch (Exception e) {
            System.debug('>>> message=' + e.getMessage());
        }
    }
}