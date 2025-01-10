import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;                                                                                                                                                                                               

  const GradientBackground({Key? key, required this.child}) : super(key: key);                                                                                                                                      

  @override                                                                                                                                                                                                         
  Widget build(BuildContext context) {                                                                                                                                                                              
    final theme = Theme.of(context);                                                                                                                                                                                
    return Container(                                                                                                                                                                                               
      decoration: BoxDecoration(                                                                                                                                                                                    
        gradient: LinearGradient(                                                                                                                                                                                   
          begin: Alignment.topLeft,                                                                                                                                                                                 
          end: Alignment.bottomRight,                                                                                                                                                                               
          colors: [                                                                                                                                                                                                 
            theme.colorScheme.primary.withAlpha((0.5 * 255).round()),                                                                                                                                               
            theme.colorScheme.surface,                                                                                                                                                                              
          ],                                                                                                                                                                                                        
        ),                                                                                                                                                                                                          
      ),                                                                                                                                                                                                            
      child: child,                                                                                                                                                                                                 
    );                                                                                                                                                                                                              
  }                                                                                                                                                                                                                 
}                                                                                                                                                                                                                   