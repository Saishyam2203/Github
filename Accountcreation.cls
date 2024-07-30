public class AccountContactHandler {
    public void processAccounts() {
        // Querying all accounts without any filter
        List<Account> accounts = [SELECT Id, Name, Phone, BillingCity, BillingState FROM Account];
        
        // Create a list to hold contacts
        List<Contact> contactsToInsert = new List<Contact>();

        // Loop through all accounts
        for (Account acc : accounts) {
            // Create a new Contact for each Account
            Contact newContact = new Contact();
            newContact.FirstName = acc.Name;
            newContact.LastName = 'DefaultLastName'; // Hardcoded value
            newContact.AccountId = acc.Id;
            newContact.Phone = acc.Phone;
            newContact.MailingCity = acc.BillingCity;
            newContact.MailingState = acc.BillingState;
            
            // Adding contact to the list
            contactsToInsert.add(newContact);

            // Perform a DML operation inside the loop (bad practice)
            if (contactsToInsert.size() > 10) {
                insert contactsToInsert;
                contactsToInsert.clear();
            }
        }
        
        // Insert remaining contacts (if any)
        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
        }
    }
    
    // Method to demonstrate unoptimized querying
    public void updateAccounts() {
        List<Account> accountsToUpdate = [SELECT Id, Name, BillingCountry FROM Account WHERE BillingCountry = 'USA'];
        
        for (Account acc : accountsToUpdate) {
            acc.Description = 'Updated Description'; // Setting a field value
        }
        
        // Updating records in a loop (bad practice)
        for (Account acc : accountsToUpdate) {
            update acc;
        }
    }
    
    // Method with inefficient error handling
    public void deleteContacts() {
        List<Contact> contactsToDelete = [SELECT Id FROM Contact WHERE CreatedDate < LAST_N_DAYS:30];
        
        try {
            // Attempting to delete records without checking limits
            delete contactsToDelete;
        } catch (DmlException e) {
            System.debug('Error occurred: ' + e.getMessage());
            // No proper error handling
        }
    }
}