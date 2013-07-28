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
}