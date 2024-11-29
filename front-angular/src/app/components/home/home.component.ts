import { ChangeDetectorRef, Component, OnInit } from '@angular/core';
import { Task } from 'src/app/models/task-model';
import { AuthService } from 'src/app/services/auth.service';
import { TaskService } from 'src/app/services/task.service';
import {  switchMap, map } from 'rxjs';

@Component({
  selector: 'tm-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss']
})
export class HomeComponent implements OnInit {
  tasks: Task[] = [];
  filteredTasks: Task[] = [];
  message: string = 'Fetching tasks...';
  showMyTasks = true;

  constructor(
    private taskService: TaskService,
    private authService: AuthService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit() {
    this.findAllTasks();
  }

  findAllTasks(): void {
    this.taskService.getTasks().pipe(
      switchMap(tasks => this.authService.user$.pipe(
        map(user => ({ tasks, user }))
      ))
    ).subscribe({
      next: ({ tasks, user }) => {
        this.tasks = tasks;
        this.filteredTasks = this.showMyTasks && user 
          ? tasks.filter(task => task.author === user.email)
          : tasks;
        this.message = this.tasks.length > 0 ? '' : 'No tasks found';
        this.cdr.detectChanges();
      },
      error: (error) => {
        console.error("Error fetching tasks", error);
        this.message = 'Error fetching tasks';
        this.cdr.detectChanges();
      }
    });
  }

  toggleFilter() {
    this.showMyTasks = !this.showMyTasks;
    this.authService.user$.pipe(
      map(user => {
        this.filteredTasks = this.showMyTasks && user
          ? this.tasks.filter(task => task.author === user.email)
          : this.tasks;
        this.cdr.detectChanges();
      })
    ).subscribe();
  }
}
  
