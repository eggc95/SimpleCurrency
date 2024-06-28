# Simple Currency App

A simple and easy to use currency converter for some of the most commonly used currencies in the world

## Design patterns and structure

### MVVM

The main design pattern of this project is the MVVM design pattern, splitting the code into Model, View, ViewModel. 
Modularisation of the project allows better scalability and maintenance especially if there are multiple devs working on the same project

### Dependency Injection

The ViewModel is using dependency injection to ensure that it is loosely coupled making the code more testable.

###Singleton 

The network layer is being created via the singleton pattern ensuring only one instance of the NetworkService is created following best practices.

###Combine

Combine framework allows easier asynchronous data management and to update the UI when data is received via reactive programming.


