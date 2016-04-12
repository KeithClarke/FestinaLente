/**
 * Self registration forms used via a Site.
 */
public with sharing class FormController {

    @TestVisible private static final String FORM_PARAMETER = 'form';
    
    public static String NEW_RIDER_FORM {get; private set;}
    public static String SPECIAL_NEEDS_FORM {get; private set;}
    public static String SUPPORTED_HELPER_FORM {get; private set;}
    static {
        NEW_RIDER_FORM = 'nr';
        SPECIAL_NEEDS_FORM = 'sn';
        SUPPORTED_HELPER_FORM = 'sh';
    }
    public static String NEW_STATUS {get; private set;}
    public static String DONE_STATUS {get; private set;}
    static {
        NEW_STATUS = 'new';
        DONE_STATUS = 'done';
    }
    
    private static String[] COUNTRIES = new String[] {
            'Afghanistan',
            'Albania',
            'Algeria',
            'American Samoa',
            'Andorra',
            'Angola',
            'Antigua and Barbuda',
            'Argentina',
            'Armenia',
            'Australia',
            'Austria',
            'Azerbaijan',
            'Bahamas',
            'Bahrain',
            'Bangladesh',
            'Barbados',
            'Belarus',
            'Belgium',
            'Belize',
            'Benin',
            'Bermuda',
            'Bhutan',
            'Bolivia',
            'Bosnia and Herzegovina',
            'Botswana',
            'Brazil',
            'Brunei',
            'Bulgaria',
            'Burkina Faso',
            'Burundi',
            'Cambodia',
            'Cameroon',
            'Canada',
            'Cape Verde',
            'Cayman Islands',
            'Central African Republic',
            'Chad',
            'Chile',
            'China',
            'Colombia',
            'Comoros',
            'Congo, Democratic Republic of the',
            'Congo, Republic of the',
            'Costa Rica',
            'Côte d\'Ivoire',
            'Croatia',
            'Cuba',
            'Cyprus',
            'Czech Republic',
            'Denmark',
            'Djibouti',
            'Dominica',
            'Dominican Republic',
            'East Timor',
            'Ecuador',
            'Egypt',
            'El Salvador',
            'Equatorial Guinea',
            'Eritrea',
            'Estonia',
            'Ethiopia',
            'Faroe Islands',
            'Fiji',
            'Finland',
            'France',
            'French Polynesia',
            'Gabon',
            'Gambia',
            'Georgia',
            'Germany',
            'Ghana',
            'Greece',
            'Greenland',
            'Grenada',
            'Guam',
            'Guatemala',
            'Guinea',
            'Guinea-Bissau',
            'Guyana',
            'Haiti',
            'Honduras',
            'Hong Kong',
            'Hungary',
            'Iceland',
            'India',
            'Indonesia',
            'Iran',
            'Iraq',
            'Ireland',
            'Israel',
            'Italy',
            'Jamaica',
            'Japan',
            'Jordan',
            'Kazakhstan',
            'Kenya',
            'Kiribati',
            'North Korea',
            'South Korea',
            'Kosovo',
            'Kuwait',
            'Kyrgyzstan',
            'Laos',
            'Latvia',
            'Lebanon',
            'Lesotho',
            'Liberia',
            'Libya',
            'Liechtenstein',
            'Lithuania',
            'Luxembourg',
            'Macedonia',
            'Madagascar',
            'Malawi',
            'Malaysia',
            'Maldives',
            'Mali',
            'Malta',
            'Marshall Islands',
            'Mauritania',
            'Mauritius',
            'Mexico',
            'Micronesia',
            'Moldova',
            'Monaco',
            'Mongolia',
            'Montenegro',
            'Morocco',
            'Mozambique',
            'Myanmar',
            'Namibia',
            'Nauru',
            'Nepal',
            'Netherlands',
            'New Zealand',
            'Nicaragua',
            'Niger',
            'Nigeria',
            'Northern Mariana Islands',
            'Norway',
            'Oman',
            'Pakistan',
            'Palau',
            'Palestine, State of',
            'Panama',
            'Papua New Guinea',
            'Paraguay',
            'Peru',
            'Philippines',
            'Poland',
            'Portugal',
            'Puerto Rico',
            'Qatar',
            'Romania',
            'Russia',
            'Rwanda',
            'Saint Kitts and Nevis',
            'Saint Lucia',
            'Saint Vincent and the Grenadines',
            'Samoa',
            'San Marino',
            'Sao Tome and Principe',
            'Saudi Arabia',
            'Senegal',
            'Serbia',
            'Seychelles',
            'Sierra Leone',
            'Singapore',
            'Sint Maarten',
            'Slovakia',
            'Slovenia',
            'Solomon Islands',
            'Somalia',
            'South Africa',
            'Spain',
            'Sri Lanka',
            'Sudan',
            'Sudan, South',
            'Suriname',
            'Swaziland',
            'Sweden',
            'Switzerland',
            'Syria',
            'Taiwan',
            'Tajikistan',
            'Tanzania',
            'Thailand',
            'Togo',
            'Tonga',
            'Trinidad and Tobago',
            'Tunisia',
            'Turkey',
            'Turkmenistan',
            'Tuvalu',
            'Uganda',
            'Ukraine',
            'United Arab Emirates',
            'United Kingdom',
            'United States',
            'Uruguay',
            'Uzbekistan',
            'Vanuatu',
            'Vatican City',
            'Venezuela',
            'Vietnam',
            'Virgin Islands, British',
            'Virgin Islands, U.S.',
            'Yemen',
            'Zambia',
            'Zimbabwe',
            'Not Applicable'
            };
    
    private static String[] COUNTIES = new String[] {
            'Dublin 1',
            'Dublin 2',
            'Dublin 3',
            'Dublin 4',
            'Dublin 5',
            'Dublin 6',
            'Dublin 6W',
            'Dublin 7',
            'Dublin 8',
            'Dublin 9',
            'Dublin 10',
            'Dublin 11',
            'Dublin 12',
            'Dublin 13',
            'Dublin 14',
            'Dublin 15',
            'Dublin 16',
            'Dublin 17',
            'Dublin 18',
            'Dublin 20',
            'Dublin 22',
            'Dublin 24',
            'Co Antrim',
            'Co Armagh',
            'Co Carlow',
            'Co Cavan',
            'Co Clare',
            'Co Cork',
            'Co Derry',
            'Co Donegal',
            'Co Down',
            'Co Dublin',
            'Co Fermanagh',
            'Co Galway',
            'Co Kerry',
            'Co Kildare',
            'Co Kilkenny',
            'Co Laois',
            'Co Leitrim',
            'Co Limerick',
            'Co Longford',
            'Co Louth',
            'Co Mayo',
            'Co Meath',
            'Co Monaghan',
            'Co Offaly',
            'Co Roscommon',
            'Co Sligo',
            'Co Tipperary',
            'Co Tyrone',
            'Co Waterford',
            'Co Westmeath',
            'Co Wexford',
            'Co Wicklow',
            'Not Applicable'
            };
            
    private static SObjectField[] FORM_FIELDS_TO_EMAIL = new SObjectField[] {
            Contact.FormName__c,
            
            Contact.NewRiderDesiredClasses__c,
            Contact.SpecialNeedsDesiredClasses__c,
            Contact.SupportedHelperDesiredClasses__c,
            Contact.AdditionalBookingInformationOrRequests__c,
            
            Contact.FirstName,
            Contact.LastName,
            Contact.MailingStreet,
            Contact.MailingCity,
            Contact.MailingState,
            Contact.MailingPostalCode,
            Contact.MailingCountry,
            Contact.MobilePhone,
            Contact.MainContactName__c,
            Contact.Email,
            Contact.MainContactRelationship__c,
            Contact.Phone,
            Contact.Birthdate,
            Contact.Gender__c,
            Contact.Height__c,
            Contact.Weight__c,
            Contact.EmergencyContactName__c,
            Contact.EmergencyContactPhone__c,
            Contact.EmergencyContactRelationship__c,
            Contact.EmergencyContactEmail__c,
            Contact.SecondEmergencyContactName__c,
            Contact.SecondEmergencyContactPhone__c,
            Contact.SecondEmergencyContactRelationship__c,
            Contact.SecondEmergencyContactEmail__c,
            
            Contact.MedicalHistory__c,
            Contact.RidingInjury__c,
            
            Contact.Allergies__c,
            Contact.MedicalConditionOrDisability__c,
            Contact.EpilepticEpisodes__c,
            Contact.AtlantoaxialInstability__c,
            Contact.PhysicalDifficulties__c,
            Contact.SensoryDifficulties__c,
            Contact.CommunicationDifficulties__c,
            Contact.CognitionDifficulties__c,
            Contact.PsychosocialDifficulties__c,
            Contact.Medication__c,
            Contact.BenefitsToApplicant__c,
            Contact.HobbiesInterestsLikesDislikes__c,
            Contact.OtherInformation__c,
            
            Contact.WorkWithHorses__c,
            Contact.OtherInformation__c,
            Contact.RidingHistory__c,
            Contact.RidingInLast12Months__c,
            Contact.HaveDoneAnEalSessionBefore__c,
            Contact.NewRiderRidingCapabilities__c,
            Contact.SpecialNeedsRidingCapabilities__c,
            Contact.AdditionalRidingHistory__c,
            
            Contact.OtherFamilyMemberClients__c,
            
            Contact.HowDidYouHearAboutUs__c,
            Contact.HowDidYouHearAboutUsOther__c,
            
            Contact.PhotoPermission__c,
            Contact.WaiverFormCompletedBy__c,
            Contact.WaiverFormRelationshipToApplicant__c,
            Contact.WaiverFormCompletedDate__c,
            Contact.WaiverFormCompleted__c
            };

    public String form {get; private set;}
    public String title {get; private set;}
    public String status {get; private set;}

    public Contact c {get; private set;}
    
    public String[] desiredClassesList {get; private set;}
    public Map<String, Boolean> desiredClassesMap {get; set;}
    
    public String[] ridingCapabilitiesList {get; private set;}
    public Map<String, Boolean> ridingCapabilitiesMap {get; set;}
    
    public String[] howDidYouHearAboutUsList {get; private set;}
    public Map<String, Boolean> howDidYouHearAboutUsMap {get; set;}
    
    // Represents what is different between the forms
    private class FormData {
        String title;
        SObjectField desiredClassesField;
        SObjectField ridingCapabilitiesField;
        SObjectField howDidYouHearAboutUsField;
        String[] emailAddresses;
        FormData(
                String title,
                SObjectField desiredClassesField,
                SObjectField ridingCapabilitiesField,
                SObjectField howDidYouHearAboutUsField,
                String[] emailAddresses
                ) {
            this.title = title;
            this.desiredClassesField = desiredClassesField;
            this.ridingCapabilitiesField = ridingCapabilitiesField;
            this.howDidYouHearAboutUsField = howDidYouHearAboutUsField;
            this.emailAddresses = emailAddresses;
        }
    }
    
    public FormController() {
    
        form = ApexPages.currentPage().getParameters().get(FORM_PARAMETER);
        status = NEW_STATUS;
        
        if (form == null) form = NEW_RIDER_FORM;
        
        c = createContact();
        
        FormData f = formData(form);
        title = f.title;
        
        desiredClassesList = picklistLabels(f.desiredClassesField);
        desiredClassesMap = toNotSelectedMap(desiredClassesList);
        
        ridingCapabilitiesList = picklistLabels(f.ridingCapabilitiesField);
        ridingCapabilitiesMap = toNotSelectedMap(ridingCapabilitiesList);
        
        howDidYouHearAboutUsList = picklistLabels(f.howDidYouHearAboutUsField);
        howDidYouHearAboutUsMap = toNotSelectedMap(howDidYouHearAboutUsList);
    }
    
    private Contact createContact() {
        return new Contact(
                MailingState = 'Co Dublin',
                MailingCountry = 'Ireland',
                WaiverFormCompletedDate__c = Date.today()
                );
    }
    
    public PageReference save() {
        
        FormData f = formData(form);
        if (f.desiredClassesField != null) {
            String selecteds = joinedSelecteds(desiredClassesMap);
            if (!String.isEmpty(selecteds)) c.put(f.desiredClassesField, selecteds);
            else addMessage(ApexPages.Severity.ERROR, 'Please select one or more "Lesson, camp or session" section items');
        }
        if (f.ridingCapabilitiesField != null) {
            String selecteds = joinedSelecteds(ridingCapabilitiesMap);
            if (!String.isEmpty(selecteds)) c.put(f.ridingCapabilitiesField, selecteds);
            else addMessage(ApexPages.Severity.ERROR, 'Please select one or more "applicant\'s riding capabilities on a horse" items in the "Riding history" section');
        }
        if (f.howDidYouHearAboutUsField != null) {
            String selecteds = joinedSelecteds(howDidYouHearAboutUsMap);
            if (!String.isEmpty(selecteds)) c.put(f.howDidYouHearAboutUsField, selecteds);
            else addMessage(ApexPages.Severity.ERROR, 'Please select one or more "How did you hear about Fetina Lente" section items');
        }
        
        if (ApexPages.getMessages().size() == 0) {
        
            c.FormName__c = f.title;
            c.ClassType__c = joinedSelecteds(desiredClassesMap);
            c.WaiverFormCompleted__c = true;
            insert c;
            
            if (f.emailAddresses.size() > 0) sendEmail(c, f.emailAddresses, 'Copy of Form Data: ' + f.title, new SObjectField[] {});
            
            // Clear out contact data
            c = createContact();
            
            addMessage(ApexPages.Severity.CONFIRM, 'Your "' + title + '" form has been successfully submitted. Thank-you.');
            status = DONE_STATUS;
        }
        
        return null;
    }
    
    // Just for test
    @TestVisible private static String[] emailAddresses;
    @TestVisible private static String emailPlainTextBody;
    
    private static void sendEmail(Contact c, String[] addresses, String subject, SObjectField[] fields) {
    
        emailAddresses = addresses;
        emailPlainTextBody = createPlainTextBody(c, fields);
    
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setSubject(subject);
        message.setPlainTextBody(emailPlainTextBody);
        message.setToAddresses(emailAddresses);
        
        // Nobody to send errors to so not checking...
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {message});
    }
    
    private static String createPlainTextBody(Contact c, SObjectField[] fields) {
    
        String[] parts = new String[] {};
        for (SObjectField f : FORM_FIELDS_TO_EMAIL) {
            Object o = c.get(f);
            if (o != null) {
                String label = f.getDescribe().getLabel();
                parts.add(' '.repeat(40 - label.length()) + label + ': ' + format(o));
            }
        }
        return String.join(parts, '\n');
    }
    
    private static String format(Object o) {
    
        if (o instanceof Date) return ((Date) o).format();
        else if (o instanceof DateTime) return ((DateTime) o).format();
        else if (o instanceof Boolean) return ((Boolean) o) ? 'Yes' : 'No';
        else return String.valueOf(o);
    }
    
    private static void addMessage(ApexPages.Severity severity, String message) {
        ApexPages.addMessage(new ApexPages.message(severity, message));
    }
    
    public static SelectOption[] getCountryOptions() {
        return toOptions(COUNTRIES);
    }
    
    public static SelectOption[] getCountyOptions() {
        return toOptions(COUNTIES);
    }
    
    private static SelectOption[] toOptions(String[] texts) {
        SelectOption[] options = new SelectOption[] {};
        for (String text : texts) options.add(new SelectOption(text, text));
        return options;
    }
    
    private static String[] picklistLabels(SObjectField f) {
        String[] labels = new String[] {};
        if (f != null) for (PicklistEntry e : f.getDescribe().getPicklistValues()) labels.add(e.getLabel());
        return labels;
    }
    
    private static Map<String, Boolean> toNotSelectedMap(String[] l) {
        Map<String, Boolean> m = new Map<String, Boolean>();
        for (String s : l) m.put(s, false);
        return m;
    }

    private static String joinedSelecteds(Map<String, Boolean> m) {
        String[] selecteds = new String[] {};
        for (String key : m.keySet()) {
            if (m.get(key)) selecteds.add(key);
        }
        return String.join(selecteds, ';');
    }
    
    private static FormData formData(String form) {
        // 3 variations
        FormOptions__c options = FormOptions__c.getInstance();
        if (form == NEW_RIDER_FORM) {
            return new FormData(
                    'New Rider Confidential Waiver & Application Form',
                    Contact.NewRiderDesiredClasses__c,
                    Contact.NewRiderRidingCapabilities__c,
                    Contact.HowDidYouHearAboutUs__c,
                    toArray(options.NewRiderEmail1__c, options.NewRiderEmail2__c)
                    );
        } else if (form == SPECIAL_NEEDS_FORM) {
            return new FormData(
                    'New Special Needs or Therapeutic Rider Confidential Waiver & Application Form',
                    Contact.SpecialNeedsDesiredClasses__c,
                    Contact.SpecialNeedsRidingCapabilities__c,
                    Contact.HowDidYouHearAboutUs__c,
                    toArray(options.SpecialNeedsEmail1__c, options.SpecialNeedsEmail2__c)
                    );
        } else if (form == SUPPORTED_HELPER_FORM) {
            return new FormData(
                    'New Supported Helper Confidential Waiver & Application Form',
                    Contact.SupportedHelperDesiredClasses__c,
                    null,
                    Contact.HowDidYouHearAboutUs__c,
                    toArray(options.SupportedHelperEmail1__c, options.SupportedHelperEmail2__c)
                    );
        } else {
            return new FormData(
                    'Unexpected form key ' + form,
                    null,
                    null,
                    null,
                    new String[] {}
                    );
        }
    }
    
    private static String[] toArray(String s1, String s2) {
    
        String[] ss = new String[] {};
        if (!String.isEmpty(s1)) ss.add(s1);
        if (!String.isEmpty(s2)) ss.add(s2);
        return ss;
    }
}