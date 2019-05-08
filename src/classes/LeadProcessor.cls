global class LeadProcessor implements 
    Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('Select Id,LeadSource from Lead'
                    );
    }

    global void execute(Database.BatchableContext bc, List<Lead> scope){
        // process each batch of records
        List<Lead> leadsToUpdate = new List<Lead>();
        for (Lead objLead: scope) 
        {
            leadsToUpdate.add(new Lead(Id = objLead.Id,LeadSource='Dreamforce')); 
        }
        update leadsToUpdate;
    }    

    global void finish(Database.BatchableContext bc){
           
    }    

}