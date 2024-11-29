import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../services/auth.service';
import { Router, RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';

@Component({
  selector: 'tm-login',
  standalone: true,
  templateUrl: './login.component.html',
  imports: [
    ReactiveFormsModule,
    RouterLink,
    CommonModule
  ],
  styleUrls: ['./login.component.scss']
})
export class LoginComponent implements OnInit {
  loginForm!: FormGroup;
  messageErrors: string[] = [];

  constructor(
    private authService: AuthService,
    private router: Router,
    private fb: FormBuilder
  ) {}

  ngOnInit() {
    this.loginForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required]]
    });
  }

  async onSubmit() {
    this.messageErrors = [];

    if (this.loginForm.invalid) {
      if (this.loginForm.get('email')?.hasError('required')) {
        this.messageErrors.push("L'adresse email est requise");
      }
      if (this.loginForm.get('email')?.hasError('email')) {
        this.messageErrors.push("L'adresse email n'est pas valide");
      }
      if (this.loginForm.get('password')?.hasError('required')) {
        this.messageErrors.push('Le mot de passe est requis');
      }
      return;
    }

    if (this.loginForm.valid) {
      try {
        const { email, password } = this.loginForm.value;
        await this.authService.login(email, password);
        await this.router.navigate(['']);
      } catch (error: any) {
        this.messageErrors.push(error.message || 'Une erreur est survenue lors de la connexion');
      }
    }
  }

  async loginWithGoogle() {
    try {
      await this.authService.loginWithGoogle();
      await this.router.navigate(['']);
    } catch (error: any) {
      this.messageErrors.push(error.message || 'Une erreur est survenue lors de la connexion avec Google');
    }
  }
}