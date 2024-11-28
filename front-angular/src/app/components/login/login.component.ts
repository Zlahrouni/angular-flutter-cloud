import { Component } from '@angular/core';
import { AuthService } from '../../services/auth.service';
import { Router, RouterLink } from '@angular/router';
import {FormBuilder, FormGroup, ReactiveFormsModule, Validators} from '@angular/forms';

@Component({
  selector: 'tm-login',
  standalone: true,
  templateUrl: './login.component.html',
  imports: [
    ReactiveFormsModule,
    RouterLink
  ],
  styleUrls: ['./login.component.scss']
})
export class LoginComponent {
  loginForm: FormGroup;

  constructor(
    private authService: AuthService,
    private router: Router,
    private fb: FormBuilder
  ) {
    this.loginForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required]]
    });
  }

  async onSubmit() {
    if (this.loginForm.valid) {
      try {
        const { email, password } = this.loginForm.value;
        await this.authService.login(email, password);
        await this.router.navigate(['']);
      } catch (error) {
        console.error('Erreur de connexion:', error);
      }
    }
  }

  async loginWithGoogle() {
    try {
      await this.authService.loginWithGoogle();
      await this.router.navigate(['']);
    } catch (error) {
      console.error('Erreur de connexion Google:', error);
    }
  }
}
