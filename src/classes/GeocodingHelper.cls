//forward geocoding using google
global class GeocodingHelper
{
  
    @future (callout=true)
    public static void forwardGeocodeConferenceRoomAddress(Id roomId, String street, String state, String city, String zip) {
             String encodedAddress  = GeocodingHelper.encodeAddress(street,state,city,zip);
      
      HttpRequest req = new HttpRequest();
      req.setEndpoint('http://maps.googleapis.com/maps/api/geocode/json?address='+encodedAddress+'&sensor=true');
      req.setMethod('GET');
      
      
      Http http = new Http();
      HTTPResponse res = http.send(req);
      System.debug(res.getBody()); 
      
      //the palace hotel, SF
      Double lng = -122.401737;
      Double lat = 37.788171; 
        
      JSONParser parser = JSON.createParser(res.getBody());
      while(parser.nextToken() != null)
      {
           if(parser.getText() == 'lat')
           {    parser.nextValue();
                lat = parser.getDoubleValue();
           }
           if(parser.getText() == 'lng')
           {
                parser.nextValue();
                lng = parser.getDoubleValue();
           }
      }
      
     
      
        
        ConferenceRoom__c room = [select id, name, GeoLocation__Latitude__s, GeoLocation__Longitude__s from ConferenceRoom__c where id =:roomId];
      room.GeoLocation__Latitude__s = lat;
      room.GeoLocation__Longitude__s = lng;
      update room;
 
    }
   
  @future (callout=true)
  public static void forwardGeocodeAddress(Id aptId, String street, String state, String city, String zip) {
      
      //todo: right now we are only handling the first case in the list
      /*
      http://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&sensor=true_or_false
      */
         
          String encodedAddress  = GeocodingHelper.encodeAddress(street,state,city,zip);
      
      HttpRequest req = new HttpRequest();
      req.setEndpoint('http://maps.googleapis.com/maps/api/geocode/json?address='+encodedAddress+'&sensor=true');
      req.setMethod('GET');
      
      
      Http http = new Http();
      HTTPResponse res = http.send(req);
      System.debug(res.getBody()); 
      
     
      JSONParser parser = JSON.createParser(res.getBody());
      
      //the palace hotel, SF
      Double lng = -122.401737;
      Double lat = 37.788171;
      
     
      
      
      
      while(parser.nextToken() != null)
      {
       if(parser.getText() == 'lat')
       {    parser.nextValue();
            lat = parser.getDoubleValue();
       }
       if(parser.getText() == 'lng')
       {
            parser.nextValue();
            lng = parser.getDoubleValue();
       }
      }
      
      
      
      Appointment__c apt = [select id, name, Service_Address_Geo__Latitude__s, Service_Address_Geo__Longitude__s from Appointment__c where id =:aptId];
      apt.Service_Address_Geo__Latitude__s = lat;
      apt.Service_Address_Geo__Longitude__s = lng;
      update apt;
  }
    
   public static String encodeAddress(String street, String city, String state, String zip)
   {
       return EncodingUtil.urlEncode(street+','+city+','+state+','+zip, 'UTF-8');
   }
}