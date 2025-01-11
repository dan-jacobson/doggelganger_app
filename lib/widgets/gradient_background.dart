import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;                                                                                                                                                                                               

  const GradientBackground({super.key, required this.child});                                                                                                                                      

  @override                                                                                                                                                                                                         
  Widget build(BuildContext context) {                                                                                                                                                                              
    final theme = Theme.of(context);                                                                                                                                                                                
    return Container(                                                                                                                                                                                               
      decoration: BoxDecoration(                                                                                                                                                                                    
        gradient: LinearGradient(                                                                                                                                                                                   
          begin: Alignment.topLeft,                                                                                                                                                                                 
          end: Alignment.bottomRight,                                                                                                                                                                               
          colors: [                                                                                                                                                                                                 
            theme.colorScheme.primary,
            theme.colorScheme.surface,                                                                                                                                                                              
          ],                                                                                                                                                                                                        
        ),                                                                                                                                                                                                          
      ),                                                                                                                                                                                                            
      child: child,                                                                                                                                                                                                 
    );                                                                                                                                                                                                              
  }                                                                                                                                                                                                                 
}                                                                                                                                                                                                                   