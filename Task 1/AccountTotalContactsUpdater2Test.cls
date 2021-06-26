@isTest
public class AccountTotalContactsUpdater2Test {
    
    @testSetup
    public static void setupData(){
        List<Account> accts = new List<Account>();
        List<Contact> conts = new List<Contact>();
        for(Integer i=1;i<25;i++){
            Account acct = new Account(Name = 'T'+i);
            accts.add(acct);
        }
        insert accts;
        
        for(Account acc : accts){
            Contact cont = new Contact();
            cont.FirstName = 'first';
            cont.LastName = 'last '+acc.Name;
            cont.AccountId = acc.Id;
            conts.add(cont);
        }
        insert conts;
    }
    
    @isTest
    public static void testUpdate(){
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        System.assertEquals(24,[SELECT Id,Status,TargetObjectId FROM ProcessInstance WHERE Status = 'Pending'].size());
        System.assertEquals(24,[SELECT Id,Active__c FROM Contact WHERE Active__c = false].size());
        
        Test.startTest();
        for(ProcessInstanceWorkitem wi : [SELECT Id FROM ProcessInstanceWorkitem]){
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approve');
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req2.setWorkitemId(wi.Id);
            requests.add(req2);
        }
        
        for(Account acc : [SELECT Id,Total_Contacts__c FROM Account]){
            System.assertEquals(0,acc.Total_Contacts__c);
        }
        
        // Approve approval request..
        List<Approval.ProcessResult> result2 = Approval.process(requests);
        for(Approval.ProcessResult res : result2){
            System.assertEquals('Approved', res.getInstanceStatus());
        }
        Test.stopTest();
        
        System.assertEquals(0,[SELECT Id,Status,TargetObjectId FROM ProcessInstance WHERE Status = 'Pending'].size());
        System.assertEquals(0,[SELECT Id,Active__c FROM Contact WHERE Active__c = false].size());
        
        for(Account acc : [SELECT Id,Total_Contacts__c FROM Account]){
            System.assertEquals(1,acc.Total_Contacts__c);
        }
        
        // Delete contact test
        AccountTotalContactsUpdater2.accountIds.clear();
        DELETE [SELECT Id FROM Contact WHERE Active__c = true];
        
        for(Account acc : [SELECT Id,Total_Contacts__c FROM Account]){
            System.assertEquals(0,acc.Total_Contacts__c);
        }
        
        // Undelete contact test
        AccountTotalContactsUpdater2.accountIds.clear();
        UNDELETE [SELECT Id FROM Contact WHERE Active__c = true AND isDeleted = true ALL ROWS];
        System.assertEquals(24,[SELECT Id,Active__c FROM Contact WHERE Active__c = true].size());
        for(Account acc : [SELECT Id,Total_Contacts__c FROM Account]){
            System.assertEquals(1,acc.Total_Contacts__c);
        }
    }
    
    @isTest
    public static void bulktest(){
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        List<Contact> conts = new List<Contact>();
        Test.startTest();
        Account acct = new Account(Name = 'Test');
        insert acct;
        
        for(Integer i=1;i<26;i++){
            Contact cont = new Contact();
            cont.FirstName = 'first';
            cont.LastName = 'last '+acct.Name+i;
            cont.AccountId = acct.Id;
            conts.add(cont);
        }
        insert conts;     
        
        for(ProcessInstanceWorkitem wi : [SELECT Id FROM ProcessInstanceWorkitem]){
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approve');
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req2.setWorkitemId(wi.Id);
            requests.add(req2);
        }
        
        System.assertEquals(0,[SELECT Id,Total_Contacts__c FROM Account WHERE Name = 'Test'][0].Total_Contacts__c);
        
        // Approve approval request..
        List<Approval.ProcessResult> result2 = Approval.process(requests);
        for(Approval.ProcessResult res : result2){
            System.assertEquals('Approved', res.getInstanceStatus());
        }
        Test.stopTest();
        System.assertEquals(25,[SELECT Id,Name FROM Contact WHERE Active__c = true AND Account.Name = 'Test'].size());
        System.assertEquals(25,[SELECT Id,Total_Contacts__c FROM Account WHERE Name = 'Test'][0].Total_Contacts__c);
        
        // Delete contact test
        AccountTotalContactsUpdater2.accountIds.clear();
        DELETE [SELECT Id FROM Contact WHERE Active__c = true];
        System.assertEquals(0,[SELECT Id,Total_Contacts__c FROM Account WHERE Name = 'Test'][0].Total_Contacts__c);
        
        // Undelete contact test
        AccountTotalContactsUpdater2.accountIds.clear();
        UNDELETE [SELECT Id FROM Contact WHERE Active__c = true AND isDeleted = true ALL ROWS];
        System.assertEquals(49,[SELECT Id,Active__c FROM Contact WHERE Active__c = true].size());
        System.assertEquals(25,[SELECT Id,Total_Contacts__c FROM Account WHERE Name = 'Test'][0].Total_Contacts__c);
    }
}