public class SmsBatchable implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    
    private static FINAL String ENDPOINT = 'https://api.twilio.com';
    private static final String VERSION = '2010-04-01';
    
    public class SmsException extends Exception {
    }
    
    private TwilioConfiguration__c config;
    private Set<Id> contactIds;
    private String message;
    private List<String> errors = new List<String>();

    public SmsBatchable(Set<Id> contactIds, String message) {
        
        config = TwilioConfiguration__c.getInstance();
        if (config == null || config.AccountSid__c == null || config.AuthToken__c == null || config.FromNumber__c == null) {
            throw new SmsException(''
                   + 'SMS not configured: enter your Twilio account information under Twilio Configuration custom settings '
                   + '(go to Setup | Develop | Custom Settings | Manage Twilio Configuration)'
                   );
        }
        this.contactIds = contactIds;
        this.message = message;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator([
                    select Id, Name, MobilePhone
                    from Contact
                    where Id in:contactIds
                    and MobilePhone != null
                    order by Name
                    ]);
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        
        List<Task> tasks = new List<Task>();
        try {
            for (SObject sob : scope) {
                Contact c = (Contact) sob;
                
                String toNumber = cleanMobilePhone(c.MobilePhone);
                if (toNumber != null) {
                
                    HttpRequest req = new HttpRequest();
                    
                    req.setHeader('X-Twilio-Client', 'salesforce-' + VERSION);
                    req.setHeader('User-Agent', 'twilio-salesforce-' + VERSION);
                    req.setHeader('Accept', 'application/json');
                    req.setHeader('Authorization', 'Basic '+ EncodingUtil.base64Encode(Blob.valueOf(config.AccountSid__c + ':' + config.AuthToken__c)));
                    
                    req.setEndpoint(ENDPOINT + '/' + VERSION + '/Accounts/' + config.AccountSid__c + '/SMS/Messages');
                    req.setMethod('POST');
                    req.setBody(''
                           + 'From=' + EncodingUtil.urlEncode(config.FromNumber__c, 'UTF-8')
                           + '&To=' + EncodingUtil.urlEncode(toNumber, 'UTF-8')
                           + '&Body=' + + EncodingUtil.urlEncode(message, 'UTF-8')
                           );
                        
                    HttpResponse res = new Http().send(req);
                    if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                        tasks.add(new Task(
                             Subject = 'SMS: ' + truncate(message),
                             Description = message,
                             WhoId = c.Id,
                             ActivityDate = Date.today(),
                             Status = 'Completed'
                             ));
                    } else {
                        errors.add(''
                                + 'Contact: ' + c.Name + ' (https://' + URL.getSalesforceBaseUrl().getHost() + '/' + c.Id + ')' + '\n'
                                + 'StatusCode: '+ res.getStatusCode() + '\n'
                                + 'Status: ' + res.getStatus() + '\n'
                                + 'Body: ' + res.getBody()
                                );
                    }
                }
            }
        } finally {
            if (tasks.size() > 0) {
                insert tasks;
            }
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        
        if (errors.size() > 0) {

            String toAddress = [Select Id, Email from User where Id =:UserInfo.getUserId()].Email;
            String body = 'Message: ' + message + '\n\n';
            for (String error : errors) {
                body += error + '\n';
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSenderDisplayName('Festina Lente App');
            mail.setToAddresses(new String[]{ toAddress });
            mail.setSubject('Festina Lente App SMS Errors (' + errors.size() + ')');
            mail.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.Email[] { mail });
        }
    }
    
    public static String cleanMobilePhone(String s) {
        
        if (s != null) {
            Boolean hasCountryCode = false;
            String ss = '';
            for (Integer i = 0; i < s.length(); i++) {
                String c = s.substring(i, i + 1);
                if (i == 0 && c == '+') {
                    hasCountryCode = true;
                    ss += c;
                } else if (c.isNumeric()) {
                    ss += c;
                }
            }
            
            if (hasCountryCode) {
                return ss;
            } else {
                return '+353' + (ss.startsWith('0') ? ss.substring(1, ss.length()) : ss);
            }
        } else {
            return null;
        }
    }
    
    private static String truncate(String s) {
        
        Integer max = 50;
        return s.length() <= max ? s : s.substring(0, max) + '...';
    }
}