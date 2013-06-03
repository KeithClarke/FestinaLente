@isTest
private class StringsTest {

    @isTest
    static void join() {
    	
    	System.assertEquals('abc;def;ghi', Strings.join(new List<String> {'abc', 'def', 'ghi'}, ';'));
    	System.assertEquals('abc, def, ghi', Strings.join(new Set<String> {'ghi', 'abc', 'def'}, ', '));
    }
}