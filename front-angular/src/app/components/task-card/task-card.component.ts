import {Component, Input} from '@angular/core';
import {DateformatorPipe} from "../../pipes/dateformator.pipe";
import {TaskService} from "../../services/task.service";
import {MatDialog} from "@angular/material/dialog";
import {ConfirmDialogComponent} from "../confirm-dialog/confirm-dialog.component";
import {TruncatePipe} from "../../truncate.pipe";
import {RouterLink} from "@angular/router";
import { SmartTruncatePipe } from 'src/app/pipes/smart-truncate.pipe';
import { AuthService } from 'src/app/services/auth.service';
import { map, Observable } from 'rxjs';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'tm-task-card',
  standalone: true,
  imports: [DateformatorPipe, TruncatePipe, RouterLink, SmartTruncatePipe, CommonModule],
  templateUrl: './task-card.component.html',
  styleUrls: ['./task-card.component.scss']
})
export class TaskCardComponent {
  @Input() title?: string;
  @Input() description?: string;
  @Input() status?: string;
  @Input() id?: string;
  @Input() date?: string;
  @Input() author?: string;

  currentUserEmail$: Observable<string | null | undefined> = this.authService.user$.pipe(
    map(user => user?.email)
  );

  canDelete$: Observable<boolean> = this.currentUserEmail$.pipe(
    map(email => email === this.author)
  );

  constructor(
    private readonly taskService: TaskService, 
    private dialog: MatDialog, 
    private authService: AuthService
  ) {}

  deleteTask(id: string) {
    const dialogRef = this.dialog.open(ConfirmDialogComponent);

    dialogRef.afterClosed().subscribe((result: any) => {
      if (result) {
        this.taskService.deleteTask(id).subscribe();
      }
    });
  }



}