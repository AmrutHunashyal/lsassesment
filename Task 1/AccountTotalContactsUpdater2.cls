public class AccountTotalContactsUpdater2 {
    @TestVisible
    private static Set<Id> accountIds = new Set<Id>();
    
    public static void onUpdate(List<Contact> contacts,Map<Id,Contact> oldMapContacts){
        for(Contact cont : contacts){
            if(cont.Active__c && oldMapContacts.get(cont.Id).Active__c != cont.Active__c){
                accountIds.add(cont.AccountId);
            }
        }
        calcTotalContacts(accountIds);
    }
    
    public static void onDelete(List<Contact> contacts){
        for(Contact cont : contacts){
            if(cont.Active__c){
                accountIds.add(cont.AccountId);
            }
        }
        calcTotalContacts(accountIds);
    }
    
    public static void onUndelete(List<Contact> contacts){
        for(Contact cont : contacts){
            if(cont.Active__c){
                accountIds.add(cont.AccountId);
            }
        }
        calcTotalContacts(accountIds);
    }
    
    
    private static void calcTotalContacts(Set<Id> accountIds){
        List<Account> acctsToBeUpdated = new List<Account>();
        for(Account acct : [SELECT Id,Total_Contacts__c,(SELECT Id FROM Contacts WHERE Active__c = true) 
                            FROM Account WHERE Id IN : accountIds])
        {
            acct.Total_Contacts__c = acct.contacts.size();
            acctsToBeUpdated.add(acct);
        }
        
        if(!acctsToBeUpdated.isEmpty()){
            Update acctsToBeUpdated;
        }
    }
}