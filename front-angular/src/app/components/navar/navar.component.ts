import { Component } from '@angular/core';
import { AuthService } from '../../services/auth.service';
import { OnInit } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'tm-navar',
  templateUrl: './navar.component.html',
  styleUrls: ['./navar.component.scss']
})
export class NavarComponent implements OnInit {
  user$ = this.authService.user$;

  constructor(private authService: AuthService, private router: Router ) { 
    this.user$.subscribe(user => {
      console.log('Current user:', user);
    });
  }

  ngOnInit(){

  }

  async logout() {
    try {
      await this.authService.logout();
      await this.router.navigate(['']);
    } catch (error) {
      console.error('Erreur de déconnexion:', error);
    }
  }

  async gotoLogin(){
    await this.router.navigate(['/login']);
  }

}
