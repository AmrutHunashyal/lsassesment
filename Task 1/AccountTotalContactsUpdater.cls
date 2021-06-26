/*
* Test Class : AccountTotalContactsUpdaterTest
* Description : Updates Total Contacts on the Account as related Contacts get approval. 
* Class methods are called from ContactTrigger.
*/
public class AccountTotalContactsUpdater {
    @TestVisible
    private static Set<Id> accountIds = new Set<Id>();
    @TestVisible
    private static List<Account> acctsToBeUpdated = new List<Account>();
    @TestVisible
    private static Map<Id,Integer> acctIdToCount = new Map<Id,Integer>();
    
    public static void onUpdate(List<Contact> contacts,Map<Id,Contact> oldMapContacts){
        for(Contact cont : contacts){
            if(cont.Active__c && oldMapContacts.get(cont.Id).Active__c != cont.Active__c){
                if(acctIdToCount.containsKey(cont.AccountId)){
                    acctIdToCount.put(cont.AccountId,acctIdToCount.get(cont.AccountId)+1);
                }else{
                    acctIdToCount.put(cont.AccountId,1);
                }
                accountIds.add(cont.AccountId);
            }
        }
        System.debug('accountIds '+accountIds);
        System.debug('accountIdsize '+accountIds.size());
        for(Account acct : [SELECT Id,Total_Contacts__c FROM Account WHERE Id IN : acctIdToCount.keySet()]){
            acct.Total_Contacts__c += acctIdToCount.get(acct.Id);
            acctsToBeUpdated.add(acct);
        }
        System.debug('acctsToBeUpdated '+acctsToBeUpdated);
        System.debug('acctsToBeUpdatedsize '+acctsToBeUpdated.size());
        if(!acctsToBeUpdated.isEmpty()){
            Update acctsToBeUpdated;
        }
    }
    
    public static void onDelete(List<Contact> contacts){
        for(Contact cont : contacts){
            if(cont.Active__c){
                if(acctIdToCount.containsKey(cont.AccountId)){
                    acctIdToCount.put(cont.AccountId,acctIdToCount.get(cont.AccountId)+1);
                }else{
                    acctIdToCount.put(cont.AccountId,1);
                }
                accountIds.add(cont.AccountId);
            }
        }
        System.debug('accountIds '+accountIds);
        for(Account acct : [SELECT Id,Total_Contacts__c FROM Account WHERE Id IN : acctIdToCount.keySet()]){
            acct.Total_Contacts__c -= acctIdToCount.get(acct.Id);
            acctsToBeUpdated.add(acct);
        }
        System.debug('acctsToBeUpdated '+acctsToBeUpdated);
        if(!acctsToBeUpdated.isEmpty()){
            Update acctsToBeUpdated;
        }
    }
    
    public static void onUndelete(List<Contact> contacts){
        for(Contact cont : contacts){
            if(cont.Active__c){
                if(acctIdToCount.containsKey(cont.AccountId)){
                    acctIdToCount.put(cont.AccountId,acctIdToCount.get(cont.AccountId)+1);
                }else{
                    acctIdToCount.put(cont.AccountId,1);
                }
                accountIds.add(cont.AccountId);
            }
        }
        
        for(Account acct : [SELECT Id,Total_Contacts__c FROM Account WHERE Id IN : acctIdToCount.keySet()]){
            acct.Total_Contacts__c += acctIdToCount.get(acct.Id);
            acctsToBeUpdated.add(acct);
        }
        
        if(!acctsToBeUpdated.isEmpty()){
            Update acctsToBeUpdated;
        }
    }
    
    
    public static void onTest(List<Contact> contacts,Map<Id,Contact> oldMapContacts){
        for(Contact cont : contacts){
            if(cont.Active__c && oldMapContacts.get(cont.Id).Active__c != cont.Active__c){
                accountIds.add(cont.AccountId);
            }
        }

        for(Account acct : [SELECT Id,Total_Contacts__c,(SELECT Id FROM Contacts WHERE Active__c = true) 
                            FROM Account WHERE Id IN : accountIds]){
            acct.Total_Contacts__c = acct.contacts.size();
            acctsToBeUpdated.add(acct);
        }

        if(!acctsToBeUpdated.isEmpty()){
            Update acctsToBeUpdated;
        }
    }
}