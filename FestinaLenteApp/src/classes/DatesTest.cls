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
}