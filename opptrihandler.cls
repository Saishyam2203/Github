public class OpportunityTriggerHandler {
    public static void handleTrigger(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunitiesMap,
                                     Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        if (isInsert || isUpdate || isUndelete) {
            updateAccountTotalOpportunityAmount(newOpportunities);
        } else if (isDelete) {
            updateAccountTotalOpportunityAmount(getClosedWonOpportunities(oldOpportunitiesMap.values()));
        }
    }

    private static List<Opportunity> getClosedWonOpportunities(List<Opportunity> opportunities) {
        List<Opportunity> closedWonOpportunities = new List<Opportunity>();
        for (Opportunity opportunity : opportunities) {
            if (opportunity.StageName == 'Closed Won') {
                closedWonOpportunities.add(opportunity);
            }
        }
        return closedWonOpportunities;
    }

    private static void updateAccountTotalOpportunityAmount(List<Opportunity> opportunities) {
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opportunity : opportunities) {
            accountIds.add(opportunity.AccountId);
        }

        List<Account> accountsToUpdate = [SELECT Id,
                                          (SELECT Amount, StageName FROM Opportunities WHERE StageName = 'Closed Won')
                                          FROM Account WHERE Id IN :accountIds];
        for (Account account : accountsToUpdate) {
            Decimal totalAmount = 0;
            for (Opportunity opportunity : account.Opportunities) {
                if (opportunity.StageName == 'Closed Won') {
                    totalAmount += opportunity.Amount;
                }
            }
            account.TotalOpportunityAmount__c = totalAmount;
        }

        update accountsToUpdate;
    }
}