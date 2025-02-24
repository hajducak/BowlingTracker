
# Sport Tracker App

This is a simple mobile application designed to track sports performances. The app allows users to input their sports activities, store them either locally (using CoreData) or remotely (using Firebase), and display the recorded entries. It is built using modern iOS development technologies such as SwiftUI, Combine, and SwiftData, and follows the MVVM architecture.

## Technologies Used

### SwiftUI
SwiftUI is a user interface toolkit introduced by Apple that allows building declarative UIs. It helps in designing the user interface with minimal code, making the application more maintainable and easy to test. SwiftUI was used for building the app's user interface and handling dynamic content updates.

### Combine
Combine is a framework by Apple for handling asynchronous events and data streams. It was used to manage data flow within the app, such as binding data from user inputs to the app's models and managing updates from both the local and remote databases.

### SwiftData
SwiftData provides an easy-to-use, native object-oriented interface for managing persistent data. It was used for storing and retrieving sports performance entries locally on the device.

### Unit and UI Testing
Testing is a crucial part of the development process. Unit tests were implemented to test individual components of the app’s logic, such as the data handling and model layers. UI tests were written to verify the user interface behavior, ensuring that the app performs correctly across different screen sizes and orientations.

### MVVM Architecture
The Model-View-ViewModel (MVVM) architecture was adopted to separate the app’s UI from its business logic. The `ViewModel` acts as an intermediary between the `Model` (data layer) and the `View` (UI layer). This structure helps maintain a clean and scalable codebase.

### Firebase
Firebase was used as the remote backend for storing sports performance data. It allows the app to store records in the cloud, making the data accessible across devices and platforms.

## App Features

### 1. **Add Sports Performance**
The first screen of the app allows the user to input the following details for their sports performance:
- Name of the sport
- Location of the event
- Duration of the activity
- Option to choose whether to store the entry locally or on the Firebase backend

Once the user inputs the information, it is saved to the chosen storage solution (local or remote).

### 2. **View Sports Performance Entries**
The second screen of the app displays a list of previously entered sports performances. The user can filter the records based on the storage type (All | Local | Remote). Entries are color-coded based on their source:
- **Local**: Entries saved locally in the device’s storage.
- **Remote**: Entries saved remotely using Firebase.

### 3. **Navigation Flow**
The app is designed with a clear and intuitive navigation flow:
- **Adding a new performance**: Users can easily navigate to the input screen to record a new activity.
- **Viewing previous entries**: The app allows users to view their past performances, filtered by storage type, in a list format.

The navigation flow is designed to be simple and user-friendly, with minimal steps to complete each task.

### 4. **Responsive Design**
The app supports both **portrait** and **landscape** orientations. The layout adapts seamlessly to different screen sizes, ensuring a great user experience across various iOS devices.

## Installation

To install and run the app on your local machine:

1. Clone the repository:
    `git clone https://github.com/yourusername/SportTracker.git`

2. Open the project in Xcode:
    `open SportTracker.xcodeproj`

3. Build and run the app on a simulator or a physical device.

4. use `main` branch only

## Testing

The app includes both **Unit Tests** and **UI Tests** to ensure its reliability:

- **Unit Tests**: Test the data handling, validation, and business logic.
- **UI Tests**: Test the user interface and navigation.

To run the tests, select **Product > Test** in Xcode or use the following command:
    `xcodebuild test`

## Conclusion
This app provides an easy way for users to track their sports activities, with the flexibility to store data either locally or remotely using Firebase. The app is built using modern iOS development techniques, ensuring a responsive, maintainable, and testable application.
