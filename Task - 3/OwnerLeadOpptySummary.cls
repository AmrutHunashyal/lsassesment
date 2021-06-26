/*
* Test Class : OwnerLeadOpptySummaryTest
* Description : Summary report of leads and opportunity owned.
*/
public class OwnerLeadOpptySummary {
    
    static Map<String,LeadOpptyWrapper> ownerToLeadOppWrapper = new Map<String,LeadOpptyWrapper>();
    
    @AuraEnabled(cacheable=true)
    public static List<LeadOpptyWrapper> getLeadOpptySummary(Date startDate,Date endDate){
        endDate +=1;
        Boolean leadOppBothExists = false;
        List<LeadOpptyWrapper> wrlist = new List<LeadOpptyWrapper>();
        for(AggregateResult ld : [SELECT COUNT(Id),OwnerId,Owner.Name lname FROM Lead 
                                  WHERE (CreatedDate >= : startDate AND CreatedDate <= : endDate)
                                  GROUP BY OwnerId,Owner.Name])
        {
            LeadOpptyWrapper wr = new LeadOpptyWrapper();
            wr.leadCount = Integer.valueOf(ld.get('expr0'));
            wr.owner = String.valueOf(ld.get('lname'));
            ownerToLeadOppWrapper.put((Id)ld.get('OwnerId'), wr);    
        }
        for(AggregateResult opp : [SELECT COUNT(id),OwnerId,Owner.Name oname,SUM(amount),MAX(CreatedDate)
                                   FROM Opportunity
                                   WHERE StageName = 'Closed Won' AND (CloseDate >= : startDate AND CloseDate < : endDate)
                                   GROUP BY OwnerId,Owner.Name])
        {
            if(ownerToLeadOppWrapper.containsKey((Id)opp.get('OwnerId'))){
                LeadOpptyWrapper wr = ownerToLeadOppWrapper.get((Id)opp.get('OwnerId'));
                wr.owner = String.valueOf(opp.get('oname'));
                wr.opptyCount = Integer.valueOf(opp.get('expr0'));
                wr.totalOpptyValue = Double.valueOf(opp.get('expr1'));
                wr.maxOppCreatedDate = Date.valueOf(opp.get('expr2'));
                leadOppBothExists = true;
            }
        }
        
        // If either lead or opportunity doesn't exists return empty..
        if(!leadOppBothExists)
            ownerToLeadOppWrapper.clear();
        
        for(String key : ownerToLeadOppWrapper.keySet()){
            LeadOpptyWrapper wr = ownerToLeadOppWrapper.get(key);
            wr.conversionRate = (wr.leadCount / wr.opptyCount).setScale(2);
        }
        return ownerToLeadOppWrapper.values();
    }
    
    public class LeadOpptyWrapper{
        @AuraEnabled
        public  Decimal leadCount;
        @AuraEnabled
        public  Decimal opptyCount;
        @AuraEnabled
        public  String owner;
        @AuraEnabled
        public  Decimal conversionRate;
        @AuraEnabled
        public  Double totalOpptyValue;
        @AuraEnabled
        public Date maxOppCreatedDate;
    }
    
}