# Malawi Geocoder Project

Welcome to the Malawi Geocoder project! This project is developed in collaboration with MACRA to introduce a formal addressing system in Malawi. It aims to provide a geocoding assistant and a geo-datastore that complements the new national addressing system.

## Table of Contents

- [Introduction](#introduction)
- [API](#api)
    - [Technologies Used](#technologies-used-api)
    - [Setup and Installation](#setup-and-installation-api)
    - [Usage](#usage-api)
    - [API Endpoints](#api-endpoints)
- [Flutter App](#flutter-app)
    - [Technologies Used](#technologies-used-flutter)
    - [Setup and Installation](#setup-and-installation-flutter)
    - [Usage](#usage-flutter)
- [Collaborators](#collaborators)

## Introduction

The Malawi Geocoder project consists of a PostgreSQL database with PostGIS extension to store geospatial data, a NodeJS API to handle search requests, and a Flutter mobile app as the geocoding assistant. The system allows users to search for addresses and view their locations on a map.

---

## API

The API handles search requests and interacts with the PostgreSQL database.

### Technologies Used (API)

- Node.js
- Express.js
- PostgreSQL
- PostGIS

### Setup and Installation (API)

#### Prerequisites

- Node.js and npm
- PostgreSQL with PostGIS extension

#### Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/malawi-geocoder.git
   cd malawi-geocoder/api
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up environment variables:
   Create a `.env` file based on the `.env.example` template and fill in your database credentials.

4. Start the API server:
   ```bash
   npm start
   ```

### Usage (API)

The API provides endpoints to search for addresses and retrieve geospatial data.

### API Endpoints

- **/find**: Find an address by house number, road name, and area name.
- **/search**: Search for addresses using a text query.

#### Example Request
```bash
GET /search?text=Area+51
```

---

