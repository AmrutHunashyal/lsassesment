@isTest
public class OwnerLeadOpptySummaryTest {
    
    @testSetup
    public static void setupData(){
        //Datetime yesterday = Datetime.now().addDays(+1);
        //Test.setCreatedDate(ld.id,yesterday);
        List<Lead> leads = new List<Lead>();
        List<Opportunity> opps = new List<Opportunity>();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User max = new User(Alias = 'standt1', Email='standarduser1@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Max', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='max@acme.com');
        insert max;
        
        User lewis = new User(Alias = 'standt2', Email='standarduser2@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Lewis', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='lewis@acme.com');
        insert lewis;
        
        System.runAs(max){
            for(Integer i=1;i<11;i++){
                Lead ld = new Lead(firstname='testmax'+i,lastname='lead',company='ABC'+i);
                leads.add(ld);
            }
            insert leads;
            
            for(Integer i=1;i<11;i++){
                Opportunity opp = new Opportunity(name='testmax opp',stagename='Closed Won',CloseDate=Date.today(),Amount=2000);
                opps.add(opp);
            }
            
            insert opps;
        }
        
        leads.clear();
        opps.clear();
        
        System.runAs(lewis){
            for(Integer i=1;i<8;i++){
                Lead ld = new Lead(firstname='testmax'+i,lastname='lead',company='ABC'+i);
                leads.add(ld);
            }
            insert leads;
            
            for(Integer i=1;i<10;i++){
                Opportunity opp = new Opportunity(name='testmax opp',stagename='Closed Won',CloseDate=Date.today(),Amount=5000);
                opps.add(opp);
            }
            insert opps;
        }
        
    }
    
    @isTest
    public static void oppleadsumTest(){
        List<OwnerLeadOpptySummary.LeadOpptyWrapper> low = OwnerLeadOpptySummary.getLeadOpptySummary(Date.today()-100, Date.today());
        for(OwnerLeadOpptySummary.LeadOpptyWrapper obj : low){
            if(obj.owner == 'Max'){
                System.assertEquals(10,obj.leadCount);
                System.assertEquals(10,obj.opptyCount);
                System.assertEquals(20000,obj.totalOpptyValue);
                System.assertEquals(1.00,obj.conversionRate);
            }else if(obj.owner == 'Lewis'){
                System.assertEquals(7,obj.leadCount);
                System.assertEquals(9,obj.opptyCount);
                System.assertEquals(45000,obj.totalOpptyValue);
            }
        }
    }
    
    @isTest
    public static void noLeadTest(){
        DELETE [SELECT Id FROM lead];
        List<OwnerLeadOpptySummary.LeadOpptyWrapper> low = OwnerLeadOpptySummary.getLeadOpptySummary(Date.today()-100, Date.today());
        System.assertEquals(0,low.size());
    }
    
    @isTest
    public static void noOppTest(){
        DELETE [SELECT Id FROM Opportunity];
        List<OwnerLeadOpptySummary.LeadOpptyWrapper> low = OwnerLeadOpptySummary.getLeadOpptySummary(Date.today()-100, Date.today());
        System.assertEquals(0,low.size());
    }
    
    @isTest
    public static void noLeadOppTest(){
        DELETE [SELECT Id FROM Opportunity];
        DELETE [SELECT Id FROM lead];
        List<OwnerLeadOpptySummary.LeadOpptyWrapper> low = OwnerLeadOpptySummary.getLeadOpptySummary(Date.today()-100, Date.today());
        System.assertEquals(0,low.size());
    }
}