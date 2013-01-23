@isTest
private class TTest {

    @isTest
    static void test() {
    
        T t1 = new T(480, '8 am');
        T t2 = new T(585, '9:45 am');
        
        System.assertEquals(1, t1.compareTo(t2));
        System.assertEquals(-1, t2.compareTo(t1));
        
        System.assertEquals(0, t1.compareTo(t1));
        System.assertEquals(0, t2.compareTo(t2));
    }
}