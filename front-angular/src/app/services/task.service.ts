import { Injectable } from '@angular/core';
import { Task } from '../models/task-model';
import { AngularFirestore, AngularFirestoreCollection, AngularFirestoreDocument } from '@angular/fire/compat/firestore';
import { docData, doc } from '@angular/fire/firestore';
import { map, Observable } from 'rxjs';
@Injectable({
  providedIn: 'root'
})
export class TaskService {

  private taskCollection: AngularFirestoreCollection<Task>;
  taskDoc!: AngularFirestoreDocument<Task>;

  constructor(private db: AngularFirestore) {
    this.taskCollection = db.collection('task');
   }
  
  // Add a new task
  addTask(task: Task) {
    const taskWithTimeatamp = { 
      ...task, 
      date: new Date() 
    };
    return this.taskCollection.add(taskWithTimeatamp)
            .then(() => {
              console.log('Task successfully added!');
            })
            .catch((error) => {console.error('Error adding task: ', error);
              throw error;
            });
  };

  // Get all tasks
  getTasks(): Observable<Task[]> {
    const collectionRef = this.db.collection<Task>('task').snapshotChanges().pipe(
      map(actions => actions.map(a => {
        const data = a.payload.doc.data() as Task;
        const id = a.payload.doc.id;
        return { id, ...data };
      }))
    );
    return collectionRef;
  }  

  // Get a task by ID
  getTaskById(taskId: string): Observable<Task | undefined> {
    const taskDocRef = doc(this.db.firestore, 'tasks', taskId);
    return docData(taskDocRef, { idField: 'id' }) as Observable<Task>;
  };

  // Update a task
  updateTask(taskId: string, newtitle: string, newdescription: string, newstatus: string) {
    return this.db.collection('tasks').doc(taskId).update({ title: newtitle, description: newdescription, status: newstatus });
  };

  // Delete a task
  deleteTask(taskId: string) {
    return this.db.collection('tasks').doc(taskId).delete()
    .then(() => {
      console.log('Task successfully deleted!');
    })
    .catch((error) => {console.error('Error deleting task: ', error);
      throw error;
    });
  };
}
