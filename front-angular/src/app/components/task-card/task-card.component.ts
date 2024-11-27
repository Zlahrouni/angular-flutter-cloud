import {Component, Input} from '@angular/core';
import {AppModule} from "../../app.module";
import {DateformatorPipe} from "../../pipes/dateformator.pipe";
import {TaskService} from "../../services/task.service";
import {MatDialog} from "@angular/material/dialog";
import {ConfirmDialogComponent} from "../confirm-dialog/confirm-dialog.component";
import {TruncatePipe} from "../../truncate.pipe";
import {RouterLink} from "@angular/router";
import { SmartTruncatePipe } from 'src/app/pipes/smart-truncate.pipe';

@Component({
  selector: 'tm-task-card',
  standalone: true,
  imports: [DateformatorPipe, TruncatePipe, RouterLink, SmartTruncatePipe],
  templateUrl: './task-card.component.html',
  styleUrls: ['./task-card.component.scss']
})
export class TaskCardComponent {
 @Input() title?: string;
 @Input() description?: string;
 @Input() status?: string;
 @Input() id?: string;
 @Input() date?: string;

 constructor(private readonly taskService: TaskService, private dialog: MatDialog) {
 }
  deleteTask(id: string) {
    const dialogRef = this.dialog.open(ConfirmDialogComponent);

    dialogRef.afterClosed().subscribe((result: any) => {
      if (result) {
        this.taskService.deleteTask(id).subscribe();
      }
    });
  }
}
