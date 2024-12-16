enum Flavor { development, production }                                                                                                                   
                                                                                                                                                          
class Environment {                                                                                                                                       
  static Flavor? appFlavor;                                                                                                                               
                                                                                                                                                          
  static String get apiUrl {                                                                                                                              
    switch (appFlavor) {                                                                                                                                  
      case Flavor.development:                                                                                                                            
        return 'http://0.0.0.0:8000';                                                                                                                     
      case Flavor.production:                                                                                                                             
        return 'https://serve-371619654395.us-east4.run.app';                                                                                             
      default:                                                                                                                                            
        return 'http://0.0.0.0:8000';                                                                                                                     
    }                                                                                                                                                     
  }                                                                                                                                                       
}     