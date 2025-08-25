# Shelfie

**Shelfie** is a fullstack digital bookshelf application designed to help users track and manage their reading activities across devices. It includes a Flutter-based mobile app, a .NET backend API, and a desktop admin application.

**Project Status:** Done

---

## Desktop Application (Admin Panel) Features

- **Books Management:**
  - View all books with title, author, genre, description, number of pages, and cover image
  - Search and sort alphabetically (asc/desc)
  - Add new books, edit existing ones, delete outdated or irrelevant titles

- **User Reviews Overview:**
  - View all reviews by a specific user with book data, rating, description, and date
  - Sort reviews by date
  - Read-only, no edits allowed

- **Book Reviews:**
  - View all reviews for a specific book with user, date, rating, and short description
  - Filter by book and sort by date
  - Read-only, no edits allowed

- **Authors Management:**
  - View all authors with name, surname, country, birth year, email, and phone
  - Search and sort alphabetically
  - Add, edit, and delete authors

- **App Statistics:**
  - Overview of total users, books, authors, reviews, most read genres, most active users, average ratings, and reading trends


- **Posts Overview:**
  - View all discussion posts, filter by genre, sort by date (newest/oldest), view read/unread
  - Delete posts if needed

- **Post Details and Comments:**
  - View full post content and comments
  - Delete inappropriate comments

---

## Mobile Application Features

- **Explore Page:**
  - Personalized book recommendations based on most read genres and top-rated books
  - Add books to shelves via “Add to Shelf” button

- **Shelves:**
  - Want to Read, Read, Currently Reading
  - Remove books from shelves if already added
  - Mark books as read to move from Currently Reading → Read
  - Sort books by date added

- **Book Details:**
  - View all info: title, author, genre, pages, summary
  - Add to desired shelf with one click

- **Reading Challenges:**
  - View active challenges with progress and remaining days
  - Add new challenge with goal (e.g., read 100 pages in 5 days)
  - Edit or delete challenges
  - See books completed in each challenge time period

- **User Statistics:**
  - Track total books/pages read this year
  - Most read genres, shortest/longest books, highest/lowest rated books

- **Discussion Forum:**
  - Browse posts by genre
  - Write new posts
  - Read and comment on posts

- **My Profile / Mini Feed:**
  - Edit personal info and app settings
  - User Activity
  - Delete profile

---

## Technology Stack

- **Frontend:** Flutter (mobile and desktop)  
- **Backend:** C# .NET Core  
- **Database:** MS SQL Server  
- **Deployment:** Docker

## RabbitMQ Notifications

This project uses RabbitMQ to send real-time in-app notifications to users. Whenever someone comments on a user's post, a notification is sent via the subscriber service. Notifications are not sent when a user comments on their own post.

---

## Running the Application

### 1. Prepare backend
- Unpack `fit-build-2025_env.zip`  
- Inside the folder, run: 
 - docker compose up

### 2. Mobile App
- Unpack `fit-build-2025-08-25.zip`
- Find the APK: `fit-build-2025-08-25/flutter-apk/app-release.apk`
- Drag & drop APK into Android Emulator (AVD)
- Launch the app in emulator
- **API address:** `http://10.0.2.2:5046`

---

### 3. Desktop App
- In the same zip, find `.exe`: `fit-build-2025-08-25/Release/`
- Run the `.exe` file
- **API address:** `http://localhost:5046`

---

### Test Accounts

**Desktop (Admin):**
- Username: `desktop` / Password: `test`

**Mobile:**
- Username: `mobile` / Password: `test`
- Username: `alice` / Password: `test`
