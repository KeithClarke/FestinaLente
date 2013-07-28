@isTest
private class DatesTest {

    @isTest
    static void test() {
    
        System.assertEquals('Monday', Dates.dayIntegerToString(1));
        System.assertEquals(4, Dates.dayStringToInteger('Thursday'));
        System.assertEquals(1, Dates.dayOfWeek(Date.newInstance(2013, 1, 21)));
        
        System.assertEquals(null, Dates.dayIntegerToString(null));
        System.assertEquals(null, Dates.dayStringToInteger(null));
        System.assertEquals(null, Dates.dayOfWeek(null));
    }
    
    @isTest
    static void precedingMonday() {
        
        System.assertEquals(Date.newInstance(2013, 7, 15), Dates.precedingMonday(Date.newInstance(2013, 7, 20)));
        System.assertEquals(Date.newInstance(2013, 7, 15), Dates.precedingMonday(Date.newInstance(2013, 7, 21)));
        
        System.assertEquals(Date.newInstance(2013, 7, 22), Dates.precedingMonday(Date.newInstance(2013, 7, 22)));
        System.assertEquals(Date.newInstance(2013, 7, 22), Dates.precedingMonday(Date.newInstance(2013, 7, 23)));
        System.assertEquals(Date.newInstance(2013, 7, 22), Dates.precedingMonday(Date.newInstance(2013, 7, 24)));
        System.assertEquals(Date.newInstance(2013, 7, 22), Dates.precedingMonday(Date.newInstance(2013, 7, 25)));
        System.assertEquals(Date.newInstance(2013, 7, 22), Dates.precedingMonday(Date.newInstance(2013, 7, 26)));
        System.assertEquals(Date.newInstance(2013, 7, 22), Dates.precedingMonday(Date.newInstance(2013, 7, 27)));
        System.assertEquals(Date.newInstance(2013, 7, 22), Dates.precedingMonday(Date.newInstance(2013, 7, 28)));
        
        System.assertEquals(Date.newInstance(2013, 7, 29), Dates.precedingMonday(Date.newInstance(2013, 7, 29)));
        System.assertEquals(Date.newInstance(2013, 7, 29), Dates.precedingMonday(Date.newInstance(2013, 7, 30)));
        
        System.assertEquals(null, Dates.precedingMonday(null));
    }
    
    @isTest
    static void weekNumber() {
        
        Class__c c = new Class__c();
        insert c;
        
        // Most of this test data taken from http://boards.developerforce.com/t5/Formulas-Validation-Rules/ISO-Week-Calculation/td-p/174749
        Integer[] expecteds = new Integer[] {
                52,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                2,
                2,
                
                37,
                52,
                null,
                
                1,
                1,
                53,
                52,
                1,
                1,
                1
                };
        Date[] ds = new Date[]{};
        for (Date d = Date.newInstance(2012, 12, 30); d < Date.newInstance(2013, 1, 9); d = d.addDays(1)) {
            ds.add(d);
        }
        
        ds.add(Date.newInstance(2013, 9, 13));
        ds.add(Date.newInstance(2013, 12, 25));
        ds.add(null);
        
        ds.add(Date.newInstance(2014, 1, 1));
        ds.add(Date.newInstance(2015, 1, 1));
        ds.add(Date.newInstance(2016, 1, 1));
        ds.add(Date.newInstance(2017, 1, 1));
        ds.add(Date.newInstance(2018, 1, 1));
        ds.add(Date.newInstance(2019, 1, 1));
        ds.add(Date.newInstance(2020, 1, 1));
        
        AvailableDate__c[] ads = new AvailableDate__c[]{};
        for (Date d : ds) {
            ads.add(new AvailableDate__c(Class__c = c.Id, Date__c = d));
        }
        insert ads;
        AvailableDate__c[] actuals = [select WeekNumber__c from AvailableDate__c where Class__c = :c.Id order by Name];
        
        for (Integer i = 0; i < ds.size(); i++) {
            // Check Apex code method
            System.assertEquals(expecteds[i], Dates.weekNumber(ds[i]), 'index=' + i);
            // Check formula field
            System.assertEquals(expecteds[i], actuals[i].WeekNumber__c, 'index=' + i);
        }
    }
    
    @isTest
    static void isEvenWeekNumber() {
    	
    	System.assertEquals(false, Dates.isEvenWeekNumber(Date.newInstance(2014, 1, 1)));
    	System.assertEquals(true, Dates.isEvenWeekNumber(Date.newInstance(2014, 1, 8)));
    	System.assertEquals(null, Dates.isEvenWeekNumber(null));
    }
}