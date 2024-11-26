import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { Task } from 'src/app/models/task-model';
import { TaskService } from 'src/app/services/task.service';

@Component({
  selector: 'tm-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss']
})
export class HomeComponent implements OnInit {
  tasks: Task[] = [];
  newTaskTitle: string = '';
  message: string = 'Fetching tasks...';

  constructor(private taskService: TaskService, private cdr: ChangeDetectorRef) { }

  ngOnInit() {
    this.findAllTasks();
  }

  findAllTasks(): void {
    this.taskService.getTasks().subscribe({
      next: (tasks) => {
        console.log("tasks retrieved", tasks);
        this.tasks = tasks;
        this.message = this.tasks.length > 0 ? '' : 'No tasks found';
        this.cdr.detectChanges();
      },
      error: (error) => {
        console.error("Error fetching tasks", error);
        this.message = 'Error fetching tasks';
        this.cdr.detectChanges();
      },
    });
  }
  
}
