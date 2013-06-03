public with sharing class SmsController {
	
	public class SelectableContact {
		
		public Boolean selected {get; set;}
		public Boolean disabled {get; private set;}
		public Contact sob {get; private set;}
		public String cleanMobileNumber {
			get {
				return SmsBatchable.cleanMobilePhone(sob.MobilePhone);
			}
		}
		
		public SelectableContact(Contact sob, Boolean selected, Boolean disabled) {
			this.sob = sob;
			this.selected = selected;
			this.disabled = disabled;
		}
	}
	  
    public String fromNumber {
        get {
            return TwilioConfiguration__c.getInstance() != null ? TwilioConfiguration__c.getInstance().FromNumber__c : null;
        }
    }

    public String message {get; set;}
    
    public SelectableContact[] contacts {
    	get {
    		if (contacts == null) {
	    		Map<String, String> params = ApexPages.currentPage().getParameters();
	    		
	    		// These can be single values or comma separated values
	    		String contactId = params.get('contactId');
	    		String classId = params.get('classId');
	    		
	    		if (contactId != null) {
	    			contacts = wrap([
	    			        select Id, Name, RecordTypeId, Status__c, MobilePhone
	    			        from Contact
	    			        where Id = :decodeIds(contactId)
	    			        order by Name
	    			        ]);
	    		} else if (classId != null) {
	    			List<Contact> cs = new List<Contact>();
	    			Set<Id> alreadyIncluded = new Set<Id>();
	    			for (Booking__c b : [
	    			        select Client__r.Id, Client__r.Name, Client__r.MobilePhone, Client__r.Email, Client__r.Status__c
	    			        from Booking__c
	    			        where Class__c = :decodeIds(classId)
	    			        order by Client__r.Name
	    			        ]) {
	    			    if (!alreadyIncluded.contains(b.Client__r.Id)) {
	    				    cs.add(b.Client__r);
	    				    alreadyIncluded.add(b.Client__r.Id);
	    			    }
	    			}
	    			contacts = wrap(cs);
	    		} else {
	    			contacts = wrap(new Contact[] {});
	    		}
    		}
    		return contacts;
    	}
    	private set;
    }
    
    private static List<String> decodeIds(String s) {
    	
    	return EncodingUtil.urlDecode(s, 'UTF-8').split(',');
    }
    
    private static SelectableContact[] wrap(Contact[] contacts) {
    	
    	List<SelectableContact> wrappers = new List<SelectableContact>();
    	for (Contact c : contacts) {
    		wrappers.add(new SelectableContact(c, c.MobilePhone != null, c.MobilePhone == null));
    	}
    	return wrappers;
    }
    
    public PageReference send() {
    	
    	Set<Id> contactIds = new Set<Id>();
    	for (SelectableContact c : contacts) {
    		if (c.selected) {
    			contactIds.add(c.sob.Id);
    		}
    	}
    	
    	if (contactIds.size() == 0) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No-one has been selected to send to'));
    		return null;
    	}
     	if (message == null || message.trim().length() == 0) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter some message text to send'));
    		return null;
    	}
    	
    	try {
    		// Each SMS sent consumes one of the 10 HTTP calliuts available so process in batchaes of 10
    		if (!Test.isRunningTest()) {
    	        Database.executeBatch(new SmsBatchable(contactIds, message), 10);
    		}
    	} catch (SmsBatchable.SmsException e) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    		return null;
    	}
    	
    	return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
    }
    
    public PageReference cancel() {
    	
    	return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
    }
}