Task List App
=============

Table of Contents
-----------------

-   [Setup Instructions](#setup-instructions)
-   [Architecture Overview](#architecture-overview)
-   [Key Design Decisions](#key-design-decisions)
-   [Known Limitations and Future Improvements](#known-limitations-and-future-improvements)

* * * * *

Setup Instructions
------------------

1.  **Clone the repository**:\
    Run the following command to clone the repository to your local machine:

    bash

    Copy code

    `git clone <repository-url>`

2.  **Install dependencies**:\
    Open the project in Xcode and ensure all required packages are installed via Swift Package Manager (e.g., Firebase, GoogleSignIn).

3.  **Configure Firebase**:

    -   Create a Firebase project and enable Firestore and Authentication (Google Sign-In).
    -   Download the `GoogleService-Info.plist` file and add it to the root of your Xcode project.
4.  **Core Data Setup**:\
    No additional setup is needed for Core Data; it's configured in the app to handle local task storage.

5.  **Build and Run**:\
    Select your simulator or connected device and press `Cmd + R` to run the app.

* * * * *

Architecture Overview
---------------------

The app follows an **MVVM (Model-View-ViewModel)** architecture, organized as follows:

-   **Model**: Handles data models, including task entities stored in Core Data and Firestore.
-   **View**: SwiftUI-based views for task creation, display, and editing.
-   **ViewModel**: Manages business logic, interacting with Core Data and Firestore to handle task operations and synchronization.

* * * * *

Key Design Decisions
--------------------

1.  **MVVM Architecture**:\
    MVVM was chosen to separate business logic from the UI, making the code more modular and scalable.

2.  **Firestore and Core Data**:\
    Data is stored both locally (Core Data) and remotely (Firestore), allowing the app to work offline and synchronize changes when back online.

3.  **Google Sign-In**:\
    Users authenticate via Google Sign-In, simplifying the login process.

4.  **Data Synchronization**:\
    Tasks are synchronized between Core Data and Firestore to ensure consistency across devices when connected to the internet.

* * * * *

Known Limitations and Future Improvements
-----------------------------------------

### Known Limitations:

1.  **Initial Network Status Check**:\
    The app's network monitor may not immediately detect the correct online/offline status at launch.

2.  **Conflict Handling**:\
    Currently, there is no conflict resolution between local and remote data changes.

### Future Improvements:

1.  **Enhanced Offline Support**:\
    Improve how Core Data handles task synchronization during offline-to-online transitions.

2.  **Task Categories**:\
    Add the ability to categorize tasks based on priority, due dates, etc.

3.  **Push Notifications**:\
    Integrate push notifications for task reminders and deadlines.

4.  **Improved Error Handling**:\
    Enhance the app's error-handling mechanisms for network and database issues.
