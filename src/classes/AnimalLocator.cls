public class AnimalLocator{
   
       public static string getAnimalNameById(Integer animalIndex){
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals/:' + animalIndex);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) 
        {
            // Deserialize the JSON string into collections of primitive data types.
            Map<String, Object> animals = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());            
            Map<String, Object> i = (Map<String, Object>)animals.get('animal');
            system.debug('------name--------' + i.get('name')); 
            system.debug('------String--------' + String.valueOf(i.get('name'))); 
            
            return String.valueOf(i.get('name'));
        }
        
        return 'test';
     }
}