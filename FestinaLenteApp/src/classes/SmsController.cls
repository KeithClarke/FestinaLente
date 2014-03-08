public with sharing class SmsController {
    
    public class SelectableContact {
        
        public Boolean emailSelected {get; set;}
        public Boolean emailDisabled {get; private set;}
        
        public Boolean smsSelected {get; set;}
        public Boolean smsDisabled {get; private set;}
        
        public Contact sob {get; private set;}
        public String cleanMobileNumber {
            get {
                return SmsBatchable.cleanMobilePhone(sob.MobilePhone);
            }
        }
        
        public SelectableContact(Contact sob) {
        	
            this.sob = sob;
            this.emailSelected = false;
            this.emailDisabled = sob.Email == null;
            this.smsSelected = false;
            this.smsDisabled = sob.MobilePhone == null;
            
            // Prefer email
            if (this.emailSelected && this.smsSelected) {
            	this.smsSelected = false;
            }
        }
    }
    
    private TwilioConfiguration__c cs {
        get {
            return TwilioConfiguration__c.getInstance();
        }
    }
    
    public String emailSubject {
    	get {
    		return cs != null ? cs.EmailSubject__c : null;
    	}
    	set;
    }
    
    public String emailMessage {
        get {
            if (emailMessage == null) {
                emailMessage = messagePrefix + messageSuffix;
            }
            return emailMessage;
        }
        set;
    }
    
    public String fromEmail {
        get {
            return cs != null ? cs.FromNumber__c : null;
        }
    }
    
    public Decimal messageCost {
        get {
            return cs != null ? cs.MessageCost__c : null;
        }
    }
      
    public String fromNumber {
        get {
            return cs != null ? cs.FromNumber__c : null;
        }
    }

    public String smsMessage {
        get {
            if (smsMessage == null) {
                smsMessage = messagePrefix + messageSuffix;
            }
            return smsMessage;
        }
        set;
    }
    
    public Integer caretPosition {
        get {
            return messagePrefix.length();
        }
    }
    
    private String messagePrefix {
        get {
            return cs != null ? format(cs.MessagePrefix__c) : '';
        }
    }
    
    private String messageSuffix {
        get {
            return cs != null ? format(cs.MessageSuffix__c) : '';
        }
    }
    
    private String format(String s) {
        if (s != null) {
        
            // Spaces
            s = s.replaceAll('\\\\s', ' ');
        
            // Line feeds
            s = s.replaceAll('\\\\n', '\n');
            
            // User fields
            Boolean keepLooking = true;
            while(keepLooking) {
                keepLooking = false;
                String prefix = '{!User.';
                String suffix = '}';
                Integer start = s.indexOf(prefix);
                if (start != -1) {
                    Integer finish = s.indexOf(suffix, start);
                    if (finish != -1) {
                        String field = s.substring(start + prefix.length(), finish);
                        
                        String userId = UserInfo.getUserId();
                        String soql = 'select ' + String.escapeSingleQuotes(field) + '  from User where Id = :userId';
                        User u = (User) Database.query(soql);
    
                        s = s.substring(0, start) + String.valueOf(u.get(field)) + s.substring(finish + suffix.length());
                        keepLooking = true;
                    }
                }
            }
            return s;
        } else {
            return '';
        }
    }
    
    public AvailableDate__c filter {
    	get {
    		if (filter == null) {
    			filter = new AvailableDate__c();
    		}
    		return filter;
    	}
    	private set;
    }
    
    public SelectableContact[] contacts {
        get {
            if (contacts == null) {
                Map<String, String> params = ApexPages.currentPage().getParameters();
                
                // These can be single values or comma separated values
                String contactId = params.get('contactId');
                String classId = params.get('classId');
                
                if (contactId != null) {
                    contacts = wrap(filter([
                            select Id, Name, RecordTypeId, MobilePhone, Email, Status__c
                            from Contact
                            where Id = :decodeIds(contactId)
                            order by Name
                            ]));
                } else if (classId != null) {
                    List<Contact> cs = new List<Contact>();
                    Set<Id> alreadyIncluded = new Set<Id>();
                    for (Booking__c b : [
                            select Client__r.Id, Client__r.Name, Client__r.RecordTypeId, Client__r.MobilePhone, Client__r.Email, Client__r.Status__c
                            from Booking__c
                            where Class__c = :decodeIds(classId)
                            order by Client__r.Name
                            ]) {
                        if (!alreadyIncluded.contains(b.Client__r.Id)) {
                            cs.add(b.Client__r);
                            alreadyIncluded.add(b.Client__r.Id);
                        }
                    }
                    contacts = wrap(filter(cs));
                } else {
                    contacts = wrap(filter(new Contact[] {}));
                }
            }
            return contacts;
        }
        private set;
    }
    
    private static List<String> decodeIds(String s) {
        
        return EncodingUtil.urlDecode(s, 'UTF-8').split(',');
    }
    
    private Contact[] filter(Contact[] contacts) {
    	
    	if (contacts.size() > 0 && filter.Date__c != null) {
    		
    	    Set<Id> contactIds = new Set<Id>();
    	    for (Contact c : contacts) {
    	    	contactIds.add(c.Id);
    	    }
    	    
    	    Set<Id> bookedContactIds = new Set<Id>();
    	    for (BookedDate__c bd : [
    	           select Booking__r.Client__c
    	           from BookedDate__c
    	           where Date__c = :filter.Date__c
    	           and Booking__r.Client__c in :contactIds
    	           ]) {
    	    	bookedContactIds.add(bd.Booking__r.Client__c);
    	    }

    	    List<Contact> filtered = new List<Contact>();
    	    for (Contact c : contacts) {
    	    	if (bookedContactIds.contains(c.Id)) {
                    filtered.add(c);
    	    	}
            }
    	    return filtered;
    	} else {
    		return contacts;
    	}
    }
    
    private static SelectableContact[] wrap(Contact[] contacts) {
        
        List<SelectableContact> wrappers = new List<SelectableContact>();
        for (Contact c : contacts) {
            wrappers.add(new SelectableContact(c));
        }
        return wrappers;
    }
    
    public PageReference refreshContacts() {
        contacts = null;
        return null;
    }
    
    public PageReference send() {
        
        Set<Id> emailContactIds = new Set<Id>();
        Set<Id> smsContactIds = new Set<Id>();
        for (SelectableContact c : contacts) {
        	if (c.emailSelected) {
        		emailContactIds.add(c.sob.Id);
        	}
            if (c.smsSelected) {
                smsContactIds.add(c.sob.Id);
            }
        }
        
        if (emailContactIds.size() == 0 && smsContactIds.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No-one has been selected to send to'));
            return null;
        }
        if (emailContactIds.size() > 0 && (emailMessage == null || emailMessage.trim().length() == 0)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter some \"Email Body\" text to send'));
            return null;
        }
        if (smsContactIds.size() > 0 && (smsMessage == null || smsMessage.trim().length() == 0)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter some \"SMS Message\" text to send'));
            return null;
        }
        
        if (emailContactIds.size() > 0) {
        	try {
        		Messaging.reserveSingleEmailCapacity(emailContactIds.size());
        	} catch (Exception e) {
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot send ' + emailContactIds.size() + ' emails: ' + e.getMessage()));
        		return null;
        	}
        	String errors = sendEmail();
        	if (errors != null) {
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errors));
        		return null;
        	}
        }
        
        if (smsContactIds.size() > 0) {
	        try {
	            // Each SMS sent consumes one of the 10 HTTP callouts available so process in batches of 10
	            if (!Test.isRunningTest()) {
	                Database.executeBatch(new SmsBatchable(smsContactIds, smsMessage), 10);
	            }
	        } catch (SmsBatchable.SmsException e) {
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
	            return null;
	        }
        }
        
        return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
    }
    
    public PageReference cancel() {
        
        return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
    }
    
    private String sendEmail() {
    	
    	Messaging.SingleEmailMessage[] messages = new Messaging.SingleEmailMessage[] {};
    	Contact[] contactSobs = new Contact[] {};
    	for (SelectableContact c : contacts) {
            if (c.emailSelected) {
            	contactSobs.add(c.sob);
            	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            	message.setTargetObjectId(c.sob.Id);
                message.setSaveAsActivity(true);
                message.setSubject(emailSubject);
                message.setPlainTextBody(emailMessage);
            	messages.add(message);
            }
        }
        
        String[] errors = new String[] {};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages, true);
        for (Integer i = 0; i < results.size(); i++) {
            Messaging.SendEmailResult result = results[i];
        	if (!result.isSuccess()) {
        		Contact contactSob = contactSobs[i];
        		Messaging.SendEmailError[] emailErrors = result.getErrors();
        		if (emailErrors != null) {
	        		for (Messaging.SendEmailError emailError : emailErrors) {
	        			errors.add('email to ' + contactSob.Name + ' using email address ' + contactSob.Email + ' - ' + emailError.getMessage()); 
	        		}
        		}
        	}
        }
        
        return errors.size() > 0 ? 'No emails sent as there were these errors: ' + String.join(errors, '; ') : null;
    }
}