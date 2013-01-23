public class SelectableAvailableDate {

    public SelectableAvailableDate(AvailableDate__c sob, Id bookedDateId) {
        this.sob = sob;
        this.bookedDateId = bookedDateId;
        this.selected = bookedDateId != null;
    }
    
    public AvailableDate__c sob {
        get {
            return sob;
        }
        private set;
    }
    
    public Boolean past {
        get {
            return sob.Date__c < Date.today();
        }
    }
     
    public Id bookedDateId {get; private set;}
    
    public Boolean selected {get; set;}
}