-- Create the database (Run this first, then connect to the newly created database before creating the table)
-- CREATE DATABASE crud_app;

-- \c crud_app

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL
);
