public class ToDoController {
    
    @AuraEnabled
    public static List<To_Do__c> getToDoList(String userId){
        return [SELECT Id,Name,Status__c,Actions__c,Contact__c,Contact__r.Name
                FROM To_Do__c 
                WHERE CreatedById =: userId
                ORDER BY CreatedDate DESC];
    }
}