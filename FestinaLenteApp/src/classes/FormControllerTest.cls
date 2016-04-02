@IsTest
private class FormControllerTest {

    @IsTest
    static void newRider() {
        test(FormController.NEW_RIDER_FORM);
    }
    
    @IsTest
    static void specialNeeds() {
        test(FormController.SPECIAL_NEEDS_FORM);
    }
    
    @IsTest
    static void supportedHelper() {
        test(FormController.SUPPORTED_HELPER_FORM);
    }
    
    private static void test(String form) {
    
        Boolean nr = form == FormController.NEW_RIDER_FORM;
        Boolean sn = form == FormController.SPECIAL_NEEDS_FORM;
        Boolean sh = form == FormController.SPECIAL_NEEDS_FORM;
    
        ApexPages.currentPage().getParameters().put(FormController.FORM_PARAMETER, form);
    
        FormController c = new FormController();
        System.assertNotEquals(null, c.form);
        System.assertNotEquals(null, c.title);
        System.assertNotEquals(null, c.status);
        
        // Most fields just directly updated but some code user for these
        System.assert(c.desiredClassesList.size() > 0);
        System.assert(c.desiredClassesMap.size() > 0);
        if (nr || sn) System.assert(c.ridingCapabilitiesList.size() > 0);
        if (nr || sn) System.assert(c.ridingCapabilitiesMap.size() > 0);
        System.assert(c.howDidYouHearAboutUsList.size() > 0);
        System.assert(c.howDidYouHearAboutUsMap.size() > 0);
        
        System.assert(FormController.getCountyOptions().size() > 0);
        System.assert(FormController.getCountryOptions().size() > 0);
        
        System.assertNotEquals(null, c.c);
        
        c.c.LastName = 'Last Name';
        c.desiredClassesMap.put(c.desiredClassesList[0], true);
        if (nr || sn) c.ridingCapabilitiesMap.put(c.ridingCapabilitiesList[0], true);
        c.howDidYouHearAboutUsMap.put(c.howDidYouHearAboutUsList[0], true);
        
        System.assertEquals(null, c.save());
        
        Contact[] actuals = [
                select NewRiderDesiredClasses__c, SpecialNeedsDesiredClasses__c,
                        NewRiderRidingCapabilities__c, SpecialNeedsRidingCapabilities__c,
                        HowDidYouHearAboutUs__c
                from Contact
                ];
        System.assertEquals(1, actuals.size());
        
        Contact actual = actuals[0];
        if (nr) System.assert(!String.isEmpty(actual.NewRiderDesiredClasses__c));
        if (sn) System.assert(!String.isEmpty(actual.SpecialNeedsDesiredClasses__c));
        if (nr) System.assert(!String.isEmpty(actual.NewRiderRidingCapabilities__c));
        if (sn) System.assert(!String.isEmpty(actual.SpecialNeedsRidingCapabilities__c));
        System.assert(!String.isEmpty(actual.HowDidYouHearAboutUs__c));
    }
}