# 3-Tier CRUD Application

A complete 3-tier CRUD app built with React, Node.js (Express), and PostgreSQL.

## Prerequisites
- **Node.js**: v14 or higher (v20+ recommended)
- **PostgreSQL**: Installed and running locally

## Setup Instructions

### 1. Database Setup
1. Open your PostgreSQL terminal (e.g., `psql` or pgAdmin).
2. Create a database named `crud_app`:
   ```sql
   CREATE DATABASE crud_app;
   ```
3. Connect to the `crud_app` database.
4. Run the SQL script located in `database.sql` to create the `users` table:
   ```sql
   CREATE TABLE IF NOT EXISTS users (
     id SERIAL PRIMARY KEY,
     name VARCHAR(100) NOT NULL,
     email VARCHAR(100) NOT NULL
   );
   ```

### 2. Backend Setup
1. Navigate to the `backend` directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Verify the `.env` file in the `backend` directory matches your PostgreSQL credentials:
   ```env
   PORT=5000
   DB_USER=postgres
   DB_PASSWORD=postgres
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=crud_app
   ```
4. Start the backend server:
   ```bash
   npm run dev
   ```
   *(Server will run on http://localhost:5000)*

### 3. Frontend Setup
1. Open a new terminal and navigate to the `frontend` directory:
   ```bash
   cd frontend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Start the React development server:
### 4. Running with Docker

You can run the entire 3-tier application using Docker and Docker Compose. This is the easiest way to get everything up and running.

1. Make sure you have Docker and Docker Compose installed.
2. In the root directory (`d:\data\crud`), run:
   ```bash
   docker-compose up --build -d
   ```
3. The services will be available at:
   - **Frontend**: http://localhost
   - **Backend API**: http://localhost:5000
   - **Database**: localhost:5432

To stop the containers, run:
```bash
docker-compose down
```

## Features
- Create new users (Name and Email)
- View all users in a list
- Update existing user details
- Delete users
- Modern, clean, and responsive UI
