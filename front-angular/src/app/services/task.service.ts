import { Injectable } from '@angular/core';
import {
  Firestore,
  collection,
  collectionData,
  doc,
  docData,
  addDoc,
  updateDoc,
  deleteDoc,
  CollectionReference,
  DocumentReference
} from '@angular/fire/firestore';
import {Observable, from, map, switchMap} from 'rxjs';
import { Task } from '../models/task-model';
import { v4 as uuidv4 } from 'uuid';

@Injectable({
  providedIn: 'root'
})
export class TaskService {
  private readonly taskCollection: CollectionReference<Task>;

  constructor(private readonly firestore: Firestore) {
    this.taskCollection = collection(this.firestore, 'task') as CollectionReference<Task>;
  }

  // Update the addTask method in TaskService to ensure the returned object matches the Task type
  addTask(title: string, description: string): Observable<Task> {
    const taskWithTimestamp: Task = {
      title,
      description,
      status: 'todo',
      date: new Date()
    };

    return from(addDoc(this.taskCollection, taskWithTimestamp)).pipe(
      switchMap(docRef => docData(docRef as DocumentReference<Task>).pipe(
        map(task => ({ id: docRef.id, ...task } as Task))
      ))
    );
  }
  // Get all tasks
  getTasks(): Observable<Task[]> {
    return collectionData(this.taskCollection, { idField: 'id' });
  }

  // Get a task by ID
  getTaskById(taskId: string): Observable<Task | undefined> {
    const taskDocRef: DocumentReference<Task> = doc(this.firestore, 'task', taskId) as DocumentReference<Task>;
    return docData(taskDocRef, { idField: 'id' });
  }

  // Update a task
  updateTask(taskId: string, updates: Partial<Task>): Observable<void> {
    const taskDocRef = doc(this.firestore, 'task', taskId);
    return from(updateDoc(taskDocRef, updates))
      .pipe(
        map(() => {
          console.log('Task successfully updated!');
        })
      );
  }

  // Delete a task
  deleteTask(taskId: string): Observable<void> {
    const taskDocRef = doc(this.firestore, 'task', taskId);
    return from(deleteDoc(taskDocRef))
      .pipe(
        map(() => {
          console.log('Task successfully deleted!');
        })
      );
  }


}
