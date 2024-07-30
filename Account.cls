public class AccountHelper {
    // This method retrieves accounts based on a given name and returns a list of accounts
    public List<Account> getAccountsByName(String accountName) {
        // Issue: Query inside a loop (potential for SOQL injection)
        for (Account acc : [SELECT Id, Name FROM Account WHERE Name LIKE :('%' + accountName + '%')]) {
            System.debug('Account Name: ' + acc.Name);
        }
        return null; // Issue: Method should return a list of accounts, not null
    }

    // This method updates the industry of accounts to the given industry
    public void updateAccountIndustry(String industry) {
        // Issue: No null check for the industry parameter
        List<Account> accountsToUpdate = [SELECT Id, Industry FROM Account WHERE Industry = null];
        for (Account acc : accountsToUpdate) {
            acc.Industry = industry;
        }
        // Issue: DML operation without a try-catch block
        update accountsToUpdate;
    }

    // This method deletes accounts with a certain type
    public void deleteAccountsByType(String accountType) {
        // Issue: No bulk-safe code (only processes one record)
        Account acc = [SELECT Id FROM Account WHERE Type = :accountType LIMIT 1];
        // Issue: Hard-coded type value check
        if (acc.Type == 'Prospect') {
            delete acc;
        }
    }
