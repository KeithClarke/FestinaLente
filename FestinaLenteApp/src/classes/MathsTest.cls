@isTest
private class MathsTest {

    @isTest
    static void min() {
    
        Date d1 = Date.newInstance(2012, 1, 1);
        Date d2 = Date.newInstance(2012, 2, 2);
        
        System.assertEquals(null, Maths.min(null, null));
        System.assertEquals(d1, Maths.min(d1, null));
        System.assertEquals(d2, Maths.min(null, d2));
        System.assertEquals(d1, Maths.min(d1, d2));
    }
    
    @isTest
    static void max() {
        
        Date d1 = Date.newInstance(2012, 1, 1);
        Date d2 = Date.newInstance(2012, 2, 2);
        
        System.assertEquals(null, Maths.max(null, null));
        System.assertEquals(d1, Maths.max(d1, null));
        System.assertEquals(d2, Maths.max(null, d2));
        System.assertEquals(d2, Maths.max(d1, d2));
    }
}