# ✅ ToDo App

A simple web-based task management application built with HTML, CSS (Bootstrap), JavaScript (jQuery), and PHP (MySQL). Easily add, view, update, and mark tasks as done or reset.

---

## 🚀 Features

- Add new tasks
- View tasks in a list format
- Mark tasks as **Done** or **Reset**
- Dynamic UI updates using AJAX
- Simple and clean Bootstrap styling

---

## 🛠️ Tech Stack

- **Frontend**: HTML, CSS, Bootstrap, JavaScript, jQuery
- **Backend**: PHP
- **Database**: MySQL

---

## 📁 Project Structure
/todo-app/
│
├── index.php           # Main frontend page where tasks are displayed and interacted with
├── add.php             # Backend script to handle adding new tasks to the database
├── done.php            # Backend script to update a task's status (done or reset)
├── get_tasks.php       # Backend script to fetch and return all tasks (used via AJAX)
├── delete.php          # Backend script to delete task 
├── db.php              # Database connection file (used by all PHP scripts)
├── style.css           # Custom CSS overrides 
├── todo-app.sql        # SQL dump file for creating the database and tasks table
└── README.md           # Project documentation (you're reading it now)

