import { Injectable } from '@angular/core';
import { TaskModel } from '../models/task-model';

@Injectable({
  providedIn: 'root'
})
export class ServiceService {

  constructor() { }

  addTask(task: TaskModel) {};
  getTasks() {};
  getTaskById(taskId: string) {};
  updateTask(task: TaskModel) {};
  deleteTask(taskId: string) {};
}
