global class DailyLeadProcessor implements Schedulable {

    global void execute(SchedulableContext ctx) {
                
                
        List<Lead> lstLeadsToUpdate = new List<Lead>();       
        
        for(Lead objLead : [Select Id,LeadSource
                            from Lead
                            where LeadSource = null limit 200])
           lstLeadsToUpdate.add(new Lead(Id = objLead.Id,LeadSource='Dreamforce'));                   
        
        update lstLeadsToUpdate;
    }
}