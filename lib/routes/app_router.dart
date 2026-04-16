import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// TODO: Import feature pages
// import '../features/auth/presentation/pages/splash_page.dart';
// import '../features/auth/presentation/pages/login_page.dart';
// import '../features/auth/presentation/pages/signup_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Home Page - To be implemented'),
        ),
      ),
      // TODO: Implement home page
    ),
    // Auth Routes
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Login Page - To be implemented'),
        ),
      ),
      // TODO: Implement login page
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Sign Up Page - To be implemented'),
        ),
      ),
      // TODO: Implement signup page
    ),
    // Doctor Routes
    GoRoute(
      path: '/doctors',
      name: 'doctors',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Doctors List - To be implemented'),
        ),
      ),
      // TODO: Implement doctors list
    ),
    GoRoute(
      path: '/doctor/:id',
      name: 'doctorDetail',
      builder: (context, state) => Scaffold(
        body: Center(
          child: Text('Doctor Detail: ${state.pathParameters['id']}'),
        ),
      ),
      // TODO: Implement doctor detail
    ),
    // Booking Routes
    GoRoute(
      path: '/booking',
      name: 'booking',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Booking - To be implemented'),
        ),
      ),
      // TODO: Implement booking
    ),
    // Payment Routes
    GoRoute(
      path: '/payment',
      name: 'payment',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Payment - To be implemented'),
        ),
      ),
      // TODO: Implement payment
    ),
    // Profile Routes
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Profile - To be implemented'),
        ),
      ),
      // TODO: Implement profile
    ),
    // Settings Routes
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Settings - To be implemented'),
        ),
      ),
      // TODO: Implement settings
    ),
    // Chat Routes
    GoRoute(
      path: '/chat',
      name: 'chat',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Chat - To be implemented'),
        ),
      ),
      // TODO: Implement chat
    ),
    GoRoute(
      path: '/chat/:id',
      name: 'chatDetail',
      builder: (context, state) => Scaffold(
        body: Center(
          child: Text('Chat Detail: ${state.pathParameters['id']}'),
        ),
      ),
      // TODO: Implement chat detail
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.error}'),
    ),
  ),
);
