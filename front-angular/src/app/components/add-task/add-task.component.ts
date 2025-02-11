// In `add-task.component.ts`
import {Component, Input, OnInit} from '@angular/core';
import {FormBuilder, FormControl, FormGroup, ReactiveFormsModule, Validators} from "@angular/forms";
import { TaskService } from "../../services/task.service";
import {CommonModule} from "@angular/common";
import { AuthService } from 'src/app/services/auth.service';
import { map, take } from 'rxjs';
import { Router } from '@angular/router';

@Component({
  selector: 'tm-add-task',
  templateUrl: './add-task.component.html',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  styleUrls: ['./add-task.component.scss']
})
export class AddTaskComponent implements OnInit {
  @Input() title?: string;
  @Input() description?: string;

  form!: FormGroup;
  messageErrors: string[] = [];
  user$ = this.authservice.user$;
  author$ = this.authservice.user$.pipe(map(user => user?.email));

  constructor(
    private fb: FormBuilder,
    private taskService: TaskService,
    private authservice: AuthService,
    private router: Router 
  ) {

  }

  ngOnInit() {
    this.form = this.fb.group({
      title: new FormControl('', [Validators.required, Validators.maxLength(20)]),
      description: new FormControl('', [Validators.required, Validators.minLength(10)]),
    });
  }

  async submitNewTask() {
    console.log('Started');
    this.messageErrors = [];

    if (this.form.invalid) {
      if (this.form.get('title')!.hasError('required')) {
        this.messageErrors.push('Title is required.');
      }
      if (this.form.get('title')!.hasError('maxlength')) {
        this.messageErrors.push('Title cannot be more than 20 characters.');
      }
      if (this.form.get('description')!.hasError('required')) {
        this.messageErrors.push('Description is required.');
      }
      if (this.form.get('description')!.hasError('minlength')) {
        this.messageErrors.push('Description must be at least 10 characters long.');
      }

      console.log('Message Error : ', this.messageErrors);

      return;
    }

    const title = this.form.get('title')!.value;
    const description = this.form.get('description')!.value;


    this.author$.pipe(
      take(1)
    ).subscribe(async author => {
      await this.taskService.addTask(title, description, author as string).subscribe();
    });

    await this.router.navigate(['']);
    
  }
}
