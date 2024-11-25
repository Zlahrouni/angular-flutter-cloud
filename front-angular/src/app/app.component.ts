import { Component, OnInit } from '@angular/core';
import { Observable } from "rxjs";
import { Firestore, collection, collectionData } from '@angular/fire/firestore';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit {
  title = 'front-angular';
  
  constructor(private firestore: Firestore) {}

  getData(): Observable<any[]> {
    const collectionRef = collection(this.firestore, 'task');
    return collectionData(collectionRef, { idField: 'id' });
  }

  ngOnInit(): void {
    this.getData().subscribe(data => {
      console.log(data);
    });
  }
}