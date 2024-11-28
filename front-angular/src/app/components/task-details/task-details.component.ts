import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import {FormBuilder, FormGroup, FormsModule, ReactiveFormsModule, Validators} from '@angular/forms';
import { Task } from '../../models/task-model';
import { TaskService } from '../../services/task.service';
import { DateformatorPipe } from '../../pipes/dateformator.pipe';
import { ConfirmDialogComponent } from '../confirm-dialog/confirm-dialog.component';
import { MatDialog } from '@angular/material/dialog';
import {CommonModule, NgIf} from "@angular/common";
import { map, Observable } from 'rxjs';
import { AuthService } from 'src/app/services/auth.service';

@Component({
  selector: 'tm-task-details',
  standalone: true,
  templateUrl: './task-details.component.html',
  imports: [
    DateformatorPipe,
    ReactiveFormsModule,
    NgIf,
    FormsModule,
    CommonModule
  ],
  styleUrls: ['./task-details.component.scss']
})
export class TaskDetailsComponent implements OnInit {
  taskForm: FormGroup;
  task?: Task;
  editMode = false;
  userAuthEmail = this.authService.getCurrentUser()?.email;


  currentUserEmail$: Observable<string | null | undefined> = this.authService.user$.pipe(
    map(user => user?.email)
  );

  canManage$: Observable<boolean> = this.currentUserEmail$.pipe(
    map(email => email === this.task?.author)
  );
  

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private fb: FormBuilder,
    private taskService: TaskService,
    private authService: AuthService,
    private dialog: MatDialog
  ) {
    this.taskForm = this.fb.group({
      title: ['', Validators.required],
      status: ['', Validators.required],
      description: ['', Validators.required]
    });
  }

  ngOnInit(): void {
    
    let taskId = this.route.snapshot.paramMap.get('id');
    if (taskId == null) {
      this.router.navigate(['/not-found']);
    }
    this.taskService.getTaskById(taskId!).subscribe(task => {
      if (!task) {
        this.router.navigate(['/not-found']);
      }
      this.task = task;
    });
  }

  editTask() {
    this.editMode = !this.editMode;

    if (this.editMode) {
      this.taskForm.setValue({
        title: this.task?.title,
        status: this.task?.status,
        description: this.task?.description
      });
    }
  }

  deleteTask() {
    const dialogRef = this.dialog.open(ConfirmDialogComponent);

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.taskService.deleteTask(this.task?.id!).subscribe({
          next: () => {
            this.router.navigate(['/']);
          },
          error: (error) => {
            console.error('Error deleting task:', error);
          }
        });
      }
    });
  }

  updateTask() {
    if (this.taskForm.valid) {
      this.taskService.updateTask(this.task?.id!, this.taskForm.value).subscribe({
        next: () => {
          this.editMode = false;
        },
        error: (error) => {
          console.error('Error updating task:', error);
        }
      });
    }
  }
}
