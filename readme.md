# LGP-16 &mdash; Kwik Report
# Product Installation and Maintenance Packages

The PIMP is the main deliverable from the team to the client during the closure of the project. The contents of this deliverable must be discussed and agreed with the client and are part of the hand-over process. The hand-over should be tailored to both the product and the client; could include handing over the code repository, setting up the product in the client production servers, etc. 

The PIMP should include all the information required by the client to use, maintain (and evolve) the product and, besides the source code repository and the deployed product when applicable, it should include install, configure and maintain instructions. These instructions should be included in the repository.

## The Backend

The backend code and setup files are located inside the ```Backend```directory. In this chapter, please consider it the root directory &mdash; all the paths mentioned will be relative to it.

All the backend was conceived to rely on a Docker Composer stack, defined on ```docker-compose.yaml```. These instructions are valid assuming that such architecture is followed.

### Setup

1. Make sure you have a file called ```.env``` with the following variables:

```
DATABASE_URL={postgresql instance URl in the form: postgres://{username}:{password}@{host}:{port}/{db name}}
GEMINI_KEY={your gemini API key}
```

The key for the Gemini API is needed by the worker that generates descriptions about the videos' contents.

2. Edit the properties in ```conf.yaml``` if needed.

### Execution

1. Run ```docker compose up -d```. The endpoint ports meant to be 'public' are the ones that are specified under the ```nginx``` service in the ```docker-compose.yaml``` file.

### Maintenance

#### User accounts DB

An auxiliary service ```pgadmin``` is also launched by the Composer stack. It provides a way to manipulate the postgreSQL database that stores the app user accounts, since currently there are no routes in the Backend API that allow edition and deletion of accounts.

The credentials for pgadmin and for the database are defined under the respective services in ```docker-compose.yaml```.

## The Frontend (Mobile App)

The mobile app code and setup files are located inside the ```app```directory. In this chapter, please consider it the root directory &mdash; all the paths mentioned will be relative to it.

The app was developed using the Flutter framework. Thus, it is necessary to have all the tools needed to compile and run a Flutter app &mdash; refer to [docs.flutter.dev](docs.flutter.dev).

### Setup

1. There is a file in the directory ```lib/data``` called ```app_constants.dart```. In it, the address of on which the backend is exposed should be specified accordingly. Note that this should be the address of the ```nginx``` service of the backend.

2. Run ```flutter pub get``` to install all the necessary packages.

### Execution/Compilation

The app may be tried with a local Android emulator. Using an emulator via Visual Studio Code or Android Studio, run the app via the file ```lib/main.dart```.

The app may be built into an APK file to be installed in an Android device &mdash; [https://docs.flutter.dev/deployment](https://docs.flutter.dev/deployment)

***

LGP-16 / Kwik Report &mdash; June 2025
