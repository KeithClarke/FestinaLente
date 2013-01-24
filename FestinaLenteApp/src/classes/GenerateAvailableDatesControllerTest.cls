@isTest
private class GenerateAvailableDatesControllerTest {

    private class Fixture {
    
        Class__c clazz;
        AvailableDate__c ad;
        
        Fixture() {
        
            clazz = new Class__c(DayOfWeek__c = 'Friday');
            insert clazz;
            
            // Friday
            ad = new AvailableDate__c(Class__c = clazz.Id, Date__c = Date.newInstance(2013, 1, 18));
            insert ad;
        }
    }

    @isTest
    static void saveAndCancel() {
    
        Fixture f = new Fixture();
        
        ApexPages.currentPage().getParameters().put('classId', f.clazz.Id);
    
        GenerateAvailableDatesController c = new GenerateAvailableDatesController();
        
        // Thursday
        c.range.From__c = Date.newInstance(2013, 1, 10);
        // Saturday
        c.range.To__c = Date.newInstance(2013, 1, 26);
        
        System.assertEquals(f.clazz.Id, c.generate().getUrl().substring(1));
        
        // Fridays
        Date[] expecteds = new Date[] {
                Date.newInstance(2013, 1, 11),
                Date.newInstance(2013, 1, 18),
                Date.newInstance(2013, 1, 25)
                };
        
        List<Date> actuals = new List<Date>();   
        for (AvailableDate__c actual : [
                select Date__c
                from AvailableDate__c
                where Class__c = :f.clazz.Id
                order by Date__c
                ]) {
            actuals.add(actual.Date__c);
        }
        System.assertEquals(expecteds, actuals);
        
        System.assertEquals(f.clazz.Id, c.cancel().getUrl().substring(1));
    }
}