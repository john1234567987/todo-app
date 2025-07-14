<?php
// Include db.php to handle the initial request for tasks
require_once 'db.php';
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>To-Do App</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <!-- Bootstrap 5 -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Custom CSS -->
  <link rel="stylesheet" href="style.css">

  <!-- jQuery CDN -->
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  
  <script>
    $(document).ready(function() {
    
    function loadTasks() {

    $.ajax({
        url: 'get_tasks.php', 
        method: 'GET',
        dataType: 'json',
        success: function(tasks) {

            // Start with just the header
            let taskList = `
                <li class="list-group-item bg-light fw-bold">
                    <div class="row">
                        <div class="col-1">#</div>
                        <div class="col-5">Task Description</div>
                        <div class="col-2">Status</div>
                        <div class="col-4 text-center">Action</div>
                    </div>
                </li>
            `;
          
            tasks.forEach(function(task, index) {
                taskList += `
                    <li class="list-group-item">
                        <div class="row align-items-center" data-id="${task.id}">
                            <div class="col-1">${task.id}</div>
                            <div class="col-5 ${task.is_done == 0 ? '' : 'text-decoration-line-through text-muted'}">
                                ${task.title}
                            </div>
                            <div class="col-2">
                                <span class="badge bg-${task.is_done == 0 ? 'white' :  'success'}">
                                    ${task.is_done ==0 ? '' : 'Done'}
                                </span>
                            </div>
                            <div class="col-4 text-end">
                            <select class="form-select form-select-sm d-inline w-auto status-select" data-id="${task.id}">
    <option value="0" ${task.is_done == 0 ? 'selected' : ''}>Reset</option>
    <option value="1" ${task.is_done == 1 ? 'selected' : ''}>Done</option>
   
</select>

                            <a href="#" data-id=${task.id} class="btn btn-sm btn-danger delete-task">🗑</a>

                            </div>
                        </div>
                    </li>
                `;
            });


            $('.list-group').html(taskList);
        }
    });
}

        // Add new task via AJAX
        $('form').on('submit', function(e) {
            e.preventDefault();
            const title = $('input[name="title"]').val();
            
            if (title) {
                $.ajax({
                    url: 'add.php',
                    method: 'POST',
                    data: {title: title},
                    success: function() {
                        loadTasks();
                        $('input[name="title"]').val('');
                    }
                });
            }
        });


        // Change task status via dropdown
        $(document).on('change', '.status-select', function() {
            const taskId = $(this).attr('data-id'); 
            const newStatus = $(this).val(); // "0" for pending, "1" for done

            console.log(taskId )
            console.log(newStatus )

            $.ajax({
                url: 'done.php',
                method: 'POST',
                data: { id: taskId, is_done: newStatus },
                success: function() {
                    loadTasks();
                }
            });
        });


        // Delete task via AJAX
        $(document).on('click', '.delete-task', function() {

            const taskId = $(this).attr('data-id');
            console.log( $(this).data('id'));
            $.ajax({
                url: 'delete.php',
                method: 'GET',
                data: { id: taskId },
                success: function() {
                    loadTasks();
                }
            });
        });
    });
  </script>

</head>
<body>

  <div class="container todo-container">
    <h2 class="mb-4 text-center">📝 To-Do List</h2>

    <!-- Add Task Form -->
    <form method="POST" class="input-group mb-4">
      <input type="text" name="title" class="form-control" placeholder="Add a new task..." >
      <button class="btn btn-primary" type="submit">Add</button>
    </form>
    <ul class="list-group">  
        <!-- AJAX-injected task items appear below -->
    </ul>
  </div>

</body>
</html>



