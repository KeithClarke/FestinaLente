@isTest
private class ClassCopyAllControllerTest {
    
    @isTest
    static void testSingle() {
        
        Class__c clazz = new Class__c();
        insert clazz;
        
        ClassCopyAllController c = new ClassCopyAllController(new ApexPages.StandardController(clazz));
        PageReference pr = c.forwardToListController();
        System.assertEquals(clazz.Id, pr.getParameters().get('id'));
        
        ApexPages.currentPage().getParameters().put('id', pr.getParameters().get('id'));
        
        // List controller will pickup data through id parameter
        doTestList(new Class__c[] {});
    }

    @isTest
    static void testList() {
        
        Class__c clazz = new Class__c();
        insert clazz;
        
        // Normal list controller approach
        doTestList(new Class__c[] {clazz});
    }
    
    private static void doTestList(Class__c[] classes) {
        
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(classes);
        ssc.setSelected(classes);
        ClassCopyAllController c = new ClassCopyAllController(ssc);
        
        System.assertEquals(1, c.selectableClasses.size());
        System.assertEquals(true, c.selectableClasses.get(0).selected);
        System.assertEquals(1, c.getSelectedClassIds().size());
        
        System.assertEquals(true, c.consecutiveDays);
        System.assertEquals(false, c.weekly);
        System.assertEquals(0, c.weeks.size());
        
        c.range.From__c = Date.newInstance(2013, 1, 1);     // Tuesday - week 1
        c.range.To__c = Date.newInstance(2013, 1, 17);      // Thursday - week 3
        c.refreshDaysToInclude();
        assertWeeksPatternOne(c);

        c.range.From__c = Date.newInstance(2013, 1, 15);    // Tuesday - week 3
        c.range.To__c = Date.newInstance(2013, 1, 23);      // Wednesday week 4   
        c.refreshDaysToInclude();
        assertWeeksPatternTwo(c);
        
        // This test doesn't assert the objects created; that is done in ClassCopyAllTest
        PageReference pr = c.copy();
        System.assertEquals(true, pr.getUrl().endsWith('/o'), 'url=' + pr.getUrl());
    }
    
    private static void assertWeeksPatternOne(ClassCopyAllController c) {
        
        System.assertEquals(3, c.weeks.size());
        
        ClassCopyAllController.Week one = c.weeks.get(0);
        System.assertEquals(false, one.mon.r);
        System.assertEquals(true, one.tue.r);
        System.assertEquals(true, one.wed.r);
        System.assertEquals(true, one.thu.r);
        System.assertEquals(true, one.fri.r);
        System.assertEquals(true, one.sat.r);
        System.assertEquals(true, one.sun.r);
        
        ClassCopyAllController.Week two = c.weeks.get(1);
        System.assertEquals(true, two.mon.r);
        System.assertEquals(true, two.tue.r);
        System.assertEquals(true, two.wed.r);
        System.assertEquals(true, two.thu.r);
        System.assertEquals(true, two.fri.r);
        System.assertEquals(true, two.sat.r);
        System.assertEquals(true, two.sun.r);
        
        ClassCopyAllController.Week three = c.weeks.get(2);
        System.assertEquals(true, three.mon.r);
        System.assertEquals(true, three.tue.r);
        System.assertEquals(true, three.wed.r);
        System.assertEquals(true, three.thu.r);
        System.assertEquals(false, three.fri.r);
        System.assertEquals(false, three.sat.r);
        System.assertEquals(false, three.sun.r);
        
        one.fri.s = false;
        one.sat.s = false;
        two.mon.s = false;
        two.tue.s = false;
        two.wed.s = false;
        two.thu.s = false;
        two.fri.s = false;
        two.sat.s = false;
        two.sun.s = false;
        
        // This deselected one will carry over to the next pattern assertion
        three.tue.s = false;
        
        System.assertEquals((6 - 2) + 0 + (4 - 1), c.getSelectedDates().size());
    }
    
    private static void assertWeeksPatternTwo(ClassCopyAllController c) {
        
        System.assertEquals(2, c.weeks.size());
        
        ClassCopyAllController.Week one = c.weeks.get(0);
        System.assertEquals(false, one.mon.r);
        System.assertEquals(true, one.tue.r);
        System.assertEquals(true, one.wed.r);
        System.assertEquals(true, one.thu.r);
        System.assertEquals(true, one.fri.r);
        System.assertEquals(true, one.sat.r);
        System.assertEquals(true, one.sun.r);
        
        ClassCopyAllController.Week two = c.weeks.get(1);
        System.assertEquals(true, two.mon.r);
        System.assertEquals(true, two.tue.r);
        System.assertEquals(true, two.wed.r);
        System.assertEquals(false, two.thu.r);
        System.assertEquals(false, two.fri.r);
        System.assertEquals(false, two.sat.r);
        System.assertEquals(false, two.sun.r);

        System.assertEquals((6 - 1) + 3, c.getSelectedDates().size());
    }
}